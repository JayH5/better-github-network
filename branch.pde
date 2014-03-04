import com.google.gson.JsonObject;

static class Branch {
  final String name;
  final String commitSha;
  final String commitUrl;
  
  Branch(JsonObject json) {
    name = json.getAsJsonPrimitive("name").getAsString();
    
    JsonObject commit = json.getAsJsonObject("commit");
    commitSha = commit.getAsJsonPrimitive("sha").getAsString();
    commitUrl = commit.getAsJsonPrimitive("url").getAsString();
  }
  
  @Override
  public boolean equals(Object obj) {
    if (obj instanceof Branch) {
      Branch branch = (Branch) obj;
      return name.equals(branch.name) && commitSha.equals(branch.commitSha);
    }
    return false;
  }
}
