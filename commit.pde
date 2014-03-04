import com.google.gson.JsonObject;
import java.util.Date;

static class Commit {
  
  final String sha;
  final String url;
  final String authorLogin;
  final String authoredDate;
  final String committerLogin;
  final String committedDate;
  
  Commit(JsonObject json) {
    sha = json.getAsJsonPrimitive("sha").getAsString();
    url = json.getAsJsonPrimitive("url").getAsString();
    
    JsonObject gitCommit = json.getAsJsonObject("commit");
    
    JsonObject gitAuthor = gitCommit.getAsJsonObject("author");
    authoredDate = gitAuthor.getAsJsonPrimitive("date").getAsString();
    
    JsonObject author = json.getAsJsonObject("author");
    authorLogin = author.getAsJsonPrimitive("date").getAsString();
    
    JsonObject gitCommitter = gitCommit.getAsJsonObject("committer");
    committedDate = gitCommitter.getAsJsonPrimitive("login").getAsString();
    
    JsonObject committer = json.getAsJsonObject("committer");
    committerLogin = committer.getAsJsonPrimitive("login").getAsString();
  }
  
  Date getAuthoredDate() {
    return parseDate(authoredDate);
  }
  
  Date getCommittedDate() {
    return parseDate(committedDate);
  }
}
