package play.hud.game.statistics;

import ui.display.FunkinText;

class RatingText extends FunkinText
{
	public var ratingString:Null<String> = 'CLEAR';
	public var rankingString:Null<String> = 'N/A';

	public function new(X:Float, Y:Float):Void
	{
		super(X, Y, FlxG.width, "CLEAR - N/A", Constants.STATISTICS_FONT_SIZE, LEFT, true);

		this.borderSize = Constants.STATISTICS_BORDER_SIZE;

		setup(ratingString, rankingString);
	}

	private function setup(rating:Null<String>, ranking:Null<String>):Void
	{
		this.text = 'CLEAR - N/A';
		if (rating != null && ranking != null) {
			this.text = '${rating} - ${ranking}';
		}
	}

	public function updateRating():Void
	{
		if (!PlayState.instance.cpuControlled && !PlayState.instance.practiceMode && !PlayState.chartingMode)
		{
			setup(ratingString, rankingString);
		}
		else
		{
			this.text = 'CLEAR - N/A';
		}
	}
}
