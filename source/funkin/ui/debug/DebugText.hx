#if (debug)
package funkin.ui.debug;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxBasic;

class DebugText extends flixel.group.FlxSpriteGroup
{
	public function new(?xAdd:Float = 1.0, ?yAdd:Float = 1.0, ?alphaOverride:Float = 0.35, ?fontSize:Int = 14):Void
	{
		super();

		var debugText:flixel.text.FlxText = new flixel.text.FlxText(0, 0, FlxG.width, 'You are testing a DEBUG build of ${Variables.APPLICATION_TITLE}', fontSize);
		debugText.setFormat(Paths.font('phantommuff.ttf'), fontSize, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		debugText.borderSize = 1.3;
		debugText.alpha = alphaOverride;
		debugText.antialiasing = Preferences.globalAntialiasing;
		debugText.x -= xAdd;
		debugText.y += yAdd;
		add(debugText);

		var debugBranch:flixel.text.FlxText = new FlxText(0, 0, FlxG.width, '(${Variables.getGroupedGitBranch()})', fontSize - 1);
		debugBranch.setFormat(Paths.font('phantommuff.ttf'), fontSize - 2, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		debugBranch.borderSize = 1.3;
		debugBranch.alpha = alphaOverride;
		debugBranch.antialiasing = Preferences.globalAntialiasing;
		debugBranch.x = debugText.x;
		debugBranch.y = debugText.y + 20;
		add(debugBranch);
	}
}
#end
