package funkin.menus.options;

#if desktop
import funkin.api.discord.Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import funkin.input.Controls;

using StringTools;

class VisualsUISubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Visuals and UI';
		rpcTitle = 'Visuals & UI Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Note Splashes',
			"If unchecked, hitting \"Sick!\" notes won't show particles.",
			'noteSplashes',
			'bool',
			true);
		addOption(option);

		#if (!debug)
		var option:Option = new Option('Show Judgement Counter',
			'Shows and tracks how many sicks, goods, bads and shits.',
			'showJudgementCounter',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Detailed Judgement Counter Info',
			'If checked, the Judgement Counter will also track the total note hits, combo and misses.',
			'detailedJudgementInfo',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Show Gameplay Info',
			'Displays the current song, the current difficulty, etc.',
			'showGameplayInfo',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Disable Watermark',
		'If checked, the watermark will not be visible',
		'hideWatermark',
		'bool',
		false);
		addOption(option);
		#end

		var option:Option = new Option('Hide HUD',
			'If checked, hides most HUD elements.',
			'hidePlayerHUD',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Time Bar:',
			"What should the Time Bar display?",
			'timeBarDisplay',
			'string',
			'Default',
			['Default', 'Time Elapsed / Song Length', 'Song Name', 'Default Percentage', 'Percentage Only', 'Disabled']);
		addOption(option);

		var option:Option = new Option('Font Face: ',
			"What type of font should be displayed?",
			'fontFace',
			'string',
			'Default',
			['Default', 'Classic', 'Engine Legacy']);
		addOption(option);

		var option:Option = new Option('Flashing Lights',
			"Uncheck this if you're sensitive to flashing lights!",
			'flashingLights',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Camera Zooms',
			"If unchecked, the camera won't zoom in on a beat hit.",
			'cameraZooming',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Directional Camera Movement',
			"Toggles whether or not the camera moves to the note\'s direction.",
			'directionalCameraMovement',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Health Bar Transparency',
			'How much transparent should the health bar and icons be.',
			'healthBarTransparency',
			'percent',
			1);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		#if !mobile
		var option:Option = new Option('Show Framerate',
			'If unchecked, hides FPS Counter.',
			'showFramerate',
			'bool',
			true);
		addOption(option);
		option.onChange = onChangeFPSCounter;
		#end

		var option:Option = new Option('Pause Screen Song:',
			"What song do you prefer for the Pause Screen?",
			'pauseMusic',
			'string',
			'Tea Time',
			['None', 'Breakfast', 'Tea Time']);
		addOption(option);
		option.onChange = onChangePauseMusic;

		#if CHECK_FOR_UPDATES
		var option:Option = new Option('Check for Updates',
			'On Release builds, turn this on to check for updates when you start the game.',
			'checkForUpdates',
			'bool',
			true);
		addOption(option);
		#end

		super();
	}

	var changedMusic:Bool = false;
	function onChangePauseMusic()
	{
		var _pauseMusic:String = Preferences.getPlayerPreference('pauseMusic', "Breakfast");
		if (_pauseMusic == 'None') {
			FlxG.sound.music.volume = 0;
		} else {
			FlxG.sound.playMusic(Paths.music(
				Paths.formatToSongPath(_pauseMusic))
			);
		}
		changedMusic = true;
	}

	override function destroy()
	{
		if (changedMusic) {
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}
		super.destroy();
	}

	#if !mobile
	function onChangeFPSCounter()
	{
		if (Main.fpsVar != null) {
			Main.fpsVar.visible = Preferences.getPlayerPreference('showFramerate', true);
		}
	}
	#end
}
