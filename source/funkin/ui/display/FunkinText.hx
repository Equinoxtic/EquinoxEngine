package funkin.ui.display;

import flixel.text.FlxText;

class FunkinText extends FlxText
{
	/**
	 * Create a new text field that extends with [``FlxText``](https://api.haxeflixel.com/flixel/text/FlxText.html).
	 * @param X The x position of the text field.
	 * @param Y The y position of the text field.
	 * @param fieldWidth The text field's width.
	 * @param text The content / text of the text field.
	 * @param fontSize The scale of the font in the text field.
	 * @param textAlignment The alignment of the text field.
	 * @param border Should the text field have a border?
	 * @param forceDefaultFont Should the text be forced to use the default font? [``phantommuff.ttf``]
	 */
	public function new(X:Float, Y:Float, fieldWidth:Float = 0, ?text:String = "", ?fontSize:Int = 16, ?textAlignment:FlxTextAlign = CENTER, border:Bool = true, ?borderSize:Float = 2.5, ?forceDefaultFont:Bool = false):Void
	{
		super(X, Y, fieldWidth, text, fontSize);

		var fontString:String = 'phantommuff';
		var fontExt:String = 'ttf';

		if (!forceDefaultFont)
		{
			switch(Preferences.fontFace)
			{
				case 'Default': // Default Equinox Engine font.
					fontString = 'phantommuff';
				case 'Classic': // Classic FNF Font.
					fontString = 'vcr';
				case 'Engine Legacy': // Legacy Equinox Engine font.
					fontString = 'azonix';
					fontExt = 'otf';
				default:
					fontString = 'phantommuff';
			}

			if (PlayState.isPixelStage)
				fontString = 'vcr';
		}

		setFormat(Paths.font(Std.string('$fontString.$fontExt')), fontSize, 0xFFFFFFFF, textAlignment);

		if (border)
		{
			setBorderStyle(OUTLINE, 0xFF000000, 0.0, 5);
			if (!(borderSize < 0)) {
				this.borderSize = borderSize;
			} else {
				borderSize = 2.5;
			}
		}

		antialiasing = (Preferences.globalAntialiasing && !PlayState.isPixelStage);
	}
}
