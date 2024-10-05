package funkin.play.components;

import funkin.tweens.GlobalTweenClass;
import flixel.ui.FlxBar;
import flixel.text.FlxText.FlxTextAlign;
import flixel.util.FlxAxes;
import funkin.play.song.Song.SwagSong;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class TimeBar extends FlxTypedSpriteGroup<FlxSprite>
{
	private var _timeBar:FlxBar;
	private var _timeBarBG:AttachedSprite;
	private var _timeText:FunkinText;

	private var value:Float = 1.0;

	private var percent:Float = 0.0;

	public function new(X:Float, Y:Float):Void
	{
		super(X, Y);

		_timeBarBG = new AttachedSprite('solariumUI/timeBar');
		_timeBarBG.screenCenter(FlxAxes.X);
		_timeBarBG.setGraphicSize(Std.int(_timeBarBG.width * 1.15), Std.int(_timeBarBG.height * 1.75));
		_timeBarBG.y += 10;
		_timeBarBG.x -= 4;

		_timeBar = new FlxBar(0, 0, FlxBarFillDirection.LEFT_TO_RIGHT, Std.int(_timeBarBG.width * 1), Std.int(_timeBarBG.height * 1), this,
		'value', 0, 1);
		_timeBar.setGraphicSize(Std.int(_timeBar.width * 1.1), Std.int(_timeBar.height * 0.8));
		_timeBar.createGradientBar([0xFF252525, 0xFF353535, 0xFF555555], [0xFFFFFFFF, 0xFFDDDDDD, 0xFFAAAAAA], 1, 180);
		_timeBar.setPosition(_timeBarBG.x * 1, _timeBarBG.y - 1);
		_timeBar.numDivisions = 1000;

		_timeText = new FunkinText(0, 0, FlxG.width, "", 20, CENTER, true);
		_timeText.y = _timeBar.y - 1.5;
		_timeText.borderSize = 3.0;

		if (GlobalSettings.DOWNSCROLL) {
			_timeText.y = FlxG.height - 44;
		}

		add(_timeBar);
		add(_timeBarBG);
		add(_timeText);

		this.alpha = 0.0;

		this.visible = (GlobalSettings.TIME_BAR_DISPLAY != 'Disabled' && !GlobalSettings.HIDE_HUD);
	}

	public function updateTimeBarText(displayMode:String, currentTime:Int, totalLength:Int):Void
	{
		@:privateAccess
		if (PlayState.instance.updateTime)
		{
			/**
			 * Create a map for each TimeBar type with a specific key.
			 * [ 'Default', 'Time Elapsed / Song Length', 'Song Name', 'Default Percentage', 'Percentage Only' ]
			 */
			var formatMap:Map<String, String> = [
				'Default'                    => '${_getSongInfo(PlayState.SONG)} (${_getSongTime(currentTime, totalLength)})',
				'Time Elapsed / Song Length' => '- ${_getSongTime(currentTime, totalLength)} -',
				'Song Name'                  => '[ ${_getSongInfo(PlayState.SONG)} ]',
				'Default Percentage'         => '${_getSongInfo(PlayState.SONG)} (${_getSongPercentageRounded(currentTime, totalLength)})',
				'Percentage Only'            => '${_getSongPercentageRounded(currentTime, totalLength)}',
			];

			var defaultKey:String = 'Default';

			if (formatMap.exists(displayMode)) {
				defaultKey = displayMode;
				if (defaultKey == 'Percentage Only') {
					_timeText.x = (_timeBar.x * 1.0) + 78.5;
					_timeText.alignment = FlxTextAlign.LEFT;
				}
			}

			_timeText.text = formatMap.get(defaultKey);
		}
	}

	public function showTimeBar():Void
	{
		GlobalTweenClass.tween(this, { alpha: 1.0 }, 0.75 / PlayState.instance.playbackRate, {
			ease: EaseUtil.getFlxEaseByString('circOut')
		});
	}

	public function adjustTime(amount:Float):Void
	{
		value = amount;
		percent = (value * 100);
	}

	private function _getSongInfo(currentSong:SwagSong):String
	{
		return '${currentSong.song} - ${FunkinUtil.difficultyString().toUpperCase()}';
	}

	private function _getSongTime(currentTime:Int, totalLength:Int):String
	{
		return '${TimeUtil.getSongTime(currentTime)} / ${TimeUtil.getSongTime(totalLength)}';
	}

	private function _getSongPercentageRounded(currentTime:Int, totalLength:Int):String
	{
		@:privateAccess
		return '${Math.round(
			(TimeUtil._calculateTime(currentTime) / TimeUtil._calculateTime(totalLength)) * 100
		)}%';
	}
}
