package funkin.play.notes;

import flixel.math.FlxRect;
import flixel.group.FlxGroup.FlxTypedGroup;

using StringTools;

class NoteHandler
{
	public static function updateStrumlines():Void
	{
		var crochet:Float = (60 / PlayState.SONG.bpm) * 1000;

		PlayState.instance.notes.forEachAlive(function(note:Note) {
			var strums:FlxTypedGroup<StrumNote> = PlayState.instance.playerStrums;
			if (!note.mustPress)
				strums = PlayState.instance.opponentStrums;

			var strumNote:StrumNote = strums.members[note.noteData];

			var STRUM_X:Float		= strumNote.x;
			var STRUM_Y:Float		= strumNote.y;
			var ANGLE:Float			= strumNote.angle;
			var DIRECTION:Float		= strumNote.direction;
			var TRANSPARENCY:Float	= strumNote.alpha;
			var DOWNSCROLL:Bool		= strumNote.downScroll;

			STRUM_X += note.offsetX;
			STRUM_Y += note.offsetY;
			ANGLE += note.offsetAngle;
			TRANSPARENCY *= note.multAlpha;

			var SONG_SPEED:Float = PlayState.instance.songSpeed;

			/**
			 * Downscroll and Upscroll.
			 */
			if (DOWNSCROLL) {
				// DOWNSCROLL
				note.distance = (0.45 * (Conductor.songPosition - note.strumTime) * SONG_SPEED * note.multSpeed);
			} else {
				// UPSCROLL
				note.distance = (-0.45 * (Conductor.songPosition - note.strumTime) * SONG_SPEED * note.multSpeed);
			}

			var ANGLE_DIRECTION = DIRECTION * Math.PI / 180;

			/**
			 * Copying of values.
			 */
			_copyAngleOfNote(note, DIRECTION, ANGLE);
			_copyAlphaOfNote(note, TRANSPARENCY);
			_copyXPositionOfNote(note, STRUM_X, ANGLE_DIRECTION);
			_copyYPositionOfNote(note, STRUM_Y, ANGLE_DIRECTION, DOWNSCROLL, crochet);

			/**
			 * Processing how notes are hit and which notes are hit by each player/opponent.
			 */
			_processNote(note);

			_adjustRectOfNote(note, strumNote, STRUM_Y, DOWNSCROLL);

			_killNote(note);
		});
	}

	private static function _copyAngleOfNote(note:Note, ?strumDirection:Float = 0.0, ?strumAngle:Float = 0.0):Void
	{
		if (note.copyAngle) {
			note.angle = strumDirection - 90 + strumAngle;
		}
	}

	private static function _copyAlphaOfNote(note:Note, ?value:Float = 1.0):Void
	{
		if (note.copyAlpha) {
			note.alpha = value;
		}
	}

	private static function _copyXPositionOfNote(note:Note, ?strumX:Float = 0.0, ?angleDir:Float = 0.0):Void
	{
		if (note.copyX) {
			note.x = strumX + Math.cos(angleDir) * note.distance;
		}
	}

	private static function _copyYPositionOfNote(note:Note, ?strumY:Float = 0.0, ?angleDir:Float = 0.0, ?downscroll:Bool = false, ?crochet:Float = 0.0):Void
	{
		var SONG_SPEED = PlayState.instance.songSpeed;

		if (note.copyY)
		{
			note.y = strumY + Math.sin(angleDir) * note.distance;

			if (downscroll && note.isSustainNote)
			{
				if (note.animation.curAnim.name.endsWith('end'))
				{
					note.y += 10.5 * (crochet / 400) * 1.5 * SONG_SPEED + (46 * (SONG_SPEED - 1));
					note.y -= 46 * (1 - (crochet / 600)) * SONG_SPEED;

					if (PlayState.isPixelStage)
						note.y += 8 + (6 - note.originalHeightForCalcs) * PlayState.daPixelZoom;
					else
						note.y -= 19;

					note.y += (Note.swagWidth / 2) - (60.5 * (SONG_SPEED - 1));
					note.y += 27.5 * ((PlayState.SONG.bpm / 100) - 1) * (SONG_SPEED - 1);
				}
			}
		}
	}

	private static function _processNote(note:Note):Void
	{
		@:privateAccess
		if (!note.mustPress && note.wasGoodHit && !note.hitByOpponent && !note.ignoreNote) {
			PlayState.instance.opponentNoteHit(note);
		}

		@:privateAccess
		if (!note.blockHit && note.mustPress && PlayState.instance.cpuControlled && note.canBeHit) {
			if (note.isSustainNote) {
				if(note.canBeHit) {
					PlayState.instance.goodNoteHit(note);
				}
			} else if(note.strumTime <= Conductor.songPosition || note.isSustainNote) {
				PlayState.instance.goodNoteHit(note);
			}
		}
	}

	private static function _adjustRectOfNote(note:Note, strumNote:StrumNote, ?strumYPos:Float = 0.0, ?isDownscroll:Bool = false):Void
	{
		var center:Float = strumYPos + Note.swagWidth / 2;
		if (strumNote.sustainReduce && note.isSustainNote && (note.mustPress || !note.ignoreNote) && (!note.mustPress || (note.wasGoodHit || (note.prevNote.wasGoodHit && !note.canBeHit))))
		{
			if (isDownscroll)
			{
				if (note.y - note.offset.y * note.scale.y + note.height >= center)
				{
					var swagRect = new FlxRect(0, 0, note.frameWidth, note.frameHeight);
					swagRect.height = (center - note.y) / note.scale.y;
					swagRect.y = note.frameHeight - swagRect.height;

					note.clipRect = swagRect;
				}
			}
			else
			{
				if (note.y + note.offset.y * note.scale.y <= center)
				{
					var swagRect = new FlxRect(0, 0, note.width / note.scale.x, note.height / note.scale.y);
					swagRect.y = (center - note.y) / note.scale.y;
					swagRect.height -= swagRect.y;

					note.clipRect = swagRect;
				}
			}
		}
	}

	private static function _killNote(note:Note):Void
	{
		if (Conductor.songPosition > PlayState.instance.noteKillOffset + note.strumTime)
		{
			if (note.mustPress && !PlayState.instance.cpuControlled &&!note.ignoreNote && !PlayState.instance.endingSong && (note.tooLate || !note.wasGoodHit)) {
				@:privateAccess
				PlayState.instance.noteMiss(note);
			}

			note.active = false;
			note.visible = false;

			note.kill();
			PlayState.instance.notes.remove(note, true);
			note.destroy();
		}
	}
}
