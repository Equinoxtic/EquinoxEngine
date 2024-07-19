package funkin.play.notes;

import flixel.FlxSprite;

using StringTools;

class HoldCover extends FlxSprite
{
	public var colorSwap:ColorSwap = null;
	private var idleAnim:String;
	private var textureLoaded:String = null;

	public var colorArray:Array<String> = ["Purple", "Blue", "Green", "Red"];

	private static final DEFAULT_FRAMERATE:Int = 24;

	public function new(X:Float = 0, Y:Float = 0, ?note:Int = 0):Void
	{
		super(X, Y);

		var skin:String = 'holdCover';
		loadAnimations(skin);

		colorSwap = new ColorSwap();
		shader = colorSwap.shader;

		setup(X, Y, note);

		antialiasing = GlobalSettings.SPRITE_ANTIALIASING;
		visible = (!PlayState.isPixelStage);
	}

	public function setup(X:Float, Y:Float, note:Int = 0, texture:String = null, hueColor:Float = 0, satColor:Float = 0, brtColor:Float = 0):Void
	{
		setCoverPosition(X, Y);

		scrollFactor.set(1.0, 1.0);

		alpha = 1.0;

		texture = 'holdCover';

		if (textureLoaded != texture)
		{
			loadAnimations(texture, note);
		}

		colorSwap.hue = hueColor;
		colorSwap.saturation = satColor;
		colorSwap.brightness = brtColor;

		offset.set(10, 10);

		playStartAnimation();

		if (animation.curAnim != null) {
			animation.curAnim.frameRate = DEFAULT_FRAMERATE;
		}
	}

	public function setCoverPosition(x:Float, y:Float):Void
	{
		setPosition(x - Note.swagWidth * 0.9, y - Note.swagWidth * 0.8);
	}

	public function playStartAnimation():Void
	{
		this.animation.play('start', true);
	}

	public function endHoldAnimation(isSuccess:Bool = false):Void
	{
		if (isSuccess) {
			animation.play('end', true);
		} else {
			kill();
		}
	}

	private function loadAnimations(skin:String, noteData:Int = 0):Void
	{
		final colorName:String = colorArray[noteData % 4];

		this.frames = Paths.getSparrowAtlas(skin + colorName);

		animation.addByPrefix('start', 'holdCoverStart$colorName', DEFAULT_FRAMERATE, false);
		animation.addByPrefix('hold', 'holdCover$colorName', DEFAULT_FRAMERATE, true);
		animation.addByPrefix('end', 'holdCoverEnd$colorName', DEFAULT_FRAMERATE, false);

		animation.finishCallback = function(name:String):Void {
			if (animation.curAnim.name == 'start') {
				animation.play('hold', true);
			} else if (animation.curAnim.name == 'end') {
				kill();
			}
		}
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
