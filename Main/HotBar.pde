/*
  Author: Cian O'Gorman
 Hotbar class for creating and modifying the hotbar
 */

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

class HotBar {

  // Table objects
  Table fullTagTable;
  Table hotBarTable;

  // Array containing tags currently contained in hotbar
  // int containing how many tags are currently being stored
  String[] hotBarTags = {"", "", "", "", ""};
  int tagAmount = 0;

  // Button objects
  Button[] removeButtons = new Button[5];
  Button[] searchButtons = new Button[5];

  // Event of the remove button that has just been pressed
  int currentRemoveEvent;

  // Other Objects
  Tag_Table tagTable;

  // Data display variables
  float currentOpen;
  float currentClose;
  int currentVolume;

  //Pixel offsets (used for spacing apart figures and plotting them on the screen).
  int ySpawnRowOffset;
  static final int X_SPAWN_POS = 0;
  static final int Y_SPAWN_POS = 550;
  static final int COUNTER_X_OFFSET = 10;
  static final int TICKER_X_OFFSET = 45;
  static final int Y_POS_OFFSET = 22;
  static final int OPEN_X_OFFSET = 222;
  static final int CLOSE_X_OFFSET = 412;
  static final int VOLUME_X_OFFSET = 602;
  static final int PERCENTAGE_X_OFFSET = 792;
  static final int X_COUNTER_POSITION = X_SPAWN_POS + COUNTER_X_OFFSET;
  static final int X_TICKER_POSITION = X_SPAWN_POS + TICKER_X_OFFSET;
  static final int X_OPEN_POSITION = X_SPAWN_POS + OPEN_X_OFFSET;
  static final int X_CLOSE_POSITION = X_SPAWN_POS + CLOSE_X_OFFSET;
  static final int X_VOLUME_POSITION = X_SPAWN_POS + VOLUME_X_OFFSET;


  /** Constructor
   * Constructor to create a HotBar object
   * @param  starting x and y location of the table
   */
  HotBar(Tag_Table tagTable)
  {
    this.tagTable = tagTable;
    // Variables
    currentRemoveEvent = 0;

    // Copy table from tagTable
    fullTagTable = tagTable.getTableData();

    // Creating hot bar table
    hotBarTable = new Table();
    hotBarTable.addColumn("ticker", Table.STRING);
    hotBarTable.addColumn("open", Table.FLOAT);
    hotBarTable.addColumn("close", Table.FLOAT);
    hotBarTable.addColumn("volume", Table.INT);
    initialiseHotBar();

    // Creating hotBar buttons buttons
    createHotBarButtons();
  }

  /**
   * Method to draw all rows to the screen. Uses a for loop to cycle the index.
   */
  void draw() {
    for (int index = 0; index < hotBarTags.length; index++) {
      if (hotBarTags[index] != "") {
        TableRow row = hotBarTable.getRow(index);
        ySpawnRowOffset = Y_SPAWN_POS + (30 * index);
        drawCell(row, index);
      }
    }
  }

  /**
   * Method to draw an individual row. location is dependent on the index of the ticker element in tickerList.
   * @param  int index is used to decide which ticker should be displayed.
   */
  void drawCell(TableRow row, int index)
  {
    fill(255);
    stroke(blackColor);
    rect(X_SPAWN_POS - 1, ySpawnRowOffset, 1281, 30);
    noStroke();
    textFont(robotoMedium22Font);
    fill(blackColor);
    text(index + 1 + ("."), X_COUNTER_POSITION, ySpawnRowOffset + Y_POS_OFFSET);
    text(row.getString("ticker"), X_TICKER_POSITION, ySpawnRowOffset + Y_POS_OFFSET);
    fill(#00D600);
    text(row.getString("open"), X_OPEN_POSITION, ySpawnRowOffset + Y_POS_OFFSET);
    fill(#F50000);
    text(row.getString("close"), X_CLOSE_POSITION, ySpawnRowOffset + Y_POS_OFFSET);
    fill(blackColor);
    text(row.getString("volume"), X_VOLUME_POSITION, ySpawnRowOffset + Y_POS_OFFSET);
    removeButtons[index].draw();
    searchButtons[index].draw();
  }


  // Code to update the hotbar based on data stored in the hotBarTags array.
  void updateHotBar() {
    // Creating variables
    TableRow foundRow, storeRow;
    String tickerName, currentTag;
    float currentOpen, currentClose;
    int currentVolume;

    // Cycling through Hotbar string
    for (int i = 0; i < hotBarTags.length; i++) {

      // Getting values
      currentTag = hotBarTags[i];

      if (currentTag != "") {
        foundRow = fullTagTable.findRow(currentTag, "ticker");
        tickerName = foundRow.getString("ticker");
        currentOpen = foundRow.getFloat("open");
        currentClose = foundRow.getFloat("close");
        currentVolume = foundRow.getInt("volume");

        storeRow = hotBarTable.getRow(i);
        storeRow.setString("ticker", tickerName);
        storeRow.setFloat("open", currentOpen);
        storeRow.setFloat("close", currentClose);
        storeRow.setInt("volume", currentVolume);
      }
    }
  }

  // Creating and loading the hotbar with data, to be run during setup only
  void initialiseHotBar() {
    // Creating variables
    TableRow foundRow, addedRow;
    String tickerName, currentTag;
    float currentOpen, currentClose;
    int currentVolume;

    // Cycling through Hotbar string
    for (int i = 0; i < hotBarTags.length; i++) {

      // Getting values
      currentTag = hotBarTags[i];

      if (currentTag != "") {
        foundRow = fullTagTable.findRow(currentTag, "ticker");
        tickerName = foundRow.getString("ticker");
        currentOpen = foundRow.getFloat("open");
        currentClose = foundRow.getFloat("close");
        currentVolume = foundRow.getInt("volume");

        // Storing values in hotbar table
        addedRow = hotBarTable.addRow();
        addedRow.setString("ticker", tickerName);
        addedRow.setFloat("open", currentOpen);
        addedRow.setFloat("close", currentClose);
        addedRow.setInt("volume", currentVolume);
      }
    }
  }

  // Checking the add buttons to see if any have been pressed, which then updates the hotbar.
  void checkAddButtons() {
    if ((mouseY < 520) && (mouseY > 80) && (mouseX > 200)) {
      int buttonEvent = 0;
      if (tagAmount < 5) {
        buttonEvent = tagTable.getButtonEvent();
        buttonEvent -= 100;
        if ((buttonEvent >= 0) && (tagAmount < 5)) {
          // Get the ticker of the tag corresponding to the button pressed and store it
          String ticker = fullTagTable.getString(buttonEvent, "ticker");
          hotBarTags[tagAmount] = ticker;
          tagAmount = tagAmount + 1;
        }
      }
    }
  }

  // Creating the remove and search buttons
  void createHotBarButtons() {
    for (int i = 0; i < 5; i++) {
      removeButtons[i] = new Button(1164, 553 + (i * 30), 110, 24, "-Remove", lightBlueColor, whiteColor, robotoMedium22Font, 50 + i);
      searchButtons[i] = new Button(1010, 553 + (i * 30), 137, 24, "+Search", lightGreenColor, whiteColor, robotoMedium22Font, 200 + i);
    }
  }

  // Check if the remove buttons have been pressed and removing the row from the hotbar if it has been pressed
  void checkRemoveButton() {
    int currentEvent = 0;
    int arrayTransformIndex = hotBarTags.length + 1;
    // Checking each remove button to see if an event != 0.
    for (int i = 0; i < hotBarTags.length; i++) {
      currentEvent = removeButtons[i].getEvent(mouseX, mouseY);
      if (currentEvent != 0) {
        i = hotBarTags.length + 1;
        arrayTransformIndex = currentEvent - 50;
      }
    }


    // Removing the given string from the search if it has been added.
    if (arrayTransformIndex < hotBarTags.length) {
      String tickerToBeRemoved = hotBarTags[arrayTransformIndex];
      if (tickerToBeRemoved != "") {
        for (int i = 0; i < searchFunctions.hotBarTags.length; i++) {
          if (searchFunctions.hotBarTags[i] == tickerToBeRemoved) {
            searchFunctions.hotBarTags[i] = "";
          }
        }
      }
    }

    // Moving each row back one position if a previous row is removed
    while (arrayTransformIndex < hotBarTags.length) {
      if (arrayTransformIndex < hotBarTags.length - 1) {
        String tempString = hotBarTags[(arrayTransformIndex + 1)];
        hotBarTags[arrayTransformIndex] = tempString;
        hotBarTags[arrayTransformIndex + 1] = "";
      } else {
        // TODO Making last row null
        hotBarTags[arrayTransformIndex] = "";
        tagAmount = tagAmount - 1;
      }
      arrayTransformIndex++;
    }
  }

  // Importing tagTable from Tag_Table class
  Table getTagTable(Tag_Table tagTable) {
    Table table = tagTable.getTableData();
    return table;
  }


  // Checks to see if a +Search button has been pressed and adds it to the search string if it has
  void updateSearchTags() {
    String currentTag = "";
    //Checking if a button has been pressed
    if (searchFunctions.hotBarTags[4] == "") {
      boolean isPressed = false;
      for (int i = 0; i < tagAmount; i++) {
        int buttonEvent = searchButtons[i].getEvent(mouseX, mouseY);
        buttonEvent -= 200;
        if (buttonEvent >= 0) {
          isPressed = true;
          currentTag = hotBarTags[buttonEvent];
          i = tagAmount;
        }
      }
      //If button has been pressed place it in string
      boolean isIncluded = false;
      if (isPressed == true) {
        for (int j = 0; j < searchFunctions.hotBarTags.length; j++) {
          if (searchFunctions.hotBarTags[j] == currentTag) {
            isIncluded = true;
            println("Tag is already included in search");
            j = searchFunctions.hotBarTags.length;
          }
        }
        if (isIncluded == false) {
          for (int i = 0; i < searchFunctions.hotBarTags.length; i++) {
            if (searchFunctions.hotBarTags[i] == "") {
              searchFunctions.hotBarTags[i] = currentTag;
              i = searchFunctions.hotBarTags.length;
            }
          }
        }
      }
    }
  }

  // If mouse is pressed
  void mousePressed() {
    checkRemoveButton();
    checkAddButtons();
    updateHotBar();
    updateSearchTags();
  }
}
