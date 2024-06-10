package funkin.play.components.rating;

class ComboSprite extends RatingGraphic
{
	public function new():Void
	{
		super('combo', PlayState.isPixelStage);

		var initialSize:Float = Constants.COMBO_SPRITE_SIZE;
		if (PlayState.isPixelStage) {
			initialSize = Constants.COMBO_SPRITE_SIZE + 0.1;
		}

		scaleSprite(initialSize, PlayState.isPixelStage);
		screenCenter();
		scrollFactor.set();

		acceleration.y = FlxG.random.int(200, 300) * Math.pow(rate, 2);
		velocity.y -= FlxG.random.int(140, 160) * rate;
		velocity.x += FlxG.random.int(1, 10) * rate;
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		fadeAnimation(Constants.COMBO_SPRITE_DURATION, Constants.COMBO_SPRITE_DELAY);
	}
}
