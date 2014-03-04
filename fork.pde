import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.util.Date;

static class Fork {
  final long id;
  final String fullName;
  final String url;
  final String createdAt;
  
  final String ownerLogin;

  Fork(JsonObject jsonFork) {
    id = jsonFork.getAsJsonPrimitive("id").getAsLong();
    fullName = jsonFork.getAsJsonPrimitive("full_name").getAsString();
    url = jsonFork.getAsJsonPrimitive("url").getAsString();    
    createdAt = jsonFork.getAsJsonPrimitive("created_at").getAsString();
    
    JsonObject owner = jsonFork.getAsJsonObject("owner");
    ownerLogin = owner.getAsJsonPrimitive("login").getAsString();
  }
  
  Date getCreatedAtDate() {
    return parseDate(createdAt);
  }
}
