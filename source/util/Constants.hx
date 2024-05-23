package util;

class Constants
{
	/**
	 * ============================= PLAYER ICON VALUES =============================
	 */

	public static final ICON_OFFSET:Int = 26;

	public static final WINNING_PERCENT:Int = 80;
	
	public static final LOSING_PERCENT:Int = 20;

	public static final ICON_BOP_BEATDRAIN:Int = 8;
	
	public static final ICON_BOP_BEATMOD:Int = 4;

	public static final ICON_BOP_INTENSITY:Float = 1.2;

	public static final ICON_BOP_INTENSITY_BEAT:Float = ICON_BOP_INTENSITY + 0.3;

	/**
	 * ============================= UI RELATED VALUES =============================
	 */

	public static final SCORE_TRACKER_SIZE:Float = 1.0;

	public static final SCORE_TRACKER_SMALL:Float = SCORE_TRACKER_SIZE - 0.15;

	public static final SCORE_TRACKER_SIZE_ADDITIVE:Float = 0.22;

	public static final JUDGEMENT_COUNTER_SIZE:Float = 1.0;

	public static final JUDGEMENT_COUNTER_SMALL:Float = SCORE_TRACKER_SIZE - 0.115;

	public static final GAMEPLAY_INFO_SIZE:Float = 1.0;

	public static final GAMEPLAY_INFO_SMALL:Float = GAMEPLAY_INFO_SIZE - 0.1;

	public static final WATERMARK_SIZE:Float = 1;

	public static final WATERMARK_SMALL:Float = WATERMARK_SIZE - 0.15;

	public static final WATERMARK_SPRITE_SIZE = WATERMARK_SIZE - 0.85;

	public static final WATERMARK_SPRITE_SMALL = WATERMARK_SPRITE_SIZE - 0.05;

	/**
	 * ============================= TWEEN VALUES =============================
	 */

	public static final SCORE_TRACKER_TWEEN_EASE:String = 'quadInOut';
	
	public static final SCORE_TRACKER_TWEEN_DURATION:Float = 0.35;

	/**
	 * ============================= HEALTH VALUES =============================
	 */
	
	/**
	 * The minimum amount of health that the player can have.
	 */
	public static final HEALTH_MIN:Float = 0.0;

	/**
	 * The maximum amount of health that the player can have.
	 */
	public static final HEALTH_MAX:Float = 2.0;

	/**
	 * The starting amount of the health that the player has.
	 */
	public static final HEALTH_START:Float = HEALTH_MAX / 2.0;

	/**
	 * The amount of health that the player gains when they receive a 'MARVELOUS' rating.
	 */
	public static final HEALTH_MARVELOUS_BONUS:Float = 2.0 / 100.0 * HEALTH_MAX;

	/**
	 * The amount of health that the player gains when they receive a 'SICK' rating.
	 */
	public static final HEALTH_SICK_BONUS:Float = 1.5 / 100.0 * HEALTH_MAX;

	/**
	 * The amount of health that the player gains when they receive a 'GOOD' rating.
	 */
	public static final HEALTH_GOOD_BONUS:Float = 0.75 / 100.0 * HEALTH_MAX;

	/**
	 * The amount of health that the player gains when they receive a 'BAD' rating.
	 */
	public static final HEALTH_BAD_BONUS:Float = 0.0 / 100.0 * HEALTH_MAX;

	/**
	 * The amount of health that the player gains when they receive a 'SHIT' rating.
	 * SHITs actually lose health now lmao
	 */
	public static final HEALTH_SHIT_BONUS:Float = -1.0 / 100.0 * HEALTH_MAX;

	/**
	 * The amount of health that the player gains when holding a note. (per second)
	 */
	public static final HEALTH_HOLD_BONUS:Float = 7.5 / 100.0 * HEALTH_MAX;

	/**
	 * The amount of health that the player loses when missing a note.
	 */
	public static final HEALTH_MISS_PENALTY:Float = 4.0 / 100.0  * HEALTH_MAX;
}
