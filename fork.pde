import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

static class Fork {
  final long id;
  final String fullName;
  final String url;
  final String createdAt;
  
  final String ownerLogin;
  boolean committed = false;
  CommitActivity commitActivity;

  static final DateFormat ISO8601 =
      new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");

  Fork(JsonObject jsonFork) {
    id = jsonFork.getAsJsonPrimitive("id").getAsLong();
    fullName = jsonFork.getAsJsonPrimitive("full_name").getAsString();
    url = jsonFork.getAsJsonPrimitive("url").getAsString();    
    createdAt = jsonFork.getAsJsonPrimitive("created_at").getAsString();
    
    JsonObject owner = jsonFork.getAsJsonObject("owner");
    ownerLogin = owner.getAsJsonPrimitive("login").getAsString();
  }
  
  Date getCreatedAtDate() {
    try {
      return ISO8601.parse(createdAt);
    } catch (ParseException e) {
      println("Couldn't parse date!");
    }
    return null;
  }
  
  void fetchCommitActivity() {
    String query = "repos/"+fullName+"/stats/commit_activity";
    //println(query);
    try{
      JsonElement commitActivityJson = HttpClient.queryGithub(query,null);//"repos/square/picasso/stats/commit_activity", null);
      commitActivity = new CommitActivity((JsonArray) commitActivityJson);
    }
    catch(Exception e)
    {
      println("failing on: " + query);
    }
    
    committed=true;
  }
  
   CommitActivity getCommits()
   {
     return commitActivity;
   }
   
   boolean isCommitted()
   {
      return committed;
   }
}
