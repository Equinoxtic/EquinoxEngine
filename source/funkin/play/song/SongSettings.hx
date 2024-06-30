package funkin.play.song;

import funkin.sound.FunkinSound;
import haxe.Json;

#if (sys)
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

typedef SongSettingsJSON = {
	var songDisplayName:String;
	var songAlbum:String;
	var difficulties:Array<String>;
	var variations:Array<String>;
	var hasCountdown:Bool;
	var	hasNoteWiggle:Bool;
	var beatMod:Int;
}

class SongSettings
{
	public var songDisplayName:String = 'Test';
	public var songAlbum:String = 'volume1';
	public var difficuties:Array<String> = [];
	public var variations:Array<String> = [];
	public var hasCountdown:Bool = true;
	public var hasNoteWiggle:Bool = false;
	public var beatMod:Int = 4;

	/**
	 * Parses the json of the song's "metadata.json" file.
	 * @param json The JSON file to parse.
	 * @return SongSettingsJSON
	 */
	public static function parseData(json:Null<String>):SongSettingsJSON
	{
		var data:SongSettingsJSON = cast Json.parse(json).metadata;
		return data;
	}
}
