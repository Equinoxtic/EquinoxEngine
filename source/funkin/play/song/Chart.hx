package funkin.play.song;

import funkin.play.song.Song.SwagSong;
import funkin.sound.FunkinSound;
import funkin.play.stage.StageData;
import funkin.play.stage.StageData;
import funkin.play.song.Section.SwagSection;
import haxe.Json;
import openfl.utils.Assets as OpenFLAssets;

#if (sys)
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

enum ParseType
{
	SONG;
	EVENTS;
	DATA;
	METADATA;
	CHARACTER_MAP;
}

class Chart
{
	public static function loadChartData(song:String, input:String, ?parseType:Null<ParseType> = SONG):Dynamic
	{
		var JSON = null;

		var stringPath:String = getDataPathOfSong(song, input, "difficulties");

		switch (parseType)
		{
			case SONG:
				stringPath = getDataPathOfSong(song, input, "difficulties");
			case EVENTS:
				stringPath = getDataPathOfSong(song, input, "events");
			case DATA:
				stringPath = getDataPathOfSong(song, input, "songdata");
			case METADATA:
				stringPath = getDataPathOfSong(song, input, null);
			case CHARACTER_MAP:
				stringPath = getDataPathOfSong(song, input, "character-maps");
		}

		#if (MODS_ALLOWED)
		var modFile = Paths.modsJson(stringPath);
		if (FileSystem.exists(modFile)) {
			JSON = File.getContent(modFile).trim();
		}
		#end

		if (JSON == null) {
			JSON = FileUtil.getContentOfFile(Paths.json(stringPath)).trim();
		}

		while (!JSON.endsWith("}")) {
			JSON = JSON.substr(0, JSON.length - 1);
		}

		var parsedJSON:Null<Dynamic> = null;

		switch(parseType)
		{
			case SONG | EVENTS | CHARACTER_MAP:
				parsedJSON = Song.parseJSONshit(JSON);
			case DATA:
				parsedJSON = SongData.parseData(JSON);
			case METADATA:
				parsedJSON = SongSettings.parseData(JSON);
		}

		if (parseType.equals(ParseType.SONG)) {
			if (input != 'events' && !parseType.equals(ParseType.EVENTS)) {
				StageData.loadDirectory(parsedJSON);
			}
			onLoadJson(parsedJSON);
		}

		return parsedJSON;
	}

	public static function getDataPathOfSong(song:String, key:String, ?library:Null<String> = ""):String
	{
		final songPath:String = Paths.formatToSongPath(song);
		final filePathString:String = 'charts/${songPath}/${_formatLibraryString(library)}${key}';

		var filePath:String = filePathString;

		switch(library) {
			case 'events' | 'songdata' | 'character-maps':
				filePath = '${filePathString}${FunkinSound.erectModeSuffix(false)}';
			case 'difficulties':
				filePath = filePathString;
			default:
				filePath = '${filePathString}${FunkinSound.erectModeSuffix(true)}';
		}

		if (FileUtil.jsonExists(filePath)) {
			return filePath;
		}

		return "";
	}

	private static function onLoadJson(songJson:Dynamic):Void
	{
		if (songJson.gfVersion == null) {
			songJson.gfVersion = songJson.player3;
			songJson.player3 = null;
		}

		if (songJson.events == null) {
			songJson.events = [];
			for (secNum in 0...songJson.notes.length)
			{
				var sec:SwagSection = songJson.notes[secNum];

				var i:Int = 0;
				var notes:Array<Dynamic> = sec.sectionNotes;
				var len:Int = notes.length;
				while(i < len)
				{
					var note:Array<Dynamic> = notes[i];
					if(note[1] < 0)
					{
						songJson.events.push([note[0], [[note[2], note[3], note[4]]]]);
						notes.remove(note);
						len = notes.length;
					}
					else i++;
				}
			}
		}
	}

	private static function _formatLibraryString(library:String):String
	{
		if (library != null && library.charAt(0) != '') {
			return '$library/';
		}
		return '';
	}
}
