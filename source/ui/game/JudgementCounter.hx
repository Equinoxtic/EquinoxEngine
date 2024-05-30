package ui.game;

import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import util.Constants;

using StringTools;

class JudgementCounter extends FlxSpriteGroup
{
	public var colorArray:Array<Int> = [225, 235, 95];

	private var instance:FlxBasic;
	
	private var judgementText:FunkinText;

	public function new(?instance:FlxBasic, ?x:Float = 0, ?y:Float = 0, ?initialSize:Float = 1.0, ?fontSize:Int = 21, ?alignment:FlxTextAlign = LEFT) {
		super();

		if (instance == null) {
			instance = this;
		}

		this.instance = instance;

		judgementText = new FunkinText(x, y, FlxG.width, "", fontSize, LEFT, true);
		judgementText.scrollFactor.set();
		judgementText.scale.set(initialSize, initialSize);
		add(judgementText);

		judgementText.updateHitbox();
		
		#if (!debug)
		visible = ((ClientPrefs.showJudgementCounter) ? !ClientPrefs.hideHud : false);
		#end
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
