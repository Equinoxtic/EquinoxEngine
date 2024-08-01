package funkin.util;

import flixel.util.FlxTimer;
import openfl.media.Sound;
import flixel.FlxG;

using StringTools;

class FunkinUtil
{
	public static var defaultDifficulties:Array<String> = [
		'Easy',
		'Normal',
		'Hard',
		'Erect'
	];

	public static var defaultDifficulty:String = 'Normal';

	public static var difficulties:Array<String> = [];

	inline public static function quantize(f:Float, snap:Float){
		// changed so this actually works lol
		var m:Float = Math.fround(f * snap);
		trace(snap);
		return (m / snap);
	}

	public static function getDifficultyFilePath(num:Null<Int> = null)
	{
		if(num == null) num = PlayState.storyDifficulty;

		var fileSuffix:String = difficulties[num];
		return Paths.formatToSongPath(fileSuffix);
	}

	public static function getSongDisplayName():String
	{
		return ((PlayState.SONG_METADATA.songDisplayName != "Test") ? PlayState.SONG_METADATA.songDisplayName : PlayState.SONG.song.replace('-', ' '));
	}

	public static function difficultyString():String
	{
		return difficulties[PlayState.storyDifficulty].toUpperCase();
	}

	public static function lowerDiffString():String
	{
		return difficulties[PlayState.storyDifficulty].toLowerCase().trim();
	}

	public static function pixelSuffix(?key:String):String
	{
		return 'pixelUI/${key}-pixel';
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(max, value));
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = [];

		if (FileUtil.fileExists(path)) {
			daList = FileUtil.getContentOfFile(path).trim().split('\n');
		}

		for (i in 0...daList.length) {
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];

		daList = string.trim().split('\n');

		for (i in 0...daList.length) {
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function dominantColor(sprite:flixel.FlxSprite):Int
	{
		var countByColor:Map<Int, Int> = [];
		for (col in 0...sprite.frameWidth){
			for (row in 0...sprite.frameHeight){
			 	var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
				if (colorOfThisPixel != 0) {
					if (countByColor.exists(colorOfThisPixel)){
						countByColor[colorOfThisPixel] =  countByColor[colorOfThisPixel] + 1;
					} else if (countByColor[colorOfThisPixel] != 13520687 - (2*13520687)){
						countByColor[colorOfThisPixel] = 1;
					}
				}
			}
		}
		var maxCount = 0;
		var maxKey:Int = 0;//after the loop this will store the max color
		countByColor[flixel.util.FlxColor.BLACK] = 0;
			for(key in countByColor.keys()){
			if(countByColor[key] >= maxCount){
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		return maxKey;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	public static function soundExists(file:Null<Dynamic>):Bool
	{
		if (file != null) {
			return (Std.isOfType(file, Sound) || FileUtil.fileExists(file));
		}
		return false;
	}

	public static function toggleListOfTimers(timerArray:Null<Array<FlxTimer>>):Void
	{
		if (timerArray != null && timerArray.length > 0)
		{
			for (i in 0...timerArray.length) {
				var timer:FlxTimer = timerArray[i];
				if (timer != null && !timer.finished) {
					timer.active = !timer.active;
				}
			}
		}
	}

	// uhhhh does this even work at all? i'm starting to doubt
	// its not a void function you dumb idiot
	public static function precacheSound(sound:String, ?library:String = null):Void
	{
		Paths.sound(sound, library);
	}

	public static function precacheMusic(sound:String, ?library:String = null):Void
	{
		Paths.music(sound, library);
	}

	public static function browserLoad(site:String):Void
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}
}
