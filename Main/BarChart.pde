/*
BarChart Class

Keira M. Gatt (Group 33)
Student #19334557
CSU11013-A-SEM202-201920 PROGRAMMING PROJECT

V1.0 : 25/03/2020 : First implementation using only main table data
V1.1 : 27/03/2020 : Manual integration without updated app due to SVN conflicts, support for search results and display of values on mouse hover
V1.2 : 04/04/2020 : Display of X-axis entries refined when range allows for all elements to be displayed without overlapping
V1.3 : 11/04/2020 : Added support for chart navigation through all table columns with prev and next buttons
V1.4 : 12/04/2020 : Added support for standard deviation graph, improved accuracy on y-scale
V1.5 : 14/04/2020 : Added support for varianceSeries(), priceChangeSeries and priceGainSeries + code maintenance
V1.6 : 22/04/2020 : Delegation of graph headings display methods to GUI class
*/

class BarChart extends Drawable {
  
  final int XDENSITY = 24;                      // If exceeded, show x-axis entries on 2 levels
    
  float[] ySeries;
  String[] xSeries, uniqueTickers;
  boolean navButtonInput;
  float yAxis, yStep, yMin, yMax;
  int xAxis, xStep, xOffset, width, height, navDataTracking, navChartTracking, navTickerTracking, navPGainTracking;
  
  PGraphics pg;
  Table chartTable;
  DataOps chartData;
  
  
  /*
   * Constructor to create BarChart object
   * @param  xData : x-data series
   * @param  yData : y-data series
   * @param  width : width of bar chart display panel
   * @param  height : height of bar chart display panel
   */
    
  BarChart(String[] xData, float[] yData, int width, int height) {
    
      xSeries = xData;
      ySeries = yData;
      xAxis = width - 60;
      yAxis = height - 80.0;
      this.width = width;
      this.height = height;
      navButtonInput = false;
      
      chartData = new DataOps();
         
  }


  /*
   * Constructor to create BarChart object
   * @param  xData : x-data series
   * @param  yData : y-data series
   * @param  width : width of bar chart display panel
   * @param  height : height of bar chart display panel
   * @param  pg : graphics container for bar chart
   */

  BarChart(String[] xData, float[] yData, int width, int height, PGraphics pg) {
    
      this(xData, yData, width, height);
      this.pg = pg;
 
  }


  /*
   * Set PGraphics container
   * @param  pg : graphics container for bar chart
   */
   
  void setPG(PGraphics pg) {
  
    this.pg = pg;
    
  }


  /*
   * Implements abstract scrolling method as required by class Drawable
   * Not applicable for Bar Chart Class
   *
   * @param  change : mouse scroll offset
   */
   
  void changeScrollOffset(float change) {
  
    // NOP
    
  }
  
  
  /* 
   * Plot bar chart
   */
   
  void draw() {

    pg.fill(lightGreyColor);                                                       // Draw display panel
    pg.rectMode(CORNER);
    pg.noStroke();
    pg.rect(30, 20, width - 60, height - 70);
    
    pg.stroke(blackColor);
    pg.line(30, height - 50, width - 30, height - 50);
    pg.line(30, height - 420, 30, height - 50);
    
    if(xSeries.length > 0) {                                                        // Plot graph only if data series is not empty

      String yFormat, yMultiplier;
      
      yMultiplier = "";                                                      
            
      pg.textSize(10);
      pg.noStroke();
      pg.fill(blackColor);
      
      for(float i = yAxis; i > -1.0; i--) {
     
        if(i % 40.0 == 0.0) {                                                                   // Draw y-scale in 40-unit increments
            pg.text("-", 27, height - 57 - i);
            
            if(yMax >= 1e6) {
                  yFormat = String.format("%.1f", (i / yStep) / 1e6);                            // Adjust y-scale resolution to avoid overlaps
                  yMultiplier = "[ M ]";
            }
            else if(yMax >= 1e3) {
                  yFormat = String.format("%.1f", (i / yStep) / 1e3);
                  yMultiplier = "[ K ]";
            }
            else {
                  yFormat = String.format("%.1f", (i / yStep));
            }
          
            pg.text(yFormat, 3, height - 57 - i);                              // Display unit on y-axis
           
        }
      
      }
      
      if(yMultiplier != "") {                                                // Display multiplier label at the graph origin if applicable
            pg.fill(yellowColor);                                                       
            pg.rect(3, height - 44, 19, 16);
            pg.fill(blackColor);
            pg.text(yMultiplier, 3, height - 44);                              
      }

      int yOffset;
      float xPoint, yPoint, barHeight;
      
      for(int i = 0; i < xSeries.length; i++) {                                   // Draw x-scale and plot data bars
      
        if(i % 2 > 0 && xSeries.length > XDENSITY) {
              yOffset = 8;                                                        // Display units on 2 levels on the x-axis to avoid cluttering if # entries exceeds limit
        }
        else {
              yOffset = 0;
        }
      
        pg.fill(blackColor);
        pg.text(xSeries[i], 20 + xOffset + (i * xStep), height - 42 - yOffset);
        if(yOffset == 0) {
              pg.text("|", 30 + xOffset + (i * xStep), height - 52);
        }

        xPoint = 20 + xOffset + (i * xStep);                                      // Calculate bar coordinates
        yPoint = height - 50 - (ySeries[i] * yStep);
        barHeight = (ySeries[i] * yStep);
        
        pg.fill(lightRedColor);
        pg.rect(xPoint, yPoint, 20, barHeight);                                   // Plot chart and display value on mouse hover
        
        if((mouseX - CONTAINER_X) > xPoint && (mouseX - CONTAINER_X) < (xPoint + 20) && (mouseY - CONTAINER_Y) > (yPoint - 10) && (mouseY - CONTAINER_Y) < (yPoint + barHeight)) {
            pg.fill(blackColor);
            pg.text(ySeries[i], (mouseX - CONTAINER_X - 10), (mouseY - CONTAINER_Y - 20));
        }
        
      }
      
      pg.stroke(blackColor);                // Reset stroke settings
      
    }

  }
  
  
  /* 
   * Prepare X & Y data series for bar chart
   * @param  xDataCol : Column id used to generate the X data series
   * @param  yDataCol : Column id used to generate the Y data series
   */
   
  void getDataSeries(int xDataCol, int yDataCol) {
    
    if(!navButtonInput) {                                                                            // check if method was called by Main interface button or graph nav buttons
          navTickerTracking = 0;
          navChartTracking = BAR_AVG;
          navPGainTracking = DATA_OPEN;
    }
    navButtonInput = false;
    
    if(navChartTracking < BAR_PC_OPEN_CLOSE) navDataTracking = yDataCol;                            // Keep track of current table col in view (relevant only when x-axis == ticker names)
          
    chartData.dataInit(xDataCol, yDataCol);                                                         // Select data source
    uniqueTickers = chartData.uniqueTickers;                                                        // Get a list of unique tickers associated with current table
    
    switch(navChartTracking) {
      
        case BAR_AVG :
            chartData.avgSeries();                                                                    // Prepare Period Average data series
            break;
        case BAR_STD :
            chartData.stdDevSeries();                                                                 // Prepare Standard Deviation data series
            break;
        case BAR_MPC :
        case BAR_MAX :
            chartData.varianceSeries(navChartTracking);                                               // Prepare Maximum Variance and Maximum Variance % of Minimum data series
            break;
        case BAR_PC_OPEN_CLOSE :                                                                     // Prepare Price Change (Open vs Close) and Price Change (Low vs High) data series 
        case BAR_PC_LOW_HIGH :
            chartData.priceChangeSeries(uniqueTickers[navTickerTracking], navChartTracking);
            break;
        case BAR_PGAIN :                                                                            // Prepare Price Gain % (Open vs Close) and Price Gain % (Low vs High) data series
            chartData.priceGainSeries();
            
    }
        
    xSeries = chartData.xSeries;                                                                    // Upate vars used by other BarChart Class methods
    ySeries = chartData.ySeries;
    userInterface.setGraphHeadings(BAR_TYPE[navChartTracking], chartData.dataTitle, chartData.periodTitle);         // Update GUI vars with header data
    
    if(xSeries.length > 0) {                                                          // Do this only if data series is not empty
      
      yMin = yMax = ySeries[0];                                                       // Find min and max values of data range
      for(int i = 1; i < ySeries.length; i++) {
  
        if(ySeries[i] < yMin) yMin = ySeries[i];
        if(ySeries[i] > yMax) yMax = ySeries[i];
       
      }
      
      xStep = xAxis / xSeries.length;                                                  // Variables used for scaling
      xOffset = xAxis / (xSeries.length * 2);
      yStep = yAxis / yMax;                                                            
                                         
    }
     
  }
  
  
  /*
   * Navigate through bar charts using up, down, previous and next navigation buttons
   * Called by Main mousePressed() method
   * @param  navAction : ID of button clicked
   */
   
  void newDataSeries(int navAction) {                                                
    
    switch(navAction) {
      
        case NAV_BAR_PREV :
            if(navChartTracking < BAR_PC_OPEN_CLOSE) {
                navDataTracking --;                                                         // Select previous table column
                if(navDataTracking == DATA_TICKER) {
                      navDataTracking = DATA_VOLUME;
                }
            }
            else if(navChartTracking < BAR_PGAIN) {
                navTickerTracking --;
                if(navTickerTracking < 0) {
                      navTickerTracking = uniqueTickers.length - 1;
                }
            }
            else {
                if(navPGainTracking == DATA_OPEN) {
                      navPGainTracking = DATA_LOW;
                }
                else {
                      navPGainTracking = DATA_OPEN;
                }
            }
            break;
            
        case NAV_BAR_NEXT :
            if(navChartTracking < BAR_PC_OPEN_CLOSE) {
                navDataTracking ++;                                                          // Select next table column
                if(navDataTracking == DATA_DATE) {
                      navDataTracking = DATA_OPEN;
                }
            }
            else if(navChartTracking < BAR_PGAIN) {
                navTickerTracking ++;
                if(navTickerTracking == uniqueTickers.length) {
                      navTickerTracking = 0;
                }
            }
            else {
                if(navPGainTracking == DATA_OPEN) {
                      navPGainTracking = DATA_LOW;
                }
                else {
                      navPGainTracking = DATA_OPEN;
                }
            }
            break;
            
        case NAV_BAR_UP :
            navChartTracking ++;                                                          // Select next graph type
            if(navChartTracking > BAR_PGAIN) {
                    navChartTracking = BAR_AVG;
            }
            break;
            
        case NAV_BAR_DOWN :
            navChartTracking --;                                                          // Select previous graph type
            if(navChartTracking == BAR_NULL) {
                    navChartTracking = BAR_PGAIN;
            }
               
    }
    
    navButtonInput = true;                                            // Flag that input came from graph nav button
    
    switch(navChartTracking) {                                        // Generate new X & Y data series
      
        case BAR_PC_OPEN_CLOSE :
            getDataSeries(DATA_DATE, DATA_OPEN);
            break;
        case BAR_PC_LOW_HIGH :
            getDataSeries(DATA_DATE, DATA_LOW);
            break;
        case BAR_PGAIN :
            getDataSeries(DATA_TICKER, navPGainTracking);
            break;
        default :
            getDataSeries(DATA_TICKER, navDataTracking);
            
    }        
     
  }

}
