package funkin.ui.display.misc;

import funkin.util.animation.CharacterUtil;

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

		var file:Dynamic = Paths.image(
			CharacterUtil.getPathToIcon(character)
		);

		loadGraphic(file, true, Constants.ICON_WIDTH, Constants.ICON_HEIGHT);
		updateHitbox();

		animation.add(character, [0], 0, false, isPlayer);
		animation.play(character);

		this.character = character;
	}
}
