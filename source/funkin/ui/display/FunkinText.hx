package funkin.ui.display;

import flixel.text.FlxText;

class FunkinText extends FlxText
{
	/**
	 * Uses / forces the font that you want to load in instead of the engine's built-in fonts.
	 */
	public var usePreferredFont:Bool = false;

	/**
	 * The string of the preferred font to use.
	 */
	public var preferredFont:String = 'phantommuff.ttf';

	/**
	 * Create a new text field that extends with [``FlxText``](https://api.haxeflixel.com/flixel/text/FlxText.html).
	 * @param X The x position of the text field.
	 * @param Y The y position of the text field.
	 * @param fieldWidth The text field's width.
	 * @param text The content / text of the text field.
	 * @param fontSize The scale of the font in the text field.
	 * @param textAligment The alignment of the text field.
	 * @param border Should the text field have a border?
	 */
	public function new(X:Float, Y:Float, fieldWidth:Float = 0, ?text:String = "", ?fontSize:Int = 16, ?textAligment:FlxTextAlign, ?border:Bool = true):Void
	{
		super(X, Y, fieldWidth, text, fontSize);

		var fontString:String = 'phantommuff';
		var fontExt:String = 'ttf';

		switch(Preferences.fontFace) {
			case 'Classic':
				fontString = 'vcr';
			case 'Engine Legacy':
				fontString = 'azonix';
				fontExt = 'otf';
			default:
				fontString = 'phantommuff';
		}

		if (PlayState.isPixelStage) {
			fontString = 'vcr';
		} else {
			if (this.usePreferredFont) {
				fontString = this.preferredFont;
			}
		}

		setFormat(Paths.font('${fontString}.${fontExt}'), fontSize, 0xFFFFFFFF, textAligment);

		if (border) {
			borderStyle = FlxTextBorderStyle.OUTLINE;
			borderColor = 0xFF000000;

			if (fontString != 'vcr') {
				borderSize = fontSize / 8.15;
			} else {
				borderSize = fontSize / 5.2;
				this.size = fontSize + 1;
			}
		}

		antialiasing = (Preferences.globalAntialiasing && !PlayState.isPixelStage);
	}
}
