package funkin.play.components;

import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase.FlxEaseUtil;
import funkin.tweens.GlobalTweenClass;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class SongCreditsPopUp extends FlxTypedSpriteGroup<FlxSprite>
{
	private var _instance:FlxBasic;

	private var _bg:FlxSprite;
	private var _songNameTxt:FunkinText;
	private var _creditsTxt:FunkinText;

	private var _playedAnimation:Bool = false;

	public function new(instance:Null<FlxBasic>, songName:String, songArtist:String, songCharter:String):Void
	{
		super(FlxG.width * 2, 0);

		if (instance == null) {
			instance = this;
		}

		this._instance = instance;

		_bg = new FlxSprite().loadGraphic(Paths.image('ui/play/SongCreditsBG'));
		_bg.scale.set(0.925, 0.925);
		_bg.screenCenter(Y);
		add(_bg);
		_songNameTxt = new FunkinText(0, _bg.y * 1.4, FlxG.width, songName.toUpperCase(), 38, CENTER, true, 3.5);
		_songNameTxt.forceDefaultFont = true;
		add(_songNameTxt);

		_creditsTxt = new FunkinText(0, _songNameTxt.y * 1.2, FlxG.width, 'By: ${songArtist} • Charted by: ${songCharter}', 21, CENTER, false);
		_creditsTxt.forceDefaultFont = true;
		_creditsTxt.defaultFont = 'vcr.ttf';
		add(_creditsTxt);

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
		if (_playedAnimation) {
			return;
		}

		GlobalTweenClass.tween(this, { x: 0 }, Constants.CREDITS_HUD_DURATION, {
			ease: FlxEaseUtil.getFlxEaseByString('cubeOut')
		});

		new FlxTimer().start(Constants.CREDITS_HUD_DELAY, function(_:FlxTimer) {
			 GlobalTweenClass.tween(this, { x: FlxG.width * -2 }, Constants.CREDITS_HUD_DURATION, {
				ease:FlxEaseUtil.getFlxEaseByString('circInOut'),
				onComplete: function(_:FlxTween) {
					this.destroy();
				}
			});
		}, 1);

		_playedAnimation = true;
	}
}
