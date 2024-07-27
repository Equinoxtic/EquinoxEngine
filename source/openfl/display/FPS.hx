package openfl.display;

import flixel.FlxSprite;
import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.math.FlxMath;
#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
#if flash
import openfl.Lib;
#end

#if openfl
import openfl.system.System;
#end

import funkin.Preferences;

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class FPS extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat(Assets.getFont('assets/fonts/comfortaabold.ttf').fontName, 14, color);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";

		cacheCount = 0;
		currentTime = 0;
		times = [];

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end
	}

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000) {
			times.shift();
		}

		var _framerate:Int = Preferences.getPlayerPreference('framerateAmount', 60);

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);
		if (currentFPS > _framerate) {
			currentFPS = _framerate;
		}

		if (currentCount != cacheCount /*&& visible*/)
		{
			text = "FPS: " + currentFPS;

			var gameMemory:Float = 0;
			var memoryPeak:Float = 0;

			#if openfl
			gameMemory = Math.round(System.totalMemory / 1024 / 1024 * 100) / 100;
			if (gameMemory > memoryPeak) memoryPeak = gameMemory;
			text += "\nMemory: " + gameMemory + "MB / " + memoryPeak + "MB";
			#end

			textColor = 0xFFFFFFFF;
			if (gameMemory > 2000 || currentFPS <= _framerate / 2) {
				textColor = 0xE67E3E;
			} else if (gameMemory > 3000 || currentFPS <= _framerate / 4) {
				textColor = 0xBF3434;
			}

			#if (gl_stats && !disable_cffi && (!html5 || !canvas))
			text += "\ntotalDC: " + Context3DStats.totalDrawCalls();
			text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
			text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
			#end

			text += "\n";
		}

		cacheCount = currentCount;
	}
}
