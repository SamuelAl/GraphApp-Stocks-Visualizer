// Imports
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.text.DateFormat;
//import com.mysql.jdbc.*;    // This is the MySQL connector import. Files need to be placed in library folder (refer to README)
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.Statement;

// Main file
final String PROGRAM_NAME = "GraphApp";

// Fonts
PFont robotoMedium22Font;
PFont QuicksandLight35Font;
PFont dateFont;

// Objects
Database database;
Tag_Table tagTable;
HotBar hotBar;
ScrollableContainer mainContainer;
SearchTools searchFunctions;      
BarChart barChart;
LineGraph lineGraph;
ScrollableTextBox aboutBox;
GUI  userInterface;                // @Cian 25/03/2020

// Graphic Image Object
PImage exitButton;                // @Keira 18/03/2020

//Dropdown-related Objects
ArrayList checkList, startDateMenu, endDateMenu;
int currentDropdown = 0;
Dropdown startDropDown, endDropDown;
Button subtractYearStart, subtractMonthStart, subtractDayStart, addDayStart, addMonthStart, addYearStart;
Button subtractYearEnd, subtractMonthEnd, subtractDayEnd, addDayEnd, addMonthEnd, addYearEnd;

//Date-related Objects
LocalDate startDate, endDate, minDate, maxDate;
DateTimeFormatter dayMonthYear;
Date_Handler dateSetter;

// Colors
color darkBlueColor = #00667E;
color lightBlueColor = #4FB5BD;
color oceanBlueColor = #007E9C;
color whiteColor = #FFFFFF;
color blackColor = #000000;
color lightGreyColor = 220;
color lightGreenColor = #00D600;
color lightRedColor = #FF6666;    
color orangeColor = #FF9900; 
color yellowColor = #FFFF00;


void setup()
{
  size(1280, 720);

  String[] xData = {"12/01", "13/01", "14/01", "12/01", "13/01", "14/01", "12/01", "13/01", "14/01", "12/01", "13/01", "14/01", "12/01", "13/01", "14/01", "12/01", "13/01", "14/01", "12/01", "13/01", "14/01", "12/01", "13/01", "14/01"};
  float[] yData = {1, 3, 2, 1, 3, 2, 1, 3, 2, 1, 3, 2, 1, 3, 2, 1, 3, 2, 1, 3, 2, 1, 3, 2};

  // Initialising fonts
  robotoMedium22Font = loadFont("Roboto-Medium-22.vlw");
  QuicksandLight35Font = loadFont("Quicksand-Light-35.vlw");
  dateFont = loadFont("Roboto-Medium-18.vlw");

  // Database initialisation
  database = new Database("daily_prices100k.csv", "stocks.csv");
  database.setSQLMode(false);

  // Data Displaying Objects
  lineGraph = new LineGraph(xData, yData, 1080, 410);                              
  barChart = new BarChart(xData, yData, 1080, 440);                                
  Tag_Table tagTable = new Tag_Table(0, 0);
  aboutBox = new ScrollableTextBox(0, 0, 1080, 410, ABOUT_CONTENT);
  aboutBox.enableScroll(false);

  // LineGraph initialisation
  lineGraph.setLineWeight(5);
  lineGraph.setLineColor(color(255, 0, 0));

  // General object initialisation
  mainContainer = new ScrollableContainer(200, 110, 1080, 440, tagTable, lineGraph, barChart);             
  searchFunctions = new SearchTools(tagTable);                                                         

  // Graphical Object initialisation
  userInterface = new GUI();
  userInterface.setup();
  hotBar = new HotBar(tagTable);

  // Icon Graphics Initialisation
  exitButton = loadImage("graphics/ExitButton.png");  // @Keira 18/03/2020

  // Date-related initialisation
  dateSetter = new Date_Handler();
  dateSetter.setup();
}

void draw()
{
  // Setting the main background to be white
  background(whiteColor);

  // Drawing the screen area that contains the main graphs and table
  mainContainer.draw();                                                                                        

  // Cian O'Gorman
  // Drawing GUI
  userInterface.draw();
  hotBar.draw();

  // Keira Gatt : 20/03/2020
  // Draw Search Box & display user input or search fail messages
  // Execute search with date range if search button or ENTER key were pressed
  searchFunctions.draw();                                                                                   
  if (searchFunctions.doSearch()) searchFunctions.dbLookup(database, startDate, endDate);                    

  // Keira Gatt : 20/03/2020
  // Display Exit button
  image(exitButton, 1240, 10);   

  // Drawing drop-down menus for changing the dates, and the dates themselves
  for (int i = 0; i < checkList.size(); i++) {
    Dropdown aDrop = (Dropdown) checkList.get(i);
    aDrop.draw();
  }
  dateSetter.draw();
}

void mouseWheel(MouseEvent e)
{

  mainContainer.changeScroll(e.getCount());
}

void mousePressed()
{

  hotBar.mousePressed();

  // Keira Gatt : 20/03/2020
  // Check if Exit button is pressed and for user requests to search functions 
  if ((mouseY > 10 && mouseY < 40) && (mouseX > 1240 && mouseX < 1280)) exit();                  
  searchFunctions.mouseInput(mouseX, mouseY);                                                    

  // Cian O'G. 19/03/2020
  // @Samuel Alarco 09/04/2020 - Added show/hide table headers functionality and show/hide graph-infor functionality  (linked to GUI class)
  int currentEvent;
  for (int i = 0; i < userInterface.sideButtonList.size(); i++) {
    Button currentButton = (Button) userInterface.sideButtonList.get(i);
    currentEvent = currentButton.getEvent(mouseX, mouseY);

    switch (currentEvent) {

    case EVENT_TABLE:
      mainContainer.currentObject = mainContainer.table;
      userInterface.setCurrentView(currentEvent);                       // @Keira - inform GUI instance of current display
      userInterface.showTableHeaders(true);
      userInterface.showGraphDataSelectors(false);
      break;
      
    case EVENT_LINE:
    mainContainer.currentObject = mainContainer.lineGraph;
      userInterface.setCurrentView(currentEvent);                       // @Keira - inform GUI instance of current display
      searchFunctions.setCurrentEvent(currentEvent);                    // @Keira - inform Search Tools of current display
      lineGraph.getDataSeries(DATA_DATE, DATA_OPEN);                    // @Keira - generate X & Y data series for Line Graph
      userInterface.showTableHeaders(false);
      userInterface.showGraphDataSelectors(true);
      break;
    }
    if (currentEvent == EVENT_TABLE) {
    } else if (currentEvent == EVENT_LINE) {
      
    } else if (currentEvent == EVENT_BAR) {                                                            
      mainContainer.currentObject = mainContainer.barChart;
      userInterface.setCurrentView(currentEvent);                        // @Keira - inform GUI instance of current display
      searchFunctions.setCurrentEvent(currentEvent);                     // @Keira - inform Search Tools of current display
      barChart.getDataSeries(DATA_TICKER, DATA_OPEN);                    // @Keira - generate X & Y data series for Bar Chart
      userInterface.showTableHeaders(false);
      userInterface.showGraphDataSelectors(false);
    }
    // @Samuel Alarco - Addition of About Button functionality
    else if (currentEvent == EVENT_ABOUT) {
      mainContainer.setCurrentObject(aboutBox);
      userInterface.showTableHeaders(false);
      userInterface.showGraphDataSelectors(false);
      userInterface.setCurrentView(currentEvent);
    }
  }
  //David O. - Handles the checkboxes (31/03/2020)
  //Moved down by Samuel Alarco to solve order issues (20/04/2020)

  //David O. - Checks whether the date needs to be updated, and handles things accordingly
  dateSetter.upDate();

  //Samuel Alarco - 07/04/2020
  // Checkquery type selector for search box events using Dropdown class
  userInterface.querySelector.getEvent(mouseX, mouseY);
  currentEvent = userInterface.querySelector.getMenuEvents();
  switch (currentEvent)
  {
  case EVENT_QUERY_TICKER:
    //call ticker mode function in search tools
    userInterface.changeSearchModeString("ticker");
    System.out.println("ticker mode");
    break;
  case EVENT_QUERY_EXCHANGE:
    //call exchange mode function in search tools
    userInterface.changeSearchModeString("exchange");
    System.out.println("exchange mode");
    break;
  case EVENT_QUERY_INDUSTRY:
    //call industry mode function in search tools
    userInterface.changeSearchModeString("industry");
    System.out.println("industry mode");
    break;
  case EVENT_QUERY_SECTOR:
    //call sector mode function in search tools
    userInterface.changeSearchModeString("sector");
    System.out.println("sector mode");
    break;
  default:
    break;
  }

  // Keira Gatt : 11/04/2020
  // Check for mouse clicks on graph navigation buttons and change data series if in graph mode

  int navAction = userInterface.graphMouseInput(mouseX, mouseY);

  switch(navAction) {

  case NAV_BAR_PREV :
  case NAV_BAR_NEXT :
  case NAV_BAR_UP :
  case NAV_BAR_DOWN :
    barChart.newDataSeries(navAction);
    break;
  case NAV_LINE_PREV :
  case NAV_LINE_NEXT :
  case NAV_LINE_UP :
  case NAV_LINE_DOWN :
    lineGraph.newDataSeries(navAction);
    break;
  }

  // Samuel Alarco: 20/04/2020 - Added visualization data selection functionality for line graph overriding nav buttons
  navAction = userInterface.checkGraphDataSelectorInput(mouseX, mouseY);

  switch(navAction) {

  case EVENT_LOW:
    lineGraph.setDataTracking(DATA_LOW);
    break;
  case EVENT_HIGH:
    lineGraph.setDataTracking(DATA_HIGH);
    break;
  case EVENT_OPEN:
    lineGraph.setDataTracking(DATA_OPEN);
    break;
  case EVENT_CLOSE:
    lineGraph.setDataTracking(DATA_CLOSE);
    break;
  case EVENT_VOLUME:
    lineGraph.setDataTracking(DATA_VOLUME);
    break;
  case EVENT_ADJ_CLOSE:
    lineGraph.setDataTracking(DATA_ADJ);
    break;
  default:
    break;
  }
}

// Keira Gatt : 18/03/2020
// Capture and validate keyboard input

void keyPressed() {

  searchFunctions.kbInput(key);
}
