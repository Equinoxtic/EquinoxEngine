package funkin.menus.title;

import flixel.text.FlxText.FlxTextBorderStyle as BorderStyle;
import flixel.text.FlxText.FlxTextAlign as TextAlignment;
import flixel.system.FlxSound;
import flixel.addons.transition.FlxTransitionableState as Transition;
import flixel.FlxSprite as Sprite;
import flixel.text.FlxText as Text;
import flixel.tweens.FlxTween as Tween;
import flixel.tweens.FlxEase.FlxEaseUtil as EaseUtil;
import flixel.util.FlxTimer as Timer;
import flixel.system.FlxSound as Sound;

import funkin.util.Constants;

#if sys
import openfl.system.System as Application;
#end

class DebugInfoState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var debugText:flixel.text.FlxText;
	var confirmedSound:Sound;
	var exitSound:Sound;

	var watermarkSprite:Sprite;
	var bg:Sprite;

	var allowInteraction:Bool = false;

	override function create():Void
	{	
		confirmedSound = new Sound().loadEmbedded(Paths.sound('confirmMenuFancy'));
		FlxG.sound.list.add(confirmedSound);

		exitSound = new Sound().loadEmbedded(Paths.sound('cancelMenu'));
		FlxG.sound.list.add(exitSound);

		bg= new Sprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), 0xFF000000);
		add(bg);

		watermarkSprite = new Sprite().loadGraphic(Paths.image('ui/watermark'));
		watermarkSprite.screenCenter(X);
		watermarkSprite.setGraphicSize(Std.int(watermarkSprite.width * 0.5), Std.int(watermarkSprite.height * 0.5));
		watermarkSprite.antialiasing = true;
		add(watermarkSprite);

		debugText = new Text(0, 250, flixel.FlxG.width, '', 28);
		debugText.screenCenter(X);
		debugText.setFormat(
			Paths.font('phantommuff.ttf'),
			28,
			0xFFFFFFFF,
			TextAlignment.CENTER,
			BorderStyle.OUTLINE,
			0xFF000000
		);
		debugText.borderSize = 1.5;
		add(debugText);

		debugText.text = 'You are now testing a DEBUG build\n
		of ${Constants.MAIN_APPLICATION_TITLE}!\n
		Everything may be unstable and buggy, here be dragons, player!\n
		Current Branch: ${Constants.GIT_BRANCH} @ ${Constants.GIT_HASH}\n\n
		Press ESC to Exit the Application | Press Enter to Continue\n\nEnjoy! :)
		';

		watermarkSprite.y = debugText.y - 270;

		super.create();

		FlxG.camera.zoom = 3.5;
		FlxG.camera.alpha = 0.000001;

		Tween.tween(
			FlxG.camera,
			{
				alpha: 1.0, zoom: 1.0
			},
			1.0,
			{
				ease: EaseUtil.getFlxEaseByString('cubeOut'),
				onComplete: function(t:Tween) {
					allowInteraction = true;
				}
			}
		);
	}

	override function update(elapsed:Float):Void
	{
		if (!leftState)
		{
			if (allowInteraction)
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
							FlxG.camera,
							{
								zoom: 30
							},
							0.8,
							{
								ease: EaseUtil.getFlxEaseByString('cubeOut'),
								onComplete: function(_:Tween):Void {
									confirmedSound.fadeOut(4.8, 0, null);
									new Timer().start(5.0, function(t:Timer) {
										watermarkSprite.destroy();
										debugText.destroy();
										FlxG.camera.zoom = 1.0;
										MusicBeatState.switchState(new TitleState());
									});
								}
							}
						);
						if (Preferences.flashing) {
							bg.color = 0xFFFFFFFF;
							Tween.color(bg, 2.75, 0xFFFFFFFF, 0xFF000000, {ease: EaseUtil.getFlxEaseByString('cubeOut')});
							flixel.FlxG.camera.flash(0xFFFFFFFF, 2.75, null, true);
						}
					}
					else
					{
						if (!exitSound.playing) {
							exitSound.play();
						}
						#if sys
						Tween.tween(
							FlxG.camera,
							{
								zoom: 0.9, alpha: 0.000001
							},
							1.5,
							{
								ease: EaseUtil.getFlxEaseByString('cubeOut'),
								onComplete: function(_:Tween):Void {
									new Timer().start(1.0, function(t:Timer) {
										Application.exit(0);
									});
								}
							}
						);
						#end
					}
				}
			}
		}
		super.update(elapsed);
	}
}
