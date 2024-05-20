package ui;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

class GameplayInfo extends FlxSpriteGroup
{
	private var instance:FlxBasic;

	private static var gameplayText:FlxText;

	public function new(?x:Float = 0.0, ?y:Float = 0.0, ?instance:FlxBasic, ?fontSize:Int = 24, ?songName:String = "", ?difficultyString:String = "", ?songCredit:String = "", ?songText:String = "")
	{
		super();
		
		if (instance == null) {
			instance = this;
		}
		
		this.instance = instance;

		gameplayText = new FlxText(x, y, FlxG.width, "", fontSize);
		gameplayText.setFormat(Paths.font('azonix.otf'), fontSize, 0xFFFFFFFF, RIGHT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		gameplayText.borderSize = 1.3;
		gameplayText.antialiasing = ClientPrefs.globalAntialiasing;
		add(gameplayText);

		if (ClientPrefs.smallerTextDisplay) {
			gameplayText.scale.set(.9, .9);
			gameplayText.x += 72;
			gameplayText.y += 12;
		}

		gameplayText.text = '${songName}\n'
		+ '${difficultyString}\n'
		+ '${songCredit}\n'
		+ '${songText}';

		visible = ((ClientPrefs.showGameplayInfo) ? !ClientPrefs.hideHud : false);
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
