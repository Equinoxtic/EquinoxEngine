package funkin.play.song;

import funkin.play.song.Section;
import funkin.play.stage.StageData;
import haxe.Json;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

import funkin.sound.FunkinSound;

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var stage:String;

	var arrowSkin:String;
	var splashSkin:String;
	var validScore:Bool;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var events:Array<Dynamic>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var arrowSkin:String;
	public var splashSkin:String;
	public var speed:Float = 1;
	public var stage:String;
	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var gfVersion:String = 'gf';

	private static function onLoadJson(songJson:Dynamic) // Convert old charts to newest format
	{
		if(songJson.gfVersion == null)
		{
			songJson.gfVersion = songJson.player3;
			songJson.player3 = null;
		}

		if(songJson.events == null)
		{
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

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	/**
	 * Loads the song from a JSON file.
	 * @param jsonInput The song JSON.
	 * @param folder The song's folder.
	 * @param isEventFile If the song is an ``events.json``
	 * @param isMappedAnimJson If the song is a character's mapped animations. [``picospeaker.json``]
	 * @return SwagSong
	 */
	public static function loadFromJson(jsonInput:String, ?folder:String, ?isEventFile:Null<Bool> = false, ?isMappedAnimJson:Null<Bool> = false):SwagSong
	{
		var rawJson = null;

		var formattedFolder:String = Paths.formatToSongPath(folder);

		var songPath:String = 'charts/${formattedFolder}/difficulties/${jsonInput}';
		var eventsPath:String = 'charts/${formattedFolder}/events/events${FunkinSound.erectModeSuffix(false)}';
		var mappedAnimsPath:String = 'charts/${formattedFolder}/character-maps/${jsonInput}';

		/**
		 * Event JSONs check.
		 */
		if (isEventFile != null || !isEventFile) {
			if (isEventFile) {
				if (FileUtil.jsonExists(eventsPath)) {
					songPath = eventsPath;
				}
			}
		}

		/**
		 * Mapped character animations (Like 'picospeaker') JSONs check.
		 */
		if (isMappedAnimJson != null || !isMappedAnimJson) {
			if (isMappedAnimJson) {
				if (FileUtil.jsonExists(mappedAnimsPath)) {
					songPath = mappedAnimsPath;
				}
			}
		}

		#if MODS_ALLOWED
		var moddyFile:String = Paths.modsJson(songPath);
		if(FileSystem.exists(moddyFile)) {
			rawJson = File.getContent(moddyFile).trim();
		}
		#end

		if (rawJson == null) {
			rawJson = FileUtil.getContentOfFile(Paths.json(songPath)).trim();
		}

		while (!rawJson.endsWith("}")) {
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		var songJson:Dynamic = parseJSONshit(rawJson);
		if(jsonInput != 'events') StageData.loadDirectory(songJson);
		onLoadJson(songJson);
		return songJson;
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}
}
