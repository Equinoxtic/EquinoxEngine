package funkin.ui.display.misc;

class StaticIcon extends FunkinSprite
{
	private var character:String = 'bf';
	public function new(character:String, ?isPlayer:Bool = false):Void
	{
		super(0, 0, false);

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
	}
}
