package funkin.ui.display.misc;

import flixel.FlxSprite;

class AttachedText extends Alphabet
{
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var sprTracker:FlxSprite;
	public var copyVisible:Bool = true;
	public var copyAlpha:Bool = false;
	public function new(text:String = "", ?offsetX:Float = 0, ?offsetY:Float = 0, ?bold = false, ?scale:Float = 1):Void
	{
		super(0, 0, text, bold);

		if (scale != null && scale > 0)
			this.scaleX = scale ; this.scaleY = scale;

		this.isMenuItem = false;

		if (offsetX != null && !Math.isNaN(offsetX)) {
			this.offsetX = offsetX;
		}
		if (offsetY != null && !Math.isNaN(offsetY)) {
			this.offsetY = offsetY;
		}
	}

	override function update(elapsed:Float):Void
	{
		if (sprTracker != null)
		{
			setPosition(sprTracker.x + offsetX, sprTracker.y + offsetY);
			if (copyVisible) {
				visible = sprTracker.visible;
			}
			if (copyAlpha) {
				alpha = sprTracker.alpha;
			}
		}
		super.update(elapsed);
	}
}
