package funkin.tweens;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.tweens.misc.VarTween;
import flixel.tweens.FlxTween.FlxTweenManager;
import flixel.tweens.FlxTween.TweenOptions;

class GlobalTweenClass
{
	public static var globalManager:FlxTweenManager = new FlxTweenManager();

	public static function tween(Object:Dynamic, Values:Dynamic, Duration:Float = 1, ?Options:TweenOptions):VarTween
	{
		return globalManager.tween(Object, Values, Duration, Options);
	}
}
