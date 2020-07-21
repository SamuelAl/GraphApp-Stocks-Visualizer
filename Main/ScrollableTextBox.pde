/**
 * Class to display a scrollable textbox with custom text.
 * 
 * @author Samuel Alarco Cantos
 * @version 1.0
 * @since 2020-03-11
 */

class ScrollableTextBox extends Drawable
{
  private String text;
  private int xPos, yPos, width, height;
  private PGraphics container = new PGraphics();
  private int margin = 5;
  private float scroll = 0;
  private color bgColor = color(255);
  private color textColor = color(0);
  private PFont textFont = createFont("Arial", 20);
  private boolean scrollEnabled = true;
  
  
  ScrollableTextBox(int xPos, int yPos, int width, int height, String text)
  {
    this.xPos = xPos;
    this.yPos = yPos;
    this.width = width;
    this.height = height;
    this.text = text;
    container = createGraphics(width, height);
  }
  
  /*
   * Updates scroll offset inside container
   * @param  change  float scroll offset
   */
  void changeScrollOffset(float change)
  {
    if (scrollEnabled)
    {
      scroll += change;
    }
    
  }
  
  /*
   * Displays text inside textbox
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
      container.text(text, margin, margin - scroll, container.width - margin, container.height + scroll);
    }
    container.endDraw();
    
    image(container, xPos, yPos);
  }
  
  /*
   * Sets text to be displayed by textbox
   * @param  scrollEnable  Boolean true if scroll is enabled for textbox; false if scrolling is disabled
   */
  void enableScroll(boolean scrollEnable)
  {
    this.scrollEnabled = scrollEnable;
  }
  
  /*
   * Sets text to be displayed by textbox
   * @param  text  String text to be displayed by textbox
   */
  void setText(String text)
  {
    if (text != null)
    {
      this.text = text;
    }
    
  }
  
  /*
   * Sets PGraphics object to display content of textbox
   * @param  pg  PGraphics object inside of which to render text
   */
  void setPG(PGraphics pg)
  {
    this.container = pg;
  }
  
  
}
