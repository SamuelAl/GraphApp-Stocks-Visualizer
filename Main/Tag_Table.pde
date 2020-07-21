// @author Cian O'Gorman
// modified by Samuel Alarco Cantos
// @Keira Gatt : 25/03/2020 : updated with constructor overload needed for the Search_Tools class instance
// @Keira Gatt : 04/04/2020 : better integration of Search Tools with Tag_Table (removed constructor overload, added table select method)
// @Keira Gatt : 14/04/2020 : added method to return actual dates associated with Main table

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

class Tag_Table extends Drawable {
  
  // List of all the tickers to be displayed
  String[] tickerList = {"AAPL", "AFSI", "AHH", "AHL", "AMSWA", "APO", "BRFS", "CAAS", "CCNE", "CLWT", "CRCM", "DSKE", "EGHT", "FLWS", "GHDX", "GTN", "GTS", "GTT", "ISTR", "MHD", "MHF", "NSEC", "OXLC", 
    "PEY", "PEZ", "RAVN", "RRC", "RRD", "SASR", "VIAV"};

  // Add buttons shown on table
  GraphicButton[] graphicButtonAddList;

  // PGraphics
  PGraphics pg;

  // Amount of pixels to move the graph by when scrolling the screen
  float scrollOffset;
  
  Table data, mainView;                                // @Keira 04/04/2020 - main data variable used to avoid reloading main table when switching from search view

  //Test variables
  int year = 2007;
  int month = 8;
  int day = 20;
 
  //Variables
  Table table;
  int xSpawnPos;
  int ySpawnPos;
  int tickerXPos;
  int openXPos;
  int closeXPos;
  int volumeXPos;
  int addButtonXPos = 980;

  //Variables filled from table (these variables are what is displayed for each row).
  float currentOpen;
  float currentClose;
  int currentVolume;

  //Pixel offsets (used for spacing apart figures and plotting them on the screen).
  int ySpawnPosRowOffset;
  static final int X_TICKER_OFFSET = 30;
  static final int Y_POSITION_OFFSET = 8;
  static final int X_OPEN_OFFSET = 150;
  static final int X_CLOSE_OFFSET = 450;
  static final int X_VOLUME_OFFSET = 765;

  /** Constructor
   * Constructor to create a Tag_Table object
   * @param  starting x and y location of the table
   */
  Tag_Table(int xSpawn, int ySpawn )
  {
    // Pixel offset initialisation
    xSpawnPos = xSpawn;
    ySpawnPos = ySpawn;
    tickerXPos = xSpawn + X_TICKER_OFFSET;
    openXPos = xSpawn + X_OPEN_OFFSET;
    closeXPos = xSpawn + X_CLOSE_OFFSET;
    volumeXPos = xSpawn + X_VOLUME_OFFSET;
    addButtonXPos = xSpawn + addButtonXPos;
    data = loadTagTable();
    mainView = data;                                                    // @Keira 04/04/2020 - main data variable used to avoid reloading main table when switching back from search view
    graphicButtonAddList = new GraphicButton[tickerList.length];
    createGraphicButtons();
}

  /** Constructor
   * Constructor to create a Tag_Table object
   * @param  starting x and y location of the table
   */
  Tag_Table(int xSpawn, int ySpawn, PGraphics pg)
  {
    this(xSpawn, ySpawn);
    tickerXPos = xSpawn + X_TICKER_OFFSET;
    openXPos = xSpawn + X_OPEN_OFFSET;
    closeXPos = xSpawn + X_CLOSE_OFFSET;
    volumeXPos = xSpawn + X_VOLUME_OFFSET;
    addButtonXPos = xSpawn + addButtonXPos;
    this.pg = pg;
    graphicButtonAddList = new GraphicButton[tickerList.length];
    createGraphicButtons();
  }

  // Setting the PGraphics
  void setPG(PGraphics pg)
  {
    this.pg = pg;

    for (int index = 0; index < graphicButtonAddList.length; index++) {
      graphicButtonAddList[index].setPG(this.pg);
    }
  }

  /**
   * Method to create a table and filter the information so that it only includes the information between certain dates and for a certain ticker.
   * @param  int index is used to cycle through each ticker from String[] tickerList.
   */
  Table loadTagTable()
  {
    database.selectBetweenDates(LocalDate.of(year, month, day), LocalDate.of(year, month, day)); 
    database.selectTickerNames(tickerList);
    return database.getQueryResult();
  }

  // Changing the amount of pixels the table is displaced by when the user scrolls
  void changeScrollOffset(float change)
  {
    int bottomLimit = (data.getRowCount() * 30) - pg.height + 60;  // Samuel Alarco 22/04/2020 - Dynamic scrolling limit for table
    if ((change > 0) && (scrollOffset < bottomLimit)) {
      scrollOffset += (change * 15);
    } else if ((change < 0) && (scrollOffset > 0)) {
      scrollOffset += (change * 15);
    }
  }

  /**
   * Method to draw all rows to the screen. Uses a for loop to cycle the index.
   */
  @Override
    void draw() {
    for (int index = 0; index < data.getRowCount(); index++) {
      TableRow row = data.getRow(index);
      ySpawnPosRowOffset = ySpawnPos + (30 * index) - (int) scrollOffset;
      drawCell(row, index, (int) scrollOffset);
      pg.fill(lightBlueColor);
      pg.rect(0, 50, 1020, 50);
    }
  }

  /**
   * Method to draw an individual row. location is dependent on the index of the ticker element in tickerList.
   * @param  int index is used to decide which ticker should be displayed.
   */
  void drawCell(TableRow row, int index, int scrollOffset)
  {
    pg.fill(255);
    pg.stroke(blackColor);
    pg.textFont(robotoMedium22Font);

    pg.beginDraw();
    pg.rect(xSpawnPos, ySpawnPosRowOffset, 1080, 55);
    pg.noStroke();
    pg.fill(0);
    pg.text(row.getString("ticker"), tickerXPos, ySpawnPosRowOffset +  Y_POSITION_OFFSET);
    pg.fill(#00D600);
    pg.text(row.getString("open"), openXPos, ySpawnPosRowOffset + Y_POSITION_OFFSET);
    pg.fill(#F50000);
    pg.text(row.getString("close"), closeXPos, ySpawnPosRowOffset + Y_POSITION_OFFSET);
    pg.fill(0);
    pg.text(row.getString("volume"), volumeXPos, ySpawnPosRowOffset + Y_POSITION_OFFSET);
    pg.endDraw();
    int buttonSpawnOffset = index * 30;
    if(searchFunctions.searchView() == false){
      graphicButtonAddList[index].draw(-scrollOffset, buttonSpawnOffset, CONTAINER_X, CONTAINER_Y);
    }
  }

  
  /*
   * @author  Keira Gatt
   * @date    04/04/2020
   *
   * Select between search results and main data
   * @param  searchResults : search results table or null
   */

  void tableSelect(Table searchResults) {

    if (searchResults != null) {          // If not a null argument, switch to search results
        data = searchResults;
    }
    else {
        data = mainView;                  // Otherwise switch to main data that was originally loaded
    }

    scrollOffset = 0.0;                  // start display from top row
  }
  
  
  /*
   * @author  Keira Gatt
   * @date    14/04/2020
   *
   * Get start and end date associated with the main data
   * @return  Start and end dates as an array of type LocalDate
   */
  
  LocalDate[] getDates() {
      
      LocalDate[] tableDates = new LocalDate[2];
      tableDates[START_DATE] = LocalDate.of(year, month, day);                            // Cian - Please change vars when done with test data
      tableDates[END_DATE] = LocalDate.of(year, month, day);
      
      return tableDates;
    
  }
  
  // Creating the add buttons
  void createGraphicButtons() {
    for (int index = 0; index < graphicButtonAddList.length; index++) {
      graphicButtonAddList[index] = new GraphicButton(addButtonXPos, 5, 75, 22, "+ADD", lightBlueColor, whiteColor, robotoMedium22Font, index + 100, pg);
    }
  }

  // Return the data from the table.
  Table getTableData() {
    return data;
  }

  // Return the data from a certain row of the table.
  TableRow getRowData(int index) {
    TableRow row = data.getRow(index);
    return row;
  }

  // Method to get the event of an add button that has been pressed.
  // Returns 0 if nothing has been pressed pressed.
  int getButtonEvent() {
    //Check the event of a buttons to see if any are !=0.
    GraphicButton tempButton;
    int buttonEvent = EVENT_NULL;
    int offset;
    for (int i = 0; i < graphicButtonAddList.length; i++) {
      offset = i * 30;
      tempButton = (GraphicButton) graphicButtonAddList[i];
      buttonEvent = tempButton.getEvent(mouseX, mouseY, CONTAINER_X, CONTAINER_Y, offset, -scrollOffset);
      if (buttonEvent != 0) {
        i = graphicButtonAddList.length + 1;
      }
    }
    return buttonEvent;
  }
}
