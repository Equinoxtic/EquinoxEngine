package funkin.play.components.rating;

import funkin.play.scoring.Rating;

class RatingSprite extends RatingGraphic
{
	public function new(rating:Rating):Void
	{
		if (rating == null) {
			rating.image = "sick";
		}

		super(rating.image, PlayState.isPixelStage);

		scaleSprite(Constants.RATING_SPRITE_SIZE, PlayState.isPixelStage);
		screenCenter();

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
