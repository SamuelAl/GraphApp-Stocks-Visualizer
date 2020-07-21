/**
 * General container class to hold different views, and 
 * 
 * @author Samuel Alarco Cantos
 * @version 2.0
 * @since 2020-03-11
 */
 
 // @Keira Gatt : 25/03/2020 : Constructor updated to support Bar Chart view
 // @Samuel Alarco: 22/04/2020 : Added setCurrentObject function.


class ScrollableContainer
{
  private int xPos, yPos, width, height;
  private PGraphics container = new PGraphics();
  private int margin = 5;
  private float scroll = 0;
  private color bgColor = color(255);
  private color textColor = color(0);
  private PFont textFont = createFont("Arial", 20);
  public Drawable currentObject;
  public Drawable table;
  public Drawable lineGraph;
  public Drawable barChart;                                                                                                     // @Keira 25/03/2020 - Bar Chart display object
  
  ScrollableContainer(int xPos, int yPos, int width, int height, Drawable currentObject)
  {
    this.xPos = xPos;
    this.yPos = yPos;
    this.width = width;
    this.height = height;
    this.currentObject = currentObject;
    container = createGraphics(width, height);
    currentObject.setPG(container);
  }
  
  // ScrollableContainer(int xPos, int yPos, int width, int height, Drawable table, Drawable lineGraph)                        // Original Constructor interface
  ScrollableContainer(int xPos, int yPos, int width, int height, Drawable table, Drawable lineGraph, Drawable barChart)        // @Keira 25/03/2020 - Added Bar Chart display object
  {
    this.xPos = xPos;
    this.yPos = yPos;
    this.width = width;
    this.height = height;
    currentObject = table;
    this.table = table;
    this.lineGraph = lineGraph;
    this.barChart = barChart;                                                                                                    // @Keira 25/03/2020
    container = createGraphics(width, height);
    currentObject.setPG(container);
  }
  
  /*
   * Updates scroll offset inside container
   * @param  change  float scroll offset
   */
  void changeScroll(float change)
  {
    scroll += change;
    currentObject.changeScrollOffset(change);
  }
  
  /*
   * Draws current object
   */
  void draw()
  {
    container.beginDraw();
    {
      container.background(bgColor);
      container.fill(bgColor);
      container.rect(0, 0, width, height);
      container.fill(textColor);
      container.textFont(textFont);
      container.textAlign(LEFT, TOP);
      currentObject.setPG(container);
      currentObject.draw();
    }
    container.endDraw();
    
    image(container, xPos, yPos);
  }
  
  /*
   * Sets object to be displayed inside the container
   */
  void setCurrentObject(Drawable object)
  {
    this.currentObject = object;
  }
  
  
}
