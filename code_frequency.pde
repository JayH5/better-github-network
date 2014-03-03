import com.google.gson.JsonArray;
import com.google.gson.JsonElement;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

static class CodeFrequency implements Iterable<Integer> {
  final List<Integer> days;
  CodeFrequency(JsonArray json) {
    days = new ArrayList<Integer>(json.size() * 7);
    for (JsonElement jsonWeek : json) {
      JsonArray week = (JsonArray) jsonWeek;
      for (JsonElement day : week) {
        days.add(day.getAsInt());
      }
    }
  }
  
  Iterator<Integer> iterator() {
    return days.iterator();
  }
}
