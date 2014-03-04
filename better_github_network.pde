import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

int WIDTH = 1280;
int HEIGHT = 720;
int ROW_HEIGHT = 40;
int STROKE_WIDTH = 10;

String DEFAULT_OWNER = "square";
String DEFAULT_REPO = "picasso";

Repo repo;
CommitActivity commitActivity;
CodeFrequency codeFrequency;
boolean deliverRepo = false;
boolean deliverCommitActivity = false;
boolean deliverCodeFrequency = false;

Forks forks;
Map<Fork, Branches> forkBranches;
boolean deliverForks = false;
boolean deliverForkBranches = false;

void setup() {
  size(WIDTH, HEIGHT);
  background(255);
  smooth();

  table();
  thread("fetchRepo");
  //thread("fetchCommitActivity");
  //thread("fetchCodeFrequency");
  //thread("fetchForks");  
}

void draw() {
  checkDeliveries();
}

void checkDeliveries() {
  if (deliverRepo) {
    if (repo != null) {
      // TODO: Do something with repo data
    }
    deliverRepo = false;
  }
  if (deliverCommitActivity) {
    if (commitActivity != null) {
      // TODO: display commit activity
    }
    deliverCommitActivity = false;
  }
  if (deliverCodeFrequency) {
    if (codeFrequency != null) {
      // TODO: display code frequency
    }
    deliverCodeFrequency = false;
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
}

void fetchRepo() {
  repo = Repo.fetch(DEFAULT_OWNER, DEFAULT_REPO);
  deliverRepo = true;
}
  

void fetchForks() {
  forks = Forks.fetch(DEFAULT_OWNER, DEFAULT_REPO);
  deliverForks = true;
}

void fetchCommitActivity() {
  commitActivity = CommitActivity.fetch(DEFAULT_OWNER, DEFAULT_REPO);
  deliverCommitActivity = true;
}

void fetchCodeFrequency() {
  codeFrequency = CodeFrequency.fetch(DEFAULT_OWNER, DEFAULT_REPO);
  deliverCodeFrequency = true;
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


