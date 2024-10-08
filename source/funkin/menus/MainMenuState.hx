package funkin.menus;

#if desktop
import funkin.api.discord.Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import funkin.play.player.Achievements;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FunkinSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'options',
		#if MODS_ALLOWED
		'mods',
		#end
		#if ACHIEVEMENTS_ALLOWED
		'awards',
		#end
		'credits',
		#if !switch
		'donate'
		#end
	];

	var mainBG:FunkinBG;
	var magentaBG:FunkinBG;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	var menuTexts:FlxTypedGroup<FlxText>;

	var mainChecker:Checkerboard;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		debugKeys = Preferences.copyKey(Preferences.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = (Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1)) * 0.5;

		mainBG = new FunkinBG(0, -80, Paths.image('menuBG'), 0.0, yScroll, 0xFFFFFFFF);
		mainBG.flickers = false;
		add(mainBG);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magentaBG = new FunkinBG(0, -80, Paths.image('menuDesat'), 0.0, yScroll, 0xFFFD719B);
		magentaBG.flickers = true;
		magentaBG.visible = false;
		add(magentaBG);

		mainChecker = new Checkerboard(XY, 1, HUGE, 0.3);
		mainChecker.setTileSpeed(0.47, 0.16);
		add(mainChecker);

		menuItems = new FlxTypedGroup<FunkinSprite>();
		add(menuItems);

		var scale:Float = 1;

		for (i in 0...optionShit.length)
		{
			var offset:Float = 100 + (Math.max(optionShit.length, 4) - 4) * 250;

			var menuItem:FunkinSprite = new FunkinSprite(0, (i * 180) + offset);
			menuItem.scale.set(scale, scale);

			menuItem.loadAnimatedSprite('mainmenu/menu_${optionShit[i]}', [
					'idle'     => '${optionShit[i]} basic',
					'selected' => '${optionShit[i]} white'
				], {
					framerate: 24,
					looped: true,
					defaultAnimation: 'idle'
				}
			);

			menuItem.ID = i;
			menuItem.screenCenter(X);

			menuItems.add(menuItem);

			var scr:Float = (optionShit.length - 4) * 0.35;
			if (optionShit.length < 6) {
				scr = 0;
			}

			menuItem.scrollFactor.set(0, scr);

			menuItem.updateHitbox();
		}

		var bars:FunkinSprite = new FunkinSprite(0, 0);
		bars.loadSprite('ui/menu/menuBars');
		bars.screenCenter();
		add(bars);

		FlxG.camera.follow(camFollowPos, null, 1);

		menuTexts = new FlxTypedGroup<FlxText>();
		add(menuTexts);

		var engineVersion:FlxText = new FlxText(12, FlxG.height - 44, 0, '${Variables.getGroupedVersionString()}', 12);
		menuTexts.add(engineVersion);

		var fnfVersion:FlxText = new FlxText(12, FlxG.height - 24, 0, '${Variables.getFunkinVersionString()}', 12);
		menuTexts.add(fnfVersion);

		menuTexts.forEach(function(txt:FlxText) {
			txt.antialiasing = GlobalSettings.SPRITE_ANTIALIASING;
			txt.scrollFactor.set();
			txt.setFormat(Paths.font('phantommuff.ttf'), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		});

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if (!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				Preferences.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement():Void
	{
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8) {
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var lerpVal:Float = FunkinUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					FunkinUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween) {
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									case 'options':
										MusicBeatState.switchState(new OptionsState());
									#if MODS_ALLOWED
									case 'mods':
										MusicBeatState.switchState(new ModsMenuState());
									#end
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		menuItems.forEach(function(spr:FlxSprite) {
			spr.screenCenter(X);
		});

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');

				var add:Float = 0;
				if (menuItems.length > 4) {
					add = menuItems.length * 8;
				}

				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);

				spr.centerOffsets();
			}
		});
	}
}
