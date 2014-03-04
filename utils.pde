import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;

static final DateFormat ISO8601 = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
      
static Date parseDate(String dateString) {
  Date date = null;
  try {
    date = ISO8601.parse(dateString);
  } catch (ParseException e) {
    println("Couldn't parse date!");
  }
  return date;
}

static String getString(JsonObject obj, String key) {
  return obj.getAsJsonPrimitive(key).getAsString();
}

static int getInt(JsonObject obj, String key) {
  return obj.getAsJsonPrimitive(key).getAsInt();
}
