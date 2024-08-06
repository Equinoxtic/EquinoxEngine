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
		_timeBar.x = _timeBarBG.x * 1;
		_timeBar.y = _timeBarBG.y - 1;
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
	}

	public function updateTimeBarText(currentTime:Int, totalLength:Int):Void
	{
		@:privateAccess
		if (PlayState.instance.updateTime)
		{
			switch(GlobalSettings.TIME_BAR_DISPLAY)
			{
				case 'Default':
					_timeText.text = '${_getSongInfo(PlayState.SONG)} (${_getSongTime(currentTime, totalLength)})';

				case 'Time Elapsed / Song Length':
					_timeText.text = '- ${_getSongTime(currentTime, totalLength)} -';

				case 'Song Name':
					_timeText.text = '[ ${_getSongInfo(PlayState.SONG)} ]';

				case 'Default Percentage':
					_timeText.text = '${_getSongInfo(PlayState.SONG)} (${_getSongPercentageRounded(currentTime, totalLength)})';

				case 'Percentage Only':
					_timeText.text = '${_getSongPercentageRounded(currentTime, totalLength)}';
					_timeText.x = (this.x * 1.0) + 78.5;
					_timeText.alignment = FlxTextAlign.LEFT;

				default:
					_timeText.text = '${_getSongInfo(PlayState.SONG)} (${_getSongTime(currentTime, totalLength)})';
			}

			trace(_timeText.text);
		}
	}

	public function showTimeBar():Void
	{
		GlobalTweenClass.tween(this, {alpha: 1.0}, 0.65, {ease: EaseUtil.getFlxEaseByString('circOut')});
	}

	public function adjustTime(amount:Float):Void
	{
		value = amount;
		percent = (value * 100);
	}

	override function update(elapsed:Float):Void
	{
		this.visible = (GlobalSettings.TIME_BAR_DISPLAY != 'Disabled' && !GlobalSettings.HIDE_HUD);

		super.update(elapsed);
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
