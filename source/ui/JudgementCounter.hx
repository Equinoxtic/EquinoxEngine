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

	private var judgementTextList:Array<String> = [
		'TOTAL HITS',
		'COMBO',
		'SICK',
		'GOOD',
		'BAD',
		'SHIT',
		'COMBO BREAKS'
	];

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

	public function updateJudgementCounter(?hitsValue:Int = 0, ?combosValue = 0, ?sicksValue:Int = 0, ?goodsValue:Int = 0, ?badsValue:Int = 0, ?shitsValue:Int = 0, ?missesValue:Int = 0) {
		judgementTxt.text = '${judgementTextList[0]}: ${hitsValue}\n' +
							'${judgementTextList[1]}: ${combosValue}\n\n' +
							'${judgementTextList[2]} ${sicksValue}\n' +
							'${judgementTextList[3]}: ${goodsValue}\n' +
							'${judgementTextList[4]}: ${badsValue}\n' +
							'${judgementTextList[5]}: ${shitsValue}\n\n' +
							'${judgementTextList[6]}: ${missesValue}';
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
