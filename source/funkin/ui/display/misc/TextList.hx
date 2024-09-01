package funkin.ui.display.misc;

import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class TextList extends FlxTypedSpriteGroup<FlxText>
{
	public function new(?x:Float, ?y:Float, ?listOfTexts:Null<Array<String>>):Void
	{
		super(x, y);

		for (i in 0...listOfTexts.length) {
			var text:FunkinText = new FunkinText(0, 0, 0, '${listOfTexts[i]}\n', 14, LEFT, true, 1.35);
			text.forceDefaultFont = true;
			text.defaultFont = "phantommuff.ttf";
			text.scrollFactor.set();
			text.y += i * 11;
			add(text);
		}
	}
}
