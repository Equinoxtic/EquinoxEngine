package;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.tweens.misc.VarTween;
import flixel.tweens.FlxTween.FlxTweenManager;
import flixel.tweens.FlxTween.TweenOptions;

class TweenClass
{
	public static var globalManager:FlxTweenManager = new FlxTweenManager();

	public static function getFlxEaseFromString(?easeString:String = 'linear') {
		if (easeString != null) {
			switch(easeString) {
				case 'linear': return FlxEase.linear;
				case 'elasticIn': return FlxEase.elasticIn;
				case 'elasticOut': return FlxEase.elasticOut;
				case 'elasticInOut': return FlxEase.elasticInOut;
				case 'sineIn': return FlxEase.sineIn;
				case 'sineOut': return FlxEase.sineOut;
				case 'sineInOut': return FlxEase.sineInOut;
				case 'cubeIn': return FlxEase.cubeIn;
				case 'cubeOut': return FlxEase.cubeOut;
				case 'cubeInOut': return FlxEase.cubeInOut;
				case 'circIn': return FlxEase.circIn;
				case 'circOut': return FlxEase.circOut;
				case 'circInOut': return FlxEase.circInOut;
				case 'expoIn': return FlxEase.expoIn;
				case 'expoOut': return FlxEase.expoOut;
				case 'expoInOut': return FlxEase.expoInOut;
				case 'quartIn': return FlxEase.quartIn;
				case 'quartOut': return FlxEase.quartOut;
				case 'quartInOut': return FlxEase.quartInOut;
				case 'quadIn': return FlxEase.quadIn;
				case 'quadOut': return FlxEase.quadOut;
				case 'quadInOut': return FlxEase.quadInOut;
				case 'backIn': return FlxEase.backIn;
				case 'backOut': return FlxEase.backOut;
				case 'backInOut': return FlxEase.backInOut;
				case 'bounceIn': return FlxEase.bounceIn;
				case 'bounceOut': return FlxEase.bounceOut;
				case 'bounceInOut': return FlxEase.bounceInOut;
				case 'quintIn': return FlxEase.quintIn;
				case 'quintOut': return FlxEase.quintOut;
				case 'quintInOut': return FlxEase.quintInOut;
			}
		}
		return FlxEase.linear;
	}

	public static function tween(Object:Dynamic, Values:Dynamic, Duration:Float = 1, ?Options:TweenOptions):VarTween {
		return globalManager.tween(Object, Values, Duration, Options);
	}
}
