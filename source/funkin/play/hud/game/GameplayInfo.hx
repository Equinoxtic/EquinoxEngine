package funkin.play.hud.game;

import funkin.ui.display.FunkinText;
import funkin.util.Constants;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

class GameplayInfo extends FlxSpriteGroup
{
	private var instance:FlxBasic;

	private static var gameplayText:FunkinText;

	/**
	 * Create a text field for Gameplay Info. (i.e. Song Name, Difficulty, Artist, etc.)
	 * @param instance The instance of the ``GameplayInfo`` class. [Default: ``this``]
	 * @param x The X position of the text field.
	 * @param y The Y position of the text field.
	 * @param initialSize The initial scale of the text field.
	 * @param fontSize The font size of the text field.
	 * @param songName The string of the song's name. ( By default it should ``PlayState.SONG.song`` )
	 * @param difficultyString The string of the player's current difficulty. ( By default it should be ``FunkinUtil.difficultyString()`` )
	 * @param songCredit The string of the artist/credit of the song. ( By default it should be ``PlayState.SONG_DATA.artist`` )
	 * @param songText The extra/optional string in the text field. ( By default it should be ``PlayState.SONG_DATA.stringExtra`` )
	 */
	public function new(?instance:FlxBasic, ?x:Float = 0.0, ?y:Float = 0.0, ?initialSize:Float = 1.0, ?fontSize:Int = 24, ?songName:Null<String> = "", ?difficultyString:Null<String> = "", ?songCredit:Null<String> = "", ?songText:Null<String> = ""):Void
	{
		super();

		if (songName == null || difficultyString == null || songCredit == null || songText == null) return;
		
		if (instance == null) {
			instance = this;
		}
		
		this.instance = instance;

		gameplayText = new FunkinText(x, y, FlxG.width, "", fontSize, RIGHT, true);
		gameplayText.scrollFactor.set();
		gameplayText.scale.set(initialSize, initialSize);
		add(gameplayText);

		gameplayText.updateHitbox();

		createGameplayText(songName, difficultyString, songCredit, songText);

		#if (!debug)
		visible = ((Preferences.showGameplayInfo) ? !Preferences.hideHud : false);
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
}
