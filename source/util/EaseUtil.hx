package util;

import flixel.tweens.FlxEase;

using StringTools;

class EaseUtil
{
	public static function getEase(ease:Null<String>):Null<Float->Float>
	{
		if (ease == null || ease == '') return FlxEase.linear;

		switch (ease)
		{
			// LINEAR (DEFAULT)
			case 'linear': return FlxEase.linear;

			// SINE FUNCTIONS
			case 'sineIn': return FlxEase.sineIn;
			case 'sineOut': return FlxEase.sineOut;
			case 'sineInOut': return FlxEase.sineInOut;

			// QUAD FUNCTIONS
			case 'quadIn': return FlxEase.quadIn;
			case 'quadOut': return FlxEase.quadOut;
			case 'quadInOut': return FlxEase.quadInOut;

			// QUART FUNCTIONS
			case 'quartIn': return FlxEase.quartIn;
			case 'quartOut': return FlxEase.quartOut;
			case 'quartInOut': return FlxEase.quartInOut;

			// QUINT FUNCTIONS
			case 'quintIn': return FlxEase.quintIn;
			case 'quintOut': return FlxEase.quintOut;
			case 'quintInOut': return FlxEase.quintInOut;

			// CUBE / CUBIC FUNCTIONS
			case 'cubeIn': return FlxEase.cubeIn;
			case 'cubeOut': return FlxEase.cubeOut;
			case 'cubeInOut': return FlxEase.cubeInOut;

			// EXPO / EXPONENTIAL FUNCTIONS
			case 'expoIn': return FlxEase.expoIn;
			case 'expoOut': return FlxEase.expoOut;
			case 'expoInOut': return FlxEase.expoInOut;
			
			default: return FlxEase.linear;
		}
		
		return FlxEase.linear;
	}
}
