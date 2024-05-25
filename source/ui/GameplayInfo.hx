package ui;

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

		gameplayText.text = '${songName}\n'
		+ '${difficultyString}\n'
		+ '${songCredit}\n'
		+ '${songText}';

		#if (!debug)
		visible = ((ClientPrefs.showGameplayInfo) ? !ClientPrefs.hideHud : false);
		#end
	}

	public function updateGameplayText(?songName:String = "", ?difficultyString:String = "", ?songCredit:String = "", ?songText:String = "") {
		gameplayText.text = '${songName}\n'
		+ '${difficultyString}\n'
		+ '${songCredit}\n'
		+ '${songText}';
	}
	
	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
