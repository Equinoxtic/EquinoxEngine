package funkin.graphics.effects;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;

class CinematicBorder extends flixel.group.FlxSpriteGroup
{
	var borderSpriteTop:FlxSprite;
	var borderSpriteBottom:FlxSprite;

	public function new(?initialScale:Null<Float>):Void
	{
		super();

		borderSpriteTop = new FlxSprite().loadGraphic(Paths.image('ui/visual/TopBorder'));
		borderSpriteTop.screenCenter(X);
		borderSpriteTop.color = FlxColor.fromRGB(0, 0, 0);
		add(borderSpriteTop);

		borderSpriteBottom = new FlxSprite().loadGraphic(Paths.image('ui/visual/BottomBorder'));
		borderSpriteBottom.screenCenter(X);
		borderSpriteBottom.color = FlxColor.fromRGB(0, 0, 0);
		add(borderSpriteBottom);
	}
}
