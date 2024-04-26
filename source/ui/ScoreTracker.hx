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

	public var fontSize:Int = 20;

	public function new(?x:Float = 0, ?y:Float = 0, ?instance:FlxBasic, ?fontSize:Int = 20, ?alignment:FlxTextAlign = CENTER) {
		super();

		if (instance == null) {
			instance = this;
		}

		this.instance = instance;
		this.fontSize = fontSize;

		scoreTxt = new FlxText(x, y, FlxG.width, "", fontSize);
		scoreTxt.setFormat(Paths.font('azonix.otf'), fontSize, FlxColor.WHITE, alignment, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		scoreTxt.borderSize = 1.3;
		scoreTxt.antialiasing = ClientPrefs.globalAntialiasing;
		add(scoreTxt);
	}

	public function updateScoreText(?score:Int = 0, ?misses:Int = 0, ?ratingFC:String = "", ?rankingString:String = "", ?ratingPercent:Float = 0.0) {

		// < SCORE: SONG SCORE / COMBO BREAKS: MISSES / ACCURACY: ACCURACY% / RATING - RANK >
		scoreTxt.text = '< SCORE: ${score}'
		+ ' / COMBO BREAKS: ${misses}'
		+ ' / '
		+ ((score > 0) ? 'ACCURACY: ${Highscore.floorDecimal(ratingPercent * 100, 2)}% / $ratingFC - ${rankingString}' : '')
		+ ' >';
		/**
		 * NOTE: I used the condition (SCORE > 0) to make it seem more feature-proof than using (RATING or RANKING != X)
		 */

		if (PlayState.instance.cpuControlled) {
			scoreTxt.size = Std.int(fontSize * 1.1);
			scoreTxt.text = '< BOTPLAY >';
		} else if (PlayState.instance.practiceMode) {
			scoreTxt.size = Std.int(fontSize * 1.1);
			scoreTxt.text = '< PRACTICE MODE >';
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
