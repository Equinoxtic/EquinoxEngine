package funkin.util.misc;

#if (desktop)
import lime.app.Application;
#end

class WindowUtil
{
	#if (desktop)
	private static var _fullscreenToggled:Bool = false;

	public static function moveWindow(x:Float, y:Float):Void
	{
		setWindowX(Std.int(x)); setWindowY(Std.int(y));
	}

	public static function setWindowX(x:Int):Void
	{
		if (Math.isNaN(x)) {
			x = 0;
		}

		Application.current.window.x = x;
	}

	public static function setWindowY(y:Int):Void
	{
		if (Math.isNaN(y)) {
			y = 0;
		}

		Application.current.window.y = y;
	}

	public static function setWindowSize(h:Float, w:Float):Void
	{
		setWindowHeight(Std.int(h)); setWindowWidth(Std.int(w));
	}

	public static function setWindowHeight(h:Int):Void
	{
		if (h >= Variables.MAX_WINDOW_HEIGHT || Math.isNaN(h)) {
			h = Variables.MAX_WINDOW_HEIGHT;
		}

		Application.current.window.height = h;
	}

	public static function setWindowWidth(w:Int):Void
	{
		if (w >= Variables.MAX_WINDOW_WIDTH || Math.isNaN(w)) {
			w = Variables.MAX_WINDOW_WIDTH;
		}

		Application.current.window.width = w;
	}

	public static function toggleFullscreen():Void
	{
		Application.current.window.fullscreen = !_fullscreenToggled;
	}
	#end
}
