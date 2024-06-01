package ui;

import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.FlxBasic;
import util.Constants;
import TweenClass;

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

		watermarkText = new FlxText(x, y, FlxG.width, '${Constants.VERSION_MAIN} | ${Constants.VERSION_PSYCH}', fontSize);
		watermarkText.setFormat(Paths.font('phantommuff.ttf'), fontSize, 0xFFFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		watermarkText.antialiasing = ClientPrefs.globalAntialiasing;
		watermarkText.borderSize = 1.3;
		watermarkText.alpha = 0.5;
		add(watermarkText);

		#if (!debug)
		visible = ((!ClientPrefs.noWatermark) ? !ClientPrefs.hideHud : false);
		#end
	}

	public function playWatermarkAnimation(?durationMultiplier:Float = 0.95):Void {
		watermarkText.alpha = 0.0;
		TweenClass.tween(watermarkText, {alpha: 0.5}, 1.0 * durationMultiplier, {ease: FlxEase.sineInOut});
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
