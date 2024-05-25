#if (debug)
package ui;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxBasic;

class DebugText extends flixel.group.FlxSpriteGroup
{
	private var instance:FlxBasic;

	public function new(instance:FlxBasic, ?xAdd:Float = 1.0, ?yAdd:Float = 1.0, ?alphaOverride:Float = 0.35, ?fontSize:Int = 14):Void
	{
		super();

		if (instance == null) instance = this;

		this.instance = instance;

		var debugText:flixel.text.FlxText = new flixel.text.FlxText(0, 0, FlxG.width, 'You are testing a DEBUG build of ${Constants.MAIN_APPLICATION_TITLE}', fontSize);
		debugText.setFormat(Paths.font('phantommuff.ttf'), fontSize, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		debugText.borderSize = 1.3;
		debugText.alpha = alphaOverride;
		debugText.antialiasing = ClientPrefs.globalAntialiasing;
		debugText.x -= xAdd;
		debugText.y += yAdd;
		add(debugText);

		var debugBranch:flixel.text.FlxText = new FlxText(0, 0, FlxG.width, '(Branch: ${Constants.GIT_BRANCH} @ ${Constants.GIT_HASH})', fontSize - 1);
		debugBranch.setFormat(Paths.font('phantommuff.ttf'), fontSize - 2, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		debugBranch.borderSize = 1.3;
		debugBranch.alpha = alphaOverride;
		debugBranch.antialiasing = ClientPrefs.globalAntialiasing;
		debugBranch.x = debugText.x;
		debugBranch.y = debugText.y + 20;
		add(debugBranch);
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
#end
