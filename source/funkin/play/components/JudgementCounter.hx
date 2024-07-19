package funkin.play.components;

import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import funkin.ui.display.FunkinText;
import funkin.util.Constants;

using StringTools;

class JudgementCounter extends FlxSpriteGroup
{
	private var instance:FlxBasic;

	private var judgementText:FunkinText;

	/**
	 * Creates a new text field for the Judgement Counter.
	 * @param instance The current instance of the Judgement Counter. [Default: ``this``]
	 * @param x The X position of the Judgement Counter.
	 * @param y The Y position of the Judgement Counter.
	 * @param initialSize The initial scale of the Judgement Counter. [Default: ``1.0``]
	 * @param fontSize The font size of the text in the Judgement Counter. [Default: ``21``]
	 * @param alignment The text alignment of the text in the Judgement Counter. [Default: ``LEFT``]
	 */
	public function new(?instance:FlxBasic, ?x:Float = 0, ?y:Float = 0, ?initialSize:Float = 1.0, ?fontSize:Int = 21, ?alignment:FlxTextAlign = LEFT):Void
	{
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
		visible = ((GlobalSettings.JUDGEMENT_COUNTER) ? !GlobalSettings.HIDE_HUD : false);
		#end
	}

	/**
	 * Updates the Judgement Counter texts/stats.
	 */
	public function updateJudgementCounter():Void
	{
		if (GlobalSettings.DETAILED_JUDGEMENT_COUNTER)
		{
			judgementText.scale.set(0.97, 0.97);
			judgementText.text = 'TOTAL HITS: ${PlayState.instance.songHits}\n'
				+ 'COMBO: ${PlayState.instance.combo}\n\n'
				+ 'MARVELOUS: ${PlayState.instance.marvs}\n'
				+ 'SICK: ${PlayState.instance.sicks}\n'
				+ 'GOOD: ${PlayState.instance.goods}\n'
				+ 'BAD: ${PlayState.instance.bads}\n'
				+ 'SHIT: ${PlayState.instance.shits}'
				+ '\n\nCOMBO BREAKS: ${PlayState.instance.songMisses}';
		}
		else
		{
			judgementText.scale.set(1.0, 1.0);
			judgementText.text = 'MARVELOUS: ${PlayState.instance.marvs}\n'
				+ 'SICK: ${PlayState.instance.sicks}\n'
				+ 'GOOD: ${PlayState.instance.goods}\n'
				+ 'BAD: ${PlayState.instance.bads}\n'
				+ 'SHIT: ${PlayState.instance.shits}';
		}
	}
}
