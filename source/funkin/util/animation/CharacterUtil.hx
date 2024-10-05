package funkin.util.animation;

class CharacterUtil
{
	public static function getPathToIcon(character:String = 'boyfriend'):String
	{
		var path:String = 'icons/$character';

		if (!Paths.fileExists('images/' + path + '.png', IMAGE)) {
			path = 'icons/icon-$character';
		}

		if (!Paths.fileExists('images/' + path + '.png', IMAGE)) {
			path = 'icons/icon-face';
		}

		// trace('Returned icon for $character: [$path]');

		return path;
	}
}
