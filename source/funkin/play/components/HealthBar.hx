package funkin.play.components;

import flixel.math.FlxMath;
import funkin.play.character.Character;
import funkin.play.character.Boyfriend;
import flixel.util.FlxColor;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.ui.FlxBar;

class HealthBar extends FlxTypedSpriteGroup<FlxSprite>
{
	private var healthBar:FlxBar;
	private var healthBarBG:AttachedSprite;

	private var value:Float = Constants.HEALTH_START;

	public var percent:Float = 1.0;

	public function new(X:Float, Y:Float):Void
	{
		super(X, Y);

		healthBarBG = new AttachedSprite('solariumUI/healthBar');
		healthBarBG.setGraphicSize(Std.int(healthBarBG.width * 1), Std.int(healthBarBG.height * 1.2));
		healthBarBG.visible = !GlobalSettings.HIDE_HUD;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -26;

		healthBar = new FlxBar(0, 0, FlxBarFillDirection.RIGHT_TO_LEFT, Std.int(healthBarBG.width * 1), Std.int(healthBarBG.height * 1.2), this, 'value', Constants.HEALTH_MIN, Constants.HEALTH_MAX);
		healthBar.setPosition(healthBarBG.x * 1, healthBarBG.y - 1);
		healthBar.setGraphicSize(Std.int(healthBarBG.width * 0.95), Std.int(healthBarBG.height * 0.35));
		healthBar.numDivisions = 1000;
		healthBar.visible = !GlobalSettings.HIDE_HUD;
		healthBar.alpha = GlobalSettings.HEALTH_BAR_TRANSPARENCY;

		add(healthBar);
		add(healthBarBG);
	}

	public function reloadColors():Void
	{
		_setHealthBarColor(_getHealthArrayIndexOf('dad'), _getHealthArrayIndexOf('bf'));
	}

	public function updateHealth(amount:Float = 1.0):Void
	{
		// Just in case it tries to increase, we stop the void function.
		if (value > Constants.HEALTH_MAX) {
			value = Constants.HEALTH_MAX;
			return;
		} else if (value < Constants.HEALTH_MIN) {
			value = Constants.HEALTH_MIN;
			return;
		}

		value = amount;
		percent = (amount / Constants.HEALTH_MAX) * 100;
	}

	private function _setHealthBarColor(left:FlxColor, right:FlxColor):Void
	{
		healthBar.createFilledBar(left, right);
		healthBar.updateBar();
	}

	private function _getHealthArrayIndexOf(?character:String = 'bf'):FlxColor
	{
		if (character != null)
		{
			final boyfriend:Boyfriend = PlayState.instance.boyfriend;
			final dad:Character = PlayState.instance.dad;

			switch(character)
			{
				/**
				 * Using Flx.fromRGBFloat to determine more precisee values of color, dividing each index of healthColorArray by 255 to achieve the same colors whilst avoiding conflicting results
				 */
				case 'bf' | 'boyfriend' | 'player':
					return FlxColor.fromRGBFloat(
						boyfriend.healthColorArray[0] / 255,
						boyfriend.healthColorArray[1] / 255,
						boyfriend.healthColorArray[2] / 255,
						boyfriend.healthColorArray[3] / 255
					);

				case 'dad' | 'opponent' | 'enemy':
					return FlxColor.fromRGBFloat(
						dad.healthColorArray[0] / 255,
						dad.healthColorArray[1] / 255,
						dad.healthColorArray[2] / 255,
						dad.healthColorArray[3] / 255
					);
			}
		}

		return FlxColor.fromRGBFloat(1.0, 1.0, 1.0, 1.0);
	}
}
