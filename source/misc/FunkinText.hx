package misc;

import flixel.text.FlxText;

class FunkinText extends FlxText
{
	public function new(X:Float, Y:Float, fieldWidth:Float = 0, ?text:String = "", ?fontSize:Int = 16, ?textAligment:FlxTextAlign, ?border:Bool = true):Void
	{
		super(X, Y, fieldWidth, text, fontSize);

		var fontString:String = 'phantommuff';
		if (PlayState.isPixelStage)
			fontString = 'vcr';

		setFormat(Paths.font('${fontString}.ttf'), fontSize, 0xFFFFFFFF, textAligment);
		
		if (border)
		{
			borderStyle = FlxTextBorderStyle.OUTLINE;
			borderColor = 0xFF000000;
			borderSize = fontSize / 8.15;
		}

		antialiasing = (ClientPrefs.globalAntialiasing && !PlayState.isPixelStage);
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
