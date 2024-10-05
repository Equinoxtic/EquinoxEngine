package funkin.play.scoring;

import flixel.FlxG;

using StringTools;

class Highscore
{
	public static var weekScores:Map<String, Int> = new Map();
	public static var songScores:Map<String, Int> = new Map();
	public static var songAccuracy:Map<String, Float> = new Map();
	public static var songRatingFC:Map<String, String> = new Map();
	public static var songRanking:Map<String, String> = new Map();

	public static function resetSong(song:String, diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);
		setScore(daSong, 0);
		setAccuracy(daSong, 0);
		setRatingFC(daSong, 'N/A');
		setRanking(daSong, 'N/A');
	}

	public static function resetWeek(week:String, diff:Int = 0):Void
	{
		var daWeek:String = formatSong(week, diff);
		setWeekScore(daWeek, 0);
	}

	public static function floorDecimal(value:Float, decimals:Int):Float
	{
		if(decimals < 1)
		{
			return Math.floor(value);
		}

		var tempMult:Float = 1;
		for (i in 0...decimals)
		{
			tempMult *= 10;
		}
		var newValue:Float = Math.floor(value * tempMult);
		return newValue / tempMult;
	}

	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0, ?rating:Float = -1, ?ratingFC:String = '', ?rank:String = ''):Void
	{
		var daSong:String = formatSong(song, diff);

		if (songScores.exists(daSong))
		{
			if (songScores.get(daSong) < score) {
				setScore(daSong, score);
				if (rank != '')
					setRanking(daSong, rank);
				if (ratingFC != '')
					setRatingFC(daSong, ratingFC);
				if (rating >= 0)
					setAccuracy(daSong, rating);
			}
		}
		else
		{
			setScore(daSong, score);
			if (rank != '')
				setRanking(daSong, rank);
			if (ratingFC != '')
				setRatingFC(daSong, ratingFC);
			if (rating >= 0)
				setAccuracy(daSong, rating);
		}
	}

	public static function saveWeekScore(week:String, score:Int = 0, ?diff:Int = 0):Void
	{
		var daWeek:String = formatSong(week, diff);

		if (weekScores.exists(daWeek)) {
			if (weekScores.get(daWeek) < score) {
				setWeekScore(daWeek, score);
			}
		} else {
			setWeekScore(daWeek, score);
		}
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}

	static function setWeekScore(week:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		weekScores.set(week, score);
		FlxG.save.data.weekScores = weekScores;
		FlxG.save.flush();
	}

	static function setAccuracy(song:String, rating:Float):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songAccuracy.set(song, rating);
		FlxG.save.data.songAccuracy = songAccuracy;
		FlxG.save.flush();
	}

	static function setRatingFC(song:String, ratingFC:String):Void
	{
		songRatingFC.set(song, ratingFC);
		FlxG.save.data.songRatingFC = songRatingFC;
		FlxG.save.flush();
	}

	static function setRanking(song:String, ranking:String):Void
	{
		songRanking.set(song, ranking);
		FlxG.save.data.songRanking = songRanking;
		FlxG.save.flush();
	}

	public static function formatSong(song:String, diff:Int):String
	{
		var path:String = '${Paths.formatToSongPath(song)}/difficulties/${FunkinUtil.getDifficultyFilePath(diff)}';
		return Std.string(path);
	}

	public static function getScore(song:String, diff:Int):Int
	{
		var daSong:String = formatSong(song, diff);
		if (!songScores.exists(daSong))
			setScore(daSong, 0);

		return songScores.get(daSong);
	}

	public static function getAccuracy(song:String, diff:Int):Float
	{
		var daSong:String = formatSong(song, diff);
		if (!songAccuracy.exists(daSong))
			setAccuracy(daSong, 0);

		return songAccuracy.get(daSong);
	}

	public static function getRatingFC(song:String, diff:Int):String
	{
		var daSong:String = formatSong(song, diff);
		if (!songRatingFC.exists(daSong))
			setRatingFC(daSong, 'N/A');

		return songRatingFC.get(daSong);
	}

	public static function getRanking(song:String, diff:Int):String
	{
		var daSong:String = formatSong(song, diff);
		if (!songRanking.exists(daSong))
			setRanking(daSong, 'N/A');

		return songRanking.get(daSong);
	}

	public static function getWeekScore(week:String, diff:Int):Int
	{
		var daWeek:String = formatSong(week, diff);
		if (!weekScores.exists(daWeek))
			setWeekScore(daWeek, 0);

		return weekScores.get(daWeek);
	}

	public static function load():Void
	{
		if (FlxG.save.data.weekScores != null)
			weekScores = FlxG.save.data.weekScores;

		if (FlxG.save.data.songScores != null)
			songScores = FlxG.save.data.songScores;

		if (FlxG.save.data.songAccuracy != null)
			songAccuracy = FlxG.save.data.songAccuracy;

		if (FlxG.save.data.songRanking != null)
			songRanking = FlxG.save.data.songRanking;

		if (FlxG.save.data.songRatingFC != null)
			songRatingFC = FlxG.save.data.songRatingFC;
	}
}
