package funkin.util;

import flixel.input.keyboard.FlxKey;

class GlobalSettings
{
	public static var FOCUS_LOST_FRAMERATE:Int;
	public static var MUTE_KEYS:Array<FlxKey>;
	public static var VOLUME_UP_KEYS:Array<FlxKey>;
	public static var VOLUME_DOWN_KEYS:Array<FlxKey>;

	public static var FRAMERATE:Int;
	public static var SHOW_FRAMERATE:Bool;
	public static var SPRITE_ANTIALIASING:Bool;
	public static var LOW_QUALITY:Bool;
	public static var MIDDLESCROLL:Bool;
	public static var MIDDLESCROLL_OPPONENT_NOTES:Bool;
	public static var DOWNSCROLL:Bool;
	public static var JUDGEMENT_COUNTER:Bool;
	public static var DETAILED_JUDGEMENT_COUNTER:Bool;
	public static var GAMEPLAY_INFO:Bool;
	public static var HIDE_WATERMARK:Bool;
	public static var NOTE_SPLASHES:Bool;
	public static var NOTE_OFFSET:Int;
	public static var RATING_OFFSET:Int;
	public static var COMBO_OFFSET:Int;
	public static var SAFE_FRAMES:Int;
	public static var HITSOUND_VOLUME:Float;
	public static var NOTE_MISS_SFX:Bool;
	public static var GHOST_TAPPING:Bool;
	public static var FLASHING_LIGHTS:Bool;
	public static var HEALTH_BAR_TRANSPARENCY:Float;
	public static var TIME_BAR_DISPLAY:String;
	public static var CAMERA_ZOOMING:Bool;
	public static var DIRECTIONAL_CAMERA_MOVEMENT:Bool;
	public static var HIDE_HUD:Bool;
	public static var PAUSE_MUSIC:String;
	public static var PLAY_PAUSE_MUSIC:Bool;
	public static var NO_RESET:Bool;
	public static var CONTROLLER_MODE:Bool;
	public static var FONT_FACE:String;
	public static var VIOLENCE:Bool;
	public static var CURSING:Bool;
	public static var SHADERS:Bool;

	/**
	 * ## Initialize all settings that can be used globally.
	 *
	 * - These are only general settings/preferences that are used repeatedly throughout the source code.
	 *
	 * - Gameplay settings are excluded and seperated from this.
	 *
	 * *``(Only initialized first through TitleState.hx so the static variables in this class will be reused later on)``*
	 */
	public static function initializeSettings():Void
	{
		FOCUS_LOST_FRAMERATE = 30;

		FRAMERATE = Preferences.getPlayerPreference('framerateAmount', 60);
		SHOW_FRAMERATE = Preferences.getPlayerPreference('showFramerate', true);
		SPRITE_ANTIALIASING = Preferences.getPlayerPreference('antialiasing', true);
		LOW_QUALITY = Preferences.getPlayerPreference('lowQuality', false);
		MIDDLESCROLL = Preferences.getPlayerPreference('middleScroll', false);
		MIDDLESCROLL_OPPONENT_NOTES = Preferences.getPlayerPreference('opponentNotesOnMiddleScroll', false);
		DOWNSCROLL = Preferences.getPlayerPreference('downscroll', false);
		JUDGEMENT_COUNTER = Preferences.getPlayerPreference('showJudgementCounter', false);
		DETAILED_JUDGEMENT_COUNTER = Preferences.getPlayerPreference('detailedJudgementCounter', false);
		GAMEPLAY_INFO = Preferences.getPlayerPreference('showGameplayInfo', false);
		HIDE_WATERMARK = Preferences.getPlayerPreference('hideWatermark', false);
		NOTE_SPLASHES = Preferences.getPlayerPreference('noteSplashes', true);
		NOTE_OFFSET = Preferences.getPlayerPreference('noteOffset', 0);
		RATING_OFFSET = Preferences.getPlayerPreference('ratingOffset', 0);
		COMBO_OFFSET = Preferences.getPlayerPreference('comboOffset', 0);
		SAFE_FRAMES = Preferences.getPlayerPreference('safeFrames', 10);
		HITSOUND_VOLUME = Preferences.getPlayerPreference('hitsoundVolume', 0.0);
		NOTE_MISS_SFX = Preferences.getPlayerPreference('missSounds', true);
		GHOST_TAPPING = Preferences.getPlayerPreference('ghostTapping', true);
		FLASHING_LIGHTS = Preferences.getPlayerPreference('flashingLights', true);
		HEALTH_BAR_TRANSPARENCY = Preferences.getPlayerPreference('healthBarTransparency', 1.0);
		TIME_BAR_DISPLAY = Preferences.getPlayerPreference('timeBarDisplay', "Default");
		CAMERA_ZOOMING = Preferences.getPlayerPreference('cameraZooming', true);
		DIRECTIONAL_CAMERA_MOVEMENT = Preferences.getPlayerPreference('directionalCameraMovement', true);
		HIDE_HUD = Preferences.getPlayerPreference('hidePlayerHUD', false);
		PAUSE_MUSIC = Preferences.getPlayerPreference('pauseMusic', "Breakfast");
		PLAY_PAUSE_MUSIC = Preferences.getPlayerPreference('playPauseMusic', true);
		NO_RESET = Preferences.getPlayerPreference('noResetButton', false);
		CONTROLLER_MODE = Preferences.getPlayerPreference('controllerMode', false);
		FONT_FACE = Preferences.getPlayerPreference('fontFace', "Default");
		VIOLENCE = Preferences.getPlayerPreference('violence', true);
		CURSING = Preferences.getPlayerPreference('cursing', true);
		SHADERS = Preferences.getPlayerPreference('enableShaders', true);

		#if (debug)
		FlxG.log.add('Initialized Global Settings!');
		#end
	}

	public static function loadVolumeControls():Void
	{
		MUTE_KEYS = [FlxKey.ZERO];
		VOLUME_UP_KEYS = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
		VOLUME_DOWN_KEYS = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	}
}
