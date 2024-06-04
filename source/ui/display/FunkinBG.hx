package ui.display;

import flixel.effects.FlxFlicker;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class FunkinBG extends FlxSprite
{
	public var flickers:Bool = false;

	public function new(X:Float, Y:Float, menuGraphic:FlxGraphicAsset, ?scrollX:Float, ?scrollY:Float, ?bgColor:FlxColor = 0xFFFFFFFF):Void
	{
		super(X, Y, menuGraphic);

		scrollFactor.set(scrollX, scrollY);
		setGraphicSize(Std.int(width * 1.175));
		updateHitbox();
		screenCenter();
		color = bgColor;
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	public function startFlicker(intervals:Float, duration:Float):Void
	{
		if (ClientPrefs.flashing) {
			FlxFlicker.flicker(this, duration, intervals, false);
		}
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		visible = !flickers;
	}
}
