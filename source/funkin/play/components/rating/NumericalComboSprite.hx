package funkin.play.components.rating;

class NumericalComboSprite extends RatingGraphic
{
	public function new(indexes:Int):Void
	{
		super('num${Std.string(indexes)}', PlayState.isPixelStage);

		scaleSprite(Constants.NUMERICAL_COMBO_SIZE, PlayState.isPixelStage);
		screenCenter();
		scrollFactor.set();

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
