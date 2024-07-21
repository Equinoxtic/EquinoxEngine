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

		_updateLOD(levelOfDetail);

		scrollFactor.set();

		antialiasing = (GlobalSettings.SPRITE_ANTIALIASING);
	}

	/**
	 * ### Loads an image of a sprite given the path.
	 * You will not need to call/type in ``Paths.image()`` as you will only need to provide the string path of the asset you want to load in.
	 *
	 * ```
	 * // Example code of using the FunkinSprite class with the loadSprite() method.
	 * var bg:FunkinSprite = new FunkinSprite();
	 * bg.loadGraphic('menuBG');
	 * add(bg);
	 * ```
	 *
	 * @param path The path of the asset/image.
	 */
	public function loadSprite(path:String):Void
	{
		if (!FunkinSprite.spriteExists(path)) {
			return;
		}

		loadGraphic(Paths.image(path));
	}

	/**
	 * ### Loads an animated sprite given the path and the provided array of animations.
	 * You will not need to call ``Paths.getSparrowAtlas()`` as it only needs you to provide the string path and the array of animations you want to load in.
	 *
	 * ```
	 * // Example code of using the FunkinSprite class with the loadAnimatedSprite() method.
	 * for (i in 0...optionShit.length)
	 * {
	 *     // ...
	 *     var menuItem:FunkinSprite = new FunkinSprite(0, (i * 180) + offset);
	 *     menuItem.scale.set(scale, scale);
	 *     menuItem.loadAnimatedSprite('mainmenu/menu_${optionShit[i]}', [
	 *         [ 'idle',     '${optionShit[i]} basic' ],
	 *         [ 'selected', '${optionShit[i]} white' ]
	 *     ], 24, 'idle');
	 *     // ...
	 * }
	 * ```
	 *
	 * @param path The path of the asset/image.
	 * @param animationKeys A 2-dimensional array of animations.
	 * @param framerate The framerate of each animation.
	 * @param defaultAnimation The initial/default animation to play when loading the animated sprite.
	 */
	public function loadAnimatedSprite(path:String, animationKeys:Array<Array<String>>, ?framerate:Int = 24, ?defaultAnimation:Null<String>):Void
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

		if (defaultAnimation != null) {
			animation.play(defaultAnimation);
		}
	}

	/**
	 * ### To check whether or not a sprite's path to an asset exists.
	 * @param path The path of the asset.
	 * @return Bool
	 */
	public static function spriteExists(path:String):Bool
	{
		var _spriteExisting:Bool = (Assets.exists(Paths.imagePath(path)) && path != null);
		if (!_spriteExisting) {
			trace('Failed to load sprite/asset: $path');
		}
		return _spriteExisting;
	}

	private function _updateLOD(levelOfDetailEnabled:Bool):Void
	{
		visible = true;
		if (levelOfDetailEnabled) {
			visible = (!GlobalSettings.LOW_QUALITY);
		}
	}
}
