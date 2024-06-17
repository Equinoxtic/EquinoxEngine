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
	 * @param textAlignment The alignment of the text field.
	 * @param border Should the text field have a border?
	 */
	public function new(X:Float, Y:Float, fieldWidth:Float = 0, ?text:String = "", ?fontSize:Int = 16, ?textAlignment:FlxTextAlign, ?border:Bool = true, ?borderSize:Float = 2.5):Void
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

		if (!this.usePreferredFont) {
			setFormat(Paths.font('${fontString}.${fontExt}'), fontSize, 0xFFFFFFFF, textAlignment);
		} else {
			setFormat(Paths.font(fontString), fontSize, 0xFFFFFFFF, textAlignment);
		}

		if (border) {
			this.setBorderStyle(OUTLINE, 0xFF000000, 0.0, 5);

			if (!(borderSize < 0)) {
				this.borderSize = borderSize;
			} else {
				this.borderSize = 2.5;
			}
		}

		antialiasing = (Preferences.globalAntialiasing && !PlayState.isPixelStage);
	}
}
