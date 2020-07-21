import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

/*
  Author: Cian O'Gorman
 Button class for creating and handling graphicbuttons within the application
 */

class GraphicButton { 
  
  // Size and location values of the button
  int x;
  int y;
  int width;
  int height;
  
  // Event of the button which is output when pressed
  int event;
  
  // Text label to be displayed on the button
  String label;
  
  // Color used for the button
  color buttonColor;
  color labelColor;
  
  // Font used for the button
  PFont buttonFont;
  
  // PGrahics object used for the button
  PGraphics pg;


  // Constructor for a graphicButton with a given PGraphics object
  GraphicButton(int x, int y, int width, int height, String label, color buttonColor, color labelColor, PFont buttonFont, int event, PGraphics pg) { 
    this.x=x;
    this.y=y;
    this.width = width;
    this.height= height;
    this.label = label;
    this.event = event;
    this.buttonColor = buttonColor;
    this.buttonFont = buttonFont;
    this.labelColor = labelColor;
    this.pg = pg;
  }

  // Constructor for a graphicButton without a given PGraphics object
  GraphicButton(int x, int y, int width, int height, color buttonColor, color labelColor, int event) { 
    this.x=x;
    this.y=y;
    this.width = width;
    this.height= height;
    this.event = event;
    this.buttonColor = buttonColor;
    this.labelColor = labelColor;
  }

  // Setting the PGraphics
  void setPG(PGraphics pg)
  {
    this.pg = pg;
  }

  void draw(int yScroll, int spawnOffset, int containerX, int containerY) { 
    
    // Changing the color of the buttons border if the mouse hovers over it
    if (hover(mouseX, mouseY, containerX, containerY, spawnOffset, yScroll)) {
      pg.stroke(lightBlueColor);
    } else {
      pg.noStroke();
    }
    
    // Setting the font and color of the button
    pg.textFont(buttonFont);
    pg.fill(buttonColor);

    // Drawing the button to the screen
    pg.beginDraw();
    pg.rect(x, y + yScroll + spawnOffset, width, height, 2);
    pg.fill(labelColor);
    pg.text(label, x + 10, y + spawnOffset + (height / 2) - 9 + yScroll);
    pg.endDraw();
  } 

  // Returning if the mouse is hovering over the button
  boolean hover(int mX, int mY, int containerX, int containerY, int spawnOffset, float yScroll) {
    if ((mX > x + containerX) && (mX < x + containerX + width) && (mY > y + containerY + spawnOffset + yScroll) && (mY < y + containerY + spawnOffset + height + yScroll)) {
      return true;
    } else return false;
  }

  // Returns the buttons event if pressed, else returns EVENT_NULL
  int getEvent(int mX, int mY, int containerX, int containerY, int spawnOffset, float yScroll) {
    if (this.hover(mX, mY, containerX, containerY, spawnOffset, yScroll)) { 
      println("returning event");
      return this.event;
    } else return EVENT_NULL;
  }
}
