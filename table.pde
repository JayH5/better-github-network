import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

class Table
{
  final int ROWS=10, ROW_HEIGHT=10,HEIGHT=720;
  final String[] months = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" };
  
  final int REPO_HEIGHT = 200;
  final int COL_WIDTH = 120;
  final int SHADOW_HEIGHT = 5;
  final int TEXT_VERTICAL_OFFSET = 5;
  final int TEXT_HORIZONTAL_OFFSET = 10;
  
  final int MAX_COMMIT_ALPHA = 192;
  final int MIN_COMMIT_ALPHA = 40;
  
  final color[] FORK_COLORS = new color[] { #33B5E5, #AA66CC, #99CC00, #FFBB33, #FF4444 };
  
  final int x0, y0, x1, y1, rows, rowHeight;
  
  final int x0Graph, y0Graph, x1Graph, y1Graph;
  
  final PFont inconsolata;
  
  final Date startDate;
  final Date endDate;
  
  //constructor
  Table(int x0, int y0, int x1, int y1, int rows, Date start, Date end) {
    this.x0 = x0;
    this.y0 = y0;
    this.x1 = x1;
    this.y1 = y1;
    this.rows = rows;
    
    // Calculate row height
    rowHeight = (y1 - y0 - REPO_HEIGHT) / rows;

    int paddingGraphTop = 10;
    int paddingGraphBottom = 25;
    int paddingGraphLeft = 0;
    int paddingGraphRight = 0;
    
    x0Graph = x0 + paddingGraphLeft + COL_WIDTH;
    y0Graph = y0 + paddingGraphTop;
    x1Graph = x1 - paddingGraphRight;
    y1Graph = y0 + REPO_HEIGHT - paddingGraphBottom;

    inconsolata = loadFont("Inconsolata-14.vlw");
    
    endDate = end; // Now
    startDate = start; // A year ago

    drawTable();
    drawRepo();   
  }
  
  void setRepoName(String name) {
    fill(0);
    textFont(inconsolata, 14);
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
      if (commits == 0) {
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
    textFont(inconsolata, 14);
    text(name, TEXT_HORIZONTAL_OFFSET, y);
  }

  //Draw repo stats with Months below
  //Draw a fork
  //Draw all 
  void drawRepo() {    
    drawRuler();
    drawShadow();
        
    // Draw graph area    
    fill(255);
    noStroke();
    int w = x1Graph - x0Graph;
    int h = y1Graph - y0Graph;
    //rect(x0Graph, y0Graph, w, h, 4, 0, 0, 4);
    
    noStroke();
    fill(0, 64);
    //rect(x0, y0Graph, COL_WIDTH, h);
    
    // Draw line down middle of graph
    noFill();
    stroke(0, 120);
    strokeWeight(1);
    int y = y0Graph + h / 2;
    line(x0Graph, y, x1Graph, y);
  }
  
  private void drawRuler() {
    int days = (int) ((endDate.getTime() - startDate.getTime()) / 86400000);
    
    int ruleY0 = y0 + REPO_HEIGHT - 5;
    int markY0 = y0 + REPO_HEIGHT - 3;
    int textY = y0 + REPO_HEIGHT - 10;
    float dayWidth = (float) (x1Graph - x0Graph) / days;    

    Calendar cal = Calendar.getInstance();
    cal.setTime(startDate);
    for (int i = 0; i < days; i++) {
      int dayOfMonth = cal.get(Calendar.DAY_OF_MONTH);
      
      int xStart = x0Graph + (int) (dayWidth * i); 
      
      if (dayOfMonth == 1) {
        // Draw ruler measure
        stroke(192);
        strokeWeight(2);
        noFill();
        line(xStart, ruleY0, xStart, REPO_HEIGHT);

        // Draw month name
        fill(192);
        String month = months[cal.get(Calendar.MONTH)];
        int offset = (int) ((month.length() / 3.0f) * 10);
        textSize(14);
        text(month, xStart - offset, textY);
      } else {
        if (days > 40) {
          int daysInMonth = cal.getActualMaximum(Calendar.DAY_OF_MONTH);
          float drawPoint = daysInMonth / 5.0f;
          if ((int) ((dayOfMonth - 1) % drawPoint) == 0) {
            strokeWeight(1);
            stroke(192);
            noFill();
            line(xStart, ruleY0, xStart, REPO_HEIGHT);
          }
        } else {
          strokeWeight(1);
          stroke(192);
          noFill();
          line(xStart, ruleY0, xStart, REPO_HEIGHT);
          
          // Draw date of month
          fill(192);
          String day = String.valueOf(dayOfMonth);
          int offset = (int) ((day.length() / 3.0f) * 10);
          textSize(10);
          text(day, xStart - offset, textY + 2);
        }
      }
      
      cal.add(Calendar.DATE, 1);
    }

  }

  private void drawShadow() {
    linearGradient(x0, REPO_HEIGHT, x1 - x0, SHADOW_HEIGHT,
        color(28, 30, 32, 128), color(28, 30, 32, 0));
  }
  
  void setBlockData(int row, List<NetworkDataChunk.Commit> commits) {
    Collections.sort(commits);
    int numCommits = commits.size(); 
    
    // Find first and last commit within time span
    boolean startsBeforeStartDate = commits.get(0).getDate().before(startDate);
    boolean endsAfterEndDate = commits.get(numCommits - 1).getDate().after(endDate);
    
    int firstCommitPos = 0;
    if (startsBeforeStartDate) {
      for (; firstCommitPos < numCommits; firstCommitPos++) {
        if (commits.get(firstCommitPos).getDate().after(startDate)) {
          break;
        }
      }
    }
    
    int lastCommitPos = numCommits - 1;
    if (endsAfterEndDate) {
      for (; lastCommitPos >= 0; lastCommitPos--) {
        if (commits.get(lastCommitPos).getDate().after(startDate)) {
          break;
        }
      }
    }
 
    if (firstCommitPos > lastCommitPos) {
      return;
    }   
    
    // Pick a colour based on the row
    color col = FORK_COLORS[row % FORK_COLORS.length];
    
    int yStart = y0 + REPO_HEIGHT + rowHeight * row;
    int yMid = yStart + rowHeight / 2;
    
    int w = x1Graph - x0Graph;
    
    int diameter = 7;    
    noStroke();
    fill(col);
    
    int xEnd;
    if (!startsBeforeStartDate) {
      NetworkDataChunk.Commit lastCommit = commits.get(lastCommitPos);
      xEnd = x0Graph + (int) (w * getRelativeTime(lastCommit.getDate()));
      ellipse(xEnd, yMid, diameter, diameter);
    } else {
      xEnd = x1Graph;
    }
    
    int xStart;
    if (!startsBeforeStartDate) {
      NetworkDataChunk.Commit firstCommit = commits.get(firstCommitPos);
      xStart = x0Graph + (int) (w * getRelativeTime(firstCommit.getDate()));
      ellipse(xStart, yMid, diameter, diameter);
    } else {
      xStart = x0Graph;
    }
    noFill();
    stroke(col);
    strokeWeight(3);
    line(xStart, yMid, xEnd, yMid);
    
    strokeWeight(2);
    int top = yMid + 3;
    int bottom = yMid - 3;
    for (int i = firstCommitPos; i <= lastCommitPos; i++) {
      NetworkDataChunk.Commit commit = commits.get(i);
      int x = x0Graph + (int) (w * getRelativeTime(commit.getDate()));
      line(x, top, x, bottom);
    }
  }
  
  private float getRelativeTime(Date date) {
    long startTime = startDate.getTime();
    long endTime = endDate.getTime();
    long range = endTime - startTime;
    long time = date.getTime();
    return (float) (time - startTime) / range;
  }
  
  // Generate some random data for each fork
  void drawRandomForks() {   
    // Generate start positions, we start with most recent commit
    List<Integer> commits = new ArrayList<Integer>();    
    int offsetRange = 65;
    int days = 364;
    int start = days;
    int averageLength = 30;
    int averageNumCommits = 2;
    for (int i = 0; i < rows; i++) {
      commits.clear();
      
      // Add a start
      start -= (int) (offsetRange * random(1));
      start = Math.max(0, start);
      commits.add(start);
      
      // Calculate an end
      int end = start + (int) (averageLength * random(0, 6));
      end = Math.min(days, end);
      
      // Add some commits in-between
      int range = end - start;
      int numCommits = (int) (averageNumCommits * random(0, 3));
      for (int j = 0; j < numCommits; j++) {
        int pos = start + (int) (range * random(1));
        commits.add(pos);
      }
      
      // Cap it off with the end
      commits.add(end);
      
      drawFork(i, commits);
    }
  }
 
  void drawFork(int row, List<Integer> commits) {
    // Pick a colour based on the row
    color col = FORK_COLORS[row % FORK_COLORS.length];
    
    int yStart = y0 + REPO_HEIGHT + rowHeight * row;
    int yMid = yStart + rowHeight / 2;
    
    // Constants
    int startPointHeight = 10;
    float dayWidth = (float) (x1Graph - x0Graph) / 364;
    int xOffset = x0 + COL_WIDTH;
    
    int numCommits = commits.size();
    
    int firstCommit = commits.get(0);
    int xStart = xOffset + (int) (firstCommit * dayWidth);
    int diameter = 7;
    noStroke();
    fill(col);
    
    if (firstCommit > 0) {
      ellipse(xStart, yMid, diameter, diameter);
    }
    
    int lastCommit = commits.get(numCommits - 1);
    int xEnd = xOffset + (int) (lastCommit * dayWidth);    
    ellipse(xEnd, yMid, diameter, diameter);
    
    noFill();
    stroke(col);
    strokeWeight(3);
    line(xStart, yMid, xEnd, yMid);
    
    strokeWeight(2);
    int top = yMid + 3;
    int bottom = yMid - 3;
    for (int i = 1; i < numCommits - 1; i++) {
      int x = xOffset + (int) (commits.get(i) * dayWidth);
      line(x, top, x, bottom);
    }
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
}
