package funkin.ui;

import flixel.addons.transition.FlxTransitionSprite;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxState;
import flixel.FlxCamera;
import funkin.play.song.Conductor.BPMChangeEvent;
import funkin.input.Controls;

class MusicBeatState extends FlxUIState
{
	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	private var controls(get, never):Controls;

	public static var camBeat:FlxCamera;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create():Void
	{
		trace('Current State: ${FlxG.state}');

		camBeat = FlxG.camera;

		super.create();

		if(!FlxTransitionableState.skipNextTransOut) {
			openSubState(new CustomFadeTransition(0.7, true));
		}

		FlxTransitionableState.skipNextTransOut = false;
	}

	override function update(elapsed:Float):Void
	{
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if(curStep > 0)
				stepHit();

			if (PlayState.SONG != null)
			{
				if (oldStep < curStep) {
					updateSection();
				} else {
					rollbackSection();
				}
			}
		}


		if (FlxG.save.data != null) {
			FlxG.save.data.fullscreen = FlxG.fullscreen;
		}

		super.update(elapsed);
	}

	private function updateSection():Void
	{
		if (stepsToDo < 1) {
			stepsToDo = Math.round(getBeatsOnSection() * 4);
		}

		while(curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	private function rollbackSection():Void
	{
		if (curStep < 0) {
			return;
		}

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;

		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if(stepsToDo > curStep) break;

				curSection++;
			}
		}

		if (curSection > lastSection) {
			sectionHit();
		}
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep/4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - GlobalSettings.NOTE_OFFSET) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public static function switchState(state:Null<FlxState> = null):Void
	{
		if (state == null) {
			state = FlxG.state;
		}

		if (state == FlxG.state) {
			resetState();
			return;
		}

		if (FlxTransitionableState.skipNextTransIn) {
			FlxG.switchState(state);
		} else {
			_startTransition(state);
		}

		FlxTransitionableState.skipNextTransIn = false;
	}

	public static function resetState():Void
	{
		if (FlxTransitionableState.skipNextTransIn) {
			FlxG.resetState();
		} else {
			_startTransition();
		}

		FlxTransitionableState.skipNextTransIn = false;
	}

	private static function _startTransition(state:Null<FlxState> = null):Void
	{
		if (state == null) {
			state = FlxG.state;
		}
		FlxG.state.openSubState(new CustomFadeTransition(0.6, false));
		if (state == FlxG.state) {
			CustomFadeTransition.finishCallback = function():Void {
				FlxG.resetState();
			}
		} else {
			CustomFadeTransition.finishCallback = function():Void {
				FlxG.switchState(state);
			}
		}
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0) {
			beatHit();
		}
	}

	public function beatHit():Void {}

	public function sectionHit():Void {}

	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;

		if (PlayState.SONG != null && PlayState.SONG.notes[curSection] != null) {
			val = PlayState.SONG.notes[curSection].sectionBeats;
		}

		return val == null ? 4 : val;
	}
}
