package util;

import flixel.tweens.FlxEase;

using StringTools;

class EaseUtil
{
	public static inline function getEase(ease:Null<String>):Null<Float->Float>
	{
		if (ease == null || ease == '') return getFlxEaseId();

		var easeArray:Array<String> = [
			'linear',
			'sineIn', 'sineOut', 'sineInOut',
			'quadIn', 'quadOut', 'quadInOut',
			'quartIn', 'quartOut', 'quartInOut',
			'quintIn', 'quintOut', 'quintInOut',
			'cubeIn', 'cubeOut', 'cubeInOut',
			'expoIn', 'expoOut', 'expoInOut'
		];

		var currentEase:Int = 0;

		for (i in 0...easeArray.length) {
			currentEase++;
			if (ease.trim() == easeArray[currentEase]) break;
		}
		
		return getFlxEaseId(currentEase);
	}

	private static function getFlxEaseId(id:Null<Int> = 1):Null<Float->Float>
	{
		if (id != null && !(id < 0))
		{
			switch (id)
			{
				// LINEAR (DEFAULT)
				case 1: return FlxEase.linear;

				// SINE FUNCTIONS
				case 2: return FlxEase.sineIn;
				case 3: return FlxEase.sineOut;
				case 4: return FlxEase.sineInOut;

				// QUAD FUNCTIONS
				case 5: return FlxEase.quadInOut;
				case 6: return FlxEase.quadInOut;
				case 7: return FlxEase.quadInOut;

				// QUART FUNCTIONS
				case 8: return FlxEase.quartIn;
				case 9: return FlxEase.quartOut;
				case 10: return FlxEase.quartInOut;

				// QUINT FUNCTIONS
				case 11: return FlxEase.quintIn;
				case 12: return FlxEase.quintOut;
				case 13: return FlxEase.quintInOut;

				// CUBE / CUBIC FUNCTIONS
				case 14: return FlxEase.cubeIn;
				case 15: return FlxEase.cubeOut;
				case 16: return FlxEase.cubeInOut;

				// EXPO / EXPONENTIAL FUNCTIONS
				case 17: return FlxEase.expoIn;
				case 18: return FlxEase.expoOut;
				case 19: return FlxEase.expoInOut;
				
				default: return FlxEase.linear;
			}
		}

		return FlxEase.linear;
	}
}
