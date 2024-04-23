package ui;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

using StringTools;

class JudgementCounter extends FlxSpriteGroup
{
	public var colorArray:Array<Int> = [225, 235, 95];
	var instance:FlxBasic;

	private static var judgementTxt:FlxText;

	public function new(?x:Float = 0, ?y:Float = 0, ?instance:FlxBasic, ?fontSize:Int = 21, ?alignment:FlxTextAlign = LEFT) {
		super();

		if (instance == null) {
			instance = this;
		}

		this.instance = instance;
		
		judgementTxt = new FlxText(x, y, FlxG.width, "", fontSize);
		judgementTxt.setFormat(Paths.font('azonix.otf'), fontSize, FlxColor.WHITE, alignment, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		judgementTxt.borderSize = 1.45;
		judgementTxt.antialiasing = ClientPrefs.globalAntialiasing;

		add(judgementTxt);
	}

	public function updateJudgementCounter(?sicksValue:Int = 0, ?goodsValue:Int = 0, ?badsValue:Int = 0, ?shitsValue:Int = 0) {
		judgementTxt.text = 'Sick: ${sicksValue}\n\n' +
							'Good: ${goodsValue}\n\n' +
							'Bad: ${badsValue}\n\n' +
							'Shit: ${shitsValue}';
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
