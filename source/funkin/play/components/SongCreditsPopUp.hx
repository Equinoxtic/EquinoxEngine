package funkin.play.components;

import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import funkin.tweens.GlobalTweenClass;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import funkin.util.EaseUtil;

class SongCreditsPopUp extends FlxTypedSpriteGroup<FlxSprite>
{
	private var songNameText:FunkinText;
	private var creditsText:FunkinText;

	private var m_playedAnimation:Bool = false;
	public var animationTimer:FlxTimer;

	private var background:FunkinSprite;

	public function new(songName:String, songArtist:String, songCharter:String):Void
	{
		super(FlxG.width * 2, 0);

		background = new FunkinSprite(0, 0, true);
		background.loadSprite('ui/play/SongCreditsBG');
		background.scale.set(0.925, 0.925);
		background.screenCenter(Y);
		background.alpha = 0.65;
		add(background);

		songNameText = new FunkinText(0, background.y * 1.4, FlxG.width, songName.toUpperCase(), 38, CENTER, true, 3.5);
		songNameText.forceDefaultFont = true;
		add(songNameText);

		creditsText = new FunkinText(0, songNameText.y * 1.2, FlxG.width, 'By: ${songArtist} • Charted by: ${songCharter}', 21, CENTER, false);
		creditsText.forceDefaultFont = true;
		creditsText.defaultFont = 'vcr.ttf';
		add(creditsText);

		var iconOffsetX:Float = 425;
		var iconOffsetY:Float = 10;

		var _icon:StaticIcon = new StaticIcon(PlayState.instance.dad.healthIcon, false);
		_icon.screenCenter();
		_icon.x -= iconOffsetX;
		_icon.y += iconOffsetY;
		add(_icon);

		var _icon:StaticIcon = new StaticIcon(PlayState.instance.boyfriend.healthIcon, true);
		_icon.screenCenter();
		_icon.x += iconOffsetX;
		_icon.y += iconOffsetY;
		add(_icon);
	}

	public function playAnimation():Void
	{
		if (m_playedAnimation) {
			return;
		}

		GlobalTweenClass.tween(this, { x: 0 }, Constants.CREDITS_HUD_DURATION, {
			ease: EaseUtil.getFlxEaseByString('cubeOut')
		});

		animationTimer = new FlxTimer().start(Constants.CREDITS_HUD_DELAY, function(_:FlxTimer) {
			 GlobalTweenClass.tween(this, { x: FlxG.width * -2 }, Constants.CREDITS_HUD_DURATION, {
				ease:EaseUtil.getFlxEaseByString('circInOut'),
				onComplete: function(_:FlxTween) {
					this.destroy();
				}
			});
		}, 1);

		m_playedAnimation = true;
	}
}
