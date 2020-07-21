/*
Date handler class for handling date-related functions within the application
 
 - code authored by David Olowookere
 - v2.0, 22/04/2020
 */

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

class Date_Handler {
  Date_Handler() {
  }

  void setup() {
    // Date initialisation
    dayMonthYear = DateTimeFormatter.ofPattern("dd MMM, yyyy");
    startDate = LocalDate.of(2007, 6, 28);
    endDate = LocalDate.of(2007, 8, 20);
    minDate = LocalDate.of(1980, 3, 17);
    maxDate = LocalDate.of(2018, 8, 24);

    // Start date dropdown initialisation
    startDateMenu = new ArrayList();
    subtractYearStart = new Button(700, 40, 150, 30, "-Year", whiteColor, oceanBlueColor, dateFont, 101);
    subtractMonthStart = new Button(700, 70, 150, 30, "-Month", whiteColor, oceanBlueColor, dateFont, 102);
    subtractDayStart = new Button(700, 100, 150, 30, "-Day", whiteColor, oceanBlueColor, dateFont, 103);
    addDayStart = new Button(700, 130, 150, 30, "+Day", whiteColor, oceanBlueColor, dateFont, 104);
    addMonthStart = new Button(700, 160, 150, 30, "+Month", whiteColor, oceanBlueColor, dateFont, 105);
    addYearStart = new Button(700, 190, 150, 30, "+Year", whiteColor, oceanBlueColor, dateFont, 106);
    startDateMenu.add(subtractYearStart);
    startDateMenu.add(subtractMonthStart);
    startDateMenu.add(subtractDayStart);
    startDateMenu.add(addDayStart);
    startDateMenu.add(addMonthStart);
    startDateMenu.add(addYearStart);

    //End date dropdown initialisation
    endDateMenu = new ArrayList();
    subtractYearEnd = new Button(950, 40, 150, 30, "-Year", whiteColor, oceanBlueColor, dateFont, 101);
    subtractMonthEnd = new Button(950, 70, 150, 30, "-Month", whiteColor, oceanBlueColor, dateFont, 102);
    subtractDayEnd = new Button(950, 100, 150, 30, "-Day", whiteColor, oceanBlueColor, dateFont, 103);
    addDayEnd = new Button(950, 130, 150, 30, "+Day", whiteColor, oceanBlueColor, dateFont, 104);
    addMonthEnd = new Button(950, 160, 150, 30, "+Month", whiteColor, oceanBlueColor, dateFont, 105);
    addYearEnd = new Button(950, 190, 150, 30, "+Year", whiteColor, oceanBlueColor, dateFont, 106);
    endDateMenu.add(subtractYearEnd);
    endDateMenu.add(subtractMonthEnd);
    endDateMenu.add(subtractDayEnd);
    endDateMenu.add(addDayEnd);
    endDateMenu.add(addMonthEnd);
    endDateMenu.add(addYearEnd);

    // Dropdown button initialisation
    checkList = new ArrayList();
    startDropDown = new Dropdown(700, 10, 30, 30, startDateMenu, 1, oceanBlueColor, whiteColor);
    endDropDown = new Dropdown(950, 10, 30, 30, endDateMenu, 2, oceanBlueColor, whiteColor);
    checkList.add(startDropDown);
    checkList.add(endDropDown);
  }

  void draw() {
    textFont(dateFont);
    fill(whiteColor);
    text("Start date: " + startDate.format(dayMonthYear), startDropDown.x+40, 32);
    text("End date: " + endDate.format(dayMonthYear), endDropDown.x+40, 32);
  }

  void upDate() {
    //David O. - Handles the drop-down menus for changing the dates    
    Dropdown aDrop;
    for (int i = 0; i < checkList.size(); i++) {
      aDrop = (Dropdown) checkList.get(i);
      aDrop.getEvent(mouseX, mouseY);
    }
    if (currentDropdown == 1) {
      aDrop = (Dropdown) checkList.get(0);
      startDate = aDrop.getMenuEvents(startDate);
      validateDate();
    } else if (currentDropdown == 2) {
      aDrop = (Dropdown) checkList.get(1);
      endDate = aDrop.getMenuEvents(endDate);
      validateDate();
    }
  }
  //David O. - Makes sure the dates are displayed logically and properly
  void validateDate()
  {
    //Checks that the dates are within the bounds of the data
    if (startDate.compareTo(minDate) < 0) {
      startDate = minDate;
    }
    if (endDate.compareTo(minDate) < 0) {
      endDate = minDate;
    }
    if (endDate.compareTo(maxDate) > 0) {
      endDate = maxDate;
    }

    //Checks that the start date is earlier than the end date
    if (startDate.compareTo(endDate) > 0) {
      startDate = endDate;
    }
  }
}
