package ui;

import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.FlxBasic;
// import Random;
import util.Constants;
import TweenClass;

using StringTools;

class Watermark extends FlxSpriteGroup
{
	private var instance:FlxBasic;

	private var watermarkText:FlxText;
	private var watermarkSprite:FlxSprite;

	public function new(?x:Float = 0.0, ?y:Float = 0.0, ?instance:FlxBasic, ?fontSize:Int = 10)
	{
		super();

		if (instance == null) {
			instance = this;
		}

		this.instance = instance;

		watermarkText = new FlxText(x, y, FlxG.width, 'Solarium Engine v${MainMenuState.solariumEngineVersion.trim()} (PE v${MainMenuState.psychEngineVersion.trim()}) - FNF v${MainMenuState.funkinVersion}');
		watermarkText.setFormat(Paths.font('azonix.otf'), fontSize, 0xFFFFFFFF, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		watermarkText.antialiasing = ClientPrefs.globalAntialiasing;
		watermarkText.borderSize = 1.3;
		watermarkText.alpha = 0.5;
		
		watermarkSprite = new FlxSprite(watermarkText.x - 225, watermarkText.y - 250).loadGraphic(Paths.image('watermark-alt'));
		watermarkSprite.antialiasing = ClientPrefs.globalAntialiasing;

		add(watermarkSprite);
		add(watermarkText);

		if (!ClientPrefs.smallerTextDisplay) {
			watermarkText.scale.set(Constants.WATERMARK_SIZE, Constants.WATERMARK_SIZE);
			watermarkSprite.scale.set(Constants.WATERMARK_SPRITE_SIZE, Constants.WATERMARK_SPRITE_SIZE);
		} else {
			watermarkText.scale.set(Constants.WATERMARK_SMALL, Constants.WATERMARK_SMALL);
			watermarkSprite.scale.set(Constants.WATERMARK_SPRITE_SMALL, Constants.WATERMARK_SPRITE_SMALL);
			watermarkText.x -= 95;
		}

		visible = ((!ClientPrefs.noWatermark) ? !ClientPrefs.hideHud : false);
	}

	public function playWatermarkAnimation(?durationMultiplier:Float = 0.95) {
		watermarkText.alpha = 0.0;
		watermarkSprite.alpha = 0.0;
		TweenClass.tween(watermarkText, {alpha: 0.5}, 1.0 * durationMultiplier, {ease: FlxEase.sineInOut});
		TweenClass.tween(watermarkSprite, {y: watermarkText.y - 300}, 1.0 * durationMultiplier, {ease: FlxEase.sineInOut});
		TweenClass.tween(watermarkSprite, {angle: 360}, 1.0 * durationMultiplier, {ease: FlxEase.sineInOut});
		TweenClass.tween(watermarkSprite, {alpha: 1.0}, 1.15 * durationMultiplier, {ease: FlxEase.sineInOut});
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
