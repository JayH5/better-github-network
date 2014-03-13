import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.util.ArrayList;
import java.util.Collections;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

int WIDTH = 1024;
int HEIGHT = 600;
int NUM_ROWS = 12;

String DEFAULT_OWNER = "square";
String DEFAULT_REPO = "picasso";
String DEFAULT_BRANCH = "master";
int NUMBER_FORK_BRANCHES = 2;
int NETWORK_DATA_CHUNK_SIZE = 200;

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

NetworkMeta networkMeta;
List<NetworkDataChunk> networkDataChunks;
boolean deliverNetworkMeta = false;
boolean deliverNetworkDataChunks = false;

Table table;

void setup() {
  size(WIDTH, HEIGHT);
  background(255);
  smooth();
  
  // Draw table for 1st week of February
  Calendar cal = new GregorianCalendar(2014, Calendar.FEBRUARY, 1);
  Date start = cal.getTime();
  cal.add(Calendar.MONTH, 2);
  Date end = cal.getTime();

  table = new Table(0, 0, width, height, NUM_ROWS, start, end);
  
  // Fetch data
  thread("fetchRepo");
  thread("fetchCommitActivity");
  thread("fetchNetworkMeta");
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
      table.setRepoCommitActivity(commitActivity);
    }
    thread("fetchCodeFrequency");
    deliverCommitActivity = false;
  }
  if (deliverCodeFrequency) {
    if (codeFrequency != null) {
      table.setRepoCodeFrequency(codeFrequency);
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
  
  if (deliverNetworkMeta) {
    if (networkMeta != null) {
      List<NetworkMeta.Block> blocks = networkMeta.blocks;
      int rows = Math.min(blocks.size(), NUM_ROWS);
      for (int i = 0; i < rows; i++) {
        table.setForkName(i, blocks.get(i).name);
      }
      thread("fetchNetworkDataChunks");
    }
    deliverNetworkMeta = false;
  }
  if (deliverNetworkDataChunks) {
    if (networkDataChunks != null) {      
      // Draw commits
      List<NetworkMeta.Block> blocks = networkMeta.blocks;
      int rows = Math.min(blocks.size(), NUM_ROWS);
      for (int i = 0; i < rows; i++) {
        table.setBlockData(i, blocks.get(i).commits);
      }
    }
    deliverNetworkDataChunks = false;
  }
}

void fetchRepo() {
  println("Fetching repo...");
  repo = Repo.fetch(DEFAULT_OWNER, DEFAULT_REPO);
  println("Repo delivered");
  deliverRepo = true;
}

void fetchBranches() {
  println("Fetching branches...");
  branches = Branches.fetch(DEFAULT_OWNER, DEFAULT_REPO);
  println("Branches delivered");
  deliverBranches = true;
}  

void fetchForks() {
  println("Fetching forks...");
  forks = Forks.fetch(DEFAULT_OWNER, DEFAULT_REPO, NUM_ROWS);
  println("Forks delivered");
  deliverForks = true;
}

void fetchNetworkMeta() {
  println("Fetching network meta...");
  networkMeta = NetworkMeta.fetch(DEFAULT_OWNER, DEFAULT_REPO);
  println("Network meta delivered");
  deliverNetworkMeta = true;
}

void fetchNetworkDataChunks() {
  println("Fetching network data chunks...");
  int remaining = networkMeta.focus;
  int chunks = Math.round((float) remaining / NETWORK_DATA_CHUNK_SIZE);
  networkDataChunks = new ArrayList<NetworkDataChunk>(chunks);
  for (int i = 0; i < chunks; i++) {
    int start = Math.max(remaining - NETWORK_DATA_CHUNK_SIZE, 0);
    int end = remaining;
    println("Fetching network data chunk " + i + " {" + start + " -> " + end + "}");
    networkDataChunks.add(NetworkDataChunk.fetch(DEFAULT_OWNER, DEFAULT_REPO, networkMeta.nethash, start, end));
    remaining -= (end - start);
  }
  println("Network data chunks delivered");
  println("Sorting data points into blocks...");
  // Sort columns into blocks
  for (NetworkDataChunk chunk : networkDataChunks) {
    List<NetworkDataChunk.Commit> commits = chunk.commits;
    List<NetworkMeta.Block> blocks = networkMeta.blocks;
    for (NetworkDataChunk.Commit commit : commits) {
      int pos = Collections.binarySearch(blocks, commit.space);
      if (pos < 0) {
        pos = -pos - 2;
      }
      if (pos >= 0 && pos < blocks.size()) {
        blocks.get(pos).addCommit(commit);
      }
      //println("Commit added to block " + pos);
    }
  }
  println("Done sorting");
  deliverNetworkDataChunks = true;
}

void fetchCommitActivity() {
  println("Fetching commit activity...");
  commitActivity = CommitActivity.fetch(DEFAULT_OWNER, DEFAULT_REPO);
  println("Commit activity delivered");
  deliverCommitActivity = true;
}

void fetchCodeFrequency() {
  println("Fetching code frequency...");
  codeFrequency = CodeFrequency.fetch(DEFAULT_OWNER, DEFAULT_REPO);
  println("Code frequency delivered");
  deliverCodeFrequency = true;
}

void fetchForkBranches() {
  println("Fetching branches...");
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



