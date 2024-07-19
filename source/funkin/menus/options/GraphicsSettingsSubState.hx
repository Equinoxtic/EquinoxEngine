package funkin.menus.options;

#if desktop
import funkin.api.discord.Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxCamera;
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
import openfl.Lib;

using StringTools;

class GraphicsSettingsSubState extends BaseOptionsMenu
{
	private var _framerate:Int = Preferences.getPlayerPreference('framerate', 60);
	private var _antialiasing:Bool = Preferences.getPlayerPreference('antialiasing', true);

	public function new()
	{
		title = 'Graphics';
		rpcTitle = 'Graphics Settings Menu'; //for Discord Rich Presence

		//I'd suggest using "Low Quality" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Low Quality', //Name
			'If checked, disables some background details,\ndecreases loading times and improves performance.', //Description
			'lowQuality', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);

		var option:Option = new Option('Anti-Aliasing',
			'If unchecked, disables anti-aliasing, increases performance\nat the cost of sharper visuals.',
			'antialiasing',
			'bool',
			true);
		option.showBoyfriend = true;
		option.onChange = onChangeAntiAliasing; //Changing onChange is only needed if you want to make a special interaction after it changes the value
		addOption(option);

		var option:Option = new Option('Shaders', //Name
			'If unchecked, disables shaders.\nIt\'s used for some visual effects, and also CPU intensive for weaker PCs.', //Description
			'enableShaders', //Save data variable name
			'bool', //Variable type
			true); //Default value
		addOption(option);

		#if !html5 // Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
		var option:Option = new Option('Framerate',
			"The current framerate/FPS of the game. (May affect the speed/rates of certain functions.)",
			'framerate',
			'int',
			60);
		addOption(option);
		option.minValue = 1; // fuck it, lets bring this back (powerpoint slideshow framerate LMFAO)
		option.maxValue = 360;
		option.displayFormat = '%v FPS';
		option.onChange = onChangeFramerate;
		#end

		super();
	}

	function onChangeAntiAliasing()
	{
		for (sprite in members)
		{
			var sprite:Dynamic = sprite; //Make it check for FlxSprite instead of FlxBasic
			var sprite:FlxSprite = sprite; //Don't judge me ok
			if(sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) {
				sprite.antialiasing = _antialiasing;
			}
		}
	}

	function onChangeFramerate()
	{
		if(_framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = _framerate;
			FlxG.drawFramerate = _framerate;
		}
		else
		{
			FlxG.drawFramerate = _framerate;
			FlxG.updateFramerate = _framerate;
		}
	}
}
