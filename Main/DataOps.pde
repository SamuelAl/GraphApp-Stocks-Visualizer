/*
DataOps Class

Keira M. Gatt (Group 33)
Student #19334557
CSU11013-A-SEM202-201920 PROGRAMMING PROJECT

V1.0 : 01/04/2020 : Code that does operations on data (moved from BarChart Class to this one so it can be shared by other Objects). Also includes Line Graph data method
V1.1 : 04/04/2020 : Code maintenance, additional code in lineSeries() to cater for search fail events
V1.2 : 12/04/2020 : Added standard deviation method
V1.3 : 14/04/2020 : Added varianceSeries(), priceChangeSeries and priceGainSeries + code maintenance
*/

import java.lang.Math;

class DataOps {
  
  final int MAXLINE_XDATA = 44;                 // Maximum data on x-axis when X series is DATA_DATE
      
  float[] ySeries;
  LocalDate[] graphDates;
  String dataTitle, periodTitle;
  String[] dataLabels, xSeries, uniqueTickers;
  int xDataCol, yDataCol;
  int[] avgCnt;
  
  Table chartTable;
 
  
  /*
   * Constructor to create DataOps object
   */
   
  DataOps() {

    graphDates = new LocalDate[2];
    
  }
  
 
  /*
   * Initialise data source for line graphs and bar charts and prepare headings
   * @param  xDataCol : Column id used to generate the X data series
   * @param  yDataCol : Column id used to generate the Y data series
   */
   
  void dataInit(int xDataCol, int yDataCol) {
    
    this.xDataCol = xDataCol;
    this.yDataCol = yDataCol;
        
    ArrayList<String> titleList = new ArrayList<String>();
    
    chartTable = searchFunctions.getTable();                                          // Assign search results table or main table
    graphDates = searchFunctions.getDates();                                          // Get start and end date for the returned table
    uniqueTickers = chartTable.getUnique(DATA_TICKER);                                // Get a list of unique tickers from table currently in view
    
    TableRow row = chartTable.getRow(0);                                              // Get column headings for chosen data series
    titleList.add(row.getColumnTitle(xDataCol));                                    
    titleList.add(row.getColumnTitle(yDataCol));
    
    dataLabels = new String[titleList.size()];                                        // Create data series display labels
    dataLabels = titleList.toArray(dataLabels);
    
    dataLabels[XLABEL] = dataLabels[XLABEL].substring(0, 1).toUpperCase() + dataLabels[XLABEL].substring(1);
    dataLabels[YLABEL] = dataLabels[YLABEL].substring(0, 1).toUpperCase() + dataLabels[YLABEL].substring(1);
    
    periodTitle = graphDates[START_DATE].getDayOfMonth() + "-" + graphDates[START_DATE].getMonth().getValue() + "-" + graphDates[START_DATE].getYear();      // Create time interval display label
    periodTitle += " : " + graphDates[END_DATE].getDayOfMonth() + "-" + graphDates[END_DATE].getMonth().getValue() + "-" + graphDates[END_DATE].getYear();
             
  }
  
 
  /*
   * Prepare data series for bar chart Period Average
   * Each data point represents the simple average for all values of a data column
   * for a ticker in the time interval specified by graphDates LocalDate array 
   */
   
  void avgSeries() {                                                          
    
    xSeries = uniqueTickers;                                                  // set x-axis to list of tickers
    ySeries = new float[xSeries.length];
    avgCnt = new int[xSeries.length];
    
    for(TableRow row : chartTable.rows()) {
      
      for(int i = 0; i < xSeries.length; i++) {                                // Aggregate column values specified by yDataCol for each ticker
      
          if(xSeries[i].equals(row.getString(xDataCol))) {
                ySeries[i] += row.getFloat(yDataCol);
                avgCnt[i]++;                                                  // Keep a count of sum elements for each ticker
          }
      }
    }
    
    for(int i = 0; i < ySeries.length; i++) ySeries[i] = ySeries[i] / (float) avgCnt[i];                           // Calculate ticker average for column yDataCol
    
    dataTitle = "X : " + dataLabels[XLABEL] + ", Y : " + dataLabels[YLABEL];                                        // Prepare title heading for this bar chart
    
  
  }
  
  
  /*
   * Prepare data series for bar chart Standard Deviation
   * Each data point represents the standard deviation for all values in a data column
   * for a ticker in the time interval specified by graphDates LocalDate array 
   */
   
  void stdDevSeries() {                                                                  
    
      avgSeries();                                                                       // Call method to get the simple average for each ticker
      
      float[] yStdDev = new float[xSeries.length];
 
      for(TableRow row : chartTable.rows()) {
      
        for(int i = 0; i < xSeries.length; i++) {                                          // Aggregate the square of the (ticker value - mean ticker value)
      
          if(xSeries[i].equals(row.getString(xDataCol))) yStdDev[i] += Math.pow((row.getFloat(yDataCol) - ySeries[i]), 2);
           
        }
      }

      for(int i = 0; i < ySeries.length; i++) {
        
            ySeries[i] = (float) Math.sqrt(yStdDev[i] / (float) avgCnt[i]);              // For each ticker, calculate StdDev with the sqr root of the mean of the squared difference
            
      }
      
      dataTitle = "X : " + dataLabels[XLABEL] + ", Y : " + dataLabels[YLABEL];            // Prepare title heading for this bar chart
      
  }
  
  
  /*
   * Prepare data series for bar charts Maximum Variance and Maximum Variance % of Minimum
   * When chartType == BAR_MAX, bar chart = Maximum Variance where each data point represents the difference between the
   * lowest and highest values in a data column for a ticker in the time interval specified by graphDates LocalDate array
   * When chartType == BAR_MPC, bar chart = Maximum Variance % of Minimum where each data point represents Maximum Variance as
   * a percentage of the lowest value in a data column for a ticker in the time interval specified by graphDates LocalDate array
   * @param  chartType : Can be either BAR_MAX (Maximum Variance) or BAR_MPC (Maximum Variance % of Minimum)
   */
  
  void varianceSeries(int chartType) {                                                           
    
    xSeries = uniqueTickers;
    ySeries = new float[xSeries.length];
    float varMin, varMax, yVal;
    boolean minMaxSet;
    
    varMin = varMax = 0.0;
        
    for(int i = 0; i < xSeries.length; i++) {                                     // For each ticker, get col min and max
      
      minMaxSet = false;
      
      for(TableRow row : chartTable.rows()) {
      
          if(xSeries[i].equals(row.getString(xDataCol))) {
            
                yVal = row.getFloat(yDataCol);
 
                if(!minMaxSet) {                                                  // Initialise min and max on first find
                      varMin = varMax = yVal;
                      minMaxSet = true;
                }
                else {
                     if(yVal < varMin) varMin = yVal;                            // Keep track of min and max values                            
                     if(yVal > varMax) varMax = yVal;
               }
          }
      }
      
      if(chartType == BAR_MAX) {
            ySeries[i] = varMax - varMin;                                       // For each ticker, calculate max variance for table col
      }
      else {
            ySeries[i] = ((varMax - varMin) / varMin) * 100;                     // Or calculate max variance % of minimum for table col
      }
      
    }
    
    dataTitle = "X : " + dataLabels[XLABEL] + ", Y : " + dataLabels[YLABEL];      // Prepare title headings for these bar charts
      
  }

  
  /*
   * Prepare data series for bar charts Price Change (Open vs Close) and Price Change (Low vs High)
   * Each data point represents the difference in prices between the Open and Close or the Low and High on a
   * daily basis for a ticker in the time interval specified by graphDates LocalDate array
   * @param  tickerName : A string with the name of the ticker
   * @param  chartType : Can be either BAR_PC_OPEN_CLOSE (Open vs Close) or BAR_PC_LOW_HIGH (Low vs High)
   */
     
  void priceChangeSeries(String tickerName, int chartType) {
    
    String xString, displayLabel;
    
    ArrayList<String> xDataList = new ArrayList<String>();
    ArrayList<Float> yDataList = new ArrayList<Float>();
    
          
    for (TableRow row : chartTable.findRows(tickerName, DATA_TICKER)) {                  // Loop through rows by ticker name
      
       xString = row.getString(xDataCol);                                                // Format to MM-DD if date column
       xString = xString.substring(5, xString.length());
      
       xDataList.add(xString);
       yDataList.add(abs(row.getFloat(yDataCol + 1) - row.getFloat(yDataCol)));        // Calculate difference between Open vs Close or Low vs High
             
       if(xDataList.size() == MAXLINE_XDATA) break;                                     // Check if we have reached the max no. of entries on the x-axis 
    }
           
    xSeries = new String[xDataList.size()];                                             // Convert array lists to String & float arrays
    ySeries = new float[xDataList.size()];
    
    for(int i = 0; i < xDataList.size(); i++) {
      
      xSeries[i] = xDataList.get(i);
      ySeries[i] = yDataList.get(i);
    
    }
    
    if(yDataCol == DATA_OPEN) {
          displayLabel = "Open vs Close";                                            // Prepare title headings for these bar charts
    }
    else {
          displayLabel = "Low vs High";
    }
    
    dataTitle = "X : " + tickerName + ", Y : " + displayLabel;                   
         
  }
  
  
   /*
   * Prepare data series for bar charts Price Gain % (Open vs Close) and Price Gain % (Low vs High)
   * Each data point represents the difference in prices between the Open and Close or the Low and High,
   * expressed as a percentage of the lowest Open or lowest Low. The data series is generated for each
   * ticker in the time interval specified by graphDates LocalDate array
   *
   * Modelled on largestPercentageChange() method from Database Class by Samuel Alarco Cantos
   */
  
  void priceGainSeries() {                                                      
                                                                                 
    boolean hiLowSet;
    String displayLabel;
    xSeries = uniqueTickers;
    ySeries = new float[xSeries.length];
    float lowVal, hiVal, yLowVal, yHiVal;
    
    
    for(int i = 0; i < xSeries.length; i++) {                                     // For each ticker, get open & close or low & high
      
      hiLowSet = false;
      yLowVal = yHiVal = 0.0;
      
      for(TableRow row : chartTable.rows()) {
      
          if(xSeries[i].equals(row.getString(xDataCol))) {
            
                lowVal = row.getFloat(yDataCol);
                hiVal = row.getFloat(yDataCol + 1);
 
                if(!hiLowSet) {                                                  // Initialise min and max on first find
                      yLowVal = lowVal;
                      yHiVal = hiVal;
                      hiLowSet = true;
                }
                else {
                     if(lowVal < yLowVal) yLowVal = lowVal;                      // Keep track of lowest and highest entries                            
                     if(hiVal > yHiVal) yHiVal = hiVal;
               }
          }
      }
      
      ySeries[i] = ((yHiVal - yLowVal) / yLowVal) * 100;                        // ((close - open) / open)% or ((high - low) / low)%
      if(ySeries[i] < 0.0) {
            ySeries[i] = 0.0;                                                  // Set to zero when there are no gains
      }
           
    }
    
    if(yDataCol == DATA_OPEN) {
          displayLabel = "Open vs Close";                                  // Prepare title headings for these bar charts
    }
    else {
          displayLabel = "Low vs High";
    }
    
    dataTitle = "X : " + dataLabels[XLABEL] + ", Y : " + displayLabel;    
      
  }
  
  
  /*
   * Prepare data series for line graph with continues data points for the data column specified
   * by yDataCol, as set by method dataInit(). The data series is for one ticker and the X-values
   * represent the timeline as specified by graphDates LocalDate array
   * @param  tickerName : A string with the name of the ticker
   */
  
  void lineSeries(String tickerName) {                                                  
    
    String xString;
    
    ArrayList<String> xDataList = new ArrayList<String>();
    ArrayList<Float> yDataList = new ArrayList<Float>();
    
    if(chartTable.getRowCount() > 0) {                                                      // Do this only if we have content
      
       for (TableRow row : chartTable.findRows(tickerName, DATA_TICKER)) {                  // Get X & Y data from table
      
          xString = row.getString(xDataCol);                                                 // Format to MM-DD if date column
          xString = xString.substring(5, xString.length());
      
          xDataList.add(xString);
          yDataList.add(row.getFloat(yDataCol));
      
          if(xDataList.size() == MAXLINE_XDATA) break;                                // Check if we have reached the max no. of entries on the x-axis 
        }
    
    }
    else {                                                                             // If no data available, pad X & Y data series 
      
        xDataList.add("");
        yDataList.add(0.0);
        
    }
   
    xSeries = new String[xDataList.size()];                                             // Convert array lists to String & float arrays
    ySeries = new float[xDataList.size()];
    
    for(int i = 0; i < xDataList.size(); i++) {
      
       xSeries[i] = xDataList.get(i);
       ySeries[i] = yDataList.get(i);
    
    }
    
    dataTitle = "X : " + tickerName + ", Y : " + dataLabels[YLABEL];                      // Prepare title heading for line graph
         
  }
 
}
