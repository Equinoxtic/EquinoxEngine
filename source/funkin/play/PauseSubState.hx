package funkin.play;

import funkin.play.song.Chart.ParseType;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import openfl.utils.Assets as OpenFlAssets;
import funkin.play.scoring.*;
import funkin.sound.FunkinSound;
import funkin.util.EaseUtil;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'Change Difficulty', 'Exit to menu'];
	var difficultyChoices = [];
	var curSelected:Int = 0;

	var pauseTexts:FlxTypedGroup<FlxText>;

	var pauseMusic:FlxSound;
	var currentModeTxt:FlxText;
	var skipTimeText:FlxText;
	var skipTimeTracker:Alphabet;
	var curTime:Float = Math.max(0, Conductor.songPosition);

	public static var songName:String = '';

	var bg:FlxSprite;

	public function new(x:Float, y:Float)
	{
		super();

		if(FunkinUtil.difficulties.length < 2) menuItemsOG.remove('Change Difficulty'); //No need to change difficulty if there is only one!

		if(PlayState.chartingMode)
		{
			menuItemsOG.insert(2, 'Leave Charting Mode');

			var num:Int = 0;
			if(!PlayState.instance.startingSong)
			{
				num = 1;
				menuItemsOG.insert(3, 'Skip Time');
			}
			menuItemsOG.insert(3 + num, 'End Song');
			menuItemsOG.insert(4 + num, 'Toggle Practice Mode');
			menuItemsOG.insert(5 + num, 'Toggle Botplay');
		}
		menuItems = menuItemsOG;

		for (i in 0...FunkinUtil.difficulties.length) {
			var diff:String = '' + FunkinUtil.difficulties[i];
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');

		playPauseMusic(GlobalSettings.PAUSE_MUSIC);

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		pauseTexts = new FlxTypedGroup<FlxText>();
		add(pauseTexts);

		var levelInfo:FlxText = new FunkinText(0, 15, 0, "", 32, RIGHT, true);
		levelInfo.text += '${PlayState.SONG.song} - ${PlayState.SONG_DATA.artist}';
		pauseTexts.add(levelInfo);

		var difficulty:FlxText = new FunkinText(0, 15 + 40, 0, "", 32, RIGHT, true);
		difficulty.text += 'Difficulty: ${FunkinUtil.difficultyString()}';
		pauseTexts.add(difficulty);

		var restarts:FlxText = new FunkinText(0, 15 + 80, 0, "", 32, RIGHT, true);
		restarts.text += 'Restarts: ${PlayState.restartCounter}';
		pauseTexts.add(restarts);

		var blueballedTxt:FlxText = new FunkinText(0, 15 + 120, 0, "", 32, RIGHT, true);
		blueballedTxt.text = "Blueballed: " + PlayState.deathCounter;
		pauseTexts.add(blueballedTxt);

		currentModeTxt = new FunkinText(0, 15 + 160, FlxG.width, "", 32, RIGHT, true);
		pauseTexts.add(currentModeTxt);

		pauseTexts.forEach(function(txt:FlxText) {
			txt.updateHitbox();
			txt.borderSize = 3.5;
			txt.antialiasing = GlobalSettings.SPRITE_ANTIALIASING;
			txt.alpha = 0;
			txt.x = FlxG.width - (txt.width + 20);
		});

		var textTweenDelay:Float = 0.5;

		pauseTexts.forEach(function(txt:FlxText) {
			textTweenDelay += 0.1;
			FlxTween.tween(txt, {alpha: 1, y: txt.y + 5}, 0.4, {ease: FlxEase.cubeOut, startDelay: textTweenDelay / 2});
		});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		setPauseMenuAlpha(0);
		tweenPauseMenuAlpha(1, 0.2, 'expoInOut', false);

		regenMenu();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	private function playPauseMusic(?musicString:String):Void
	{
		pauseMusic = new FlxSound();

		if (musicString != null && OpenFlAssets.exists(Paths.formatToSongPath(GlobalSettings.PAUSE_MUSIC)) && pauseMusic != null)
		{
			if (songName != null) {
				pauseMusic.loadEmbedded(Paths.music(songName), true, true);
			} else if (songName != 'None') {
				pauseMusic.loadEmbedded(Paths.music(Paths.formatToSongPath(musicString)), true, true);
			}

			pauseMusic.volume = 0;

			pauseMusic.play(false);
			FlxG.sound.list.add(pauseMusic);

			if (pauseMusic.volume < 0.5)
				pauseMusic.fadeIn(1.2, 0, 0.5);
		}
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;
	override function update(elapsed:Float)
	{
		cantUnpause -= elapsed;

		super.update(elapsed);

		currentModeTxt.visible = (PlayState.instance.practiceMode || PlayState.instance.cpuControlled || PlayState.chartingMode);

		updateCurrentModeText();

		updateSkipTextStuff();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		var daSelected:String = menuItems[curSelected];
		switch (daSelected)
		{
			case 'Skip Time':
				if (controls.UI_LEFT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime -= 1000;
					holdTime = 0;
				}
				if (controls.UI_RIGHT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime += 1000;
					holdTime = 0;
				}

				if(controls.UI_LEFT || controls.UI_RIGHT)
				{
					holdTime += elapsed;
					if(holdTime > 0.5)
					{
						curTime += 45000 * elapsed * (controls.UI_LEFT ? -1 : 1);
					}

					if(curTime >= FlxG.sound.music.length) curTime -= FlxG.sound.music.length;
					else if(curTime < 0) curTime += FlxG.sound.music.length;
					updateSkipTimeText();
				}
		}

		if (accepted && (cantUnpause <= 0 || !GlobalSettings.CONTROLLER_MODE))
		{
			if (menuItems == difficultyChoices)
			{
				if (menuItems.length - 1 != curSelected && difficultyChoices.contains(daSelected)) {
					var name:String = PlayState.SONG.song;
					var poop = Highscore.formatSong(name, curSelected);
					PlayState.SONG = Chart.loadChartData(name, difficultyChoices[curSelected].toLowerCase(), ParseType.SONG);
					PlayState.storyDifficulty = curSelected;
					MusicBeatState.resetState();
					FlxG.sound.music.volume = 0;
					PlayState.changedDifficulty = true;
					PlayState.chartingMode = false;
					return;
				}

				menuItems = menuItemsOG;
				regenMenu();
			}

			switch (daSelected)
			{
				case "Resume":
					/**
					 * Close the pause menu.
					 */
					tweenPauseMenuAlpha(0, 0.6, 'sineInOut', true);

				case 'Change Difficulty':
					menuItems = difficultyChoices;
					deleteSkipTimeText();
					regenMenu();

				case 'Toggle Practice Mode':
					PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
					PlayState.changedDifficulty = true;

				case "Restart Song":
					restartSong();

				case "Leave Charting Mode":
					restartSong();
					PlayState.chartingMode = false;

				case 'Skip Time':
					if(curTime < Conductor.songPosition)
					{
						PlayState.startOnTime = curTime;
						restartSong(true);
					}
					else
					{
						if (curTime != Conductor.songPosition)
						{
							PlayState.instance.clearNotesBefore(curTime);
							PlayState.instance.setSongTime(curTime);
						}
						close();
					}

				case "End Song":
					close();
					PlayState.instance.finishSong(true);

				case 'Toggle Botplay':
					PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
					PlayState.changedDifficulty = true;
					PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled;
					PlayState.instance.botplayTxt.alpha = 1;
					PlayState.instance.botplaySine = 0;

				case "Exit to menu":
					FlxG.mouse.visible = true;

					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;

					WeekData.loadTheFirstEnabledMod();
					if(PlayState.isStoryMode) {
						MusicBeatState.switchState(new StoryMenuState());
					} else {
						MusicBeatState.switchState(new FreeplayState());
					}
					PlayState.cancelMusicFadeTween();
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
			}
		}
	}

	private function updateCurrentModeText():Void
	{
		currentModeTxt.text =
			((PlayState.instance.practiceMode) ? 'PRACTICE MODE\n' : '')
			+ ((PlayState.instance.cpuControlled) ? 'BOTPLAY MODE\n' : '')
			+ ((PlayState.chartingMode) ? 'CHARTING MODE\n' : '');
	}

	function deleteSkipTimeText()
	{
		if(skipTimeText != null)
		{
			skipTimeText.kill();
			remove(skipTimeText);
			skipTimeText.destroy();
		}
		skipTimeText = null;
		skipTimeTracker = null;
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.restartCounter++;

		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		FunkinSound.muteVoices(false);

		if(noTrans) {
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		} else {
			MusicBeatState.resetState();
		}
	}

	override function destroy()
	{
		pauseMusic.fadeOut(0.2, 0);

		super.destroy();
	}

	private function setPauseMenuAlpha(?toAlpha:Float):Void
	{
		grpMenuShit.forEach(function(spr:FlxSprite) { spr.alpha = toAlpha; });
		pauseTexts.forEach(function(txt:FlxText) { txt.alpha = toAlpha; });
		bg.alpha = toAlpha;
	}

	private function tweenPauseMenuAlpha(?toAlpha:Float, ?duration:Float, ?ease:Null<String>, ?closeState:Bool = false):Void
	{
		grpMenuShit.forEach(function(spr:FlxSprite) {
			FlxTween.tween(spr, {alpha: toAlpha}, duration, {ease: EaseUtil.getFlxEaseByString(ease)});
		});

		if (closeState) {
			pauseTexts.forEach(function(txt:FlxText) {
				FlxTween.tween(txt, {alpha: toAlpha}, duration, {ease: EaseUtil.getFlxEaseByString(ease)});
			});
		}

		FlxTween.tween(bg, {alpha: ((toAlpha >= 0.6) ? toAlpha - 0.4 : toAlpha)}, duration, {ease: EaseUtil.getFlxEaseByString(ease), onComplete: function(_) {
			new FlxTimer().start(0.1, function(_) {
				if (closeState) {
					closePauseMenu();
				}
			});
		}});
	}

	private function closePauseMenu():Void
	{
		close();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));

				if(item == skipTimeTracker)
				{
					curTime = Math.max(0, Conductor.songPosition);
					updateSkipTimeText();
				}
			}
		}
	}

	function regenMenu():Void
	{
		for (i in 0...grpMenuShit.members.length)
		{
			var obj = grpMenuShit.members[0];
			obj.kill();
			grpMenuShit.remove(obj, true);
			obj.destroy();
		}

		for (i in 0...menuItems.length) {
			var item = new Alphabet(90, 320, menuItems[i], true);
			item.isMenuItem = true;
			item.targetY = i;
			grpMenuShit.add(item);

			if(menuItems[i] == 'Skip Time')
			{
				skipTimeText = new FlxText(0, 0, 0, '', 64);
				skipTimeText.setFormat(Paths.font("phantommuff.ttf"), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				skipTimeText.scrollFactor.set();
				skipTimeText.borderSize = 2;
				skipTimeTracker = item;
				add(skipTimeText);

				updateSkipTextStuff();
				updateSkipTimeText();
			}
		}
		curSelected = 0;
		changeSelection();
	}

	function updateSkipTextStuff()
	{
		if(skipTimeText == null || skipTimeTracker == null) return;

		skipTimeText.x = skipTimeTracker.x + skipTimeTracker.width + 60;
		skipTimeText.y = skipTimeTracker.y;
		skipTimeText.visible = (skipTimeTracker.alpha >= 1);
	}

	function updateSkipTimeText()
	{
		skipTimeText.text = FlxStringUtil.formatTime(Math.max(0, Math.floor(curTime / 1000)), false) + ' / ' + FlxStringUtil.formatTime(Math.max(0, Math.floor(FlxG.sound.music.length / 1000)), false);
	}
}
