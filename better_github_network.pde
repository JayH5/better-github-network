import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.util.ArrayList;
import java.util.List;

int WIDTH = 640;
int HEIGHT = 480;
int ROW_HEIGHT = 40;
int STROKE_WIDTH = 10;

List<Fork> forks;
boolean threadDelivery = false;

void setup() {
  size(WIDTH, HEIGHT);
  background(255);
  smooth();

  table();
  thread("fetchForks");  
}

void draw() {
  if (threadDelivery) {
    if (forks != null) {
      int rows = height / ROW_HEIGHT;
      fill(0);
      for (int i = 0, n = forks.size(); i < n && i < rows; i++) {
        Fork fork = forks.get(i);
        text(fork.fullName, 10, i * ROW_HEIGHT + ROW_HEIGHT / 2);
      }
    }
    threadDelivery = false;
  }
}

void fetchForks() {
  JsonArray forksJson = (JsonArray) HttpClient.queryGithub("repos/square/picasso/forks", null);
  forks = new ArrayList<Fork>(forksJson.size());
  for (JsonElement forkJson : forksJson) {
    forks.add(new Fork((JsonObject) forkJson));
  }
  threadDelivery = true;
}

void table() {
  noStroke();
  int rows = height / ROW_HEIGHT;
  for (int i = 0; i < rows; i++) {
    if (i % 2 == 0) {
      fill(140,190,253);
    } else {
      fill(120,170,220);
    }
    rect(0, i * ROW_HEIGHT, 100, (i + 1) * ROW_HEIGHT);
  }

  stroke(0);
  noFill();

  for (int i = 0; i < rows; i++) {
    int y = i * ROW_HEIGHT;
    line(0, y, width, y);
  }
}


