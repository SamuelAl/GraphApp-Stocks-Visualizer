/**
 * Database class for loading and handling data from csv files and MySQL server
 *  
 * The database can connect to a MySQL server using an appropriate JDBC Connector, that is installed in the libraries folder for Processing
 * The code is adapted from the latest JDBC connector in order to be imported as a Processing library.
 *
 * @author Samuel Alarco Cantos
 * @version 3.0
 * @since 2020-03-10
 */

// Samuel Alarco : 14/04/2020 : Added multiple key support for industry, sector and exchange queries.
//                              Added method to return unique labels of specified type from stockRedDatabase eg. list of unique exchanges, list of unique sectors etc. 

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;


class Database
{
  Table database = null;
  Table stocksRefDatabase = null;
  Table partialQuery;
  String[] columnNamesPrices = {"ticker", "open", "close", "adj_close", "low", "high", "volume", "date"};
  boolean sqlMode = false;  //modify to turn on SQL

  // SQL Config
  String url = "jdbc:mysql://localhost:3306/stocksdb?useJDBCCompliantTimezoneShift=true&useLegacyDatetimeCode=false&serverTimezone=UTC";
  String user = "root";
  String password = "31415ein";
  Connection connection = null;

  ArrayList<String> whereClause, fromClause, selectClause, innerJoinClause;
  String sortingClause;
  int limitClause;

  /** Constructor
   * Constructor to create database object
   * @param  file String containing name of .csv file (saved in data folder)
   * @param  stocksRef String  containing name of .csv stocks reference file (saved in data folder)
   */
  Database(String file, String stocksRef)
  {
    database = loadTable(file, "header");
    stocksRefDatabase = loadTable(stocksRef, "header");
    partialQuery = database;

    for (int i = 0; i < columnNamesPrices.length; i++)
    {
      columnNamesPrices[i] = new String("daily_prices." + columnNamesPrices[i]);
    }

    whereClause = new ArrayList<String>();
    fromClause = new ArrayList<String>();
    selectClause = new ArrayList<String>();
    innerJoinClause = new ArrayList<String>();
    sortingClause = "";
    limitClause = 0;

    if (sqlMode)
    {
      try
      {
        connection = DriverManager.getConnection(url, user, password);
      }
      catch (SQLException e)
      {
        System.out.println(e.getMessage());
      }
    }
  }

  /**
   * Returns entire database table without queries or filters (use of this feature should be avoided as it can overload the program)  
   * @return Table object containing database data
   */
  Table getData()
  {
    return database;
  }

  /**
   * Resets internal query holder object to copy of original database
   */
  void newQuery()
  {
    if (!sqlMode)
    {
      partialQuery = database.copy();
    } else
    {
      whereClause.clear();
      fromClause.clear();
      selectClause.clear();
      innerJoinClause.clear();
      sortingClause = "";
    }
  }

  /**
   * Returns query result as it stands and resets query
   * @return Table object containing query data
   */
  Table getQueryResult()
  {
    Table queryResult = null;
    if (!sqlMode)
    {
      queryResult = partialQuery;
      newQuery();
    } else
    {
      String query = "SELECT ";
      //SELECT clauses
      if (fromClause.contains("daily_prices"))
      {
        for (int i = 0; i < columnNamesPrices.length; i++)
        {
          if (i > 0) {
            query += ", ";
          }
          query += columnNamesPrices[i];
        }
        if (selectClause.size() > 0) {
          query += ", ";
        }
      }

      for (int i = 0; i < selectClause.size(); i++)
      {
        if (i > 0) {
          query += ", ";
        }
        query += selectClause.get(i);
      }

      query += " ";
      //FROM clauses
      query += "FROM ";
      query += "stocksdb." + fromClause.get(0) + " ";

      //INNER JOIN clauses
      for (String join : innerJoinClause)
      {
        query += "INNER JOIN ";
        query += join;
      }

      query += " ";

      //WHERE clauses
      query += "WHERE ";
      for (int i = 0; i < whereClause.size(); i++) 
      {
        if (i > 0) {
          query += " AND ";
        }
        query += whereClause.get(i);
      }

      //ORDER BY clause
      if (!sortingClause.equals(""))
      {
        query += "ORDER BY " + sortingClause;
      }
      query += " ";
      
      //LIMIT clause
      if (limitClause > 0)
      {
        query += "LIMIT " + limitClause;
      }
      else
      {
        // Standard limit to avoid data overflow. Can be changed
        query += "LIMIT 10000";
      }
      query += ";";

      try
      {
        // Execute query
        System.out.println(query);
        Connection connection = DriverManager.getConnection(url, user, password);
        Statement statement = connection.createStatement();
        ResultSet results = statement.executeQuery(query);
        //Build results table
        ResultSetMetaData resultsMetaData = results.getMetaData();
        queryResult = new Table();
        int columnCount = resultsMetaData.getColumnCount();
        for (int i= 1; i <= columnCount; i++)
        {
          String columnTitle = resultsMetaData.getColumnName(i);          
          queryResult.addColumn(columnTitle);
        }
        DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        while (results.next())
        {
          TableRow newRow = queryResult.addRow();
          for (int i = 0; i < columnCount; i++)
          {
            String columnTitle = resultsMetaData.getColumnName(i + 1);
            int typeNumber = resultsMetaData.getColumnType(i + 1);
            switch(typeNumber)
            {
              // Type String
            case 12:
              newRow.setString(columnTitle, results.getString(columnTitle));
              break;
              // Type Date
            case 93:
              Date date = results.getDate(columnTitle);
              String parsedDate = dateFormat.format(date);
              newRow.setString(columnTitle, parsedDate);
              break;
              // Type float
            case 7:
              newRow.setFloat(columnTitle, results.getFloat(columnTitle));
              break;
              // Type int
            case 4:
              newRow.setInt(columnTitle, results.getInt(columnTitle));
              break;
            default:
              newRow.setString(columnTitle, results.getString(columnTitle));
              break;
            }
            System.out.print(results.getString(columnTitle) + "  -  ");
          }
          System.out.println("");
        }
        System.out.println("Results: " + queryResult.getRowCount());
        newQuery();
      }
      catch (SQLException e)
      {
        e.printStackTrace(System.out);
      }
    }
    return queryResult;
  }

  /**
   * Query to filter for a specific ticker name
   * @param ticker String of ticker name to be searched for
   */
  void selectTickerName(String ticker)
  {
    if (!sqlMode)
    {
      Table tickerFilter = new Table();
      tickerFilter.setColumnTitles(partialQuery.getColumnTitles());
      for (TableRow row : partialQuery.findRows(ticker, "ticker"))
      {
        tickerFilter.addRow(row);
      }
      partialQuery = tickerFilter;
    } else
    {
      whereClause.add("daily_prices.ticker = '" + ticker + "'");
      if (!fromClause.contains("daily_prices"))
        fromClause.add("daily_prices");
    }
  }

  /**
   * Query to filter for one or more ticker names
   * @param ticker String[] of ticker names to be searched for
   */
  void selectTickerNames(String[] tickers)
  {
    if (tickers == null) {throw new IllegalArgumentException("null array");}
    if (!sqlMode)
    {
      Table tickersFilter = new Table();
      tickersFilter.setColumnTitles(partialQuery.getColumnTitles());

      for (int i = 0; i < tickers.length; i++)
      {
        for (TableRow row : partialQuery.findRows(tickers[i], "ticker"))
        {
          tickersFilter.addRow(row);
        }
      }
      partialQuery = tickersFilter;
    } else
    {
      String where = "daily_prices.ticker IN (";
      for (int i = 0; i < tickers.length; i++)
      {
        if (i > 0) {
          where += ", ";
        }
        where += "'" +  tickers[i] + "'";
      }
      where += ")";

      whereClause.add(where);
      if (!fromClause.contains("daily_prices"))
        fromClause.add("daily_prices");
    }
  }

  /**
   * Query to filter rows between two specific dates (inclusive)
   * @param date1 LocalDate: beginning date (inclusive)
   * @param date2 LocalDate: end date (inclusive)
   */
  void selectBetweenDates(LocalDate date1, LocalDate date2)
  {
    if (date1.isAfter(date2)) {throw new IllegalArgumentException("Date1 is after Date2");}
    if (!sqlMode)
    {
      Table queryResult = new Table();
      queryResult.setColumnTitles(partialQuery.getColumnTitles());
      partialQuery.sort("date");
      DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
      try
      {
        for (TableRow row : partialQuery.rows())
        {
          String dateString = row.getString("date");
          LocalDate parsedDate = LocalDate.parse(dateString, formatter);
          if ((parsedDate.isAfter(date1) || parsedDate.isEqual(date1)) && 
            (parsedDate.isBefore(date2) || parsedDate.isEqual(date2)))
          {
            queryResult.addRow(row);
          }
        }
      }
      catch (Exception e) {
      }
      partialQuery = queryResult;
    } else
    {
      DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy/MM/dd");
      String parsedDate1 = date1.format(formatter);
      String parsedDate2 = date2.format(formatter);
      String where = "daily_prices.date BETWEEN '" + parsedDate1 + "' AND '" + parsedDate2 + "'";
      whereClause.add(where);
      if (!fromClause.contains("daily_prices"))
        fromClause.add("daily_prices");
    }
  }

  /**
   * Query to calculate and return stocks with most
   * percentage change between open and close prices 
   * on a specific date.
   * Results sorted in from largest to smallest change
   * @param date LocalDate: date to be analyzed
   * @param max Int: maximum number of rows to include
   */
  void largestPercentageChange(LocalDate date, int max)
  {
    if (!sqlMode)
    {
      Table queryResult = new Table();
      queryResult.setColumnTitles(partialQuery.getColumnTitles());
      for (TableRow row : partialQuery.rows())
      {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        String dateString = row.getString("date");
        LocalDate parsedDate = LocalDate.parse(dateString, formatter);
        if (parsedDate.isEqual(date)) {
          queryResult.addRow(row);
        }
      }
      queryResult.addColumn("per_diff");
      for (TableRow row : queryResult.rows())
      {
        float difference = row.getFloat("close") - row.getFloat("open");
        float percentageDifference = difference / row.getFloat("open") * 100;
        row.setFloat("per_diff", percentageDifference);
      }
      queryResult.sortReverse("per_diff");
      Table limitedQueryResult = new Table();
      limitedQueryResult.setColumnTitles(queryResult.getColumnTitles());
      for (int i = 0; i < max && i < queryResult.getRowCount(); i++)
      {
        limitedQueryResult.addRow(queryResult.getRow(i));
      }
      partialQuery = limitedQueryResult;
    }
    else
    {
      if (!fromClause.contains("daily_prices"))
      {
        fromClause.add("daily_prices");
      }
      selectClause.add("(daily_prices.close - daily_prices.open)/daily_prices.open * 100 AS per_diff");
      DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy/MM/dd");
      String parsedDate = date.format(formatter);
      whereClause.add("daily_prices.date = '" + parsedDate + "'");
      sortingClause = "per_diff DESC";
      limitClause = max;
    }
  }
  
  /**
   * Query to calculate mean of prices grouped by ticker. 
   * Meant to be used together with date and ticker queries,
   * else too much data might be returned
   */
  void meanByTicker()
  {
    // this could be implemented in the database to increase speed, but due to team factors it was implemented in the SearchTools/DataOps class group
  }

  /**
   * Query to filter by exchange
   * @param exchange String: name of exchange eg. NASDAQ
   */
  void selectExchange(String exchange)
  {
    if (!sqlMode)
    {
      Table queryResult = new Table();
      queryResult.setColumnTitles(partialQuery.getColumnTitles());
      for (TableRow row : partialQuery.rows())
      {
        String ticker = row.getString("ticker").trim();
        TableRow reference = stocksRefDatabase.findRow(ticker, "ticker");
        if (reference.getString("exchange").equals(exchange))
        {
          queryResult.addRow(row);
        }
      }
      partialQuery = queryResult;
    } else
    {
      if (!fromClause.contains("daily_prices"))
        fromClause.add("daily_prices");
      selectClause.add("stocks.exchange");
      if (!innerJoinClause.contains("stocksdb.stocks ON daily_prices.ticker = stocks.ticker"))
      {
        innerJoinClause.add("stocksdb.stocks ON daily_prices.ticker = stocks.ticker");
      }
      whereClause.add("stocks.exchange = '" + exchange + "'");
    }
  }
  
  /**
   * Query to filter by exchanges (in array)
   * @param exchanges String[]: array containing names of exchanges eg. NASDAQ, NYSE
   */
  void selectExchanges(String[] exchanges)
  {
    if (exchanges == null) {throw new IllegalArgumentException("null array");}
    if (!sqlMode)
    {
      Table queryResult = new Table();
      queryResult.setColumnTitles(partialQuery.getColumnTitles());
      for (TableRow row : partialQuery.rows())
      {
        String ticker = row.getString("ticker").trim();
        TableRow reference = stocksRefDatabase.findRow(ticker, "ticker");
        for (String exchange : exchanges)
        {
          if (reference.getString("exchange").equals(exchange))
          {
            queryResult.addRow(row);
            break;
          }
        }
      }
      partialQuery = queryResult;
    } else
    {
      if (!fromClause.contains("daily_prices"))
        fromClause.add("daily_prices");
      selectClause.add("stocks.exchange");
      if (!innerJoinClause.contains("stocksdb.stocks ON daily_prices.ticker = stocks.ticker"))
      {
        innerJoinClause.add("stocksdb.stocks ON daily_prices.ticker = stocks.ticker");
      }
      
      String newWhereClause = "stocks.exchange IN (";
  
      for (int i = 0; i < exchanges.length; i++)
      {
        if (i > 0) {
          newWhereClause+= ", ";
        }
        newWhereClause+= "'" +  exchanges[i] + "'";
      }
      newWhereClause += ")";
      whereClause.add(newWhereClause);
    }
  }

  /**
   * Query to filter by sector
   * @param exchange String: name of sector eg. FINANCE
   */
  void selectSector(String sector)
  {
    if (!sqlMode)
    {
      Table queryResult = new Table();
      queryResult.setColumnTitles(partialQuery.getColumnTitles());

      for (TableRow row : partialQuery.rows())
      {
        String ticker = row.getString("ticker").trim();
        TableRow reference = stocksRefDatabase.findRow(ticker, "ticker");
        if (reference.getString("sector").equals(sector))
        {
          queryResult.addRow(row);
        }
      }
      partialQuery = queryResult;
    } else
    {
      if (!fromClause.contains("daily_prices"))
      {
        fromClause.add("daily_prices");
      }
      selectClause.add("stocks.sector");
      if (!innerJoinClause.contains("stocksdb.stocks ON daily_prices.ticker = stocks.ticker"))
      {
        innerJoinClause.add("stocksdb.stocks ON daily_prices.ticker = stocks.ticker");
      }
      whereClause.add("stocks.sector = '" + sector + "'");
    }
  }
  
  /**
   * Query to filter by sectors (in array)
   * @param exchange String[]: names of sectors eg. FINANCE
   */
  void selectSectors(String[] sectors)
  {
    if (sectors == null) {throw new IllegalArgumentException("null array");}
    if (!sqlMode)
    {
      Table queryResult = new Table();
      queryResult.setColumnTitles(partialQuery.getColumnTitles());

      for (TableRow row : partialQuery.rows())
      {
        String ticker = row.getString("ticker").trim();
        TableRow reference = stocksRefDatabase.findRow(ticker, "ticker");
        for (String sector : sectors)
        {
          if (reference.getString("sector").equals(sector))
          {
            queryResult.addRow(row);
            break;
          }
        }
      }
      partialQuery = queryResult;
    } else
    {
      if (!fromClause.contains("daily_prices"))
      {
        fromClause.add("daily_prices");
      }
      selectClause.add("stocks.sector");
      if (!innerJoinClause.contains("stocksdb.stocks ON daily_prices.ticker = stocks.ticker"))
      {
        innerJoinClause.add("stocksdb.stocks ON daily_prices.ticker = stocks.ticker");
      }
      
      String newWhereClause = "stocks.sector IN (";
  
      for (int i = 0; i < sectors.length; i++)
      {
        if (i > 0) {
          newWhereClause+= ", ";
        }
        newWhereClause+= "'" +  sectors[i] + "'";
      }
      newWhereClause += ")";
      whereClause.add(newWhereClause);
    }
  }

  /**
   * Query to filter by Industry
   * @param exchange String: name of Industry eg. PROPERTY-CASUALTY INSURERS
   */
  void selectIndustry(String industry)
  {
    if (!sqlMode)
    {
      Table queryResult = new Table();
      queryResult.setColumnTitles(partialQuery.getColumnTitles());

      for (TableRow row : partialQuery.rows())
      {
        String ticker = row.getString("ticker").trim();
        TableRow reference = stocksRefDatabase.findRow(ticker, "ticker");
        if (reference.getString("industry").equals(industry))
        {
          queryResult.addRow(row);
        }
      }

      partialQuery = queryResult;
    } else
    {
      if (!fromClause.contains("daily_prices"))
      {
        fromClause.add("daily_prices");
      }
      selectClause.add("stocks.industry");
      if (!innerJoinClause.contains("stocksdb.stocks ON daily_prices.ticker = stocks.ticker"))
      {
        innerJoinClause.add("stocksdb.stocks ON daily_prices.ticker = stocks.ticker");
      }
      whereClause.add("stocks.industry = '" + industry + "'");
    }
  }
  
  /**
   * Query to filter by Industries
   * @param exchange String[]: names of Industries eg. PROPERTY-CASUALTY INSURERS
   */
  void selectIndustry(String[] industries)
  {
    if (industries == null) {throw new IllegalArgumentException("null array");}
    if (!sqlMode)
    {
      Table queryResult = new Table();
      queryResult.setColumnTitles(partialQuery.getColumnTitles());

      for (TableRow row : partialQuery.rows())
      {
        String ticker = row.getString("ticker").trim();
        TableRow reference = stocksRefDatabase.findRow(ticker, "ticker");
        for (String industry : industries)
        {
          if (reference.getString("industry").equals(industry))
          {
            queryResult.addRow(row);
            break;
          }
        }
      }

      partialQuery = queryResult;
    } else
    {
      if (!fromClause.contains("daily_prices"))
      {
        fromClause.add("daily_prices");
      }
      selectClause.add("stocks.industry");
      if (!innerJoinClause.contains("stocksdb.stocks ON daily_prices.ticker = stocks.ticker"))
      {
        innerJoinClause.add("stocksdb.stocks ON daily_prices.ticker = stocks.ticker");
      }
      
     String newWhereClause = "stocks.sector IN (";
  
      for (int i = 0; i < industries.length; i++)
      {
        if (i > 0) {
          newWhereClause+= ", ";
        }
        newWhereClause+= "'" +  industries[i] + "'";
      }
      newWhereClause += ")";
      whereClause.add(newWhereClause);
    }
  }

  /**
   * Returns list of unique tickers present in database file
   */
  String[] getTickerNames()
  {
    String[] tickers = new String[1];
    if (!sqlMode)
    {
      tickers = database.getUnique("ticker");
    } else
    {
      try
      {
        //Establish connection and execute query
        Connection connection = DriverManager.getConnection(url, user, password);
        Statement statement = connection.createStatement();
        String query = "SELECT DISTINCT daily_prices.ticker FROM stocksdb.daily_prices;";
        ResultSet results = statement.executeQuery(query);

        //Prepare results
        ArrayList<String> uniqueTickerList = new ArrayList<String>();
        while (results.next())
        {
          uniqueTickerList.add(results.getString("ticker"));
        }
        tickers = uniqueTickerList.toArray(tickers);
        results.close();
        statement.close();
      }
      catch (SQLException e)
      {
        System.out.println(e);
      }
    }
    return tickers;
  }
  
  /**
   * Returns list of unique info labels present in stocksRefDatabase file
   * @param labelType String: type of label eg. sector, exchange, industry....
   * @return String[] of unique labels of selected type
   */
  String[] getUniqueStockInfoLabelList(String labelType)
  {
    String[] resultArray = new String[1];
    if (!sqlMode)
    {
      resultArray = stocksRefDatabase.getUnique(labelType);
    } else
    {
      try
      {
        //Establish connection and execute query
        Connection connection = DriverManager.getConnection(url, user, password);
        Statement statement = connection.createStatement();
        String query = "SELECT DISTINCT stocks." + labelType  + " FROM stocksdb.stocks;";
        ResultSet results = statement.executeQuery(query);

        //Prepare results
        ArrayList<String> uniqueLabelList = new ArrayList<String>();
        while (results.next())
        {
          uniqueLabelList.add(results.getString(labelType));
        }
        resultArray = uniqueLabelList.toArray(resultArray);
        results.close();
        statement.close();
      }
      catch (SQLException e)
      {
        System.out.println(e);
      }
    }
    return resultArray;
  }

  /**
   * Sorts partial query result according to values on column specified
   * @param  columnName  String name of column to be sorted
   * @param  descendingOrder  boolean true - column sorted in ascending order; false - column sorted in descending order
   */
  void sortQuery(String columnName, boolean ascendingOrder)
  {
    if (!sqlMode)
    {
      if (ascendingOrder)
      {
        partialQuery.sort(columnName);
      } else
      {
        partialQuery.sortReverse(columnName);
      }
    } else
    {
      sortingClause =  columnName + " " + (ascendingOrder ? "ASC" : "DESC");
    }
  }

  /**
   * Reset sorting statement
   */
  void resetSorting()
  {
    sortingClause = "";
  }

  /**
   * Sets database mode (MySQL server or CSV database mode)
   * @param boolean true - MySQL server mode;  false - CSV import mode
   */
  void setSQLMode(boolean sql)
  {
    this.sqlMode = sql;
  }
}
