package funkin.menus.editors;

import funkin.menus.editors.charteditor.ChartEditorBackend;
import funkin.ui.editor.EditorTabMenu;
import funkin.play.song.Chart.ParseType;
import funkin.play.song.SongSettings.SongSettingsJSON;
#if desktop
import funkin.api.discord.Discord.DiscordClient;
#end
import flash.geom.Rectangle;
import haxe.Json;
import haxe.format.JsonParser;
import haxe.io.Bytes;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUISlider;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import lime.media.AudioBuffer;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.Assets as OpenFlAssets;
import openfl.utils.ByteArray;

import funkin.ui.display.misc.AttachedFlxText;
import funkin.ui.editor.FlxUIDropDownMenuCustom;
import funkin.sound.FunkinSound;
import funkin.play.notes.StrumNote;
import funkin.play.notes.Note;
import funkin.play.components.HealthIcon;
import funkin.play.stage.StageData;
import funkin.play.character.Character;
import funkin.play.character.Character.CharacterFile;
import funkin.play.song.Conductor.BPMChangeEvent;
import funkin.play.song.Section.SwagSection;
import funkin.play.song.Song.SwagSong;
import funkin.play.song.SongData;
import funkin.sound.FunkinSound.FunkinSoundChartEditor;

#if sys
import flash.media.Sound;
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

enum SaveContext
{
	CHART;
	EVENTS;
	DATA;
	METADATA;
}

@:access(flixel.system.FlxSound._sound)
@:access(openfl.media.Sound.__buffer)

class ChartingState extends MusicBeatState
{
	public static var noteTypeList:Array<String> = //Used for backwards compatibility with 0.1 - 0.3.2 charts, though, you should add your hardcoded custom note types here too.
	[
		'',
		'Alt Animation',
		'Hey!',
		'Hurt Note',
		'GF Sing',
		'No Animation'
	];

	private var noteTypeIntMap:Map<Int, String> = new Map<Int, String>();
	private var noteTypeMap:Map<String, Null<Int>> = new Map<String, Null<Int>>();

	public var ignoreWarnings = false;

	var undos = [];
	var redos = [];

	var eventStuff:Array<Dynamic> =
	[
		[
			'',
			"Nothing. Yep, that's right."
		],

		[
			'Dadbattle Spotlight',
			"Used in Dad Battle,\nValue 1: 0/1 = ON/OFF,\n2 = Target Dad\n3 = Target BF"
		],

		[
			'Cinematic Border',
			"Adds a cinematic border to the playfield.\n\nVALUE 1: Amount of zoom and time it takes for\nthe border to appear.\n[DEFAULT: 0.5, 0.35].\n\nVALUE 2: The ease of the border\'s tween.\n[DEFAULT: sineInOut]"
		],

		[
			'Grayscale Effect',
			"Creates a Grayscale effect on the screen. (Tweened)\nVALUE 1: Strength, Tween Duration, Delay.\n[DEFAULT: 0.0, 1.0, 0.0]\nVALUE 2: The ease of the tween.\n[DEFAULT: sineInOut]"
		],

		[
			'Set Default Camera Zoom',
			"VALUE 1: How much it should zoom.\n[DEFAULT: 0.1]\n\nVALUE 2: Multiply it by?\n[DEFAULT: 1.0]"
		],

		[
			'Instant Camera Zoom',
			"A more instantaneous camera zoom with no\ncap to the zoom amount.\nValue 1: Camera zoom add (Default: 0.015)\nValue2: HUD zoom add (Default: 0.03)"
		],

		[
			'Tween Camera Angle',
			"Tween the camera's angle.\n\nVALUE 1: The angle, the duration, and\nthe delay of the tween.\n[DEFAULT: 0.0, 1.0, 0.0]\n\nVALUE 2: The ease of the tween.\n[DEFAULT: cubeOut]"
		],

		[
			'Camera Flash',
			"VALUE 1: The strength, duration, and delay\nof the flash.\n[DEFAULT: 1.0, 0.8, 0.0]\n\nVALUE 2: The ease of the flash.\n[DEFAULT: linear]"
		],

		[
			'Hey!',
			"Plays the \"Hey!\" animation from Bopeebo,\nValue 1: BF = Only Boyfriend, GF = Only Girlfriend,\nSomething else = Both.\nValue 2: Custom animation duration,\nleave it blank for 0.6s"
		],

		[
			'Set GF Speed',
			"Sets GF head bopping speed,\nValue 1: 1 = Normal speed,\n2 = 1/2 speed, 4 = 1/4 speed etc.\nUsed on Fresh during the beatbox parts.\n\nWarning: Value must be integer!"
		],

		[
			'Philly Glow',
			"Exclusive to Week 3\nValue 1: 0/1/2 = OFF/ON/Reset Gradient\n \nNo, i won't add it to other weeks."
		],

		[
			'Kill Henchmen',
			"For Mom's songs, don't use this please, i love them :("
		],

		[
			'Add Camera Zoom',
			"Used on MILF on that one \"hard\" part\nValue 1: Camera zoom add (Default: 0.015)\nValue 2: UI zoom add (Default: 0.03)\nLeave the values blank if you want to use Default."
		],

		[
			'BG Freaks Expression',
			"Should be used only in \"school\" Stage!"
		],

		[
			'Trigger BG Ghouls',
			"Should be used only in \"schoolEvil\" Stage!"
		],

		[
			'Play Animation',
			"Plays an animation on a Character,\nonce the animation is completed,\nthe animation changes to Idle\n\nValue 1: Animation to play.\nValue 2: Character (Dad, BF, GF)"
		],

		[
			'Camera Follow Pos',
			"Value 1: X\nValue 2: Y\n\nThe camera won't change the follow point\nafter using this, for getting it back\nto normal, leave both values blank."
		],

		[
			'Alt Idle Animation',
			"Sets a specified suffix after the idle animation name.\nYou can use this to trigger 'idle-alt' if you set\nValue 2 to -alt\n\nValue 1: Character to set (Dad, BF or GF)\nValue 2: New suffix (Leave it blank to disable)"
		],

		[
			'Screen Shake',
			"Value 1: Camera shake\nValue 2: HUD shake\n\nEvery value works as the following example: \"1, 0.05\".\nThe first number (1) is the duration.\nThe second number (0.05) is the intensity."
		],

		[
			'Change Character',
			"Value 1: Character to change (Dad, BF, GF)\nValue 2: New character's name"
		],

		[
			'Change Scroll Speed',
			"Value 1: Scroll Speed Multiplier (1 is default)\nValue 2: Time it takes to change fully in seconds."
		],

		[
			'Change Beat Modulo',
			"VALUE 1: The value of the new Beat Modulo.\nVALUE 2: Leave blank or take notes."
		],

		[
			'Set Property',
			"Value 1: Variable name\nValue 2: New value"
		],
	];

	var _file:FileReference;

	// Tab menus for the song tabs.
	private var songTabMenu:EditorTabMenu;
	private var songDataTabMenu:EditorTabMenu;

	public static var goToPlayState:Bool = false;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	public static var curSec:Int = 0;
	public static var lastSection:Int = 0;
	private static var lastSong:String = '';

	var bpmTxt:FlxText;

	var camPos:FlxObject;
	var strumLine:FlxSprite;
	var quant:AttachedSprite;
	var strumLineNotes:FlxTypedGroup<StrumNote>;
	var curSong:String = 'Test';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;

	var highlight:FlxSprite;

	public static var GRID_SIZE:Int = 40;
	var CAM_OFFSET:Int = 360;

	var dummyArrow:FlxSprite;

	var curRenderedSustains:FlxTypedGroup<FlxSprite>;
	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedNoteType:FlxTypedGroup<FlxText>;

	var nextRenderedSustains:FlxTypedGroup<FlxSprite>;
	var nextRenderedNotes:FlxTypedGroup<Note>;

	var gridBG:FlxSprite;
	var nextGridBG:FlxSprite;

	var daquantspot = 0;
	var curEventSelected:Int = 0;
	var curUndoIndex = 0;
	var curRedoIndex = 0;

	var _song:SwagSong;
	var _song_data:SongDataJson;
	var _metadata:SongSettingsJSON;

	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic> = null;

	var tempBpm:Float = 0;
	var tempOffset:Float = 0;
	var playbackSpeed:Float = 1;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;

	var value1InputText:FlxUIInputText;
	var value2InputText:FlxUIInputText;
	var currentSongName:String;

	var zoomTxt:FlxText;

	var playVocals:Bool = true;

	var zoomList:Array<Float> = [
		0.25,
		0.5,
		1,
		2,
		3,
		4,
		6,
		8,
		12,
		16,
		24
	];

	var curZoom:Int = 2;

	private var blockPressWhileTypingOn:Array<FlxUIInputText> = [];
	private var blockPressWhileTypingOnStepper:Array<FlxUINumericStepper> = [];
	private var blockPressWhileScrolling:Array<FlxUIDropDownMenuCustom> = [];

	var waveformSprite:FlxSprite;
	var gridLayer:FlxTypedGroup<FlxSprite>;

	public static var quantization:Int = 16;
	public static var curQuant = 3;

	public var quantizations:Array<Int> = [
		4,     // x4
		8,     // x8
		12,    // x12
		16,    // x16
		20,    // x20
		24,    // x24
		32,    // x32
		48,    // x48
		64,    // x64
		96,    // x96
		192    // x192
	];

	public static var vortex:Bool = false;
	public var mouseQuant:Bool = false;

	override function create():Void
	{
		if (PlayState.SONG != null)
		{
			_song = PlayState.SONG;
		}
		else
		{
			FunkinUtil.difficulties = FunkinUtil.defaultDifficulties.copy();

			_song = {
				song: 'Test',
				notes: [],
				events: [],
				bpm: 150.0,
				needsVoices: true,
				arrowSkin: '',
				splashSkin: 'noteSplashes',//idk it would crash if i didn't
				player1: 'bf',
				player2: 'dad',
				gfVersion: 'gf',
				speed: 1,
				stage: 'stage',
				validScore: false
			};

			addSection();

			PlayState.SONG = _song;
		}

		if (PlayState.SONG_DATA != null)
		{
			_song_data = PlayState.SONG_DATA;
		}
		else
		{
			_song_data = {
				artist: 'Artist',
				charter: 'Person',
				stringExtra: 'Test'
			};

			PlayState.SONG_DATA = _song_data;
		}

		if (PlayState.SONG_METADATA != null)
		{
			_metadata = PlayState.SONG_METADATA;
		}
		else
		{
			_metadata = {
				songDisplayName: 'Test',
				songAlbum: 'volume1',
				difficulties: ["easy", "normal", "hard"],
				variations: ["default", "erect"],
				hasCountdown: true,
				hasNoteWiggle: false,
				beatMod: 4
			};

			PlayState.SONG_METADATA = _metadata;
		}

		ChartEditorBackend.setupSong(_song);

		ChartEditorBackend.initializeDataMapForSong([
			{ key: 'song',      value: _song      },
			{ key: 'song_data', value: _song_data },
			{ key: 'metadata',  value: _metadata  },
		]);

		FlxG.mouse.visible = true;

		#if desktop
		DiscordClient.changePresence("Chart Editor", StringTools.replace(_song.song, '-', ' '));
		#end

		vortex = FlxG.save.data.chart_vortex;
		ignoreWarnings = FlxG.save.data.ignoreWarnings;
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set();
		bg.color = 0xFF222222;
		add(bg);

		gridLayer = new FlxTypedGroup<FlxSprite>();
		add(gridLayer);

		waveformSprite = new FlxSprite(GRID_SIZE, 0).makeGraphic(FlxG.width, FlxG.height, 0x00FFFFFF);
		add(waveformSprite);

		// Player/Boyfriend icon
		leftIcon = new HealthIcon('bf');
		leftIcon.scrollFactor.set(1, 1);
		leftIcon.setGraphicSize(0, 45);

		// Opponent/Dad icon
		rightIcon = new HealthIcon('dad');
		rightIcon.scrollFactor.set(1, 1);
		rightIcon.setGraphicSize(0, 45);

		// Event icon
		var eventIcon:FlxSprite = new FlxSprite(-GRID_SIZE - 5, -90).loadGraphic(Paths.image('eventArrow'));
		eventIcon.scrollFactor.set(1, 1);
		eventIcon.setGraphicSize(30, 30);

		add(eventIcon);
		add(leftIcon);
		add(rightIcon);

		leftIcon.setPosition(GRID_SIZE + 10, -100);
		rightIcon.setPosition(GRID_SIZE * 5.2, -100);

		curRenderedSustains = new FlxTypedGroup<FlxSprite>();
		curRenderedNotes = new FlxTypedGroup<Note>();

		curRenderedNoteType = new FlxTypedGroup<FlxText>();

		nextRenderedSustains = new FlxTypedGroup<FlxSprite>();
		nextRenderedNotes = new FlxTypedGroup<Note>();

		if (curSec >= _song.notes.length) {
			curSec = _song.notes.length - 1;
		}

		tempBpm = _song.bpm;

		addSection();

		currentSongName = Paths.formatToSongPath(_song.song);
		loadSong();

		reloadGridLayer();

		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		bpmTxt = new FlxText(1000, 50, 0, "", 16);
		bpmTxt.setFormat(Paths.font('phantommuff.ttf'), 16, FlxColor.WHITE);
		bpmTxt.borderStyle = FlxTextBorderStyle.OUTLINE;
		bpmTxt.borderColor = FlxColor.BLACK;
		bpmTxt.borderSize = 1.75;
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(GRID_SIZE * 9), 4);
		add(strumLine);

		quant = new AttachedSprite('chart_quant','chart_quant');
		quant.animation.addByPrefix('q','chart_quant',0,false);
		quant.animation.play('q', true, false, 0);
		quant.sprTracker = strumLine;
		quant.xAdd = -32;
		quant.yAdd = 8;
		add(quant);

		strumLineNotes = new FlxTypedGroup<StrumNote>();

		for (i in 0 ... 8)
		{
			var note:StrumNote = new StrumNote(GRID_SIZE * (i+1), strumLine.y, i % 4, 0);
			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
			note.updateHitbox();
			note.playAnim('static', true);
			strumLineNotes.add(note);
			note.scrollFactor.set(1, 1);
		}

		add(strumLineNotes);

		camPos = new FlxObject(0, 0, 1, 1);
		camPos.setPosition(strumLine.x + CAM_OFFSET, strumLine.y);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		songTabMenu = new EditorTabMenu(640 + GRID_SIZE / 2, 25, {
			tabs: [
				{ name: "Song",     label: 'Song'     },
				{ name: "Section",  label: 'Section'  },
				{ name: "Note",     label: 'Note'     },
				{ name: "Events",   label: 'Events'   },
				{ name: "Charting", label: 'Charting' }
			],
			width: 300, height: 400
		});

		songDataTabMenu = new EditorTabMenu(15, 30, {
			tabs: [
				{ name: "Info",     label: 'Info'     },
				{ name: "Settings", label: 'Settings' }
			],
			width: 275, height: 325
		});

		var TEXT_LIST:TextList = new TextList(songTabMenu.x, songTabMenu.y + songTabMenu.height + 8, [
			"W/S or Mouse Wheel - Change Conductor's strum time",
			"A/D - Go to the previous/next section",
			"Left/Right - Change Snap",
			"Up/Down - Change Conductor's Strum Time with Snapping",
			"Left Bracket / Right Bracket - Change Song Playback Rate (SHIFT to go Faster)",
			"ALT + Left Bracket / Right Bracket - Reset Song Playback Rate",
			"Hold Shift to move 4x faster & enable \'Free-Snap\'",
			"Hold Control and click on an arrow to select it",
			"Z/X - Zoom in/out",
			"\n",
			"Esc - Test your chart inside the Chart Editor",
			"Enter - Play your chart normally through the game",
			"Q/E - Decrease/Increase Note Sustain Length",
			"Space - Stop/Resume song"
		]);

		TEXT_LIST.scrollFactor.set();

		add(TEXT_LIST);
		add(songTabMenu);
		add(songDataTabMenu);

		addSongUI();
		addSectionUI();
		addNoteUI();
		addEventsUI();
		addChartingUI();
		updateIcons();
		updateSongWaveform();

		add(curRenderedSustains);
		add(curRenderedNotes);
		add(curRenderedNoteType);
		add(nextRenderedSustains);
		add(nextRenderedNotes);

		if (lastSong != currentSongName) {
			changeSection();
		}

		lastSong = currentSongName;

		zoomTxt = new FlxText(10, 10, 0, "Zoom: 1 / 1", 16);
		zoomTxt.scrollFactor.set();
		add(zoomTxt);

		updateGridOfRenderedNotes();

		addInfoUI();
		addSongSettingsUI();

		FlxG.camera.follow(camPos);

		super.create();

		ChartEditorBackend.zoomAmount = zoomList[curZoom];

		playVocals = _song.needsVoices;
	}

	var check_mute_inst:FlxUICheckBox = null;
	var check_vortex:FlxUICheckBox = null;
	var check_warnings:FlxUICheckBox = null;
	var playSoundBf:FlxUICheckBox = null;
	var playSoundDad:FlxUICheckBox = null;
	var UI_songTitle:FlxUIInputText;
	var noteSkinInputText:FlxUIInputText;
	var noteSplashesInputText:FlxUIInputText;
	var stageDropDown:FlxUIDropDownMenuCustom;
	var sliderRate:FlxUISlider;

	function addSongUI():Void
	{
		UI_songTitle = new FlxUIInputText(10, 10, 70, _song.song, 8);
		blockPressWhileTypingOn.push(UI_songTitle);

		var check_voices = new FlxUICheckBox(10, 25, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		check_voices.callback = function() {
			_song.needsVoices = check_voices.checked;
		};

		var saveButton:FlxButton = new FlxButton(110, 8, "Save Song", function():Void {
			saveChartData(CHART);
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x + 90, saveButton.y, "Reload Audio", function():Void {
			currentSongName = Paths.formatToSongPath(UI_songTitle.text);
			loadSong();
			updateSongWaveform();
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", function():Void {
			openSubState(new Prompt('This action will clear current progress.\n\nProceed?', 0, function(){loadJson(_song.song.toLowerCase()); }, null,ignoreWarnings));
		});

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'Load Autosave', function():Void {
			PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
			MusicBeatState.resetState();
		});

		var loadEventJson:FlxButton = new FlxButton(loadAutosaveBtn.x, loadAutosaveBtn.y + 30, 'Load Events', function()
		{
			var songName:String = Paths.formatToSongPath(_song.song);

			var eventsPath:String = '${songName}/events/events${FunkinSound.erectModeSuffix(false)}';

			if (FileUtil.jsonExists(eventsPath)) {
				clearEvents();
				var events:SwagSong = Chart.loadChartData(songName, 'events', ParseType.EVENTS);
				_song.events = events.events;
				changeSection(curSec);
			}
		});

		var saveEvents:FlxButton = new FlxButton(110, reloadSongJson.y, 'Save Events', function ()
		{
			saveChartData(EVENTS);
		});

		var clear_events:FlxButton = new FlxButton(320, 310, 'Clear events', function()
			{
				openSubState(new Prompt('This action will clear current progress.\n\nProceed?', 0, clearEvents, null,ignoreWarnings));
			});
		clear_events.color = FlxColor.RED;
		clear_events.label.color = FlxColor.WHITE;

		var clear_notes:FlxButton = new FlxButton(320, clear_events.y + 30, 'Clear notes', function()
			{
				openSubState(new Prompt('This action will clear current progress.\n\nProceed?', 0, function(){for (sec in 0..._song.notes.length) {
					_song.notes[sec].sectionNotes = [];
				}
				updateGridOfRenderedNotes();
			}, null,ignoreWarnings));

			});
		clear_notes.color = FlxColor.RED;
		clear_notes.label.color = FlxColor.WHITE;

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 70, 1, 1, 1, 400, 3);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';
		blockPressWhileTypingOnStepper.push(stepperBPM);

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, stepperBPM.y + 35, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';
		blockPressWhileTypingOnStepper.push(stepperSpeed);

		#if MODS_ALLOWED
		var directories:Array<String> = [Paths.mods('characters/'), Paths.mods(Paths.currentModDirectory + '/characters/'), Paths.getPreloadPath('characters/')];
		for(mod in Paths.getGlobalMods())
			directories.push(Paths.mods(mod + '/characters/'));
		#else
		var directories:Array<String> = [Paths.getPreloadPath('characters/')];
		#end

		var tempMap:Map<String, Bool> = new Map<String, Bool>();
		var characters:Array<String> = FunkinUtil.coolTextFile(Paths.txt('characterList'));
		for (i in 0...characters.length) {
			tempMap.set(characters[i], true);
		}

		#if MODS_ALLOWED
		for (i in 0...directories.length) {
			var directory:String = directories[i];
			if(FileSystem.exists(directory)) {
				for (file in FileSystem.readDirectory(directory)) {
					var path = haxe.io.Path.join([directory, file]);
					if (!FileSystem.isDirectory(path) && file.endsWith('.json')) {
						var charToCheck:String = file.substr(0, file.length - 5);
						if(!charToCheck.endsWith('-dead') && !tempMap.exists(charToCheck)) {
							tempMap.set(charToCheck, true);
							characters.push(charToCheck);
						}
					}
				}
			}
		}
		#end

		var player1DropDown = new FlxUIDropDownMenuCustom(10, stepperSpeed.y + 45, FlxUIDropDownMenuCustom.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player1 = characters[Std.parseInt(character)];
			updateIcons();
		});
		player1DropDown.selectedLabel = _song.player1;
		blockPressWhileScrolling.push(player1DropDown);

		var gfVersionDropDown = new FlxUIDropDownMenuCustom(player1DropDown.x, player1DropDown.y + 40, FlxUIDropDownMenuCustom.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.gfVersion = characters[Std.parseInt(character)];
			updateIcons();
		});
		gfVersionDropDown.selectedLabel = _song.gfVersion;
		blockPressWhileScrolling.push(gfVersionDropDown);

		var player2DropDown = new FlxUIDropDownMenuCustom(player1DropDown.x, gfVersionDropDown.y + 40, FlxUIDropDownMenuCustom.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player2 = characters[Std.parseInt(character)];
			updateIcons();
		});
		player2DropDown.selectedLabel = _song.player2;
		blockPressWhileScrolling.push(player2DropDown);

		#if MODS_ALLOWED
		var directories:Array<String> = [Paths.mods('stages/'), Paths.mods(Paths.currentModDirectory + '/stages/'), Paths.getPreloadPath('stages/')];
		for(mod in Paths.getGlobalMods())
			directories.push(Paths.mods(mod + '/stages/'));
		#else
		var directories:Array<String> = [Paths.getPreloadPath('stages/')];
		#end

		tempMap.clear();

		var stageFile:Array<String> = FunkinUtil.coolTextFile(Paths.txt('stageList'));
		var stages:Array<String> = [];
		for (i in 0...stageFile.length) { //Prevent duplicates
			var stageToCheck:String = stageFile[i];
			if(!tempMap.exists(stageToCheck)) {
				stages.push(stageToCheck);
			}
			tempMap.set(stageToCheck, true);
		}

		#if MODS_ALLOWED
		for (i in 0...directories.length) {
			var directory:String = directories[i];
			if (FileSystem.exists(directory)) {
				for (file in FileSystem.readDirectory(directory)) {
					var path = haxe.io.Path.join([directory, file]);
					if (!FileSystem.isDirectory(path) && file.endsWith('.json')) {
						var stageToCheck:String = file.substr(0, file.length - 5);
						if(!tempMap.exists(stageToCheck)) {
							tempMap.set(stageToCheck, true);
							stages.push(stageToCheck);
						}
					}
				}
			}
		}
		#end

		if (stages.length < 1)
			stages.push('stage');

		stageDropDown = new FlxUIDropDownMenuCustom(player1DropDown.x + 140, player1DropDown.y, FlxUIDropDownMenuCustom.makeStrIdLabelArray(stages, true), function(character:String)
		{
			_song.stage = stages[Std.parseInt(character)];
		});
		stageDropDown.selectedLabel = _song.stage;
		blockPressWhileScrolling.push(stageDropDown);

		var skin = PlayState.SONG.arrowSkin;
		if(skin == null) skin = '';
		noteSkinInputText = new FlxUIInputText(player2DropDown.x, player2DropDown.y + 50, 150, skin, 8);
		blockPressWhileTypingOn.push(noteSkinInputText);

		noteSplashesInputText = new FlxUIInputText(noteSkinInputText.x, noteSkinInputText.y + 35, 150, _song.splashSkin, 8);
		blockPressWhileTypingOn.push(noteSplashesInputText);

		var reloadNotesButton:FlxButton = new FlxButton(noteSplashesInputText.x + 5, noteSplashesInputText.y + 20, 'Change Notes', function() {
			_song.arrowSkin = noteSkinInputText.text;
			updateGridOfRenderedNotes();
		});

		var tab_group_song = new FlxUI(null, songTabMenu);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);

		tab_group_song.add(check_voices);
		tab_group_song.add(clear_events);
		tab_group_song.add(clear_notes);
		tab_group_song.add(saveButton);
		tab_group_song.add(saveEvents);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(loadEventJson);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(reloadNotesButton);
		tab_group_song.add(noteSkinInputText);
		tab_group_song.add(noteSplashesInputText);
		tab_group_song.add(new FlxText(stepperBPM.x, stepperBPM.y - 20, 0, 'Song BPM:'));
		tab_group_song.add(new FlxText(stepperSpeed.x, stepperSpeed.y - 15, 0, 'Song Speed:'));
		tab_group_song.add(new FlxText(player2DropDown.x, player2DropDown.y - 15, 0, 'Opponent:'));
		tab_group_song.add(new FlxText(gfVersionDropDown.x, gfVersionDropDown.y - 15, 0, 'Girlfriend:'));
		tab_group_song.add(new FlxText(player1DropDown.x, player1DropDown.y - 15, 0, 'Boyfriend:'));
		tab_group_song.add(new FlxText(stageDropDown.x, stageDropDown.y - 15, 0, 'Stage:'));
		tab_group_song.add(new FlxText(noteSkinInputText.x, noteSkinInputText.y - 15, 0, 'Note Texture:'));
		tab_group_song.add(new FlxText(noteSplashesInputText.x, noteSplashesInputText.y - 15, 0, 'Note Splashes Texture:'));
		tab_group_song.add(player2DropDown);
		tab_group_song.add(gfVersionDropDown);
		tab_group_song.add(player1DropDown);
		tab_group_song.add(stageDropDown);

		songTabMenu.addGroup(tab_group_song);
	}

	var stepperBeats:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_gfSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;

	var sectionToCopy:Int = 0;
	var notesCopied:Array<Dynamic>;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, songTabMenu);
		tab_group_section.name = 'Section';

		check_mustHitSection = new FlxUICheckBox(10, 15, null, null, "Must hit section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = _song.notes[curSec].mustHitSection;

		check_gfSection = new FlxUICheckBox(10, check_mustHitSection.y + 22, null, null, "GF section", 100);
		check_gfSection.name = 'check_gf';
		check_gfSection.checked = _song.notes[curSec].gfSection;
		// _song.needsVoices = check_mustHit.checked;

		check_altAnim = new FlxUICheckBox(check_gfSection.x + 120, check_gfSection.y, null, null, "Alt Animation", 100);
		check_altAnim.checked = _song.notes[curSec].altAnim;

		stepperBeats = new FlxUINumericStepper(10, 100, 1, 4, 1, 6, 2);
		stepperBeats.value = getSectionBeats();
		stepperBeats.name = 'section_beats';
		blockPressWhileTypingOnStepper.push(stepperBeats);
		check_altAnim.name = 'check_altAnim';

		check_changeBPM = new FlxUICheckBox(10, stepperBeats.y + 30, null, null, 'Change BPM', 100);
		check_changeBPM.checked = _song.notes[curSec].changeBPM;
		check_changeBPM.name = 'check_changeBPM';

		stepperSectionBPM = new FlxUINumericStepper(10, check_changeBPM.y + 20, 1, Conductor.bpm, 0, 999, 1);
		if(check_changeBPM.checked) {
			stepperSectionBPM.value = _song.notes[curSec].bpm;
		} else {
			stepperSectionBPM.value = Conductor.bpm;
		}
		stepperSectionBPM.name = 'section_bpm';
		blockPressWhileTypingOnStepper.push(stepperSectionBPM);

		var check_eventsSec:FlxUICheckBox = null;
		var check_notesSec:FlxUICheckBox = null;
		var copyButton:FlxButton = new FlxButton(10, 190, "Copy Section", function()
		{
			notesCopied = [];
			sectionToCopy = curSec;
			for (i in 0..._song.notes[curSec].sectionNotes.length)
			{
				var note:Array<Dynamic> = _song.notes[curSec].sectionNotes[i];
				notesCopied.push(note);
			}

			var startThing:Float = sectionStartTime();
			var endThing:Float = sectionStartTime(1);
			for (event in _song.events)
			{
				var strumTime:Float = event[0];
				if(endThing > event[0] && event[0] >= startThing)
				{
					var copiedEventArray:Array<Dynamic> = [];
					for (i in 0...event[1].length)
					{
						var eventToPush:Array<Dynamic> = event[1][i];
						copiedEventArray.push([eventToPush[0], eventToPush[1], eventToPush[2]]);
					}
					notesCopied.push([strumTime, -1, copiedEventArray]);
				}
			}
		});

		var pasteButton:FlxButton = new FlxButton(copyButton.x + 100, copyButton.y, "Paste Section", function()
		{
			if(notesCopied == null || notesCopied.length < 1)
			{
				return;
			}

			var addToTime:Float = Conductor.stepCrochet * (getSectionBeats() * 4 * (curSec - sectionToCopy));
			//trace('Time to add: ' + addToTime);

			for (note in notesCopied)
			{
				var copiedNote:Array<Dynamic> = [];
				var newStrumTime:Float = note[0] + addToTime;
				if(note[1] < 0)
				{
					if(check_eventsSec.checked)
					{
						var copiedEventArray:Array<Dynamic> = [];
						for (i in 0...note[2].length)
						{
							var eventToPush:Array<Dynamic> = note[2][i];
							copiedEventArray.push([eventToPush[0], eventToPush[1], eventToPush[2]]);
						}
						_song.events.push([newStrumTime, copiedEventArray]);
					}
				}
				else
				{
					if(check_notesSec.checked)
					{
						if(note[4] != null) {
							copiedNote = [newStrumTime, note[1], note[2], note[3], note[4]];
						} else {
							copiedNote = [newStrumTime, note[1], note[2], note[3]];
						}
						_song.notes[curSec].sectionNotes.push(copiedNote);
					}
				}
			}
			updateGridOfRenderedNotes();
		});

		var clearSectionButton:FlxButton = new FlxButton(pasteButton.x + 100, pasteButton.y, "Clear", function()
		{
			if(check_notesSec.checked)
			{
				_song.notes[curSec].sectionNotes = [];
			}

			if(check_eventsSec.checked)
			{
				var i:Int = _song.events.length - 1;
				var startThing:Float = sectionStartTime();
				var endThing:Float = sectionStartTime(1);
				while(i > -1) {
					var event:Array<Dynamic> = _song.events[i];
					if(event != null && endThing > event[0] && event[0] >= startThing)
					{
						_song.events.remove(event);
					}
					--i;
				}
			}
			updateGridOfRenderedNotes();
			_updateNoteUI();
		});
		clearSectionButton.color = FlxColor.RED;
		clearSectionButton.label.color = FlxColor.WHITE;

		check_notesSec = new FlxUICheckBox(10, clearSectionButton.y + 25, null, null, "Notes", 100);
		check_notesSec.checked = true;
		check_eventsSec = new FlxUICheckBox(check_notesSec.x + 100, check_notesSec.y, null, null, "Events", 100);
		check_eventsSec.checked = true;

		var swapSection:FlxButton = new FlxButton(10, check_notesSec.y + 40, "Swap section", function()
		{
			for (i in 0..._song.notes[curSec].sectionNotes.length)
			{
				var note:Array<Dynamic> = _song.notes[curSec].sectionNotes[i];
				note[1] = (note[1] + 4) % 8;
				_song.notes[curSec].sectionNotes[i] = note;
			}
			updateGridOfRenderedNotes();
		});

		var stepperCopy:FlxUINumericStepper = null;
		var copyLastButton:FlxButton = new FlxButton(10, swapSection.y + 30, "Copy last section", function()
		{
			var value:Int = Std.int(stepperCopy.value);
			if(value == 0) return;

			var daSec = FlxMath.maxInt(curSec, value);

			for (note in _song.notes[daSec - value].sectionNotes)
			{
				var strum = note[0] + Conductor.stepCrochet * (getSectionBeats(daSec) * 4 * value);
				var copiedNote:Array<Dynamic> = [strum, note[1], note[2], note[3]];
				_song.notes[daSec].sectionNotes.push(copiedNote);
			}

			var startThing:Float = sectionStartTime(-value);
			var endThing:Float = sectionStartTime(-value + 1);

			for (event in _song.events)
			{
				var strumTime:Float = event[0];

				if (endThing > event[0] && event[0] >= startThing)
				{
					strumTime += Conductor.stepCrochet * (getSectionBeats(daSec) * 4 * value);

					var copiedEventArray:Array<Dynamic> = [];

					for (i in 0...event[1].length) {
						var eventToPush:Array<Dynamic> = event[1][i];
						copiedEventArray.push([eventToPush[0], eventToPush[1], eventToPush[2]]);
					}

					_song.events.push([strumTime, copiedEventArray]);
				}
			}

			updateGridOfRenderedNotes();
		});

		copyLastButton.setGraphicSize(80, 30);
		copyLastButton.updateHitbox();

		stepperCopy = new FlxUINumericStepper(copyLastButton.x + 100, copyLastButton.y, 1, 1, -999, 999, 0);
		blockPressWhileTypingOnStepper.push(stepperCopy);

		var duetButton:FlxButton = new FlxButton(10, copyLastButton.y + 45, "Duet Notes", function()
		{
			var duetNotes:Array<Array<Dynamic>> = [];

			for (note in _song.notes[curSec].sectionNotes)
			{
				var dummyNote = note[1];

				if (dummyNote > 3) {
					dummyNote -= 4;
				} else {
					dummyNote += 4;
				}

				var copiedNote:Array<Dynamic> = [note[0], dummyNote, note[2], note[3]];

				duetNotes.push(copiedNote);
			}

			for (i in duetNotes){
				_song.notes[curSec].sectionNotes.push(i);
			}

			updateGridOfRenderedNotes();
		});

		var mirrorButton:FlxButton = new FlxButton(duetButton.x + 100, duetButton.y, "Mirror Notes", function()
		{
			var duetNotes:Array<Array<Dynamic>> = [];
			for (note in _song.notes[curSec].sectionNotes)
			{
				var dummyNote = note[1] % 4;
				dummyNote = 3 - dummyNote;

				if (note[1] > 3) {
					dummyNote += 4;
				}

				note[1] = dummyNote;
			}

			updateGridOfRenderedNotes();
		});

		tab_group_section.add(new FlxText(stepperBeats.x, stepperBeats.y - 15, 0, 'Beats per Section:'));
		tab_group_section.add(stepperBeats);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_gfSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(pasteButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(check_notesSec);
		tab_group_section.add(check_eventsSec);
		tab_group_section.add(swapSection);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(copyLastButton);
		tab_group_section.add(duetButton);
		tab_group_section.add(mirrorButton);

		songTabMenu.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;
	var strumTimeInputText:FlxUIInputText; //I wanted to use a stepper but we can't scale these as far as i know :(
	var noteTypeDropDown:FlxUIDropDownMenuCustom;
	var currentType:Int = 0;

	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, songTabMenu);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 25, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 64);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';
		blockPressWhileTypingOnStepper.push(stepperSusLength);

		strumTimeInputText = new FlxUIInputText(10, 65, 180, "0");
		tab_group_note.add(strumTimeInputText);
		blockPressWhileTypingOn.push(strumTimeInputText);

		var key:Int = 0;
		var displayNameList:Array<String> = [];
		while (key < noteTypeList.length) {
			displayNameList.push(noteTypeList[key]);
			noteTypeMap.set(noteTypeList[key], key);
			noteTypeIntMap.set(key, noteTypeList[key]);
			key++;
		}

		#if LUA_ALLOWED
		var directories:Array<String> = [];

		#if MODS_ALLOWED
		directories.push(Paths.mods('custom_notetypes/'));
		directories.push(Paths.mods(Paths.currentModDirectory + '/custom_notetypes/'));
		for(mod in Paths.getGlobalMods())
			directories.push(Paths.mods(mod + '/custom_notetypes/'));
		#end

		for (i in 0...directories.length) {
			var directory:String =  directories[i];
			if(FileSystem.exists(directory)) {
				for (file in FileSystem.readDirectory(directory)) {
					var path = haxe.io.Path.join([directory, file]);
					if (!FileSystem.isDirectory(path) && file.endsWith('.lua')) {
						var fileToCheck:String = file.substr(0, file.length - 4);
						if(!noteTypeMap.exists(fileToCheck)) {
							displayNameList.push(fileToCheck);
							noteTypeMap.set(fileToCheck, key);
							noteTypeIntMap.set(key, fileToCheck);
							key++;
						}
					}
				}
			}
		}
		#end

		for (i in 1...displayNameList.length) {
			displayNameList[i] = i + '. ' + displayNameList[i];
		}

		noteTypeDropDown = new FlxUIDropDownMenuCustom(10, 105, FlxUIDropDownMenuCustom.makeStrIdLabelArray(displayNameList, true), function(character:String)
		{
			currentType = Std.parseInt(character);
			if(curSelectedNote != null && curSelectedNote[1] > -1) {
				curSelectedNote[3] = noteTypeIntMap.get(currentType);
				updateGridOfRenderedNotes();
			}
		});
		blockPressWhileScrolling.push(noteTypeDropDown);

		tab_group_note.add(new FlxText(10, 10, 0, 'Sustain length:'));
		tab_group_note.add(new FlxText(10, 50, 0, 'Strum time (in miliseconds):'));
		tab_group_note.add(new FlxText(10, 90, 0, 'Note type:'));
		tab_group_note.add(stepperSusLength);
		tab_group_note.add(strumTimeInputText);
		tab_group_note.add(noteTypeDropDown);

		songTabMenu.addGroup(tab_group_note);
	}

	var eventDropDown:FlxUIDropDownMenuCustom;
	var descText:FlxText;
	var selectedEventText:FlxText;
	function addEventsUI():Void
	{
		var tab_group_event = new FlxUI(null, songTabMenu);
		tab_group_event.name = 'Events';

		#if LUA_ALLOWED
		var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
		var directories:Array<String> = [];

		#if MODS_ALLOWED
		directories.push(Paths.mods('custom_events/'));
		directories.push(Paths.mods(Paths.currentModDirectory + '/custom_events/'));
		for(mod in Paths.getGlobalMods())
			directories.push(Paths.mods(mod + '/custom_events/'));
		#end

		for (i in 0...directories.length) {
			var directory:String =  directories[i];
			if(FileSystem.exists(directory)) {
				for (file in FileSystem.readDirectory(directory)) {
					var path = haxe.io.Path.join([directory, file]);
					if (!FileSystem.isDirectory(path) && file != 'readme.txt' && file.endsWith('.txt')) {
						var fileToCheck:String = file.substr(0, file.length - 4);
						if(!eventPushedMap.exists(fileToCheck)) {
							eventPushedMap.set(fileToCheck, true);
							eventStuff.push([fileToCheck, File.getContent(path)]);
						}
					}
				}
			}
		}
		eventPushedMap.clear();
		eventPushedMap = null;
		#end

		descText = new FlxText(20, 200, 0, eventStuff[0][0]);

		var leEvents:Array<String> = [];
		for (i in 0...eventStuff.length) {
			leEvents.push(eventStuff[i][0]);
		}

		var text:FlxText = new FlxText(20, 30, 0, "Event:");
		tab_group_event.add(text);
		eventDropDown = new FlxUIDropDownMenuCustom(20, 50, FlxUIDropDownMenuCustom.makeStrIdLabelArray(leEvents, true), function(pressed:String) {
			var selectedEvent:Int = Std.parseInt(pressed);
			descText.text = eventStuff[selectedEvent][1];
				if (curSelectedNote != null &&  eventStuff != null) {
				if (curSelectedNote != null && curSelectedNote[2] == null){
				curSelectedNote[1][curEventSelected][0] = eventStuff[selectedEvent][0];

				}
				updateGridOfRenderedNotes();
			}
		});
		blockPressWhileScrolling.push(eventDropDown);

		var text:FlxText = new FlxText(20, 90, 0, "Value 1:");
		tab_group_event.add(text);
		value1InputText = new FlxUIInputText(20, 110, 100, "");
		blockPressWhileTypingOn.push(value1InputText);

		var text:FlxText = new FlxText(20, 130, 0, "Value 2:");
		tab_group_event.add(text);
		value2InputText = new FlxUIInputText(20, 150, 100, "");
		blockPressWhileTypingOn.push(value2InputText);

		// New event buttons
		var removeButton:FlxButton = new FlxButton(eventDropDown.x + eventDropDown.width + 10, eventDropDown.y, '-', function()
		{
			if(curSelectedNote != null && curSelectedNote[2] == null) //Is event note
			{
				if(curSelectedNote[1].length < 2)
				{
					_song.events.remove(curSelectedNote);
					curSelectedNote = null;
				}
				else
				{
					curSelectedNote[1].remove(curSelectedNote[1][curEventSelected]);
				}

				var eventsGroup:Array<Dynamic>;
				--curEventSelected;
				if(curEventSelected < 0) curEventSelected = 0;
				else if(curSelectedNote != null && curEventSelected >= (eventsGroup = curSelectedNote[1]).length) curEventSelected = eventsGroup.length - 1;

				changeEventSelected();
				updateGridOfRenderedNotes();
			}
		});
		removeButton.setGraphicSize(Std.int(removeButton.height), Std.int(removeButton.height));
		removeButton.updateHitbox();
		removeButton.color = FlxColor.RED;
		removeButton.label.color = FlxColor.WHITE;
		removeButton.label.size = 12;
		setAllLabelsOffset(removeButton, -30, 0);
		tab_group_event.add(removeButton);

		var addButton:FlxButton = new FlxButton(removeButton.x + removeButton.width + 10, removeButton.y, '+', function()
		{
			if(curSelectedNote != null && curSelectedNote[2] == null) //Is event note
			{
				var eventsGroup:Array<Dynamic> = curSelectedNote[1];
				eventsGroup.push(['', '', '']);

				changeEventSelected(1);
				updateGridOfRenderedNotes();
			}
		});
		addButton.setGraphicSize(Std.int(removeButton.width), Std.int(removeButton.height));
		addButton.updateHitbox();
		addButton.color = FlxColor.GREEN;
		addButton.label.color = FlxColor.WHITE;
		addButton.label.size = 12;
		setAllLabelsOffset(addButton, -30, 0);
		tab_group_event.add(addButton);

		var moveLeftButton:FlxButton = new FlxButton(addButton.x + addButton.width + 20, addButton.y, '<', function()
		{
			changeEventSelected(-1);
		});
		moveLeftButton.setGraphicSize(Std.int(addButton.width), Std.int(addButton.height));
		moveLeftButton.updateHitbox();
		moveLeftButton.label.size = 12;
		setAllLabelsOffset(moveLeftButton, -30, 0);
		tab_group_event.add(moveLeftButton);

		var moveRightButton:FlxButton = new FlxButton(moveLeftButton.x + moveLeftButton.width + 10, moveLeftButton.y, '>', function()
		{
			changeEventSelected(1);
		});
		moveRightButton.setGraphicSize(Std.int(moveLeftButton.width), Std.int(moveLeftButton.height));
		moveRightButton.updateHitbox();
		moveRightButton.label.size = 12;
		setAllLabelsOffset(moveRightButton, -30, 0);
		tab_group_event.add(moveRightButton);

		selectedEventText = new FlxText(addButton.x - 100, addButton.y + addButton.height + 6, (moveRightButton.x - addButton.x) + 186, 'Selected Event: None');
		selectedEventText.alignment = CENTER;
		tab_group_event.add(selectedEventText);

		tab_group_event.add(descText);
		tab_group_event.add(value1InputText);
		tab_group_event.add(value2InputText);
		tab_group_event.add(eventDropDown);

		songTabMenu.addGroup(tab_group_event);
	}

	function changeEventSelected(change:Int = 0)
	{
		if(curSelectedNote != null && curSelectedNote[2] == null) //Is event note
		{
			curEventSelected += change;
			if(curEventSelected < 0) curEventSelected = Std.int(curSelectedNote[1].length) - 1;
			else if(curEventSelected >= curSelectedNote[1].length) curEventSelected = 0;
			selectedEventText.text = 'Selected Event: ' + (curEventSelected + 1) + ' / ' + curSelectedNote[1].length;
		}
		else
		{
			curEventSelected = 0;
			selectedEventText.text = 'Selected Event: None';
		}
		_updateNoteUI();
	}

	function setAllLabelsOffset(button:FlxButton, x:Float, y:Float)
	{
		for (point in button.labelOffsets)
		{
			point.set(x, y);
		}
	}

	var metronome:FlxUICheckBox;
	var mouseScrollingQuant:FlxUICheckBox;
	var metronomeStepper:FlxUINumericStepper;
	var metronomeOffsetStepper:FlxUINumericStepper;
	var disableAutoScrolling:FlxUICheckBox;
	#if desktop
	var waveformUseInstrumental:FlxUICheckBox;
	var waveformUseVoicesPlayer:FlxUICheckBox;
	var waveformUseVoicesOpponent:FlxUICheckBox;
	#end
	var instVolume:FlxUINumericStepper;
	var voicesVolume:FlxUINumericStepper;
	function addChartingUI() {
		var tab_group_chart = new FlxUI(null, songTabMenu);
		tab_group_chart.name = 'Charting';

		#if desktop
		if (FlxG.save.data.chart_waveformInst == null)
			FlxG.save.data.chart_waveformInst = false;

		if (FlxG.save.data.chart_waveformVoicesPlayer == null)
			FlxG.save.data.chart_waveformVoicesPlayer = false;

		if (FlxG.save.data.chart_waveformVoicesOpponent == null)
			FlxG.save.data.chart_waveformVoicesOpponent = false;

		waveformUseInstrumental = new FlxUICheckBox(10, 90, null, null, "Instrumental Waveform", 100);
		waveformUseInstrumental.checked = FlxG.save.data.chart_waveformInst;
		waveformUseInstrumental.callback = function()
		{
			FlxG.save.data.chart_waveformVoicesPlayer = false;
			FlxG.save.data.chart_waveformVoicesOpponent = false;
			FlxG.save.data.chart_waveformInst = waveformUseInstrumental.checked;
			updateSongWaveform();
		};

		waveformUseVoicesPlayer = new FlxUICheckBox(waveformUseInstrumental.x + 120, waveformUseInstrumental.y, null, null, "Waveform Voices (PLAYER)", 100);
		waveformUseVoicesPlayer.checked = FlxG.save.data.chart_waveformVoicesPlayer;
		waveformUseVoicesPlayer.callback = function()
		{
			waveformUseInstrumental.checked = false;
			FlxG.save.data.chart_waveformInst = false;
			FlxG.save.data.chart_waveformVoicesPlayer = waveformUseVoicesPlayer.checked;
			updateSongWaveform();
		};

		waveformUseVoicesOpponent = new FlxUICheckBox(waveformUseVoicesPlayer.x, waveformUseInstrumental.y + 30, null, null, "Waveform Voices (OPPONENT)", 100);
		waveformUseVoicesOpponent.checked = FlxG.save.data.chart_waveformVoicesOpponent;
		waveformUseVoicesOpponent.callback = function()
		{
			waveformUseInstrumental.checked = false;
			FlxG.save.data.chart_waveformInst = false;
			FlxG.save.data.chart_waveformVoicesOpponent = waveformUseVoicesOpponent.checked;
			updateSongWaveform();
		};
		#end

		check_mute_inst = new FlxUICheckBox(10, 310, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};
		mouseScrollingQuant = new FlxUICheckBox(10, 200, null, null, "Mouse Scrolling Quantization", 100);
		if (FlxG.save.data.mouseScrollingQuant == null) FlxG.save.data.mouseScrollingQuant = false;
		mouseScrollingQuant.checked = FlxG.save.data.mouseScrollingQuant;

		mouseScrollingQuant.callback = function()
		{
			FlxG.save.data.mouseScrollingQuant = mouseScrollingQuant.checked;
			mouseQuant = FlxG.save.data.mouseScrollingQuant;
		};

		check_vortex = new FlxUICheckBox(10, 160, null, null, "Vortex Editor (BETA)", 100);
		if (FlxG.save.data.chart_vortex == null) FlxG.save.data.chart_vortex = false;
		check_vortex.checked = FlxG.save.data.chart_vortex;

		check_vortex.callback = function()
		{
			FlxG.save.data.chart_vortex = check_vortex.checked;
			vortex = FlxG.save.data.chart_vortex;
			reloadGridLayer();
		};

		check_warnings = new FlxUICheckBox(10, 120, null, null, "Ignore Progress Warnings", 100);
		if (FlxG.save.data.ignoreWarnings == null) FlxG.save.data.ignoreWarnings = false;
		check_warnings.checked = FlxG.save.data.ignoreWarnings;

		check_warnings.callback = function()
		{
			FlxG.save.data.ignoreWarnings = check_warnings.checked;
			ignoreWarnings = FlxG.save.data.ignoreWarnings;
		};

		var check_mute_playervocals = new FlxUICheckBox(check_mute_inst.x + 120, check_vortex.y + 10, null, null, "Mute Vocals (PLAYER)", 100);
		check_mute_playervocals.checked = false;
		check_mute_playervocals.callback = function()
		{
			if (FunkinSoundChartEditor.vocalsPlayer != null)
			{
				var vol:Float = 1;

				if (check_mute_playervocals.checked) {
					vol = 0;
				}

				FunkinSoundChartEditor.vocalsTrackSetVolume(vol, 'player');
			}
		};

		var check_mute_opponentvocals = new FlxUICheckBox(check_mute_inst.x + 120, check_mute_playervocals.y + 30, null, null, "Mute Vocals (OPPONENT)", 100);
		check_mute_opponentvocals.checked = false;
		check_mute_opponentvocals.callback = function()
		{
			if (FunkinSoundChartEditor.vocalsOpponent != null)
			{
				var vol:Float = 1;

				if (check_mute_opponentvocals.checked) {
					vol = 0;
				}

				FunkinSoundChartEditor.vocalsTrackSetVolume(vol, 'opponent');
			}
		};

		playSoundBf = new FlxUICheckBox(check_mute_inst.x, check_mute_opponentvocals.y + 30, null, null, 'Play Sound (Boyfriend notes)', 100,
			function() {
				FlxG.save.data.chart_playSoundBf = playSoundBf.checked;
			}
		);
		if (FlxG.save.data.chart_playSoundBf == null) FlxG.save.data.chart_playSoundBf = false;
		playSoundBf.checked = FlxG.save.data.chart_playSoundBf;

		playSoundDad = new FlxUICheckBox(check_mute_inst.x + 120, playSoundBf.y, null, null, 'Play Sound (Opponent notes)', 100,
			function() {
				FlxG.save.data.chart_playSoundDad = playSoundDad.checked;
			}
		);
		if (FlxG.save.data.chart_playSoundDad == null) FlxG.save.data.chart_playSoundDad = false;
		playSoundDad.checked = FlxG.save.data.chart_playSoundDad;

		metronome = new FlxUICheckBox(10, 15, null, null, "Metronome Enabled", 100,
			function() {
				FlxG.save.data.chart_metronome = metronome.checked;
			}
		);
		if (FlxG.save.data.chart_metronome == null) FlxG.save.data.chart_metronome = false;
		metronome.checked = FlxG.save.data.chart_metronome;

		metronomeStepper = new FlxUINumericStepper(15, 55, 5, _song.bpm, 1, 1500, 1);
		metronomeOffsetStepper = new FlxUINumericStepper(metronomeStepper.x + 100, metronomeStepper.y, 25, 0, 0, 1000, 1);
		blockPressWhileTypingOnStepper.push(metronomeStepper);
		blockPressWhileTypingOnStepper.push(metronomeOffsetStepper);

		disableAutoScrolling = new FlxUICheckBox(metronome.x + 120, metronome.y, null, null, "Disable Autoscroll (Not Recommended)", 120,
			function() {
				FlxG.save.data.chart_noAutoScroll = disableAutoScrolling.checked;
			}
		);
		if (FlxG.save.data.chart_noAutoScroll == null) FlxG.save.data.chart_noAutoScroll = false;
		disableAutoScrolling.checked = FlxG.save.data.chart_noAutoScroll;

		instVolume = new FlxUINumericStepper(metronomeStepper.x, 270, 0.1, 1, 0, 1, 1);
		instVolume.value = FlxG.sound.music.volume;
		instVolume.name = 'inst_volume';
		blockPressWhileTypingOnStepper.push(instVolume);

		voicesVolume = new FlxUINumericStepper(instVolume.x + 100, instVolume.y, 0.1, 1, 0, 1, 1);
		voicesVolume.value = 1;
		voicesVolume.name = 'voices_volume';
		blockPressWhileTypingOnStepper.push(voicesVolume);

		#if !html5
		/*
		sliderRate = new FlxUISlider(this, 'playbackSpeed', 120, 120, 0.5, 3, 150, null, 5, FlxColor.WHITE, FlxColor.BLACK);
		sliderRate.nameLabel.text = 'Playback Rate';
		tab_group_chart.add(sliderRate);
		*/
		#end

		tab_group_chart.add(new FlxText(metronomeStepper.x, metronomeStepper.y - 15, 0, 'BPM:'));
		tab_group_chart.add(new FlxText(metronomeOffsetStepper.x, metronomeOffsetStepper.y - 15, 0, 'Offset (ms):'));
		tab_group_chart.add(new FlxText(instVolume.x, instVolume.y - 15, 0, 'Inst Volume'));
		tab_group_chart.add(new FlxText(voicesVolume.x, voicesVolume.y - 15, 0, 'Voices Volume'));
		tab_group_chart.add(metronome);
		tab_group_chart.add(disableAutoScrolling);
		tab_group_chart.add(metronomeStepper);
		tab_group_chart.add(metronomeOffsetStepper);
		#if desktop
		tab_group_chart.add(waveformUseInstrumental);
		tab_group_chart.add(waveformUseVoicesPlayer);
		tab_group_chart.add(waveformUseVoicesOpponent);
		#end
		tab_group_chart.add(instVolume);
		tab_group_chart.add(voicesVolume);
		tab_group_chart.add(check_mute_inst);
		tab_group_chart.add(check_mute_playervocals);
		tab_group_chart.add(check_mute_opponentvocals);
		tab_group_chart.add(check_vortex);
		tab_group_chart.add(mouseScrollingQuant);
		tab_group_chart.add(check_warnings);
		tab_group_chart.add(playSoundBf);
		tab_group_chart.add(playSoundDad);
		songTabMenu.addGroup(tab_group_chart);
	}

	var creditsInputText:FlxUIInputText;
	var charterInputText:FlxUIInputText;
	var extraStringInputText:FlxUIInputText;

	function addInfoUI():Void
	{
		var tab_group_info = new FlxUI(null, songDataTabMenu);
		tab_group_info.name = "Info";

		var songCredit = PlayState.SONG_DATA.artist;
		var songCharter = PlayState.SONG_DATA.charter;
		var songExtraText = PlayState.SONG_DATA.stringExtra;
		if (songCredit == null)
			songCredit = '';
		if (songCharter == null)
			songCharter = '';
		if (songExtraText == null)
			songExtraText = '';

		creditsInputText = new FlxUIInputText(10, 50, 200, songCredit, 8);
		blockPressWhileTypingOn.push(creditsInputText);
		charterInputText = new FlxUIInputText(creditsInputText.x, creditsInputText.y + 37, 200, songCharter, 8);
		blockPressWhileTypingOn.push(charterInputText);
		extraStringInputText = new FlxUIInputText(charterInputText.x, charterInputText.y + 37, 200, songExtraText, 8);
		blockPressWhileTypingOn.push(extraStringInputText);

		var saveButton:FlxButton = new FlxButton(charterInputText.x + 5, charterInputText.y + 65, "Save Information", function()
		{
			saveChartData(DATA);
		});

		tab_group_info.add(new FlxText(5, 5, FlxG.width, '- Song Data / Information -', 14));

		tab_group_info.add(new FlxText(creditsInputText.x, creditsInputText.y - 15, 0, 'Song Credits:'));
		tab_group_info.add(new FlxText(charterInputText.x, charterInputText.y - 15, 0, 'Song Charter:'));
		tab_group_info.add(new FlxText(extraStringInputText.x, extraStringInputText.y - 15, 0, 'Extra String:'));
		tab_group_info.add(creditsInputText);
		tab_group_info.add(charterInputText);
		tab_group_info.add(extraStringInputText);
		tab_group_info.add(saveButton);

		songDataTabMenu.addGroup(tab_group_info);
	}

	var songDisplayNameInput:FlxUIInputText;
	var albumTextInput:FlxUIInputText;
	var countdownCheckbox:FlxUICheckBox;
	var noteWiggleCheckbox:FlxUICheckBox;
	var beatModInput:FlxUINumericStepper;

	function addSongSettingsUI():Void
	{
		var tab_group_settings = new FlxUI(null, songDataTabMenu);
		tab_group_settings.name = "Settings";

		var songAlbum:String = PlayState.SONG_METADATA.songAlbum;
		var songDisplayName:String = PlayState.SONG_METADATA.songDisplayName;
		if (songDisplayName == null)
			songDisplayName = "";
		if (songAlbum == null)
			songAlbum = "";

		songDisplayNameInput = new FlxUIInputText(10, 50, 200, songDisplayName, 8);
		blockPressWhileTypingOn.push(songDisplayNameInput);

		albumTextInput = new FlxUIInputText(10, songDisplayNameInput.y + 50, 100, songAlbum, 8);
		blockPressWhileTypingOn.push(albumTextInput);

		countdownCheckbox = new FlxUICheckBox(10, albumTextInput.y + 35, null, null, "Countdown on Start");
		countdownCheckbox.checked = _metadata.hasCountdown;
		countdownCheckbox.callback = function() {
			_metadata.hasCountdown = countdownCheckbox.checked;
		};

		noteWiggleCheckbox = new FlxUICheckBox(10, countdownCheckbox.y + 40, null, null, "Note Tail Wiggles on Beat (Experimental)");
		noteWiggleCheckbox.checked = _metadata.hasNoteWiggle;
		noteWiggleCheckbox.callback = function() {
			_metadata.hasNoteWiggle = noteWiggleCheckbox.checked;
		};

		beatModInput = new FlxUINumericStepper(10, noteWiggleCheckbox.y + 50, 1, 4, 1, 24, 1);
		beatModInput.value = _metadata.beatMod;
		beatModInput.name = 'beat_mod';
		blockPressWhileTypingOnStepper.push(beatModInput);

		var saveButton:FlxButton = new FlxButton(beatModInput.x, beatModInput.y + 35, "Save Metadata", function ()
		{
			saveChartData(METADATA);
		});

		tab_group_settings.add(new FlxText(5, 5, FlxG.width, '- Song Settings -', 14));

		tab_group_settings.add(new FlxText(songDisplayNameInput.x, songDisplayNameInput.y - 15, 0, "Song Display Name:"));
		tab_group_settings.add(new FlxText(albumTextInput.x, albumTextInput.y - 15, 0, "Song Album:"));
		tab_group_settings.add(new FlxText(beatModInput.x, beatModInput.y - 15, 0, "Camera Beat Modulo (Per Beat):"));
		tab_group_settings.add(songDisplayNameInput);
		tab_group_settings.add(albumTextInput);
		tab_group_settings.add(countdownCheckbox);
		tab_group_settings.add(noteWiggleCheckbox);
		tab_group_settings.add(beatModInput);
		tab_group_settings.add(saveButton);

		songDataTabMenu.addGroup(tab_group_settings);
	}

	function loadSong():Void
	{
		FunkinSoundChartEditor.stopSongInst();

		FunkinSoundChartEditor.loadSongVocals(currentSongName);

		generateSong();

		FunkinSoundChartEditor.pauseSongInst();
		FunkinSound.setConductorSongPos(sectionStartTime());
		FunkinSoundChartEditor.setInstTime(Conductor.songPosition);
	}

	function generateSong()
	{
		FunkinSoundChartEditor.loadSongInst(currentSongName);

		if (instVolume != null) {
			FunkinSoundChartEditor.setInstVolume(instVolume.value);
		}

		if (check_mute_inst != null && check_mute_inst.checked) {
			FunkinSoundChartEditor.setInstVolume(0);
		}

		FlxG.sound.music.onComplete = function()
		{
			FunkinSoundChartEditor.resetSongInst();

			FunkinSoundChartEditor.resetSongVocals();

			changeSection();
			curSec = 0;
			updateGridOfRenderedNotes();
			_updateSectionUI();

			FunkinSoundChartEditor.playSongVocals();
		};
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(songTabMenu.x + 20, songTabMenu.y + 20, 0);
		bullshitUI.add(title);
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;

			var label = check.getLabel().text;

			switch (label)
			{
				case 'Must hit section':
					_song.notes[curSec].mustHitSection = check.checked;

					updateGridOfRenderedNotes();
					updateIcons();

				case 'GF section':
					_song.notes[curSec].gfSection = check.checked;

					updateGridOfRenderedNotes();
					updateIcons();

				case 'Change BPM':
					_song.notes[curSec].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				case "Alt Animation":
					_song.notes[curSec].altAnim = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;

			FlxG.log.add(wname);

			switch(wname)
			{
				case 'section_beats':
					_song.notes[curSec].sectionBeats = nums.value;
					reloadGridLayer();

				case 'song_speed':
					_song.speed = nums.value;

				case 'song_bpm':
					tempBpm = nums.value;
					Conductor.mapBPMChanges(_song);
					Conductor.changeBPM(nums.value);

				case 'song_offset':
					tempOffset = nums.value;

				case 'note_susLength':
					if (curSelectedNote != null && curSelectedNote[2] != null) {
						curSelectedNote[2] = nums.value;
						updateGridOfRenderedNotes();
					}

				case 'section_bpm':
					_song.notes[curSec].bpm = nums.value;
					updateGridOfRenderedNotes();

				case 'inst_volume':
					FlxG.sound.music.volume = nums.value;

				case 'voices_volume':
					FunkinSoundChartEditor.setVocalsVolume(nums.value);

				case 'beat_mod':
					_metadata.beatMod = Std.int(nums.value);
			}
		}
		else if (id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText))
		{
			/*
			if (sender == noteSplashesInputText) {
				_song.splashSkin = noteSplashesInputText.text;
			} else if (sender == creditsInputText) {
				_song_data.artist = creditsInputText.text;
			} else if (sender == charterInputText) {
				_song_data.charter = charterInputText.text;
			} else if (sender == extraStringInputText) {
				_song_data.stringExtra = extraStringInputText.text;
			} else if (sender == songDisplayNameInput) {
				_metadata.songDisplayName = songDisplayNameInput.text;
			} else if (sender == albumTextInput) {
				_metadata.songAlbum = albumTextInput.text;
			}
			else if (curSelectedNote != null)
			{
				if (sender == value1InputText) {
					if(curSelectedNote[1][curEventSelected] != null)
					{
						curSelectedNote[1][curEventSelected][1] = value1InputText.text;
						updateGridOfRenderedNotes();
					}
				} else if (sender == value2InputText) {
					if(curSelectedNote[1][curEventSelected] != null) {
						curSelectedNote[1][curEventSelected][2] = value2InputText.text;
						updateGridOfRenderedNotes();
					}
				} else if (sender == strumTimeInputText) {
					var value:Float = Std.parseFloat(strumTimeInputText.text);
					if(Math.isNaN(value)) value = 0;
					curSelectedNote[0] = value;
					updateGridOfRenderedNotes();
				}
			}
			*/

			switch (sender)
			{
				case noteSplashesInputText:
					_song.splashSkin = noteSplashesInputText.text;

				case creditsInputText:
					_song_data.artist = creditsInputText.text;

				case charterInputText:
					_song_data.charter = charterInputText.text;

				case extraStringInputText:
					_song_data.stringExtra = extraStringInputText.text;

				case songDisplayNameInput:
					_metadata.songDisplayName = songDisplayNameInput.text;

				case albumTextInput:
					_metadata.songAlbum = albumTextInput.text;
			}

			if (curSelectedNote != null) {
				/*
				if (sender == value1InputText) {
					if(curSelectedNote[1][curEventSelected] != null)
					{
						curSelectedNote[1][curEventSelected][1] = value1InputText.text;
						updateGridOfRenderedNotes();
					}
				} else if (sender == value2InputText) {
					if(curSelectedNote[1][curEventSelected] != null) {
						curSelectedNote[1][curEventSelected][2] = value2InputText.text;
						updateGridOfRenderedNotes();
					}
				} else if (sender == strumTimeInputText) {
					var value:Float = Std.parseFloat(strumTimeInputText.text);
					if(Math.isNaN(value)) value = 0;
					curSelectedNote[0] = value;
					updateGridOfRenderedNotes();
				}
				*/

				switch(sender)
				{
					case value1InputText:
						curSelectedNote[1][curEventSelected][1] = value1InputText.text;
						updateGridOfRenderedNotes();

					case value2InputText:
						curSelectedNote[1][curEventSelected][2] = value2InputText.text;
						updateGridOfRenderedNotes();

					case strumTimeInputText:
						var value:Float = Std.parseFloat(strumTimeInputText.text);

						if (Math.isNaN(value)) {
							value = 0;
						}

						curSelectedNote[0] = value;
						updateGridOfRenderedNotes();
				}
			}
		}
		else if (id == FlxUISlider.CHANGE_EVENT && (sender is FlxUISlider))
		{
			switch (sender)
			{
				case 'playbackSpeed':
					playbackSpeed = Std.int(sliderRate.value);
			}
		}
	}

	var updatedSection:Bool = false;

	function sectionStartTime(add:Int = 0):Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSec + add)
		{
			if(_song.notes[i] != null)
			{
				if (_song.notes[i].changeBPM)
				{
					daBPM = _song.notes[i].bpm;
				}
				daPos += getSectionBeats(i) * (1000 * 60 / daBPM);
			}
		}
		return daPos;
	}

	var lastConductorPos:Float;
	var colorSine:Float = 0;
	override function update(elapsed:Float)
	{
		curStep = recalculateSteps();

		if(FlxG.sound.music.time < 0) {
			FunkinSoundChartEditor.resetSongInst();
		}
		else if(FlxG.sound.music.time > FlxG.sound.music.length) {
			FunkinSoundChartEditor.resetSongInst();
			changeSection();
		}
		Conductor.songPosition = FlxG.sound.music.time;
		_song.song = UI_songTitle.text;

		strumLineUpdateY();
		for (i in 0...8){
			strumLineNotes.members[i].y = strumLine.y;
		}

		camPos.y = strumLine.y;
		if(!disableAutoScrolling.checked) {
			if (Math.ceil(strumLine.y) >= gridBG.height)
			{
				if (_song.notes[curSec + 1] == null)
				{
					addSection();
				}

				changeSection(curSec + 1, false);
			} else if(strumLine.y < -10) {
				changeSection(curSec - 1, false);
			}
		}
		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);


		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * getSectionBeats() * 4) * zoomList[curZoom])
		{
			dummyArrow.visible = true;
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
			{
				var gridmult = GRID_SIZE / (quantization / 16);
				dummyArrow.y = Math.floor(FlxG.mouse.y / gridmult) * gridmult;
			}
		} else {
			dummyArrow.visible = false;
		}

		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEachAlive(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
					{
						if (FlxG.keys.pressed.CONTROL)
						{
							selectNote(note);
						}
						else if (FlxG.keys.pressed.ALT)
						{
							selectNote(note);
							curSelectedNote[3] = noteTypeIntMap.get(currentType);
							updateGridOfRenderedNotes();
						}
						else
						{
							//trace('tryin to delete note...');
							deleteNote(note);
						}
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * getSectionBeats() * 4) * zoomList[curZoom])
				{
					FlxG.log.add('added note');
					addNote();
				}
			}
		}

		var blockInput:Bool = false;
		for (inputText in blockPressWhileTypingOn) {
			if (inputText.hasFocus)
			{
				FunkinSoundChartEditor.disableVolumeControlKeys();
				blockInput = true;
				break;
			}
		}

		if(!blockInput) {
			for (stepper in blockPressWhileTypingOnStepper) {
				@:privateAccess
				var leText:Dynamic = stepper.text_field;
				var leText:FlxUIInputText = leText;
				if (leText.hasFocus) {
					FunkinSoundChartEditor.disableVolumeControlKeys();
					blockInput = true;
					break;
				}
			}
		}

		if(!blockInput) {
			FunkinSoundChartEditor.enableVolumeControlKeys();
			for (dropDownMenu in blockPressWhileScrolling) {
				if(dropDownMenu.dropPanel.visible) {
					blockInput = true;
					break;
				}
			}
		}

		if (!blockInput)
		{
			if (FlxG.keys.justPressed.ESCAPE)
			{
				autosaveSong();
				LoadingState.loadAndSwitchState(new EditorPlayState(sectionStartTime()));
			}
			if (FlxG.keys.justPressed.ENTER)
			{
				autosaveSong();
				PlayState.SONG = _song;

				FunkinSoundChartEditor.stopSong();

				//if(_song.stage == null) _song.stage = stageDropDown.selectedLabel;
				StageData.loadDirectory(_song);
				LoadingState.loadAndSwitchState(new PlayState());
			}

			if(curSelectedNote != null && curSelectedNote[1] > -1) {
				if (FlxG.keys.justPressed.E) {
					changeNoteSustain(Conductor.stepCrochet);
				}

				if (FlxG.keys.justPressed.Q) {
					changeNoteSustain(-Conductor.stepCrochet);
				}
			}


			if (FlxG.keys.justPressed.BACKSPACE) {
				PlayState.chartingMode = false;
				MusicBeatState.switchState(new MasterEditorMenu());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				return;
			}

			if(FlxG.keys.justPressed.Z && FlxG.keys.pressed.CONTROL) {
				undo();
			}

			if(FlxG.keys.justPressed.Z && curZoom > 0 && !FlxG.keys.pressed.CONTROL) {
				--curZoom;
				updateZoom();
			}
			if(FlxG.keys.justPressed.X && curZoom < zoomList.length-1) {
				curZoom++;
				updateZoom();
			}

			if (FlxG.keys.justPressed.TAB)
			{
				if (FlxG.keys.pressed.SHIFT)
				{
					songTabMenu.selected_tab -= 1;
					if (songTabMenu.selected_tab < 0)
						songTabMenu.selected_tab = 2;
				}
				else
				{
					songTabMenu.selected_tab += 1;
					if (songTabMenu.selected_tab >= 3)
						songTabMenu.selected_tab = 0;
				}
			}

			if (FlxG.keys.justPressed.SPACE)
			{

				if (playVocals)
				{
					FunkinSoundChartEditor.playSongVocals();
					FunkinSoundChartEditor.pauseAndResyncVocals(FlxG.sound.music.time);
				}

				FunkinSoundChartEditor.playSong(playVocals);
			}

			if (!FlxG.keys.pressed.ALT && FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}

			if (FlxG.mouse.wheel != 0)
			{
				FlxG.sound.music.pause();
				if (!mouseQuant)
				{
					FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet*0.8);
				}
				else
				{
					var time:Float = FlxG.sound.music.time;
					var beat:Float = curDecBeat;
					var snap:Float = quantization / 4;
					var increase:Float = 1 / snap;

					FunkinSoundChartEditor.quantizeInst(beat, snap, increase, false);
				}

				FunkinSoundChartEditor.pauseAndResyncVocals(FlxG.sound.music.time);
			}

			if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
			{
				FunkinSoundChartEditor.pauseSongInst();

				var holdingShift:Float = 1;
				if (FlxG.keys.pressed.CONTROL) holdingShift = 0.25;
				else if (FlxG.keys.pressed.SHIFT) holdingShift = 4;

				var daTime:Float = 700 * FlxG.elapsed * holdingShift;

				FunkinSoundChartEditor.adjustMusicTime(daTime);

				FunkinSoundChartEditor.pauseAndResyncVocals(FlxG.sound.music.time);
			}

			if(!vortex){
				if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN  )
				{
					FunkinSoundChartEditor.pauseSongInst();
					updateCurStep();
					var time:Float = FlxG.sound.music.time;
					var beat:Float = curDecBeat;
					var snap:Float = quantization / 4;
					var increase:Float = 1 / snap;

					FunkinSoundChartEditor.quantizeInst(beat, snap, increase, true);
				}
			}

			var style = currentType;

			if (FlxG.keys.pressed.SHIFT){
				style = 3;
			}

			var conductorTime = Conductor.songPosition; //+ sectionStartTime();Conductor.songPosition / Conductor.stepCrochet;

			//AWW YOU MADE IT SEXY <3333 THX SHADMAR

			if(!blockInput){
				if(FlxG.keys.justPressed.RIGHT){
					curQuant++;
					if(curQuant>quantizations.length-1)
						curQuant = 0;

					quantization = quantizations[curQuant];
				}

				if(FlxG.keys.justPressed.LEFT){
					curQuant--;
					if(curQuant<0)
						curQuant = quantizations.length-1;

					quantization = quantizations[curQuant];
				}
				quant.animation.play('q', true, false, curQuant);
			}
			if(vortex && !blockInput){
				var controlArray:Array<Bool> = [FlxG.keys.justPressed.ONE, FlxG.keys.justPressed.TWO, FlxG.keys.justPressed.THREE, FlxG.keys.justPressed.FOUR,
											   FlxG.keys.justPressed.FIVE, FlxG.keys.justPressed.SIX, FlxG.keys.justPressed.SEVEN, FlxG.keys.justPressed.EIGHT];

				if(controlArray.contains(true))
				{
					for (i in 0...controlArray.length)
					{
						if(controlArray[i])
							doANoteThing(conductorTime, i, style);
					}
				}

				var feces:Float;
				if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN  )
				{
					FunkinSoundChartEditor.pauseSongInst();

					updateCurStep();
					var time:Float = FlxG.sound.music.time;
					var beat:Float = curDecBeat;
					var snap:Float = quantization / 4;
					var increase:Float = 1 / snap;

					FunkinSoundChartEditor.tweenedQuantizeInst(beat, snap, increase, FlxEase.circInOut);

					FunkinSoundChartEditor.pauseAndResyncVocals(FlxG.sound.music.time);

					var dastrum = 0;

					if (curSelectedNote != null){
						dastrum = curSelectedNote[0];
					}

					var secStart:Float = sectionStartTime();
					var datime = (FunkinSoundChartEditor.quantizeShit - secStart) - (dastrum - secStart); //idk math find out why it doesn't work on any other section other than 0
					if (curSelectedNote != null)
					{
						var controlArray:Array<Bool> = [FlxG.keys.pressed.ONE, FlxG.keys.pressed.TWO, FlxG.keys.pressed.THREE, FlxG.keys.pressed.FOUR,
													   FlxG.keys.pressed.FIVE, FlxG.keys.pressed.SIX, FlxG.keys.pressed.SEVEN, FlxG.keys.pressed.EIGHT];

						if(controlArray.contains(true))
						{

							for (i in 0...controlArray.length)
							{
								if(controlArray[i])
									if(curSelectedNote[1] == i) curSelectedNote[2] += datime - curSelectedNote[2] - Conductor.stepCrochet;
							}
							updateGridOfRenderedNotes();
							_updateNoteUI();
						}
					}
				}
			}
			var shiftThing:Int = 1;
			if (FlxG.keys.pressed.SHIFT)
				shiftThing = 4;

			if (FlxG.keys.justPressed.D)
				changeSection(curSec + shiftThing);
			if (FlxG.keys.justPressed.A) {
				if(curSec <= 0) {
					changeSection(_song.notes.length-1);
				} else {
					changeSection(curSec - shiftThing);
				}
			}
		} else if (FlxG.keys.justPressed.ENTER) {
			for (i in 0...blockPressWhileTypingOn.length) {
				if(blockPressWhileTypingOn[i].hasFocus) {
					blockPressWhileTypingOn[i].hasFocus = false;
				}
			}
		}

		_song.bpm = tempBpm;
		strumLineNotes.visible = quant.visible = vortex;

		if (FlxG.sound.music.time < 0) {
			FunkinSoundChartEditor.resetSongInst();
		}
		else if (FlxG.sound.music.time > FlxG.sound.music.length) {
			FunkinSoundChartEditor.resetSongInst();
			changeSection();
		}

		Conductor.songPosition = FlxG.sound.music.time;
		strumLineUpdateY();
		camPos.y = strumLine.y;

		for (i in 0...8) {
			strumLineNotes.members[i].y = strumLine.y;
			strumLineNotes.members[i].alpha = FlxG.sound.music.playing ? 1 : 0.35;
		}

		// PLAYBACK SPEED CONTROLS //
		var holdingShift = FlxG.keys.pressed.SHIFT;
		var holdingLB = FlxG.keys.pressed.LBRACKET;
		var holdingRB = FlxG.keys.pressed.RBRACKET;
		var pressedLB = FlxG.keys.justPressed.LBRACKET;
		var pressedRB = FlxG.keys.justPressed.RBRACKET;

		if (!holdingShift && pressedLB || holdingShift && holdingLB)
			playbackSpeed -= 0.01;
		if (!holdingShift && pressedRB || holdingShift && holdingRB)
			playbackSpeed += 0.01;
		if (FlxG.keys.pressed.ALT && (pressedLB || pressedRB || holdingLB || holdingRB))
			playbackSpeed = 1;
		//

		if (playbackSpeed <= 0.5)
			playbackSpeed = 0.5;
		if (playbackSpeed >= 3)
			playbackSpeed = 3;

		FunkinSoundChartEditor.setSongPitch(playbackSpeed);

		bpmTxt.text =
		Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2)) + " / " + Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2)) +
		"\nSection: " + curSec +
		"\n\nBeat: " + Std.string(curDecBeat).substring(0,4) +
		"\n\nStep: " + curStep +
		"\n\nBeat Snap: " + quantization + "th";

		var playedSound:Array<Bool> = [false, false, false, false]; //Prevents ouchy GF sex sounds
		curRenderedNotes.forEachAlive(function(note:Note) {
			note.alpha = 1;
			if(curSelectedNote != null) {
				var noteDataToCheck:Int = note.noteData;
				if(noteDataToCheck > -1 && note.mustPress != _song.notes[curSec].mustHitSection) noteDataToCheck += 4;

				if (curSelectedNote[0] == note.strumTime && ((curSelectedNote[2] == null && noteDataToCheck < 0) || (curSelectedNote[2] != null && curSelectedNote[1] == noteDataToCheck)))
				{
					colorSine += elapsed;
					var colorVal:Float = 0.7 + Math.sin(Math.PI * colorSine) * 0.3;
					note.color = FlxColor.fromRGBFloat(colorVal, colorVal, colorVal, 0.999); //Alpha can't be 100% or the color won't be updated for some reason, guess i will die
				}
			}

			if(note.strumTime <= Conductor.songPosition) {
				note.alpha = 0.4;
				if(note.strumTime > lastConductorPos && FlxG.sound.music.playing && note.noteData > -1) {
					var data:Int = note.noteData % 4;
					var noteDataToCheck:Int = note.noteData;
					if(noteDataToCheck > -1 && note.mustPress != _song.notes[curSec].mustHitSection) noteDataToCheck += 4;
						strumLineNotes.members[noteDataToCheck].playAnim('confirm', true);
						strumLineNotes.members[noteDataToCheck].resetAnim = (note.sustainLength / 1000) + 0.15;
					if(!playedSound[data]) {
						if((playSoundBf.checked && note.mustPress) || (playSoundDad.checked && !note.mustPress)){
							var soundToPlay = 'hitsound';
							if(_song.player1 == 'gf') { //Easter egg
								soundToPlay = 'GF_' + Std.string(data + 1);
							}

							FlxG.sound.play(Paths.sound(soundToPlay)).pan = note.noteData < 4? -0.3 : 0.3; //would be coolio
							playedSound[data] = true;
						}

						data = note.noteData;
						if(note.mustPress != _song.notes[curSec].mustHitSection)
						{
							data += 4;
						}
					}
				}
			}
		});

		if(metronome.checked && lastConductorPos != Conductor.songPosition) {
			var metroInterval:Float = 60 / metronomeStepper.value;
			var metroStep:Int = Math.floor(((Conductor.songPosition + metronomeOffsetStepper.value) / metroInterval) / 1000);
			var lastMetroStep:Int = Math.floor(((lastConductorPos + metronomeOffsetStepper.value) / metroInterval) / 1000);
			if(metroStep != lastMetroStep) {
				FlxG.sound.play(Paths.sound('Metronome_Tick'));
				//trace('Ticked');
			}
		}
		lastConductorPos = Conductor.songPosition;
		super.update(elapsed);
	}

	private function updateZoom():Void
	{
		var zoom_value:Float = zoomList[curZoom];
		var zoom_string:String = '1 / ' + zoom_value;

		if (zoom_value < 1) {
			zoom_string = '${Math.round(1 / zoom_value)} / 1';
		}

		zoomTxt.text = 'Zoom: $zoom_string';

		ChartEditorBackend.zoomAmount = zoom_value;

		trace(ChartEditorBackend.zoomAmount);

		reloadGridLayer();
	}

	var lastSecBeats:Float = 0;
	var lastSecBeatsNext:Float = 0;
	function reloadGridLayer():Void
	{
		gridLayer.clear();

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 9, Std.int(GRID_SIZE * getSectionBeats() * 4 * zoomList[curZoom]));
		gridBG.drawFrame(false);

		#if desktop
		updateSongWaveform();
		#end

		var leHeight:Int = Std.int(gridBG.height);
		var foundNextSec:Bool = false;
		if(sectionStartTime(1) <= FlxG.sound.music.length)
		{
			nextGridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 9, Std.int(GRID_SIZE * getSectionBeats(curSec + 1) * 4 * zoomList[curZoom]));
			leHeight = Std.int(gridBG.height + nextGridBG.height);
			foundNextSec = true;
		}
		else
		{
			nextGridBG = new FlxSprite().makeGraphic(1, 1, FlxColor.TRANSPARENT);
		}

		nextGridBG.y = gridBG.height;

		gridLayer.add(nextGridBG);
		gridLayer.add(gridBG);

		nextGridBG.drawFrame(false);

		if(foundNextSec)
		{
			var gridBlack:FlxSprite = new FlxSprite(0, gridBG.height).makeGraphic(Std.int(GRID_SIZE * 9), Std.int(nextGridBG.height), FlxColor.BLACK);
			gridBlack.alpha = 0.4;
			gridBlack.drawFrame(false);
			gridLayer.add(gridBlack);
		}

		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + gridBG.width - (GRID_SIZE * 4)).makeGraphic(2, leHeight, FlxColor.BLACK);
		gridLayer.add(gridBlackLine);

		for (i in 1...4) {
			var beatsep1:FlxSprite = new FlxSprite(gridBG.x, (GRID_SIZE * (4 * curZoom)) * i).makeGraphic(Std.int(gridBG.width), 1, 0x44FF0000);
			if(vortex)
			{
				gridLayer.add(beatsep1);
			}
		}

		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + GRID_SIZE).makeGraphic(2, leHeight, FlxColor.BLACK);
		gridLayer.add(gridBlackLine);

		updateGridOfRenderedNotes();

		lastSecBeats = getSectionBeats();

		if (sectionStartTime(1) > FlxG.sound.music.length)
			lastSecBeatsNext = 0;
		else
			getSectionBeats(curSec + 1);
	}

	function strumLineUpdateY()
	{
		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) / zoomList[curZoom] % (Conductor.stepCrochet * 16)) / (getSectionBeats() / 4);
	}

	@:noPrivateAccess
	private function updateSongWaveform():Void
	{
		#if (desktop)
		ChartEditorBackend.updateWaveform(waveformSprite, curSec, gridBG.height, gridBG.width);
		#end
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		_updateNoteUI();
		updateGridOfRenderedNotes();
	}

	function recalculateSteps(add:Float = 0):Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime + add) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGridOfRenderedNotes();

		if (songBeginning) {
			FunkinSoundChartEditor.setInstTime(0);
			curSec = 0;
		}

		FunkinSoundChartEditor.pauseAndResyncVocals(FlxG.sound.music.time);

		updateCurStep();

		updateGridOfRenderedNotes();
		_updateSectionUI();
		updateSongWaveform();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		if (_song.notes[sec] != null)
		{
			curSec = sec;
			if (updateMusic)
			{
				FunkinSoundChartEditor.pauseAndResyncInst(sectionStartTime());
				FunkinSoundChartEditor.pauseAndResyncVocals(FlxG.sound.music.time);

				updateCurStep();
			}

			var blah1:Float = getSectionBeats();
			var blah2:Float = getSectionBeats(curSec + 1);
			if(sectionStartTime(1) > FlxG.sound.music.length) blah2 = 0;

			if (blah1 != lastSecBeats || blah2 != lastSecBeatsNext)
			{
				reloadGridLayer();
			}
			else
			{
				updateGridOfRenderedNotes();
			}

			_updateSectionUI();
		}
		else
		{
			changeSection();
		}
		Conductor.songPosition = FlxG.sound.music.time;
		updateSongWaveform();
	}

	private function _updateSectionUI():Void
	{
		var sec = _song.notes[curSec];

		stepperBeats.value = getSectionBeats();
		check_mustHitSection.checked = sec.mustHitSection;
		check_gfSection.checked = sec.gfSection;
		check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;

		updateIcons();
	}

	@:noPrivateAccess
	private function updateIcons():Void
	{
		ChartEditorBackend.updatePlayerIcons(
			leftIcon,
			rightIcon,
			curSec
		);
	}

	private function _updateNoteUI():Void
	{
		if (curSelectedNote != null) {
			if(curSelectedNote[2] != null) {
				stepperSusLength.value = curSelectedNote[2];
				if(curSelectedNote[3] != null) {
					currentType = noteTypeMap.get(curSelectedNote[3]);
					if(currentType <= 0) {
						noteTypeDropDown.selectedLabel = '';
					} else {
						noteTypeDropDown.selectedLabel = currentType + '. ' + curSelectedNote[3];
					}
				}
			} else {
				eventDropDown.selectedLabel = curSelectedNote[1][curEventSelected][0];
				var selected:Int = Std.parseInt(eventDropDown.selectedId);
				if(selected > 0 && selected < eventStuff.length) {
					descText.text = eventStuff[selected][1];
				}
				value1InputText.text = curSelectedNote[1][curEventSelected][1];
				value2InputText.text = curSelectedNote[1][curEventSelected][2];
			}
			strumTimeInputText.text = '' + curSelectedNote[0];
		}
	}

	@:noPrivateAccess
	private function updateGridOfRenderedNotes():Void
	{
		ChartEditorBackend.clearGroupList([
			curRenderedNotes,
			curRenderedSustains,
			curRenderedNoteType,
			nextRenderedNotes,
			nextRenderedSustains
		]);

		ChartEditorBackend.updateGridBPM(curSec);

		var beats:Float = getSectionBeats();
		for (i in _song.notes[curSec].sectionNotes)
		{
			var note:Note = ChartEditorBackend.setupNoteData(i, noteTypeIntMap, curSec, false, gridBG.y);

			curRenderedNotes.add(note);

			if (note.sustainLength > 0) {
				curRenderedSustains.add(ChartEditorBackend.setupSustainNote(note, beats, Conductor.stepCrochet));
			}

			if (i[3] != null && note.noteType != null && note.noteType.length > 0) {
				var daText:AttachedFlxText = new AttachedFlxText(
					0, 0,
					100,
					ChartEditorBackend.getNoteType(noteTypeMap, i),
					24
				);

				daText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				daText.xAdd = -32;
				daText.yAdd = 6;
				daText.borderSize = 1;

				curRenderedNoteType.add(daText);

				daText.sprTracker = note;
			}

			note.mustPress = _song.notes[curSec].mustHitSection;

			if (i[1] > 3) {
				note.mustPress = !note.mustPress;
			}
		}

		var startThing:Float = sectionStartTime();
		var endThing:Float = sectionStartTime(1);

		for (i in _song.events)
		{
			if(endThing > i[0] && i[0] >= startThing)
			{
				var eventNote:Note = ChartEditorBackend.setupNoteData(i, noteTypeIntMap, curSec, false, gridBG.y);
				curRenderedNotes.add(eventNote);

				var text:String = 'Event: ' + eventNote.eventName + ' (' + Math.floor(eventNote.strumTime) + ' ms)' + '\nValue 1: ' + eventNote.eventVal1 + '\nValue 2: ' + eventNote.eventVal2;

				if (eventNote.eventLength > 1) {
					text = eventNote.eventLength + ' Events:\n' + eventNote.eventName;
				}

				var daText:AttachedFlxText = new AttachedFlxText(0, 0, 400, text, 12);
				daText.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
				daText.xAdd = -410;
				daText.borderSize = 1;

				if (eventNote.eventLength > 1) {
					daText.yAdd += 8;
				}

				curRenderedNoteType.add(daText);

				daText.sprTracker = eventNote;
			}
		}

		ChartEditorBackend.renderNextNotes(curSec, noteTypeIntMap, nextRenderedNotes, nextRenderedSustains, gridBG.y);
	}

	private function addSection(sectionBeats:Float = 4):Void
	{
		var sec:SwagSection = {
			sectionBeats: sectionBeats,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			gfSection: false,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note):Void
	{
		var noteDataToCheck:Int = note.noteData;

		if (noteDataToCheck > -1)
		{
			if (note.mustPress != _song.notes[curSec].mustHitSection)
				noteDataToCheck += 4;

			for (i in _song.notes[curSec].sectionNotes)
			{
				if (i != curSelectedNote && i.length > 2 && i[0] == note.strumTime && i[1] == noteDataToCheck)
				{
					curSelectedNote = i;
					break;
				}
			}
		}
		else
		{
			for (i in _song.events)
			{
				if (i != curSelectedNote && i[0] == note.strumTime)
				{
					curSelectedNote = i;
					curEventSelected = Std.int(curSelectedNote[1].length) - 1;
					break;
				}
			}
		}

		changeEventSelected();

		updateGridOfRenderedNotes();
		_updateNoteUI();
	}

	function deleteNote(note:Note):Void
	{
		var noteDataToCheck:Int = note.noteData;

		if (noteDataToCheck > -1 && note.mustPress != _song.notes[curSec].mustHitSection)
			noteDataToCheck += 4;

		if (note.noteData > -1) // Regular Notes
		{
			for (i in _song.notes[curSec].sectionNotes)
			{
				if (i[0] == note.strumTime && i[1] == noteDataToCheck)
				{
					if (i == curSelectedNote)
						curSelectedNote = null;

					_song.notes[curSec].sectionNotes.remove(i);

					break;
				}
			}
		}
		else // Event Notes
		{
			for (i in _song.events)
			{
				if (i[0] == note.strumTime)
				{
					if (i == curSelectedNote) {
						curSelectedNote = null;
						changeEventSelected();
					}

					_song.events.remove(i);

					break;
				}
			}
		}

		updateGridOfRenderedNotes();
	}

	public function doANoteThing(cs, d, style):Void
	{
		var delnote = false;
		if (strumLineNotes.members[d].overlaps(curRenderedNotes))
		{
			curRenderedNotes.forEachAlive(function(note:Note)
			{
				if (note.overlapsPoint(new FlxPoint(strumLineNotes.members[d].x + 1,strumLine.y+1)) && note.noteData == d%4)
				{
						if( !delnote)
							deleteNote(note);
						delnote = true;
				}
			});
		}

		if (!delnote) {
			addNote(cs, d, style);
		}
	}
	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length) {
			_song.notes[daSection].sectionNotes = [];
		}

		updateGridOfRenderedNotes();
	}

	private function addNote(strum:Null<Float> = null, data:Null<Int> = null, type:Null<Int> = null):Void
	{
		var noteStrum = getStrumTime(dummyArrow.y * (getSectionBeats() / 4), false) + sectionStartTime();
		var noteData = Math.floor((FlxG.mouse.x - GRID_SIZE) / GRID_SIZE);
		var noteSus = 0;
		var daAlt = false;
		var daType = currentType;

		if (strum != null)
			noteStrum = strum;
		if (data != null)
			noteData = data;
		if (type != null)
			daType = type;

		if(noteData > -1)
		{
			_song.notes[curSec].sectionNotes.push([noteStrum, noteData, noteSus, noteTypeIntMap.get(daType)]);
			curSelectedNote = _song.notes[curSec].sectionNotes[_song.notes[curSec].sectionNotes.length - 1];
		}
		else
		{
			var event = eventStuff[Std.parseInt(eventDropDown.selectedId)][0];
			var text1 = value1InputText.text;
			var text2 = value2InputText.text;
			_song.events.push([noteStrum, [[event, text1, text2]]]);
			curSelectedNote = _song.events[_song.events.length - 1];
			curEventSelected = 0;
		}

		changeEventSelected();

		if (FlxG.keys.pressed.CONTROL && noteData > -1)
		{
			_song.notes[curSec].sectionNotes.push([noteStrum, (noteData + 4) % 8, noteSus, noteTypeIntMap.get(daType)]);
		}

		strumTimeInputText.text = '' + curSelectedNote[0];

		updateGridOfRenderedNotes();
		_updateNoteUI();
	}

	// will figure this out l8r
	function redo():Void {}

	function undo():Void
	{
		undos.pop();
	}

	function getStrumTime(yPos:Float, doZoomCalc:Bool = true):Float
	{
		var leZoom:Float = zoomList[curZoom];

		if (!doZoomCalc)
			leZoom = 1;

		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height * leZoom, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float, doZoomCalc:Bool = true):Float
	{
		var leZoom:Float = zoomList[curZoom];

		if (!doZoomCalc)
			leZoom = 1;

		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height * leZoom);
	}

	function getYfromStrumNotes(strumTime:Float, beats:Float):Float
	{
		var value:Float = strumTime / (beats * 4 * Conductor.stepCrochet);
		return GRID_SIZE * beats * 4 * zoomList[curZoom] * value + gridBG.y;
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes) {
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String):Void
	{
		if (FunkinUtil.difficulties[PlayState.storyDifficulty] != FunkinUtil.defaultDifficulty)
		{
			if (FunkinUtil.difficulties[PlayState.storyDifficulty] == null) {
				PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
			} else {
				PlayState.SONG = Song.loadFromJson('${song.toLowerCase()}${FunkinUtil.difficulties[PlayState.storyDifficulty].toLowerCase()}', song.toLowerCase());
			}
		} else {
			PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
		}

		MusicBeatState.resetState();
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	function clearEvents():Void
	{
		_song.events = [];
		updateGridOfRenderedNotes();
	}

	private function saveChartData(?context:Null<SaveContext> = CHART):Void
	{
		var dataMap_SONG:Dynamic = ChartEditorBackend.getDataFromChart('song');

		if (context.equals(SaveContext.EVENTS)) {
			if (dataMap_SONG.events != null && dataMap_SONG.events.length > 1) {
				dataMap_SONG.events.sort(sortByTime);
			}
		}

		ChartEditorBackend.saveSong(context);
	}

	function sortByTime(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	function getSectionBeats(?section:Null<Int> = null)
	{
		if (section == null)
			section = curSec;

		var val:Null<Float> = null;

		if (_song.notes[section] != null)
			val = _song.notes[section].sectionBeats;

		return val != null ? val : 4;
	}
}
