import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

int WIDTH = 1024;
int HEIGHT = 600;
int NUM_ROWS = 15;

String DEFAULT_OWNER = "square";
String DEFAULT_REPO = "picasso";
String DEFAULT_BRANCH = "master";
int NUMBER_FORK_BRANCHES = 2;

Repo repo;
Branches branches;
CommitActivity commitActivity;
CodeFrequency codeFrequency;
boolean deliverRepo = false;
boolean deliverBranches = false;
boolean deliverCommitActivity = false;
boolean deliverCodeFrequency = false;

Forks forks;
Map<Fork, Branches> forkBranches;
boolean deliverForks = false;
boolean deliverForkBranches = false;

Table table;

void setup() {
  size(WIDTH, HEIGHT);
  background(255);
  smooth();

  table = new Table(0, 0, width, height, NUM_ROWS);
  
  // Fetch data
  thread("fetchRepo");
  //thread("fetchBranches");
  //thread("fetchCommitActivity");
  //thread("fetchCodeFrequency");
  //thread("fetchForks");  // Uncomment to fetch fork names
}

void draw() {
  checkDeliveries();
}

void checkDeliveries() {
  if (deliverRepo) {
    if (repo != null) {
      table.setRepoName(repo.fullName);
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
      List<Fork> forkList = forks.forks;
      int rows = Math.min(forkList.size(), NUM_ROWS);
      for (int i = 0; i < rows; i++) {
        table.setForkName(i, forkList.get(i).ownerLogin);
      } 
    }
    deliverForks = false;
  }
  if (deliverForkBranches) {
    if (forkBranches != null) {
      // TODO: do something with branches
    }
  }
}

void fetchRepo() {
  repo = Repo.fetch(DEFAULT_OWNER, DEFAULT_REPO);
  deliverRepo = true;
}

void fetchBranches() {
  branches = Branches.fetch(DEFAULT_OWNER, DEFAULT_REPO);
  deliverBranches = true;
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

void fetchForkBranches() {
  forkBranches = new HashMap<Fork, Branches>();
  int forkCount = Math.min(forks.forks.size(), NUMBER_FORK_BRANCHES);
  List<Fork> forksList = forks.forks.subList(0, forkCount);
  for (Fork fork : forksList) {
    forkBranches.put(fork, Branches.fetch(fork));
  }
  deliverForkBranches = true;
}

// WIP
/*void fetchBranchCompare() {
  for (Map.Entry forkBranch : forkBranches) {
    Fork fork = (Fork) forkBranch.getKey();
    Branches branches = (Branches) forkBranch.getValue();
    String forkName = fork.ownerLogin;
  }
}*/



