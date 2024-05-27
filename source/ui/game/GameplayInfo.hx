package ui.game;

import util.Constants;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

class GameplayInfo extends FlxSpriteGroup
{
	private var instance:FlxBasic;

	private static var gameplayText:FlxText;

	public function new(?instance:FlxBasic, ?x:Float = 0.0, ?y:Float = 0.0, ?initialSize:Float = 1.0, ?fontSize:Int = 24, ?songName:String = "", ?difficultyString:String = "", ?songCredit:String = "", ?songText:String = "")
	{
		super();
		
		if (instance == null) {
			instance = this;
		}
		
		this.instance = instance;

		gameplayText = new FlxText(x, y, FlxG.width, "", fontSize);
		gameplayText.setFormat(Paths.font('phantommuff.ttf'), fontSize, 0xFFFFFFFF, RIGHT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		gameplayText.borderSize = 1.3;
		gameplayText.antialiasing = ClientPrefs.globalAntialiasing;
		add(gameplayText);

		gameplayText.updateHitbox();

		createGameplayText(songName, difficultyString, songCredit, songText);

		#if (!debug)
		visible = ((ClientPrefs.showGameplayInfo) ? !ClientPrefs.hideHud : false);
		#end
	}

	private function createGameplayText(songName:Null<String>, difficultyString:Null<String>, songCredit:Null<String>, songText:Null<String>):Void
	{
		var nullCheckArray:Array<String> = [];
		var text:String = '';

		/**
		 * Make place holder text first just in case if anything returns null.
		 */
		gameplayText.text = 'Song\nDifficulty\nArtist\nText';

		nullCheckArray.push(songName);
		nullCheckArray.push(difficultyString);
		nullCheckArray.push(songCredit);
		nullCheckArray.push(songText);

		for (s in 0...nullCheckArray.length) {
			if (nullCheckArray[s] != null && nullCheckArray[s] != '') {
				text += '${nullCheckArray[s]}\n';
			}
		}

		/**
		 * Finally, update the placeholder text to the current text.
		 */
		gameplayText.text = text;
	}
	
	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
