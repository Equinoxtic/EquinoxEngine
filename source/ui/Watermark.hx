package ui;

import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.FlxBasic;
// import Random;
import TweenClass;

using StringTools;

class Watermark extends FlxSpriteGroup
{
	private var instance:FlxBasic;

	private var watermarkText:FlxText;
	private var watermarkSprite:FlxSprite;

	public function new(?x:Float = 0.0, ?y:Float = 0.0, ?instance:FlxBasic, ?spriteScaleMult:Float = 0.35)
	{
		super();

		if (instance == null) {
			instance = this;
		}

		this.instance = instance;

		if (spriteScaleMult > 1) {
			spriteScaleMult = 1;
		}

		watermarkText = new FlxText(x, y, FlxG.width, 'Solarium Engine v${MainMenuState.solariumEngineVersion.trim()} (PE v${MainMenuState.psychEngineVersion.trim()}) - FNF v${MainMenuState.funkinVersion}');
		watermarkText.setFormat(Paths.font('azonix.otf'), 11, 0xFFFFFFFF, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		watermarkText.antialiasing = ClientPrefs.globalAntialiasing;
		watermarkText.borderSize = 1.3;
		watermarkText.alpha = 0.5;
		
		watermarkSprite = new FlxSprite(watermarkText.x - 225, watermarkText.y - 250).loadGraphic(Paths.image('watermark-alt'));
		watermarkSprite.setGraphicSize(Std.int(watermarkSprite.width * spriteScaleMult), Std.int(watermarkSprite.height * spriteScaleMult));
		watermarkSprite.antialiasing = ClientPrefs.globalAntialiasing;
		// watermarkSprite.cameras = [spriteCam];
		// watermarkSprite.alpha = 0.5;

		add(watermarkSprite);
		add(watermarkText);
	}

	public function playWatermarkAnimation(?durationMultiplier:Float = 0.95) {
		watermarkText.alpha = 0.0;
		// watermarkSprite.alpha = 0.0;
		// watermarkSprite.y = FlxG.height * 1.2;
		TweenClass.tween(watermarkText, {alpha: 0.5}, 1.0 * durationMultiplier, {ease: FlxEase.quadInOut});
		// TweenClass.tween(watermarkSprite, {alpha: 0.5}, 1.0 * durationMultiplier, {ease: FlxEase.quadInOut});
		TweenClass.tween(watermarkSprite, {y: watermarkText.y - 300}, 1.0 * durationMultiplier, {ease: FlxEase.quartOut});
		TweenClass.tween(watermarkSprite, {angle: 360}, 1.0 * durationMultiplier, {ease: FlxEase.quartOut});
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
