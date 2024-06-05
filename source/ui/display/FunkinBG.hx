package ui.display;

import flixel.effects.FlxFlicker;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class FunkinBG extends FlxSprite
{
	public var flickers:Bool = false;
	public var isFreeplayBG:Bool = false;

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
	 */
	public function new(X:Float, Y:Float, menuGraphic:FlxGraphicAsset, ?scrollX:Float, ?scrollY:Float, ?bgColor:FlxColor = 0xFFFFFFFF):Void
	{
		super(X, Y, menuGraphic);

		this.scrollFactor.set(scrollX, scrollY);
		this.setGraphicSize(Std.int(width * 1.175));
		this.updateHitbox();
		this.screenCenter();
		this.color = bgColor;
		this.antialiasing = ClientPrefs.globalAntialiasing;
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (flickers && ClientPrefs.flashing)
		{
			if (controls.ACCEPT) {
				FlxFlicker.flicker(this, 1.1, 0.15, false);
			}
		}
		else
		{
			if (isFreeplayBG)
			{
				// TODO: Make it compatible with FreeplayState.
			}
		}
	}
}
