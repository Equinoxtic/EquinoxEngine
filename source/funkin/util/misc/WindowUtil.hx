package funkin.util.misc;

#if (desktop)
import lime.app.Application;
#end

class WindowUtil
{
	#if (desktop)
	private static var _fullscreenToggled:Bool = false;

	/**
	 * Sets the window's position based on the x and y position in space relative to the screen.
	 * @param x The x position in space.
	 * @param y The y position in space.
	 */
	public static function setWindowPosition(x:Float, y:Float):Void
	{
		setWindowX(Std.int(x)); setWindowY(Std.int(y));
	}

	/**
	 * Sets the window's position in the x position in space relative to the screen.
	 * @param x The x position in space.
	 */
	public static function setWindowX(x:Int):Void
	{
		if (Math.isNaN(x)) {
			x = 0;
		}

		Application.current.window.x = x;
	}

	/**
	 * Sets the window's position in the y position in space relative to the screen.
	 * @param y The y position y space.
	 */
	public static function setWindowY(y:Int):Void
	{
		if (Math.isNaN(y)) {
			y = 0;
		}

		Application.current.window.y = y;
	}

	/**
	 * Sets the window's height and width.
	 * @param h The height of the window to set.
	 * @param w The width of the window to set.
	 */
	public static function setWindowSize(h:Float, w:Float):Void
	{
		setWindowHeight(Std.int(h)); setWindowWidth(Std.int(w));
	}

	/**
	 * Sets the window's height.
	 * @param h The value of the height.
	 */
	public static function setWindowHeight(h:Int):Void
	{
		if (h >= Variables.MAX_WINDOW_HEIGHT || Math.isNaN(h)) {
			h = Variables.MAX_WINDOW_HEIGHT;
		}

		Application.current.window.height = h;
	}

	/**
	 * Sets the window's width.
	 * @param w The value of the width.
	 */
	public static function setWindowWidth(w:Int):Void
	{
		if (w >= Variables.MAX_WINDOW_WIDTH || Math.isNaN(w)) {
			w = Variables.MAX_WINDOW_WIDTH;
		}

		Application.current.window.width = w;
	}

	/**
	 * Toggles whether or not the window should be fullscreen.
	 */
	public static function toggleFullscreen():Void
	{
		Application.current.window.fullscreen = !_fullscreenToggled;
	}
	#end
}
