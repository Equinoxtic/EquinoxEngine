package funkin.play.components.statistics;

import funkin.play.scoring.Rating;
import funkin.tweens.GlobalTweenClass;
import funkin.play.components.rating.ComboSprite;
import funkin.play.components.rating.TallyCounter;
import funkin.play.components.rating.RatingSprite;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class ScorePopUp extends FlxTypedSpriteGroup<FlxSprite>
{
	private var _comboValue:Int;
	private var _currentRating:Rating;
	private var _showsTallyCounter:Bool;
	private var _showsCombo:Bool;

	public function new(?rating:Null<Rating>, ?combo:Null<Int>, ?showCombo:Bool = false, ?showTallyCounter:Bool = true):Void
	{
		super(0, 0);

		if (combo >= 0) {
			this._comboValue = combo;
		}

		if (rating != null) {
			this._currentRating = rating;
		}

		this._showsTallyCounter = showTallyCounter;
		this._showsCombo = showCombo;

		scrollFactor.set();
		cameras = [PlayState.instance.camRating];
		visible = (!GlobalSettings.HIDE_HUD);

		_showScorePopUp();
	}

	private function _showScorePopUp():Void
	{
		var placement:String = Std.string(_comboValue);

		var offsetText:FlxText = new FlxText(0, 0, 0, placement, 32);
		offsetText.screenCenter();
		offsetText.x = FlxG.width * 0.35;

		var ratingSprite:RatingSprite = new RatingSprite(_currentRating);
		ratingSprite.x = offsetText.x - 50;
		ratingSprite.y -= 20;
		add(ratingSprite);

		var seperatedScore:Array<Int> = [];

		var comboConditions:Array<Dynamic> = [
			[(_comboValue >= 1000), (_comboValue / 1000)],
			[(_comboValue >= 100), (_comboValue / 100)],
			[(_comboValue >= 10), (_comboValue / 10)],
			[(_comboValue > 0), _comboValue],
		];

		for (i in 0...comboConditions.length) {
			if (comboConditions[i][0]) {
				seperatedScore.push(Math.floor(comboConditions[i][1] % 10));
			}
		}

		var iterations:Int = 0;
		var xIncrement:Float = 0;

		for (i in seperatedScore)
		{
			var tallyCounter:TallyCounter = new TallyCounter(i);
			tallyCounter.setPosition(offsetText.x + (42 * iterations) - 75, ratingSprite.y);
			tallyCounter.x += -5;
			tallyCounter.y += 100;
			tallyCounter.visible = _showsTallyCounter;
			add(tallyCounter);

			iterations++;

			if (tallyCounter.x > xIncrement) {
				xIncrement = tallyCounter.x;
			}
		}

		var comboSprite:ComboSprite = new ComboSprite();
		comboSprite.setPosition(xIncrement + 85, ratingSprite.y);
		comboSprite.y += 85;
		comboSprite.visible = _showsCombo;
		add(comboSprite);

		offsetText.text = Std.string(seperatedScore);

		GlobalTweenClass.tween(offsetText, { y: 1, x : 1 }, Constants.NUMERICAL_SCORE_DURATION / PlayState.instance.playbackRate, {
			startDelay: Constants.NUMERICAL_SCORE_DELAY / PlayState.instance.playbackRate,
			onComplete: function(_) {
				offsetText.destroy();
			}
		});
	}
}
