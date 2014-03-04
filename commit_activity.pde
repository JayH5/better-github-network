import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

static class CommitActivity implements Iterable<Integer> {
  final List<Integer> days;
  
  static CommitActivity fetch(String owner, String repo) {
    JsonElement json =
        HttpClient.queryGithub("repos/" + owner + "/" + repo + "/stats/commit_activity", null);
    return new CommitActivity((JsonArray) json);
  }
  
  CommitActivity(JsonArray json) {
    days = new ArrayList<Integer>(json.size() * 7);
    for (JsonElement weekJson : json) {
      JsonObject week = (JsonObject) weekJson;
      JsonArray daysJson = week.getAsJsonArray("days");
      for (JsonElement dayJson : daysJson) {
        days.add(dayJson.getAsInt());
      }
    }
  }

  Iterator<Integer> iterator() {
    return days.iterator();
  }
}
