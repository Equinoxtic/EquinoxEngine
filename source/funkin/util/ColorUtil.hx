package funkin.util;

import flixel.util.FlxColor;
import flixel.FlxSprite;

class ColorUtil
{
	private static final DEFAULT_COLOR:Int = 0xFFFFFFFF;

	/**
	 * Converts colors of RGBA to Float using FlxColor.
	 * @param colors
	 * @return FlxColor
	 */
	public static function convertRGBAToFloat(colors:{r:Int, g:Int, b:Int, a:Int}):FlxColor
	{
		final max:Int = 255;

		final R:Int = colors.r;
		final G:Int = colors.g;
		final B:Int = colors.b;
		final A:Int = colors.a;

		if (R >= max || G >= max || B >= max || A >= max) {
			return DEFAULT_COLOR;
		}

		return FlxColor.fromRGBFloat(
			(R / max), (G / max), (B / max), (A / max)
		);
	}

	/**
	 * Convert an array of RGBA integers into floats.
	 * @param array
	 * @return FlxColor
	 */
	public static function convertRGBAArrayToFloats(array:Array<Int>):FlxColor
	{
		if (array == null || array.length <= 0) {
			return DEFAULT_COLOR;
		}

		return convertRGBAToFloat({
			r: array[0],
			g: array[1],
			b: array[2],
			a: array[3]
		});
	}

	/**
	 * Picks the dominant color of the sprite.
	 * @param sprite The sprite itself.
	 * @return Int
	 */
	public static function pickDominantColorOfSprite(sprite:FlxSprite):Int
	{
		var countByColor:Map<Int, Int> = [];

		for (col in 0...sprite.frameWidth)
		{
			for (row in 0...sprite.frameHeight)
			{
			 	var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);

				if (colorOfThisPixel != 0)
				{
					if (countByColor.exists(colorOfThisPixel)){
						countByColor[colorOfThisPixel] =  countByColor[colorOfThisPixel] + 1;
					} else if (countByColor[colorOfThisPixel] != 13520687 - (2*13520687)){
						countByColor[colorOfThisPixel] = 1;
					}
				}
			}
		}

		var maxCount = 0;
		var maxKey:Int = 0;//after the loop this will store the max color

		countByColor[flixel.util.FlxColor.BLACK] = 0;

		for(key in countByColor.keys())
		{
			if (countByColor[key] >= maxCount) {
				maxCount = countByColor[key];
				maxKey = key;
			}
		}

		return maxKey;
	}
}
