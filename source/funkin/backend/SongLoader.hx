package funkin.backend;

import funkin.play.notes.Note.EventNote;
import openfl.utils.Assets as OpenFlAssets;

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
	static function getDummySongData():Dynamic
	{
		var dummyJson = {
			artist: 'Artist',
			charter: 'Charter',
			stringExtra: 'String message'
		};

		return dummyJson;
	}

	static function getDummySongSettings():Dynamic
	{
		var dummyJson = {
			songDisplayName: 'Test',
			difficulties: ["easy", "normal", "hard"],
			variations: ["default", "erect"],
			hasCountdown: true,
			hasNoteWiggle: false,
			beatMod: 4
		};

		return dummyJson;
	}

	static function getDummyStageData():Dynamic
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

	/**
	 * Loads the song's data file.
	 * * [i.e. ``~/(SONG)/songdata/songdata-default.json``]
	 * @param song The string of the song to be loaded.
	 */
	public static function loadSongData(?song:Null<String>):Void
	{
		if (song != null && song != '')
		{
			final songDataPath:String = 'charts/${Paths.formatToSongPath(song)}/songdata/songdata${FunkinSound.erectModeSuffix(false)}';

			#if MODS_ALLOWED
			if (sys.FileSystem.exists(Paths.modsJson(songDataPath)) || sys.FileSystem.exists(Paths.json(songDataPath)))
			#else
			if (OpenFlAssets.exists(Paths.json(songDataPath)))
			#end
			{
				PlayState.SONG_DATA = SongData.loadSongData(song);
			}
			else
			{
				PlayState.SONG_DATA = getDummySongData();
			}
		}
		else
		{
			PlayState.SONG_DATA = getDummySongData();
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
			final songSettingsPath:String = 'charts/${Paths.formatToSongPath(song)}/metadata';

			#if (MODS_ALLOWED)
			if (sys.FileSystem.exists(Paths.modsJson(songSettingsPath)) || sys.FileSystem.exists(Paths.json(songSettingsPath)))
			#else
			if (OpenFlAssets.exists(Paths.json(songsongSettingsPath)))
			#end
			{
				PlayState.SONG_METADATA = SongSettings.loadSongSettings(song);
			}
			else
			{
				PlayState.SONG_METADATA = getDummySongSettings();
			}
		}
		else
		{
			PlayState.SONG_METADATA = getDummySongSettings();
		}
	}

	/**
	 * Loads the song's event notes.
	 * @param song The string of the song to be loaded.
	 */
	public static function loadSongEvents(?song:Null<String>):Void
	{
		if (song == null || song == '') return;

		final eventsPath = 'charts/${song}/events/events${FunkinSound.erectModeSuffix(false)}';

		var file:String = Paths.json(eventsPath);
		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modsJson(eventsPath)) || FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', song, true).events;

			for (event in eventsData)
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
						strumTime: newEventNote[0] + Preferences.noteOffset,
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
	}

	public static function loadGirlfriendVariant(?stage:Null<String>, ?song:Null<String>):Void
	{
		var gf:String = PlayState.SONG.gfVersion;

		if (gf == null || gf.length < 1)
		{
			if (stage != null)
			{
				switch (stage)
				{
					case 'limo': gf = "gf-car"; 
					case 'mall' | 'mallEvil': gf = "gf-christmas";
					case 'school' | 'schoolEvil': gf = "gf-pixel";
					case 'tank': gf = "gf-tankmen";
					default: gf = "gf";
				}
			}

			if (song != null)
			{
				switch (Paths.formatToSongPath(song))
				{
					case 'stress': gf = "pico-speaker";
				}
			}

			PlayState.SONG.gfVersion = Std.string(gf).trim();
		}
		else
		{
			PlayState.SONG.gfVersion = "gf";
		}
	}

	/**
	 * Loads the current stage of the song.
	 * @param stageData The file of the stage.
	 */
	public static function loadStageData(?stageData:Null<StageFile>):Void
	{
		// If "stageData" is null, then load a dummy JSON to prevent crashes.
		if (stageData == null)
		{
			stageData = getDummyStageData();
		}

		PlayState.instance.defaultCamZoom = stageData.defaultZoom;
		PlayState.isPixelStage = stageData.isPixelStage;
		PlayState.instance.BF_X = stageData.boyfriend[0];
		PlayState.instance.BF_Y = stageData.boyfriend[1];
		PlayState.instance.GF_X = stageData.girlfriend[0];
		PlayState.instance.GF_Y = stageData.girlfriend[1];
		PlayState.instance.DAD_X = stageData.opponent[0];
		PlayState.instance.DAD_Y = stageData.opponent[1];

		if (stageData.camera_speed != null)
			PlayState.instance.cameraSpeed = stageData.camera_speed;

		PlayState.instance.boyfriendCameraOffset = stageData.camera_boyfriend;
		if (PlayState.instance.boyfriendCameraOffset == null)
			PlayState.instance.boyfriendCameraOffset = [0, 0];

		PlayState.instance.opponentCameraOffset = stageData.camera_opponent;
		if(PlayState.instance.opponentCameraOffset == null)
			PlayState.instance.opponentCameraOffset = [0, 0];

		PlayState.instance.girlfriendCameraOffset = stageData.camera_girlfriend;
		if(PlayState.instance.girlfriendCameraOffset == null)
			PlayState.instance.girlfriendCameraOffset = [0, 0];
	}
}
