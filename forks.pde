import com.google.gson.JsonObject;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

static class Forks implements Iterable<Fork> {
  
  final List<Fork> forks;
  
  static Forks fetch(String owner, String repo) {
    JsonElement json = HttpClient.queryGithub("repos/" + owner + "/" + repo + "/forks", null);
    return new Forks((JsonArray) json);
  }
  
  Forks(JsonArray jsonForks) {
    forks = new ArrayList<Fork>(jsonForks.size());
    for (JsonElement jsonFork : jsonForks) {
      forks.add(new Fork((JsonObject) jsonFork));
    }
  }
  
  Iterator<Fork> iterator() {
    return forks.iterator();
  }
}
