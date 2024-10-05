package funkin.play.scoring;

import funkin.play.song.Song.SwagSong;
import flixel.math.FlxMath;

class Scoring
{
	/**
	 * The multiplier for the score.
	 */
	public static var SCORE_MULTIPLIER:Float = 1.0;

	/**
	 * The multiplier for the misses.
	 */
	public static var MISS_MULTIPLIER:Float = 1.0;

	/**
	 * The global multiplier for the score and the misses.
	 */
	private static var GLOBAL_MULTIPLIER:Float = 1.0;

	public static function setScore(amount:Int, ?deduct:Bool = false):Void
	{
		if (!deduct)
			_increaseScore(amount);
		else
			_deductScore(amount);
	}

	public static function updateMultipliers():Void
	{
		if (SCORE_MULTIPLIER >= Constants.SCORE_MULTIPLIER_MAX)
			SCORE_MULTIPLIER = Constants.SCORE_MULTIPLIER_MAX;
		else
			SCORE_MULTIPLIER = _formulateScoreMultiplier(PlayState.instance.ratingPercent, PlayState.instance.combo);

		if (MISS_MULTIPLIER >= Constants.MISS_MULTIPLIER_MAX)
			MISS_MULTIPLIER = Constants.MISS_MULTIPLIER_MAX;
		else
			MISS_MULTIPLIER = _formulateMissMultiplier(PlayState.instance.songMisses, PlayState.instance.comboPeak);
	}

	public static function resetMultipliers():Void
	{
		SCORE_MULTIPLIER = 1.0;
		MISS_MULTIPLIER = 1.0;
	}

	public static function save(songInstance:Null<SwagSong>):Void
	{
		if (songInstance == null)
			return;

		if (songInstance.validScore)
		{
			if (!PlayState.instance.cpuControlled && !PlayState.instance.practiceMode && !PlayState.chartingMode)
			{
				var saveMap:Map<String, Dynamic> = [
					'score'		 => PlayState.instance.songScore,
					'difficulty' => PlayState.storyDifficulty,
					'accuracy'	 => PlayState.instance.ratingPercent,
					'fc'		 => PlayState.instance.ratingFC,
					'rank'		 => PlayState.instance.ranking
				];

				for (k => v in saveMap) {
					var keyUpperCase:String = k.toUpperCase();
					switch (k) {
						case 'accuracy':
							trace('[${keyUpperCase}]: ${(Highscore.floorDecimal(v * 100, 2))}%');
						case 'difficulty':
							trace('[${keyUpperCase}]: ${FunkinUtil.difficulties[v].toUpperCase()}');
						default:
							trace('[Saved ${keyUpperCase}]: ${v}');
					}
				}

				var percent:Float = saveMap.get('accuracy');

				if (Math.isNaN(percent)) {
					percent = 0.0;
				}

				Highscore.saveScore(
					songInstance.song.toLowerCase(),
					saveMap.get('score'),
					saveMap.get('difficulty'),
					percent,
					saveMap.get('fc'),
					saveMap.get('rank')
				);
			}
		}
	}

	private static function _formulateScoreMultiplier(accuracy:Float, combo:Int):Float
	{
		return ((combo * 0.15) * (accuracy)) + 1.0 * GLOBAL_MULTIPLIER;
	}

	private static function _formulateMissMultiplier(misses:Int, comboPeak:Int):Float
	{
		final MOD:Float = .085;
		return ((misses * MOD) + (comboPeak * MOD)) + 1.0 * GLOBAL_MULTIPLIER;
	}

	private static function _increaseScore(amount:Int):Void
	{
		PlayState.instance.songScore += amount * Std.int(SCORE_MULTIPLIER);
	}

	private static function _deductScore(amount:Int):Void
	{
		PlayState.instance.songScore -= amount * Std.int(MISS_MULTIPLIER);
	}
}
