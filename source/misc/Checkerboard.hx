package misc;

import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxColor;
import flixel.FlxBasic;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxAxes;

enum CheckerboardSizeType
{
	SMALL;
	NORMAL;
	LARGE;
	HUGE;
	EXTRA_HUGE;
}

class Checkerboard extends FlxBackdrop
{
	/**
	 * Create a new Checker Background, using FlxBackdrop.
	 * @param axes The axes on which to repeat. The default, XY will tile the entire camera.
	 * @param spacing Amount of spacing between tiles on the X and Y axis.
	 * @param sizeType The size of each tile checkerboard. Larger sizes may cause performance and loading issues!
	 * @param checkerAlpha The alpha of each tile of the checkerboard.
	 * @param checkerColor The color of each tile of the checkerboard.
	 * @param scrollX The scrollfactor on the X axis.
	 * @param scrollY the scrollfactor on the Y axis.
	 */
	public function new(?axes:FlxAxes = XY, ?spacing:Int = 0, ?sizeType:CheckerboardSizeType = NORMAL, ?checkerAlpha:Float = 0.5, ?checkerColor:FlxColor = 0xFF000000, ?scrollX:Float = 0.0, ?scrollY:Float = 0.07):Void
	{
		super(Paths.image(Std.string('ui/menu/checkers/checker${getSizePrefixBySizeType(sizeType)}')), axes, spacing, spacing);
		color = checkerColor;
		alpha = checkerAlpha;
		scrollFactor.set(scrollX, scrollY);
	}

	private function getSizePrefixBySizeType(sizeType:CheckerboardSizeType = NORMAL):String
	{
		var sizePrefix:String = '32';
		switch (sizeType)
		{
			case SMALL: sizePrefix = '16';
			case NORMAL: sizePrefix = '32';
			case LARGE: sizePrefix = '64';
			case HUGE: sizePrefix = '128';
			case EXTRA_HUGE: sizePrefix = '256';
		}
		return '_${Std.string(sizePrefix)}';
	}

	public function updatePosition(ix:Float = 0.47, iy:Float = 0.16):Void
	{
		x -= ix / (ClientPrefs.framerate / 60);
		y -= iy / (ClientPrefs.framerate / 60);
	}
}
