package funkin.ui.debug;

import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.FlxBasic;
import funkin.util.Constants;
import funkin.tweens.GlobalTweenClass;

using StringTools;

class Watermark extends FlxSpriteGroup
{
	private var instance:FlxBasic;

	private var watermarkText:FlxText;

	public function new(?instance:FlxBasic, ?x:Float = 0.0, ?y:Float = 0.0, ?initialSize:Float = 1.0, ?fontSize:Int = 10)
	{
		super();

		if (instance == null) {
			instance = this;
		}

		this.instance = instance;

		watermarkText = new FlxText(x, y, FlxG.width, '${Variables.getGroupedVersionString()}', fontSize);
		watermarkText.setFormat(Paths.font('phantommuff.ttf'), fontSize, 0xFFFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		watermarkText.antialiasing = Preferences.globalAntialiasing;
		watermarkText.borderSize = 1.3;
		watermarkText.alpha = 0.5;
		add(watermarkText);

		#if (!debug)
		visible = ((!Preferences.noWatermark) ? !Preferences.hideHud : false);
		#end
	}

	public function playWatermarkAnimation(?durationMultiplier:Float = 0.95):Void
	{
		watermarkText.alpha = 0.0;
		GlobalTweenClass.tween(watermarkText, {alpha: 0.5}, 1.0 * durationMultiplier, {ease: FlxEase.sineInOut});
	}
}
