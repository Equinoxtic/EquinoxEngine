package funkin.graphics.effects;

import flixel.tweens.FlxTween;
import funkin.tweens.GlobalTweenClass;

class FlashEffect extends FunkinSprite
{
	private var _flashed:Bool = false;

	public function new(strength:Float, duration:Float, delay:Float, ?ease:Null<String> = 'linear'):Void
	{
		super(0, 0, false);
		makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), 0xFFFFFFFF);
		screenCenter();
		alpha = strength;
		_playFlash(strength, duration, delay, ease);
	}

	private function _playFlash(strength:Float, duration:Float, delay:Float, ?easing:Null<String> = 'linear'):Void
	{
		if (_flashed) {
			return;
		}

		alpha = strength;

		GlobalTweenClass.tween(this, { alpha: 0.0 }, duration, {
			ease: EaseUtil.getFlxEaseByString(easing),
			startDelay: delay,
			onComplete: function(_:FlxTween):Void {
				this.destroy();
			}
		});
	}
}
