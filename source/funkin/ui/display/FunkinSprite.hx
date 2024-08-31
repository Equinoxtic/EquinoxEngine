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

/**
 * The properties of an animated ``FunkinSprite``.
 */
typedef FunkinSpriteAnimationProperties = {
	@:optional var framerate:Int;
	@:optional var looped:Bool;
	@:optional var spriteType:SpriteType;
	@:optional var defaultAnimation:String;
}

/**
 * An extra typedef to support properties in animation indices.
 */
typedef AnimationIndicesProperties = {
	var prefix:String;
	var indices:Array<Int>;
}

/**
 * The options/properties of a child sprite (in this case the current ``FunkinSprite``) to follow/copy certain values from its parent sprite. (If existing.)
 */
typedef ChildProperties = {
	@:optional var copyPosition:Bool;
	@:optional var copyAngle:Bool;
	@:optional var followTransparency:Bool;
	@:optional var followVisibility:Bool;
}

class FunkinSprite extends FlxSprite
{
	/**
	 * The parent of the sprite. (Functions like 'sprTracker')
	 */
	public var parentSprite:FlxObject;

	/**
	 * The offsets of the main sprite from the parent sprite.
	 */
	private var _parentOffsets:Array<Float> = [0, 0]; // Coordinates/Position.
	private var _parentAngleOffset:Float = 0.0;
	private var _parentAlphaMultiplier:Float = 1.0;

	// Private properties for child sprite(s).
	private var COPY_POSITION:Bool = true; // Whether to copy the position of the parent sprite.
	private var COPY_ALPHA:Bool = true; // Whether to copy the alpha/opacity/transparency of the parent sprite.
	private var COPY_ANGLE:Bool = false; // Whether to copy the angle/rotation of the parent sprite.
	private var COPY_VISIBLE:Bool = false; // Whether to copy the state of visibility of the parent sprite.

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
	 * **IMPORTANT NOTE: Use ``sprite.addAnimatedSprite()`` to add animations to already existing/loaded sprites.**
	 *
	 * @param path The path of the asset/image.
	 * @param animations The map of the name and prefixes of the sprite's animation.
	 * @param properties The properties of the animated sprite.
	 */
	public function loadAnimatedSprite(path:String, animations:Map<String, String>, ?properties:Null<FunkinSpriteAnimationProperties>):Void
	{
		if (!FunkinSprite.spriteExists(path)) {
			return;
		}

		setAtlasSpriteType(path, SpriteType.SPARROW);

		addAnimatedSprite(
			animations,                    // Map of animations
			properties.framerate,          // Framerate from the sprite's properties
			properties.looped,             // Should loop from the sprite's properties
			properties.defaultAnimation    // The default animation from the sprite's properties
		);
	}

	/**
	 * ### Loads an animated sprites given the path, the animations, and the animation's indices.
	 *
	 * **IMPORTANT NOTE: Use ``sprite.addIndicesToAnimatedSprite()`` to add animations with indices to already existing/loaded sprites.**
	 *
	 * @param path The path of the asset/image.
	 * @param animations The map of the name, prefix, and indices of the sprite's animation.
	 * @param framerate The framerate of all present animations.
	 * @param looped Whether the sprite's animation should be looped.
	 * @param defaultAnimation The default animation of the animated sprite.
	 */
	public function loadAnimatedSpriteByIndices(path:String, animations:Map<String, AnimationIndicesProperties>, ?properties:Null<FunkinSpriteAnimationProperties>):Void
	{
		if (!FunkinSprite.spriteExists(path)) {
			return;
		}

		setAtlasSpriteType(path, SpriteType.SPARROW);

		addIndicesToAnimatedSprite(
			animations,
			properties.framerate,
			properties.looped,
			properties.defaultAnimation
		);
	}

	/**
	 * ### Adds the animation to already existing/loaded sprites.
	 *
	 * @param animations The map of the name and prefixes of the sprite's animation.
	 * @param framerate The framerate of all present animations.
	 * @param looped Whether the sprite's animation should be looped.
	 * @param defaultAnimation The initial/default animation to play when loading the animated sprite.
	 */
	public function addAnimatedSprite(animations:Map<String, String>, ?framerate:Int = 24, ?looped:Bool = false, ?defaultAnimation:Null<String>):Void
	{
		if (animations != null) {
			for (name => anim in animations) {
				_constructAnimationPrefixes(name, anim, framerate, looped);
			}
		}

		if (defaultAnimation != null) {
			animation.play(defaultAnimation);
		}
	}

	/**
	 * ### Adds the animation's indices to already existing/loaded sprites.
	 *
	 * @param animations The map of the name, prefix, and indices of the sprite's animation.
	 * @param framerate The framerate of all present animations.
	 * @param looped Whether the sprite's animation should be looped.
	 * @param defaultAnimation The default animation of the animated sprite.
	 */
	public function addIndicesToAnimatedSprite(animations:Map<String, AnimationIndicesProperties>, ?framerate:Int = 24, ?looped:Bool = false, ?defaultAnimation:Null<String>):Void
	{
		if (animations != null) {
			for (anim => properties in animations) {
				_constructAnimationIndices(anim, properties.prefix, properties.indices, framerate, looped);
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

	public function setPropertiesForChildSprite(childProperties:Null<ChildProperties>):Void
	{
		if (childProperties == null) {
			return;
		}

		this.COPY_POSITION = childProperties.copyPosition;
		this.COPY_ANGLE    = childProperties.copyAngle;
		this.COPY_ALPHA    = childProperties.followTransparency;
		this.COPY_VISIBLE  = childProperties.followVisibility;
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
	 * ### Sets the child sprite's X and Y offset(s) from the parent sprite.
	 * @param x The offset of the x position.
	 * @param y The offset of the y position.
	 */
	public function setParentCoordinateOffset(?x:Null<Float> = 0.0, ?y:Null<Float> = 0.0):Void
	{
		_parentOffsets[0] = x; _parentOffsets[1] = y;
	}

	/**
	 * ### Sets the child sprite's angle offset from the parent sprite.
	 * @param v The angle offset.
	 */
	public function setParentAngleOffset(?v:Float = 0.0):Void
	{
		_parentAngleOffset = v;
	}

	/**
	 * ### Set the multiplier of the transparency of the child's sprite to be multiplied with the parent sprite's current transparency.
	 * @param v The value of the alpha multiplier.
	 */
	public function setParentAlphaMultiplier(?v:Float = 0.0):Void
	{
		_parentAlphaMultiplier = v;
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (parentSprite != null && parentSprite.alive)
		{
			// Copying the position of the parent sprite.
			if (this.COPY_POSITION) {
				setPosition(
					new TransformData().incrementalValue(parentSprite.x, _parentOffsets[0]),
					new TransformData().incrementalValue(parentSprite.y, _parentOffsets[1])
				);
			}

			// Copying the angle of the parent sprite.
			if (this.COPY_ANGLE) {
				angle = new TransformData().incrementalValue(parentSprite.angle, _parentAngleOffset);
			}

			// Copying the alpha/transparency of the parent sprite.
			if (this.COPY_ALPHA) {
				alpha = new TransformData().multiply(parentSprite.alpha, _parentAlphaMultiplier);
			}

			// Follow the state of visibility of the parent sprite.
			if (this.COPY_VISIBLE) {
				visible = parentSprite.visible;
			}
		}
	}

	/**
	 * Updates the level of detail for the sprite.
	 * @param levelOfDetailEnabled Whether the level of detail system should be enabled.
	 */
	private function _updateLOD(levelOfDetailEnabled:Bool):Void
	{
		visible = true;
		if (levelOfDetailEnabled) {
			visible = (!GlobalSettings.LOW_QUALITY);
		}
	}

	/**
	 * Constructs a prefix for the sprite's animation.
	 * @param name The name of the animation from the sprite.
	 * @param prefix The prefix of the animation to be used.
	 * @param framerate The framerate of the animation.
	 * @param looped Whether the animation should be looped.
	 */
	private function _constructAnimationPrefixes(name:String, prefix:String, ?framerate:Int = 24, ?looped:Bool = false):Void
	{
		if (name != null && prefix != null) {
			animation.addByPrefix(name, prefix, _setFramerate(framerate), looped);
		}
	}

	/**
	 * Constructs an animation's indices per prefix.
	 * @param name The name of the animation from the sprite.
	 * @param prefix The prefix of the animation to be used.
	 * @param indices The array of indices of each animation.
	 * @param framerate The framerate of the indices.
	 * @param looped Whether the animation should be looped.
	 */
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
