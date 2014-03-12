
static class NetworkMeta {
  final String nethash;
  final List<Block> blocks;
  
  static NetworkMeta fetch(String owner, String repo) {
    String path = owner + "/" + repo + "/network_meta";
    URL url = HttpClient.buildURL(HttpClient.GITHUB_OLD_API, path, null);
    JsonElement json = HttpClient.queryJsonService(url);
    return new NetworkMeta((JsonObject) json);
  }
  
  NetworkMeta(JsonObject obj) {
    nethash = getString(obj, "nethash");
    
    JsonArray blocksJson = obj.getAsJsonArray("blocks");
    blocks = new ArrayList<Block>(blocksJson.size());
    for (JsonElement block : blocksJson) {
      blocks.add(new Block((JsonObject) block));
    }
  }
  
  static class Block {
    final String name;
    final int start;
    final int count;
    
    Block(JsonObject obj) {
      name = getString(obj, "name");
      start = getInt(obj, "start");
      count = getInt(obj, "count");
    }
  }
}
