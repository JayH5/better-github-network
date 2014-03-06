import com.google.gson.JsonArray;
import com.google.gson.JsonElement;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

static class CodeFrequency implements Iterable<CodeFrequency.Diff> {
  final List<Diff> weeks;
  
  static CodeFrequency fetch(String owner, String repo) {
    JsonElement json = HttpClient.queryGithub("repos/" + owner + "/" + repo + "/stats/code_frequency", null);
    return new CodeFrequency((JsonArray) json);
  }
  
  CodeFrequency(JsonArray json) {
    weeks = new ArrayList<Diff>(json.size());
    for (JsonElement jsonWeek : json) {
      weeks.add(new Diff((JsonArray) jsonWeek));
    }
  }
  
  Iterator<Diff> iterator() {
    return weeks.iterator();
  }
  
  public int size() {
    return weeks.size();
  }
  
  public Diff get(int position) {
    return weeks.get(position);
  }
  
  static class Diff {
    final Date week;
    final int additions;
    final int deletions;
    
    Diff(JsonArray json) {
      week = new Date(json.get(0).getAsLong() * 1000);
      additions = json.get(1).getAsInt();
      deletions = json.get(2).getAsInt();
    }
  }
}
