package funkin.play.song;

import haxe.Json;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

import funkin.sound.FunkinSound;

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
	 * Load a song's information/data file.
	 * @param song The song to load.
	 * @return SongDataJson
	 */
	public static function loadSongData(song:String):SongDataJson
	{
		if (song == null || song == '')
			return null;

		var j = null;

		final f:String = Paths.formatToSongPath(song);

		var p:String = 'charts/${f}/songdata/songdata${FunkinSound.erectModeSuffix(false)}';
		
		#if MODS_ALLOWED
		var m:String = Paths.modsJson(p);
		if (FileSystem.exists(m))
			j = File.getContent(m).trim();
		#end

		if (j == null)
			#if sys j = File.getContent(Paths.json(p).trim()); #else j = Assets.getText(Paths.json(p).trim()); #end

		while (!j.endsWith('}'))
			j = j.substr(0, j.length - 1);

		var sj:Dynamic = parseData(j);

		return sj;
	}

	public static function parseData(j:String):SongDataJson
	{
		var s:SongDataJson = cast Json.parse(j).song_data;
		return s;
	}
}
