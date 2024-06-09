package funkin.play.song;

import haxe.Json;

#if (sys)
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

typedef SongSettingsJSON = {
	var songDisplayName:String;
	var difficulties:Array<String>;
	var variations:Array<String>;
	var hasCountdown:Bool;
	var	hasNoteWiggle:Bool;
	var beatMod:Int;
}

class SongSettings
{
	public var songDisplayName:String = 'Test';
	public var difficuties:Array<String> = [];
	public var variations:Array<String> = [];
	public var hasCountdown:Bool = true;
	public var hasNoteWiggle:Bool = false;
	public var beatMod:Int = 4;

	public static function loadSongSettings(song:String):SongSettingsJSON
	{
		if (song == null || song == "")
			return null;

		var JSON = null;
		
		final songPath:String = Paths.formatToSongPath(song);

		var filePath:String = 'charts/${songPath}/metadata';

		#if MODS_ALLOWED
		var modFile:String = Paths.modsJson(filePath);
		if (FileSystem.exists(modFile)) {
			JSON = File.getContent(modFile).trim();
		}
		#end

		if (JSON == null)
		{
			#if (sys)
			JSON = File.getContent(Paths.json(filePath).trim());
			#else
			JSON = Assets.getText(Paths.json(filePath).trim());
			#end
		}

		while (!JSON.endsWith("}")) {
			JSON = JSON.substr(0, JSON.length - 1);
		}

		var ParsedJSON = parseData(JSON);

		return ParsedJSON;
	}

	public static function parseData(json:Null<String>):SongSettingsJSON
	{
		var data:SongSettingsJSON = cast Json.parse(json).metadata;
		return data;
	}
}
