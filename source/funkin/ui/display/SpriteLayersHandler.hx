package funkin.ui.display;

import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxBasic;

enum CharacterLayers
{
	GF;
	BF;
	DAD;
}

class SpriteLayersHandler extends FlxTypedGroup<FlxBasic>
{
	private final _enumMappings:Map<CharacterLayers, Dynamic> = [
		GF  => PlayState.instance.gfGroup,
		BF  => PlayState.instance.boyfriendGroup,
		DAD => PlayState.instance.dadGroup
	];

	/**
	 * Create a new instance for handling and layering sprites.
	 */
	public function new():Void
	{
		super(0, 0);
		trace('Initialized handler for Sprite Layering');
	}

	/**
	 * Adds an object behind the given character.
	 * @param characterLayer The layer of the character/the character itself.
	 * @param object The object/sprite.
	 */
	public function addBehind(characterLayer:Null<CharacterLayers>, object:Null<FlxObject>):Void
	{
		if (object == null || !object.alive) {
			return;
		}

		insert(members.indexOf(_enumMappings.get(characterLayer)), object);
	}

	/**
	 * Adds a list of objects behind the given character.
	 * @param characterLayer The layer of the character/the character itself.
	 * @param objectList The list of objects/sprites.
	 */
	public function addListOfObjectsBehind(characterLayer:Null<CharacterLayers>, objectList:Null<Array<FlxObject>>):Void
	{
		if (objectArray != null && objectArray.length > 0) {
			for (i in 0 ... objectArray.length) {
				addBehind(characterLater, objectArray[i]);
			}
		}
	}
}
