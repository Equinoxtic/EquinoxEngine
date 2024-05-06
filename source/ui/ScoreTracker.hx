package ui;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

using StringTools;

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

	public function updateScoreText() {
		// < SCORE: SONG SCORE / COMBO BREAKS: MISSES / ACCURACY: ACCURACY% / RATING - RANK >
		scoreTxt.text = '< SCORE: ${PlayState.instance.songScore}'
		+ ' / COMBO BREAKS: ${PlayState.instance.songMisses}'
		+ ' / ACCURACY: ${Highscore.floorDecimal(PlayState.instance.ratingPercent * 100, 2)}%'
		+ ((PlayState.instance.songScore > 0) ? ' / ${PlayState.instance.ratingFC} - ${PlayState.instance.ranking}' : '')
		+ ' >';
		/**
		 * NOTE: I used the condition (SCORE > 0) to make it seem more feature-proof than using (RATING or RANKING != X)
		 */
	}

	public function changeScoreTextMode(mode:String, ?defaultFontSizeMult:Float = 1.0):Void {
		if (mode != null) {
			var validModes:Array<String> = [ 
				'botplay', 
				'charting-mode', 
				'practice-mode' 
			];

			var isValidMode:Bool = false;

			for (i in 0...validModes.length) {
				isValidMode = ((mode.toLowerCase() == validModes[i].toLowerCase()));
				if (isValidMode) break;
			}

			trace(isValidMode);

			if (isValidMode) scoreTxt.text = '< ${mode.toUpperCase().replace('-', ' ')} >';
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
