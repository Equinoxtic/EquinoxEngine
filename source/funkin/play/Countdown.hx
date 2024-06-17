package funkin.play;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase.FlxEaseUtil;
import funkin.tweens.GlobalTweenClass;
import flixel.FlxSprite;
import flixel.FlxBasic;

class Countdown extends flixel.group.FlxSpriteGroup
{
	private var instance:FlxBasic;

	private var antialias:Bool = true;
	private var isHidden:Bool = false;
	public var soundSuffix:String = '';

	var countdownReady:FlxSprite;
	var countdownSet:FlxSprite;
	var countdownGo:FlxSprite;

	public function new(instance:FlxBasic, X:Float, Y:Float, ?antialias:Bool = true, ?introAssets:Null<Array<String>>):Void
	{
		super(X, Y);

		if (instance == null) {
			instance = this;
		}

		this.instance = instance;
		this.antialias = antialias;
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
				countdownReady = new FlxSprite().loadGraphic(Paths.image(introAssets[0]));
				countdownReady.scrollFactor.set();
				countdownReady.screenCenter();
				countdownReady.antialiasing = antialias;

				add(countdownReady);

				startTween(countdownReady);

			case 'set':
				countdownSet = new FlxSprite().loadGraphic(Paths.image(introAssets[1]));
				countdownSet.scrollFactor.set();
				countdownSet.screenCenter();
				countdownSet.antialiasing = antialias;

				add(countdownSet);

				startTween(countdownSet);

			case 'go':
				countdownGo = new FlxSprite().loadGraphic(Paths.image(introAssets[2]));
				countdownGo.scrollFactor.set();
				countdownGo.screenCenter();
				countdownGo.antialiasing = antialias;

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

		if (!PlayState.isPixelStage) {
			scale.set(wSpriteSize + 0.2, hSpriteSize + 0.2);
		} else {
			scale.set((wSpriteSize * PlayState.daPixelZoom) + 0.2, (hSpriteSize * PlayState.daPixelZoom) + 0.2);
		}

		GlobalTweenClass.tween(sprite, {alpha: 0.0}, Conductor.crochet / 1000, {startDelay: 0.085 / PlayState.instance.playbackRate, ease: FlxEaseUtil.getFlxEaseByString('cubeOut')});

		GlobalTweenClass.tween(sprite, {
				"scale.x": 1.0, "scale.y": 1.0
			},
			Conductor.crochet / 1000, {
				startDelay: 0.035 / PlayState.instance.playbackRate,
				ease: FlxEaseUtil.getFlxEaseByString('cubeOut'),
				onComplete: function(_:FlxTween):Void {
					remove(sprite);
					sprite.destroy();
				}
			}
		);
	}
}