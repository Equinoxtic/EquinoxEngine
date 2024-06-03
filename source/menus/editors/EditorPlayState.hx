package menus.editors;

import FunkinSound.FunkinSoundChartEditor;
import Section.SwagSection;
import Song.SwagSong;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;

using StringTools;

class EditorPlayState extends MusicBeatState
{
	private var strumLine:FlxSprite;
	private var comboGroup:FlxTypedGroup<FlxSprite>;
	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];

	var generatedMusic:Bool = false;
	
	var vocals:FlxSound;
	var vocalsBf:FlxSound;
	var vocalsDad:FlxSound;

	var startOffset:Float = 0;
	var startPos:Float = 0;

	public function new(startPos:Float):Void
	{
		this.startPos = startPos;
		Conductor.songPosition = startPos - startOffset;
		startOffset = Conductor.crochet;
		timerToStart = startOffset;
		super();
	}

	var stepTxt:FlxText;
	var beatTxt:FlxText;
	var sectionTxt:FlxText;
	
	var timerToStart:Float = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	
	private var keysArray:Array<Dynamic>;

	public static var instance:EditorPlayState;

	override function create():Void
	{
		instance = this;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set();
		bg.color = 0xFF252525;
		add(bg);

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];
		
		strumLine = new FlxSprite(ClientPrefs.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if (ClientPrefs.downScroll)
			strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();
		
		comboGroup = new FlxTypedGroup<FlxSprite>();
		add(comboGroup);

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);

		generateStaticArrows(0);
		generateStaticArrows(1);

		FunkinSound.loadVocals(PlayState.SONG.song, PlayState.SONG.needsVoices);

		generateSong(PlayState.SONG.song);

		#if (LUA_ALLOWED && MODS_ALLOWED)
		for (notetype in noteTypeMap.keys())
		{
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if (sys.FileSystem.exists(luaToLoad))
			{
				var lua:EditorLua = new EditorLua(luaToLoad);
				new FlxTimer().start(0.1, function (tmr:FlxTimer) {
					lua.stop();
					lua = null;
				});
			}
		}
		#end
		
		noteTypeMap.clear();
		noteTypeMap = null;
		
		sectionTxt = new FlxText(10, 580, FlxG.width - 20, "Section: 0", 20);
		sectionTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		sectionTxt.scrollFactor.set();
		sectionTxt.borderSize = 1.25;
		add(sectionTxt);
		
		beatTxt = new FlxText(10, sectionTxt.y + 30, FlxG.width - 20, "Beat: 0", 20);
		beatTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		beatTxt.scrollFactor.set();
		beatTxt.borderSize = 1.25;
		add(beatTxt);

		stepTxt = new FlxText(10, beatTxt.y + 30, FlxG.width - 20, "Step: 0", 20);
		stepTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		stepTxt.scrollFactor.set();
		stepTxt.borderSize = 1.25;
		add(stepTxt);

		var tipText:FlxText = new FlxText(10, FlxG.height - 24, 0, 'Press ESC to Go Back to Chart Editor', 16);
		tipText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipText.borderSize = 2;
		tipText.scrollFactor.set();
		add(tipText);

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		super.create();
	}

	function sayGo()
	{
		var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image('go'));
		go.scrollFactor.set();
		go.updateHitbox();
		go.screenCenter();
		go.antialiasing = ClientPrefs.globalAntialiasing;
		add(go);

		FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween)
			{
				go.destroy();
			}
		});
		
		FlxG.sound.play(Paths.sound('introGo'), 0.6);
	}

	var startingSong:Bool = true;
	private function generateSong(dataPath:String):Void
	{
		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0, false);
		FlxG.sound.music.pause();
		FlxG.sound.music.onComplete = endSong;

		FunkinSound.muteVoices(true);

		var songData = PlayState.SONG;
		Conductor.changeBPM(songData.bpm);
		
		notes = new FlxTypedGroup<Note>();
		add(notes);
		
		var noteData:Array<SwagSection>;

		noteData = songData.notes;

		var daBeats:Int = 0;

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				if (songNotes[1] > -1)
				{
					var daStrumTime:Float = songNotes[0];
					if (daStrumTime >= startPos)
					{
						var daNoteData:Int = Std.int(songNotes[1] % 4);

						var gottaHitNote:Bool = section.mustHitSection;

						if (songNotes[1] > 3)
						{
							gottaHitNote = !section.mustHitSection;
						}

						var oldNote:Note;
						if (unspawnNotes.length > 0)
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
						else
							oldNote = null;

						var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
						swagNote.mustPress = gottaHitNote;
						swagNote.sustainLength = songNotes[2];
						swagNote.noteType = songNotes[3];
						if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts
						swagNote.scrollFactor.set();

						unspawnNotes.push(swagNote);

						final susLength:Float = swagNote.sustainLength / (Conductor.stepCrochet / 1.04);
						final ceilSus:Int = Math.ceil(susLength);

						if (ceilSus > 0)
						{
							for (susNote in 0...ceilSus)
							{
								oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

								var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(PlayState.SONG.speed, 2)), daNoteData, oldNote, true);
								sustainNote.mustPress = gottaHitNote;
								sustainNote.noteType = swagNote.noteType;
								sustainNote.scrollFactor.set();
								unspawnNotes.push(sustainNote);

								if (sustainNote.mustPress)
								{
									sustainNote.x += FlxG.width / 2;
								}
								else if (ClientPrefs.middleScroll)
								{
									sustainNote.x += 310;
									if (daNoteData > 1) {
										sustainNote.x += FlxG.width / 2 + 25;
									}
								}
							}
						}

						if (swagNote.mustPress)
						{
							swagNote.x += FlxG.width / 2;
						}
						else if (ClientPrefs.middleScroll)
						{
							swagNote.x += 310;
							if (daNoteData > 1) {
								swagNote.x += FlxG.width / 2 + 25;
							}
						}
						
						if (!noteTypeMap.exists(swagNote.noteType)) {
							noteTypeMap.set(swagNote.noteType, true);
						}
					}
				}
			}
			daBeats += 1;
		}

		unspawnNotes.sort(sortByShit);
		generatedMusic = true;
	}

	function startSong():Void
	{
		startingSong = false;
		FunkinSound.setInstTime(startPos);
		FunkinSound.setVolume(Constants.INSTRUMENTAL_VOLUME, 'instrumental');
		FunkinSound.playInst();
		FunkinSound.setVoicesVolume(1);
		FunkinSound.setVoicesTime(startPos);
		FunkinSound.playVoices();
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function endSong() {
		LoadingState.loadAndSwitchState(new ChartingState());
	}

	public var noteKillOffset:Float = 350;
	public var spawnTime:Float = 2000;
	override function update(elapsed:Float):Void
	{
		if (FlxG.keys.justPressed.ESCAPE)
		{
			FunkinSound.pauseInst();
			
			FunkinSound.pauseVoices();

			LoadingState.loadAndSwitchState(new ChartingState());
		}

		if (startingSong)
		{
			timerToStart -= elapsed * 1000;
			Conductor.songPosition = startPos - timerToStart;
			if (timerToStart < 0) {
				startSong();
			}
		}
		else
		{
			Conductor.songPosition += elapsed * 1000;
		}

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime;
			if (PlayState.SONG.speed < 1) time /= PlayState.SONG.speed;
			if (unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned = true;
				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}
		
		if (generatedMusic)
		{
			var fakeCrochet:Float = (60 / PlayState.SONG.bpm) * 1000;

			notes.forEachAlive(function(daNote:Note)
			{
				var strumX:Float = 0;
				var strumY:Float = 0;
				var strumAlpha:Float = 0;

				if (daNote.mustPress)
				{
					strumX = playerStrums.members[daNote.noteData].x;
					strumY = playerStrums.members[daNote.noteData].y;
					strumAlpha = playerStrums.members[daNote.noteData].alpha;
				}
				else
				{
					strumX = opponentStrums.members[daNote.noteData].x;
					strumY = opponentStrums.members[daNote.noteData].y;
					strumAlpha = opponentStrums.members[daNote.noteData].alpha;
				}

				strumX += daNote.offsetX;
				strumY += daNote.offsetY;
				var center:Float = strumY + Note.swagWidth / 2;

				if (daNote.copyAlpha) {
					daNote.alpha = strumAlpha * daNote.multAlpha;
				}

				if (daNote.copyX) {
					daNote.x = strumX;
				}
				
				if (daNote.copyY)
				{
					if (ClientPrefs.downScroll)
					{
						daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * PlayState.SONG.speed);
						if (daNote.isSustainNote)
						{
							if (daNote.animation.curAnim.name.endsWith('end')) {
								daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * PlayState.SONG.speed + (46 * (PlayState.SONG.speed - 1));
								daNote.y -= 46 * (1 - (fakeCrochet / 600)) * PlayState.SONG.speed;
								if (PlayState.isPixelStage) {
									daNote.y += 8;
								} else {
									daNote.y -= 19;
								}
							}

							daNote.y += (Note.swagWidth / 2) - (60.5 * (PlayState.SONG.speed - 1));
							daNote.y += 27.5 * ((PlayState.SONG.bpm / 100) - 1) * (PlayState.SONG.speed - 1);

							if(daNote.mustPress || !daNote.ignoreNote)
							{
								if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
									&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
								{
									var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
									swagRect.height = (center - daNote.y) / daNote.scale.y;
									swagRect.y = daNote.frameHeight - swagRect.height;
									daNote.clipRect = swagRect;
								}
							}
						}
					}
					else
					{
						daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * PlayState.SONG.speed);

						if (daNote.mustPress || !daNote.ignoreNote)
						{
							if (daNote.isSustainNote
								&& daNote.y + daNote.offset.y * daNote.scale.y <= center
								&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;
								daNote.clipRect = swagRect;
							}
						}
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
				{
					FunkinSound.setVoicesVolume(1);

					var time:Float = 0.15;
					
					if (daNote.isSustainNote && !daNote.animation.curAnim.name.endsWith('end'))
						time += 0.15;
					
					StrumPlayAnim(true, Std.int(Math.abs(daNote.noteData)) % 4, time);
					daNote.hitByOpponent = true;

					if (!daNote.isSustainNote)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				}

				if (Conductor.songPosition > (noteKillOffset / PlayState.SONG.speed) + daNote.strumTime)
				{
					if (daNote.mustPress)
					{
						if (daNote.tooLate || !daNote.wasGoodHit)
						{
							notes.forEachAlive(function(note:Note) {
								if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 10)
								{
									note.kill();
									notes.remove(note, true);
									note.destroy();
								}
							});

							if (!daNote.ignoreNote)
								FunkinSound.setVolume(0, 'bf');
						}
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		keyShit();

		sectionTxt.text = 'Section: ' + curSection;
		beatTxt.text = 'Beat: ' + curBeat;
		stepTxt.text = 'Step: ' + curStep;
		
		super.update(elapsed);
	}
	
	override public function onFocus():Void
	{
		FunkinSound.playVoices();

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		FunkinSound.pauseVoices();

		super.onFocusLost();
	}

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}
	}

	override function stepHit()
	{
		super.stepHit();

		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}
	}

	function resyncVocals():Void
	{
		FunkinSound.pauseVoices();
		FunkinSound.playInst();
		FunkinSound.setConductorSongPos(FlxG.sound.music.time);
		FunkinSound.setVoicesTime(Conductor.songPosition);
		FunkinSound.playVoices();
	}

	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);

		if (key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if (generatedMusic)
			{
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				var pressNotes:Array<Note> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote)
					{
						if(daNote.noteData == key)
							sortedNotesList.push(daNote);
						canMiss = true;
					}
				});

				sortedNotesList.sort(sortHitNotes);

				if (sortedNotesList.length > 0)
				{
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else {
								notesStopped = true;
							}
						}

						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}
				else if (canMiss && ClientPrefs.ghostTapping)
				{
					noteMiss();
				}

				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];

			if (spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
		}
	}

	function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority) {
			return 1;
		} else if (!a.lowPriority && b.lowPriority) {
			return -1;
		}
		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
		}
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if(key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	private function keyShit():Void
	{
		var up = controls.NOTE_UP;
		var right = controls.NOTE_RIGHT;
		var down = controls.NOTE_DOWN;
		var left = controls.NOTE_LEFT;

		var controlHoldArray:Array<Bool> = [left, down, up, right];
		
		if (ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];
			if (controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if (controlArray[i]) {
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
					}
				}
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit 
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
					goodNoteHit(daNote);
				}
			});
		}

		if (ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			switch(note.noteType)
			{
				case 'Hurt Note': //Hurt note
					noteMiss();

					note.wasGoodHit = true;

					FunkinSound.setVolume(0, 'bf');

					if (!note.isSustainNote)
					{
						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
					return;
			}

			if (!note.isSustainNote)
				popUpScore(note);

			playerStrums.forEach(function(spr:StrumNote)
			{
				if (Math.abs(note.noteData) == spr.ID)
					spr.playAnim('confirm', true);
			});

			note.wasGoodHit = true;

			FunkinSound.setVolume(Constants.VOCALS_VOLUME, 'bf');

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	function noteMiss():Void
	{
		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
		FunkinSound.setVolume(0, 'bf');
	}

	var COMBO_X:Float = 400;
	var COMBO_Y:Float = 340;
	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
		FunkinSound.setVolume(Constants.VOCALS_VOLUME, 'bf');
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			var targetAlpha:Float = 1;
			if (player < 1)
			{
				if (ClientPrefs.middleScroll && ClientPrefs.opponentStrumsMiddleScroll) {
					targetAlpha = 0.35;
				}
			}

			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X, strumLine.y, i, player);
			babyArrow.alpha = targetAlpha;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				if(ClientPrefs.middleScroll)
				{
					babyArrow.x += 310;
					if(i > 1) {
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}


	function StrumPlayAnim(isDad:Bool, id:Int, time:Float)
	{
		var spr:StrumNote = null;

		if (isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if (spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}
	
	override function destroy()
	{
		FunkinSound.stopSong();

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		super.destroy();
	}
}
