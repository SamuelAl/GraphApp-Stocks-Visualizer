/*
SearchTools Class
 
Keira M. Gatt (Group 33)
Student #19334557
CSU11013-A-SEM202-201920 PROGRAMMING PROJECT

V1.0  Early prototype with custom GUI
V1.1  Initial version of Search box, Quit and input functions on standard GUI
V1.2  Revised placement of Search box and Quit icon, single ticker search & display using a revised version of Tag_Table
V1.3  Multi-ticker and wildcard search functionality
V1.4 : 23/03/2020 : Extended search functionality with date range
V1.5 : 25/03/2020 : Use of standard Tag_Table, class renamed to SearchTools and Integration of Bar Char function
V1.6 : 27/03/2020 : Manual integration without updated app due to SVN conflicts
V1.7 : 05/04/2020 : Tighter integration with Tag_Table, search functions available on graph views, search results retained across buttons, search fail message display, cancel search fnctionality, code maintenance
V1.8 : 11/04/2020 : Added support to search by Stock type and text centering, enhanced search box display
V1.9 : 14/04/2020 : Integration with new db methods provided by Samuel to get unique labels from Stock Register and to search sector, industry and exchange columns with multiple tokens
V1.10 : 20/04/2020 : Included search support for HotBar entries

Additional Changes

Samuel : 23/03/2020 uniqueTokens now uses Database class method instead of native call
Cian : 24/03/2020 : GUI and appearance modifications
Cian : 20/04/2020 : Added hotBarTags array to include HotBar entries in Searches

*/

import java.util.regex.Matcher;
import java.util.regex.Pattern;

class SearchTools {

  final int INPUTMAX = 18;                                                                                                // Max chars allowed for search criteria
  final boolean CHANGETOCAPS = true;                                                                                      // Set to false for case sensitive
  final int SEARCHBOXX = 240, SEARCHBOXY = 10, SEARCHBOXWIDTH = 300;                                                      // Display settings
  final int SEARCHBOXHEIGHT = 30, SEARCHBOXCURVE = 3, SEARCHBOXTXTWIDTH = 270;                                            // Display settings
  final int NULLFUNCT = 0, SEARCHBOX = 1, SEARCHBUTTON = 2, SEARCHVIEW = 4, SEARCHERROR = 8;                              // Search function controls (can be tested as integers and in bitwise ops)
  final String FILTEREDCHARS = "\\.!\"#$%&'()+/:;<=>@[]^_`{|}";                                                           // Chars that are filtered out from kb input
  
  LocalDate[] searchDates;                                                                                                // Array to preserve search dates independently of date changes on the GUI
  int searchAction, currentEvent;
  PImage searchButton, cancelSearchButton;
  String inputBuffer, searchModeString, dispString;
  String[] hotBarTags = {"", "", "", "", ""};                                                                              // @Cian 20/04/2020 : Searchable HotBar tags - updated by HotBar class instance 
  
  Tag_Table tagTable;                                                                                                      // Reference to Tag Table initialised in M ain
  Table searchResults, searchResultsTmp;
  
  
  /*
   * Constructor to create SearchTools object
   * @param  tagTable : Tag_Table class instance initialised in Main
   */
   
  SearchTools(Tag_Table tagTable) {                                                                                        
  
    inputBuffer = "";
    searchModeString = "ticker";                                                                                           // App always starts in ticker query mode
    
    searchButton = loadImage("graphics/SearchButton.png");                                                                 // Search interface button images
    cancelSearchButton = loadImage("graphics/CancelSearchButton.png");
        
    searchAction = NULLFUNCT;                                                                                              // Start instance with search inactive
    currentEvent = EVENT_NULL;
    
    this.tagTable = tagTable;
    searchDates = new LocalDate[2];
    
  }


  /* 
   * Display search box, user input and error messages
   */

  void draw() {
    
    fill(whiteColor);
    stroke(blackColor);
    rect(SEARCHBOXX, SEARCHBOXY, SEARCHBOXWIDTH + 32, SEARCHBOXHEIGHT, SEARCHBOXCURVE);      // Search input field
    image(searchButton, SEARCHBOXX + SEARCHBOXWIDTH - 37, SEARCHBOXY - 1);                   // Quick search icon
    image(cancelSearchButton, SEARCHBOXX + SEARCHBOXWIDTH, SEARCHBOXY + 1);                  // Cancel search icon
    
    noStroke();
    fill(lightGreyColor);
    rect(SEARCHBOXX + 263, SEARCHBOXY + 1, 2, SEARCHBOXHEIGHT - 1);                        // Line separating Quick search button @Cian
    rect(SEARCHBOXX + 298, SEARCHBOXY + 1, 2, SEARCHBOXHEIGHT - 1);                        // Line separating Cancel search button   

    textSize(16);
    
    if(boolean(searchAction & SEARCHERROR)) {                                              // Display Search fail message if error flag set
    
        fill(orangeColor);
        dispString = "Invalid Input or No Data Available";
        text(dispString, SEARCHBOXX + userInterface.centreText(dispString, SEARCHBOXTXTWIDTH), SEARCHBOXY + 21);
  
    }
    else if(boolean(searchAction & SEARCHBOX)) {                                            // Display input and prompt user for additional search criteria
      
        fill(blackColor);
        text(inputBuffer + "__", SEARCHBOXX + 5, SEARCHBOXY + 21);
      
    }
    else {                                                                                  // Display empty search box with Query mode status
  
        fill(lightGreyColor);
        searchModeString = userInterface.getSearchModeString();                                                                 // Get current search mode
        dispString = "<Search by " + searchModeString.substring(0, 1).toUpperCase() + searchModeString.substring(1) + ">";      // Construct display string and change first char to uppercase
        text(dispString, SEARCHBOXX + userInterface.centreText(dispString, SEARCHBOXTXTWIDTH), SEARCHBOXY + 21);
    
    }
     
  }


  /* 
   * Process mouse events
   * @param  xpos : mouse X position
   * @param  ypos : mouse Y position
   */
   
  void mouseInput(int xpos, int ypos) {                                                    
    
        
    if(ypos > SEARCHBOXY && ypos < SEARCHBOXY + SEARCHBOXHEIGHT) {
    
      if(xpos > SEARCHBOXX && xpos < SEARCHBOXX + SEARCHBOXWIDTH) {
            searchAction = (searchAction | SEARCHBOX) & ~SEARCHERROR;                                  // Enable search box input and clear error flag
      }
      
      if(xpos > SEARCHBOXX + 255 && xpos < SEARCHBOXX + SEARCHBOXWIDTH) {
            searchAction |= SEARCHBUTTON;                                                             // Initiate search
      }
      
      if(xpos > SEARCHBOXX + 287 && xpos < SEARCHBOXX + SEARCHBOXWIDTH + 32) {
            cancelSearchView();                                                                       // Call method to cancel search
      }
   
    }
      
  }

  
  /* 
   * Process keyboard events
   * @param  kbChar : keyboard input character
   */
   
  void kbInput(char kbChar) {                                                       
   
    if(boolean(searchAction & SEARCHBOX) && kbChar != CODED) {                      // Only accept input if the user is in search input mode and input is not a special key (ALT, CTRL, ...)
    
      switch(kbChar) {
        
          case ENTER :
          case RETURN :
              searchAction = searchAction |= SEARCHBUTTON;                           // Input is the same as clicking on Search Button (i.e. initiate search)
              break;
              
          case BACKSPACE :
              if(inputBuffer.length() > 0) inputBuffer = inputBuffer.substring(0, inputBuffer.length() - 1);            // Clear last char from input buffer
              break;
              
          case DELETE :                                                            // Clear input buffer
              inputBuffer = "";
              break;
              
          default :
              if(kbChar > 31 && kbChar < 127 && inputBuffer.length() < INPUTMAX) {          // Add char to string if within range and buffer limit
      
                  if(FILTEREDCHARS.indexOf(kbChar) < 0 ) {                                  // Discard invalid input chars
                  
                      if(CHANGETOCAPS && kbChar > 96 && kbChar < 123) {                     // Change to Caps if flag is set
                            kbChar -=32;          
                      }
                      
                      inputBuffer += kbChar;
                  }
              }
      }
    
    }
    
  }


  /* 
   * Carry out a search on the master database and stock ref database if applicable
   * @param  dbInstance : Instance of database class
   * @param  startDate : Start of data range as shown on GUI
   * @param  endDate : End of data range as shown on GUI
   */
   
  void dbLookup(Database dbInstance, LocalDate startDate, LocalDate endDate) {              

    searchDates[START_DATE] = startDate;                                                    // Glue dates to these search results (in case they change in the GUI without refreshing the search)
    searchDates[END_DATE] = endDate;
    
    searchAction = (searchAction | SEARCHERROR) & ~SEARCHBUTTON;                            // Clear search execute flag and set error flag initially (a successful search will clear the error flag)
    searchModeString = userInterface.getSearchModeString();                                 // Determine Query type i.e. how the search is to be carried out
       
    ArrayList<String> tokenArray = processInputBuffer(inputBuffer, hotBarTags);             // Parse and validate search criteria
  
    if(tokenArray.size() > 0) { 
      
      String tokenList[] = createTokenList(dbInstance, tokenArray);                        // Create a list of tickers to use as argument for db search queries
  
      if(tokenList.length > 0) {
        
          switch(searchModeString) {
                
             case "ticker" :
                 dbInstance.selectTickerNames(tokenList);                          // Search main table directly if this is a token search
                 break;
             case "exchange" :
                 dbInstance.selectExchanges(tokenList);                            // Otherwise search by stock categories
                 break;
             case "sector" :
                 dbInstance.selectSectors(tokenList);
                 break;
             case "industry" :
                 dbInstance.selectIndustry(tokenList);
                       
              }
           
          dbInstance.selectBetweenDates(startDate, endDate);                        // Filter search results by date range
          searchResultsTmp = dbInstance.getQueryResult();                           // Get table containing search results and assign to temp var

          if(searchResultsTmp.getRowCount() > 0) {                                  // Confirm that search table contains data
    
                searchAction = (searchAction | SEARCHVIEW) & ~SEARCHERROR;           // Flag search view as ready and clear error flag
                searchResults = searchResultsTmp;                                    // Assign results table to search results var
                tagTable.tableSelect(searchResults);                                 // Let Tag_Table instance know of new search results table
                updateSearchGraphs();                                                // Update graph data if graphs are active     
                        
          }
  
      }
  
    }
             
  }

  
  /* 
   * Parse and validate search criteria
   * @param  inputBuffer : User search input
   * @param  hotBarTags : A list of searchable tags from HotBar
   * @return An Array List of search String tokens
   */
   
 ArrayList<String> processInputBuffer(String inputBuffer, String[] hotBarTags) {                    
    
    char inputChar;
    boolean newToken, inputError;
    String partialToken, finalToken;
    
    ArrayList<String> tokenArray = new ArrayList<String>();                   // Array list that will hold the String tokens when parsed
    
    newToken = true;
    inputError = false;
    partialToken = finalToken = "";
    
    if(searchModeString.equals("ticker")) {                                    // Add HotBar items tagged for search if we're searching by ticker
            for(int i = 0; i < hotBarTags.length; i++) {
                if(hotBarTags[i] != "") {
                      tokenArray.add(hotBarTags[i]);
                }
            }
   }
    
   for(int i = 0; i <= inputBuffer.length(); i++) {                              // Validate and tokenise input                      
      
      if(i == inputBuffer.length()) {                                             // Force token validation when we're past the end of input buffer
          inputChar = 32;
          newToken = false;
      }
      else {
          inputChar = inputBuffer.charAt(i);
      }
      
      if(inputChar == 32 || inputChar == 44) {                                   // Check for comman and space delimiters
        
          if(!newToken) {                                                        // If end of token, first check if token consists only of wildcards, which is not allowed and will be ignored
            inputError = true;
            for(int j = 0; j < partialToken.length(); j++) {
                  if(partialToken.charAt(j) != '*' && partialToken.charAt(j) != '?') {
                      inputError = false;
                      break;
                  }
            }
          
            if(!inputError) {                                                                                    // If token has correct syntax, copy it to ArrayList. Otherwise ignore token
              for(int j = 0; j < partialToken.length(); j++) {
                  if(partialToken.charAt(j) == '*' || partialToken.charAt(j) == '?') {
                        finalToken += '.';                                                                      // Prefix wildcards with dot for correct regex syntax
                  }
                  finalToken += partialToken.charAt(j);
              }  
            
              tokenArray.add(finalToken);                                                                       // Copy token to ArrayList     
           }
           
           newToken = true;                                                                                    // Prepare to read new token from input buffer
           partialToken = finalToken = "";
            
          }
       }
       else {
        
         partialToken += inputChar;                                                                           // If char is not a delimiter, copy it to token buffer
         newToken = false;
              
       }
  
    } 
        
   return tokenArray;
    
  } 

  
  /* 
   * Create an arguments list to for db search queries
   * The contents of the arguments list will depend on the Query type
   * @param    dbInstance : Instance of database class
   * @param    tokenArray : A non-empty Array List of search String tokens
   * @return   String array of search tokens as required by the Database Class query methods
   */
   
  String[] createTokenList(Database dbInstance, ArrayList<String> tokenArray) {         
    
    Pattern searchRegex;
    Matcher tokenMatch;
    String[] uniqueTokens;
    String searchPattern = "";
    ArrayList<String> validTokenList = new ArrayList<String>();
   
    if(searchModeString == "ticker") {
          uniqueTokens = dbInstance.getTickerNames();                                   // Retrieve a list of unique tickers from main data table if this is a ticker search
    }
    else {
          uniqueTokens = dbInstance.getUniqueStockInfoLabelList(searchModeString);     // Otherwise retrieve a list of unique exchange, sector or industry designations
    }
   
    for(int i = 0; i < tokenArray.size(); i++) {                                      // Run through each token passed in the Array List argument
      
      searchPattern = tokenArray.get(i);
      searchRegex = Pattern.compile(searchPattern);                                    // Compile regex string based on token
    
      for(int j = 0; j < uniqueTokens.length; j++ ) {                                 // Loop through each unique token and keep only those that match the regex pattern
    
          if(uniqueTokens[j] != null) {
            
              tokenMatch = searchRegex.matcher(uniqueTokens[j]);
              if(tokenMatch.matches()) {
                
                  validTokenList.add(uniqueTokens[j]);
                  uniqueTokens[j] = null;                                           // Remove token from unique token list if matched to avoid duplicates
                  
              }
          }
 
      } 
    
    }
    
    String[] validTokens = new String[validTokenList.size()];                   // Convert ArrayList to String array of correct size (as required by Database Class methods)
    
    for(int i = 0; i < validTokenList.size(); i++) {
      
             validTokens[i] = validTokenList.get(i);
             
    }
    
    return validTokens;
    
  }


  /* 
   * Let Main know if we can start a search query
   * @return  booelan true or false
   */
   
  boolean doSearch() {
    
     return boolean(searchAction & SEARCHBUTTON);                                // Return true if search button was clicked or ENTER key was pressed
    
  }
 
  
  /* 
   * Let Main & DataOps Class instance know if search results should be displayed
   * @return  booelan true or false
   */
  
  boolean searchView() {
    
    return boolean(searchAction & SEARCHVIEW);                                 // Return true if we had a successful search or if search results are already in view
    
  }
 
  
  /* 
   * Reset search view, clear search box and switch to main data
   */
  
  void cancelSearchView() {                                                     
    
    inputBuffer = "";                                                          // Clear search input buffer
    searchAction = NULLFUNCT;                                                  // Reset search control flags

    tagTable.tableSelect(null);                                                // Switch to main table
    updateSearchGraphs();                                                      // Update graph data if graphs are active   
   
    userInterface.changeSearchModeString("ticker");                            // Reset search Query type
  }


  /* 
   * Returns Table asscoiated with the current view
   * @return  main data table or search results table
   */
  
  Table getTable() {
    
    if(searchView()) {
          return searchResults;                                                // If search view is active, return search table
    }
    else {
          return tagTable.getTableData();                                      // otherwise return main table
    }
       
  }
  
  
  /* 
   * Returns start and end of data range associated with the current view
   * @return  Start and end dates as an array of type LocalDate
   */
  
  LocalDate[] getDates() {                                                     
   
    if(searchView()) {
          return searchDates;                                                 // If search view is active, return search dates
    }
    else {
          return tagTable.getDates();                                         // otherwise return dates associated with main table
    }
    
  }

  
  /* 
   * Called from Main so SearchTools can keep track of the new view upon user mouse click
   * @param  currentEvent : new view as assigned in Main mousePressed() method
   */
   
  void setCurrentEvent(int currentEvent) {                                      
    
    this.currentEvent = currentEvent;                                          // Update this Class variable
    
  }

 
  /* 
   * Force an update of Line Graph or Bar Chart if in view
   * Called when switching from search results to main data or following a new successful search
   */
 
  void updateSearchGraphs() {                                                  
    
    switch(currentEvent) {
        
        case EVENT_LINE :
            lineGraph.getDataSeries(DATA_DATE, DATA_OPEN);                    // Generate new X & Y series for Line Graph
            break;
        
        case EVENT_BAR :
            barChart.getDataSeries(DATA_TICKER, DATA_OPEN);                  // Generate new X & Y series for Bar Chart
            
    }
    
  }  
  
}
