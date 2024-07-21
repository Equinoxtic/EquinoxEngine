package funkin.ui.display;

import flixel.FlxSprite;
import openfl.utils.Assets as Assets;

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

		visible = true;
		active = true;
		if (levelOfDetail) {
			if (GlobalSettings.LOW_QUALITY) {
				visible = false;
				active = false;
			}
		} else {
			visible = true;
			active = true;
		}

		scrollFactor.set();

		antialiasing = (GlobalSettings.SPRITE_ANTIALIASING);
	}

	public function loadSprite(path:String):Void
	{
		if (!FunkinSprite.spriteExists(path)) {
			return;
		}

		loadGraphic(Paths.image(path));
	}

	public function loadAnimatedSprite(path:String, animationKeys:Array<Array<String>>, ?framerate:Int = 24):Void
	{
		if (!FunkinSprite.spriteExists(path)) {
			return;
		}

		frames = Paths.getSparrowAtlas(path);

		if (animationKeys != null && animationKeys.length > 0) {
			if (framerate <= 0 && Math.isNaN(framerate)) {
				framerate = 24;
			}
			for (i in 0...animationKeys.length) {
				animation.addByPrefix(animationKeys[i][0], animationKeys[i][1], framerate);
			}
		}
	}

	public static function spriteExists(path:String):Bool
	{
		var _spriteExisting:Bool = (Assets.exists(Paths.imagePath(path)) && path != null);
		if (!_spriteExisting) {
			trace('Failed to load sprite/asset: $path');
		}
		return _spriteExisting;
	}
}
