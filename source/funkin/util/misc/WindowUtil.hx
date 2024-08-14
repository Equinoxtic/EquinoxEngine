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
		Application.current.window.x = Std.int(x); Application.current.window.y = Std.int(y);
		#else _traceUnsupportedMessage() #end
	}

	public static function setWindowSize(h:Float, w:Float):Void
	{
		#if (desktop)
		Application.current.window.height = Std.int(h); Application.current.window.width = Std.int(w);
		#else _traceUnsupportedMessage() #end
	}

	public static function toggleFullscreen():Void
	{
		#if (desktop)
		Application.current.window.fullscreen = !_fullscreenToggled;
		#else _traceUnsupportedMessage() #end
	}

	private static function _traceUnsupportedMessage():Void
	{
		trace('Platform not supported!');
	}
}
