package funkin.ui.display.misc;

import flixel.FlxSprite;

class StaticIcon extends FlxSprite
{
	private var character:String = 'bf';
	public function new(character:String, ?isPlayer:Bool = false):Void
	{
		super();

		if (character == null) {
			character = 'bf';
		}

		this.character = character;

		var path:String = 'icons/' + character;

		if (!Paths.fileExists('images/' + path + '.png', IMAGE)) {
			path = 'icons/icon-' + character;
		}

		if (!Paths.fileExists('images/' + path + '.png', IMAGE)) {
			path = 'icons/icon-face';
		}

		var file:Dynamic = Paths.image(path);

		loadGraphic(file, true, 150, 150);
		updateHitbox();

		animation.add(character, [0], 0, false, isPlayer);
		animation.play(character);
		this.character = character;

		scrollFactor.set();

		antialiasing = Preferences.globalAntialiasing;
	}
}
