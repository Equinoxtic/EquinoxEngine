package play.hud.game.statistics;

import misc.FunkinText;

class AccuracyText extends FunkinText
{
	public var accuracyString:Null<String> = 'Accuracy';
	public var accuracyNum:Float = 0.0;
	public var shouldRound:Bool = false;

	public function new(X:Float, Y:Float):Void
	{
		super(X, Y, FlxG.width, "Accuracy: N/A", Constants.STATISTICS_FONT_SIZE, LEFT, true);

		this.borderSize = Constants.STATISTICS_BORDER_SIZE;

		setup(accuracyString, accuracyNum, shouldRound);
	}

	private function setup(txt:Null<String>, accuracy:Float, ?roundUp:Bool = false):Void
	{
		this.text = 'Accuracy: ';

		if (txt != null)
		{
			this.text = '${txt}: ';
			if (!roundUp) {
				this.text += '${Std.string(accuracy)}%';
			} else {
				this.text += '${Std.string(Math.round(accuracy))}%';
			}
		}
	}

	public function updateAccuracy():Void
	{
		if (!PlayState.instance.cpuControlled && !PlayState.instance.practiceMode && !PlayState.chartingMode)
		{
			setup(accuracyString, accuracyNum, shouldRound);
		}
		else
		{
			this.text = 'Accuracy: N/A';
			if (accuracyString != null && accuracyString != '') {
				this.text = '${accuracyString}: N/A';
			}
		}
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
