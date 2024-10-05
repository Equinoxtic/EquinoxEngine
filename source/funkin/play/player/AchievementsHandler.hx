package funkin.play.player;

import flixel.FlxCamera;
import funkin.play.player.Achievements.AchievementObject;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

using StringTools;

class AchievementsHandler extends FlxTypedSpriteGroup<FlxSprite>
{
	private var ACHIEVEMENT_OBJECT:AchievementObject = null;

	final TARGET_CAMERA:FlxCamera = PlayState.instance.camOther;

	public static final DEFAULT_ACHIEVEMENTS:Array<String> = [
		'week1_nomiss', 'week2_nomiss', 'week3_nomiss',
		'week4_nomiss', 'week5_nomiss', 'week6_nomiss',
		'week7_nomiss', 'ur_bad', 'ur_good',
		'hype', 'two_keys', 'toastie', 'debugger'
	];

	public function new():Void
	{
		super(0, 0);
		trace('Initialized Achievements Handler');
	}

	#if ACHIEVEMENTS_ALLOWED
	public function awardAchievement(achievement:String):Void
	{
		ACHIEVEMENT_OBJECT = new AchievementObject(achievement, TARGET_CAMERA);
		ACHIEVEMENT_OBJECT.onFinish = function() {
			ACHIEVEMENT_OBJECT = null;
			if (PlayState.instance.endingSong && !PlayState.instance.inCutscene) {
				PlayState.instance.endSong();
			}
		}
		add(ACHIEVEMENT_OBJECT);
	}
	#end

	#if ACHIEVEMENTS_ALLOWED
	public static function checkAchievement(achievesToCheck:Array<String> = null):String
	{
		if (PlayState.chartingMode)
			return null;

		var usedPractice:Bool = (Preferences.getGameplaySetting('practice', false) || Preferences.getGameplaySetting('botplay', false));
		var cpuControlled:Bool = PlayState.instance.cpuControlled;
		var practiceMode:Bool = PlayState.instance.practiceMode;
		var ratingPercent:Float = PlayState.instance.ratingPercent;

		for (i in 0...achievesToCheck.length)
		{
			var achievementName:String = achievesToCheck[i];
			if (!Achievements.isAchievementUnlocked(achievementName) && !cpuControlled)
			{
				var unlock:Bool = false;

				@:privateAccess
				var keysPressed:Array<Bool> = PlayState.instance.keysPressed;

				if (achievementName.contains(WeekData.getWeekFileName()) && achievementName.endsWith('nomiss'))
				{
					if (PlayState.isStoryMode && PlayState.campaignMisses + PlayState.instance.songMisses < 1 && FunkinUtil.difficultyString() == 'HARD' && PlayState.storyPlaylist.length <= 1 && !PlayState.changedDifficulty && !usedPractice) {
						unlock = true;
					}
				}

				switch(achievementName)
				{
					case 'ur_bad':
						if (ratingPercent < 0.2 && !practiceMode) {
							unlock = true;
						}

					case 'ur_good':
						if (ratingPercent >= 1 && !usedPractice) {
							unlock = true;
						}

					case 'roadkill_enthusiast':
						if(Achievements.henchmenDeath >= 100) {
							unlock = true;
						}

					case 'oversinging':
						if(PlayState.instance.boyfriend.holdTimer >= 10 && !usedPractice) {
							unlock = true;
						}

					case 'hype':
						@:privateAccess
						if(!PlayState.instance.boyfriendIdled && !usedPractice) {
							unlock = true;
						}

					case 'two_keys':
						if(!usedPractice) {
							var howManyPresses:Int = 0;
							for (j in 0...keysPressed.length) {
								if (keysPressed[j]) howManyPresses++;
							}

							if(howManyPresses <= 2) {
								unlock = true;
							}
						}

					case 'toastie':
						if(!GlobalSettings.SHADERS && GlobalSettings.LOW_QUALITY && !GlobalSettings.SPRITE_ANTIALIASING) {
							unlock = true;
						}

					case 'debugger':
						if(Paths.formatToSongPath(PlayState.SONG.song) == 'test' && !usedPractice) {
							unlock = true;
						}
				}

				if (unlock) {
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}
	#end
}
