package funkin.util.misc;

#if (desktop)
import lime.app.Application;
#end

class WindowUtil
{
	private static var _fullscreenToggled:Bool = false;

	public static function moveWindow(x:Float, y:Float):Void
	{
		#if (desktop)
		// Set limits for x and y position.
		if (Math.isNaN(x))
			x = 0.0;
		if (Math.isNaN(y))
			y = 0.0;
		Application.current.window.x = Std.int(x);
		Application.current.window.y = Std.int(y);
		#else
		_traceUnsupportedMessage();
		#end
	}

	public static function setWindowSize(h:Float, w:Float):Void
	{
		#if (desktop)
		// Set limits for height and width.
		if (h > 5120 || Math.isNaN(h)) {
			h = 1920;
		}

		if (w > 1990 || Math.isNaN(w)) {
			w = 1080;
		}

		Application.current.window.height = Std.int(h);
		Application.current.window.width = Std.int(w);
		#else
		_traceUnsupportedMessage();
		#end
	}

	public static function toggleFullscreen():Void
	{
		#if (desktop)
		Application.current.window.fullscreen = !_fullscreenToggled;
		#else
		_traceUnsupportedMessage();
		#end
	}

	private static function _traceUnsupportedMessage():Void
	{
		trace('Platform not supported!');
	}
}
