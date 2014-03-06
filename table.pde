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
  
  final int REPO_HEIGHT = 70;
  final int COL_WIDTH = 120;
  final int SHADOW_HEIGHT = 5;
  final int TEXT_VERTICAL_OFFSET = 5;
  final int TEXT_HORIZONTAL_OFFSET = 10;
  
  final int x0, y0, x1, y1, rows, rowHeight;
  
  //constructor
  Table(int x0, int y0, int x1, int y1, int rows)
  {
    this.x0 = x0;
    this.y0 = y0;
    this.x1 = x1;
    this.y1 = y1;
    this.rows = rows;
    
    // Calculate row height
    rowHeight = (y1 - y0 - REPO_HEIGHT) / rows;

    drawTable();
    drawRepo();
    
    
    rowList = new ArrayList<Row>(rows);
  }
  
  void setRepoName(String name) {
    fill(0);
    text(name, TEXT_HORIZONTAL_OFFSET, REPO_HEIGHT / 2 + TEXT_VERTICAL_OFFSET);
  }
  
  void setForkName(int row, String name) {
    fill(0);
    int y = REPO_HEIGHT + rowHeight * row + rowHeight / 2 + TEXT_VERTICAL_OFFSET;
    text(name, TEXT_HORIZONTAL_OFFSET, y);
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
    fill(28, 30, 32);
    rect(0, 0, width, REPO_HEIGHT);
    fill(255, 192);
    rect(0, 0, COL_WIDTH, REPO_HEIGHT);
    
    int ruleY0 = REPO_HEIGHT - 5;
    int markY0 = REPO_HEIGHT - 3;
    int textY = REPO_HEIGHT - 10;
    int monthWidth = (x1 - x0 - COL_WIDTH) / 12;
    int monthMarks = monthWidth / 5;
    int padding = 40;
    for (int i = 0; i < 12; i++)
    {
      int xStart = x0 + padding + COL_WIDTH + monthWidth * i;
      
      // Draw ruler measure
      stroke(192);
      strokeWeight(2);
      noFill();
      line(xStart, ruleY0, xStart, REPO_HEIGHT);
      
      // Ruler marks inbetween
      strokeWeight(1);
      for (int j = 0; j < 5; j++) {
        int xMark = xStart + j * monthMarks;
        line(xMark, markY0, xMark, REPO_HEIGHT);
      }
      
      // Draw month name
      fill(192);
      String month = months[i];
      int offset = (int) ((month.length() / 3.0f) * 10);
      text(months[i], xStart - offset, textY);
    }
   
    // Draw gradient
    linearGradient(x0, REPO_HEIGHT, x1 - x0, SHADOW_HEIGHT,
        color(28, 30, 32, 128), color(28, 30, 32, 0));
        
    int paddingVisTop = 15;
    int paddingVisBottom = 40;
    int paddingVisRight = 10;
    fill(255);
    rect(x0 + padding + COL_WIDTH, paddingVisTop, x1 - paddingVisRight, REPO_HEIGHT - paddingVisBottom);
  }
   
  void drawForks()
  {
   
  }
   
  
  void drawTable() {    
    int rowHeight = (y1 - y0 - REPO_HEIGHT) / rows;
    noStroke();
    for (int i = 0; i < rows; i++) {
      if (i % 2 == 0) {
        fill(211,211,211);
      } else {
        fill(229,229,229);
      }
      rect(0, REPO_HEIGHT + i * rowHeight, COL_WIDTH, (i + 1) * rowHeight);
    }

    stroke(0);
    strokeWeight(1);
    noFill();
    for (int i = 1; i <= rows; i++) {
      int y = i * rowHeight + REPO_HEIGHT;
      line(0, y, width, y);
    }
  }
  
  class Row
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
