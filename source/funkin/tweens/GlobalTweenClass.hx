package funkin.tweens;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.tweens.misc.ColorTween;
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

	public static function color(Sprite:FlxSprite, Duration:Float = 1.0, FromColor:FlxColor = 0xFFFFFFFF, ToColor:FlxColor = 0xFFFFFFFF, ?Options:TweenOptions):ColorTween
	{
		return globalManager.color(Sprite, Duration, FromColor, ToColor, Options);
	}
}
