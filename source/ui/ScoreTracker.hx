package ui;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

class ScoreTracker extends FlxSpriteGroup
{
	var instance:FlxBasic;

	private static var scoreTxt:FlxText;

	public function new(?x:Float = 0, ?y:Float = 0, ?instance:FlxBasic, ?fontSize = 24, ?alignment:FlxTextAlign = CENTER) {
		super();

		if (instance == null) {
			instance = this;
		}

		this.instance = instance;

		scoreTxt = new FlxText(x, /**healthBarBG.y + 42*/ y, FlxG.width, "", fontSize);
		scoreTxt.setFormat(Paths.font('squareone.ttf'), fontSize, FlxColor.WHITE, alignment, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		scoreTxt.borderSize = 1.275;
		scoreTxt.antialiasing = ClientPrefs.globalAntialiasing;
		add(scoreTxt);
	}

	public function updateScoreText(?score:Int = 0, ?misses:Int = 0, ?rating: String = "", ?ratingFC: String = "", ?ratingPercent:Float = 0.0) {
		scoreTxt.text = 'Score: ' + score
		+ ' | Misses: ' + misses
		+ ' | Rating: ' + rating
		+ (rating != '?' ? ' (${Highscore.floorDecimal(ratingPercent * 100, 2)}%) - $ratingFC' : '');
	}
}
