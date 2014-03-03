import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.util.ArrayList;
import java.util.List;

int WIDTH = 1280;
int HEIGHT = 720;
int ROW_HEIGHT = 40;
int STROKE_WIDTH = 10;

Repo repo;
Forks forks;
CommitActivity commitActivity;
boolean deliverRepo = false;
boolean deliverForks = false;
boolean deliverCommitActivity = false;

void setup() {
  size(WIDTH, HEIGHT);
  background(255);
  smooth();

  table();
  thread("fetchRepo");
  thread("fetchForks");
  thread("fetchCommitActivity");
}

void draw() {
  if (deliverRepo) {
    if (repo != null) {
      fill(0);
      // TODO: Do something with repo data
    }
    deliverRepo = false;
  }
  if (deliverForks) {
    if (forks != null) {
      fill(0);
      int rows = height / ROW_HEIGHT;
      int row = 0;
      for (Fork fork : forks) {
        text(fork.ownerLogin, 10, row * ROW_HEIGHT + ROW_HEIGHT / 2);
        if (++row == rows) {
          break;
        }
      }
    }
    deliverForks = false;
  }
  if (deliverCommitActivity) {
    if (commitActivity != null) {
      fill(0);
      int rows = height / ROW_HEIGHT;
      int row = 0;
      for (Integer dayCommits : commitActivity) {
        // TODO: Draw commit activity
        if (++row == rows) {
          break;
        }
      }
    }
    deliverCommitActivity = false;
  }
}

void fetchRepo() {
  JsonElement repoJson = HttpClient.queryGithub("repos/square/picasso", null);
  repo = new Repo((JsonObject) repoJson);
  deliverRepo = true;
}
  

void fetchForks() {
  JsonElement forksJson = HttpClient.queryGithub("repos/square/picasso/forks", null);
  forks = new Forks((JsonArray) forksJson);
  deliverForks = true;
}

void fetchCommitActivity() {
  JsonElement commitActivityJson = HttpClient.queryGithub("repos/square/picasso/stats/commit_activity", null);
  commitActivity = new CommitActivity((JsonArray) commitActivityJson);
  deliverCommitActivity = true;
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


