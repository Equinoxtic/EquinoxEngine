package ui.game.rating;

import flixel.tweens.FlxEase.FlxEaseUtil;
import flixel.FlxCamera;
import flixel.FlxSprite;

class RatingSprite extends FlxSprite implements IRatingGraphic
{
	public function new(?rating:Rating, isPixel:Bool = false):Void
	{
		super();

		load(rating.image, isPixel, PlayState.instance.camHUD);
		screenCenter();
		visible = (!ClientPrefs.hideHud && PlayState.instance.showRating);
		antialiasing = (ClientPrefs.globalAntialiasing && !isPixel);
	}

	public function load(key:String, ?isPixel:Bool, ?camera:Null<FlxCamera>):Void
	{
		var k:String = '${key}';
		if (isPixel)
			k = CoolUtil.pixelSuffix('${key}');

		loadGraphic(Paths.image(Std.string(k)));

		if (camera != null)
			cameras = [camera];
	}

	public function loadNumericalIndexes(indexes:Int, ?isPixel:Bool, ?camera:Null<FlxCamera>):Void
	{
		return;
	}

	public function accelerateSprite(?rate:Float):Void
	{
		acceleration.y = 550 * (rate);
	}

	public function velocitateSprite(?rate:Float):Void
	{
		velocity.x -= FlxG.random.int(0, 10) * rate;
		velocity.y -= FlxG.random.int(140, 175) * rate;
	}

	public function scaleSprite(?isPixel:Bool, ?pixelZoom:Float):Void
	{
		if (!isPixel)
			setGraphicSize(Std.int(width * Constants.RATING_SPRITE_SIZE));
		else
			setGraphicSize(Std.int(width * pixelZoom * Constants.RATING_SPRITE_SIZE));
		updateHitbox();
	}

	public function fadeAnimation(?rate:Float):Void
	{
		TweenClass.tween(this, { alpha: 0 }, Constants.RATING_SPRITE_DURATION / rate, {
			startDelay: Constants.RATING_SPRITE_DELAY / rate,
			ease: FlxEaseUtil.getFlxEaseByString("cubeOut"),
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
