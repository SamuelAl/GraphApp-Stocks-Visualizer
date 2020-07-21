static final int WIDTH = 1280;
static final int HEIGHT = 720;

static final int EVENT_NULL = 0;
static final int EVENT_TABLE = 1;
static final int EVENT_LINE = 2;
static final int EVENT_BAR = 3;
static final int EVENT_ABOUT = 4;

static final int EVENT_LOW = 31;
static final int EVENT_HIGH = 32;
static final int EVENT_VOLUME = 33;
static final int EVENT_OPEN = 34;
static final int EVENT_CLOSE = 35;
static final int EVENT_ADJ_CLOSE = 36;

static final int DATA_TICKER = 0;       // @Keira - Columns IDs to plot - used by BarChart and LineGraph when calling DataOps methods
static final int DATA_OPEN = 1;
static final int DATA_CLOSE = 2;
static final int DATA_ADJ = 3;
static final int DATA_LOW = 4;
static final int DATA_HIGH = 5;
static final int DATA_VOLUME = 6;
static final int DATA_DATE = 7;

static final int XLABEL = 0;          // @Keira - Index of String array containing axis label - used by BarChart, LineGraph and DataOps
static final int YLABEL = 1;

static final int NAV_NULL = 0;        // @Keira - Constants used for graphs navigation buttons
static final int NAV_BAR_PREV = 1;
static final int NAV_BAR_NEXT = 2;
static final int NAV_BAR_UP = 3;
static final int NAV_BAR_DOWN = 4;
static final int NAV_LINE_PREV = 5;
static final int NAV_LINE_NEXT = 6;
static final int NAV_LINE_UP = 7;
static final int NAV_LINE_DOWN = 8;

final int BAR_NULL = 0;                       // @Keira - Constants that define the type of graphs that can be plotted
final int BAR_AVG = 1;
final int BAR_MAX = 2;
final int BAR_MPC = 3;
final int BAR_STD = 4;
final int BAR_PC_OPEN_CLOSE = 5;
final int BAR_PC_LOW_HIGH = 6;
final int BAR_PGAIN = 7;
final String[] BAR_TYPE = { "", "Period Average", "Maximum Variance", "Maximum Variance % of Minimum", "Standard Deviation", "Price Change", "Price Change", "Price Gain %" };

final int LINE_NULL = 0;                       
final int LINE_PRICE = 1;
final String[] LINE_TYPE = { "", "Stock Price" };

final int START_DATE = 0;                    // @Keira - Index constants to LocalDates array used by SearchTools, Tag_Tables and DataOps
final int END_DATE = 1;

final int CHART_TITLE = 0;                  // @Keira - Index constants to chartHeadings String array used by GUI class to display headings for Line Graph and Bar Chart       
final int CHART_DATA = 1;
final int CHART_PERIOD = 2;
final int CHART_HEADINGS = 3;



final int CONTAINER_X = 200, CONTAINER_Y = 110;             // Scrollable Container xpos and ypos to calculate mouse hover coordinates relative to the chart display


// Samuel Alarco 7/04/2020  -  Event codes for query selector (search box)
static final int EVENT_QUERY_EXCHANGE = 201;
static final int EVENT_QUERY_INDUSTRY = 202;
static final int EVENT_QUERY_SECTOR = 203;
static final int EVENT_QUERY_TICKER = 204;

// Cian O'Gorman 22/04/2020
// Values for sideButton locations and sizes
  static final int X_BUTTON_SPAWN = 0;
  static final int Y_TABLE_BUTTON_SPAWN = 50;
  static final int Y_LINE_BUTTON_SPAWN = 168;
  static final int Y_BAR_BUTTON_SPAWN = 286;
  static final int Y_HELP_BUTTON_SPAWN = 404;
  static final int X_BUTTON_LENGTH = 200;
  static final int Y_BUTTON_HEIGHT = 117;
  static final int Y_HELP_BUTTON_HEIGHT = 116;


// Keira Gatt : 19/04/2020 : String constants used on Status Bar display

final String HELP_TIPS[] = {  "View Main Data or Search Results in Table format", 
                              "View Main Data or Search Results as Line Graphs", 
                              "View Main Data or Search Results as Bar Charts", 
                              "View Credits",
                              "Add entry to HotBar",
                              "Remove entry from HotBar",
                              "Quit GraphApp",
                              "Enter one or more comma / space delimited Search Tokens, optionally using wildcards * and ? [ABC A*, ?B?,*BC ...] (BS or DEL to clear)",
                              "Execute Search (or press ENTER)",
                              "Cancel Search, clear Search Results and return to Main Data",
                              "Select Search Query type from Dropdown Menu",
                              "Set Start Date for Search Query from Dropdown Menu",
                              "Set End Date for Search Query from Dropdown Menu",
                              "Previous Data Series",
                              "Previous Line Graph / Bar Chart",
                              "Next Line Graph / Bar Chart",
                              "Next Data Series",
                              "Mouse hover on Bars to view actual values",
                              "Include Ticker in Searches",
                              "Quick launch LOW series",
                              "Quick launch HIGH series",
                              "Quick launch VOLUME series",
                              "Quick launch OPEN series",
                              "Quick launch CLOSE series",
                              "Quick launch ADJUSTED CLOSE series",
                              "Line Graph quick launch buttons" };
                              
                              
final String VIEW_STATUS[] = {  "Viewing Main Data",
                                "Viewing Search Results" };
     
final String ABOUT_CONTENT = "GraphApp - Stocks made Simple\n" +
                              "Authors\n" +
                              "  -Keira Gatt\n" +
                              "  -Cian O'Gorman\n" +
                              "  -David Olowookere\n" +
                              "  -Samuel Alarco Cantos\n" +
                              "PROGRAMMING PROJECT CSU11013 2020\n" +
                              "This app offers a wide variety of search tools and visualizations to analyze stocks data from the\n" +
                              "NASDAQ and NYSE stock exchanges. For information on the usage of this app please consult the attached\n" +
                              "documentation. The GraphApp team hopes that this app wil serve your stock analysis needs";
                                
