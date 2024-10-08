package funkin.play;

import funkin.play.components.statistics.ScorePopUp;
import funkin.graphics.effects.FlashEffect;
import funkin.play.song.Chart.ParseType;
import funkin.play.song.SongSettings.SongSettingsJSON;
import funkin.util.EaseUtil;
import flixel.graphics.FlxGraphic;
#if desktop
import funkin.api.discord.Discord.DiscordClient;
#end
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.effects.FlxTrail;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import openfl.utils.Assets as OpenFlAssets;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import flixel.util.FlxSave;
import flixel.animation.FlxAnimationController;

import funkin.graphics.shaders.Shaders.ChromaticAberration;
import funkin.graphics.shaders.Shaders.VCRDistortionEffect;
import funkin.graphics.shaders.WiggleEffect;
import funkin.graphics.shaders.WiggleEffect.WiggleEffectType;
import funkin.animateatlas.AtlasFrameMaker;
import funkin.util.Constants;
import funkin.play.song.*;
import funkin.play.song.Song.SwagSong;
import funkin.play.song.Section.SwagSection;
import funkin.play.song.SongData.SongDataJson;
import funkin.play.stage.StageData.StageFile;
import funkin.play.notes.Note.EventNote;
import funkin.play.player.Achievements;
import funkin.play.stage.*;
import funkin.play.stage.props.*;
import funkin.play.notes.*;
import funkin.play.character.Boyfriend;
import funkin.play.character.Character;
import funkin.play.components.*;
import funkin.play.components.rating.*;
import funkin.play.components.dialogue.*;
import funkin.play.components.dialogue.DialogueBoxPsych.DialogueFile;
import funkin.play.PauseSubState;
import funkin.play.GameOverSubstate;
import funkin.graphics.effects.CinematicBorder;
import funkin.sound.FunkinSound;
import funkin.tweens.GlobalTweenClass;
import funkin.play.scoring.*;
import funkin.play.scoring.Rating.PlayStateRating;
import funkin.ui.debug.Watermark;
import funkin.backend.*;

import funkin.ui.display.SpriteLayersHandler.CharacterLayers;

#if (debug)
import funkin.ui.debug.DebugText;
#end

/**
 * FNF-Modcharting-Tools (DEPRECATED FOR NOW.)
 */

/**import modcharting.ModchartFuncs;
import modcharting.NoteMovement;
import modcharting.PlayfieldRenderer;*/


#if !flash
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

#if sys
import sys.FileSystem;
import sys.io.File;
#end

#if VIDEOS_ALLOWED
import vlc.MP4Handler;
import funkin.graphics.FunkinVideo;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	//event variables
	private var isCameraOnForcedPos:Bool = false;

	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	public var variables:Map<String, Dynamic> = new Map();
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var playbackRate(default, set):Float = 1;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public static var SONG:SwagSong = null;
	public static var SONG_DATA:SongDataJson = null;
	public static var SONG_METADATA:SongSettingsJSON = null;

	public var spawnTime:Float = 2000;

	public var vocals:FlxSound;

	public var vocalsBf:FlxSound;
	public var vocalsDad:FlxSound;

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	private var strumLine:FlxSprite;

	//Handles the new epic mega sexy cam code that i've done
	public var camFollow:FlxPoint;
	public var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;
	public var grpHoldCovers:FlxTypedGroup<HoldCover>;

	public var camZooming:Bool = true;
	public var camZoomingMult:Float = 1.1;
	public var camZoomingDecay:Float = 0.95;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

	public var healthBar:HealthBar;
	var songPercent:Float = 0;

	public var timeBar:TimeBar;

	public var marvs:Int = 0;
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var isDead:Bool = false;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var gameplayInfo:GameplayInfo;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var playerIcons:FlxTypedGroup<HealthIcon>;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var borderCam:FlxCamera;
	public var camRating:FlxCamera;
	public var camExternalInfo:FlxCamera;
	public var camOther:FlxCamera;
	public var camStrum:FlxCamera;
	public var camSus:FlxCamera;
	public var camNotes:FlxCamera;
	public var cameraSpeed:Float = 1.0;

	/**
	 * Shaders
	 */
	public var aberrationEffect:ChromaticAberration;
	public var vcrEffect:VCRDistortionEffect;
	public var noteWiggle:WiggleEffect;
	public var grayscale:Grayscale;

	/**
	 * Shader values
	 */
	var noteWiggleAmplitude:Float = 0.0325;
	var noteWiggleFrequency:Float = 8;
	var noteWiggleSpeed:Float = 2.25 + (Conductor.bpm / 100);
	var noteWiggleAmplitudeDecay = 4.0 + (Conductor.bpm / 150) + (PlayState.SONG.speed / 3.0);
	var lerpAmplitude:Float;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;

	var dadbattleBlack:BackgroundStageSprite;
	var dadbattleLight:BackgroundStageSprite;
	var dadbattleSmokes:FlxSpriteGroup;

	var halloweenBG:BackgroundStageSprite;
	var halloweenWhite:BackgroundStageSprite;

	var phillyLightsColors:Array<FlxColor>;
	var phillyWindow:BackgroundStageSprite;
	var phillyStreet:BackgroundStageSprite;
	var phillyTrain:BackgroundStageSprite;
	var blammedLightsBlack:FlxSprite;
	var phillyWindowEvent:BackgroundStageSprite;
	var trainSound:FlxSound;
	var doPhillyCAB:Bool = false;

	var phillyGlowGradient:PhillyGlow.PhillyGlowGradient;
	var phillyGlowParticles:FlxTypedGroup<PhillyGlow.PhillyGlowParticle>;

	var limoKillingState:Int = 0;
	var limo:BackgroundStageSprite;
	var limoMetalPole:BackgroundStageSprite;
	var limoLight:BackgroundStageSprite;
	var limoCorpse:BackgroundStageSprite;
	var limoCorpseTwo:BackgroundStageSprite;
	var bgLimo:BackgroundStageSprite;
	var grpLimoParticles:FlxTypedGroup<BackgroundStageSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BackgroundStageSprite;

	var upperBoppers:BackgroundStageSprite;
	var bottomBoppers:BackgroundStageSprite;
	var santa:BackgroundStageSprite;
	var heyTimer:Float;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var bgGhouls:BackgroundStageSprite;

	var tankWatchtower:BackgroundStageSprite;
	var tankGround:BackgroundStageSprite;
	var tankmanRun:FlxTypedGroup<TankmenBG>;
	var foregroundSprites:FlxTypedGroup<BackgroundStageSprite>;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	var scoreTxtTween:FlxTween;

	public var statsHUD:StatisticsHUD;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var campaignMarvs:Int = 0;
	public static var campaignSicks:Int = 0;
	public static var campaignGoods:Int = 0;
	public static var campaignBads:Int = 0;
	public static var campaignShits:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;
	public static var restartCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;
	public var luaArray:Array<FunkinLua> = [];
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var introSoundsSuffix:String = '';

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;

	// Less laggy controls
	private var keysArray:Array<Dynamic>;
	private var controlArray:Array<String>;

	#if (debug)
	private var debugText:DebugText;
	#end

	var precacheList:Map<String, String> = new Map<String, String>();

	// stores the last judgement object
	public static var lastRating:FlxSprite;
	// stores the last combo sprite object
	public static var lastCombo:FlxSprite;
	// stores the last combo score objects in an array
	public static var lastScore:Array<FlxSprite> = [];

	var judgementCounter:JudgementCounter;
	var engineWatermark:Watermark;

	var songCreditTxt:String = "";
	var songExtraTxt:String = "";

	public var canPause:Bool = false;
	public var finishedCountdown:Bool = false;
	public var displayedHealth:Float = Constants.HEALTH_START;
	public var lerpTime:Float = 0;
	public var comboPeak:Int = 0;

	public var currentTimeOfSong:Int = 0;
	public var totalLengthOfSong:Int = 0;

	private var hudGroup:FlxTypedGroup<FlxSprite>;
	private var hudGroupInfo:FlxTypedGroup<FlxSprite>;
	private var hudGroupExcluded:FlxTypedGroup<FlxSprite>;
	private var shaderCameraGroup:Array<FlxCamera> = [];
	private var updateShaderGroup:Array<Dynamic> = [];

	public var focusedCharacter:Character;
	public var animOffsetX:Float = 0;
	public var animOffsetY:Float = 0;

	public var erectMode:Bool = (PlayState.storyDifficulty > 2);

	private var songPopUp:SongCreditsPopUp;

	private var cinematicBorder:CinematicBorder;

	var tweenedZoomCameraTween:FlxTween;
	var doCameraZoomEvent:Bool = false;
	var borderCameraTween:FlxTween;
	var grayscaleTween:FlxTween;
	var cameraAngleTween:FlxTween;

	public var beatModulo:Int = 4;

	public var achievementHandler:AchievementsHandler;

	var onPlayerHoldCover:Array<HoldCover> = [];

	override public function create()
	{
		FlxG.mouse.visible = false;

		Paths.clearStoredMemory();

		instance = this;

		debugKeysChart = Preferences.copyKey(Preferences.keyBinds.get('debug_1'));
		debugKeysCharacter = Preferences.copyKey(Preferences.keyBinds.get('debug_2'));
		PauseSubState.songName = null; //Reset to default
		playbackRate = Preferences.getGameplaySetting('songspeed', 1);

		keysArray = [
			Preferences.copyKey(Preferences.keyBinds.get('note_left')),
			Preferences.copyKey(Preferences.keyBinds.get('note_down')),
			Preferences.copyKey(Preferences.keyBinds.get('note_up')),
			Preferences.copyKey(Preferences.keyBinds.get('note_right'))
		];

		controlArray = [
			'NOTE_LEFT',
			'NOTE_DOWN',
			'NOTE_UP',
			'NOTE_RIGHT'
		];

		/**
		 * Song ratings.
		 */
		PlayStateRating.initPlayStateRatings();

		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray.length) {
			keysPressed.push(false);
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = Preferences.getGameplaySetting('healthgain', 1);
		healthLoss = Preferences.getGameplaySetting('healthloss', 1);
		instakillOnMiss = Preferences.getGameplaySetting('instakill', false);
		practiceMode = Preferences.getGameplaySetting('practice', false);
		cpuControlled = Preferences.getGameplaySetting('botplay', false);

		camGame = new FlxCamera();
		borderCam = new FlxCamera();
		camRating = new FlxCamera();
		camHUD = new FlxCamera();
		camStrum = new FlxCamera();
		camSus = new FlxCamera();
		camNotes = new FlxCamera();
		camExternalInfo = new FlxCamera();
		camOther = new FlxCamera();

		borderCam.bgColor.alpha = 0;
		camRating.bgColor.alpha = 0;
		camHUD.bgColor.alpha = 0;
		camStrum.bgColor.alpha = 0;
		camSus.bgColor.alpha = 0;
		camNotes.bgColor.alpha = 0;
		camExternalInfo.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(borderCam, false);
		FlxG.cameras.add(camRating, false);
		FlxG.cameras.add(camStrum, false);
		FlxG.cameras.add(camSus, false);
		FlxG.cameras.add(camNotes, false);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camExternalInfo, false);
		FlxG.cameras.add(camOther, false);

		shaderCameraGroup.push(camGame);
		shaderCameraGroup.push(camHUD);
		shaderCameraGroup.push(camRating);
		shaderCameraGroup.push(camSus);
		shaderCameraGroup.push(camStrum);
		shaderCameraGroup.push(camNotes);

		camHUD.zoom = Constants.CAMERA_HUD_ZOOM;
		camRating.zoom = 0.8;
		camRating.setPosition(575, 250);

		aberrationEffect = new ChromaticAberration(0.0);

		vcrEffect = new VCRDistortionEffect(1.0);
		updateShaderGroup.push(vcrEffect);

		noteWiggle = new WiggleEffect();
		noteWiggle.effectType = WiggleEffectType.DREAMY;

		grayscale = new Grayscale();
		grayscale.strength = 0.0;

		ShaderUtil.setShadersToCameraGroup(shaderCameraGroup, [new ShaderFilter(grayscale.shader)]);

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		grpHoldCovers = new FlxTypedGroup<HoldCover>();

		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		CustomFadeTransition.nextCamera = camOther;

		persistentUpdate = true;
		persistentDraw = true;

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		storyDifficultyText = FunkinUtil.difficulties[storyDifficulty];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode) {
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		} else {
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();

		var songName:String = Paths.formatToSongPath(SONG.song);
		if (SONG.stage == null || SONG.stage.length < 1) {
			SONG.stage = StageData.vanillaSongStage(songName);
		}

		curStage = SONG.stage;

		var stageData:StageFile = StageData.getStageFile(curStage);

		loadStageData(stageData);

		loadStages(curStage);

		switch(Paths.formatToSongPath(SONG.song))
		{
			case 'stress':
				GameOverSubstate.characterName = 'bf-holding-gf-dead';
		}

		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		add(gfGroup); //Needed for blammed lights

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo') {
			add(limo);
		}

		add(dadGroup);
		add(boyfriendGroup);

		switch(curStage)
		{
			case 'spooky':
				add(halloweenWhite);
			case 'tank':
				add(foregroundSprites);
		}

		achievementHandler = new AchievementsHandler();

		/**
		 * Song Data / Information / Credits JSONs.
		 */
		SongLoader.loadSongData(PlayState.SONG.song);

		/**
		 * Song Settings / Metadata.
		 */
		SongLoader.loadSongSettings(PlayState.SONG.song);

		beatModulo = PlayState.SONG_METADATA.beatMod;

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		/**
		 * Loads the "Global" Scripts. [mods/scripts/]
		 */
		LuaLoader.loadGlobalScripts();

		/**
		 * Loads the "Stage" scripts. [mods/stages/]
		 */
		LuaLoader.loadStageScripts(curStage);

		/**
		 * Loads the girlfriend variant / "version".
		 */
		SongLoader.loadGirlfriendVariant(curStage, PlayState.SONG.song);

		if (!stageData.hide_girlfriend)
		{
			/**
			 * Use "SONG.gfVersion" instead of "gfVersion" as a string alone, as it already reads the "gfVersion" right after "loadGfVersion()" is called.
			 */
			gf = new Character(0, 0, SONG.gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set();
			gfGroup.add(gf);
			startCharacterLua(gf.curCharacter);

			if (SONG.gfVersion == 'pico-speaker')
			{
				if (!GlobalSettings.LOW_QUALITY)
				{
					var firstTank:TankmenBG = new TankmenBG(20, 500, true);
					firstTank.resetShit(20, 600, true);
					firstTank.strumTime = 10;
					tankmanRun.add(firstTank);

					for (i in 0...TankmenBG.animationNotes.length) {
						if (FlxG.random.bool(16)) {
							var tankBih = tankmanRun.recycle(TankmenBG);
							tankBih.strumTime = TankmenBG.animationNotes[i][0];
							tankBih.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
							tankmanRun.add(tankBih);
						}
					}
				}
			}
		}

		dad = new Character(0, 0, SONG.player2);
		dad.scrollFactor.set();
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterLua(dad.curCharacter);

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		boyfriend.scrollFactor.set();
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterLua(boyfriend.curCharacter);

		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if (gf != null) {
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if (dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if (gf != null)
				gf.visible = false;
		}

		switch(curStage)
		{
			case 'limo':
				resetFastCar();
				SpriteLayersHandler.addBehind(this, CharacterLayers.GF, fastCar);

			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069); //nice
				SpriteLayersHandler.addBehind(this, CharacterLayers.DAD, evilTrail);
		}

		var file:String = Paths.json('charts/${songName}/dialogue'); //Checks for json/Psych Engine dialogue

		if (OpenFlAssets.exists(file)) {
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
		}

		var file:String = Paths.txt('charts/${songName}/${songName}Dialogue'); //Checks for vanilla/Senpai dialogue

		if (OpenFlAssets.exists(file)) {
			dialogue = FunkinUtil.coolTextFile(file);
		}

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;
		doof.skipDialogueThing = skipDialogue;

		Conductor.songPosition = -5000 / Conductor.songPosition;

		strumLine = new FlxSprite(GlobalSettings.MIDDLESCROLL ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if (GlobalSettings.DOWNSCROLL) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		var showTime:Bool = (GlobalSettings.TIME_BAR_DISPLAY != 'Disabled');

		// timeBarBG.sprTracker = timeBar;

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);

		var holdSplash:HoldCover = new HoldCover(100, 100, 0);
		grpHoldCovers.add(holdSplash);

		holdSplash.alpha = 0.0;
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);

		/**playfieldRenderer = new PlayfieldRenderer(strumLineNotes, notes, this);
		playfieldRenderer.cameras = [camHUD];
		add(playfieldRenderer);*/

		add(grpNoteSplashes);
		add(grpHoldCovers);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);

		if (prevCamFollow != null) {
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		if (prevCamFollowPos != null) {
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}

		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection();

		/**
		 * General sprites on the HUD / UI, such as bars, and etc.
		 */
		hudGroup = new FlxTypedGroup<FlxSprite>();
		add(hudGroup);

		/**
		 * HealthBar Code.
		 */
		var healthBarY:Float = FlxG.height * 0.85;
		if (GlobalSettings.DOWNSCROLL) {
			healthBarY = FlxG.height * 0.11;
		}

		healthBar = new HealthBar(0, healthBarY);
		healthBar.screenCenter(X);
		hudGroup.add(healthBar);

		healthBar.reloadColors();

		/**
		 * TimeBar code.
		 */
		timeBar = new TimeBar(0, 0);
		timeBar.screenCenter(X);
		hudGroup.add(timeBar);

		/**
		 * Player Icons.
		 */
		playerIcons = new FlxTypedGroup<HealthIcon>();
		add(playerIcons);

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		playerIcons.add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		playerIcons.add(iconP2);

		playerIcons.forEach(function(icon:HealthIcon) {
			icon.y = healthBar.y - 50;
			icon.visible = !GlobalSettings.HIDE_HUD;
			icon.alpha = GlobalSettings.HEALTH_BAR_TRANSPARENCY;
		});

		/**
		 * General info on the HUD such as statistics, score, etc.
		 */
		hudGroupInfo = new FlxTypedGroup<FlxSprite>();
		add(hudGroupInfo);

		/**
		 * External info such as the engine's version, git branch, etc.
		 */
		hudGroupExcluded = new FlxTypedGroup<FlxSprite>();
		add(hudGroupExcluded);

		statsHUD = new StatisticsHUD(0, FlxG.height * 0.85, Constants.STATISTICS_HUD_SIZE);
		statsHUD.x += 25;
		statsHUD.scrollFactor.set();
		hudGroupInfo.add(statsHUD);

		botplayTxt = new FlxText(0, 75, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font('phantommuff.ttf'), 38, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.screenCenter(X);
		botplayTxt.borderSize = 1.5;
		botplayTxt.visible = cpuControlled;
		hudGroupInfo.add(botplayTxt);

		/**
		 * JudgementCounter.
		 */
		judgementCounter = new JudgementCounter(15, -25, Constants.JUDGEMENT_COUNTER_SIZE, 18, LEFT);
		judgementCounter.screenCenter(Y);
		hudGroupInfo.add(judgementCounter);

		/**
		 * GameplayInfo.
		 */
		gameplayInfo = new GameplayInfo(-15, FlxG.height * 0.875, Constants.GAMEPLAY_INFO_SIZE, 17,
			FunkinUtil.getSongDisplayName(),
			FunkinUtil.difficultyString().toUpperCase().trim(),
			PlayState.SONG_DATA.artist,
			PlayState.SONG_DATA.stringExtra
		);
		gameplayInfo.scrollFactor.set();
		hudGroupInfo.add(gameplayInfo);

		/**
		 * Pop-up for song's credits.
		 */
		songPopUp = new SongCreditsPopUp(
			FunkinUtil.getSongDisplayName(),
			PlayState.SONG_DATA.artist,
			PlayState.SONG_DATA.charter
		);
		hudGroupInfo.add(songPopUp);

		/**
		 * Engine Watermark.
		 */
		engineWatermark = new Watermark(0, FlxG.height * 0.97, Constants.WATERMARK_SIZE, 12);
		engineWatermark.screenCenter(X);
		engineWatermark.scrollFactor.set();
		hudGroupExcluded.add(engineWatermark);

		engineWatermark.playWatermarkAnimation();

		#if (debug)
		debugText = new DebugText(1.0, 1.0, 0.3, 16);
		debugText.scrollFactor.set();
		hudGroupExcluded.add(debugText);
		#end

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		grpHoldCovers.cameras = [camHUD];
		notes.cameras = [camHUD];
		doof.cameras = [camHUD];

		hudGroup.forEach(function(spr:FlxSprite) {
			spr.scrollFactor.set();
			spr.antialiasing = GlobalSettings.SPRITE_ANTIALIASING;
			spr.cameras = [camHUD];
		});

		playerIcons.forEach(function(icon:FlxSprite) {
			icon.cameras = [camHUD];
		});

		hudGroupInfo.forEach(function(spr:FlxSprite) {
			spr.scrollFactor.set();
			spr.antialiasing = GlobalSettings.SPRITE_ANTIALIASING;
			spr.cameras = [camHUD];
		});

		hudGroupExcluded.forEach(function(spr:FlxSprite) {
			spr.scrollFactor.set();
			spr.antialiasing = GlobalSettings.SPRITE_ANTIALIASING;
			spr.cameras = [camExternalInfo];
		});

		cinematicBorder = new CinematicBorder(1.0);
		cinematicBorder.scrollFactor.set();
		cinematicBorder.cameras = [borderCam];
		add(cinematicBorder);

		startingSong = true;

		#if LUA_ALLOWED
		// Loads Custom Notetypes. [mods/custom_notetypes/]
		for (notetype in noteTypeMap.keys()) {
			LuaLoader.loadLuaPath('custom_notetypes/$notetype');
		}

		// Loads Custom Events. [mods/custom_events/]
		for (event in eventPushedMap.keys()) {
			LuaLoader.loadLuaPath('custom_events/$event');
		}
		#end

		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		/**
		 * Loads the Song's scripts. [mods/data/charts/(SONG)]
		 */
		LuaLoader.loadSongScripts(SONG.song);

		var daSong:String = Paths.formatToSongPath(curSong);
		if (isStoryMode && !seenCutscene)
		{
			switch (daSong)
			{
				case "monster":
					var whiteScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
					add(whiteScreen);
					whiteScreen.scrollFactor.set();
					whiteScreen.blend = ADD;
					camHUD.visible = false;
					snapCamFollowToPos(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
					inCutscene = true;

					GlobalTweenClass.tween(whiteScreen, {alpha: 0}, 1, {
						startDelay: 0.1,
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween) {
							camHUD.visible = true;
							remove(whiteScreen);
							startCountdown();
						}
					});

					FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
					if(gf != null) gf.playAnim('scared', true);
					boyfriend.playAnim('scared', true);

				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;
					inCutscene = true;

					GlobalTweenClass.tween(blackScreen, {alpha: 0}, 0.7, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween) {
							remove(blackScreen);
						}
					});

					FlxG.sound.play(Paths.sound('Lights_Turn_On'));

					snapCamFollowToPos(400, -2050);
					FlxG.camera.focusOn(camFollow);
					FlxG.camera.zoom = 1.5;

					new FlxTimer().start(0.8, function(tmr:FlxTimer) {
						camHUD.visible = true;
						remove(blackScreen);
						GlobalTweenClass.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween) {
								startCountdown();
							}
						});
					});

				case 'senpai' | 'roses' | 'thorns':
					if(daSong == 'roses') FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);

				case 'ugh' | 'guns' | 'stress':
					tankIntro();

				default:
					startCountdown();
			}

			seenCutscene = true;
		}
		else
		{
			startCountdown();
		}

		RecalculateRating();

		/**
		 * Shader filters set / create for specific stages.
		 */
		switch (curStage) {
			case 'philly':
				ShaderUtil.setShadersToCameraGroup(shaderCameraGroup, [new ShaderFilter(grayscale.shader), new ShaderFilter(aberrationEffect.shader)]);
			case 'school' | 'schoolEvil':
				ShaderUtil.setShadersToCameraGroup(shaderCameraGroup, [new ShaderFilter(grayscale.shader), new ShaderFilter(vcrEffect.shader)]);
		}

		if (GlobalSettings.HITSOUND_VOLUME > 0) {
			precacheList.set('hitsound', 'sound');
		}

		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');

		if (PauseSubState.songName != null) {
			precacheList.set(PauseSubState.songName, 'music');
		} else if (GlobalSettings.PAUSE_MUSIC != 'None') {
			precacheList.set(Paths.formatToSongPath(GlobalSettings.PAUSE_MUSIC), 'music');
		}

		precacheList.set('alphabet', 'image');

		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end

		if(!GlobalSettings.CONTROLLER_MODE) {
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		// ModchartFuncs.loadLuaFunctions();

		callOnLuas('onCreatePost', []);

		super.create();

		/**
		 * Make Note Strum Tail wiggle when the song has 'hasNoteWiggle' on.
		 */
		if (PlayState.SONG_METADATA.hasNoteWiggle)
		{
			strumLineNotes.forEach(function(strum:StrumNote):Void {
				strum.cameras = [camStrum];
			});

			notes.forEach(function(note:Note):Void {
				if (note.isSustainNote)
					note.cameras = [camSus];
				else
					note.cameras = [camNotes];
			});

			camSus.setFilters([new ShaderFilter(noteWiggle.shader)]);
		}

		borderCam.zoom = 1.85;
		borderCam.visible = false;

		health = Constants.HEALTH_START;

		cacheCountdown();
		cacheScoreProcess();

		for (key => type in precacheList)
		{
			switch(type)
			{
				case 'image':
					Paths.image(key);
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
			}
		}

		Paths.clearUnusedMemory();

		CustomFadeTransition.nextCamera = camOther;
	}

	private function loadStageData(?stageData:Null<StageFile>):Void
	{
		SongLoader.loadStageData(stageData);

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);
	}

	private function loadStages(?stageKey:Null<String>):Void
	{
		if (stageKey == null || stageKey == '') return;

		switch (stageKey)
		{
			case 'stage': //Week 1

				var stageStuff:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
				add(stageStuff);

				var bg:BackgroundStageSprite = new BackgroundStageSprite('stageback', -600, -200);
				stageStuff.add(bg);

				var stageFront:BackgroundStageSprite = new BackgroundStageSprite('stagefront', -780, 600);
				// stageFront.setGraphicSize(Std.int(stageFront.width * 3.0), Std.int(stageFront.height * 3.0));
				stageStuff.add(stageFront);

				var stageLight:BackgroundStageSprite = new BackgroundStageSprite('stage_light', -125, -100, 0.9, 0.9);
				// stageLight.setGraphicSize(Std.int(stageLight.width * 1.05));
				stageStuff.add(stageLight);

				var stageLight:BackgroundStageSprite = new BackgroundStageSprite('stage_light', 1225, -100, 0.9, 0.9);
				// stageLight.setGraphicSize(Std.int(stageLight.width * 1.05));
				stageLight.flipX = true;
				stageStuff.add(stageLight);

				var stageCurtains:BackgroundStageSprite = new BackgroundStageSprite('stagecurtains', -720, -360, 1.1, 1.1);
				// stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageStuff.add(stageCurtains);

				stageStuff.forEach(function(sprite:FlxSprite) {
					sprite.antialiasing = GlobalSettings.SPRITE_ANTIALIASING;
					sprite.setGraphicSize(Std.int(sprite.width * 1.2), Std.int(sprite.height * 1.2));
					sprite.updateHitbox();
				});

				dadbattleSmokes = new FlxSpriteGroup(); //troll'd

			case 'spooky': //Week 2
				if (!GlobalSettings.LOW_QUALITY)
					halloweenBG = new BackgroundStageSprite('halloween_bg', -180, -120, ['halloweem bg0', 'halloweem bg lightning strike']);
				else
					halloweenBG = new BackgroundStageSprite('halloween_bg_low', -180, -120);

				halloweenBG.setGraphicSize(Std.int(halloweenBG.width * 1.2), Std.int(halloweenBG.height * 1.2));

				add(halloweenBG);

				halloweenWhite = new BackgroundStageSprite(null, -800, -400, 0, 0);
				halloweenWhite.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
				halloweenWhite.alpha = 0;
				halloweenWhite.blend = ADD;

				precacheList.set('thunder_1', 'sound');
				precacheList.set('thunder_2', 'sound');

			case 'philly': //Week 3
				if (!GlobalSettings.LOW_QUALITY) {
					var bg:BackgroundStageSprite = new BackgroundStageSprite('philly/sky', -100, 0, 0.1, 0.1);
					add(bg);
				}

				var city:BackgroundStageSprite = new BackgroundStageSprite('philly/city', -10, 0, 0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);

				phillyLightsColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
				phillyWindow = new BackgroundStageSprite('philly/window', city.x, city.y, 0.3, 0.3);
				phillyWindow.setGraphicSize(Std.int(phillyWindow.width * 0.85));
				phillyWindow.updateHitbox();
				add(phillyWindow);
				phillyWindow.alpha = 0;

				if(!GlobalSettings.LOW_QUALITY) {
					var streetBehind:BackgroundStageSprite = new BackgroundStageSprite('philly/behindTrain', -40, 50);
					add(streetBehind);
				}

				phillyTrain = new BackgroundStageSprite('philly/train', 2000, 360);
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
				FlxG.sound.list.add(trainSound);

				phillyStreet = new BackgroundStageSprite('philly/street', -40, 50);
				add(phillyStreet);

			case 'limo': //Week 4
				var skyBG:BackgroundStageSprite = new BackgroundStageSprite('limo/limoSunset', -120, -50, 0.1, 0.1);
				add(skyBG);

				if (!GlobalSettings.LOW_QUALITY)
				{
					limoMetalPole = new BackgroundStageSprite('gore/metalPole', -500, 220, 0.4, 0.4);
					add(limoMetalPole);

					bgLimo = new BackgroundStageSprite('limo/bgLimo', -150, 480, 0.4, 0.4, ['background limo pink'], true);
					add(bgLimo);

					limoCorpse = new BackgroundStageSprite('gore/noooooo', -500, limoMetalPole.y - 130, 0.4, 0.4, ['Henchmen on rail'], true);
					add(limoCorpse);

					limoCorpseTwo = new BackgroundStageSprite('gore/noooooo', -500, limoMetalPole.y, 0.4, 0.4, ['henchmen death'], true);
					add(limoCorpseTwo);

					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5)
					{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 170, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
					}

					limoLight = new BackgroundStageSprite('gore/coldHeartKiller', limoMetalPole.x - 180, limoMetalPole.y - 80, 0.4, 0.4);
					add(limoLight);

					grpLimoParticles = new FlxTypedGroup<BackgroundStageSprite>();
					add(grpLimoParticles);

					var particle:BackgroundStageSprite = new BackgroundStageSprite('gore/stupidBlood', -400, -400, 0.4, 0.4, ['blood'], false);
					particle.alpha = 0.01;
					grpLimoParticles.add(particle);
					resetLimoKill();

					precacheList.set('dancerdeath', 'sound');
				}

				limo = new BackgroundStageSprite('limo/limoDrive', -120, 550, 1, 1, ['Limo stage'], true);

				fastCar = new BackgroundStageSprite('limo/fastCarLol', -300, 160);
				fastCar.active = true;
				limoKillingState = 0;

			case 'mall': //Week 5 - Cocoa, Eggnog
				var bg:BackgroundStageSprite = new BackgroundStageSprite('christmas/bgWalls', -1000, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				if (!GlobalSettings.LOW_QUALITY)
				{
					upperBoppers = new BackgroundStageSprite('christmas/upperBop', -240, -90, 0.33, 0.33, ['Upper Crowd Bob']);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					add(upperBoppers);

					var bgEscalator:BackgroundStageSprite = new BackgroundStageSprite('christmas/bgEscalator', -1100, -600, 0.3, 0.3);
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);
				}

				var tree:BackgroundStageSprite = new BackgroundStageSprite('christmas/christmasTree', 370, -250, 0.40, 0.40);
				add(tree);

				bottomBoppers = new BackgroundStageSprite('christmas/bottomBop', -300, 140, 0.9, 0.9, ['Bottom Level Boppers Idle']);
				bottomBoppers.animation.addByPrefix('hey', 'Bottom Level Boppers HEY', 24, false);
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				add(bottomBoppers);

				var fgSnow:BackgroundStageSprite = new BackgroundStageSprite('christmas/fgSnow', -600, 700);
				add(fgSnow);

				santa = new BackgroundStageSprite('christmas/santa', -840, 150, 1, 1, ['santa idle in fear']);
				add(santa);
				precacheList.set('Lights_Shut_off', 'sound');

			case 'mallEvil': //Week 5 - Winter Horrorland
				var bg:BackgroundStageSprite = new BackgroundStageSprite('christmas/evilBG', -400, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				var evilTree:BackgroundStageSprite = new BackgroundStageSprite('christmas/evilTree', 300, -300, 0.2, 0.2);
				add(evilTree);

				var evilSnow:BackgroundStageSprite = new BackgroundStageSprite('christmas/evilSnow', -200, 700);
				add(evilSnow);

			case 'school': //Week 6 - Senpai, Roses
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				var bgSky:BackgroundStageSprite = new BackgroundStageSprite('weeb/weebSky', 0, 0, 0.1, 0.1);
				add(bgSky);
				bgSky.antialiasing = false;

				var repositionShit = -200;

				var bgSchool:BackgroundStageSprite = new BackgroundStageSprite('weeb/weebSchool', repositionShit, 0, 0.6, 0.90);
				add(bgSchool);
				bgSchool.antialiasing = false;

				var bgStreet:BackgroundStageSprite = new BackgroundStageSprite('weeb/weebStreet', repositionShit, 0, 0.95, 0.95);
				add(bgStreet);
				bgStreet.antialiasing = false;

				var widShit = Std.int(bgSky.width * 6);

				if (!GlobalSettings.LOW_QUALITY)
				{
					var fgTrees:BackgroundStageSprite = new BackgroundStageSprite('weeb/weebTreesBack', repositionShit + 170, 130, 0.9, 0.9);
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					fgTrees.updateHitbox();
					add(fgTrees);
					fgTrees.antialiasing = false;
				}

				var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
				bgTrees.frames = Paths.getPackerAtlas('weeb/weebTrees');
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);
				bgTrees.antialiasing = false;

				if (!GlobalSettings.LOW_QUALITY)
				{
					var treeLeaves:BackgroundStageSprite = new BackgroundStageSprite('weeb/petals', repositionShit, -40, 0.85, 0.85, ['PETALS ALL'], true);
					treeLeaves.setGraphicSize(widShit);
					treeLeaves.updateHitbox();
					add(treeLeaves);
					treeLeaves.antialiasing = false;
				}

				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));

				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();

				if (!GlobalSettings.LOW_QUALITY)
				{
					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					add(bgGirls);
				}

			case 'schoolEvil': //Week 6 - Thorns
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				var posX = 400;
				var posY = 200;

				if (!GlobalSettings.LOW_QUALITY)
				{
					var bg:BackgroundStageSprite = new BackgroundStageSprite('weeb/animatedEvilSchool', posX, posY, 0.8, 0.9, ['background 2'], true);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);

					bgGhouls = new BackgroundStageSprite('weeb/bgGhouls', -100, 190, 0.9, 0.9, ['BG freaks glitch instance'], false);
					bgGhouls.setGraphicSize(Std.int(bgGhouls.width * daPixelZoom));
					bgGhouls.updateHitbox();
					bgGhouls.visible = false;
					bgGhouls.antialiasing = false;
					add(bgGhouls);
				}
				else
				{
					var bg:BackgroundStageSprite = new BackgroundStageSprite('weeb/animatedEvilSchool_low', posX, posY, 0.8, 0.9);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);
				}

			case 'tank': //Week 7 - Ugh, Guns, Stress
				var sky:BackgroundStageSprite = new BackgroundStageSprite('tankSky', -400, -400, 0, 0);
				add(sky);

				if (!GlobalSettings.LOW_QUALITY)
				{
					var clouds:BackgroundStageSprite = new BackgroundStageSprite('tankClouds', FlxG.random.int(-700, -100), FlxG.random.int(-20, 20), 0.1, 0.1);
					clouds.active = true;
					clouds.velocity.x = FlxG.random.float(5, 15);
					add(clouds);

					var mountains:BackgroundStageSprite = new BackgroundStageSprite('tankMountains', -300, -20, 0.2, 0.2);
					mountains.setGraphicSize(Std.int(1.2 * mountains.width));
					mountains.updateHitbox();
					add(mountains);

					var buildings:BackgroundStageSprite = new BackgroundStageSprite('tankBuildings', -200, 0, 0.3, 0.3);
					buildings.setGraphicSize(Std.int(1.1 * buildings.width));
					buildings.updateHitbox();
					add(buildings);
				}

				var ruins:BackgroundStageSprite = new BackgroundStageSprite('tankRuins',-200,0,.35,.35);
				ruins.setGraphicSize(Std.int(1.1 * ruins.width));
				ruins.updateHitbox();
				add(ruins);

				if (!GlobalSettings.LOW_QUALITY)
				{
					var smokeLeft:BackgroundStageSprite = new BackgroundStageSprite('smokeLeft', -200, -100, 0.4, 0.4, ['SmokeBlurLeft'], true);
					add(smokeLeft);

					var smokeRight:BackgroundStageSprite = new BackgroundStageSprite('smokeRight', 1100, -100, 0.4, 0.4, ['SmokeRight'], true);
					add(smokeRight);

					tankWatchtower = new BackgroundStageSprite('tankWatchtower', 100, 50, 0.5, 0.5, ['watchtower gradient color']);
					add(tankWatchtower);
				}

				tankGround = new BackgroundStageSprite('tankRolling', 300, 300, 0.5, 0.5,['BG tank w lighting'], true);
				add(tankGround);

				tankmanRun = new FlxTypedGroup<TankmenBG>();
				add(tankmanRun);

				var ground:BackgroundStageSprite = new BackgroundStageSprite('tankGround', -420, -150);
				ground.setGraphicSize(Std.int(1.15 * ground.width));
				ground.updateHitbox();
				add(ground);

				moveTank();

				foregroundSprites = new FlxTypedGroup<BackgroundStageSprite>();

				foregroundSprites.add(new BackgroundStageSprite('tank0', -500, 650, 1.7, 1.5, ['fg']));

				if (!GlobalSettings.LOW_QUALITY)
					foregroundSprites.add(new BackgroundStageSprite('tank1', -300, 750, 2, 0.2, ['fg']));

				foregroundSprites.add(new BackgroundStageSprite('tank2', 450, 940, 1.5, 1.5, ['foreground']));

				if (!GlobalSettings.LOW_QUALITY)
					foregroundSprites.add(new BackgroundStageSprite('tank4', 1300, 900, 1.5, 1.5, ['fg']));

				foregroundSprites.add(new BackgroundStageSprite('tank5', 1620, 700, 1.5, 1.5, ['fg']));

				if (!GlobalSettings.LOW_QUALITY)
					foregroundSprites.add(new BackgroundStageSprite('tank3', 1300, 1200, 3.5, 2.5, ['fg']));
		}
	}

	function set_songSpeed(value:Float):Float
	{
		if (generatedMusic) {
			var ratio:Float = value / songSpeed; //funny word huh

			for (note in notes) {
				note.resizeByRatio(ratio);
			}

			for (note in unspawnNotes) {
				note.resizeByRatio(ratio);
			}
		}

		songSpeed = value;
		noteKillOffset = 350 / songSpeed;

		return value;
	}

	function set_playbackRate(value:Float):Float
	{
		if(generatedMusic) {
			FunkinSound.setVoicesPitch(value);
			FunkinSound.setInstPitch(value);
		}

		playbackRate = value;

		FlxAnimationController.globalSpeed = value;

		trace('Anim speed: ' + FlxAnimationController.globalSpeed);
		Conductor.safeZoneOffset = (GlobalSettings.SAFE_FRAMES / 60) * 1000 * value;
		setOnLuas('playbackRate', playbackRate);

		return value;
	}

	public function addTextToDebug(text:String, color:FlxColor):Void
	{
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});

		if (luaDebugGroup.members.length > 34) {
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}

		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup, color));
		#end
	}

	public function addCharacterToList(newCharacter:String, type:Int):Void
	{
		switch (type)
		{
			case 0:
				if (!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					newBoyfriend.scrollFactor.set();
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if (!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					newDad.scrollFactor.set();
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if (gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					// newGf.scrollFactor.set(0.95, 0.95);
					newGf.scrollFactor.set();
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
				}
		}
	}

	function startCharacterLua(name:String):Void
	{
		#if LUA_ALLOWED
		LuaLoader.loadCharacterScript(name);
		#end
	}

	public function getLuaObject(tag:String, text:Bool=true):FlxSprite
	{
		if (modchartSprites.exists(tag))
			return modchartSprites.get(tag);

		if (text && modchartTexts.exists(tag))
			return modchartTexts.get(tag);

		if (variables.exists(tag))
			return variables.get(tag);

		return null;
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false):Void
	{
		if (gfCheck && char.curCharacter.startsWith('gf')) {
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}

		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String):Void
	{
		#if VIDEOS_ALLOWED
		inCutscene = true;
		var video:FunkinVideo = new FunkinVideo();
		video.start(name, startAndEnd);
		#end
	}

	function startAndEnd():Void
	{
		if (endingSong) {
			endSong();
		} else {
			startCountdown();
		}
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if (psychDialogue != null)
			return;

		if (dialogueFile.dialogue.length > 0)
		{
			inCutscene = true;
			precacheList.set('dialogue', 'sound');
			precacheList.set('dialogueClose', 'sound');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();

			if (endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}

			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];

			add(psychDialogue);
		}
		else
		{
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				endSong();
			} else {
				startCountdown();
			}
		}
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += 300;

		var songName:String = Paths.formatToSongPath(SONG.song);

		if (songName == 'roses' || songName == 'thorns') {
			remove(black);
			if (songName == 'thorns') {
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					if (Paths.formatToSongPath(SONG.song) == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
				{
					startCountdown();
				}

				remove(black);
			}
		});
	}

	function tankIntro():Void
	{
		var cutsceneHandler:CutsceneHandler = new CutsceneHandler();

		var songName:String = Paths.formatToSongPath(SONG.song);
		dadGroup.alpha = 0.00001;
		camHUD.visible = false;

		var tankman:FlxSprite = new FlxSprite(-20, 320);
		tankman.frames = Paths.getSparrowAtlas('cutscenes/' + songName);
		tankman.antialiasing = GlobalSettings.SPRITE_ANTIALIASING;
		SpriteLayersHandler.addBehind(this, CharacterLayers.DAD, tankman);

		var tankman2:FlxSprite = new FlxSprite(16, 312);
		tankman2.alpha = 0.000001;

		var gfDance:FlxSprite = new FlxSprite(gf.x - 107, gf.y + 140);

		var gfCutscene:FlxSprite = new FlxSprite(gf.x - 104, gf.y + 122);

		var picoCutscene:FlxSprite = new FlxSprite(gf.x - 849, gf.y - 264);

		var boyfriendCutscene:FlxSprite = new FlxSprite(boyfriend.x + 5, boyfriend.y + 20);

		cutsceneHandler.push(tankman);
		cutsceneHandler.push(tankman2);
		cutsceneHandler.push(gfDance);
		cutsceneHandler.push(gfCutscene);
		cutsceneHandler.push(picoCutscene);
		cutsceneHandler.push(boyfriendCutscene);

		cutsceneHandler.finishCallback = function()
		{
			var timeForStuff:Float = Conductor.crochet / 1000 * 4.5;
			FlxG.sound.music.fadeOut(timeForStuff);
			GlobalTweenClass.tween(FlxG.camera, {zoom: defaultCamZoom}, timeForStuff, {ease: FlxEase.quadInOut});
			moveCamera(true);
			startCountdown();

			dadGroup.alpha = 1;
			camHUD.visible = true;
			boyfriend.animation.finishCallback = null;
			gf.animation.finishCallback = null;
			gf.dance();
		};

		camFollow.set(dad.x + 280, dad.y + 170);
		switch(songName)
		{
			case 'ugh':
				cutsceneHandler.endTime = 12;
				cutsceneHandler.music = 'DISTORTO';
				precacheList.set('wellWellWell', 'sound');
				precacheList.set('killYou', 'sound');
				precacheList.set('bfBeep', 'sound');

				var wellWellWell:FlxSound = new FlxSound().loadEmbedded(Paths.sound('wellWellWell'));
				FlxG.sound.list.add(wellWellWell);

				tankman.animation.addByPrefix('wellWell', 'TANK TALK 1 P1', 24, false);
				tankman.animation.addByPrefix('killYou', 'TANK TALK 1 P2', 24, false);
				tankman.animation.play('wellWell', true);
				FlxG.camera.zoom *= 1.2;

				// Well well well, what do we got here?
				cutsceneHandler.timer(0.1, function() {
					wellWellWell.play(true);
				});

				// Move camera to BF
				cutsceneHandler.timer(3, function() {
					camFollow.x += 750;
					camFollow.y += 100;
				});

				// Beep!
				cutsceneHandler.timer(4.5, function() {
					boyfriend.playAnim('singUP', true);
					boyfriend.specialAnim = true;
					FlxG.sound.play(Paths.sound('bfBeep'));
				});

				// Move camera to Tankman
				cutsceneHandler.timer(6, function() {
					camFollow.x -= 750;
					camFollow.y -= 100;

					// We should just kill you but... what the hell, it's been a boring day... let's see what you've got!
					tankman.animation.play('killYou', true);

					FlxG.sound.play(Paths.sound('killYou'));
				});

			case 'guns':
				cutsceneHandler.endTime = 11.5;
				cutsceneHandler.music = 'DISTORTO';
				tankman.x += 40;
				tankman.y += 10;
				precacheList.set('tankSong2', 'sound');

				var tightBars:FlxSound = new FlxSound().loadEmbedded(Paths.sound('tankSong2'));
				FlxG.sound.list.add(tightBars);

				tankman.animation.addByPrefix('tightBars', 'TANK TALK 2', 24, false);
				tankman.animation.play('tightBars', true);
				boyfriend.animation.curAnim.finish();

				cutsceneHandler.onStart = function() {
					tightBars.play(true);
					GlobalTweenClass.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 4, {ease: FlxEase.quadInOut});
					GlobalTweenClass.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2 * 1.2}, 0.5, {ease: FlxEase.quadInOut, startDelay: 4});
					GlobalTweenClass.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 1, {ease: FlxEase.quadInOut, startDelay: 4.5});
				};

				cutsceneHandler.timer(4, function() {
					gf.playAnim('sad', true);

					gf.animation.finishCallback = function(name:String) {
						gf.playAnim('sad', true);
					};
				});

			case 'stress':
				cutsceneHandler.endTime = 35.5;
				tankman.x -= 54;
				tankman.y -= 14;
				gfGroup.alpha = 0.00001;
				boyfriendGroup.alpha = 0.00001;
				camFollow.set(dad.x + 400, dad.y + 170);
				GlobalTweenClass.tween(FlxG.camera, {zoom: 0.9 * 1.2}, 1, {ease: FlxEase.quadInOut});

				foregroundSprites.forEach(function(spr:BackgroundStageSprite) {
					spr.y += 100;
				});

				precacheList.set('stressCutscene', 'sound');

				tankman2.frames = Paths.getSparrowAtlas('cutscenes/stress2');

				SpriteLayersHandler.addBehind(this, CharacterLayers.DAD, tankman2);

				if (!GlobalSettings.LOW_QUALITY) {
					gfDance.frames = Paths.getSparrowAtlas('characters/gfTankmen');
					gfDance.animation.addByPrefix('dance', 'GF Dancing at Gunpoint', 24, true);
					gfDance.animation.play('dance', true);
					SpriteLayersHandler.addBehind(this, CharacterLayers.GF, gfDance);
				}

				gfCutscene.frames = Paths.getSparrowAtlas('cutscenes/stressGF');
				gfCutscene.animation.addByPrefix('dieBitch', 'GF STARTS TO TURN PART 1', 24, false);
				gfCutscene.animation.addByPrefix('getRektLmao', 'GF STARTS TO TURN PART 2', 24, false);
				gfCutscene.animation.play('dieBitch', true);
				gfCutscene.animation.pause();

				if (!GlobalSettings.LOW_QUALITY) {
					gfCutscene.alpha = 0.00001;
				}

				picoCutscene.frames = AtlasFrameMaker.construct('cutscenes/stressPico');
				picoCutscene.animation.addByPrefix('anim', 'Pico Badass', 24, false);
				picoCutscene.alpha = 0.00001;

				boyfriendCutscene.frames = Paths.getSparrowAtlas('characters/BOYFRIEND');
				boyfriendCutscene.animation.addByPrefix('idle', 'BF idle dance', 24, false);
				boyfriendCutscene.animation.play('idle', true);
				boyfriendCutscene.animation.curAnim.finish();

				SpriteLayersHandler.addListOfObjectsBehind(this, CharacterLayers.GF,
					[ gfCutscene, picoCutscene, boyfriendCutscene ]
				);

				var cutsceneSnd:FlxSound = new FlxSound().loadEmbedded(Paths.sound('stressCutscene'));
				FlxG.sound.list.add(cutsceneSnd);

				tankman.animation.addByPrefix('godEffingDamnIt', 'TANK TALK 3', 24, false);
				tankman.animation.play('godEffingDamnIt', true);

				var calledTimes:Int = 0;

				var zoomBack:Void->Void = function() {
					var camPosX:Float = 630;
					var camPosY:Float = 425;
					camFollow.set(camPosX, camPosY);
					camFollowPos.setPosition(camPosX, camPosY);
					FlxG.camera.zoom = 0.8;
					cameraSpeed = 1;

					calledTimes++;

					if (calledTimes > 1) {
						foregroundSprites.forEach(function(spr:BackgroundStageSprite) {
							spr.y -= 100;
						});
					}
				}

				cutsceneHandler.onStart = function() {
					cutsceneSnd.play(true);
				};

				cutsceneHandler.timer(15.2, function()
				{
					GlobalTweenClass.tween(camFollow, {x: 650, y: 300}, 1, {ease: FlxEase.sineOut});
					GlobalTweenClass.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 2.25, {ease: FlxEase.quadInOut});

					gfDance.visible = false;
					gfCutscene.alpha = 1;
					gfCutscene.animation.play('dieBitch', true);
					gfCutscene.animation.finishCallback = function(name:String)
					{
						if (name == 'dieBitch') //Next part
						{
							gfCutscene.animation.play('getRektLmao', true);
							gfCutscene.offset.set(224, 445);
						}
						else
						{
							gfCutscene.visible = false;
							picoCutscene.alpha = 1;
							picoCutscene.animation.play('anim', true);

							boyfriendGroup.alpha = 1;
							boyfriendCutscene.visible = false;

							boyfriend.playAnim('bfCatch', true);

							boyfriend.animation.finishCallback = function(name:String) {
								if(name != 'idle') {
									boyfriend.playAnim('idle', true);
									boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
								}
							};

							picoCutscene.animation.finishCallback = function(name:String) {
								picoCutscene.visible = false;
								gfGroup.alpha = 1;
								picoCutscene.animation.finishCallback = null;
							};

							gfCutscene.animation.finishCallback = null;
						}
					};
				});

				cutsceneHandler.timer(17.5, function() {
					zoomBack();
				});

				cutsceneHandler.timer(19.5, function() {
					tankman2.animation.addByPrefix('lookWhoItIs', 'TANK TALK 3', 24, false);
					tankman2.animation.play('lookWhoItIs', true);
					tankman2.alpha = 1;
					tankman.visible = false;
				});

				cutsceneHandler.timer(20, function() {
					camFollow.set(dad.x + 500, dad.y + 170);
				});

				cutsceneHandler.timer(31.2, function() {
					boyfriend.playAnim('singUPmiss', true);

					boyfriend.animation.finishCallback = function(name:String) {
						if (name == 'singUPmiss') {
							boyfriend.playAnim('idle', true);
							boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
						}
					};

					camFollow.set(boyfriend.x + 280, boyfriend.y + 200);
					cameraSpeed = 12;
					GlobalTweenClass.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 0.25, {ease: FlxEase.elasticOut});
				});

				cutsceneHandler.timer(32.2, function()
				{
					zoomBack();
				});
		}
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	function cacheCountdown():Void
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		introAssets.set('default', ['ready', 'set', 'go']);
		introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

		var introAlts:Array<String> = introAssets.get('default');
		if (isPixelStage)
			introAlts = introAssets.get('pixel');

		for (asset in introAlts)
			Paths.image(asset);

		final introSoundsCacheArray:Array<String> = [ 'intro3', 'intro2', 'intro1', 'introGo' ];

		for (i in 0...introSoundsCacheArray.length) {
			Paths.sound('${introSoundsCacheArray[i]}${introSoundsSuffix}');
		}
	}

	public function startCountdown():Void
	{
		if (startedCountdown) {
			callOnLuas('onStartCountdown', []);
			return;
		}

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', [], false);
		if (ret != FunkinLua.Function_Stop)
		{
			if (skipCountdown || startOnTime > 0) {
				skipArrowStartTween = true;
			}

			if (GlobalSettings.MIDDLESCROLL) {
				var opponentNoteAlpha:Float = 0.35;
				if (!GlobalSettings.MIDDLESCROLL_OPPONENT_NOTES) {
					opponentNoteAlpha = 0.0;
				}
				generateStaticArrows('dad', opponentNoteAlpha);
			} else {
				generateStaticArrows('dad', Constants.NOTE_ALPHA);
			}

			generateStaticArrows('bf', Constants.NOTE_ALPHA);

			// NoteMovement.getDefaultStrumPos(this);

			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}

			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
			}

			startedCountdown = true;
			Conductor.songPosition = -Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);
			callOnLuas('onCountdownStarted', []);

			var swagCounter:Int = 0;

			if (startOnTime < 0)
				startOnTime = 0;

			if (startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
				return;
			} else if (skipCountdown) {
				setSongTime(0);
				return;
			}

			startTimer = new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
			{
				if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned) {
					gf.dance();
				}

				if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned) {
					boyfriend.dance();
				}

				if (tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned) {
					dad.dance();
				}

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias = GlobalSettings.SPRITE_ANTIALIASING;
				if (isPixelStage) {
					introAlts = introAssets.get('pixel');
					antialias = false;
				}

				if (curStage == 'mall') {
					if (!GlobalSettings.LOW_QUALITY) {
						upperBoppers.dance(true);
					}
					bottomBoppers.dance(true);
					santa.dance(true);
				}

				var countdown:Countdown = new Countdown(0, 0, (GlobalSettings.SPRITE_ANTIALIASING && !PlayState.isPixelStage), introAlts);
				countdown.soundSuffix = introSoundsSuffix;
				countdown.cameras = [camHUD];
				insert(members.indexOf(notes), countdown);
				countdown.startCountdown(swagCounter, !PlayState.SONG_METADATA.hasCountdown, introAlts);

				notes.forEachAlive(function(note:Note) {
					if (GlobalSettings.MIDDLESCROLL_OPPONENT_NOTES) {
						note.copyAlpha = false;
						note.alpha = note.multAlpha;
						if (GlobalSettings.MIDDLESCROLL) {
							note.alpha *= 0.35;
						}
					}
				});

				callOnLuas('onCountdownTick', [swagCounter]);

				swagCounter += 1;
			}, 5);
		}
	}

	public function clearNotesBefore(time:Float):Void
	{
		var i:Int = unspawnNotes.length - 1;

		while (i >= 0)
		{
			var daNote:Note = unspawnNotes[i];

			if (daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;
				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}

			--i;
		}

		i = notes.length - 1;

		while (i >= 0)
		{
			var daNote:Note = notes.members[i];

			if (daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;
				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}

			--i;
		}
	}

	// Keeping this because I just feel bad for not having code here anymore lol
	public function updateScore(miss:Bool = false)
	{
		callOnLuas('onUpdateScore', [miss]);
	}

	public function setSongTime(time:Float)
	{
		if (time < 0) {
			time = 0;
		}

		FunkinSound.setSoundTime(time);

		Conductor.songPosition = time;
		songTime = time;
	}

	function startNextDialogue():Void
	{
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue():Void
	{
		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FunkinSound.setVolume(Constants.INSTRUMENTAL_VOLUME, 'instrumental');

		FunkinSound.start();

		if(startOnTime > 0) {
			setSongTime(startOnTime - 500);
		}

		startOnTime = 0;

		if(paused) {
			FunkinSound.pauseSong();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		timeBar.showTimeBar();

		switch(curStage)
		{
			case 'tank':
				if (!GlobalSettings.LOW_QUALITY)
					tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BackgroundStageSprite) {
					spr.dance();
				});
		}

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength);
		#end

		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeedType = Preferences.getGameplaySetting('scrolltype','multiplicative');

		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * Preferences.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = Preferences.getGameplaySetting('scrollspeed', 1);
		}

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		FunkinSound.loadSong(PlayState.SONG.song);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		SongLoader.loadSongEvents(PlayState.SONG.song);

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
					gottaHitNote = !section.mustHitSection;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];

				if (!Std.isOfType(songNotes[3], String))
					swagNote.noteType = ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts

				swagNote.scrollFactor.set();

				unspawnNotes.push(swagNote);

				NoteHandler.evaluateSustainNote(swagNote, oldNote, section, songNotes, daNoteData, daStrumTime, gottaHitNote);

				if (swagNote.mustPress) {
					swagNote.x += FlxG.width / 2; // general offset
				} else if (GlobalSettings.MIDDLESCROLL) {
					swagNote.x += 310;
					if (daNoteData > 1) { // Up and Right
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				if (!noteTypeMap.exists(swagNote.noteType)) {
					noteTypeMap.set(swagNote.noteType, true);
				}
			}

			daBeats += 1;
		}

		unspawnNotes.sort(sortByShit);

		if(eventNotes.length > 1) { // No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}

		checkEventNote();

		generatedMusic = true;
	}

	public function eventPushed(event:EventNote) {
		switch(event.event)
		{
			case 'Change Character':
				var charType:Int = 0;

				switch(event.value1.toLowerCase())
				{
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if (Math.isNaN(charType))
							charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);

			case 'Dadbattle Spotlight':
				dadbattleBlack = new BackgroundStageSprite(null, -800, -400, 0, 0);
				dadbattleBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				dadbattleBlack.alpha = 0.25;
				dadbattleBlack.visible = false;
				add(dadbattleBlack);

				dadbattleLight = new BackgroundStageSprite('spotlight', 400, -400);
				dadbattleLight.alpha = 0.375;
				dadbattleLight.blend = ADD;
				dadbattleLight.visible = false;

				dadbattleSmokes.alpha = 0.7;
				dadbattleSmokes.blend = ADD;
				dadbattleSmokes.visible = false;
				add(dadbattleLight);
				add(dadbattleSmokes);

				var offsetX = 200;
				var smoke:BackgroundStageSprite = new BackgroundStageSprite('smoke', -1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(15, 22);
				smoke.active = true;
				dadbattleSmokes.add(smoke);
				var smoke:BackgroundStageSprite = new BackgroundStageSprite('smoke', 1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(-15, -22);
				smoke.active = true;
				smoke.flipX = true;
				dadbattleSmokes.add(smoke);

			case 'Philly Glow':
				blammedLightsBlack = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				blammedLightsBlack.visible = false;
				insert(members.indexOf(phillyStreet), blammedLightsBlack);

				phillyWindowEvent = new BackgroundStageSprite('philly/window', phillyWindow.x, phillyWindow.y, 0.3, 0.3);
				phillyWindowEvent.setGraphicSize(Std.int(phillyWindowEvent.width * 0.85));
				phillyWindowEvent.updateHitbox();
				phillyWindowEvent.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyWindowEvent);

				phillyGlowGradient = new PhillyGlow.PhillyGlowGradient(-400, 225); //This shit was refusing to properly load FlxGradient so fuck it
				phillyGlowGradient.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyGlowGradient);
				if (!GlobalSettings.FLASHING_LIGHTS) {
					phillyGlowGradient.intendedAlpha = 0.7;
				}

				precacheList.set('philly/particle', 'image'); //precache particle image
				phillyGlowParticles = new FlxTypedGroup<PhillyGlow.PhillyGlowParticle>();
				phillyGlowParticles.visible = false;
				insert(members.indexOf(phillyGlowGradient) + 1, phillyGlowParticles);
		}

		if (!eventPushedMap.exists(event.event)) {
			eventPushedMap.set(event.event, true);
		}
	}

	public function eventNoteEarlyTrigger(event:EventNote):Float
	{
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event.event]);

		if (returnedValue != 0)
			return returnedValue;

		switch(event.event) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}

		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	private function generateStaticArrows(playerId:Null<String> = '', ?alphaOverride:Null<Float> = 1.0):Void
	{
		if (playerId == null || playerId == '')
			return;

		for (i in 0...4)
		{
			var targetAlpha:Float = alphaOverride;

			var player:Int = 0;

			switch (playerId) {
				case 'bf' | 'player':
					player = 1;
				case 'dad' | 'opponent':
					player = 0;
			}

			var babyArrow:StrumNote = new StrumNote(GlobalSettings.MIDDLESCROLL ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);

			babyArrow.downScroll = GlobalSettings.DOWNSCROLL;

			if (!isStoryMode && !skipArrowStartTween) {
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				GlobalTweenClass.tween(babyArrow, {y: babyArrow.y + 10, alpha: targetAlpha}, 1, {
					ease: FlxEase.circOut,
					startDelay: 0.5 + (0.2 * i)
				});
			} else {
				babyArrow.alpha = targetAlpha;
			}

			if (player == 1) {
				playerStrums.add(babyArrow);
			} else {
				if (GlobalSettings.MIDDLESCROLL) {
					babyArrow.x += 310;
					if (i > 1) {
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			GlobalTweenClass.globalManager.active = false;

			if (FlxG.sound.music != null) {
				FunkinSound.pauseSong();
			}

			FunkinUtil.toggleListOfTimers([
				startTimer, finishTimer, songPopUp.animationTimer
			]);

			if (carTimer != null)
				carTimer.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = false;
				}
			}

			toggleModchartTimersAndTweens(false);
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			GlobalTweenClass.globalManager.active = true;

			if (FlxG.sound.music != null && !startingSong) {
				FunkinSound.resumeSong();
			}

			FunkinUtil.toggleListOfTimers([
				startTimer, finishTimer, songPopUp.animationTimer
			]);

			if (carTimer != null)
				carTimer.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];

			for (char in chars) {
				if (char != null && char.colorTween != null) {
					char.colorTween.active = true;
				}
			}

			toggleModchartTimersAndTweens(true);

			paused = false;

			callOnLuas('onResume', []);

			#if desktop
			if (startTimer != null && startTimer.finished) {
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - GlobalSettings.NOTE_OFFSET);
			} else {
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > Constants.HEALTH_MIN && !paused) {
			if (Conductor.songPosition > 0.0) {
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - GlobalSettings.NOTE_OFFSET);
			} else {
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > Constants.HEALTH_MIN  && !paused) {
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	public function toggleModchartTimersAndTweens(?v:Bool = true):Void
	{
		for (tween in modchartTweens)
			tween.active = v;
		for (timer in modchartTimers)
			timer.active = v;
	}

	public var paused:Bool = false;
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var limoSpeed:Float = 0;
	override public function update(elapsed:Float)
	{
		/*if (FlxG.keys.justPressed.NINE)
		{
			iconP1.swapOldIcon();
		}*/

		callOnLuas('onUpdate', [elapsed]);

		switch (curStage)
		{
			case 'tank':
				moveTank(elapsed);
			case 'schoolEvil':
				if (!GlobalSettings.LOW_QUALITY && bgGhouls.animation.curAnim.finished) {
					bgGhouls.visible = false;
				}

				vcrEffect.setGlitchModifier(0.005);

			case 'school':
				vcrEffect.setGlitchModifier(0.0001);
				vcrEffect.setVignette(false);
				vcrEffect.setVignetteMoving(false);

			case 'philly':
				if (trainMoving) {
					trainFrameTiming += elapsed;
					if (trainFrameTiming >= 1 / 24) {
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}

				phillyWindow.alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;

				if (phillyGlowParticles != null)
				{
					var i:Int = phillyGlowParticles.members.length-1;
					while (i > 0)
					{
						var particle = phillyGlowParticles.members[i];
						if(particle.alpha < 0)
						{
							particle.kill();
							phillyGlowParticles.remove(particle, true);
							particle.destroy();
						}
						--i;
					}
				}

				var cameraShakeIntensity = 0.00175;

				aberrationEffect.setOffset(
					((doPhillyCAB) ? FlxG.random.float(0.001, 0.005) : 0.0)
				);

				if (doPhillyCAB) {
					cameraShakeIntensity += (cameraShakeIntensity / 24);
					camGame.shake(cameraShakeIntensity, 0.5);
					camHUD.shake(cameraShakeIntensity, 0.5);
				}

			case 'limo':
				if (!GlobalSettings.LOW_QUALITY) {
					grpLimoParticles.forEach(function(spr:BackgroundStageSprite) {
						if(spr.animation.curAnim.finished) {
							spr.kill();
							grpLimoParticles.remove(spr, true);
							spr.destroy();
						}
					});

					switch(limoKillingState)
					{
						case 1:
							limoMetalPole.x += 5000 * elapsed;
							limoLight.x = limoMetalPole.x - 180;
							limoCorpse.x = limoLight.x - 50;
							limoCorpseTwo.x = limoLight.x + 35;

							var dancers:Array<BackgroundDancer> = grpLimoDancers.members;

							for (i in 0...dancers.length)
							{
								if (dancers[i].x < FlxG.width * 1.5 && limoLight.x > (370 * i) + 170)
								{
									switch(i)
									{
										case 0 | 3:
											if (i == 0) FlxG.sound.play(Paths.sound('dancerdeath'), 0.5);

											var diffStr:String = i == 3 ? ' 2 ' : ' ';
											var particle:BackgroundStageSprite = new BackgroundStageSprite('gore/noooooo', dancers[i].x + 200, dancers[i].y, 0.4, 0.4, ['hench leg spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BackgroundStageSprite = new BackgroundStageSprite('gore/noooooo', dancers[i].x + 160, dancers[i].y + 200, 0.4, 0.4, ['hench arm spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BackgroundStageSprite = new BackgroundStageSprite('gore/noooooo', dancers[i].x, dancers[i].y + 50, 0.4, 0.4, ['hench head spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);

											var particle:BackgroundStageSprite = new BackgroundStageSprite('gore/stupidBlood', dancers[i].x - 110, dancers[i].y + 20, 0.4, 0.4, ['blood'], false);
											particle.flipX = true;
											particle.angle = -57.5;
											grpLimoParticles.add(particle);
										case 1:
											limoCorpse.visible = true;
										case 2:
											limoCorpseTwo.visible = true;
									} //Note: Nobody cares about the fifth dancer because he is mostly hidden offscreen :(

									dancers[i].x += FlxG.width * 2;
								}
							}

							if(limoMetalPole.x > FlxG.width * 2) {
								resetLimoKill();
								limoSpeed = 800;
								limoKillingState = 2;
							}

						case 2:
							limoSpeed -= 4000 * elapsed;
							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x > FlxG.width * 1.5) {
								limoSpeed = 3000;
								limoKillingState = 3;
							}

						case 3:
							limoSpeed -= 2000 * elapsed;
							if(limoSpeed < 1000) limoSpeed = 1000;

							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x < -275) {
								limoKillingState = 4;
								limoSpeed = 800;
							}

						case 4:
							bgLimo.x = FlxMath.lerp(bgLimo.x, -150, FunkinUtil.boundTo(elapsed * 9, 0, 1));
							if(Math.round(bgLimo.x) == -150) {
								bgLimo.x = -150;
								limoKillingState = 0;
							}
					}

					if (limoKillingState > 2) {
						var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
						for (i in 0...dancers.length) {
							dancers[i].x = (370 * i) + bgLimo.x + 280;
						}
					}
				}

			case 'mall':
				if (heyTimer > 0) {
					heyTimer -= elapsed;
					if (heyTimer <= 0) {
						bottomBoppers.dance(true);
						heyTimer = 0;
					}
				}
		}

		/**
		 * Directional Camera Movement.
		 */
		final cameraOffsetAmount:Float = 18 + (defaultCamZoom * 1.5) + 0.5;

		if (GlobalSettings.DIRECTIONAL_CAMERA_MOVEMENT) {
			moveCameraToDirection(cameraOffsetAmount, focusedCharacter);
		}

		if (!inCutscene)
		{
			var lerpVal:Float = FunkinUtil.boundTo(Math.abs(elapsed * 2.4) * cameraSpeed * playbackRate, 0, 1);

			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x + animOffsetX, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y + animOffsetY, lerpVal));

			if (!startingSong && !endingSong && boyfriend.animation.curAnim != null && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if (boyfriendIdleTime >= 0.15) {
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}

		super.update(elapsed);

		/**
		 * Play the Song Credits Pop-up animation.
		 */
		if (finishedCountdown)
			songPopUp.playAnimation();

		/**
		 * Shader updates / update calls.
		 */
		 if (GlobalSettings.SHADERS)
		{
			switch (curStage) {
				case 'school' | 'schoolEvil':
					vcrEffect.update(elapsed);
			}

			grayscale.update(elapsed);

			noteWiggle.waveSpeed = noteWiggleSpeed;
			noteWiggle.waveFrequency = noteWiggleFrequency;
			noteWiggle.waveAmplitude = lerpAmplitude;
		}

		noteWiggle.update(elapsed);

		/**
		 * Set any HUD-related cameras to camHUD.
		 */
		setCameraRelative(camSus, camHUD);
		setCameraRelative(camStrum, camHUD);
		setCameraRelative(camNotes, camHUD);

		/**
		 * Combo caps and combo peak.
		 */
		if (combo >= Constants.GLOBAL_NUMBER_CAP)
			combo = Constants.GLOBAL_NUMBER_CAP;
		if (combo > comboPeak)
			comboPeak = combo;

		// Smooth linear interpolation on the health.
		if (health > Constants.HEALTH_MAX)
			health = Constants.HEALTH_MAX;
		if (health < Constants.HEALTH_MIN)
			health = Constants.HEALTH_MIN;

		displayedHealth = FlxMath.lerp(displayedHealth, health, .15);

		// Smooth linear interpolation on the time.
		lerpTime = FlxMath.lerp(lerpTime, songPercent, .15);

		// Update the healthBar's value.
		healthBar.updateHealth(displayedHealth);

		// Update the timeBar's value.
		timeBar.adjustTime(lerpTime);

		// Update Judgement Counter ratings.
		judgementCounter.updateJudgementCounter();

		// Added a cool global tween class. (Basically modified FlxTween, thanks for @Quackerona for teaching me this a while back)
		GlobalTweenClass.globalManager.update(elapsed);

		if (combo >= 10)
			showCombo = true;

		// Multipliers for score and misses.
		Scoring.updateMultipliers();

		setOnLuas('curDecStep', curDecStep);
		setOnLuas('curDecBeat', curDecBeat);

		if (botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			var alphaSine:Float = 1 - Math.sin((Math.PI * botplaySine) / 180);
			botplayTxt.alpha = alphaSine;
		}

		if (controls.PAUSE && startedCountdown && canPause) {
			var ret:Dynamic = callOnLuas('onPause', [], false);
			if (ret != FunkinLua.Function_Stop) {
				openPauseMenu();
			}
		}

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene) {
			FlxG.mouse.visible = true;
			openChartEditor();
		}

		iconP1.scaleIcon(FlxMath.lerp(1, iconP1.scale.x, FunkinUtil.boundTo(1 - (elapsed * Constants.ICON_BOP_BEATDECAY * playbackRate), 0, 1)));
		iconP1.offsetIcon(Constants.ICON_OFFSET, true);
		iconP1.updateHealthIcon();

		iconP2.scaleIcon(FlxMath.lerp(1, iconP2.scale.x, FunkinUtil.boundTo(1 - (elapsed * Constants.ICON_BOP_BEATDECAY * playbackRate), 0, 1)));
		iconP2.offsetIcon(Constants.ICON_OFFSET, false);
		iconP2.updateHealthIcon();

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene)
		{
			FlxG.mouse.visible = true;
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}

		if (startedCountdown) {
			Conductor.songPosition += FlxG.elapsed * 1000 * playbackRate;
		}

		if (startingSong)
		{
			if (startedCountdown && Conductor.songPosition >= 0)
				startSong();
			else if (!startedCountdown)
				Conductor.songPosition = -Conductor.crochet * 5;
		}
		else
		{
			if (!paused)
			{
				songTime += TimeUtil.getTicks(previousFrameTime);

				previousFrameTime = FlxG.game.ticks;

				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = TimeUtil.adjustSongTime(songTime);
					Conductor.lastSongPos = Conductor.songPosition;
				}

				if (updateTime)
				{
					var curTime:Float = TimeUtil.adjustConductorTime();

					if (curTime < 0) {
						curTime = 0;
					}

					songPercent = (curTime / songLength);

					timeBar.updateTimeBarText(
						GlobalSettings.TIME_BAR_DISPLAY,
						Std.int(curTime),
						Std.int(songLength)
					);
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, FunkinUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
			camHUD.zoom = FlxMath.lerp(Constants.CAMERA_HUD_ZOOM, camHUD.zoom, FunkinUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
		}

		if (PlayState.SONG_METADATA.hasNoteWiggle) {
			lerpAmplitude = FlxMath.lerp(lerpAmplitude, 0.0005, elapsed * noteWiggleAmplitudeDecay);
		}

		#if (debug)
		FlxG.watch.addQuick("Current Section", curSection);
		FlxG.watch.addQuick("Current Beat", curBeat);
		FlxG.watch.addQuick("Current Step", curStep);
		#end

		if (!GlobalSettings.NO_RESET && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong) {
			health = Constants.HEALTH_MIN;
		}

		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime;
			if(songSpeed < 1) time /= songSpeed;
			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned=true;
				callOnLuas('onSpawnNote', [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote]);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic && !inCutscene)
		{
			if (!cpuControlled)
			{
				keyShit();
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress)
					{
						/**
						 * Bonus score and health when holding notes.
						 */
						health += Constants.HEALTH_HOLD_BONUS * elapsed * healthGain;
						@:privateAccess
						Scoring._increaseScore(Std.int(Constants.SCORE_HOLD_BONUS * elapsed));
					}
				});
			}
			else if (boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
			}

			if (startedCountdown) {
				NoteHandler.updateStrumlines();
			} else {
				notes.forEachAlive(function(daNote:Note) {
					daNote.canBeHit = false;
					daNote.wasGoodHit = false;
				});
			}
		}
		checkEventNote();

		#if debug
		if (!endingSong && !startingSong)
		{
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}

			if (FlxG.keys.justPressed.TWO) {
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		#end

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
	}

	/**
	 * Small wrapper function that allows the base / target camera's properties to be relative with the target camera's properties.
	 */
	private function setCameraRelative(baseCamera:Null<FlxCamera>, targetCamera:Null<FlxCamera>):Void
	{
		if (baseCamera != null && targetCamera != null) {
			baseCamera.zoom = targetCamera.zoom;
			baseCamera.x = targetCamera.x;
			baseCamera.y = targetCamera.y;
			baseCamera.angle = targetCamera.angle;
			baseCamera.alpha = targetCamera.alpha;
			baseCamera.visible = targetCamera.visible;

		} else {
			return;
		}
	}

	function openPauseMenu()
	{
		#if desktop
		DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end

		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		if (FlxG.sound.music != null)
			FunkinSound.pauseSong();

		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
	}

	function openChartEditor()
	{
		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end

		persistentUpdate = false;
		paused = true;

		cancelMusicFadeTween();

		MusicBeatState.switchState(new ChartingState());

		chartingMode = true;
	}

	function doDeathCheck(?skipHealthCheck:Bool = false):Bool
	{
		if (((skipHealthCheck && instakillOnMiss) || health <= Constants.HEALTH_MIN) && !practiceMode && !isDead)
		{
			var ret:Dynamic = callOnLuas('onGameOver', [], false);

			if (ret != FunkinLua.Function_Stop)
			{
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				FunkinSound.stopSong();

				persistentUpdate = false;
				persistentDraw = false;

				toggleModchartTimersAndTweens(true);

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));

				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end

				isDead = true;

				return true;
			}
		}

		return false;
	}

	public function checkEventNote():Void
	{
		while (eventNotes.length > 0)
		{
			var leStrumTime:Float = eventNotes[0].strumTime;

			if (Conductor.songPosition < leStrumTime)
				break;

			var value1:String = '';
			var value2:String = '';

			if (eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;
			if (eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);

			eventNotes.shift();
		}
	}

	public function getControl(key:String):Bool
	{
		var pressed:Bool = Reflect.getProperty(controls, key);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String)
	{
		switch(eventName)
		{
			case 'Dadbattle Spotlight':
				var val:Null<Int> = Std.parseInt(value1);

				if (val == null)
					val = 0;

				switch(Std.parseInt(value1))
				{
					case 1, 2, 3:
						if (val == 1)
						{
							dadbattleBlack.visible = true;
							dadbattleLight.visible = true;
							dadbattleSmokes.visible = true;
							defaultCamZoom += 0.12;
						}

						var who:Character = dad;
						if (val > 2)
							who = boyfriend;

						dadbattleLight.alpha = 0;

						new FlxTimer().start(0.12, function(tmr:FlxTimer) {
							dadbattleLight.alpha = 0.375;
						});

						dadbattleLight.setPosition(who.getGraphicMidpoint().x - dadbattleLight.width / 2, who.y + who.height - dadbattleLight.height + 50);

					default:
						dadbattleBlack.visible = false;
						dadbattleLight.visible = false;
						defaultCamZoom -= 0.12;

						GlobalTweenClass.tween(dadbattleSmokes, {alpha: 0}, 1, {
							onComplete: function(twn:FlxTween) {
								dadbattleSmokes.visible = false;
							}
						});
				}

			case 'Hey!':
				var value:Int = 2;

				switch(value1.toLowerCase().trim())
				{
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);

				if (Math.isNaN(time) || time <= 0)
					time = 0.6;

				if (value != 0)
				{
					if (dad.curCharacter.startsWith('gf')) {
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}

					if (curStage == 'mall') {
						bottomBoppers.animation.play('hey', true);
						heyTimer = time;
					}
				}

				if (value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if (Math.isNaN(value) || value < 1)
					value = 1;
				gfSpeed = value;

			case 'Philly Glow':
				var lightId:Int = Std.parseInt(value1);

				if (Math.isNaN(lightId))
					lightId = 0;

				var doFlash:Void->Void = function() {
					var color:FlxColor = FlxColor.WHITE;

					if (!GlobalSettings.FLASHING_LIGHTS)
						color.alphaFloat = 0.5;

					FlxG.camera.flash(color, 0.15, null, true);
				};

				var chars:Array<Character> = [boyfriend, gf, dad];
				switch(lightId)
				{
					case 0: // OFF
						if (phillyGlowGradient.visible)
						{
							doFlash();

							if (GlobalSettings.CAMERA_ZOOMING) {
								FlxG.camera.zoom += 0.5;
								camHUD.zoom += 0.1;
							}

							doPhillyCAB = false;

							blammedLightsBlack.visible = false;
							phillyWindowEvent.visible = false;
							phillyGlowGradient.visible = false;
							phillyGlowParticles.visible = false;
							curLightEvent = -1;

							for (who in chars) {
								who.color = FlxColor.WHITE;
							}

							phillyStreet.color = FlxColor.WHITE;
						}

					case 1: // ON
						curLightEvent = FlxG.random.int(0, phillyLightsColors.length-1, [curLightEvent]);

						var color:FlxColor = phillyLightsColors[curLightEvent];

						if (!phillyGlowGradient.visible)
						{
							doFlash();

							if (GlobalSettings.CAMERA_ZOOMING) {
								FlxG.camera.zoom += 0.5;
								camHUD.zoom += 0.1;
							}

							blammedLightsBlack.visible = true;
							blammedLightsBlack.alpha = 1;
							phillyWindowEvent.visible = true;
							phillyGlowGradient.visible = true;
							phillyGlowParticles.visible = true;
						}
						else if (GlobalSettings.FLASHING_LIGHTS)
						{
							var colorButLower:FlxColor = color;
							colorButLower.alphaFloat = 0.25;
							FlxG.camera.flash(colorButLower, 0.5, null, true);
						}

						var charColor:FlxColor = color;
						if (!GlobalSettings.FLASHING_LIGHTS)
							charColor.saturation *= 0.5;
						else
							charColor.saturation *= 0.75;

						for (who in chars) {
							who.color = charColor;
						}

						phillyGlowParticles.forEachAlive(function(particle:PhillyGlow.PhillyGlowParticle) {
							particle.color = color;
						});

						phillyGlowGradient.color = color;
						phillyWindowEvent.color = color;

						color.brightness *= 0.5;
						phillyStreet.color = color;

						doPhillyCAB = true;

					case 2: // PARTICLES
						if (!GlobalSettings.LOW_QUALITY)
						{
							var particlesNum:Int = FlxG.random.int(8, 12);
							var width:Float = (2000 / particlesNum);
							var color:FlxColor = phillyLightsColors[curLightEvent];

							for (j in 0...3) {
								for (i in 0...particlesNum) {
									var particle:PhillyGlow.PhillyGlowParticle = new PhillyGlow.PhillyGlowParticle(-400 + width * i + FlxG.random.float(-width / 5, width / 5), phillyGlowGradient.originalY + 200 + (FlxG.random.float(0, 125) + j * 40), color);
									phillyGlowParticles.add(particle);
								}
							}
						}

						phillyGlowGradient.bop();
				}

			case 'Kill Henchmen':
				killHenchmen();

			case 'Add Camera Zoom':
				if (GlobalSettings.CAMERA_ZOOMING && FlxG.camera.zoom < 1.35)
				{
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);

					if (Math.isNaN(camZoom))
						camZoom = 0.015;
					if (Math.isNaN(hudZoom))
						hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Trigger BG Ghouls':
				if (curStage == 'schoolEvil' && !GlobalSettings.LOW_QUALITY) {
					bgGhouls.dance(true);
					bgGhouls.visible = true;
				}

			case 'Play Animation':
				var char:Character = dad;

				switch(value2.toLowerCase().trim())
				{
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);

						if (Math.isNaN(val2))
							val2 = 0;

						if (val2 >= 1) {
							char = boyfriend;
						} else if (val2 >= 2) {
							char = gf;
						}
				}

				if (char != null) {
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				if(camFollow != null)
				{
					var val1:Float = Std.parseFloat(value1);
					var val2:Float = Std.parseFloat(value2);

					if (Math.isNaN(val1))
						val1 = 0;
					if (Math.isNaN(val2))
						val2 = 0;

					isCameraOnForcedPos = false;

					if (!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
						camFollow.x = val1;
						camFollow.y = val2;
						isCameraOnForcedPos = true;
					}
				}

			case 'Alt Idle Animation':
				var char:Character = dad;

				switch(value1.toLowerCase().trim())
				{
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null) {
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];

				for (i in 0...targetsArray.length)
				{
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;

					if (split[0] != null)
						duration = Std.parseFloat(split[0].trim());
					if(split[1] != null)
						intensity = Std.parseFloat(split[1].trim());

					if (Math.isNaN(duration))
						duration = 0;
					if (Math.isNaN(intensity))
						intensity = 0;

					if (duration > 0 && intensity != 0)
						targetsArray[i].shake(intensity, duration);
				}

			case 'Cinematic Border':
				var amount:Float = 0.0;
				var duration:Float = 0.0;
				var ease:String = '';

				var split = value1.split(',');

				if (split[0] != null)
					amount = Std.parseFloat(split[0].trim());
				if (split[1] != null)
					duration = Std.parseFloat(split[1].trim());
				if (value2 != null)
					ease = Std.string(value2);

				if (Math.isNaN(amount) || amount < 0)
					amount = 0;
				if (Math.isNaN(duration) || duration < 0)
					duration = 0;
				if (ease == null || ease == '')
					ease = 'sineInOut';

				if ((amount >= 0.0 && amount <= 1.0) && duration > 0 && (ease != null && ease != ''))
				{
					borderCam.visible = true;

					if (borderCameraTween != null) {
						borderCameraTween.cancel();
					}

					borderCameraTween = GlobalTweenClass.tween(borderCam, {zoom: 1.0 - (1.0 + (amount * -0.25)) + 1.0}, duration / playbackRate, {
						ease: EaseUtil.getFlxEaseByString(ease),
						onComplete: function(_) {
							borderCameraTween = null;
						}
					});

					borderCameraTween.start();
				}

			case 'Grayscale Effect':
				var strength:Float = 0.0;
				var duration:Float = 0.0;
				var delay:Float = 0.0;
				var ease:String = "";

				var split = value1.split(',');

				if (split[0] != null)
					strength = Std.parseFloat(split[0].trim());
				if (split[1] != null)
					duration = Std.parseFloat(split[1].trim());
				if (split[2] != null)
					delay = Std.parseFloat(split[2]);
				if (value2 != null)
					ease = Std.string(value2);

				if (Math.isNaN(strength) || strength < 0)
					strength = 0.5;
				if (Math.isNaN(duration) || duration < 0)
					duration = 1.0;
				if (Math.isNaN(delay) || delay < 0)
					duration = 0.0;
				if (ease == null || ease == "")
					ease = "sineInOut";

				if (strength >= 0 && duration >= 0 && delay >= 0 && ease != null)
				{
					if (GlobalSettings.SHADERS)
					{
						if (grayscaleTween != null) {
							grayscaleTween.cancel();
						}

						grayscaleTween = GlobalTweenClass.tween(grayscale, {strength: strength}, duration / playbackRate, {
							ease: EaseUtil.getFlxEaseByString(ease),
							onComplete: function(_:FlxTween) {
								grayscaleTween = null;
							}
						});

						grayscaleTween.start();
					}
				}

			case 'Instant Camera Zoom':
				if (GlobalSettings.CAMERA_ZOOMING)
				{
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);

					if (Math.isNaN(camZoom))
						camZoom = 0.015;
					if (Math.isNaN(hudZoom))
						hudZoom = 0.03;

					FlxG.camera.zoom = FlxG.camera.zoom + camZoom;
					camHUD.zoom = camHUD.zoom + hudZoom;
				}

			case 'Set Default Camera Zoom':
				var amount:Float = 0.0;
				var multiplier:Float = 0.0;

				if (value1 != null)
					amount = Std.parseFloat(value1.trim());
				if (value2 != null)
					multiplier = Std.parseFloat(value2.trim());

				if (Math.isNaN(amount) || amount < 0)
					amount = 0.9;
				if (Math.isNaN(multiplier) || multiplier < 0)
					multiplier = 1.0;

				if (amount >= 0.0 && multiplier >= 0.0)
					defaultCamZoom = amount * multiplier;

			case 'Camera Flash':
				var strength:Float = 1.0;
				var duration:Float = 0.8;
				var delay:Float = 0.0;
				var ease:String = 'linear';

				var split:Array<String> = null;

				if (value1 != null) {
					split = value1.split(',');
					if (split[0] != null)
						strength = Std.parseFloat(split[0].trim());
					if (split[1] != null)
						duration = Std.parseFloat(split[1].trim());
					if (split[2] != null)
						delay = Std.parseFloat(split[2].trim());
				}

				if (value2 != null)
					ease = Std.string(value2);

				if (GlobalSettings.FLASHING_LIGHTS) {
					if (strength >= 0.0 && duration >= 0.0 && delay >= 0.0 && ease != null) {
						var flashEffect:FlashEffect = new FlashEffect(strength, duration, delay, ease);
						add(flashEffect);
					}
				}

			case 'Change Character':
				var charType:Int = 0;

				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if (boyfriend.curCharacter != value2) {
							if (!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnLuas('boyfriendName', boyfriend.curCharacter);

					case 1:
						if (dad.curCharacter != value2) {
							if (!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;

							dad.alpha = 0.00001;
							dad = dadMap.get(value2);

							if (!dad.curCharacter.startsWith('gf')) {
								if (wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}

							dad.alpha = lastAlpha;

							iconP2.changeIcon(dad.healthIcon);
						}

						setOnLuas('dadName', dad.curCharacter);

					case 2:
						if (gf != null)
						{
							if (gf.curCharacter != value2)
							{
								if (!gfMap.exists(value2)) {
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;

								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}

							setOnLuas('gfName', gf.curCharacter);
						}
				}
				healthBar.reloadColors();

			case 'BG Freaks Expression':
				if (bgGirls != null)
					bgGirls.swapDanceType();

			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
					return;

				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);

				if (Math.isNaN(val1))
					val1 = 1;
				if (Math.isNaN(val2))
					val2 = 0;

				var newValue:Float = SONG.speed * Preferences.getGameplaySetting('scrollspeed', 1) * val1;

				if(val2 <= 0) {
					songSpeed = newValue;
				} else {
					songSpeedTween = GlobalTweenClass.tween(this, {songSpeed: newValue}, val2 / playbackRate, {
						ease: FlxEase.quadInOut,
						onComplete: function (twn:FlxTween) {
							songSpeedTween = null;
						}
					});

					songSpeedTween.start();
				}

			case 'Change Beat Modulo':
				var beatMod:Int = 4;

				if (!Math.isNaN(Std.parseInt(value1)) && Std.parseInt(value1) > 0) {
					beatMod = Std.parseInt(value1);
				}

				beatModulo = beatMod;

			case 'Tween Camera Angle':
				var angle:Float = 0.0;
				var duration:Float = 1.0;
				var delay:Float = 0.0;
				var ease:String = "sineInOut";

				if (value1 != null) {
					var split:Array<String> = value1.split(',');

					if (split[0] != null)
						angle = Std.parseFloat(split[0].trim());
					if (split[1] != null)
						duration = Std.parseFloat(split[1].trim());
					if (split[2] != null)
						delay = Std.parseFloat(split[2].trim());
				}

				if (value2 != null)
					ease = Std.string(value2.trim());

				if (!Math.isNaN(angle) && !Math.isNaN(duration) && !Math.isNaN(delay)) {
					if (angle < 0.0)
						angle = 0.0;
					if (duration < 0.0)
						duration = 0.0;
					if (delay < 0.0)
						delay = 0.0;
				}

				if (ease == null && ease == "")
					ease = "sineInOut";

				if (cameraAngleTween != null)
					cameraAngleTween.cancel();

				cameraAngleTween =  GlobalTweenClass.tween(FlxG.camera, {angle: angle}, duration, {
					startDelay: delay,
					ease: EaseUtil.getFlxEaseByString(ease),
					onComplete: function(_:FlxTween):Void {
						cameraAngleTween = null;
					}
				});

				cameraAngleTween.start();

			case 'Set Property':
				var killMe:Array<String> = value1.split('.');
				if(killMe.length > 1) {
					FunkinLua.setVarInArray(FunkinLua.getPropertyLoopThingWhatever(killMe, true, true), killMe[killMe.length-1], value2);
				} else {
					FunkinLua.setVarInArray(this, value1, value2);
				}
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function moveCameraSection():Void
	 {
		if (SONG.notes[curSection] == null)
			return;

		if (gf != null && SONG.notes[curSection].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnLuas('onMoveCamera', ['gf']);
			return;
		}

		if (!SONG.notes[curSection].mustHitSection) {
			if (focusedCharacter != dad) {
				moveCamera(true);
			}
			callOnLuas('onMoveCamera', ['dad']);
		} else {
			if (focusedCharacter != boyfriend) {
				moveCamera(false);
			}
			callOnLuas('onMoveCamera', ['boyfriend']);
		}
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool):Void
	{
		if (isDad)
		{
			focusedCharacter = dad;
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0];
			camFollow.y += dad.cameraPosition[1];
			tweenCamIn();
		}
		else
		{
			focusedCharacter = boyfriend;
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

			// Directional camera movement fix for certain stages.
			switch(curStage)
			{
				case 'limo':
					camFollow.x = boyfriend.getMidpoint().x - 300;
				case 'mall':
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'school' | 'schoolEvil':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 200;
			}

			camFollow.x -= boyfriend.cameraPosition[0];
			camFollow.y += boyfriend.cameraPosition[1];

			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = GlobalTweenClass.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
				cameraTwn.start();
			}
		}
	}

	function tweenCamIn():Void
	{
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3)
		{
			cameraTwn = GlobalTweenClass.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});

			cameraTwn.start();
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	var directionOffsetMult:Float;

	/**
	 * Small wrapper function for directional camera movement.
	 */
	public function moveCameraToDirection(?globalOffset:Null<Float>, ?focusedCharacter:Null<Character>):Void
	{
		// Set animOffset X and Y to 0 so that it doesn't mess up the offsets way too much. (Bad mistake that I've done before)
		animOffsetX = 0;
		animOffsetY = 0;

		// Check if globalOffset is more than 0 and is not null, otherwise the camera would just not move at all.
		if (globalOffset > 0 && globalOffset != null) {
			directionOffsetMult = (globalOffset * 1.75);
		}

		if (focusedCharacter != null)
		{
			if (focusedCharacter.animation.curAnim != null && directionOffsetMult > 0)
			{
				switch(focusedCharacter.animation.curAnim.name)
				{
					// This takes in the poses of the characters instead of the notes being pressed. (incl. Alt animations)
					case 'singLEFT' | 'singLEFT-alt': // Left Pose of the Character.
						animOffsetX -= directionOffsetMult;
					case 'singRIGHT' | 'singRIGHT-alt': // Right Pose of the Character.
						animOffsetX += directionOffsetMult;
					case 'singUP' | 'singUP-alt': // Up Pose of the Character.
						animOffsetY -= directionOffsetMult;
					case 'singDOWN' | 'singDOWN-alt': // Down Pose of the Character.
						animOffsetY += directionOffsetMult;
				}
			}
		}
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong;

		updateTime = false;

		FunkinSound.setVolume(0, 'instrumental');
		FunkinSound.pauseSong();

		if (GlobalSettings.NOTE_OFFSET <= 0 || ignoreNoteOffset) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(GlobalSettings.NOTE_OFFSET / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}

	public var transitioning = false;

	public function endSong():Void
	{
		if(!startingSong)
		{
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= Constants.HEALTH_MISS_PENALTY * healthLoss;
				}
			});

			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= Constants.HEALTH_MISS_PENALTY * healthLoss;
				}
			}

			if (doDeathCheck()) {
				return;
			}
		}

		canPause = false;
		finishedCountdown = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		Scoring.resetMultipliers();

		deathCounter = 0;
		restartCounter = 0;

		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		@:privateAccess
		if(achievementHandler.ACHIEVEMENT_OBJECT != null) {
			return;
		} else {
			var achieve:String = AchievementsHandler.checkAchievement(AchievementsHandler.DEFAULT_ACHIEVEMENTS);
			if (achieve != null) {
				achievementHandler.awardAchievement(achieve);
				return;
			}
		}
		#end

		var ret:Dynamic = callOnLuas('onEndSong', [], false);

		if (ret != FunkinLua.Function_Stop && !transitioning)
		{
			Scoring.save(PlayState.SONG);

			playbackRate = 1;

			if (chartingMode) {
				openChartEditor();
				return;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;
				campaignMarvs += marvs;
				campaignSicks += sicks;
				campaignGoods += goods;
				campaignBads += bads;
				campaignShits += shits;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					WeekData.loadTheFirstEnabledMod();
					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					cancelMusicFadeTween();

					MusicBeatState.switchState(new StoryMenuState());

					if (!Preferences.getGameplaySetting('practice', false) && !Preferences.getGameplaySetting('botplay', false)) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore) {
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;

						FlxG.save.flush();
					}

					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = FunkinUtil.getDifficultyFilePath();

					var winterHorrorlandNext = (Paths.formatToSongPath(SONG.song) == "eggnog");

					if (winterHorrorlandNext)
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Chart.loadChartData(PlayState.storyPlaylist[0], difficulty, ParseType.SONG);

					FlxG.sound.music.stop();

					if (winterHorrorlandNext) {
						new FlxTimer().start(1.5, function(tmr:FlxTimer) {
							cancelMusicFadeTween();
							LoadingState.loadAndSwitchState(new PlayState());
						});
					} else {
						cancelMusicFadeTween();
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
			else
			{
				WeekData.loadTheFirstEnabledMod();

				cancelMusicFadeTween();

				if (FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}

				MusicBeatState.switchState(new FreeplayState());

				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				changedDifficulty = false;
			}

			transitioning = true;
		}
	}

	public function KillNotes():Void
	{
		while (notes.length > 0)
		{
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}

		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var showCombo:Bool = false;
	public var showTally:Bool = true;
	public var showRating:Bool = true;

	private function cacheScoreProcess():Void
	{
		var spriteArray:Array<String> = [ 'marv', 'sick', 'good', 'bad', 'shit', 'combo' ];

		var pixelPrefix:String = '';
		var pixelSuffix:String = '';

		if (isPixelStage) {
			pixelPrefix = 'pixelUI/';
			pixelSuffix = '-pixel';
		}

		for (i in 0...spriteArray.length - 1) {
			Paths.image('${pixelPrefix}${spriteArray[i]}${pixelSuffix}');
		}

		for (i in 0...10) {
			Paths.image('${pixelPrefix}num${i}${pixelSuffix}');
		}
	}

	private function processScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + GlobalSettings.RATING_OFFSET);

		FunkinSound.setVolume(Constants.VOCALS_VOLUME, 'player');

		var score:Int = 700;

		var daRating:Rating = Conductor.judgeNote(note, noteDiff / playbackRate);

		totalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		note.rating = daRating.name;
		score = daRating.score;

		if (!note.ratingDisabled)
		{
			daRating.increase();

			if (!note.isSustainNote) {
				Scoring.setScore(score, false);
			}

			songHits++;
			totalPlayed++;
			RecalculateRating(false);
		}

		if (!note.noteSplashDisabled && daRating.noteSplash) {
			spawnNoteSplashOnNote(note);
		}

		final scorePopUp:ScorePopUp =
			new ScorePopUp(
				daRating,
				combo,
				(showCombo && !daRating.comboBreak),
				showTally
			);

		insert(members.indexOf(strumLineNotes), scorePopUp);
	}

	public var strumsBlocked:Array<Bool> = [];
	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);

		if (!cpuControlled && startedCountdown && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || GlobalSettings.CONTROLLER_MODE))
		{
			if (!boyfriend.stunned && generatedMusic && !endingSong)
			{
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !GlobalSettings.GHOST_TAPPING;

				var pressNotes:Array<Note> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];

				notes.forEachAlive(function(daNote:Note)
				{
					if (strumsBlocked[daNote.noteData] != true && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote && !daNote.blockHit) {
						if(daNote.noteData == key) {
							sortedNotesList.push(daNote);
						}
						canMiss = true;
					}
				});

				sortedNotesList.sort(sortHitNotes);

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}

						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				} else {
					callOnLuas('onGhostTap', [key]);
					if (canMiss) {
						noteMissPress(key);
					}
				}

				keysPressed[key] = true;

				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];

			if (strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm') {
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}

			callOnLuas('onKeyPress', [key]);
		}
	}

	function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);

		if (!cpuControlled && startedCountdown && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];

			if (spr != null) {
				spr.playAnim('static');
				spr.resetAnim = 0;
			}

			callOnLuas('onKeyRelease', [key]);
		}
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if (key != NONE) {
			for (i in 0...keysArray.length) {
				for (j in 0...keysArray[i].length) {
					if (key == keysArray[i][j]) {
						return i;
					}
				}
			}
		}

		return -1;
	}

	// Function for HOLD notes.
	private function keyShit():Void
	{
		var parsedHoldArray:Array<Bool> = parseKeys();

		if (GlobalSettings.CONTROLLER_MODE)
		{
			var parsedArray:Array<Bool> = parseKeys('_P');

			if (parsedArray.contains(true)) {
				for (i in 0...parsedArray.length) {
					if (parsedArray[i] && strumsBlocked[i] != true) {
						onKeyPress(
							new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0])
						);
					}
				}
			}
		}

		if (startedCountdown && !boyfriend.stunned && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note) {
				if (strumsBlocked[daNote.noteData] != true && daNote.isSustainNote && parsedHoldArray[daNote.noteData] && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.blockHit) {
					goodNoteHit(daNote);
					endHoldSplash(onPlayerHoldCover, daNote);
				}
			});

			processHoldSplash(parsedHoldArray, onPlayerHoldCover, playerStrums);

			if (parsedHoldArray.contains(true) && !endingSong) {
				#if ACHIEVEMENTS_ALLOWED
				var achieve:String = AchievementsHandler.checkAchievement(['oversinging']);
				if (achieve != null) {
					achievementHandler.awardAchievement(achieve);
				}
				#end
			} else if (boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
				boyfriend.dance();
			}
		}

		if (GlobalSettings.CONTROLLER_MODE || strumsBlocked.contains(true))
		{
			var parsedArray:Array<Bool> = parseKeys('_R');
			if (parsedArray.contains(true)) {
				for (i in 0...parsedArray.length) {
					if (parsedArray[i] || strumsBlocked[i] == true) {
						onKeyRelease(
							new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1,keysArray[i][0])
						);
					}
				}
			}
		}
	}

	private function parseKeys(?suffix:String = ''):Array<Bool>
	{
		var ret:Array<Bool> = [];

		for (i in 0...controlArray.length) {
			ret[i] = Reflect.getProperty(controls, controlArray[i] + suffix);
		}

		return ret;
	}

	function noteMiss(daNote:Note):Void
	{
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});

		if (GlobalSettings.NOTE_MISS_SFX) {
			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.3, 0.5), false);
		}

		Scoring.resetMultipliers();

		combo = 0;
		health -= Constants.HEALTH_MISS_PENALTY * healthLoss;

		if (instakillOnMiss) {
			FunkinSound.setVolume(0, 'player');
			doDeathCheck(true);
		}

		songMisses++;

		FunkinSound.setVolume(0, 'player');

		if (!practiceMode)
			Scoring.setScore(300, true);

		totalPlayed++;

		RecalculateRating(true);

		var char:Character = boyfriend;

		if (daNote.gfNote) {
			char = gf;
		}

		if (char != null && !daNote.noMissAnimation && char.hasMissAnimations)
		{
			var missAnimation:String = '${singAnimations[Std.int(Math.abs(daNote.noteData))]}miss';
			var animToPlay:String = '${missAnimation}${daNote.animSuffix}'; // Alt animations for all characters.

			if (char.curCharacter == 'bf-zero') {
				animToPlay = missAnimation; // Make an exception for ZeroArtist's BF since the JSON schema does not include Alt. Miss Animations.
			}

			char.playAnim(animToPlay, true);
		}

		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	function noteMissPress(direction:Int = 1):Void
	{
		if (GlobalSettings.GHOST_TAPPING)
			return;

		if (!boyfriend.stunned)
		{
			health -= Constants.HEALTH_MISS_PENALTY * healthLoss;

			if (instakillOnMiss) {
				FunkinSound.setVolume(0, 'player');
				doDeathCheck(true);
			}

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad')) {
				gf.playAnim('sad');
			}

			combo = 0;

			if (!practiceMode)
				Scoring.setScore(300, true);

			if (!endingSong) {
				songMisses++;
			}

			totalPlayed++;
			RecalculateRating(true);

			if (GlobalSettings.NOTE_MISS_SFX) {
				FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.3, 0.5), false);
			}

			if (boyfriend.hasMissAnimations) {
				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}

			FunkinSound.setVolume(0, 'player');
		}

		callOnLuas('noteMissPress', [direction]);
	}

	function opponentNoteHit(note:Note):Void
	{
		if (note.noteType == 'Hey!' && dad.animOffsets.exists('hey'))
		{
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		}
		else if (!note.noAnimation)
		{
			var altAnim:String = note.animSuffix;

			if (SONG.notes[curSection] != null) {
				if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection) {
					altAnim = '-alt';
				}
			}

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;

			if (note.gfNote) {
				char = gf;
			}

			if (char != null) {
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}
		}

		if (SONG.needsVoices) {
			FunkinSound.setVolume(Constants.VOCALS_VOLUME, 'opponent');
		}


		var time:Float = 0.15;

		if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
			time += 0.15;
		}

		strumPlayAnim(true, Std.int(Math.abs(note.noteData)), time);

		note.hitByOpponent = true;

		callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (cpuControlled && (note.ignoreNote || note.hitCausesMiss))
				return;

			if (GlobalSettings.HITSOUND_VOLUME > 0 && !note.hitsoundDisabled) {
				FlxG.sound.play(Paths.sound('hitsound'), GlobalSettings.HITSOUND_VOLUME);
			}

			if (note.hitCausesMiss)
			{
				noteMiss(note);

				if (!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(note);
				}

				if (!note.noMissAnimation)
				{
					switch(note.noteType) {
						case 'Hurt Note': //Hurt note
							if(boyfriend.animation.getByName('hurt') != null) {
								boyfriend.playAnim('hurt', true);
								boyfriend.specialAnim = true;
							}
					}
				}

				note.wasGoodHit = true;

				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}

				return;
			}

			processNote(note);

			if(!note.noAnimation) {
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];

				if(note.gfNote)
				{
					if(gf != null)
					{
						gf.playAnim(animToPlay + note.animSuffix, true);
						gf.holdTimer = 0;
					}
				}
				else
				{
					boyfriend.playAnim(animToPlay + note.animSuffix, true);
					boyfriend.holdTimer = 0;
				}

				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}

					if(gf != null && gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if (cpuControlled) {
				var time:Float = 0.15;
				if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				strumPlayAnim(false, Std.int(Math.abs(note.noteData)), time);
			} else {
				var spr = playerStrums.members[note.noteData];
				if (spr != null) {
					spr.playAnim('confirm', true);
				}
			}

			note.wasGoodHit = true;

			FunkinSound.setVolume(Constants.VOCALS_VOLUME, 'player');

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;

			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	public function processNote(note:Note):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + GlobalSettings.RATING_OFFSET);
		var ratingHealthGain:Float = Constants.HEALTH_MARVELOUS_BONUS;
		var daRating:Rating = Conductor.judgeNote(note, noteDiff / playbackRate);

		ratingHealthGain = daRating.healthGain;

		if (!note.isSustainNote)
		{
			if (!daRating.comboBreak) {
				combo++;
				health += (ratingHealthGain * healthGain);
			} else {
				noteMiss(note);
			}

			if (!PlayState.SONG_METADATA.hasNoteWiggle) {
				if (GlobalSettings.HOLD_NOTE_SPLASHES) {
					if (note.sustainLength > 0) {
						spawnHoldSplashOnNote(playerStrums, note, false);
					}
				}
			}

			processScore(note);
		}
	}

	public function spawnNoteSplashOnNote(note:Note):Void
	{
		if(GlobalSettings.NOTE_SPLASHES && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if (strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note, false);
			}
		}
	}

	public function spawnHoldSplashOnNote(strums:Null<FlxTypedGroup<StrumNote>>, note:Note, ?isDad:Bool = false):Void
	{
		if (strums != null) {
			if (GlobalSettings.NOTE_SPLASHES && GlobalSettings.HOLD_NOTE_SPLASHES && note != null) {
				var strum:StrumNote = strums.members[note.noteData];
				if (strum != null) {
					spawnNoteSplash(strum.x, strum.y, note.noteData, note, true, isDad);
				}
			}
		}
	}

	public function processHoldSplash(parsedHoldArray:Null<Array<Bool>>, holdSplashArray:Null<Array<HoldCover>>, targetStrumline:Null<FlxTypedGroup<StrumNote>>):Void
	{
		if (!GlobalSettings.HOLD_NOTE_SPLASHES) {
			return;
		}

		if (parsedHoldArray == null || holdSplashArray == null) {
			return;
		}

		for (i in 0...4)
		{
			if (holdSplashArray != null)
			{
				if (holdSplashArray[i] != null && holdSplashArray[i].animation.curAnim.name == 'hold') {
					if (!parsedHoldArray[i]) {
						holdSplashArray[i].alpha = 0.0;
					} else {
						holdSplashArray[i].setCoverPosition(targetStrumline.members[i].x, targetStrumline.members[i].y);
					}
				}
			}
		}
	}

	public function endHoldSplash(holdSplashArray:Null<Array<HoldCover>>, note:Note):Void
	{
		if (!GlobalSettings.HOLD_NOTE_SPLASHES) {
			return;
		}

		if (holdSplashArray == null) {
			return;
		}

		if (holdSplashArray[note.noteData] != null)
		{
			if (note.animation.curAnim.name.endsWith('holdend'))
			{
				holdSplashArray[note.noteData].alpha = 1.0;
				holdSplashArray[note.noteData].endHoldAnimation(true);
				holdSplashArray[note.noteData] = null;
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null, ?sustainNote:Bool = false, ?isDad:Bool = false):Void
	{
		var skin:String = 'noteSplashes';

		if (PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) {
			skin = PlayState.SONG.splashSkin;
		}

		var hue:Float = 0;
		var sat:Float = 0;
		var brt:Float = 0;

		if (data > -1 && data < Preferences.arrowHSV.length)
		{
			hue = Preferences.arrowHSV[data][0] / 360;
			sat = Preferences.arrowHSV[data][1] / 100;
			brt = Preferences.arrowHSV[data][2] / 100;
			if (note != null) {
				skin = note.noteSplashTexture;
				hue = note.noteSplashHue;
				sat = note.noteSplashSat;
				brt = note.noteSplashBrt;
			}
		}

		if (sustainNote && GlobalSettings.HOLD_NOTE_SPLASHES) {
			var holdCover:HoldCover = grpHoldCovers.recycle(HoldCover);
			holdCover.setup(x, y, data, skin, hue, sat, brt);
			grpHoldCovers.add(holdCover);
			onPlayerHoldCover[note.noteData] = holdCover;
		} else {
			var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
			splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
			grpNoteSplashes.add(splash);
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.setPosition(-12600, FlxG.random.int(140, 250));
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	var carTimer:FlxTimer;
	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);
		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		carTimer = new FlxTimer().start(2, function(tmr:FlxTimer) {
			resetFastCar();
			carTimer = null;
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	var trainShakeIntensity:Float = 0.0015;

	function trainStart():Void
	{
		trainMoving = true;

		trainSound.pitch = FlxG.random.float(0.9, 1.2);
		trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			FlxG.camera.shake(trainShakeIntensity, 0.8);
			if (gf != null) {
				gf.playAnim('hairBlow');
				gf.specialAnim = true;
			}
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		if (gf != null) {
			gf.danced = false; // Sets head to the correct position once the animation ends
			gf.playAnim('hairFall');
			gf.specialAnim = true;
		}

		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));

		if (!GlobalSettings.LOW_QUALITY)
			halloweenBG.animation.play('halloweem bg lightning strike');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if (boyfriend.animOffsets.exists('scared')) {
			boyfriend.playAnim('scared', true);
		}

		if (gf != null && gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
		}

		if (GlobalSettings.CAMERA_ZOOMING) {
			FlxG.camera.zoom = FlxG.camera.zoom + 0.015;
			camHUD.zoom = camHUD.zoom + 0.03;

			if(!camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				GlobalTweenClass.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				GlobalTweenClass.tween(camHUD, {zoom: camHUD.zoom - 0.03}, 0.5);
			}
		}

		if (GlobalSettings.FLASHING_LIGHTS) {
			halloweenWhite.alpha = 0.4;
			GlobalTweenClass.tween(halloweenWhite, {alpha: 0.5}, 0.075);
			GlobalTweenClass.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}

	function killHenchmen():Void
	{
		if (!GlobalSettings.LOW_QUALITY && GlobalSettings.VIOLENCE && curStage == 'limo') {
			if (limoKillingState < 1) {
				limoMetalPole.x = -400;
				limoMetalPole.visible = true;
				limoLight.visible = true;
				limoCorpse.visible = false;
				limoCorpseTwo.visible = false;
				limoKillingState = 1;

				#if ACHIEVEMENTS_ALLOWED
				Achievements.henchmenDeath++;
				FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
				var achieve:String = AchievementsHandler.checkAchievement(['roadkill_enthusiast']);
				if (achieve != null) {
					achievementHandler.awardAchievement(achieve);
				} else {
					FlxG.save.flush();
				}
				FlxG.log.add('Deaths: ' + Achievements.henchmenDeath);
				#end
			}
		}
	}

	function resetLimoKill():Void
	{
		if(curStage == 'limo') {
			limoMetalPole.x = -500;
			limoMetalPole.visible = false;
			limoLight.x = -500;
			limoLight.visible = false;
			limoCorpse.x = -500;
			limoCorpse.visible = false;
			limoCorpseTwo.x = -500;
			limoCorpseTwo.visible = false;
		}
	}

	var tankX:Float = 400;
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankAngle:Float = FlxG.random.int(-90, 45);

	function moveTank(?elapsed:Float = 0):Void
	{
		if (!inCutscene)
		{
			tankAngle += elapsed * tankSpeed;
			tankGround.angle = tankAngle - 90 + 15;
			tankGround.setPosition(
				tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180)),
				1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180))
			);
		}
	}

	override function destroy()
	{
		for (lua in luaArray) {
			lua.call('onDestroy', []);
			lua.stop();
		}

		luaArray = [];

		#if hscript
		if (FunkinLua.hscript != null)
			FunkinLua.hscript = null;
		#end

		if (!GlobalSettings.CONTROLLER_MODE) {
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		FlxAnimationController.globalSpeed = 1;

		FlxG.sound.music.pitch = 1;

		super.destroy();
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();

		if (SONG.needsVoices && FlxG.sound.music.time >= -GlobalSettings.NOTE_OFFSET) {
			FunkinSound.updateSongSync();
		}

		if (curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		super.beatHit();

		if (lastBeatHit >= curBeat) {
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, GlobalSettings.DOWNSCROLL ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}
		// Note / Strum Tail wiggles to the beat.
		if (PlayState.SONG_METADATA.hasNoteWiggle) {
			if (curBeat % 1 == 0) {
				noteTailWiggleToBeat();
			}
		}

		// Camera zooms to the beat.
		cameraZoomToTheBeat(beatModulo);

		// Icon-Bop function.
		playerIcons.forEach(function(icon:HealthIcon) {
			icon.bopToBeat(
				curBeat,
				beatModulo,
				Constants.ICON_BOP_INTENSITY,
				Constants.ICON_BOP_INTENSITY_ON_BEAT
			);
		});

		if (gf != null && curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned) {
			gf.dance();
		}

		if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned) {
			boyfriend.dance();
		}

		if (curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned) {
			dad.dance();
		}

		switch (curStage)
		{
			case 'tank':
				if(!GlobalSettings.LOW_QUALITY) tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BackgroundStageSprite) {
					spr.dance();
				});

			case 'school':
				if (!GlobalSettings.LOW_QUALITY) {
					bgGirls.dance();
				}

			case 'mall':
				if (!GlobalSettings.LOW_QUALITY) {
					upperBoppers.dance(true);
				}

				if (heyTimer <= 0)
					bottomBoppers.dance(true);

				santa.dance(true);

			case 'limo':
				if (!GlobalSettings.LOW_QUALITY) {
					grpLimoDancers.forEach(function(dancer:BackgroundDancer) {
						dancer.dance();
					});
				}

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();

			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0) {
					curLight = FlxG.random.int(0, phillyLightsColors.length - 1, [curLight]);
					phillyWindow.color = phillyLightsColors[curLight];
					phillyWindow.alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8) {
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (curStage == 'spooky' && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset) {
			lightningStrikeShit();
		}

		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat); //DAWGG?????
		callOnLuas('onBeatHit', []);
	}

	var noteWiggleModLeft:Bool = false;
	private function noteTailWiggleToBeat():Void
	{
		noteWiggleModLeft = !noteWiggleModLeft;
		if (noteWiggleModLeft) {
			lerpAmplitude = -noteWiggleAmplitude;
		} else {
			lerpAmplitude = noteWiggleAmplitude;
		}
	}

	override function sectionHit()
	{
		super.sectionHit();

		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
			{
				moveCameraSection();
			}

			if (SONG.notes[curSection].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[curSection].bpm);
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}

			setOnLuas('mustHitSection', SONG.notes[curSection].mustHitSection);
			setOnLuas('altAnim', SONG.notes[curSection].altAnim);
			setOnLuas('gfSection', SONG.notes[curSection].gfSection);
		}

		setOnLuas('curSection', curSection);
		callOnLuas('onSectionHit', []);
	}

	private function cameraZoomToTheBeat(?beatMod:Int = 4, ?zoomIntensity:Float = 0.015, ?zoomAdd:Float = 0.015):Void
	{
		if (!doPhillyCAB) {
			if (camZooming && FlxG.camera.zoom < 1.35 && GlobalSettings.CAMERA_ZOOMING) {
				if ((curBeat % beatMod) == 0) {
					addCameraZoom(zoomIntensity, zoomIntensity + zoomAdd);
				}
			}
		} else {
			if (camZooming && FlxG.camera.zoom < 1.35 && GlobalSettings.CAMERA_ZOOMING) {
				if ((curBeat % beatMod) == 0) {
					addCameraZoom(zoomIntensity * 1.5, zoomIntensity + (zoomAdd * 4.5));
				} else {
					addCameraZoom(zoomIntensity * 1.2, zoomIntensity + (zoomAdd * 2.5));
				}
			}
		}
	}

	/**
	 * Tiny little wrapper function for setting the camera zoom. (Only gonna use it for beating camera smh)
	 */
	private function addCameraZoom(?gameZoomAdd:Null<Float>, ?hudZoomAdd:Null<Float>):Void
	{
		if (!(gameZoomAdd <= 0 && hudZoomAdd <= 0) && (gameZoomAdd != null && hudZoomAdd != null)) {
			FlxG.camera.zoom += gameZoomAdd * camZoomingMult;
			camHUD.zoom += hudZoomAdd * camZoomingMult;
		}
	}

	public function callOnLuas(event:String, args:Array<Dynamic>, ignoreStops = true, exclusions:Array<String> = null):Dynamic
	{
		var returnVal:Dynamic = FunkinLua.Function_Continue;

		#if LUA_ALLOWED
		if (exclusions == null) exclusions = [];

		for (script in luaArray)
		{
			if (exclusions.contains(script.scriptName))
				continue;

			var ret:Dynamic = script.call(event, args);
			if (ret == FunkinLua.Function_StopLua && !ignoreStops)
				break;

			// had to do this because there is a bug in haxe where Stop != Continue doesnt work
			var bool:Bool = ret == FunkinLua.Function_Continue;
			if (!bool && ret != 0) {
				returnVal = cast ret;
			}
		}
		#end

		//trace(event, returnVal);
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic):Void
	{
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function strumPlayAnim(isDad:Bool, id:Int, time:Float):Void
	{
		var spr:StrumNote = null;

		if (isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if (spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingPercent:Float = 1.0;
	public var ratingFC:String = 'N/A';
	public var ranking:String = 'N/A';

	public function RecalculateRating(badHit:Bool = false):Void
	{
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);

		var ret:Dynamic = callOnLuas('onRecalculateRating', [], false);
		if(ret != FunkinLua.Function_Stop)
		{
			if (totalPlayed < 1) { //Prevent divide by 0
				ratingPercent = 1.0;
			} else {
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
			}

			ratingFC = Ranking.evaluateRatingFC(songMisses, shits, bads, goods, sicks, marvs);
			ranking = Ranking.evaluateLetterRanking(Ranking.calculateAccuracy(ratingPercent));
		}

		updateScore(badHit); // I made this function useless LMFAO -Equinoxtic

		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingFC', ratingFC);
		setOnLuas('ranking', ranking);
	}

	var curLight:Int = -1;
	var curLightEvent:Int = -1;
}
