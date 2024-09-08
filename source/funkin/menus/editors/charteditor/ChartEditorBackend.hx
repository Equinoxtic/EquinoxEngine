package funkin.menus.editors.charteditor;

import haxe.Json;
import funkin.play.character.Character;
#if (sys)
import sys.FileSystem;
#end

import funkin.play.components.HealthIcon;
import funkin.play.song.Song.SwagSong;

class ChartEditorBackend
{
	// TODO: Finish rest of the methods that are needed.

	public static function updatePlayerIcons(_song:Null<SwagSong>, leftIcon:HealthIcon, rightIcon:HealthIcon, ?currentSection:Int):Void
	{
		if (_song == null) {
			return;
		}

		var healthIconP1:String = _loadHealthIconFromCharacter(_song.player1);
		var healthIconP2:String = _loadHealthIconFromCharacter(_song.player2);

		if (_song.notes[currentSection].mustHitSection)
		{
			leftIcon.changeIcon(healthIconP1);
			rightIcon.changeIcon(healthIconP2);
			if (_song.notes[currentSection].gfSection) {
				leftIcon.changeIcon('gf');
			}
		}
		else
		{
			leftIcon.changeIcon(healthIconP2);
			rightIcon.changeIcon(healthIconP1);
			if (_song.notes[currentSection].gfSection) {
				leftIcon.changeIcon('gf');
			}
		}
	}

	private static function _loadHealthIconFromCharacter(char:String):String
	{
		var characterPath:String = 'characters/${char}.json';

		var path:String = '';

		#if MODS_ALLOWED
		path = Paths.modFolders(characterPath);
		if (!FileSystem.exists(path)) {
			path = Paths.getPreloadPath(characterPath);
		}
		#else
		path = Paths.getPreloadPath(characterPath);
		#end

		if (!FileUtil.fileExists(path)) {
			path = Paths.getPreloadPath('characters/${Character.DEFAULT_CHARACTER}.json');
		}

		var rawJson = FileUtil.getContentOfFile(path);

		var json:CharacterFile = cast Json.parse(rawJson);

		return json.healthicon;
	}
}
