package funkin;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import funkin.input.Controls;

enum PreferenceActionType
{
	SAVE;
	LOAD;
}

class Preferences
{
	public static var arrowHSV:Array<Array<Int>> = [
		[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]
	];
	public static var comboOffset:Array<Int> = [0, 0, 0, 0];

	public static var playerPreferences:Map<String, Dynamic> = [
		/**
		 * Graphics, shaders, and performance Settings.
		*/
		'antialiasing' => true,
		'showFramerate' => true,
		'lowQuality' => true,
		'enableShaders' => true,
		'framerateAmount' => 60,

		/**
		 * Gameplay settings, and Note settings.
		 */
		'downScroll' => false,
		'middleScroll' => false,
		'opponentNotesOnMiddleScroll' => false,
		'missSounds' => true,
		'hitsoundVolume' => 0.0,
		'ghostTapping' => true,
		'noteSplashes' => true,
		'noteOffset' => 0,
		'noResetButton' => false,
		'controllerMode' => true,

		/**
		 * Visuals, UI Settings, and Camera Settings.
		 */
		'flashingLights' => true,
		'cameraZooming' => true,
		'hidePlayerHUD' => false,
		'showJudgementCounter' => true,
		'detailedJudgementCounter' => true,
		'showGameplayInfo' => true,
		'hideWatermark' => false,
		'directionalCameraMovement' => true,
		'fontFace' => "Default",
		'timeBarDisplay' => "Default",
		'healthBarTransparency' => 1.0,
		'pauseMusic' => "Breakfast",
		'playPauseMusic' => true,

		/**
		 * Ratings, windows, and offsets.
		 */
		'ratingOffset' => 0,
		'marvWindow' => 20,
		'sickWindow' => 30,
		'goodWindow' => 75,
		'badWindow' => 95,
		'safeFrames' => 10,

		/**
		 * Universal game settings.
		 */
		'updateChecking' => true,
		'violence' => true,
		'cursing' => true
	];

	public static var gameplaySettings:Map<String, Dynamic> = [
		'scrollspeed' => 1.0,
		'scrolltype' => 'multiplicative',
		// anyone reading this, amod is multiplicative speed mod, cmod is constant speed mod, and xmod is bpm based speed mod.
		// an amod example would be chartSpeed * multiplier
		// cmod would just be constantSpeed = chartSpeed
		// and xmod basically works by basing the speed on the bpm.
		// iirc (beatsPerSecond * (conductorToNoteDifference / 1000)) * noteSize (110 or something like that depending on it, prolly just use note.height)
		// bps is calculated by bpm / 60
		// oh yeah and you'd have to actually convert the difference to seconds which I already do, because this is based on beats and stuff. but it should work
		// just fine. but I wont implement it because I don't know how you handle sustains and other stuff like that.
		// oh yeah when you calculate the bps divide it by the songSpeed or rate because it wont scroll correctly when speeds exist.
		'songspeed' => 1.0,
		'healthgain' => 1.0,
		'healthloss' => 1.0,
		'instakill' => false,
		'practice' => false,
		'botplay' => false,
		'opponentplay' => false
	];

	//Every key has two binds, add your key bind down here and then add your control on options/ControlsSubState.hx and Controls.hx
	public static var keyBinds:Map<String, Array<FlxKey>> = [
		//Key Bind, Name for ControlsSubState
		'note_left'		=> [A, LEFT],
		'note_down'		=> [S, DOWN],
		'note_up'		=> [W, UP],
		'note_right'	=> [D, RIGHT],

		'ui_left'		=> [A, LEFT],
		'ui_down'		=> [S, DOWN],
		'ui_up'			=> [W, UP],
		'ui_right'		=> [D, RIGHT],

		'accept'		=> [SPACE, ENTER],
		'back'			=> [BACKSPACE, ESCAPE],
		'pause'			=> [ENTER, ESCAPE],
		'reset'			=> [R, NONE],

		'volume_mute'	=> [ZERO, NONE],
		'volume_up'		=> [NUMPADPLUS, PLUS],
		'volume_down'	=> [NUMPADMINUS, MINUS],

		'debug_1'		=> [SEVEN, NONE],
		'debug_2'		=> [EIGHT, NONE]
	];
	public static var defaultKeys:Map<String, Array<FlxKey>> = null;

	public static function loadDefaultKeys() {
		defaultKeys = keyBinds.copy();
		//trace(defaultKeys);
	}

	private static function _preferenceAction(_actionType:Null<PreferenceActionType>):Void
	{
		if (_actionType == null) {
			return;
		}

		if (_actionType.equals(PreferenceActionType.SAVE)) {
			trace('Saving Prefences...');
			FlxG.save.data.playerPreferences = playerPreferences;
		} else if (_actionType.equals(PreferenceActionType.LOAD)) {
			trace('Loading Preferences...');
			if (FlxG.save.data.playerPreferences != null) {
				var loadedPreferences:Map<String, Dynamic> = FlxG.save.data.playerPreferences;
				for (preferenceKey => preferenceValue in loadedPreferences) {
					playerPreferences.set(preferenceKey, preferenceValue);
				}
			}
		}

		// No Reflect shit, I just like and love to make my own implementations :sunglasses:
	}

	public static function saveSettings():Void
	{
		FlxG.save.data.arrowHSV = arrowHSV;

		FlxG.save.data.gameplaySettings = gameplaySettings;

		_preferenceAction(PreferenceActionType.SAVE);

		Achievements.saveAchievements();

		FlxG.save.flush();

		var save:FlxSave = new FlxSave();
		save.bind('controls_v2', 'ninjamuffin99'); // Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		save.data.customControls = keyBinds;
		save.flush();

		trace("Player Preferences saved!");
	}

	public static function loadPrefs():Void
	{
		if (FlxG.save.data.arrowHSV != null) {
			arrowHSV = FlxG.save.data.arrowHSV;
		}

		if (FlxG.save.data.comboOffset != null) {
			comboOffset = FlxG.save.data.comboOffset;
		}

		_preferenceAction(PreferenceActionType.LOAD);

		_toggleFPSCounter(playerPreferences.get('showFramerate'));
		_setFramerate(playerPreferences.get('framerate'));

		if (FlxG.save.data.gameplaySettings != null) {
			var savedMap:Map<String, Dynamic> = FlxG.save.data.gameplaySettings;
			for (name => value in savedMap) {
				gameplaySettings.set(name, value);
			}
		}

		var save:FlxSave = new FlxSave();
		save.bind('controls_v2', 'ninjamuffin99');
		if(save != null && save.data.customControls != null) {
			var loadedControls:Map<String, Array<FlxKey>> = save.data.customControls;
			for (control => keys in loadedControls) {
				keyBinds.set(control, keys);
			}
			reloadControls();
		}

		trace("Player Preferences Loaded!");
	}

	private static function _setFramerate(?framerate:Int = 60):Void
	{
		if (framerate <= 0) {
			framerate = 60;
		}

		if (framerate > FlxG.drawFramerate) {
			FlxG.updateFramerate = framerate;
			FlxG.drawFramerate = framerate;
		} else {
			FlxG.drawFramerate = framerate;
			FlxG.updateFramerate = framerate;
		}

		trace("Set framerate: " + framerate);
	}

	private static function _toggleFPSCounter(?showFPS:Bool = true):Void
	{
		if (Main.fpsVar != null) {
			Main.fpsVar.visible = showFPS;
		}
		trace("Show FPS Counter: " + showFPS);
	}

	inline public static function getGameplaySetting(name:String, defaultValue:Dynamic):Dynamic {
		return (gameplaySettings.exists(name) ? gameplaySettings.get(name) : defaultValue);
	}

	inline public static function getPlayerPreference(key:String, ?value:Dynamic):Dynamic {
		if (!playerPreferences.exists(key)) {
			return value;
		}
		return playerPreferences.get(key);
	}

	public static function reloadControls() {
		PlayerSettings.player1.controls.setKeyboardScheme(KeyboardScheme.Solo);

		TitleState.muteKeys = copyKey(keyBinds.get('volume_mute'));
		TitleState.volumeDownKeys = copyKey(keyBinds.get('volume_down'));
		TitleState.volumeUpKeys = copyKey(keyBinds.get('volume_up'));
		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
	}
	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey> {
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;

		while (i < len) {
			if(copiedArray[i] == NONE) {
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}
		return copiedArray;
	}
}
