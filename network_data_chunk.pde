
static class NetworkDataChunk {
  final List<Commit> commits;
  
  static NetworkDataChunk fetch(String owner, String repo, String nethash) {
    String path = owner + "/" + repo + "/network_data_chunk";
    Map<String, String> params = new HashMap<String, String>();
    params.put("nethash", nethash);
    URL url = HttpClient.buildURL(HttpClient.GITHUB_OLD_API, path, params);
    JsonElement json = HttpClient.queryJsonService(url);
    return new NetworkDataChunk((JsonObject) json);
  }
  
  static NetworkDataChunk fetch(String owner, String repo, String nethash, int start, int end) {
    String path = owner + "/" + repo + "/network_data_chunk";
    Map<String, String> params = new HashMap<String, String>();
    params.put("nethash", nethash);
    params.put("start", String.valueOf(start));
    params.put("end", String.valueOf(end));
    URL url = HttpClient.buildURL(HttpClient.GITHUB_OLD_API, path, params);
    JsonElement json = HttpClient.queryJsonService(url);
    return new NetworkDataChunk((JsonObject) json);
  }
  
  NetworkDataChunk(JsonObject json) {
    JsonArray commitsJson = json.getAsJsonArray("commits");
    commits = new ArrayList<Commit>(commitsJson.size());
    for (JsonElement commit : commitsJson) {
      commits.add(new Commit((JsonObject) commit));
    }
  }
  
  static class Commit implements Comparable<Commit> {
    final String id;
    final List<Parent> parents;
    final int space;
    final int time;
    final String date;
    
    static final DateFormat GITHUB_DATE = new SimpleDateFormat("yyyy-MM-dd' 'HH:mm:ss");
    
    Commit(JsonObject obj) {
      id = getString(obj, "id");
      space = getInt(obj, "space");
      time = getInt(obj, "time");
      date = getString(obj, "date");
      
      JsonArray parentsJson = obj.getAsJsonArray("parents");
      parents = new ArrayList<Parent>(parentsJson.size());
      for (JsonElement parent : parentsJson) {
        parents.add(new Parent((JsonArray) parent));
      }
    }
    
    public Date getDate() {
      Date dateDate = null;
      try {
        dateDate = GITHUB_DATE.parse(date);
      } catch (ParseException e) {
        println("Couldn't parse date!");
      }
      return dateDate;
    }
    
    public int compareTo(Commit other) {
      return ((Integer) time).compareTo(other.time);
    }
    
    static class Parent {
      final String id;
      final int time;
      final int space;
      
      Parent(JsonArray json) {
        id = json.get(0).getAsString();
        time = json.get(1).getAsInt();
        space = json.get(2).getAsInt();
      }
    }
  }
}
