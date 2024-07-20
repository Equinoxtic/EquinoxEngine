package funkin.ui.display;

import flixel.FlxSprite;

class FunkinSprite extends FlxSprite
{
	/**
	 * Create a new sprite/graphic. (Extends [``FlxSprite``](https://api.haxeflixel.com/flixel/FlxSprite.html))
	 * @param X The X position/coordinates of the sprite in space.
	 * @param Y The Y position/coordinates of the sprite in space.
	 * @param levelOfDetail Allows ``GlobalSettings.LOW_QUALITY`` to hide not draw/hide the sprite.
	 */
	public function new(?X:Float, ?Y:Float, ?levelOfDetail:Bool = false):Void
	{
		super(X, Y);

		visible = (levelOfDetail && GlobalSettings.LOW_QUALITY);

		antialiasing = (GlobalSettings.SPRITE_ANTIALIASING);
	}
}
