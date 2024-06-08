package funkin.play.hud.game;

import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.group.FlxSpriteGroup;
import funkin.play.hud.game.statistics.StatisticsText;

class StatisticsHUD extends FlxTypedSpriteGroup<FlxSprite>
{
	private var instance:FlxBasic;

	private var scoreText:StatisticsText;
	private var missesText:StatisticsText;
	private var accuracyText:StatisticsText;
	private var ratingText:StatisticsText;

	/**
	 * Creates the HUD for the player's score/statistics. (Shows the Score, Misses, Accuracy, and Rating)
	 * @param instance The current instance of the Statistics HUD. [Default: ``this``]
	 * @param X The X position of the Statistics HUD.
	 * @param Y The Y position of the Statistics HUD.
	 * @param scale The scale of the Statistics HUD. [Default: ``1.0``]
	 */
	public function new(instance:FlxBasic, X:Float, Y:Float, ?scale:Float = 1.0):Void
	{
		super();

		if (instance == null)
		{
			instance = this;
		}

		this.instance = instance;

		#if (debug)
		FlxG.log.add('Created Statistics HUD.');
		#end

		scoreText = new StatisticsText(X, Y, SCORE);
		missesText = new StatisticsText(scoreText.x, scoreText.y + 25, MISSES);
		accuracyText = new StatisticsText(missesText.x, missesText.y + 25, ACCURACY);
		ratingText = new StatisticsText(accuracyText.x, accuracyText.y + 25, RATING);
		
		add(scoreText);
		add(missesText);
		add(accuracyText);
		add(ratingText);
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
