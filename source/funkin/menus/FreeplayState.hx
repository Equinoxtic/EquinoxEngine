package funkin.menus;

import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.util.FlxStringUtil;
#if desktop
import funkin.api.discord.Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import funkin.play.song.*;
import funkin.play.scoring.*;
import funkin.play.components.HealthIcon;
import funkin.input.Controls;
import funkin.menus.substate.*;
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = '';

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;
	var intendedRatingFC:String = '';
	var intendedRanking:String = '';

	private var grpSongs:FlxTypedGroup<Alphabet>;
	var grpDifficulties:FlxTypedSpriteGroup<DifficultySprite>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var shittyText:FlxText;

	var checkerBg:Checkerboard;

	override function create()
	{
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...WeekData.weeksList.length) {
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length) {
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);

			for (song in leWeek.songs) {
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3) {
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		WeekData.loadTheFirstEnabledMod();

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = Preferences.globalAntialiasing;
		add(bg);
		bg.screenCenter();

		checkerBg = new Checkerboard(XY, 1, EXTRA_HUGE, .27, 0xFF000000, 0.0, 0.09);
		add(checkerBg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(90, 320, songs[i].songName, true);
			songText.antialiasing = Preferences.globalAntialiasing;
			songText.isMenuItem = true;
			songText.targetY = i - curSelected;
			grpSongs.add(songText);

			var maxWidth = 980;
			if (songText.width > maxWidth)
			{
				songText.scaleX = maxWidth / songText.width;
			}
			songText.snapToPosition();

			Paths.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.antialiasing = Preferences.globalAntialiasing;
			icon.sprTracker = songText;

			iconArray.push(icon);
			add(icon);
		}
		WeekData.setDirectoryFromWeek();

		var bars:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/menu/menuBars'));
		bars.antialiasing = Preferences.globalAntialiasing;
		bars.scrollFactor.set();
		bars.screenCenter();
		add(bars);

		grpDifficulties = new FlxTypedSpriteGroup<DifficultySprite>(-300, FlxG.height * 0.75);
		add(grpDifficulties);

		scoreText = new FlxText(FlxG.width * 0.8, 18, 0, "", 32);
		scoreText.antialiasing = Preferences.globalAntialiasing;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		scoreText.borderSize = 3.5;
		
		shittyText = new FlxText(FlxG.width * 0.8, 10, 0, "PERSONAL BEST", 48);
		shittyText.setFormat(Paths.font('phantommuff.ttf'), 48, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		shittyText.borderSize = 3.5;
		add(shittyText);

		scoreBG = new FlxSprite(scoreText.x - 6, 85).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.000001;
		add(scoreBG);

		var diffSelLeft:DifficultySelector = new DifficultySelector(FlxG.width * 0.7, grpDifficulties.y - 10, false, controls);
		var diffSelRight:DifficultySelector = new DifficultySelector(diffSelLeft.x + 305, grpDifficulties.y - 10, true, controls);
		add(diffSelLeft);
		add(diffSelRight);

		add(scoreText);

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;

		if(lastDifficultyName == '')
		{
			lastDifficultyName = FunkinUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, FunkinUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		changeSelection();
		changeDiff();

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF353535);
		textBG.alpha = 0.6;
		add(textBG);

		#if PRELOAD_ALL
		var leText:String = "Press SPACE to play song instrumental / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 16;
		#else
		var leText:String = "Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 18;
		#end
		
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, RIGHT);
		text.antialiasing = Preferences.globalAntialiasing;
		text.scrollFactor.set();
		add(text);

		super.create();

		for (i in 0...FunkinUtil.difficulties.length) 
		{
			var diffSprite:DifficultySprite = new DifficultySprite(FunkinUtil.difficulties[i].toLowerCase());
			diffSprite.difficultyId = FunkinUtil.difficulties[i].toLowerCase();
			grpDifficulties.add(diffSprite);
		}

		grpDifficulties.group.forEach(function(spr) {
			spr.visible = false;
		});
	
		for (diffSprite in grpDifficulties.group.members)
		{
			if (diffSprite == null) continue;
			if (diffSprite.difficultyId == FunkinUtil.difficulties[curDifficulty].toLowerCase()) diffSprite.visible = true;
		}

		FlxTween.tween(grpDifficulties, {x: diffSelLeft.x + 70}, 0.6, {ease: FlxEase.quartOut});
	}

	override function closeSubState()
	{
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	var holdTime:Float = 0;
	var playingSongInst:Bool = false;
	override function update(elapsed:Float)
	{
		checkerBg.updatePosition(0.0, 0.21);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, FunkinUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, FunkinUtil.boundTo(elapsed * 12, 0, 1));
		intendedRanking = '${Highscore.getRanking(songs[curSelected].songName, curDifficulty)}';
		intendedRatingFC = '${Highscore.getRatingFC(songs[curSelected].songName, curDifficulty)}';

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if (ratingSplit.length < 2) {
			ratingSplit.push('');
		}
		
		while (ratingSplit[1].length < 2) {
			ratingSplit[1] += '0';
		}

		scoreText.text = '\n\n'
			+ '> SCORE: ${lerpScore}\n'
			+ '> ACCURACY: ${ratingSplit.join('.')}%\n'
			+ '> ${intendedRatingFC} - ${intendedRanking}';
		
		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;
		var ctrl = FlxG.keys.justPressed.CONTROL;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if(songs.length > 1)
		{
			if (upP)
			{
				changeSelection(-shiftMult);
				holdTime = 0;
			}
			if (downP)
			{
				changeSelection(shiftMult);
				holdTime = 0;
			}

			if (controls.UI_DOWN || controls.UI_UP)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
				{
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					changeDiff();
				}
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
				changeSelection(-shiftMult * FlxG.mouse.wheel, false);
				changeDiff();
			}
		}

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		else if (controls.UI_RIGHT_P)
			changeDiff(1);
		else if (upP || downP)
			changeDiff();

		if (controls.BACK)
		{
			persistentUpdate = false;
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
		if(ctrl)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}
		else if(space)
		{
			playSongInst(1.0);
		}
		else if (accepted)
		{
			persistentUpdate = false;

			if (colorTween != null) {
				cancelColorTweens();
			}

			var selectedSong:String = Paths.formatToSongPath(songs[curSelected].songName);

			loadSong(selectedSong, FunkinUtil.difficulties[curDifficulty].toLowerCase());

			checkChartingInput();

			FlxG.sound.music.volume = 0;

			destroyFreeplayVocals();
		}
		else if (controls.RESET)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		super.update(elapsed);

		if (playingSongInst) trace('${FlxStringUtil.formatTime(Math.floor(FlxG.sound.music.time / 1000))}');
	}

	private function playSongInst(?instVolume:Null<Float>):Void
	{
		if (instPlaying != curSelected)
		{
			var shitVolume = instVolume;

			FlxG.sound.music.volume = 0;
			FlxG.sound.music.stop();

			destroyFreeplayVocals();

			Paths.currentModDirectory = songs[curSelected].folder;
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
			PlayState.SONG = Song.loadFromJson(poop, FunkinUtil.difficulties[curDifficulty].toLowerCase());

			instPlaying = curSelected;

			playingSongInst = true;

			if (playingSongInst) {
				if (!(instVolume > 0))
					shitVolume = 1.0;

				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), shitVolume, true);
			}

			FlxG.sound.music.onComplete = finishSongInst.bind();
		}
	}

	private function loadSong(?selectedSong:String, ?jsonDiff:String):Void
	{
		var songPath:String = Std.string('charts/${selectedSong}/difficulties/${jsonDiff}');
		
		#if MODS_ALLOWED
		if (!sys.FileSystem.exists(Paths.modsJson(songPath)) && !sys.FileSystem.exists(Paths.json(songPath)))
		#else
		if (!OpenFlAssets.exists(Paths.json(songPath)))
		#end
		{
			#if (debug)
			FlxG.log.add('Couldnt find file: ${songPath} of ${selectedSong}');
			#else
			trace('Couldnt find file: ${songPath} of ${selectedSong}');
			#end

			jsonDiff = 'hard';
			selectedSong = 'dad-battle';
			curDifficulty = 2;
		}

		#if (debug)
		FlxG.log.add('Chose Song: ${selectedSong.replace('-', ' ').toUpperCase()} - ${jsonDiff.toUpperCase()}');
		#else
		trace('Chose Song: ${selectedSong.replace('-', ' ').toUpperCase()} - ${jsonDiff.toUpperCase()}');
		#end

		PlayState.storyDifficulty = curDifficulty;
		PlayState.SONG = Song.loadFromJson(jsonDiff, selectedSong);
		PlayState.isStoryMode = false;

		trace('CURRENT WEEK: ${WeekData.getWeekFileName()}');
	}

	private function cancelColorTweens():Void
	{
		colorTween.cancel();
	}

	private function checkChartingInput():Void
	{
		if (FlxG.keys.pressed.SHIFT)
		{
			/**
			 * Go to ChartingState (Charting Menu) whenever pressing Shift+Enter.
			 */
			LoadingState.loadAndSwitchState(new ChartingState());
		}
		else
		{
			/**
			 * Go to regular PlayState (Game itself) whenever pressing Enter only.
			 */
			LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	function finishSongInst():Void
	{
		playingSongInst = false;
	}

	public static function destroyFreeplayVocals() {
		if (vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = FunkinUtil.difficulties.length-1;
		if (curDifficulty >= FunkinUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = FunkinUtil.difficulties[curDifficulty];

		grpDifficulties.group.forEach(function(spr) {
			spr.visible = false;
		});
		
		for (diffSprite in grpDifficulties.group.members)
		{
			if (diffSprite == null) continue;
			if (diffSprite.difficultyId == FunkinUtil.difficulties[curDifficulty].toLowerCase())
			{
				if (change != 0)
				{
					diffSprite.visible = true;
					diffSprite.offset.y += 5;
					diffSprite.alpha = 0.5;
					new FlxTimer().start(1 / 24, function(swag) {
						diffSprite.alpha = 1;
						diffSprite.updateHitbox();
					});
				}
				else
				{
					diffSprite.visible = true;
				}
			}
		}

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getAccuracy(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		positionHighscore();
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;
			
		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getAccuracy(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
			iconArray[i].animation.curAnim.curFrame = 0;
		}

		iconArray[curSelected].alpha = 1;
		
		switch(songs[curSelected].songName.toLowerCase())
		{
			case 'tutorial':
				iconArray[curSelected].animation.curAnim.curFrame = 1;
			default:
				iconArray[curSelected].animation.curAnim.curFrame = 2;
		}

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
		
		Paths.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;

		FunkinUtil.difficulties = FunkinUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				FunkinUtil.difficulties = diffs;
			}
		}
		
		if (FunkinUtil.difficulties.contains(FunkinUtil.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, FunkinUtil.defaultDifficulties.indexOf(FunkinUtil.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}

		var newPos:Int = FunkinUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
	}

	private function positionHighscore():Void
	{
		scoreText.x = FlxG.width - scoreText.width - 10;
		scoreText.y = scoreBG.y + 15;
		shittyText.x = FlxG.width - shittyText.width - 10;
		shittyText.y = scoreBG.y + 5;
		scoreBG.scale.x = FlxG.width - scoreText.x + 15;
		scoreBG.scale.y = FlxG.height - scoreText.height + 2;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
	}
}

class DifficultySprite extends FlxSprite
{
	public var difficultyId:String;

	public function new(diffId:String)
	{
		super();
		difficultyId = diffId;
		this.loadGraphic(Paths.image('freeplay/freeplay${diffId}'));
	}
}

class DifficultySelector extends FlxSprite
{
	var controls:Controls;
	var whiteShader:PureColor;

	public function new(x:Float, y:Float, flipped:Bool, controls:Controls):Void
	{
		super(x, y);

		this.controls = controls;

		frames = Paths.getSparrowAtlas('freeplay/freeplaySelector');
		animation.addByPrefix('shine', "arrow pointer loop", 24);
		animation.play('shine');

		whiteShader = new PureColor(FlxColor.WHITE);

		shader = whiteShader;

		flipX = flipped;
	}

	override function update(elapsed:Float):Void
	{
		if (flipX && controls.UI_RIGHT_P && !FlxG.keys.pressed.CONTROL) moveShitDown();
		if (!flipX && controls.UI_LEFT_P && !FlxG.keys.pressed.CONTROL) moveShitDown();

		super.update(elapsed);
	}

	private function moveShitDown():Void
	{
		offset.y -= 5;

		whiteShader.colorSet = true;

		scale.x = scale.y = 0.5;

		new FlxTimer().start(2 / 24, function(tmr) {
			scale.x = scale.y = 1;
			whiteShader.colorSet = false;
			updateHitbox();
		});
	}
}
