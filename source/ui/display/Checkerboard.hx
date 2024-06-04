package ui.display;

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
	 * The default path for the 'checkers' asset.
	 */
	private var defaultCheckersPath:String = 'ui/menu/checkers/checker';

	/**
	 * The size of each tile checkerboard. Larger sizes may cause performance and loading issues!
	 */
	public var tileSize:CheckerboardSizeType = NORMAL;

	/**
	 * Create a new Checker Background, uses and extends [``FlxBackdrop``](https://api.haxeflixel.com/flixel/addons/display/FlxBackdrop.html).
	 * 
	 * @param axes The axes on which to repeat. The default, XY will tile the entire camera.
	 * @param spacing Amount of spacing between tiles on the X and Y axis.
	 * @param tileSize The size of each tile checkerboard. Larger sizes may cause performance and loading issues!
	 * @param checkerAlpha The alpha of each tile of the checkerboard.
	 * @param checkerColor The color of each tile of the checkerboard.
	 * @param scrollX The scrollfactor on the X axis.
	 * @param scrollY the scrollfactor on the Y axis.
	 */
	public function new(?axes:FlxAxes = XY, ?spacing:Int = 0, ?tileSize:CheckerboardSizeType = NORMAL, ?checkerAlpha:Float = 0.5, ?checkerColor:FlxColor = 0xFF000000, ?scrollX:Float = 0.0, ?scrollY:Float = 0.07):Void
	{
		super(Paths.image(Std.string('${defaultCheckersPath}${getTileSize(tileSize)}')), axes, spacing, spacing);

		color = checkerColor;
		alpha = checkerAlpha;
		
		if (tileSize == null)
			tileSize = NORMAL;
		this.tileSize = tileSize;
		
		scrollFactor.set(scrollX, scrollY);
	}

	/**
	 * Gets the size prefix from a Checkerboard's size type.
	 * @param tileSize 
	 * @return String
	 */
	private function getTileSize(tileSizeType:CheckerboardSizeType = NORMAL):String
	{
		var r:String = '32';

		switch (tileSizeType)
		{
			case SMALL: r = '16';
			case NORMAL: r = '32';
			case LARGE: r = '64';
			case HUGE: r = '128';
			case EXTRA_HUGE: r = '256';
		}

		return '_${Std.string(r)}';
	}

	/**
	 * Updates and increments the position of the Checkerboard.
	 * 
	 * (Use this under the ``update()`` function of a state.)
	 * 
	 * @param ix The amount of increments in the x axis.
	 * @param iy The amount of increments in the y axis.
	 */
	public function updatePosition(ix:Float = 0.47, iy:Float = 0.16):Void
	{
		x -= ix / (ClientPrefs.framerate / 60);
		y -= iy / (ClientPrefs.framerate / 60);
	}
}
