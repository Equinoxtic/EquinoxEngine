package funkin.util;

import flixel.tweens.FlxEase;

using StringTools;

/**
 * Custom class by @Equinoxtic (me) :333
 *
 * Utility functions for getting FlxEases through certain methods
 */
class EaseUtil
{
	private static final stringEaseMap:Map<String, Float->Float> = [
		'linear' 				=> FlxEase.linear,
		'elasticIn' 			=> FlxEase.elasticIn,
		'elasticOut' 			=> FlxEase.elasticOut,
		'elasticInOut' 			=> FlxEase.elasticInOut,
		'sineIn' 				=> FlxEase.sineIn,
		'sineOut' 				=> FlxEase.sineOut,
		'sineInOut' 			=> FlxEase.sineInOut,
		'cubeIn' 				=> FlxEase.cubeIn,
		'cubeOut' 				=> FlxEase.cubeOut,
		'cubeInOut'				=> FlxEase.cubeInOut,
		'circIn' 				=> FlxEase.circIn,
		'circOut' 				=> FlxEase.circOut,
		'circInOut' 			=> FlxEase.circInOut,
		'expoIn' 				=> FlxEase.expoIn,
		'expoOut' 				=> FlxEase.expoOut,
		'expoInOut' 			=> FlxEase.expoInOut,
		'quartIn' 				=> FlxEase.quartIn,
		'quartOut' 				=> FlxEase.quartOut,
		'quartInOut' 			=> FlxEase.quartInOut,
		'quadIn' 				=> FlxEase.quadIn,
		'quadOut' 				=> FlxEase.quadOut,
		'quadInOut' 			=> FlxEase.quadInOut,
		'backIn' 				=> FlxEase.backIn,
		'backOut' 				=> FlxEase.backOut,
		'backInOut' 			=> FlxEase.backInOut,
		'bounceIn' 				=> FlxEase.bounceIn,
		'bounceOut' 			=> FlxEase.bounceOut,
		'bounceInOut' 			=> FlxEase.bounceInOut,
		'quintIn' 				=> FlxEase.quintIn,
		'quintOut' 				=> FlxEase.quintOut,
		'quintInOut' 			=> FlxEase.quintInOut,
		'smoothStepIn' 			=> FlxEase.smoothStepIn,
		'smoothStepOut' 		=> FlxEase.smoothStepOut,
		'smoothStepInOut' 		=> FlxEase.smoothStepInOut,
		'smootherStepIn' 		=> FlxEase.smootherStepIn,
		'smootherStepOut' 		=> FlxEase.smootherStepOut,
		'smootherStepInOut' 	=> FlxEase.smootherStepInOut
	];

	public static function getFlxEaseByString(?ease:Null<String> = 'linear'):Null<Float->Float>
	{
		if (ease == null || ease.charAt(0) == '') {
			return FlxEase.linear;
		}

		var currentEase:Float->Float = FlxEase.linear;

		for (easeKey in stringEaseMap.keys()) {
			if (ease.trim() == easeKey && currentEase != null) {
				currentEase = stringEaseMap[easeKey];
				break;
			}
		}

		return currentEase;
	}
}
