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

class SpriteLayersHandler
{

	/**
	 * Adds an object behind the given character.
	 * @param characterLayer The layer of the character/the character itself.
	 * @param object The object/sprite.
	 */
	public static function addBehind(instance:Null<FlxTypedGroup<FlxBasic>>, characterLayer:Null<CharacterLayers>, object:Null<FlxObject>):Void
	{
		final _enumMappings:Map<CharacterLayers, Dynamic> = [
			GF  => PlayState.instance.gfGroup,
			BF  => PlayState.instance.boyfriendGroup,
			DAD => PlayState.instance.dadGroup
		];

		if (instance == null || object == null || !object.alive) {
			return;
		}

		instance.insert(instance.members.indexOf(_enumMappings.get(characterLayer)), object);
	}

	/**
	 * Adds a list of objects behind the given character.
	 * @param characterLayer The layer of the character/the character itself.
	 * @param objectList The list of objects/sprites.
	 */
	public static function addListOfObjectsBehind(instance:Null<FlxTypedGroup<FlxBasic>>, characterLayer:Null<CharacterLayers>, objectList:Null<Array<FlxObject>>):Void
	{
		if (objectList != null && objectList.length > 0) {
			for (i in 0 ... objectList.length) {
				addBehind(instance, characterLayer, objectList[i]);
			}
		}
	}
}
