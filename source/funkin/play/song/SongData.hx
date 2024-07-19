package funkin.play.song;

import haxe.Json;

using StringTools;

typedef SongDataJson = {
	var artist:String;
	var charter:String;
	var stringExtra:String;
}

class SongData
{
	public var artist:String;
	public var charter:String;
	public var stringExtra:String;

	/**
	 * Parses the json of the song's "songdata.json" file.
	 * @param j The JSON file to parse.
	 * @return SongDataJson
	 */
	public static function parseData(j:String):SongDataJson
	{
		var s:SongDataJson = cast Json.parse(j).song_data;
		return s;
	}
}
