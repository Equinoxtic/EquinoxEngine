package ui.game.rating;

import flixel.FlxCamera;
import flixel.tweens.FlxEase.FlxEaseUtil;
import flixel.FlxSprite;

class ComboSprite extends FlxSprite implements IRatingGraphic
{
	public function new(?isPixel:Bool = false):Void
	{
		super();
		
		load('combo', PlayState.instance.camHUD);
		screenCenter();
		visible = (!ClientPrefs.hideHud && PlayState.instance.showCombo);
		antialiasing = (ClientPrefs.globalAntialiasing && !isPixel);
		updateHitbox();
	}

	/**
	 * Loads the current rating's image/graphic.
	 */
	public function load(key:String, ?isPixel:Bool, ?camera:Null<FlxCamera>):Void
	{
		var k:String = '${key}';
		if (isPixel)
			k = CoolUtil.pixelSuffix('${key}');

		loadGraphic(Paths.image(Std.string(k)));
		
		if (camera != null)
			cameras = [camera];
	}

	/**
	 * Loads rating images/graphics in numerical indexes.
	 */
	public function loadNumericalIndexes(indexes:Int, ?isPixel:Bool, ?camera:Null<FlxCamera>):Void
	{
		return;
	}

	/**
	 * Sets the acceleration of the rating graphic.
	 */
	public function accelerateSprite(?rate:Float):Void
	{
		acceleration.y = FlxG.random.int(200, 300) * (rate);
	}

	/**
	 * Sets the velocity of the rating graphic.
	 */
	public function velocitateSprite(?rate:Float):Void
	{
		velocity.x += FlxG.random.int(1, 10) * rate;
		velocity.y -= FlxG.random.int(140, 160) * rate;
	}

	/**
	 * Sets the scale/graphic size of the rating graphic.
	 */
	public function scaleSprite(?isPixel:Bool, ?pixelZoom:Float):Void
	{
		if (!isPixel)
			setGraphicSize(Std.int(width * Constants.COMBO_SPRITE_SIZE));
		else
			setGraphicSize(Std.int(width * pixelZoom * Constants.COMBO_SPRITE_SIZE));
	}

	/**
	 * Plays the fading animation of the graphic, and destroys it.
	 */
	public function fadeAnimation(?rate:Float):Void
	{
		TweenClass.tween(this, { alpha: 0 }, Constants.COMBO_SPRITE_DURATION / rate, {
			startDelay: Constants.COMBO_SPRITE_DELAY / rate,
			ease: FlxEaseUtil.getFlxEaseByString("cubeOut"),	
			onComplete: function(_) {
				destroy();
			}
		});
	}
}
