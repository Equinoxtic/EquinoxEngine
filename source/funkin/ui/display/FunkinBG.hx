package funkin.ui.display;

import flixel.effects.FlxFlicker;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import funkin.input.Controls;
import flixel.tweens.FlxTween;

class FunkinBG extends FlxSprite
{
	/**
	 * Does the background do the flickering animation?
	 */
	public var flickers:Bool = false;

	/**
	 * Is the background exclusive to freeplay only?
	 */
	public var isFreeplayBG:Bool = false;

	/**
	 * The color tween for the background.
	 */
	private var _colorTweenBG:FlxTween;

	/**
	 * The intended color of the background during a color tween.
	 */
	private var _intendedColor:Int;

	private var controls(get, never):Controls;

	inline function get_controls():Controls {
		return PlayerSettings.player1.controls;
	}

	/**
	 * Create a background graphic that extends with FlxSprite.
	 * @param X The X position of the background.
	 * @param Y The Y position of the background.
	 * @param menuGraphic The graphic/asset of the background. [``Recommended size for assets is 1280x720``]
	 * @param scrollX The scroll factor in the X coordinates in space.
	 * @param scrollY The scroll factor in the Y coordinates in space.
	 * @param bgColor The color of the background.
	 * @param isFreeplayBG Should the background be exclusive to freeplay only?
	 */
	public function new(X:Float, Y:Float, menuGraphic:FlxGraphicAsset, ?scrollX:Float, ?scrollY:Float, ?bgColor:FlxColor = 0xFFFFFFFF, ?isFreeplayBG:Bool = false):Void
	{
		super(X, Y, menuGraphic);

		scrollFactor.set(scrollX, scrollY);
		setGraphicSize(Std.int(width * 1.175));
		updateHitbox();
		screenCenter();
		color = bgColor;
		antialiasing = GlobalSettings.SPRITE_ANTIALIASING;

		this.isFreeplayBG = isFreeplayBG;

		_intendedColor = bgColor;
	}

	/**
	 * Updates the color for the background. (Only works if ``isFreeplayBG`` is set to ``true``)
	 * @param songs The array of songs.
	 * @param index The index of the song array.
	 */
	public function updateColor(songs:Array<SongMetadata>, index:Int):Void
	{
		if (!isFreeplayBG) {
			return;
		}

		var newColor:Int = songs[index].color;

		if (newColor != _intendedColor)
		{
			_intendedColor = newColor;

			if (_colorTweenBG != null) {
				_cancelColorTweens();
			}

			_colorTweenBG = FlxTween.color(this, 1.0, this.color, _intendedColor, {
				onComplete: function(_:FlxTween):Void {
					_colorTweenBG = null;
				}
			});

			_colorTweenBG.start();
		}
	}

	private function _cancelColorTweens():Void
	{
		_colorTweenBG.cancel();
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (!isFreeplayBG)
		{
			if (flickers && GlobalSettings.FLASHING_LIGHTS)
			{
				if (controls.ACCEPT) {
					FlxFlicker.flicker(this, 1.1, 0.15, false);
				}
			}
		}
	}
}
