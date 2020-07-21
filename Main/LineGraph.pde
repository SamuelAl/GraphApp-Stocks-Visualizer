/**
 * Class for drawing a line graph view
 * 
 * @author Samuel Alarco Cantos
 * @version 3.0
 * @since 2020-03-17
 */
 
 // Keira Gatt : 01/04/2020 : Modified to plot table / search live data instead of test data
 // Keira Gatt : 05/04/2020 : Removed debug output
 // Keira Gatt : 11/04/2020 : Added support for chart navigation through all table columns with prev and next buttons
 // Keira Gatt : 12/04/2020 : Added functionality to cycle through tickers with up and down buttons
 // Samuel Alarco: 14/04/2020 : Clean up of debug code.
 // Keira Gatt : 14/04/2020 : Reduction of code in getDataSeries method by centralising it in DataOps Class
 // Samuel Alarco: 20/04/2020 : Line graph changes color according to data being shown (rotating color scheme)
 // Keira Gatt : 22/04/2020 : Delegation of graph headings display methods to GUI class
 
 
class LineGraph extends Drawable
{
  //Data variables
  String[] xData;
  float[] yData;
  float yMin, yMax, xStep, yStep, xAxisLength, yAxisLength;
  boolean customYAxis = false;
  int width, height;
  PGraphics pg;
  PFont font = createFont("Arial", 10);
  
  DataOps graphData;                                                // @Keira - Class used to generate data series
  boolean navButtonInput;                                           // @Keira - Detects when we need to change data set
  String[] uniqueTickers;                                           // @Keira - Line graph will be plotted for these tickers
  int navDataTracking, navTickerTracking;                           // @Keira - Keep track of current view for line graph navigation

  //Visualization settings and variables
  color lineColor = color(255, 0, 0);
  color backgroundColor = color(255, 255, 255);
  int lineWeight;
  boolean showAxis = true;
  int maxXLabels = 20;
  color[] rotatingColors = {color(#f0f000), color(#f000f0), color(#00f0f0), color(#ff0000), color(#00ff00), color(#0000ff)};

  //Margin variables
  int axisMargin_y = 30;
  int axisMargin_x = 30;
  int axisMarginExtra_x = 30;

 /** Constructor
   * Constructor to create LineGraph object
   * @param  xData String[] Array of Strings that serve as labels for each data point in the x-Axis
   * @param  yData float[] Array of float values for y axis. Must be same length as xData
   * @width  width  int of graph
   * @height height  int height of graph
   */
  LineGraph(String[] xData, float[] yData, int width, int height)
  {
    this.xData = xData;
    this.yData = yData;
    if (yData.length != xData.length) {throw new IllegalArgumentException("Data arrays not of same length");}
    this.width = width;
    this.height = height;
    
    navButtonInput = false;                                     // Navigation flag initially set to false
    graphData = new DataOps();                                  // @Keira - create class instance
  }

 /** Constructor
   * Constructor to create LineGraph object
   * @param  xData String[] Array of Strings that serve as labels for each data point in the x-Axis
   * @param  yData float[] Array of float values for y axis. Must be same length as xData
   * @width  width  int of graph
   * @height height  int height of graph
   * @pg    PGraphics object to contain graph
   */
  LineGraph(String[] xData, float[] yData, int width, int height, PGraphics pg)
  {
    this(xData, yData, width, height);
    this.pg = pg;
  }

 /**
   *  Implements draw functionality
   */
  void draw()
  {
    //Set up of yMin and yMax
    if (!customYAxis)
    {
      yMin = yMax = yData[0];

      for (int i = 0; i < yData.length; i++)
      {
        yMax = Math.max(yData[i], yMax);
        yMin = Math.min(yData[i], yMin);
      }
    }

    //Set up of Axis
    xStep = yStep = 0;
    int xSteps = 0;
    int ySteps = 10;
    float yStepSize = (yMax - yMin) / (ySteps-1);

    pg.stroke(0);
    pg.strokeWeight(1);
    //Axis
    if (showAxis)
    {
      // Axis X
      pg.line(axisMargin_x + axisMarginExtra_x, height - axisMargin_y, width - axisMargin_x, height - axisMargin_y);
      // Axis Y
      pg.line(axisMargin_x + axisMarginExtra_x, height - axisMargin_y, axisMargin_x + axisMarginExtra_x, 0 + axisMargin_y);
    }
    xAxisLength = width - (2*axisMargin_x + axisMarginExtra_x);   
    yAxisLength = height - (2 * axisMargin_y);
    yStep = yAxisLength / ySteps;
    float yPixelScale = (yAxisLength - yStep) / (yMax - yMin);
    xSteps = xData.length; 
    xStep = xAxisLength / xSteps;
   
    //Draw tick lines and X labels
    pg.textFont(font);
    pg.textAlign(CENTER);

    if (showAxis)
    {
      int xLabelInterval = 1;
      if (xSteps > maxXLabels) 
      {
        xLabelInterval = (int) Math.ceil(xSteps / maxXLabels);
      }
      for (int i = 0; i < xSteps; i++)
      {
        int xPos = (int) Math.floor( (axisMargin_x + axisMarginExtra_x + ((float)i * xStep))); 
        
        if (i % xLabelInterval == 0)
        {
          pg.line(xPos, height - axisMargin_y, xPos, height - axisMargin_y + 7);
          String dateLabel = xData[i];
          pg.text(dateLabel, xPos, height - axisMargin_y + 20);
        }
        else
        {
          pg.line(xPos, height - axisMargin_y, xPos, height - axisMargin_y + 5);
        }
        
      }

      for (int i = 0; i < ySteps; i++)
      {
        int yPos = (int) ( height - axisMargin_y - yStep - (i * yStep)); 
        pg.line(axisMargin_x + axisMarginExtra_x, yPos, axisMargin_x + axisMarginExtra_x - 5, yPos);
        String yLabel = "" + String.format("%.2f", (yMin + (i * yStepSize)));
        pg.text(yLabel, axisMargin_x + axisMarginExtra_x - 40, yPos);
      }
    }

    //Draw lines for graph;
    for (int i = 0; i < yData.length - 1; i++)
    {
      pg.stroke(lineColor);
      pg.strokeWeight(lineWeight);
      int initXPos = (int) (axisMargin_x + axisMarginExtra_x + (((float)i) * xStep)); 
      int endXPos = (int) (axisMargin_x + axisMarginExtra_x + (((float)(i + 1)) * xStep)); 
      int initYPos = (int) (height - axisMargin_y - yStep - ((yData[i] - yMin) * yPixelScale));
      int endYPos = (int) (height - axisMargin_y - yStep - ((yData[i+1] - yMin) * yPixelScale));
      pg.line(initXPos, initYPos, endXPos, endYPos);
    }
    pg.stroke(0);
    pg.strokeWeight(1);
  }

 /**
   *  Sets custom PGraphics object for rendering
   *  @param  pg  PGraphics object
   */
  void setPG(PGraphics pg)
  {
    this.pg = pg;
  }

 /**
   *  Implements scrolling functionality (empty)
   *  @param  float scroll change
   */
  void changeScrollOffset(float change)
  {
  }

 /**
   *  Sets custom line weigth for graph
   *  @param  weight  int weight of line
   */
  void setLineWeight(int weight)
  {
    this.lineWeight = weight;
  }

 /**
   *  Sets custom line color
   *  @param  lineColor  color Color of line
   */
  void setLineColor(color lineColor)
  {
    this.lineColor = lineColor;
  }

 /**
   *  Sets custom Y Axis data value
   *  @param  yData  float[] yData values in array form
   */
  void setYValues(float[] yData)
  {
    this.yData = yData;
  }

 /**
   *  Sets custom X Axis data value
   *  @param  xData  String[] xData values
   */
  void setXValues(String[] xData)
  {
    this.xData = xData;
  }

 /**
   *  Sets custom Y Axis min and max values. 
   *  This can be used for custom scaling of the y axis eg. when stacking graphs one on top of each other.
   *  @param  yMin  float minimum value for y axis
   *  @param  yMax  float maximum value for y axis
   */
  void setYAxis(float yMin, float yMax)
  {
    this.yMin = yMin;
    this.yMax = yMax;
    customYAxis = true;
  }

 /**
   *  Sets whether to show axis or not
   *  @param  showAxis boolean true - show axis; false - hide axis
   */
  void showAxis(boolean showAxis)
  {
    this.showAxis = showAxis;
  }
  
 /**
   *  Sets custom background color
   *  @param  bgColor color background color
   */
  void setBackgroundColor(color bgColor)
  {
    this.backgroundColor = bgColor;
    pg.background(backgroundColor);
  }


  /*
   * @author  Keira Gatt
   * @date    01/04/2020
   *
   * Prepare X & Y data series for line graph
   * @param  xDataCol : Column id used to generate the X data series
   * @param  yDataCol : Column id used to generate the Y data series
   */
 
 void getDataSeries(int xDataCol, int yDataCol) {
    
    navDataTracking = yDataCol;
    if(!navButtonInput) {
        navTickerTracking = 0;                                  // If not called by graph navigation buttons, start with the first ticker
    }
    navButtonInput = false;
    
    graphData.dataInit(xDataCol, yDataCol);                     // Initialise data source - main data or search results
    uniqueTickers = graphData.uniqueTickers;                    // Get a list of unique tickers from table currently in view
    graphData.lineSeries(uniqueTickers[navTickerTracking]);     // Prepare data series for ticker
    
    xData = graphData.xSeries;                                  // Upate vars used by Line Graph methods above
    yData = graphData.ySeries;
       
    userInterface.setGraphHeadings(LINE_TYPE[LINE_PRICE], graphData.dataTitle, graphData.periodTitle);         // Update GUI vars with header data
   
 }
 

  /*
   * @author  Keira Gatt
   * @date    11/04/2020
   *
   * @contributor  Samuel Alarco Cantos : line graph rotating colors
   *
   * Navigate through table columns with prev and next buttons
   * Navigate through ticker list with up and down buttons
   * Called by Main mousePressed() method
   * @param  navAction : ID of button clicked
   */

 void newDataSeries(int navAction) {                                                
    
    switch(navAction) {
      
        case NAV_LINE_PREV :
            navDataTracking --;                                                          // Select previous table column
            if(navDataTracking == DATA_TICKER) {
                  navDataTracking = DATA_VOLUME;
            }
            setLineColor(rotatingColors[(navDataTracking - 1)%rotatingColors.length]);
            break;
        case NAV_LINE_NEXT :
            navDataTracking ++;                                                          // Select next table column
            if(navDataTracking == DATA_DATE) {
                  navDataTracking = DATA_OPEN;
            }
            setLineColor(rotatingColors[(navDataTracking - 1)%rotatingColors.length]);
            break;
        case NAV_LINE_UP :
            navTickerTracking ++;                                                        // Select next ticker
            if(navTickerTracking == uniqueTickers.length) {
                  navTickerTracking = 0;
            }
            break;
        case NAV_LINE_DOWN :
            navTickerTracking --;                                                       // Select previous ticker
            if(navTickerTracking < 0) {
                  navTickerTracking = uniqueTickers.length - 1;
            }
               
    }
    
    navButtonInput = true;                                                              // Inidicate that new X & Y data series are triggered with navigation buttons    
    getDataSeries(DATA_DATE, navDataTracking);                                          // Generate new X & Y data series
    
  }
   
  // @Samuel Alarco - Function to override navigation buttons and jump straight to a nav position
  
  /*
   * Set current data in displayed and changes
   * line color
   * @param  trackingCode  int Code related to the data to be displayed (consult Constants for specific codes e.g. DATA_OPEN)
   */
  void setDataTracking(int trackingCode)
  {
    navDataTracking = trackingCode;
    setLineColor(rotatingColors[(navDataTracking - 1)%rotatingColors.length]);
    navButtonInput = true;
    getDataSeries(DATA_DATE, navDataTracking);
  }

}
