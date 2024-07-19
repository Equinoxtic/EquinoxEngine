package funkin.ui.display;

import flixel.text.FlxText;

class FunkinText extends FlxText
{
	/**
	 * Forces the given default font. [ Default: ``false`` ]
	 */
	public var forceDefaultFont:Bool = false;

	/**
	 * The default font to be forced. [ Default: ``phantommuff.ttf`` ]
	 */
	public var defaultFont:String = 'phantommuff.ttf';

	private var _fontKey:String = null;
	private var _updatedFont:Bool = false;

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
	public function new(X:Float, Y:Float, fieldWidth:Float = 0, ?text:String = "", ?fontSize:Int = 16, ?textAlignment:FlxTextAlign = CENTER, border:Bool = true, ?borderSize:Float = 2.5):Void
	{
		super(X, Y, fieldWidth, text, fontSize);

		var fontString:String = 'phantommuff';
		var fontExt:String = 'ttf';

		switch(GlobalSettings.FONT_FACE)
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

		if (PlayState.isPixelStage) {
			fontString = 'vcr';
		}

		this._fontKey = '${fontString}.${fontExt}';

		setFormat(Paths.font(Std.string('${fontString}.${fontExt}')), fontSize, 0xFFFFFFFF, textAlignment);

		if (border)
		{
			setBorderStyle(OUTLINE, 0xFF000000, 0.0, 1);
			if (!(borderSize < 0)) {
				this.borderSize = borderSize;
			} else {
				borderSize = 2.5;
			}
		}

		antialiasing = (GlobalSettings.SPRITE_ANTIALIASING && !PlayState.isPixelStage);
	}

	private function _updateFont():Void
	{
		if (_updatedFont) {
			return;
		}

		var fontString:String = this._fontKey;
		if (forceDefaultFont) {
			fontString = defaultFont;
		}

		font = Paths.font(fontString);

		_updatedFont = true;
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		_updateFont();
	}
}
