package ui;

import flixel.group.FlxGroup.FlxTypedGroup;
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

	
	private var instance:FlxBasic;
	
	private var judgementText:FlxText;

	public function new(?x:Float = 0, ?y:Float = 0, ?instance:FlxBasic, ?fontSize:Int = 21, ?alignment:FlxTextAlign = LEFT) {
		super();

		if (instance == null) {
			instance = this;
		}

		this.instance = instance;

		judgementText = new FlxText(x, y, FlxG.width, "", fontSize);
		judgementText.setFormat(Paths.font('azonix.otf'), fontSize, FlxColor.WHITE, alignment, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		judgementText.borderSize = 1.45;
		judgementText.antialiasing = ClientPrefs.globalAntialiasing;
		add(judgementText);
	}

	public function updateJudgementCounter() {
		if (ClientPrefs.detailedJudgementInfo) {
			judgementText.scale.set(0.985, 0.985);
			judgementText.text = 'TOTAL HITS: ${PlayState.instance.songHits}\n'
				+ 'COMBO: ${PlayState.instance.combo}\n\n'
				+ 'MARVELOUS: ${PlayState.instance.marvs}\n'
				+ 'SICK: ${PlayState.instance.sicks}\n'
				+ 'GOOD: ${PlayState.instance.goods}\n'
				+ 'BAD: ${PlayState.instance.bads}\n'
				+ 'SHIT: ${PlayState.instance.shits}'
				+ '\n\nCOMBO BREAKS: ${PlayState.instance.songMisses}';
		} else {
			judgementText.scale.set(1.025, 1.025);
			judgementText.text = 'MARVELOUS: ${PlayState.instance.marvs}\n'
				+ 'SICK: ${PlayState.instance.sicks}\n'
				+ 'GOOD: ${PlayState.instance.goods}\n'
				+ 'BAD: ${PlayState.instance.bads}\n'
				+ 'SHIT: ${PlayState.instance.shits}';
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
