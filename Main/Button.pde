import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

/*
Button class for creating and handling buttons within the application
 
 - code adapted by David Ayomide Olowookere from Widget class given by Gavin Doherty
 - v3.0: Fully functional Dropdown class
 */

class Button { 
  int x, y, width, height;
  String label;
  int event;
  color buttonColor, labelColor;
  PFont buttonFont;
  Button(int x, int y, int width, int height, String label, color buttonColor, color labelColor, PFont buttonFont, int event) { 
    this.x=x;
    this.y=y;
    this.width = width;
    this.height= height;
    this.label = label;
    this.event = event;
    this.buttonColor = buttonColor;
    this.buttonFont = buttonFont;
    this.labelColor = labelColor;
  }
  Button(int x, int y, int width, int height, color buttonColor, color labelColor, int event) { 
    this.x=x;
    this.y=y;
    this.width = width;
    this.height= height;
    this.event = event;
    this.buttonColor = buttonColor;
    this.labelColor = labelColor;
  }

  void draw() { 
    if (hover(mouseX, mouseY)) stroke(labelColor);
    else noStroke();
    fill(buttonColor);
    rect(x, y, width, height);
    fill(labelColor);
    textFont(buttonFont);
    text(label, x + 10, y + (height / 2) + 8);
  } 

  //David O. - Checks whether the mouse is within the bounds of the button
  boolean hover(int mX, int mY) {
    return (mX > x && mX < x + width && mY > y && mY < y + height);
  }

  //David O. - Simple method for returning the event of the button when clicked
  int getEvent(int mX, int mY) { 
    if (hover(mX, mY)) { 
      return event;
    } 
    return EVENT_NULL;
  }
}

class Checkbox extends Button {
  boolean selected;
  int offset;

  Checkbox(int x, int y, int width, int height, String label, int offset, color buttonColor, color labelColor, PFont buttonFont, int event) {
    super(x, y, width, height, label, buttonColor, labelColor, buttonFont, event);
    labelColor= color(255);
    selected = false;
    this.offset = offset;
  }

  void draw() {
    if (hover(mouseX, mouseY)) stroke(lightGreyColor);
    else stroke(0);
    if (selected) {
      fill(buttonColor);
      rect(x, y, width, height);
      fill(labelColor);
      textFont(buttonFont);
      text(label, x-offset, y+(height));
    } else {
      fill(labelColor);
      rect(x, y, width, height);
      textFont(buttonFont);
      text(label, x-offset, y+(height));
    }
  }

  //David O. - Inverts the status of the checkbox when clicked
  int getEvent(int mX, int mY) {
    if (hover(mX, mY)) {
      selected = !selected;
      return event;
    }
    return EVENT_NULL;
  }

  void unCheck()
  {
    selected = false;
  }
}

class Dropdown extends Button {
  int menuNumber;
  ArrayList menu;
  color chosenColor, emptyColor;

  Dropdown(int x, int y, int width, int height, ArrayList menu, int event, color buttonColor, color labelColor) {
    super(x, y, width, height, buttonColor, labelColor, event);
    labelColor= color(255);
    this.menu = menu;
    menuNumber = event;
    chosenColor = buttonColor;
    emptyColor = labelColor;
  }

  void draw() {
    if (hover(mouseX, mouseY)) stroke(labelColor);
    else stroke(0);
    if (currentDropdown == menuNumber) {
      fill(chosenColor);

      int ySpawn = y + height;
      for (int i = 0; i < menu.size(); i++) {
        Button date = (Button) menu.get(i);
        date.x = x;                                  //
        date.y = ySpawn;                             //David O. - Dynamically drawing the dropdown menu according to the position of the dropdown spawner (07/04/2020)
        ySpawn += date.height;                       //

        date.draw();
      }
      noStroke();
    } else {
      fill(emptyColor);
    }
    rect(x, y, width, height);
    fill(255);
  }

  int getEvent(int mX, int mY) {
    if (hover(mX, mY)) {
      if (currentDropdown == menuNumber) currentDropdown = EVENT_NULL;
      else currentDropdown = menuNumber;
      return event;
    }
    if (currentDropdown == menuNumber && !menuHover(mouseX, mouseY)) currentDropdown = EVENT_NULL;
    return EVENT_NULL;
  }

  //David O. - Checks whether the mouse is over the dropdown menu or not 
  boolean menuHover(int mX, int mY) {
    int menuTopX = x;
    int menuTopY = y+height;

    Button aButton = (Button) menu.get(0);
    int menuWidth = aButton.width;
    int menuHeight = aButton.height;

    for (int i = 1; i < menu.size(); i++) {
      aButton = (Button) menu.get(i);
      menuHeight += aButton.height;
    }

    return (mX > menuTopX && mX < menuTopX + menuWidth && mY > menuTopY && mY < menuTopY + menuHeight);
  }

  //David O. - Removed Unresolved References from earlier version of the class
  //Function checks if any of the date buttons are clicked, and updates the date accordingly
  LocalDate getMenuEvents(LocalDate date) {
    for (int i = 0; i < menu.size(); i++) {
      Button aButton = (Button) menu.get(i);
      event = aButton.getEvent(mouseX, mouseY);
      switch (event) {
      case 101:
        date = date.minusYears(1);                               
        break;
      case 102:
        date = date.minusMonths(1);                             
        break;
      case 103:
        date = date.minusDays(1);                             
        break;
      case 104:
        date = date.plusDays(1);                               
        break;
      case 105:
        date = date.plusMonths(1);                             
        break;
      case 106:
        date = date.plusYears(1);
        break;
      default:
        break;
      }
    }
    return date;
  }

  //David O. - General method for returning the dropdown button clicked
  int getMenuEvents() {
    int event = EVENT_NULL; 
    for (int i = 0; i < menu.size(); i++) {
      Button aButton = (Button) menu.get(i);
      event = aButton.getEvent(mouseX, mouseY);
      if (event != EVENT_NULL) return event;
    }
    return EVENT_NULL;
  }
}
