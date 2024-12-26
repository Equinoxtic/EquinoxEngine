package funkin.play;

import flixel.tweens.FlxTween;
import funkin.tweens.GlobalTweenClass;
import flixel.FlxSprite;
import flixel.FlxBasic;
import funkin.util.EaseUtil;

class Countdown extends flixel.group.FlxSpriteGroup
{
	private var isHidden:Bool = false;
	public var soundSuffix:String = '';

	var countdownReady:FunkinSprite;
	var countdownSet:FunkinSprite;
	var countdownGo:FunkinSprite;

	public function new(X:Float, Y:Float):Void
	{
		super(X, Y);
	}

	public function startCountdown(counter:Int, ?hidden:Bool = false, ?introAssets:Null<Array<String>>):Void
	{
		this.isHidden = hidden;

		switch(counter)
		{
			case 0:
				playSound('intro3', soundSuffix);
			case 1:
				createSprite('ready', introAssets);
				playSound('intro2', soundSuffix);
			case 2:
				createSprite('set', introAssets);
				playSound('intro1', soundSuffix);
			case 3:
				createSprite('go', introAssets);
				playSound('introGo', soundSuffix);
			case 4:
				PlayState.instance.canPause = true;
				PlayState.instance.finishedCountdown = true;
		}
	}

	private function createSprite(key:String, ?introAssets:Null<Array<String>>):Void
	{
		if (isHidden) {
			return;
		}

		switch(key.toLowerCase())
		{
			case 'ready':
				countdownReady = new FunkinSprite(0, 0, false);
				countdownReady.loadSprite(introAssets[0]);
				countdownReady.screenCenter();
				add(countdownReady);

				startTween(countdownReady);

			case 'set':
				countdownSet = new FunkinSprite(0, 0, false);
				countdownSet.loadSprite(introAssets[1]);
				countdownSet.screenCenter();
				add(countdownSet);

				startTween(countdownSet);

			case 'go':
				countdownGo = new FunkinSprite(0, 0, false);
				countdownGo.loadSprite(introAssets[2]);
				countdownGo.screenCenter();
				add(countdownGo);

				startTween(countdownGo);
		}
	}

	private function playSound(sound:String, ?suffix:String = ''):Void
	{
		if (isHidden) {
			return;
		}

		FlxG.sound.play(Paths.sound('${sound}${suffix}'));
	}

	private function startTween(sprite:Null<FlxSprite>):Void
	{
		if (sprite == null || !sprite.alive) {
			return;
		}

		var wSpriteSize:Float = sprite.scale.x;
		var hSpriteSize:Float = sprite.scale.y;

		var defultScale:Float = 1.0;
		var scaleAdd:Float = 0.2;
		if (PlayState.isPixelStage) {
			defultScale = 1.0 * PlayState.daPixelZoom;
			scaleAdd = 0.45;
		}

		if (!PlayState.isPixelStage) {
			sprite.scale.set(wSpriteSize + scaleAdd, hSpriteSize + scaleAdd);
		} else {
			sprite.scale.set((wSpriteSize * PlayState.daPixelZoom) + scaleAdd, (hSpriteSize * PlayState.daPixelZoom) + scaleAdd);
		}

		GlobalTweenClass.tween(sprite, {alpha: 0.0}, Conductor.crochet / 1000, {startDelay: 0.085 / PlayState.instance.playbackRate, ease: EaseUtil.getFlxEaseByString('cubeOut')});

		GlobalTweenClass.tween(sprite, {
				"scale.x": defultScale, "scale.y": defultScale
			},
			Conductor.crochet / 1000, {
				startDelay: 0.035 / PlayState.instance.playbackRate,
				ease: EaseUtil.getFlxEaseByString('cubeOut'),
				onComplete: function(_:FlxTween):Void {
					remove(sprite);
					sprite.destroy();
				}
			}
		);
	}
}
