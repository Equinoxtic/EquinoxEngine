package play.hud.game.rating;

import flixel.tweens.FlxEase.FlxEaseUtil;
import flixel.FlxSprite;
import flixel.FlxCamera;
import tweens.GlobalTweenClass;

class NumericalComboSprite extends FlxSprite implements IRatingGraphic
{
	public function new(indexes:Int, ?isPixel:Bool)
	{
		super();

		loadNumericalIndexes(indexes, isPixel, PlayState.instance.camHUD);
		screenCenter();
		visible = (!ClientPrefs.hideHud && PlayState.instance.showComboNum);
		antialiasing = (ClientPrefs.globalAntialiasing && !isPixel);
		updateHitbox();
	}

	/**
	 * Loads the current rating's image/graphic.
	 */
	public function load(key:String, ?isPixel:Bool, ?camera:Null<FlxCamera>):Void
	{
		return;
	}

	 /**
	  * Loads rating images/graphics in numerical indexes.
	  */
	public function loadNumericalIndexes(indexes:Int, ?isPixel:Bool, ?camera:Null<FlxCamera>):Void
	{
		var k:String = 'num${Std.int(indexes)}';
		if (isPixel)
			k = FunkinUtil.pixelSuffix('num${Std.int(indexes)}');

		loadGraphic(Paths.image(Std.string(k)));
		
		if (camera != null)
			cameras = [camera];
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
		velocity.y -= FlxG.random.int(140, 160) * rate;
		velocity.x = FlxG.random.float(-5, 5) * rate;
	}
 
	 /**
	  * Sets the scale/graphic size of the rating graphic.
	  */
	public function scaleSprite(?isPixel:Bool, ?pixelZoom:Float):Void
	{
		if (!isPixel)
			setGraphicSize(Std.int(width * Constants.NUMERICAL_COMBO_SIZE));
		else
			setGraphicSize(Std.int(width * pixelZoom - Constants.NUMERICAL_COMBO_SIZE));
	}
 
	 /**
	  * Plays the fading animation of the graphic, and destroys it.
	  */
	public function fadeAnimation(?rate:Float):Void
	{
		GlobalTweenClass.tween(this, { alpha: 0 }, Constants.NUMERICAL_SCORE_DURATION / rate, {
			ease: FlxEaseUtil.getFlxEaseByString("cubeOut"),
			startDelay: Constants.NUMERICAL_SCORE_DELAY / rate,
			onComplete: function(_) {
				destroy();
			}
		});
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
