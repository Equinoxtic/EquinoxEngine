package funkin.ui.debug;

import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.FlxBasic;
import funkin.tweens.GlobalTweenClass;

using StringTools;

class Watermark extends FlxSpriteGroup
{
	private var watermarkText:FlxText;

	public function new(?x:Float = 0.0, ?y:Float = 0.0, ?initialSize:Float = 1.0, ?fontSize:Int = 10)
	{
		super();

		watermarkText = new FlxText(x, y, FlxG.width, '${Variables.getGroupedVersionString()}', fontSize);
		watermarkText.setFormat(Paths.font('phantommuff.ttf'), fontSize, 0xFFFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		watermarkText.antialiasing = GlobalSettings.SPRITE_ANTIALIASING;
		watermarkText.borderSize = 1.3;
		watermarkText.alpha = 0.5;
		add(watermarkText);

		#if (!debug)
		visible = ((!GlobalSettings.HIDE_WATERMARK) ? !GlobalSettings.HIDE_HUD : false);
		#end
	}

	public function playWatermarkAnimation(?durationMultiplier:Float = 0.95):Void
	{
		watermarkText.alpha = 0.0;
		GlobalTweenClass.tween(watermarkText, {alpha: 0.5}, 1.0 * durationMultiplier, {ease: FlxEase.sineInOut});
	}
}
