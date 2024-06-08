package funkin.play.hud.game.rating;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase.FlxEaseUtil;
import funkin.tweens.GlobalTweenClass;
import funkin.play.scoring.Rating;
import flixel.FlxSprite;
import flixel.FlxCamera;

class RatingGraphic extends FlxSprite
{
	/**
	 * The rate for the velocity, acceleration, and tweens for the rating sprite/graphic.
	 */
	public var rate:Float = 1.0;

	/**
	 * Loads the current rating's image/graphic.
	 */
	public function new(key:String, ?isPixelStage:Bool = false):Void
	{
		super(0, 0);

		loadRatingSprite(key, isPixelStage);

		cameras = [ PlayState.instance.camHUD ];

		antialiasing = (Preferences.globalAntialiasing && !isPixelStage);
		visible = !Preferences.hideHud;
	}

	/**
	 * Loads the images/graphics for the rating sprite.
	 * @param ratingImage 
	 * @param isPixel = false 
	 */
	private function loadRatingSprite(ratingImage:Null<String>, ?isPixel = false):Void
	{
		if (ratingImage == null || ratingImage == '') return;
		var k:String = ratingImage;
		if (isPixel)
			k = FunkinUtil.pixelSuffix(ratingImage);
		loadGraphic(Paths.image(k));
	}
	/**
	 * Sets the scale/graphic size of the rating graphic.
	 */
	public function scaleSprite(size:Null<Float>, ?isPixel:Bool = false, ?pixelZoom:Float = 6):Void
	{
		if (!isPixel)
			setGraphicSize(Std.int(width * size));
		else
			setGraphicSize(Std.int(width * pixelZoom * size));
		updateHitbox();
	}

	/**
	 * Plays the fading animation of the graphic, and destroys it.
	 */
	public function fadeAnimation(duration:Null<Float>, delay:Null<Float>):Void
	{
		GlobalTweenClass.tween(this, { alpha: 0 }, duration / rate, {
			startDelay: delay / rate,
			ease: FlxEaseUtil.getFlxEaseByString("cubeOut"),
			onComplete: function(_:FlxTween) {
				destroy();
			}
		});
	}
}
