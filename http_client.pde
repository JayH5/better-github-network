import com.google.gson.JsonElement;
import com.google.gson.JsonParser;

import java.io.InputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLEncoder;
import java.net.MalformedURLException;
import java.net.HttpURLConnection;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

static class HttpClient {
  
  static final String GITHUB_API = "https://api.github.com/";
  static final String GITHUB_OLD_API = "https://github.com/";
  static final int MAX_PAGES = 10;
  static final Pattern GITHUB_NEXT_LINK_PATTERN = Pattern.compile("<(.*)>; rel=\"next\"");
  static final long RETRY_DELAY = 2000; // 2 seconds
  
  /** 
   * Perform a query against the Github API returning the JSON response.
   * @param path the query path, e.g. "repos/square/picasso"
   * @param params the unescaped query parameters
   */
  static JsonElement queryGithub(String path, Map<String, String> params) {
    return queryJsonService(buildURL(GITHUB_API, path, params));
  }
  
  static JsonElement queryJsonService(URL url) {
    JsonParser parser = new JsonParser();
    HttpURLConnection conn =  null;
    JsonElement json = null;
    try {
      conn = openConnection(url);
      int responseCode = conn.getResponseCode();
      println("Connection opened to url " + url + " with response code " + responseCode);
      if (responseCode == 200) {
        json = parser.parse(new InputStreamReader(conn.getInputStream()));
      } else if (responseCode == 202) { // Data not ready, wait a bit and try again
        try {
          Thread.sleep(RETRY_DELAY);
          return queryJsonService(url);
        } catch (InterruptedException ignored) {
        }
        return queryJsonService(url);
      }
    } catch(IOException e) {
      println("Damn. Some kinda error occurred: " + e.getMessage());
    } finally {
      if (conn != null) {
        conn.disconnect();
      }
    }
    return json;
  }
  
  /**
   * Query github for a paginated response (e.g. list of forks).
   * @param required the minimum number of elements desired. Once this required number is met no
   *   further pages will be downloaded.
   */
  static List<JsonArray> queryGithubPaginated(String path, Map<String, String> params, int required) {
    JsonParser parser = new JsonParser();
    List<JsonArray> pages = new ArrayList<JsonArray>();
    
    URL currentURL = buildURL(GITHUB_API, path, params);
    int count = 0;
    // Loop through the pages while URL not null and we haven't reached MAX_PAGES
    for (int i = 0; i < MAX_PAGES; i++) {
      if (currentURL == null) {
        break;
      }
      println("Fetching page " + i);
      
      HttpURLConnection conn = null;
      JsonElement json = null;
      try {
        // Connect to the URL
        conn = openConnection(currentURL);
        int responseCode = conn.getResponseCode();
        println("Connection opened to url " + currentURL + " with response code " + responseCode);
        if (conn != null && responseCode == 200) {
          // If successful parse the JSON response
          json = parser.parse(new InputStreamReader(conn.getInputStream()));
          JsonArray jsonArray = (JsonArray) json;
          // If JSON parsed ok, add it to the list of pages
          if (jsonArray != null) {
            int len = jsonArray.size();
            println("Page downloaded with length " + len);
            count += len;
            println("Elements downloaded: " + count + "/" + required);
            pages.add(jsonArray);
            
            if (count >= required) {
              break;
            }
          }
        }
        // Get the URL for the next page from the headers
        currentURL = parseNextGithubLink(conn.getHeaderField("Link"));
        println("Link to next page: " + currentURL);
      } catch (IOException e) {
        println("Connection error! " + e.getMessage());
        break;
      } catch (ClassCastException e) {
        println("Received JSON was not an array!");
        break;
      } finally {
        if (conn != null) {
          conn.disconnect();
        }
      }
    }
    return pages;
  }
  
  private static URL parseNextGithubLink(String link) {
    if (link == null) {
      return null;
    }
    URL url = null;
    String[] links = link.split(",");
    String urlString = null;
    for (String l : links) {
      Matcher matcher = GITHUB_NEXT_LINK_PATTERN.matcher(l);
      if (matcher.matches()) {
        urlString = matcher.group(1);
        break;
      }
    }
    
    if (urlString != null) {
      try {
        url = new URL(urlString);
      } catch (MalformedURLException ignored) {
      }
    }
    
    return url;
  }
  
  private static HttpURLConnection openConnection(URL url) throws IOException {
    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
    conn.setInstanceFollowRedirects(true);
    return conn;
  }
  
  static URL buildURL(String host, String path, Map<String, String> params) {
    StringBuilder sb = new StringBuilder();
    sb.append(host);
    if (host != null) {
      sb.append(path);
    }
    if (params != null && !params.isEmpty()) {
      sb.append("?");
      // Bug in Processing means we can't do Map.Entry<String, String>
      // See: https://github.com/processing/processing/issues/1600
      for (Map.Entry param : params.entrySet()) {
        sb.append(URLEncoder.encode((String) param.getKey()))
          .append("=")
          .append(URLEncoder.encode((String) param.getValue()))
          .append("&");
      }
    }
    try {
      return new URL(sb.toString());
    } catch (MalformedURLException e) {
      println("Malformed URL!");
    }
    return null;
  }
}
