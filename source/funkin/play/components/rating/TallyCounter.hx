package funkin.play.components.rating;

class TallyCounter extends RatingGraphic
{
	public function new(indexes:Int):Void
	{
		super('num${Std.string(indexes)}', PlayState.isPixelStage);

		var initialSize:Float = Constants.NUMERICAL_COMBO_SIZE;
		if (PlayState.isPixelStage) {
			initialSize = Constants.NUMERICAL_COMBO_SIZE + 0.2;
		}

		scaleSprite(initialSize, PlayState.isPixelStage);
		screenCenter();

		acceleration.y = FlxG.random.int(200, 300) * Math.pow(rate, 2);
		velocity.x = FlxG.random.float(-5, 5) * rate;
		velocity.y -= FlxG.random.int(140, 160) * rate;
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		fadeAnimation(Constants.NUMERICAL_SCORE_DURATION, Constants.NUMERICAL_SCORE_DELAY);
	}
}
