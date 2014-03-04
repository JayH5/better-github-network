import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

static class Compare {
  
  final String status;
  final int aheadBy;
  final int behindBy;
  final List<Commit> commits;
  
  static Compare fetch(String owner, String repo, String lhs, String rhs) {
    JsonElement json =
        HttpClient.queryGithub("repos/" + owner + "/" + repo + "/compare/" + lhs + "..." + rhs, null);
    return new Compare((JsonObject) json);
  }
  
  Compare(JsonObject json) {
    status = getString(json, "status");
    aheadBy = getInt(json, "ahead_by");
    behindBy = getInt(json, "behind_by");
    
    JsonArray commitsJson = json.getAsJsonArray("commits");
    commits = new ArrayList<Commit>(commitsJson.size());
    for (JsonElement commitJson : commitsJson) {
      commits.add(new Commit((JsonObject) commitJson));
    }
  }
}
