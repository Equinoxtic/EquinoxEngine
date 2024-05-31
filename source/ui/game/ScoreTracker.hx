package ui.game;

import misc.FunkinText;
import util.Constants;
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

	public function new(?instance:FlxBasic, ?x:Float = 0, ?y:Float = 0, ?initialSize:Float = 1.0, ?fontSize:Int = 20, ?alignment:FlxTextAlign = CENTER) {
		super();

		if (instance == null) {
			instance = this;
		}

		this.instance = instance;

		scoreTxt = new FunkinText(x, y, FlxG.width, "", fontSize, CENTER, true);
		scoreTxt.scrollFactor.set();
		scoreTxt.screenCenter(X);
		scoreTxt.scale.set(initialSize, initialSize);
		add(scoreTxt);

		scoreTxt.updateHitbox();

		visible = !ClientPrefs.hideHud;
	}

	public function updateScoreText(?songScore:Int = 0, ?songMisses:Int = 0, ?accuracy:Float = 0, ?rating:String = '', ?ranking:String = ''):Void
	{
		// < SCORE: SONG SCORE | COMBO BREAKS: MISSES | ACCURACY: ACCURACY% | RATING - RANK >
		scoreTxt.text = 'SCORE: ${songScore}'
		+ ' | MISSES: ${songMisses}'
		+ ' | ACCURACY: ${accuracy}%'
		+ ((songScore > 0) ? ' | ${rating} - ${ranking}' : '');
		/**
		 * NOTE: I used the condition (SCORE > 0) to make it seem more feature-proof than using (RATING or RANKING != X)
		 */
	}

	public function checkPlayStateMode():Void
	{
		var botplay:Bool = PlayState.instance.cpuControlled;
		var practiceMode:Bool = PlayState.instance.practiceMode;
		var chartingMode:Bool = PlayState.chartingMode;

		var text:String = '- ${((botplay) ? 'Botplay - ' : '')}${((practiceMode) ? 'Practice Mode - ' : '')}${((chartingMode) ? 'Charting Mode - ' : '')}
		';

		scoreTxt.text = text;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
