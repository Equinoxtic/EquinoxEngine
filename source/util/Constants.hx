package util;

import lime.app.Application;
import util.macro.GitCommit as Repository;

using StringTools;

class Constants
{
	/**
	 * ============================= APPLICATION INFORMATION =============================
	 */

	/**
	 * The application title of the original FNF project. [ Friday Night Funkin' ]
	 */
	public static final FUNKIN_APPLICATION_TITLE:String = 'Friday Night Funkin\'';

	/**
	 * The application title of the base engine. [ Psych Engine ]
	 */
	public static final ENGINE_APPLICATION_TITLE:String = 'Psych Engine';

	/**
	 * The application of the current engine. [ Solarium Engine ]
	 */
	public static final MAIN_APPLICATION_TITLE:String = 'Solarium Engine';

	/**
	 * The version of Funkin' / FNF.
	 */
	public static var VERSION_FUNKIN(get, never):String;
	
	/**
	 * The version of Psych Engine.
	 */
	public static var VERSION_PSYCH(get, never):String;
	
	/**
	 * The version of the current engine.
	 */
	public static var VERSION_MAIN(get, never):String;

	static function get_VERSION_FUNKIN():String
	{
		return '${FUNKIN_APPLICATION_TITLE} - v${Application.current.meta.get('version')}';
	}

	static function get_VERSION_PSYCH():String
	{
		var http:haxe.Http = new haxe.Http('https://raw.githubusercontent.com/ShadowMario/FNF-PsychEngine/0.6.3/gitVersion.txt');
		var version:String = '';
		http.onData = function(data:String):Void {
			version = data.split('\n')[0].trim();
		}
		http.request();
		return '${ENGINE_APPLICATION_TITLE} v${version}';
	}

	static function get_VERSION_MAIN():String
	{
		#if !debug
		var http:haxe.Http = new haxe.Http('https://raw.githubusercontent.com/Equinoxtic/SolariumEngine/master/gitVersion.txt');
		var version:String = '';
		http.onData = function(data:String):Void {
			version = data.split('\n')[0].trim();
		}
		http.request();
		return '${MAIN_APPLICATION_TITLE} - v${version}';
		#else
		return '${MAIN_APPLICATION_TITLE} - DEV : ${Repository.getGitBranch()} @ ${Repository.getGitCommitHash()}';
		#end
	}
	
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
	public static final ICON_BOP_BEATDECAY:Float = 7.0;

	/**
	 * The mod of the icon bop based on beat. (Used for ICON_BOP_INTENSITY_BEAT)
	 */
	public static final ICON_BOP_BEATMOD:Int = 4;

	/**
	 * The intensity of the icon bop.
	 */
	public static final ICON_BOP_INTENSITY:Float = 1.2;

	/**
	 * The intensity of the icon bop every MOD beats. (Refer to ICON_BOP_BEATMOD)
	 */
	public static final ICON_BOP_INTENSITY_BEAT:Float = ICON_BOP_INTENSITY + 0.21;

	/**
	 * ============================= NOTE VALUES =============================
	 */

	/**
	 * The alpha/transparency of the Note Tail.
	 */
	public static final NOTE_TAIL_ALPHA:Float = 0.77;

	/**
	 * The amplitude of the note tail wiggle.
	 */
	public static final NOTE_WIGGLE_AMPLITUDE:Float = 0.06;

	/**
	 * The frequency of the note tail wiggle.
	 */
	public static final NOTE_WIGGLE_FREQUENCY:Float = 7;

	/**
	 * The speed of the note tail wiggle.
	 */
	public static final NOTE_WIGGLE_SPEED:Float = 15;

	/**
	 * The decay of the amplitude of the note tail wiggle.
	 */
	public static final NOTE_WIGGLE_AMPLITUDE_DECAY:Float = 8;

	/**
	 * ============================= UI RELATED VALUES =============================
	 */

	/**
	 * The size of the Score Tracker.
	 */
	public static final SCORE_TRACKER_SIZE:Float = 1.0;

	/**
	 * The size that gets added up to the Score Tracker. (Used for the Score Tracker zoom tween)
	 */
	public static final SCORE_TRACKER_SIZE_ADDITIVE:Float = 0.075;

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

	public static final CAMERA_GAME_ZOOM:Float = 1.0;

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
}
