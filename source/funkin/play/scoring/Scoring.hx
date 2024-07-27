package funkin.play.scoring;

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

	private static function _resetMultipliers():Void
	{
		SCORE_MULTIPLIER = 1.0;
		MISS_MULTIPLIER = 1.0;
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
