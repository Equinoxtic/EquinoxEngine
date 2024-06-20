package funkin.play.components.statistics;

import funkin.play.scoring.Highscore;
import funkin.tweens.GlobalTweenClass;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

using StringTools;

enum StatisticType
{
	SCORE;
	MISSES;
	ACCURACY;
	RATING;
}

class StatisticsText extends FunkinText
{
	/**
	 * The type of statistic to display.
	 */
	public var statisticType:StatisticType = SCORE;

	/**
	 * Create a new text for player-specified statistics.
	 * @param X The X position of the text.
	 * @param Y The Y position of the text
	 * @param statisticType The type of statistic to display. [Default: SCORE]
	 */
	public function new(?X:Float = 0.0, ?Y:Float, ?statisticType:Null<StatisticType> = SCORE):Void
	{
		super(X, Y, FlxG.width, "", Constants.STATISTICS_FONT_SIZE, LEFT, true, Constants.STATISTICS_BORDER_SIZE);

		this.scrollFactor.set();

		if (statisticType == null) {
			statisticType = StatisticType.SCORE;
		}

		this.statisticType = statisticType;

		displayStatistic(statisticType);
	}

	private function displayStatistic(statisticType:Null<StatisticType>):Void
	{
		if (statisticType == null) return;

		switch (statisticType)
		{
			case SCORE:
				var value:Int = PlayState.instance.songScore;
				if (!Math.isNaN(value)) {
					this.text = 'Score: ${value}';
				}

			case MISSES:
				var value:Int = PlayState.instance.songMisses;
				if (!Math.isNaN(value) && value >= 0)
				{
					if (value >= Constants.GLOBAL_NUMBER_CAP)
						value = Constants.GLOBAL_NUMBER_CAP;
					this.text = 'Misses: ${value}';
				}

			case ACCURACY:
				var value:Float = Highscore.floorDecimal(PlayState.instance.ratingPercent * 100, 2);
				if (!Math.isNaN(value)) {
					this.text = 'Accuracy: ${value}%';
				}

			case RATING:
				var rating:String = PlayState.instance.ratingFC;
				var ranking:String = PlayState.instance.ranking;
				if (rating != null && ranking != null) {
					this.text = '${rating} - ${ranking}';
				}
		}
	}

	private var missTween:FlxTween;

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (!PlayState.instance.cpuControlled && !PlayState.instance.practiceMode && !PlayState.chartingMode)
		{
			displayStatistic(statisticType);
		}
		else
		{
			switch (statisticType)
			{
				case SCORE:
					this.text =
						"-" + ((PlayState.instance.cpuControlled) ? " BOTPLAY -" : "")
						+ ((PlayState.instance.practiceMode) ? " PRACTICE MODE -" : "")
						+ ((PlayState.chartingMode) ? " CHARTING MODE -" : "");
				case MISSES:
					this.text = "Misses: N/A";
				case ACCURACY:
					this.text = "Accuracy: N/A";
				case RATING:
					this.text = "CLEAR - N/A";
			}
		}
	}
}
