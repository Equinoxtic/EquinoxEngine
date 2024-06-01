package ui.game;

import misc.FunkinText;

class RatingText extends FunkinText
{
	public var ratingString:Null<String> = 'CLEAR';
	public var rankingString:Null<String> = 'N/A';

	public function new(X:Float, Y:Float):Void
	{
		super(X, Y, FlxG.width, "CLEAR - N/A", 20, LEFT, true);

		this.borderSize = 3.0;

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

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
