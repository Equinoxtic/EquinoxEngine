package funkin.backend;

import funkin.play.song.Chart.ParseType;
import funkin.play.notes.Note.EventNote;

#if sys
import sys.FileSystem;
#end

import funkin.sound.FunkinSound;

import funkin.play.stage.StageData.StageFile;
using StringTools;

/**
 * A utility class for loading the song's data.
 */
class SongLoader
{
	/**
	 * Loads the song's data file.
	 * * [i.e. ``~/(SONG)/songdata/songdata-default.json``]
	 * @param song The string of the song to be loaded.
	 */
	public static function loadSongData(?song:Null<String>):Void
	{
		if (song != null && song != '')
		{
			final songDataPath:String = Chart.getDataPathOfSong(song, 'songdata', 'songdata');

			if (FileUtil.modFileExists(songDataPath))
			{
				PlayState.SONG_DATA = Chart.loadChartData(song, 'songdata', ParseType.DATA);
			}
			else
			{
				PlayState.SONG_DATA = _getDummySongData();
			}
		}
		else
		{
			PlayState.SONG_DATA = _getDummySongData();
		}
	}

	/**
	 * Loads the song's settings / "metadata" file.
	 * * [i.e. ``~/(SONG)/metadata.json``]
	 * @param song The string of the song to be loaded.
	 */
	public static function loadSongSettings(?song:Null<String>):Void
	{
		if (song != null && song != "")
		{
			final songSettingsPath:String = Chart.getDataPathOfSong(song, 'metadata', null);

			if (FileUtil.modFileExists(songSettingsPath))
			{
				PlayState.SONG_METADATA = Chart.loadChartData(PlayState.SONG.song, 'metadata', ParseType.METADATA);
			}
			else
			{
				PlayState.SONG_METADATA = _getDummySongSettings();
			}
		}
		else
		{
			PlayState.SONG_METADATA = _getDummySongSettings();
		}
	}

	/**
	 * Loads the song's event notes.
	 * @param song The string of the song to be loaded.
	 */
	public static function loadSongEvents(?song:Null<String>):Void
	{
		if (song == null || song == '') {
			return;
		}

		final eventsPath:String = Chart.getDataPathOfSong(song, 'events', 'events');

		if (FileUtil.modFileExists(eventsPath))
		{
			// Standardised way of loading events. (Using Chart.loadChartData(...))
			var eventsData:Array<Dynamic> = Chart.loadChartData(song, 'events', ParseType.EVENTS).events;

			// Legacy / old way of loading events.
			if (eventsData == null || eventsData.length <= 0) {
				eventsData = Song.loadFromJson('events', song, true).events;
			}

			_loadEventData(eventsData);
		}
	}

	/**
	 * Loads the girlfriend variant.
	 * @param stage The current in-game stage.
	 * @param song The current in-game song.
	 */
	public static function loadGirlfriendVariant(?stage:Null<String>, ?song:Null<String>):Void
	{
		var gf:String = PlayState.SONG.gfVersion;

		if (gf == null || gf.length < 1)
		{
			if (stage != null)
			{
				switch (stage)
				{
					case 'limo':
						gf = "gf-car";
					case 'mall' | 'mallEvil':
						gf = "gf-christmas";
					case 'school' | 'schoolEvil':
						gf = "gf-pixel";
					case 'tank':
						gf = "gf-tankmen";
					default:
						gf = "gf";
				}
			}

			if (song != null)
			{
				switch (Paths.formatToSongPath(song))
				{
					case 'stress':
						gf = "pico-speaker";
				}
			}

			PlayState.SONG.gfVersion = Std.string(gf).trim();
		}
		else
		{
			return;
		}
	}

	/**
	 * Loads the current stage of the song.
	 * @param stageData The file of the stage.
	 */
	public static function loadStageData(?stageData:Null<StageFile>):Void
	{
		// If "stageData" is null, then load a dummy JSON to prevent crashes.
		if (stageData == null) {
			stageData = _getDummyStageData();
		}

		PlayState.instance.defaultCamZoom = stageData.defaultZoom;
		PlayState.isPixelStage = stageData.isPixelStage;
		PlayState.instance.BF_X = stageData.boyfriend[0];
		PlayState.instance.BF_Y = stageData.boyfriend[1];
		PlayState.instance.GF_X = stageData.girlfriend[0];
		PlayState.instance.GF_Y = stageData.girlfriend[1];
		PlayState.instance.DAD_X = stageData.opponent[0];
		PlayState.instance.DAD_Y = stageData.opponent[1];

		if (stageData.camera_speed != null) {
			PlayState.instance.cameraSpeed = stageData.camera_speed;
		}

		PlayState.instance.boyfriendCameraOffset = stageData.camera_boyfriend;
		if (PlayState.instance.boyfriendCameraOffset == null) {
			PlayState.instance.boyfriendCameraOffset = [0, 0];
		}

		PlayState.instance.opponentCameraOffset = stageData.camera_opponent;
		if(PlayState.instance.opponentCameraOffset == null) {
			PlayState.instance.opponentCameraOffset = [0, 0];
		}

		PlayState.instance.girlfriendCameraOffset = stageData.camera_girlfriend;
		if(PlayState.instance.girlfriendCameraOffset == null) {
			PlayState.instance.girlfriendCameraOffset = [0, 0];
		}
	}

	private static function _loadEventData(data:Array<Dynamic>):Void
	{
		for (event in data)
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [
					event[0],
					event[1][i][0],
					event[1][i][1],
					event[1][i][2]
				];

				var subEvent:EventNote = {
					strumTime: newEventNote[0] + GlobalSettings.NOTE_OFFSET,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};

				subEvent.strumTime -= PlayState.instance.eventNoteEarlyTrigger(subEvent);
				PlayState.instance.eventNotes.push(subEvent);
				PlayState.instance.eventPushed(subEvent);
			}
		}
	}

	private static function _getDummySongData():Dynamic
	{
		var dummyJson = {
			artist: 'Artist',
			charter: 'Charter',
			stringExtra: 'String message'
		};

		return dummyJson;
	}

	private static function _getDummySongSettings():Dynamic
	{
		var dummyJson = {
			songDisplayName: 'Test',
			songAlbum: 'volume1',
			difficulties: ["easy", "normal", "hard"],
			variations: ["default", "erect"],
			hasCountdown: true,
			hasNoteWiggle: false,
			beatMod: 4
		};

		return dummyJson;
	}

	private static function _getDummyStageData():Dynamic
	{
		var stageData = {
			directory: "",
			defaultZoom: 0.9,
			isPixelStage: false,
			boyfriend: [770, 100],
			girlfriend: [400, 130],
			opponent: [100, 100],
			hide_girlfriend: false,
			camera_boyfriend: [0, 0],
			camera_opponent: [0, 0],
			camera_girlfriend: [0, 0],
			camera_speed: 1
		};

		return stageData;
	}
}
