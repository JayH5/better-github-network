import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import java.util.Iterator;

static class Branches implements Iterable<Branch> {
  
  static Branches fetch(String owner, String repo) {
    JsonElement json = HttpClient.queryGithub("repos/" + owner + "/" + repo + "/branches", null);
    return new Branches((JsonArray) json);
  }
  
  final List<Branch> branches;
  
  Branches(JsonArray json) {
    branches = new ArrayList<Branch>(json.size());
    for (JsonElement jsonBranch : json) {
      branches.add(new Branch((JsonObject) jsonBranch));
    }
  }
  
  Iterator<Branch> iterator() {
    return branches.iterator();
  }
}
