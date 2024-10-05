package funkin.menus.editors.charteditor;

import flixel.FlxBasic;
import flixel.FlxObject;
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

	public static var zoomAmount:Float = 1.0;

	public static var songDataMap:Map<String, Dynamic> = [];

	public static var CURRENT_SONG:SwagSong = null;

	// private static var GRID_BACKGROUND:FlxSprite;
	public static var GRID_SIZE:Int = 40;

	public static function updatePlayerIcons(leftIcon:HealthIcon, rightIcon:HealthIcon, ?currentSection:Int):Void
	{
		if (CURRENT_SONG == null) {
			return;
		}

		var healthIconP1:String = _loadHealthIconFromCharacter(CURRENT_SONG.player1);
		var healthIconP2:String = _loadHealthIconFromCharacter(CURRENT_SONG.player2);

		if (CURRENT_SONG.notes[currentSection].mustHitSection)
		{
			leftIcon.changeIcon(healthIconP1);
			rightIcon.changeIcon(healthIconP2);
			if (CURRENT_SONG.notes[currentSection].gfSection) {
				leftIcon.changeIcon('gf');
			}
		}
		else
		{
			leftIcon.changeIcon(healthIconP2);
			rightIcon.changeIcon(healthIconP1);
			if (CURRENT_SONG.notes[currentSection].gfSection) {
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

	public static function setupSong(currentSong:SwagSong, ?initialBeats:Int):Void
	{
		if (currentSong == null) {
			return;
		}

		CURRENT_SONG = currentSong;

		trace('Loaded Song ${CURRENT_SONG.song}');
	}

	public static function updateGridBPM(?sec:Int = 0):Void
	{
		if (CURRENT_SONG == null) {
			return;
		}

		if (CURRENT_SONG.notes[sec].changeBPM && CURRENT_SONG.notes[sec].bpm > 0)
		{
			Conductor.changeBPM(CURRENT_SONG.notes[sec].bpm);
		}
		else
		{
			var bpm:Float = CURRENT_SONG.bpm;

			for (i in 0 ... sec) {
				if (CURRENT_SONG.notes[i].changeBPM) {
					bpm = CURRENT_SONG.notes[i].bpm;
				}
			}

			Conductor.changeBPM(bpm);
		}
	}

	public static function renderNextNotes(sec:Int = 0, noteTypes:Map<Int, String>, nextRenderedNotes:FlxTypedGroup<Note>, nextRenderedSustains:FlxTypedGroup<FlxSprite>, ?yAdd:Float):Void
	{
		var beats:Float = getSectionBeats(1);

		if (sec < CURRENT_SONG.notes.length - 1)
		{
			for (i in CURRENT_SONG.notes[sec + 1].sectionNotes) {
				var note:Note = setupNoteData(i, noteTypes, sec, true, yAdd);
				note.alpha = 0.6;
				nextRenderedNotes.add(note);
				if (note.sustainLength > 0) {
					nextRenderedSustains.add(setupSustainNote(note, beats, Conductor.stepCrochet));
				}
			}
		}

		var start:Float = getSectionStartTime(1);
		var end:Float   = getSectionStartTime(2);

		for (event in CURRENT_SONG.events)
		{
			if (end > event[0] && event[0] >= start)
			{
				var eventNote:Note = setupNoteData(event, noteTypes, sec, true, yAdd);
				eventNote.alpha = 0.6;
				nextRenderedNotes.add(eventNote);
			}
		}
	}

	public static function getNoteType(noteType:Map<String, Null<Int>>, ?sectionNoteArray:Array<Dynamic>):String
	{
		var m_IntType = noteType.get(sectionNoteArray[3]);
		var m_Type:String = '' + m_IntType;

		if (m_IntType == null) {
			m_Type = '?';
		}

		return m_Type;
	}

	public static function setupNoteData(noteArray:Array<Dynamic>, noteTypes:Map<Int, String>, ?currentSection:Int, ?isNextSection:Bool, ?yAdd:Float):Note
	{
		var NOTE_INFO = noteArray[1];
		var STRUM_TIME = noteArray[0];
		var SUSTAIN:Dynamic = noteArray[2];

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
			note.eventLength = noteArray[1].length;

			if (noteArray[1].length < 2) {
				note.setEventValues(noteArray[1][0][1], noteArray[1][0][2]);
			}

			note.noteData = -1;
			NOTE_INFO = -1;
		}

		note.setGraphicSize(GRID_SIZE, GRID_SIZE);
		note.updateHitbox();
		note.x = Math.floor(NOTE_INFO * GRID_SIZE) + GRID_SIZE;

		if (isNextSection && CURRENT_SONG.notes[currentSection].mustHitSection != CURRENT_SONG.notes[currentSection + 1].mustHitSection)
		{
			if (NOTE_INFO > 3) {
				note.x -= GRID_SIZE * 4;
			} else if (SUSTAIN != null) {
				note.x += GRID_SIZE * 4;
			}
		}

		var section:Float = getSectionBeats(isNextSection ? 1 : 0, currentSection);

		note.y = _getYFromStrumNotes(STRUM_TIME - getSectionStartTime(currentSection), section, Conductor.stepCrochet, yAdd);

		if (note.y < -150) {
			note.y = -150;
		}

		return note;
	}

	public static function setupSustainNote(note:Note, beats:Float, crochet:Float):FlxSprite
	{
		var height:Int = Math.floor(FlxMath.remapToRange(note.sustainLength, 0, crochet * 16, 0, GRID_SIZE * 16 * zoomAmount) + (GRID_SIZE * zoomAmount) - GRID_SIZE / 2);
		var minHeight:Int = Std.int((GRID_SIZE * zoomAmount / 2) + GRID_SIZE / 2);

		if (height < minHeight) {
			height = minHeight;
		}

		if (height < 1) {
			height = 1;
		}

		var spr:FlxSprite = new FlxSprite(note.x + (GRID_SIZE * 0.5) - 4, note.y + GRID_SIZE / 2).makeGraphic(9, height);
		spr.alpha = Constants.NOTE_TAIL_ALPHA;
		spr.color = FlxColor.fromRGB(250, 110, 0);

		return spr;
	}

	public static function getSectionBeats(?targetSection:Int = null, ?currentSection:Int = 0):Float
	{
		if (targetSection == null) {
			targetSection = currentSection;
		}

		var v:Null<Float> = null;

		if (CURRENT_SONG.notes[targetSection] != null) {
			v = CURRENT_SONG.notes[targetSection].sectionBeats;
		}

		return (v != null ? v : 4);
	}

	public static function getSectionStartTime(?currentSection:Int = 0, ?add:Int = 0):Float
	{
		var bpm:Float = CURRENT_SONG.bpm;
		var pos:Float = 0;

		for (i in 0 ... currentSection + add)
		{
			if (CURRENT_SONG.notes[i] != null) {
				if (CURRENT_SONG.notes[i].changeBPM) {
					bpm = CURRENT_SONG.notes[i].bpm;
				}
				pos += getSectionBeats(i, currentSection) * (1000 * 60 / bpm);
			}
		}

		return pos;
	}

	public static function updateWaveform(waveformSprite:FlxSprite, currentSection:Int, height:Float, width:Float):Void
	{
		#if (desktop)
		FunkinSoundChartEditor.updateWaveformSprite(
			waveformSprite,
			GRID_SIZE,
			height,
			width
		);

		var steps:Int = Math.round(getSectionBeats(null, currentSection) * 4);
		var st:Float = getSectionStartTime(currentSection, 0);
		var et:Float = st + (Conductor.stepCrochet * steps);

		FunkinSoundChartEditor.updateWaveforms(
			st,
			et,
			GRID_SIZE,
			height
		);

		FunkinSoundChartEditor.drawWaveformData(GRID_SIZE, waveformSprite);
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

	public static function saveSong(?saveContext:SaveContext = SaveContext.CHART):Void
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
	private static function _saveJsonDataToSongByContext(json:Dynamic, fileName:String, ?saveContext:SaveContext = SaveContext.CHART):Void
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
	private static function _getFileNameByContext(?saveContext:SaveContext = SaveContext.CHART):String
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
	private static function _getYFromStrumNotes(strumTime:Float, beats:Float, ?crochet:Float, ?yAmount:Float):Float
	{
		var v:Float = strumTime / (beats * 4 * crochet);
		return GRID_SIZE * beats * 4 * zoomAmount * v + yAmount;
	}
}
