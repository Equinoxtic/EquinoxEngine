package funkin.ui.display.misc;

import flixel.FlxSprite;
import flixel.text.FlxText;

class AttachedFlxText extends FlxText
{
	public var sprTracker:FlxSprite;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;

	public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true):Void
	{
		super(X, Y, FieldWidth, Text, Size, EmbeddedFont);
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (sprTracker != null)
		{
			setPosition(sprTracker.x + xAdd, sprTracker.y + yAdd);
			angle = sprTracker.angle;
			alpha = sprTracker.alpha;
		}
	}
}
