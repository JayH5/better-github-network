
static class NetworkMeta {
  final String nethash;
  final int focus;
  final List<Block> blocks;
  
  static NetworkMeta fetch(String owner, String repo) {
    String path = owner + "/" + repo + "/network_meta";
    URL url = HttpClient.buildURL(HttpClient.GITHUB_OLD_API, path, null);
    JsonElement json = HttpClient.queryJsonService(url);
    return new NetworkMeta((JsonObject) json);
  }
  
  NetworkMeta(JsonObject obj) {
    nethash = getString(obj, "nethash");
    focus = getInt(obj, "focus");
    
    JsonArray blocksJson = obj.getAsJsonArray("blocks");
    blocks = new ArrayList<Block>(blocksJson.size());
    for (JsonElement block : blocksJson) {
      blocks.add(new Block((JsonObject) block));
    }
  }
  
  static class Block implements Comparable<Integer> {
    final String name;
    final int start;
    final int count;
    
    List<NetworkDataChunk.Commit> commits;
    
    Block(JsonObject obj) {
      name = getString(obj, "name");
      start = getInt(obj, "start");
      count = getInt(obj, "count");
      
      commits = new ArrayList<NetworkDataChunk.Commit>();
    }
    
    public void addCommit(NetworkDataChunk.Commit commit) {
      commits.add(commit);
    }
    
    public int compareTo(Integer other) {
      return ((Integer) start).compareTo(other);
    }
  }
}
