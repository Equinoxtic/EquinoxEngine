package funkin.play.hud.game.rating;

import flixel.tweens.FlxEase.FlxEaseUtil;
import flixel.FlxCamera;
import flixel.FlxSprite;
import funkin.tweens.GlobalTweenClass;
import funkin.play.scoring.*;

class RatingSprite extends RatingGraphic
{
	public function new(rating:Rating):Void
	{
		if (rating == null)
			rating.image = "sick";

		super(rating.image, PlayState.isPixelStage);

		scaleSprite(Constants.RATING_SPRITE_SIZE, PlayState.isPixelStage);
		screenCenter();
		scrollFactor.set();

		acceleration.y = 550 * Math.pow(rate, 2);
		velocity.x -= FlxG.random.int(0, 10) * rate;
		velocity.y -= FlxG.random.int(140, 175) * rate;
	}
	
	override function update(elapsed:Float):Void
	{

		super.update(elapsed);
		fadeAnimation(Constants.RATING_SPRITE_DURATION, Constants.RATING_SPRITE_DELAY);
	}
}
