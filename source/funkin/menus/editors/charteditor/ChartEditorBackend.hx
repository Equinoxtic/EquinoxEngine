package funkin.menus.editors.charteditor;

import funkin.sound.FunkinSound;
import funkin.menus.editors.ChartingState.SaveContext;
import funkin.sound.FunkinSound.FunkinSoundChartEditor;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import funkin.play.notes.Note;
import flixel.group.FlxGroup.FlxTypedGroup;
import haxe.Json;
import funkin.play.character.Character;
#if (sys)
import sys.FileSystem;
#end

import funkin.play.components.HealthIcon;
import funkin.play.song.Song.SwagSong;

using StringTools;

class ChartEditorBackend
{
	// TODO: Finish rest of the methods that are needed.

	public static var zoomAmount:Float = 2.0;

	public static var songDataMap:Map<String, Dynamic> = [];

	public static function updatePlayerIcons(SONG:Null<SwagSong>, leftIcon:Null<HealthIcon>, rightIcon:Null<HealthIcon>, ?currentSection:Int):Void
	{
		if (SONG == null) {
			return;
		}

		var healthIconP1:String = _loadHealthIconFromCharacter(SONG.player1);
		var healthIconP2:String = _loadHealthIconFromCharacter(SONG.player2);

		if (SONG.notes[currentSection].mustHitSection)
		{
			leftIcon.changeIcon(healthIconP1);
			rightIcon.changeIcon(healthIconP2);
			if (SONG.notes[currentSection].gfSection) {
				leftIcon.changeIcon('gf');
			}
		}
		else
		{
			leftIcon.changeIcon(healthIconP2);
			rightIcon.changeIcon(healthIconP1);
			if (SONG.notes[currentSection].gfSection) {
				leftIcon.changeIcon('gf');
			}
		}
	}

	public static function clearGroup(group:FlxTypedGroup<Dynamic>):Void
	{
		if (group != null && group.alive) {
			group.clear();
		}
	}

	public static function clearGroupList(groups:Array<FlxTypedGroup<Dynamic>>):Void
	{
		if (groups.length <= 0 || groups == null) {
			return;
		}

		for (group in 0 ... groups.length) {
			groups[group].clear();
		}
	}

	public static function updateGridBPM(SONG:Null<SwagSong>, ?sec:Null<Int> = 0):Void
	{
		if (SONG == null) {
			return;
		}

		if (SONG.notes[sec].changeBPM && SONG.notes[sec].bpm > 0)
		{
			Conductor.changeBPM(SONG.notes[sec].bpm);
		}
		else
		{
			var bpm:Float = SONG.bpm;

			for (i in 0 ... sec) {
				if (SONG.notes[i].changeBPM) {
					bpm = SONG.notes[i].bpm;
				}
			}

			Conductor.changeBPM(bpm);
		}
	}

	public static function updateRenderedNotes(
			SONG:Null<SwagSong>,
			?noteTypes:Null<Map<Int, String>>,
			?sec:Null<Int> = 0,
			?gridSize:Null<Int> = 40,
			?gridBG:Null<FlxSprite>,
			?renderedNotes:Null<FlxTypedGroup<Note>>,
			?renderedSustains:Null<FlxTypedGroup<FlxSprite>>
		):Void
	{
		var beats:Float = getSectionBeats(SONG, 1);

		if (sec < SONG.notes.length - 1)
		{
			for (i in SONG.notes[sec + 1].sectionNotes) {
				var note:Note = setupNoteData(
					SONG,
					i,
					noteTypes,
					gridSize,
					gridBG,
					sec,
					true
				);
				note.alpha = 0.6;
				renderedNotes.add(note);
				if (note.sustainLength > 0) {
					renderedSustains.add(setupSustainNote(
						note,
						beats,
						Conductor.stepCrochet,
						gridSize,
						zoomAmount
					));
				}
			}
		}

		var start:Float = getSectionStartTime(SONG, 1);
		var end:Float   = getSectionStartTime(SONG, 2);

		for (event in SONG.events)
		{
			if (end > event[0] && event[0] >= start)
			{
				var note:Note = setupNoteData(
					SONG,
					event,
					noteTypes,
					gridSize,
					gridBG,
					sec,
					true
				);
				note.alpha = 0.6;
				renderedNotes.add(note);
			}
		}
	}

	public static function getNoteType(noteType:Null<Map<String, Null<Int>>>, ?sectionNoteArray:Dynamic):String
	{
		var m_IntType = noteType.get(sectionNoteArray[3]);
		var m_Type:String = '' + m_IntType;

		if (m_IntType == null) {
			m_Type = '?';
		}

		return m_Type;
	}

	public static function setupNoteData(
			SONG:Null<SwagSong>,
			noteArray:Null<Array<Dynamic>>,
			?noteTypes:Null<Map<Int, String>>,
			?gridSize:Null<Int>,
			?currentGrid:Null<FlxSprite>,
			?currentSection:Null<Int>,
			?isNextSection:Null<Bool>
		):Note
	{
		if (SONG == null || noteArray == null || currentGrid == null) {
			return null;
		}

		var NOTE_INFO = noteArray[1];
		var STRUM_TIME = noteArray[0];
		var SUSTAIN:Null<Dynamic> = noteArray[2];

		var note:Note = new Note(
			STRUM_TIME,
			NOTE_INFO % 4,
			null,
			null,
			true
		);

		if (SUSTAIN != null)
		{
			/**
			 * For Regular Notes.
			 */

			if (noteTypes == null) {
				return null;
			}

			if (!Std.isOfType(noteArray[3], String)) {
				noteArray[3] = noteTypes.get(noteArray[3]);
			}

			if (noteArray.length > 3 && (noteArray[3] == null || noteArray[3].length < 1)) {
				noteArray.remove(noteArray[3]);
			}

			note.sustainLength = SUSTAIN;
			note.noteType = noteArray[3];
		}
		else
		{
			/**
			 * For Event Notes.
			 */

			note.loadGraphic(Paths.image('eventArrow'));
			note.eventName = _getEventName(noteArray[1]);

			var INDEXES = noteArray[1][0][2];

			if (noteArray[1].length < 2) {
				note.setEventValues(INDEXES, INDEXES);
			}

			note.noteData = -1;
			NOTE_INFO = -1;
		}

		note.setGraphicSize(gridSize, gridSize);
		note.updateHitbox();
		note.x = Math.floor(NOTE_INFO * gridSize) + gridSize;

		if (isNextSection && SONG.notes[currentSection].mustHitSection != SONG.notes[currentSection + 1].mustHitSection)
		{
			if (NOTE_INFO > 3) {
				note.x -= gridSize * 4;
			} else if (SUSTAIN != null) {
				note.x += gridSize * 4;
			}
		}

		var section:Float = getSectionBeats(SONG, isNextSection ? 1 : 0, currentSection);

		note.y = _getYFromStrumNotes(
			STRUM_TIME - getSectionStartTime(SONG),
			section,
			Conductor.stepCrochet,
			gridSize,
			currentGrid.y,
			zoomAmount
		);

		if (note.y < -150) {
			note.y = -150;
		}

		return note;
	}

	public static function setupSustainNote(note:Null<Note>, beats:Null<Float>, crochet:Null<Float>, gridSize:Null<Float>, ?zoomIncrement:Null<Float>):FlxSprite
	{
		var height:Int = Math.floor(FlxMath.remapToRange(note.sustainLength, 0, crochet * 16, 0, gridSize * 16 * zoomIncrement) + (gridSize * zoomIncrement) - gridSize / 2);
		var minHeight:Int = Std.int((gridSize * zoomIncrement / 2) + gridSize / 2);

		if (height < minHeight) {
			height = minHeight;
		}

		if (height < 1) {
			height = 1;
		}

		var spr:FlxSprite = new FlxSprite(note.x + (gridSize * 0.5) - 4, note.y + gridSize / 2).makeGraphic(9, height);
		spr.alpha = Constants.NOTE_TAIL_ALPHA;
		spr.color = FlxColor.fromRGB(250, 110, 0);

		return spr;
	}

	public static function getSectionBeats(SONG:Null<SwagSong>, ?targetSection:Null<Int> = null, ?currentSection:Null<Int> = 0):Float
	{
		if (targetSection == null) {
			targetSection = currentSection;
		}

		var v:Null<Float> = null;

		if (SONG.notes[targetSection] != null) {
			v = SONG.notes[targetSection].sectionBeats;
		}

		return (v != null ? v : 4);
	}

	public static function getSectionStartTime(SONG:Null<SwagSong>, ?currentSection:Null<Int> = 0, ?add:Int = 0):Float
	{
		var bpm:Float = SONG.bpm;
		var pos:Float = 0;

		for (i in 0 ... currentSection + add)
		{
			if (SONG.notes[i] != null) {
				if (SONG.notes[i].changeBPM) {
					bpm = SONG.notes[i].bpm;
				}
				pos += getSectionBeats(SONG, i, currentSection) * (1000 * 60 / bpm);
			}
		}

		return pos;
	}

	public static function updateWaveform(SONG:Null<SwagSong>, waveformSprite:Null<FlxSprite>, gridBG:Null<FlxSprite>, gridSize:Null<Int>, currentSection:Null<Int>):Void
	{
		if (SONG == null) {
			return;
		}

		#if (desktop)
		FunkinSoundChartEditor.updateWaveformSprite(
			waveformSprite,
			gridSize,
			gridBG.height,
			gridBG.width
		);

		var steps:Int = Math.round(getSectionBeats(SONG, null, currentSection) * 4);
		var st:Float = getSectionStartTime(SONG, currentSection, 0);
		var et:Float = st + (Conductor.stepCrochet * steps);

		FunkinSoundChartEditor.updateWaveforms(
			st,
			et,
			gridSize,
			gridBG.height
		);

		FunkinSoundChartEditor.drawWaveformData(gridSize, waveformSprite);
		#end
	}

	public static function initializeDataMapForSong(dataTable:Array<{key:String, value:Dynamic}>):Void
	{
		if (dataTable != null) {
			for (tdata in dataTable) {
				if (songDataMap.exists(tdata.key)) {
					return; // Prevent from setting duplicate keys in songDataMap
				}
				songDataMap.set(tdata.key, tdata.value);
				trace('Initialized Data: \"${tdata.key}\"');
			}
		}
	}

	public static function getDataFromChart(key:String):Dynamic
	{
		if (songDataMap.exists(key)) {
			return songDataMap.get(key);
		}
		return null;
	}

	public static function saveSong(?saveContext:Null<SaveContext> = SaveContext.CHART):Void
	{
		var v:Dynamic = {};

		switch (saveContext)
		{
			case CHART:
				// Create a temporary variable for the current song.
				var tempSongChart:Dynamic = songDataMap.get('song');
				// Clear the tempSongChart's events so that we can free up space in the json.
				FunkinUtil.clearArray(tempSongChart.events);
				v = tempSongChart;
			case EVENTS:
				v = songDataMap.get('song').events;
			case DATA:
				v = songDataMap.get('song_data');
			case METADATA:
				v = songDataMap.get('metadata');
		}

		_saveJsonDataToSongByContext(v, _getFileNameByContext(saveContext), saveContext);
	}

	@:noPrivateAccess
	private static function _saveJsonDataToSongByContext(json:Dynamic, fileName:String, ?saveContext:Null<SaveContext> = SaveContext.CHART):Void
	{
		if (json != null)
		{
			var f = {};

			if (saveContext != null)
			{
				switch (saveContext)
				{
					case CHART | EVENTS:
						f = { 'song': json };
					case DATA:
						f = { 'song_data': json };
					case METADATA:
						f = { 'metadata': json };
					default:
						f = { 'song': json };
				}
			}

			var m_FileName:String = '';
			if (fileName.trim() != '' && fileName != null) {
				m_FileName = fileName;
			}

			trace('Saving... [${m_FileName}.json]');

			FileUtil.saveJSON(f, '$m_FileName');
		}
	}

	@:noPrivateAccess
	private static function _getFileNameByContext(?saveContext:Null<SaveContext> = SaveContext.CHART):String
	{
		var fname:String = '';

		switch (saveContext)
		{
			case CHART:
				fname = FunkinUtil.lowerDiffString();
			case EVENTS:
				fname = 'events';
			case DATA:
				fname = 'songdata';
			case METADATA:
				fname = 'metadata';
		}

		var ret:String = fname;
		if (!saveContext.equals(CHART)) {
			ret = '$fname' + FunkinSound.erectModeSuffix(false);
		}

		return ret;
	}

	@:noPrivateAccess
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

	@:noPrivateAccess
	private static function _getEventName(_arr:Array<Dynamic>):String
	{
		var r:String = '';
		var added:Bool = false;
		for (i in 0 ... _arr.length) {
			if (added) {
				r += ', ';
			}
			r += _arr[i][0];
			added = true;
		}
		return r;
	}

	@:noPrivateAccess
	private static function _getYFromStrumNotes(strumTime:Null<Float>, beats:Null<Float>, crochet:Null<Float>, gridSize:Null<Int>, gridY:Null<Float>, zoomIncrement:Null<Float>):Float {
		var v:Float = strumTime / (beats * 4 * crochet);
		return gridSize * beats * 4 * zoomIncrement * v + gridY;
	}
}
