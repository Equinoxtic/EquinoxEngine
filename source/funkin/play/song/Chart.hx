package funkin.play.song;

import funkin.sound.FunkinSound;
import funkin.play.stage.StageData;
import funkin.play.stage.StageData;
import funkin.play.song.Section.SwagSection;
import haxe.Json;

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
	public function new():Void {}

	public static function loadChartData(song:String, input:String, ?parseType:Null<ParseType> = SONG):Dynamic
	{
		var JSON = null;

		var stringPath:String = "";

		switch (parseType)
		{
			case SONG:
				stringPath = getDataPathOfSong(song, input, 'difficulties/');
			case EVENTS:
				stringPath = getDataPathOfSong(song, input, 'events/', false);
			case DATA:
				stringPath = getDataPathOfSong(song, input, 'songdata/', false);
			case METADATA:
				stringPath = getDataPathOfSong(song, input, '', true);
			case CHARACTER_MAP:
				stringPath = getDataPathOfSong(song, input, 'character-maps/');
		}

		#if (MODS_ALLOWED)
		var modFile = Paths.modsJson(stringPath);
		if (FileSystem.exists(modFile)) {
			JSON = File.getContent(modFile).trim();
		}
		#end

		if (JSON == null) {
			JSON = File.getContent(Paths.json(stringPath).trim());
		}

		while (!JSON.endsWith("}")) {
			JSON = JSON.substr(0, JSON.length - 1);
		}

		var parsedJSON:Dynamic = parseChartData(JSON, parseType);

		if (parseType == ParseType.SONG) {
			if (parseType != ParseType.EVENTS && input != 'events') {
				StageData.loadDirectory(parsedJSON);
			}
			onLoadJson(parsedJSON);
		}

		return parsedJSON;
	}

	public static function parseChartData(rawJsonFilePath:String, ?parseType:Null<ParseType> = SONG):Dynamic
	{
		var data:Dynamic = null;

		switch (parseType)
		{
			case SONG | CHARACTER_MAP | EVENTS:
				data = cast Json.parse(rawJsonFilePath).song;
				data.validScore = true;
			case DATA:
				data = cast Json.parse(rawJsonFilePath).song_data;
			case METADATA:
				data = cast Json.parse(rawJsonFilePath).metadata;
		}

		return data;
	}

	private static function getDataPathOfSong(song:String, key:String, ?library:Null<String> = "", ?blankErectSuffix:Bool = false):String
	{
		if (song == null || song.length <= 0)
			return "";

		final songPath:String = Paths.formatToSongPath(song);

		var filePath:String = 'charts/${songPath}/${library}${key}';
		if (library != "difficulties/" && library != "character-maps") {
			filePath = 'charts/${songPath}/${library}${key}${FunkinSound.erectModeSuffix(blankErectSuffix)}';
		}

		#if (debug)
		FlxG.log.add('Loaded $filePath !');
		#end

		return filePath;
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
}