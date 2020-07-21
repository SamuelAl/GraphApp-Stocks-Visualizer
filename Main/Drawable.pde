/**
 * Abstract class for scrollable and contained objects.
 * Object contained in the ScrollableContainer class must extend this class
 * 
 * @author Samuel Alarco Cantos
 * @version 1.0
 * @since 2020-03-10
 */

abstract class Drawable
{
  abstract void draw();
  abstract void setPG(PGraphics pg);
  abstract void changeScrollOffset(float change);
}
