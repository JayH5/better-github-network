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
  
  final int REPO_HEIGHT = 100;
  final int COL_WIDTH = 120;
  final int SHADOW_HEIGHT = 5;
  final int TEXT_VERTICAL_OFFSET = 5;
  final int TEXT_HORIZONTAL_OFFSET = 10;
  
  final int MAX_COMMIT_ALPHA = 192;
  final int MIN_COMMIT_ALPHA = 40;
  
  final int x0, y0, x1, y1, rows, rowHeight;
  
  final int x0Graph, y0Graph, x1Graph, y1Graph;
  
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

    int paddingGraphTop = 10;
    int paddingGraphBottom = 25;
    int paddingGraphLeft = 40;
    int paddingGraphRight = 10;
    
    x0Graph = x0 + paddingGraphLeft + COL_WIDTH;
    y0Graph = y0 + paddingGraphTop;
    x1Graph = x1 - paddingGraphRight;
    y1Graph = y0 + REPO_HEIGHT - paddingGraphBottom;

    drawTable();
    drawRepo();    
    
    rowList = new ArrayList<Row>(rows);
  }
  
  void setRepoName(String name) {
    fill(0);
    text(name, TEXT_HORIZONTAL_OFFSET, REPO_HEIGHT / 2 + TEXT_VERTICAL_OFFSET);
  }
  
  void setRepoCommitActivity(CommitActivity commitActivity) {
    int days = commitActivity.size();
    
    // Loop through days, find min/max commits
    int minCommits = Integer.MAX_VALUE;
    int maxCommits = Integer.MIN_VALUE;
    for (int day : commitActivity) {
      if (day != 0) {
        minCommits = Math.min(day, minCommits);
        maxCommits = Math.max(day, maxCommits);
      }
    }
    
    // Calculate the range of commit alpha values
    int commitRange = maxCommits - minCommits;
    int alphaRange = MAX_COMMIT_ALPHA - MIN_COMMIT_ALPHA;
    
    // Calculate the width of a day in the graph
    float dayWidth = (float) (x1Graph - x0Graph) / days;
    
    // Set up to draw
    noFill();
    strokeWeight(dayWidth);
    
    // Calculate positions
    for (int day = 0; day < days; day++) {
      int commits = commitActivity.get(day);
      if (day == 0) {
        continue;
      }
      
      int x = x0Graph + (int) (day * dayWidth + dayWidth / 2);
      float commitIntensity = (float) (commits - minCommits) / commitRange;
      int alpha = (int) (MIN_COMMIT_ALPHA + commitIntensity * alphaRange);
      stroke(0, alpha);
      line(x, y0Graph, x, y1Graph);
    }
  }
  
  void setRepoCodeFrequency(CodeFrequency codeFrequency) {
    // Get the max additions/deletions
    int maxAdditions = 0;
    int maxDeletions = 0;
    for(CodeFrequency.Diff diff : codeFrequency) {
      maxAdditions = Math.max(diff.additions, maxAdditions);
      maxDeletions = Math.min(diff.deletions, maxDeletions);
    }
    
    int weeks = codeFrequency.size();
    float weekWidth = (float) (x1Graph - x0Graph) / weeks;
    
    noFill();
    int halfGraphHeight = (y1Graph - y0Graph) / 2;
    int yMidGraph = y0Graph + halfGraphHeight;
    
    // Draw additions
    noStroke();
    fill(102, 153, 0, 128);
    beginShape();
    vertex(x0Graph, yMidGraph);
    for (int week = 0; week < weeks; week++) {
      int x = x0Graph + (int) (weekWidth * week);
      
      int additions = codeFrequency.get(week).additions;
      float additionIntensity = (float) additions / maxAdditions;
      additionIntensity = decelerateInterpolator(additionIntensity);
      int y = yMidGraph - Math.round(halfGraphHeight * additionIntensity);
      
      println("Drawing curve vertex at (" + x + "," + y + ") for week " + week);
      
      curveVertex(x, y);
    }
    vertex(x1Graph, yMidGraph);
    vertex(x0Graph, yMidGraph); 
    endShape();
    
    // Draw deletions
    fill(204, 0, 0, 128);
    beginShape();
    vertex(x0Graph, yMidGraph);
    for (int week = 0; week < weeks; week++) {
      int x = x0Graph + (int) (weekWidth * week);
      
      int deletions = codeFrequency.get(week).deletions;
      float deletionIntensity = (float) deletions / maxDeletions;
      deletionIntensity = decelerateInterpolator(deletionIntensity);
      int y = yMidGraph + Math.round(halfGraphHeight * deletionIntensity);
      
      println("Drawing curve vertex at (" + x + "," + y + ") for week " + week);
      
      curveVertex(x, y);
    }
    vertex(x1Graph, yMidGraph);
    vertex(x0Graph, yMidGraph);
    endShape();
  }
  
  float decelerateInterpolator(float input) {
    return (float)(1.0f - (1.0f - input) * (1.0f - input));
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
    
    int ruleY0 = y0 + REPO_HEIGHT - 5;
    int markY0 = y0 + REPO_HEIGHT - 3;
    int textY = y0 + REPO_HEIGHT - 10;
    int monthWidth = (x1 - x0 - COL_WIDTH) / 12;
    int monthMarks = monthWidth / 5;
    for (int i = 0; i < 12; i++)
    {
      int xStart = x0Graph + monthWidth * i;
      
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
        
    // Draw graph area    
    fill(255);
    noStroke();
    int w = x1Graph - x0Graph;
    int h = y1Graph - y0Graph;
    rect(x0Graph, y0Graph, w, h, 4, 0, 0, 4);
    
    // Draw line down middle of graph
    noFill();
    stroke(0, 120);
    strokeWeight(1);
    int y = y0Graph + h / 2;
    line(x0Graph, y, x1Graph, y);
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
