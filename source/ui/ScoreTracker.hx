package ui;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.FlxCamera;

using StringTools;

class ScoreTracker extends FlxSpriteGroup
{
	var instance:FlxBasic;

	private static var scoreTxt:FlxText;

	public function new(?x:Float = 0, ?y:Float = 0, ?instance:FlxBasic, ?fontSize:Int = 20, ?alignment:FlxTextAlign = CENTER) {
		super();

		if (instance == null) {
			instance = this;
		}

		this.instance = instance;

		scoreTxt = new FlxText(x, y, FlxG.width, "", fontSize);
		scoreTxt.setFormat(Paths.font('azonix.otf'), fontSize, FlxColor.WHITE, alignment, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		scoreTxt.borderSize = 1.3;
		scoreTxt.antialiasing = ClientPrefs.globalAntialiasing;
		add(scoreTxt);

		if (ClientPrefs.smallerTextDisplay) {
			scoreTxt.scale.set(.87, .87);
		}

		visible = !ClientPrefs.hideHud;
	}

	public function updateScoreText(?songScore:Int = 0, ?songMisses:Int = 0, ?accuracy:Float = 0, ?rating:String = '', ?ranking:String = '') {
		// < SCORE: SONG SCORE / COMBO BREAKS: MISSES / ACCURACY: ACCURACY% / RATING - RANK >
		scoreTxt.text = '< SCORE: ${songScore}'
		+ ' / MISSES: ${songMisses}'
		+ ' / ACCURACY: ${accuracy}%'
		+ ((songScore > 0) ? ' / ${rating} - ${ranking}' : '')
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
				isValidMode = ((mode.toLowerCase() == validModes[i]));
				if (isValidMode)
					break;
			}

			// trace(isValidMode);

			if (isValidMode) scoreTxt.text = '< ${mode.toUpperCase().replace('-', ' ')} >';
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
