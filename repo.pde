import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

/** Just a copy of Fork for now. */
static class Repo {
  final long id;
  final String fullName;
  final String url;
  final String createdAt;
  
  final String ownerLogin;

  static final DateFormat ISO8601 =
      new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");

  Repo(JsonObject jsonFork) {
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
}

