// GUI class by Cian O'Gorman 25/03/2020 - A class for the general user interface such as the headers, logo, and buttons used to navigate.
// @Samuel Alarco: 07/04/2020 : added query selector dropdown menu functionality 
// @Keira Gatt : 11/04/2020 : added setCurrentView, getSearchModeString() and centreText() methods, display searchModeString as centred text and method graphMouseInput + objects for prev and next graph navigation
// @Keira Gatt : 12/04/2020 : added support for up and down graph navigation buttons
// @Keira Gatt : 19/04/2020 : added support to display help tips and status info on status line
// @Keira Gatt : 21/04/2020 : added support for HotBar +Search and Quick Launch buttons
// @Keira Gatt : 22/04/2020 : new method and additional draw() code to display graph headings in the nav buttons area, nav buttons moved to the side
// @Samuel Alarco: 22/04/2020 : Show/hide functionality for graph heading and buttons

class GUI {

  // header bar
  static final int X_BAR_SPAWN = 0;
  static final int Y_BAR_SPAWN = 0;
  static final int X_BAR_LENGTH = 1280;
  static final int Y_BAR_LENGTH = 50;

  // header hotbar
  static final int X_HOTBAR_SPAWN = 0;
  static final int Y_HOTBAR_SPAWN = 520;
  static final int X_HOTBAR_LENGTH = 1280;
  static final int Y_HOTBAR_LENGTH = 30;

  // header menu
  static final int X_MENU_SPAWN = 200;
  static final int Y_MENU_SPAWN = 50;
  static final int X_MENU_LENGTH = 1080;
  static final int Y_MENU_LENGTH = 30;

  static final int X_TABLE_SPAWN = 200;
  static final int Y_TABLE_SPAWN = 80;
  static final int X_TABLE_LENGTH = 1080;
  static final int Y_TABLE_LENGTH = 30;

  static final int X_TICKER_TABLE = X_TABLE_SPAWN + 30;
  static final int Y_TICKER_TABLE = Y_TABLE_SPAWN + 25;
  static final int X_OPEN_TABLE = X_TABLE_SPAWN + 148;
  static final int X_CLOSE_TABLE = X_TABLE_SPAWN + 448;
  static final int X_VOLUME_TABLE = X_TABLE_SPAWN + 762;

  // Bottom Options
  static final int X_OPTIONS_SPAWN = 0;
  static final int Y_OPTIONS_SPAWN = 701;
  static final int X_OPTIONS_LENGTH = 1280;
  static final int Y_OPTIONS_LENGTH = 720 - Y_OPTIONS_SPAWN;

  // Side buttons
  ArrayList sideButtonList;
  ArrayList<Checkbox> checkBoxList;
  PFont stdFont;

  //@Samuel Alarco 07/04/2020
  //Query selector drop down
  Dropdown querySelector;

  //@Samuel Alarco - string to show search mode
  String searchModeString;

  boolean drawTable = true;
  boolean drawLine = false;
  boolean drawBar = false;
  boolean drawHelp = false;

  //@Samuel Alarco 09/04/2020 - draw other elements boolean variables
  boolean drawTableHeaders = true;
  boolean drawGraphDataSelectors = false;

  int currentView;                                          // @Keira - keep track of what is being displayed (sync'd with EVENT in Main)
  String[] chartHeadings;                                   // @Keira - used to hold display strings for graph headings 
  PImage nextButton, prevButton, upButton, downButton;      // @Keira - graphic objects for navigation arrows

  void setup() 
  {
    Button buttonTable, buttonLine, buttonBar, buttonHelp;
    stdFont = robotoMedium22Font; 
    textFont(stdFont);
    buttonTable = new Button(0, 50, 200, 117, "Table View", oceanBlueColor, whiteColor, robotoMedium22Font, EVENT_TABLE);
    buttonLine = new Button(0, 168, 200, 117, "Line Graph View", oceanBlueColor, whiteColor, robotoMedium22Font, EVENT_LINE);
    buttonBar = new Button(0, 286, 200, 117, "Bar Chart View", oceanBlueColor, whiteColor, robotoMedium22Font, EVENT_BAR);
    buttonHelp = new Button(0, 404, 200, 116, "About", oceanBlueColor, whiteColor, robotoMedium22Font, EVENT_ABOUT);

    sideButtonList = new ArrayList();
    sideButtonList.add(buttonTable); 
    sideButtonList.add(buttonLine);
    sideButtonList.add(buttonBar);
    sideButtonList.add(buttonHelp);

    //David O. - Added the checkboxes for the line graph (31/03/2020)
    Checkbox checkLow, checkHigh, checkVolume, checkOpen, checkClose, checkAdjClose;
    
    // Samuel Alarco: 20/04/2020 - Substituted event codes with constants
    checkLow = new Checkbox(727, 56, 15, 15, "Low", 41, #ff0000, 255, dateFont, EVENT_LOW);
    checkHigh = new Checkbox(794, 56, 15, 15, "High", 44, #00ff00, 255, dateFont, EVENT_HIGH);
    checkVolume = new Checkbox(884, 56, 15, 15, "Volume", 67, #0000ff, 255, dateFont, EVENT_VOLUME);
    checkOpen = new Checkbox(957, 56, 15, 15, "Open", 48, #f0f000, 255, dateFont, EVENT_OPEN);
    checkClose = new Checkbox(1032, 56, 15, 15, "Close", 50, #f000f0, 255, dateFont, EVENT_CLOSE);
    checkAdjClose = new Checkbox(1186, 56, 15, 15, "Adjusted Close", 126, #00f0f0, 255, dateFont, EVENT_ADJ_CLOSE);

    checkBoxList = new ArrayList();
    checkBoxList.add(checkLow); 
    checkBoxList.add(checkHigh);
    checkBoxList.add(checkVolume);
    checkBoxList.add(checkOpen);
    checkBoxList.add(checkClose);
    checkBoxList.add(checkAdjClose);

    //@Samuel Alarco: 07/04/2020 - Added query options dropdown menu
    Button buttonTickerQuery = new Button(580, 10, 100, 30, "Ticker", oceanBlueColor, whiteColor, dateFont, EVENT_QUERY_TICKER);
    Button buttonExchangeQuery = new Button(580, 10, 100, 30, "Exchange", oceanBlueColor, whiteColor, dateFont, EVENT_QUERY_EXCHANGE);
    Button buttonIndustryQuery = new Button(580, 10, 100, 30, "Industry", oceanBlueColor, whiteColor, dateFont, EVENT_QUERY_INDUSTRY);
    Button buttonSectorQuery = new Button(580, 10, 100, 30, "Sector", oceanBlueColor, whiteColor, dateFont, EVENT_QUERY_SECTOR);
    ArrayList querySelectorButtons = new ArrayList();
    querySelectorButtons.add(buttonTickerQuery);
    querySelectorButtons.add(buttonExchangeQuery);
    querySelectorButtons.add(buttonIndustryQuery);
    querySelectorButtons.add(buttonSectorQuery);
    querySelector = new Dropdown(580, 10, 100, 30, querySelectorButtons, 200, oceanBlueColor, whiteColor);

    searchModeString = "ticker";

    nextButton = loadImage("graphics/NextButton.png");                     // @Keira - load graph navigation arrows
    prevButton = loadImage("graphics/PrevButton.png");
    upButton = loadImage("graphics/UpButton.png");
    downButton = loadImage("graphics/DownButton.png");

    currentView = EVENT_NULL;                                              // @Keira - initialise current view variable
    chartHeadings = new String[CHART_HEADINGS];                            // @Keira - initialise headings array for graphs
  }

  void draw() {
    // Drawing header bar
    fill(darkBlueColor);
    noStroke();
    rect(X_BAR_SPAWN, Y_BAR_SPAWN, X_BAR_LENGTH, Y_BAR_LENGTH);
    fill(whiteColor);
    textFont(QuicksandLight35Font);
    text(PROGRAM_NAME, 30, 37);
    fill(lightBlueColor);
    noStroke();
    circle(15, 25, 20);

    // Drawing hot bar
    fill(lightBlueColor);
    noStroke();
    rect(X_HOTBAR_SPAWN, Y_HOTBAR_SPAWN, X_HOTBAR_LENGTH, Y_HOTBAR_LENGTH);
    fill(whiteColor);
    textFont(robotoMedium22Font);
    text("Hotbar", X_HOTBAR_SPAWN + 10, Y_HOTBAR_SPAWN + 24);
    text("OPEN", X_HOTBAR_SPAWN + 220, Y_HOTBAR_SPAWN + 24);
    text("CLOSE", X_HOTBAR_SPAWN + 410, Y_HOTBAR_SPAWN + 24);
    text("VOLUME", X_HOTBAR_SPAWN + 600, Y_HOTBAR_SPAWN + 24);

    // Drawing header menu
    if (drawGraphDataSelectors)
    {
      fill(lightBlueColor);
      noStroke();
      rect(X_MENU_SPAWN, Y_MENU_SPAWN, X_MENU_LENGTH, Y_MENU_LENGTH);
      for (int i = 0; i < checkBoxList.size(); i++) {
        Checkbox currentCheck = (Checkbox) checkBoxList.get(i);
        currentCheck.draw();
      }
    }

    // Drawing header Table
    // Updates:
    // @Samuel Alarco 09/04/2020 - made conditional to be able to hide it and show it
    // @Keira Gatt 11/04/2020 - added display of navigation arrows when graphs are displayed
    // @Samuel Alarco 22/04/2020  - added currency indicators
    if (drawTableHeaders)
    {
      fill(oceanBlueColor);
      noStroke();
      rect(X_TABLE_SPAWN, Y_TABLE_SPAWN, X_TABLE_LENGTH, Y_TABLE_LENGTH);
      fill(whiteColor);
      textFont(robotoMedium22Font);
      text("TICKER", X_TICKER_TABLE, + Y_TICKER_TABLE);
      text("OPEN ($)", X_OPEN_TABLE, Y_TICKER_TABLE);
      text("CLOSE ($)", X_CLOSE_TABLE, Y_TICKER_TABLE);
      text("VOLUME", X_VOLUME_TABLE, Y_TICKER_TABLE);
    } else if (currentView == EVENT_BAR || currentView == EVENT_LINE) {
      
      image(prevButton, 1200, Y_TABLE_SPAWN - 8);                  // @Keira - display graphs navigation buttons and headings
      image(nextButton, 1240, Y_TABLE_SPAWN - 8);
      image(downButton, 194, Y_TABLE_SPAWN - 8);
      image(upButton, 224, Y_TABLE_SPAWN - 8);
      
      fill(darkBlueColor);                                      
      text(chartHeadings[CHART_TITLE], X_TABLE_SPAWN + centreText(chartHeadings[CHART_TITLE], X_TABLE_LENGTH), Y_TABLE_SPAWN + 21);
      
      textSize(14);
      fill(oceanBlueColor);
      text(chartHeadings[CHART_DATA], X_TABLE_SPAWN + centreText(chartHeadings[CHART_DATA], X_TABLE_LENGTH / 2), Y_TABLE_SPAWN + 21);
      text(chartHeadings[CHART_PERIOD], X_TABLE_SPAWN + (X_TABLE_LENGTH / 2) + centreText(chartHeadings[CHART_PERIOD], X_TABLE_LENGTH / 2), Y_TABLE_SPAWN + 21);
      
   }

    // Drawing side buttons
    for (int i = 0; i < sideButtonList.size(); i++) {
      Button currentWidget = (Button) sideButtonList.get(i);
      currentWidget.draw();
    }

    // Drawing bottom options
    fill(lightBlueColor);
    noStroke();
    rect(X_OPTIONS_SPAWN, Y_OPTIONS_SPAWN, X_OPTIONS_LENGTH, Y_OPTIONS_LENGTH);

    // @Samuel Alarco 07/04/2020
    // Draw query type selector dropdown menu
    querySelector.draw();
    textFont(dateFont);
    fill(oceanBlueColor);
    text(searchModeString, 580 + centreText(searchModeString, 100), 30);    // @Keira - added centre text functionality

    // @Keira Gatt : 19/04/2020
    // Display help tips and status information

    fill(whiteColor);
    textSize(15);
    text(helpStatus(), 10, 716);
    text(viewStatus(), 1110, 716);
  }
  
   /*
   * @author  Samuel Alarco
   * @date    07/04/2020
   *
   * Updates search mode indicator next to the search box
   */
  void changeSearchModeString(String newMode)
  {
    searchModeString = newMode;
  }
  
   /*
   * @author  Samuel Alarco
   * @date    07/04/2020
   *
   * Shows or hides table headers
   */
  void showTableHeaders(boolean visible)
  {
    drawTableHeaders = visible;
  }
  
  /*
   * @author  Samuel Alarco
   * @date    22/04/2020
   *
   * Shows or hides graph data selector checkboxes
   */
  void showGraphDataSelectors(boolean visible)
  {
    drawGraphDataSelectors = visible;
  }
  
  
  /*
   * @author  Keira Gatt
   * @date    11/04/2020
   *
   * Let SearchTools Class know the currently selected Query type
   * @return  String containing one of thse tokens - "ticker", "sector", "industry", "exchange"
   */
  
  String getSearchModeString() {         
  
    return searchModeString;
    
  }


  /*
   * @author  Keira Gatt
   * @date    11/04/2020
   *
   * Centre text horizontally
   * @param    textString : String to be centred
   * @param    width : width of textString display area
   * @return   x-offset relative to start of width
   */
   
  float centreText(String textString, float width) {
    
    return (width - textWidth(textString)) / 2.0;
    
  }


  /*
   * @author  Keira Gatt
   * @date    11/04/2020
   *
   * Keep track of current view (required for graph navigation method graphMouseInput()
   * @param  currentView : value of currentView passed as argument from Main
   */
   
  void setCurrentView(int currentView) {                                      

    this.currentView = currentView;
    
  }

 
  /*
   * @author  Keira Gatt
   * @date    11/04/2020
   *
   * Determine which nav button has been pressed when in graph mode
   * @param   mx : value of X mouse position passed as argument from Main
   * @param   my : value of Y mouse position passed as argument from Main
   * @return  value indicating button pressed on which graph
   */

  int graphMouseInput(int mx, int my) {
    int navAction = NAV_NULL;
    if (my > 88 && my < 98) {
        if (mx > 1214 && mx < 1230) {                                // Test for prev button
          switch(currentView) {
            case EVENT_LINE :
              navAction = NAV_LINE_PREV;
              break;
            case EVENT_BAR :
              navAction = NAV_BAR_PREV;
          }
        }
        
        if (mx > 1253 && mx < 1270) {                              // Test for next button
          switch(currentView) {
            case EVENT_LINE :
              navAction = NAV_LINE_NEXT;
              break;
            case EVENT_BAR :
              navAction = NAV_BAR_NEXT;
          }
        }
    }
    
    if (my > 84 && my < 102) {
        if (mx > 211 && mx < 220) {                              // Test for down button
          switch(currentView) {
            case EVENT_LINE :
              navAction = NAV_LINE_DOWN;
              break;
            case EVENT_BAR :
              navAction = NAV_BAR_DOWN;
          }
        }

        if (mx > 242 && mx < 249) {                              // Test for up button
          switch(currentView) {
            case EVENT_LINE :
              navAction = NAV_LINE_UP;
              break;
            case EVENT_BAR :
              navAction = NAV_BAR_UP;
          }
       }
    }
    
    return navAction;
  }
  
  // @Samuel Alarco: Check for graph navigation checkbox input
  int checkGraphDataSelectorInput(int mX, int mY)
  {
    int event = EVENT_NULL;
    for (Checkbox checkbox : checkBoxList)
    {
      int tempEvent = checkbox.getEvent(mX, mY);
      if (tempEvent != EVENT_NULL) {event = tempEvent;}
      else {checkbox.unCheck();}
    }
    return event;
  }


  /*
   * @author  Keira Gatt
   * @date    19/04/2020
   *
   * Return relevant help info for Status Bar display on mouse hover
   * @return  display String from file Constants
   */

  String helpStatus() {
    int helpIndex = -1;
    String helpString = "";

    if (mouseX > 2 && mouseX < 197) {                                                    // Side buttons
      if (mouseY > 54 && mouseY < 165) {
          helpIndex = 0;
      }
      else if (mouseY > 170 && mouseY < 282) {
          helpIndex = 1;
      }
      else if (mouseY > 286 && mouseY < 397) {
          helpIndex = 2;
      }
      else if (mouseY > 406 && mouseY < 516){
          helpIndex = 3;
      }
    }
    
    if (mouseX > 1180 && mouseX < 1255 && mouseY > 108 && mouseY < 516) {                // Add entry to HotBar
      if (currentView == EVENT_TABLE || currentView == EVENT_NULL ) {
          helpIndex = 4;
      }
    }
    
    if (hotBar.tagAmount > 0) {                                                          // HotBar buttons
      if (mouseY > 553 && mouseY < 577 + ((hotBar.tagAmount - 1) * 30)) {
          if (mouseX > 1173 && mouseX < 1263) {
              helpIndex = 5;
          }
          else if (mouseX > 1012 && mouseX < 1145) {
              helpIndex = 18;
          }
      }
    }
    
    if (mouseY > 16 && mouseY < 32) {                                                  // Quit, Search, Cancel Search buttons
      if (mouseX > 1208 && mouseX < 1265) {
          helpIndex = 6;
      }
      else if (mouseX > 511 && mouseX < 526) {
          helpIndex = 8;
      }
      else if (mouseX > 546 && mouseX < 561) {
          helpIndex = 9;
      }
    }
    
    if (mouseY > 11 && mouseY < 41) {                                                  // Search Box, Query Type, Dates
      if (mouseX > 241 && mouseX < 503) {
          helpIndex = 7;
      }
      else if (mouseX > 580 && mouseX < 679) {
          helpIndex = 10;
      }
      else if (mouseX > 701 && mouseX < 730) {
          helpIndex = 11;
      }
      else if (mouseX > 950 && mouseX < 980) {
          helpIndex = 12;
      }
    }
    
    if (currentView == EVENT_LINE || currentView == EVENT_BAR) {                      // Graphs Navigation buttons
      if (mouseY > 84 && mouseY < 102) {
        if (mouseX > 1214 && mouseX < 1230) {
            helpIndex = 13;
        }
        else if (mouseX > 211 && mouseX < 220) {
            helpIndex = 14;
        }
        else if (mouseX > 242 && mouseX < 249) {
            helpIndex = 15;
        }
        else if (mouseX > 1253 && mouseX < 1270) {
            helpIndex = 16;
        }
     }
     else if (currentView == EVENT_BAR) {                                            // Bar Chart area
        if (mouseX > 202 && mouseX < 1276 && mouseY > 114 && mouseY < 516) {
            helpIndex = 17;    
        }
     }
   }
   
   if(mouseY > 57 && mouseY < 71) {                                                 // Quick Launch Buttons
       if(mouseX > 728 && mouseX < 742) {
             helpIndex = 19;
       }
       else if(mouseX > 794 && mouseX < 808) {
             helpIndex = 20;
       }
       else if(mouseX > 884 && mouseX < 898) {
             helpIndex = 21;
       }
       else if(mouseX > 957 && mouseX < 971) {
             helpIndex = 22;
       }
       else if(mouseX > 1032 && mouseX < 1046) {
             helpIndex = 23;
       }
       else if(mouseX > 1186 && mouseX < 1200) {
             helpIndex = 24;
       }
       
       if(helpIndex > 18 && currentView != EVENT_LINE) {      // Display another help tip if we have a match but not on Line Graph
             helpIndex = 25;
       }
   }
    
    if (helpIndex >= 0) {
        helpString = HELP_TIPS[helpIndex];
    }
    
    return helpString;
  }


  /*
   * @author  Keira Gatt
   * @date    19/04/2020
   *
   * Determine if Main Data or Search Results are in view for display on status line
   * @return  display String from file Constants
   */
   
  String viewStatus() {
    if (searchFunctions.searchView()) {
        return VIEW_STATUS[1];
    }
    
    return VIEW_STATUS[0];
  }
  
  /*
   * @author  Keira Gatt
   * @date    22/04/2020
   *
   * Update graph headings array for display when graphs are in view
   * @param  chartTitle : name of chart
   * @param  dataTitle : information on the current graph data series
   * @param  periodTitle : date range for current graph
   */
   
  void setGraphHeadings(String chartTitle, String dataTitle, String periodTitle) {
    
    chartHeadings[CHART_TITLE] = chartTitle;
    chartHeadings[CHART_DATA] = dataTitle;
    chartHeadings[CHART_PERIOD] = periodTitle;
  
  }
  
  
}
