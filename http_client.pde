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

static class HttpClient {
  
  static final String GITHUB_API = "https://api.github.com/";
  
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
      conn = (HttpURLConnection) url.openConnection();
      if (conn.getResponseCode() == 200) {
        json = parser.parse(new InputStreamReader(conn.getInputStream()));
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
      println(sb.toString());
      return new URL(sb.toString());
    } catch (MalformedURLException e) {
      println("Malformed URL!");
    }
    return null;
  }
}
