import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

class Table
{
  final int ROWS=10, ROW_HEIGHT=10,HEIGHT=720;
  final ArrayList<Row> rowList;
  final String[] months = { "Apr '13", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "Jan '14", "Feb", "Mar" };
  
  Row repo;
  
  //constructor
  Table()
  {
    rowList = new ArrayList<Row>();
  }
  
  void setRepo(String repo_name, List<Integer> activityList)
  {
    repo = new Row(repo_name, activityList);
  }
  
  void addRow(String fork_name, List<Integer> activityList)
  {
    rowList.add(new Row(fork_name, activityList));
  }

   //Draw repo stats with Months below
   //Draw a fork
   //Draw all 
  void drawRepo()
  {
    noStroke();
    fill(140,255,253);
    rect(0,40,100,40);
    stroke(0);
    noFill();
     
    int count = 0;
    for (String month : months)
    {
      count++;
      noStroke();
      fill(200,200,253);
      rect(100 + 60*(count),40, 60, 30);
      fill(0,0,0);
      stroke(2);
      line(100 + 60*(count), 40, 100 + 60 * count, 69);
      //text
      //       fill(255,255,255);
      text(month, 125 + 60*count, 50);
    }   
  }
   
  void drawForks()
  {
   
  }
   
  
  void drawTable(int ROW_HEIGHT) {
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
  
  static class Row
  {
    String name;
    List<Integer> acitivityList;
    
    Row(String name, List<Integer> acitivityList)
    {
      this.name = name; 
      this.acitivityList = acitivityList;      
    }    
  }
}
