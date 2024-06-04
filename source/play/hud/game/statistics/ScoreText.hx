package play.hud.game.statistics;

import ui.display.FunkinText;

class ScoreText extends FunkinText
{
	public var scoreString:Null<String> = 'Score';
	public var scoreNum:Int = 0;

	public function new(X:Float, Y:Float):Void
	{
		super(X, Y, FlxG.width, "Score: N/A", Constants.STATISTICS_FONT_SIZE, LEFT, true);

		this.borderSize = Constants.STATISTICS_BORDER_SIZE;
		
		setup(scoreString, scoreNum);
	}

	private function setup(txt:Null<String>, score:Int):Void
	{
		this.text = 'Score: ${Std.string(score)}';
		if (txt != null) {
			this.text = '${txt}: ${Std.string(score)}';
		}
	}

	public function updateScore():Void
	{
		if (!PlayState.instance.cpuControlled && !PlayState.instance.practiceMode && !PlayState.chartingMode)
		{
			setup(scoreString, scoreNum);
		}
		else
		{
			changeTextToMode(PlayState.instance.cpuControlled, PlayState.instance.practiceMode, PlayState.chartingMode);
		}
	}

	private function changeTextToMode(?botplay:Bool, ?practice:Bool, ?charting:Bool):Void
	{
		this.text = '- '
			+ ((botplay) ? 'Botplay - ' : '')
			+ ((practice) ? 'Practice Mode - ' : '')
			+ ((charting) ? 'Charting Mode -' : '');
	}
}
