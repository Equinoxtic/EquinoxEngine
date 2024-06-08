package funkin.play.hud.game.statistics;

using StringTools;

class StatisticsText extends FunkinText
{
	public var keyStatistic:String = "score";

	public function new(?X:Float = 0.0, ?Y:Float, keyStatistic:Null<String>):Void
	{
		super(X, Y, FlxG.width, "", Constants.STATISTICS_FONT_SIZE, LEFT, true);

		this.borderSize = Constants.STATISTICS_BORDER_SIZE;

		if (keyStatistic == null) keyStatistic = "score";

		this.keyStatistic = keyStatistic;

		switch (keyStatistic.toLowerCase().trim())
		{
			case "score": // TODO: Add keyStatistic for displaying score.
			case "misses": // TODO: Add keyStatistic for displaying misses/combo breaks.
			case "accuracy": // TODO: Add keyStatistic for displaying accuracy.
			case "rating": // TODO: Add keyStatistic for displaying the rating.
		}
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
