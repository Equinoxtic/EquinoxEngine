package;

import flixel.system.FlxSoundGroup;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import openfl.media.Sound;
import lime.media.AudioBuffer;
import haxe.io.Bytes;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flash.geom.Rectangle;
import flixel.math.FlxMath;
import openfl.utils.ByteArray;
import CoolUtil as FunkinUtil;

using StringTools;

class FunkinSound
{
	public static var voicesPlayer:FlxSound;
	public static var voicesOpponent:FlxSound;

	/**
	 * Loads the song, by default it should be 'PlayState.SONG.song' on PlayState.hx.
	 */
	public static function loadSong(songToLoad:String):Void
	{
		if (songToLoad != null && songToLoad != '')
		{
			loadVocals(songToLoad, PlayState.SONG.needsVoices);

			FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(songToLoad)));
		}
	}

	/**
	 * Loads the song's vocals.
	 */
	public static function loadVocals(songToLoad:String, needsVoices:Bool):Void
	{
		if (songToLoad != null)
		{
			if (needsVoices) {
				voicesPlayer = new FlxSound().loadEmbedded(Paths.playerVoices(songToLoad, 0), false);
				voicesOpponent = new FlxSound().loadEmbedded(Paths.playerVoices(songToLoad, 1), false);
			} else {
				voicesPlayer = new FlxSound();
				voicesOpponent = new FlxSound();
			}

			FlxG.sound.list.add(voicesPlayer);
			FlxG.sound.list.add(voicesOpponent);
			
			if (voicesPlayer != null)
				voicesPlayer.onComplete = destroyVoicesOf.bind('player');

			if (voicesOpponent != null)
				voicesOpponent.onComplete = destroyVoicesOf.bind('opponent');
		}
	}

	/**
	 * Pauses the song and the vocals.
	 */
	public static function pauseSong():Void
	{
		pauseInst();
		pauseVoices();
	}

	/**
	 * Stops the song and the vocals.
	 */
	public static function stopSong():Void
	{
		stopInst();
		stopVoices();
	}

	/**
	 * Resumes the song and resyncs it.
	 */
	public static function resumeSong():Void
	{
		resyncSound();
	}

	/**
	 * Plays the vocals.
	 */
	public static function playVoices():Void
	{
		if (voicesPlayer != null)
			voicesPlayer.play();
		if (voicesOpponent != null)
			voicesOpponent.play();
	}

	/**
	 * Pauses the vocals.
	 */
	public static function pauseVoices():Void
	{
		if (voicesPlayer != null)
			voicesPlayer.pause();
		if (voicesOpponent != null)
			voicesOpponent.pause();
	}

	/**
	 * Stops the vocals.
	 */
	public static function stopVoices():Void
	{
		if (voicesPlayer != null)
			voicesPlayer.stop();
		if (voicesOpponent != null)
			voicesOpponent.stop();
	}

	/**
	 * Mutes and optionally pauses the vocals.
	 */
	 public static function muteVoices(?shouldPause:Bool = true):Void
	{
		setVoicesVolume(0);
		if (shouldPause) pauseVoices();
	}

	public static function playInst():Void
	{
		if (FlxG.sound.music != null) {
			FlxG.sound.music.play();
		}
	}

	public static function pauseInst():Void
	{
		if (FlxG.sound.music != null) {
			FlxG.sound.music.pause();
		}
	}


	public static function stopInst():Void
	{
		if (FlxG.sound.music != null) {
			FlxG.sound.music.stop();
		}
	}

	public static function setVoicesVolume(value:Null<Float>):Void
	{
		if (value != null && value >= 0.0) {
			if (voicesPlayer != null)
				voicesPlayer.volume = value;
			if (voicesOpponent != null)
				voicesOpponent.volume = value;
		}
	}

	public static function setVoicesPitch(value:Null<Float>):Void
	{
		if (value != null && value > 0.0) {
			if (voicesPlayer != null)
				voicesPlayer.pitch = value;
			if (voicesOpponent != null)
				voicesOpponent.pitch = value;
		}
	}

	public static function setVoicesTime(value:Null<Float>):Void
	{
		if (value != null && value >= 0.0) {
			if (voicesPlayer != null)
				voicesPlayer.time = value;
			if (voicesOpponent != null)
				voicesOpponent.time = value;
		}
	}

	public static function setInstVolume(value:Null<Float>):Void
	{
		if (value != null && value >= 0.0) {
			if (FlxG.sound.music != null) {
				FlxG.sound.music.volume = value;
			}
		}
	}

	/**
	 * Sets the pitch for the instrumental.
	 */
	 public static function setInstPitch(value:Null<Float>):Void
	{
		if (value != null && value > 0.0) {
			if (FlxG.sound.music != null)
				FlxG.sound.music.pitch = value;
		}
	}

	public static function setInstTime(value:Null<Float>):Void
	{
		if (value != null && value >= 0.0) {
			if (FlxG.sound.music != null) {
				FlxG.sound.music.time = value;
			}
		}
	}

	/**
	 * Starts the song along with the instrumental.
	 */
	public static function start():Void
	{
		// Play the instrumental.
		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		setInstPitch(PlayState.instance.playbackRate);
		FlxG.sound.music.onComplete = PlayState.instance.finishSong.bind();

		// Play the vocals.
		playVoices();

		trace(
			'\n\n\t- [ Funkin\' Sound System ] : Song Loaded! -'
			+ '\n\t    * SONG: ${PlayState.SONG.song} - ${FunkinUtil.difficultyString().toUpperCase()}'
			+ '\n\t    * BF VOCALS:  ${checkPlaying(voicesPlayer)}'
			+ '\n\t    * DAD VOCALS: ${checkPlaying(voicesOpponent)}'
			+ '\n\t    * INSTRUMENTAL: ${checkPlaying(FlxG.sound.music)}'
			+ '\n'
		);
	}

	/**
	 * Sets the volume for the vocals and the instrumental depending on the target.
	 */
	 public static function setVolume(value:Null<Float>, ?target:String = 'bf'):Void
	{
		if (value != null && value >= 0)
		{
			if (target.toLowerCase() == 'bf' || target.toLowerCase() == 'player')
			{
				if (voicesPlayer != null)
					voicesPlayer.volume = value;
			}
			else if (target.toLowerCase() == 'dad' || target.toLowerCase() == 'opponent')
			{
				if (voicesOpponent != null) {
					voicesOpponent.volume = value;
				} else {
					if (voicesPlayer != null) {
						voicesPlayer.volume = value;
					}
				}
			}
			else if (target.toLowerCase() == 'instrumental')
			{
				FlxG.sound.music.volume = value;
			}
		}
	}

	/**
	 * Sets and adjusts the time for the song.
	 */
	public static function setSoundTime(time:Float):Void
	{
		pauseSong();

		setInstTime(time);
		setInstPitch(PlayState.instance.playbackRate);
		playInst();

		if (Conductor.songPosition <= voicesPlayer.length || Conductor.songPosition <= voicesOpponent.length) {
			adjustRateVoices(time, PlayState.instance.playbackRate);
		}

		playVoices();
	}

	/**
	 * A wrapper function that is used for resyncing the song.
	 */
	public static function resyncSound():Void
	{
		pauseSong();

		playInst();
		setInstPitch(PlayState.instance.playbackRate);
		setConductorSongPos(FlxG.sound.music.time);

		if (Conductor.songPosition <= voicesPlayer.length || Conductor.songPosition <= voicesOpponent.length) {
			adjustRateVoices(Conductor.songPosition, PlayState.instance.playbackRate);
		}

		playVoices();
	}

	/**
	 * Uses 'resyncSound()' to properly synchronize along the song's stepHits.
	 */
	public static function updateSongSync():Void
	{
		if (voicesOpponent != null)
		{
			if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > (20 * PlayState.instance.playbackRate)
				|| (PlayState.SONG.needsVoices && Math.abs(voicesPlayer.time - (Conductor.songPosition - Conductor.offset)) > (20 * PlayState.instance.playbackRate))
				|| (PlayState.SONG.needsVoices && Math.abs(voicesOpponent.time - (Conductor.songPosition - Conductor.offset)) > (20 * PlayState.instance.playbackRate)))
			{
				FunkinSound.resyncSound();
			}
		}
		else
		{
			if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > (20 * PlayState.instance.playbackRate)
				|| (PlayState.SONG.needsVoices && Math.abs(voicesPlayer.time - (Conductor.songPosition - Conductor.offset)) > (20 * PlayState.instance.playbackRate)))
			{
				FunkinSound.resyncSound();
			}
		}
	}

	/**
	 * Adjusts the rate for the voices.
	 */
	public static function adjustRateVoices(time:Float, value:Float):Void
	{
		if (time >= 0.0 && value >= 0.0)
		{
			if (voicesPlayer != null) {
				setVoicesTime(time);
				voicesPlayer.pitch = value;
			}
			if (voicesOpponent != null) {
				setVoicesTime(time);
				voicesOpponent.pitch = value;
			}
		}
	}

	/**
	 * Sets the conductors song position according to the value.
	 */
	public static function setConductorSongPos(value:Float):Void
	{
		Conductor.songPosition = value;
	}

	/**
	 * Gets the ERECT mode prefix. (Returns '-erect')
	 */
	public static function erectModePrefix():String
	{
		if (PlayState.storyDifficulty > 2) {
			return '-erect';
		}
		return '';
	}

	/**
	 * Checks whether the song is playing. Returns 'Playing!' if true, otherwise, return 'No Input.'
	 */
	private static function checkPlaying(song:Null<FlxSound>):String
	{
		if (song != null) {
			return ((song.playing) ? 'Playing!' : 'No Input.');
		}
		return '';
	}

	/**
	 * WARNING: Destroys a song's vocal track. May cause a "Null Object Reference" error when not handled properly.
	 */
	private static function destroyVoicesOf(playerId:Null<String>):Void
	{
		if (playerId != null && playerId != '')
		{
			switch (playerId)
			{
				case 'player' | 'bf' | '0':
					if (voicesPlayer != null) {
						voicesPlayer.destroy();
					}
				case 'opponent' | 'dad' | '1':
					if (voicesOpponent != null) {
						voicesOpponent.destroy();
					}
				default: trace('Invalid player ID: ${playerId}');
			}
		}
	}
}

@:access(flixel.system.FlxSound._sound)
@:access(openfl.media.Sound.__buffer)

class FunkinSoundChartEditor
{
	public static var vocalsPlayer:FlxSound;
	public static var vocalsOpponent:FlxSound;

	private static var wavData:Array<Array<Array<Float>>> = [[[0], [0]], [[0], [0]]];
	private static var waveformPrinted:Bool = true;

	public static var quantizeShit:Float;

	/**
	 * Loads the song's vocals.
	 */
	public static function loadSongVocals(song:Null<String>):Void
	{
		if (song != null && song != '')
		{
			var filePlayer:Dynamic = Paths.playerVoices(song, 0);
			var fileOpponent:Dynamic = Paths.playerVoices(song, 1);
			var loadedString:String = '\n\n\t- [ Funkin\' Sound System @ Chart Editor ] : Song VOCALS Loaded! -';

			loadedString += '\n\t    * SONG: ${song.toUpperCase()} - ${FunkinUtil.difficultyString().toUpperCase()}';

			vocalsPlayer = new FlxSound();
			if (checkSoundExists(filePlayer))
			{
				vocalsPlayer = new FlxSound().loadEmbedded(filePlayer);
				loadedString += '\n\t    * BF VOCALS LOADED!';
			}
			FlxG.sound.list.add(vocalsPlayer);

			vocalsOpponent = new FlxSound();
			if (checkSoundExists(fileOpponent))
			{
				vocalsOpponent = new FlxSound().loadEmbedded(fileOpponent);
				loadedString += '\n\t    * DAD VOCALS LOADED!';
			}
			FlxG.sound.list.add(vocalsOpponent);

			trace('${loadedString}\n');
		}
	}

	/**
	 * Plays the song's vocals.
	 */
	public static function playSongVocals():Void
	{
		if (vocalsPlayer != null)
			vocalsPlayer.play();
		if (vocalsOpponent != null)
			vocalsOpponent.play();
	}

	/**
	 * Pauses the song's vocals.
	 */
	public static function pauseSongVocals():Void
	{
		if (vocalsPlayer != null)
			vocalsPlayer.pause();
		if (vocalsOpponent != null)
			vocalsOpponent.pause();
	}

	/**
	 * Stops the song's vocals.
	 */
	public static function stopSongVocals():Void
	{
		if (vocalsPlayer != null)
			vocalsPlayer.stop();
		if (vocalsOpponent != null)
			vocalsOpponent.stop();
	}

	/**
	 * Sets both of the player and opponent's vocals volume.
	 */
	public static function setVocalsVolume(value:Null<Float>):Void
	{
		if (value != null && value >= 0)
		{
			if (vocalsPlayer != null)
				vocalsPlayer.volume = value;
			if (vocalsOpponent != null)
				vocalsOpponent.volume = value;
		}
	}

	/**
	 * Sets the volume for either the player or opponent.
	 */
	public static function vocalsTrackSetVolume(value:Null<Float>, ?track:String = 'player'):Void
	{
		if (value != null && value >= 0)
		{
			switch (track.toLowerCase())
			{
				case 'player' | 'bf' | '0':
					vocalsPlayer.volume = value;
				case 'opponent' | 'dad' | '1':
					vocalsOpponent.volume = value;
				default: vocalsPlayer.volume = value;
			}
		}
	}

	/**
	 * Sets the current time of the vocals.
	 */
	public static function setVocalsTime(value:Null<Float>):Void
	{
		if (value != null && value >= 0)
		{
			if (vocalsPlayer != null) 
				vocalsPlayer.time = value;
			if (vocalsOpponent != null)
				vocalsOpponent.time = value;
		}
	}

	/**
	 * Sets the pitch of the vocals.
	 */
	public static function setVocalsPitch(value:Null<Float>):Void
	{
		if (value != null && value >= 0)
		{
			if (vocalsPlayer != null)
				vocalsPlayer.pitch = value;
			if (vocalsOpponent != null)
				vocalsOpponent.pitch = value;
		}
	}

	/**
	 * Pauses and resyncs the vocals to the instrumental.
	 */
	public static function pauseAndResyncVocals(offset:Float):Void
	{
		pauseSongVocals();
		setVocalsTime(offset);
	}

	/**
	 * Pauses and resets each vocals' current time.
	 */
	public static function resetSongVocals():Void
	{
		pauseAndResyncVocals(0);
	}

	/**
	 * Loads the song's instrumental.
	 */
	public static function loadSongInst(song:String):Void
	{
		if (song != null && song != '')
		{
			FlxG.sound.playMusic(Paths.inst(song), 1.0);
			trace(
				'\n\n\t- [ Funkin\' Sound System @ Chart Editor ] : Song INSTRUMENTAL Loaded! -'
				+ '\n\t    * SONG: ${song.toUpperCase()} - ${FunkinUtil.difficultyString().toUpperCase()}\n'
			);
		}
	}

	/**
	 * Plays the song's instrumental.
	 */
	public static function playSongInst():Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.play();
		}
	}

	/**
	 * Pauses the song's instrumental.
	 */
	public static function pauseSongInst():Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.pause();
			
		}
	}

	/**
	 * Stops the song's instrumental.
	 */
	public static function stopSongInst():Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
		}
	}

	/**
	 * Sets the volume for the instrumental.
	 */
	public static function setInstVolume(value:Null<Float>):Void
	{
		if (value != null && value >= 0)
		{
			FlxG.sound.music.volume = value;
		}
	}

	/**
	 * Sets and adjusts the current time for the instrumental.
	 */
	public static function setInstTime(value:Null<Float>):Void
	{
		if (value != null && value >= 0)
		{
			FlxG.sound.music.time = value;
		}
	}

	/**
	 * Sets the instrumental's pitch.
	 */
	public static function setInstPitch(value:Null<Float>):Void
	{
		if (value != null && value >= 0)
		{
			FlxG.sound.music.pitch = value;
		}
	}

	/**
	 * Pauses the instrumental and resyncs it with the offset.
	 */
	public static function pauseAndResyncInst(offset:Float):Void
	{
		pauseSongInst();
		setInstTime(offset);
	}

	/**
	 * Pauses and resets the time of the instrumental.
	 */
	public static function resetSongInst():Void
	{
		pauseAndResyncInst(0);
	}

	/**
	 * Play's the song.
	 */
	public static function playSong(vocalsCondition:Bool):Void
	{
		if (!FlxG.sound.music.playing)
		{
			playSongInst();
			if (vocalsCondition) {
				playSongVocals();
			}
		}
		else
		{
			pauseSongInst();
		}
	}

	/**
	 * Stops the song.
	 */
	public static function stopSong(?vocalsCondition:Bool = true):Void
	{
		stopSongInst();
		stopSongVocals();
	}

	/**
	 * Sets the song's pitch.
	 */
	public static function setSongPitch(value:Null<Float>):Void
	{
		if (value != null && value >= 0) {
			setInstPitch(value);
			setVocalsPitch(value);
		}
	}

	public static function updateWaveforms(valueST:Null<Float>, valueET:Null<Float>, gridSize:Null<Int>, gridHeight:Null<Float>):Void
	{
		#if desktop
		if(!FlxG.save.data.chart_waveformInst
			&& !FlxG.save.data.chart_waveformVoicesPlayer
			&& !FlxG.save.data.chart_waveformVoicesOpponent) {
			return;
		}

		wavData[0][0] = [];
		wavData[0][1] = [];
		wavData[1][0] = [];
		wavData[1][1] = [];

		var st = valueST;
		var et = valueET;

		if (FlxG.save.data.chart_waveformInst)
		{
			createInstWaveform(st, et, gridHeight);
		}

		if (FlxG.save.data.chart_waveformVoicesPlayer)
		{
			createVocalWaveform(st, et, true, gridHeight);
		}

		if (FlxG.save.data.chart_waveformVoicesOpponent)
		{
			createVocalWaveform(st, et, false, gridHeight);
		}

		// drawWaveformData(gridSize);
		#end
	}

	public static function createVocalWaveform(st:Null<Float>, et:Null<Float>, isPlayer:Bool, gridHeight:Null<Float>):Void
	{
		#if desktop
		if (isPlayer)
		{
			var sound:FlxSound = vocalsPlayer;
			if (sound._sound != null && sound._sound.__buffer != null)
			{
				var bytes:Bytes = sound._sound.__buffer.data.toBytes();
				createSoundWaveform(sound, bytes, st, et, gridHeight);
			}
		}
		else
		{
			var sound:FlxSound = vocalsOpponent;
			if (sound._sound != null && sound._sound.__buffer != null)
			{
				var bytes:Bytes = sound._sound.__buffer.data.toBytes();
				createSoundWaveform(sound, bytes, st, et, gridHeight);
			}
		}
		#end
	}

	public static function createInstWaveform(st:Null<Float>, et:Null<Float>, gridHeight:Null<Float>):Void
	{
		#if desktop
		var sound:FlxSound = FlxG.sound.music;
		if (sound._sound != null && sound._sound.__buffer != null)
		{
			var bytes:Bytes = sound._sound.__buffer.data.toBytes();
			createSoundWaveform(sound, bytes, st, et, gridHeight);
		}
		#end
	}

	public static function createSoundWaveform(sound:Null<FlxSound>, bytes:Bytes, startTime:Null<Float>, endTime:Null<Float>, gridHeight:Null<Float>):Void
	{
		#if desktop
		if (sound != null && sound.alive)
		{
			if (sound._sound != null && sound._sound.__buffer != null)
			{
				wavData = createWaveformData(
					sound._sound.__buffer,
					bytes,
					startTime,
					endTime,
					1,
					wavData,
					Std.int(gridHeight)
				);
			}
		}
		#end
	}

	public static function createWaveformData(buffer:AudioBuffer, bytes:Bytes, time:Float, endTime:Float, multiply:Float = 1, ?array:Array<Array<Array<Float>>>, ?steps:Float):Array<Array<Array<Float>>>
	{
		#if (lime_cffi && !macro)
		if (buffer == null || buffer.data == null) return [[[0], [0]], [[0], [0]]];

		var khz:Float = (buffer.sampleRate / 1000);
		var channels:Int = buffer.channels;

		var index:Int = Std.int(time * khz);

		var samples:Float = ((endTime - time) * khz);

		if (steps == null) steps = 1280;

		var samplesPerRow:Float = samples / steps;
		var samplesPerRowI:Int = Std.int(samplesPerRow);

		var gotIndex:Int = 0;

		var lmin:Float = 0;
		var lmax:Float = 0;

		var rmin:Float = 0;
		var rmax:Float = 0;

		var rows:Float = 0;

		var simpleSample:Bool = true;//samples > 17200;
		var v1:Bool = false;

		if (array == null) array = [[[0], [0]], [[0], [0]]];

		while (index < (bytes.length - 1))
		{
			if (index >= 0)
			{
				var byte:Int = bytes.getUInt16(index * channels * 2);

				if (byte > 65535 / 2) byte -= 65535;

				var sample:Float = (byte / 65535);

				if (sample > 0) {
					if (sample > lmax) lmax = sample;
				} else if (sample < 0) {
					if (sample < lmin) lmin = sample;
				}

				if (channels >= 2) {
					byte = bytes.getUInt16((index * channels * 2) + 2);

					if (byte > 65535 / 2) byte -= 65535;

					sample = (byte / 65535);

					if (sample > 0) {
						if (sample > rmax) rmax = sample;
					} else if (sample < 0) {
						if (sample < rmin) rmin = sample;
					}
				}
			}

			v1 = samplesPerRowI > 0 ? (index % samplesPerRowI == 0) : false;
			while (simpleSample ? v1 : rows >= samplesPerRow)
			{
				v1 = false;
				rows -= samplesPerRow;

				gotIndex++;

				var lRMin:Float = Math.abs(lmin) * multiply;
				var lRMax:Float = lmax * multiply;

				var rRMin:Float = Math.abs(rmin) * multiply;
				var rRMax:Float = rmax * multiply;

				if (gotIndex > array[0][0].length) {
					array[0][0].push(lRMin);
				} else {
					array[0][0][gotIndex - 1] = array[0][0][gotIndex - 1] + lRMin;
				}

				if (gotIndex > array[0][1].length) {
					array[0][1].push(lRMax);
				} else {
					array[0][1][gotIndex - 1] = array[0][1][gotIndex - 1] + lRMax;
				}

				if (channels >= 2)
				{
					if (gotIndex > array[1][0].length) {
						array[1][0].push(rRMin);
					}
					else {
						array[1][0][gotIndex - 1] = array[1][0][gotIndex - 1] + rRMin;
					}

					if (gotIndex > array[1][1].length) {
						array[1][1].push(rRMax);
					} else {
						array[1][1][gotIndex - 1] = array[1][1][gotIndex - 1] + rRMax;
					}
				}
				else
				{
					if (gotIndex > array[1][0].length) {
						array[1][0].push(lRMin);
					} else {
						array[1][0][gotIndex - 1] = array[1][0][gotIndex - 1] + lRMin;
					}

					if (gotIndex > array[1][1].length) {
						array[1][1].push(lRMax);
					} else {
						array[1][1][gotIndex - 1] = array[1][1][gotIndex - 1] + lRMax;
					}
				}

				lmin = 0;
				lmax = 0;

				rmin = 0;
				rmax = 0;
			}

			index++;
			rows++;

			if (gotIndex > steps)
				break;
		}

		return array;

		#else

		return [[[0], [0]], [[0], [0]]];

		#end
	}

	public static function drawWaveformData(gridSize:Null<Int>, tWaveformSprite:Null<FlxSprite>):Void
	{
		#if desktop
		if (tWaveformSprite == null) return;

		var gSize:Int = Std.int(gridSize * 8);
		var hSize:Int = Std.int(gSize / 2);

		var lmin:Float = 0;
		var lmax:Float = 0;

		var rmin:Float = 0;
		var rmax:Float = 0;

		var size:Float = 1;

		var leftLength:Int = (
			wavData[0][0].length > wavData[0][1].length ? wavData[0][0].length : wavData[0][1].length
		);

		var rightLength:Int = (
			wavData[1][0].length > wavData[1][1].length ? wavData[1][0].length : wavData[1][1].length
		);

		var length:Int = leftLength > rightLength ? leftLength : rightLength;

		var index:Int;

		for (i in 0...length)
		{
			index = i;

			lmin = FlxMath.bound(((index < wavData[0][0].length && index >= 0) ? wavData[0][0][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;
			lmax = FlxMath.bound(((index < wavData[0][1].length && index >= 0) ? wavData[0][1][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;
			rmin = FlxMath.bound(((index < wavData[1][0].length && index >= 0) ? wavData[1][0][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;
			rmax = FlxMath.bound(((index < wavData[1][1].length && index >= 0) ? wavData[1][1][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;

			tWaveformSprite.pixels.fillRect(new Rectangle(hSize - (lmin + rmin), i * size, (lmin + rmin) + (lmax + rmax), size), FlxColor.BLUE);
		}

		waveformPrinted = true;
		#end
	}

	public static function updateWaveformSprite(tWaveformSprite:Null<FlxSprite>, gridSize:Null<Float>, gridHeight:Null<Float>, gridWidth:Null<Float>):Void
	{
		#if desktop
		if (tWaveformSprite != null)
		{
			if (waveformPrinted) {
				tWaveformSprite.makeGraphic(Std.int(gridSize * 8), Std.int(gridHeight), 0x00FFFFFF);
				tWaveformSprite.pixels.fillRect(new Rectangle(0, 0, gridWidth, gridHeight), 0x00FFFFFF);
			}
			waveformPrinted = false;
		}
		#end
	}

	public static function enableVolumeControlKeys():Void
	{
		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
	}

	public static function disableVolumeControlKeys():Void
	{
		FlxG.sound.muteKeys = [];
		FlxG.sound.volumeDownKeys = [];
		FlxG.sound.volumeUpKeys = [];
	}

	public static function adjustMusicTime(increment:Null<Float>):Void
	{
		if (FlxG.keys.pressed.W) {
			FlxG.sound.music.time -= increment;
		} else {
			FlxG.sound.music.time += increment;
		}
	}

	public static function quantizeInst(beat:Null<Float>, snap:Null<Float>, increase:Null<Float>, ?useKeys:Bool = false):Void
	{
		if (beat != null && snap != null && increase != null)
		{
			var fuck:Float = 0.0;

			if (!useKeys)
			{
				if (FlxG.mouse.wheel > 0) {
					fuck = FunkinUtil.quantize(beat, snap) - increase;
				} else {
					fuck = FunkinUtil.quantize(beat, snap) + increase;
				}
			}
			else
			{
				if (FlxG.keys.pressed.UP) {
					fuck = FunkinUtil.quantize(beat, snap) - increase;
				} else {
					fuck = FunkinUtil.quantize(beat, snap) + increase;
				}
			}

			FunkinSoundChartEditor.setInstTime(Conductor.beatToSeconds(fuck));
		}
	}

	public static function tweenedQuantizeInst(beat:Null<Float>, snap:Null<Float>, increase:Null<Float>, ?tweenEase:Null<Float->Float>):Void
	{
		if (beat != null && snap != null && increase != null)
		{
			var fuck:Float = 0.0;

			if (FlxG.keys.pressed.UP) {
				fuck = FunkinUtil.quantize(beat, snap) - increase;
				quantizeShit = Conductor.beatToSeconds(fuck);
			} else {
				fuck = FunkinUtil.quantize(beat, snap) + increase;
				quantizeShit = Conductor.beatToSeconds(fuck);
			}

			FlxTween.tween(
				FlxG.sound.music,
				{time: quantizeShit},
				0.1,
				{ease: tweenEase}
			);
		}
	}

	private static function checkSoundExists(file:Null<Dynamic>):Bool
	{
		if (file != null) {
			return (Std.isOfType(file, Sound) || OpenFlAssets.exists(file));
		}
		return false;
	}
}
