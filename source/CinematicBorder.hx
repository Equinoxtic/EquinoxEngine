package;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;

class CinematicBorder extends flixel.group.FlxSpriteGroup
{
	private var instance:FlxBasic;

	var borderSprite:FlxSprite;

	public function new(instance:FlxBasic, ?initialScale:Null<Float>):Void
	{
		super();

		if (instance == null)
		{
			instance = this;
		}

		this.instance = instance;

		borderSprite = new FlxSprite().loadGraphic(Paths.image('ui/Asset_FilmBorder'));
		if (initialScale != null && initialScale > 0) {
			borderSprite.scale.set(initialScale * (initialScale + 1), initialScale);
		}
		borderSprite.screenCenter(X);
		add(borderSprite);
	}
}
