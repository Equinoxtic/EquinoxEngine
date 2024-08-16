package funkin.ui.display;

import funkin.graphics.TransformData;
import flixel.FlxObject;
import funkin.animateatlas.AtlasFrameMaker;
import flixel.FlxSprite;
import openfl.utils.Assets as Assets;

using StringTools;

enum SpriteType
{
	SPARROW;
	PACKER;
	TEXTURE;
}

class FunkinSprite extends FlxSprite
{
	/**
	 * The relative parent of the sprite. (Functions like 'sprTracker')
	 */
	public var parentSprite:FlxObject;

	/**
	 * The offsets of the main sprite from the parent sprite.
	 */
	private var _parentOffsets:Array<Float> = [0, 0];

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
	 * bg.loadSprite('menuBG');
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
	 *     ],
	 *     24,
	 *     false,
	 *     'idle');
	 *     // ...
	 * }
	 * ```
	 *
	 * @param path The path of the asset/image.
	 * @param animations A 2-dimensional array of the name and prefix of the animation.
	 * @param framerate The framerate of all present animations.
	 * @param looped Whether the sprite's animation should be looped.
	 * @param defaultAnimation The initial/default animation to play when loading the animated sprite.
	 */
	public function loadAnimatedSprite(path:String, animations:Array<Array<String>>, ?framerate:Int = 24, ?looped:Bool = false, ?defaultAnimation:Null<String>):Void
	{
		if (!FunkinSprite.spriteExists(path)) {
			return;
		}

		setAtlasSpriteType(path, SpriteType.SPARROW);

		addAnimatedSprite(animations, framerate, looped, defaultAnimation);
	}

	/**
	 * ### Adds the animation to already existing sprites.
	 * @param animations A 2-dimensional array of the name and prefix of the animation.
	 * @param framerate The framerate of all present animations.
	 * @param looped Whether the sprite's animation should be looped.
	 * @param defaultAnimation The initial/default animation to play when loading the animated sprite.
	 */
	public function addAnimatedSprite(animations:Array<Array<String>>, ?framerate:Int = 24, ?looped:Bool = false, ?defaultAnimation:Null<String>):Void
	{
		if (animations != null && animations.length > 0) {
			for (i in 0...animations.length) {
				_constructAnimationPrefixes(animations[i][0], animations[i][1], framerate, looped);
			}
		}

		if (defaultAnimation != null) {
			animation.play(defaultAnimation);
		}
	}

	/**
	 * ### Loads an animated sprites given the path, the animations, and the animation's indices.
	 *
	 * ```
	 * // ...
	 * var sprite:FunkinSprite = new FunkinSprite();
	 * sprite.loadAnimtedSpriteByIndicies('SPRITESHEET', [
	 *         [ 'name_1', 'prefix_1', [ 0, 1, 2, 3, 4, 5, ... ] ],
	 *         [ 'name_2', 'prefix_2', [ 0, 1, 2, 3, 4, 5, ... ] ],
	 *         [ 'name_3', 'prefix_3', [ 0, 1, 2, 3, 4, 5, ... ] ],
	 *     ],
	 *     24,
	 *     true,
	 *     'name_1'
	 * );
	 * add(sprite);
	 * // ...
	 * ```
	 *
	 * @param path The path of the asset/image.
	 * @param animations The 2-dimensional array of the name, prefix, and indices of the animation.
	 * @param framerate The framerate of all present animations.
	 * @param looped Whether the sprite's animation should be looped.
	 * @param defaultAnimation The default animation of the animated sprite.
	 */
	public function loadAnimatedSpriteByIndices(path:String, animations:Array<Dynamic>, ?framerate:Int = 24, ?looped:Bool = false, ?defaultAnimation:Null<String>):Void
	{
		if (!FunkinSprite.spriteExists(path)) {
			return;
		}

		setAtlasSpriteType(path, SpriteType.SPARROW);

		addIndicesToAnimatedSprite(animations, framerate, looped, defaultAnimation);
	}

	/**
	 * ### Adds the animation's indices to already existing sprites.
	 * @param animations The 2-dimensional array of the name, prefix, and indices of the animation.
	 * @param framerate The framerate of all present animations.
	 * @param looped Whether the sprite's animation should be looped.
	 * @param defaultAnimation The default animation of the animated sprite.
	 */
	public function addIndicesToAnimatedSprite(animations:Array<Dynamic>, ?framerate:Int = 24, ?looped:Bool = false, ?defaultAnimation:Null<String>):Void
	{
		if (animations != null && animations.length > 0) {
			for (i in 0...animations.length) {
				_constructAnimationIndices(animations[i][0], animations[i][1], animations[i][2], framerate, looped);
			}
		}

		if (defaultAnimation != null) {
			animation.play(defaultAnimation);
		}
	}

	/**
	 * ### Sets the sprite's atlas based on the type of the sprite.
	 * @param key The key/path of the sprite.
	 * @param spriteType The ``SpriteType`` of the sprite.
	 */
	public function setAtlasSpriteType(key:String, ?spriteType:Null<SpriteType> = SpriteType.SPARROW):Void
	{
		switch (spriteType)
		{
			case SPARROW:
				frames = Paths.getSparrowAtlas(key);
			case PACKER:
				frames = Paths.getPackerAtlas(key);
			case TEXTURE:
				frames = AtlasFrameMaker.construct(key);
		}
	}

	/**
	 * ### To check whether or not a sprite's path to an asset exists.
	 * @param path The path of the asset.
	 * @return Bool
	 */
	public static function spriteExists(path:String):Bool
	{
		var existing:Bool = (Assets.exists(Paths.imagePath(path)) && path != null);
		if (!existing) {
			trace('Failed to load sprite/asset: $path');
		}
		return existing;
	}

	/**
	 * ### Sets the main sprite's X and Y offset(s) from the parent sprite.
	 * @param x The x position.
	 * @param y The y position.
	 */
	public function setOffsetFromParentSprite(x:Null<Float>, y:Null<Float>):Void
	{
		_parentOffsets[0] = x; _parentOffsets[1] = y;
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (parentSprite != null && parentSprite.alive)
		{
			setPosition(
				new TransformData().incrementalValue(parentSprite.x, _parentOffsets[0]),
				new TransformData().incrementalValue(parentSprite.y, _parentOffsets[1])
			);
		}
	}

	private function _updateLOD(levelOfDetailEnabled:Bool):Void
	{
		visible = true;
		if (levelOfDetailEnabled) {
			visible = (!GlobalSettings.LOW_QUALITY);
		}
	}

	private function _constructAnimationPrefixes(name:String, prefix:String, ?framerate:Int = 24, ?looped:Bool = false):Void
	{
		if (name != null && prefix != null) {
			animation.addByPrefix(name, prefix, _setFramerate(framerate), looped);
		}
	}

	private function _constructAnimationIndices(name:String, prefix:String, indices:Array<Int>, ?framerate:Int = 24, ?looped:Bool = false):Void
	{
		if (name != null && prefix != null) {
			if (indices != null && indices.length > 0) {
				animation.addByIndices(name, prefix, indices, "", _setFramerate(framerate), looped);
			} else {
				_constructAnimationPrefixes(name, prefix, framerate, looped);
			}
		}
	}

	private function _setFramerate(framerate:Int):Int
	{
		var m_framerate:Int = 24;
		if (framerate > 0 && !Math.isNaN(framerate)) {
			m_framerate = framerate;
		}
		return m_framerate;
	}
}
