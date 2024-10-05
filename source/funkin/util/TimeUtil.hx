package funkin.util;

import flixel.util.FlxStringUtil;

class TimeUtil
{
	public static function getTicks(previousFrameTime:Null<Int>):Float
	{
		if (previousFrameTime == null) {
			return 0;
		}
		return FlxG.game.ticks - previousFrameTime;
	}

	public static function adjustSongTime(time:Float):Float
	{
		return (time + Conductor.songPosition) / 2;
	}

	public static function adjustConductorTime():Float
	{
		return Conductor.songPosition - GlobalSettings.NOTE_OFFSET;
	}

	public static function getSongTime(time:Float):String
	{
		return FlxStringUtil.formatTime(_calculateTime(time), false);
	}

	private static function _calculateTime(time:Float):Int
	{
		var m_time:Int = Math.floor(time / 1000);
		if (m_time < 0) {
			m_time = 0;
		}
		return m_time;
	}
}
