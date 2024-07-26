package funkin.util;

import lime.app.Application;
import funkin.util.Http;
import funkin.util.macro.GitCommit as Repository;

using StringTools;

class Constants
{
	/**
	 * ============================= SONG VALUES =============================
	 */

	/**
	 * The volume for the instrumental.
	 */
	public static final INSTRUMENTAL_VOLUME:Float = 1.0;

	/**
	 * The volume for the vocals.
	 */
	public static final VOCALS_VOLUME:Float = 1.0;

	/**
	 * ============================= PLAYER ICON VALUES =============================
	 */

	/**
	 * The default offset of the icons.
	 */
	public static final ICON_OFFSET:Int = 26;

	/**
	 * The winning percentage based on health percentage.
	 */
	public static final WINNING_PERCENT:Int = 80;

	/**
	 * The losing percentage based on health percentage.
	 */
	public static final LOSING_PERCENT:Int = 20;

	/**
	 * The decay of the icon bop.
	 */
	public static final ICON_BOP_BEATDECAY:Float = 6.0;

	/**
	 * The intensity of the icon bop.
	 */
	public static final ICON_BOP_INTENSITY:Float = 1.1;

	/**
	 * The intensity of the icon bop every MOD beats.
	 */
	public static final ICON_BOP_INTENSITY_ON_BEAT:Float = ICON_BOP_INTENSITY * 1.125;

	/**
	 * ============================= NOTE VALUES =============================
	 */

	/**
	 * The alpha/transparency of the Note itself.
	 */
	public static final NOTE_ALPHA:Float = 1.0;

	/**
	 * The alpha/transparency of the Note Tail.
	 */
	public static final NOTE_TAIL_ALPHA:Float = 0.6;

	/**
	 * ============================= UI RELATED VALUES =============================
	 */

	/**
	 * The size of the Statistics HUD.
	 */
	public static final STATISTICS_HUD_SIZE:Float = 1.0;

	/**
	 * The FONT size of each texts in the Statistics HUD.
	 */
	public static final STATISTICS_FONT_SIZE:Int = 20;

	/**
	 * The text's BORDER size in the Statistics HUD.
	 */
	public static final STATISTICS_BORDER_SIZE:Float = 2.5;

	/**
	 * The size of the Judgement Counter.
	 */
	public static final JUDGEMENT_COUNTER_SIZE:Float = 1.0;

	/**
	 * The size of the Gameplay Info.
	 */
	public static final GAMEPLAY_INFO_SIZE:Float = 1.0;

	/**
	 * The size of the Engine Watermark.
	 */
	public static final WATERMARK_SIZE:Float = 1.0;

	/**
	 * The size of the 'Rating' sprite.
	 * 'Sick!!', 'Good!', 'Bad', and 'Shit' sprites.
	 */
	public static final RATING_SPRITE_SIZE:Float = 0.6;

	/**
	 * The size of the 'Combo' sprite.
	 */
	public static final COMBO_SPRITE_SIZE:Float = 0.5;

	/**
	 * The size for the 'Numerical Combo' sprites.
	 */
	public static final NUMERICAL_COMBO_SIZE:Float = 0.5;

	/**
	 * The duration of the song's credits pop-up.
	 */
	public static final CREDITS_HUD_DURATION:Float = 0.8;

	/**
	 * The starting delay of the song's credits pop-up
	 */
	public static final CREDITS_HUD_DELAY:Float = CREDITS_HUD_DURATION + 2.35;

	/**
	 * The zoom of the main camera. (camGame | FlxG.camera.zoom)
	 */
	public static final CAMERA_GAME_ZOOM:Float = 1.0;

	/**
	 * The zoom of the HUD camera.
	 */
	public static final CAMERA_HUD_ZOOM:Float = 1.0;

	/**
	 * ============================= TWEEN VALUES =============================
	 */

	/**
	 * The default ease of the Score Tracker Zoom Tween.
	 */
	public static final SCORE_TRACKER_TWEEN_EASE:String = 'cubeOut';

	/**
	 * The default duration of the Score Tracker Zoom Tween.
	 */
	public static final SCORE_TRACKER_TWEEN_DURATION:Float = 0.6;

	/**
	 * The duration of the 'Rating Sprite' tween.
	 */
	public static final RATING_SPRITE_DURATION:Float = 0.35;

	/**
	 * The starting delay of the 'Rating Sprite' tween.
	 */
	public static final RATING_SPRITE_DELAY:Float = 0.23;

	/**
	 * The duration of the 'Combo Sprite' tween.
	 */
	public static final COMBO_SPRITE_DURATION:Float = RATING_SPRITE_DURATION + 0.02;

	/**
	 * The starting delay of the 'Combo Sprite' tween.
	 */
	public static final COMBO_SPRITE_DELAY:Float = RATING_SPRITE_DELAY + 0.02;

	/**
	 * The duration of the 'Numerical Score' tween.
	 */
	public static final NUMERICAL_SCORE_DURATION:Float = COMBO_SPRITE_DURATION + 0.01;

	/**
	 * The starting delay of the 'Numerical Score' tween.
	 */
	public static final NUMERICAL_SCORE_DELAY:Float = COMBO_SPRITE_DELAY + 0.03;

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
	public static final HEALTH_BAD_BONUS:Float = 0.15 / 100.0 * HEALTH_MAX;

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

	/**
	 * ============================= SCORE VALUES =============================
	 */

	/**
	 * The amount of score that the player gains when holding notes. (per second)
	 */
	public static final SCORE_HOLD_BONUS:Float = 250.0;

	/**
	 * The maximum value for the score multiplier.
	 */
	public static final SCORE_MULTIPLIER_MAX:Float = 500.0;

	/**
	 * The maximum value for the miss multiplier.
	 */
	public static final MISS_MULTIPLIER_MAX:Float = SCORE_MULTIPLIER_MAX / 15.0;

	/**
	 * The global cap for all integers.
	 */
	public static final GLOBAL_NUMBER_CAP:Int = 999999;
}
