package;

import flixel.system.FlxSound;
import flixel.addons.transition.FlxTransitionableState as Transition;
import flixel.FlxSprite as Sprite;
import flixel.text.FlxText as Text;
import flixel.tweens.FlxTween as Tween;
import flixel.tweens.FlxEase.FlxEaseUtil as EaseUtil;
import flixel.util.FlxTimer as Timer;
import flixel.system.FlxSound as Sound;

import util.Constants;

#if sys
import openfl.system.System as Application;
#end

class DebugInfoState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var debugText:flixel.text.FlxText;
	var confirmedSound:Sound;

	override function create():Void
	{
		confirmedSound = new Sound().loadEmbedded(Paths.sound('confirmMenuFancy'));
		FlxG.sound.list.add(confirmedSound);

		var bg:Sprite = new Sprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), 0xFF000000);
		add(bg);

		debugText = new Text(0, 200, flixel.FlxG.width, '', 28);
		// debugText.scrollFactor.set();
		debugText.screenCenter(X);
		debugText.setFormat(
			Paths.font('phantommuff.ttf'),
			28,
			0xFFFFFFFF,
			CENTER
		);
		add(debugText);

		debugText.text = 'You are now testing a DEBUG build\n
		of ${Constants.MAIN_APPLICATION_TITLE}!\n
		Everthing may be unstable and buggy, here be dragons, player!\n
		Current Branch: ${Constants.GIT_BRANCH} @ ${Constants.GIT_HASH}\n\n
		Press ESC to Exit the Application | Press Enter to Continue\n\nEnjoy! :)
		';

		debugText.scale.set(7.5, 7.5);
		debugText.alpha = 0;

		Tween.tween(
			debugText,
			{
				alpha: 1,
				'scale.x': 1.0,
				'scale.y': 1.0
			},
			1.0,
			{
				ease: EaseUtil.getFlxEaseByString('cubeOut')
			}
		);

		super.create();
	}

	override function update(elapsed:Float):Void
	{
		if (!leftState)
		{
			if (controls.ACCEPT || controls.BACK)
			{
				leftState = true;
				flixel.FlxG.save.data.leftDebugWarningState = leftState;
				Transition.skipNextTransIn = true;
				Transition.skipNextTransOut = true;
				if (controls.ACCEPT)
				{
					if (!confirmedSound.playing) {
						confirmedSound.volume = 1;
						confirmedSound.play();
					}
					Tween.tween(
						debugText,
						{
							'scale.x': 10.5,
							'scale.y': 10.5,
							alpha: 0
						},
						0.6,
						{
							ease: EaseUtil.getFlxEaseByString('cubeOut'),
							onComplete: function(_:Tween):Void {
								confirmedSound.fadeOut(4.8, 0, null);
								new Timer().start(5, function(t:Timer) {
									debugText.destroy();
									MusicBeatState.switchState(new TitleState());
								});
							}
						}
					);
					if (ClientPrefs.flashing) {
						flixel.FlxG.camera.flash(0xFFFFFFFF, 2.75, null, true);
					}
				}
				else
				{
					#if sys
					Application.exit(0);
					#end
				}
			}
		}
		super.update(elapsed);
	}
}
