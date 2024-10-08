package funkin.play.components;

import funkin.util.animation.CharacterUtil;
import flixel.FlxSprite;
import flixel.math.FlxMath;

using StringTools;

class HealthIcon extends FunkinSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super(0, 0, false);
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char);
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (sprTracker != null) {
			setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
		}
	}

	public function swapOldIcon():Void
	{
		if (isOldIcon = !isOldIcon) {
			changeIcon('bf-old');
		} else {
			changeIcon('bf');
		}
	}

	private var iconOffsets:Array<Float> = [0, 0];

	public function changeIcon(char:String):Void
	{
		if (this.char != char)
		{
			var file:Dynamic = Paths.image(
				CharacterUtil.getPathToIcon(char)
			);

			loadGraphic(file); //Load stupidly first for getting the file size
			loadGraphic(file, true, Constants.ICON_WIDTH, Constants.ICON_HEIGHT); //Then load it fr

			for (i in 0...iconOffsets.length)
				iconOffsets[i] = (width - Constants.ICON_WIDTH) / 2;

			updateHitbox();

			animation.add(char, [0, 1, 2], 0, false, isPlayer);
			animation.play(char);

			this.char = char;

			if (char.endsWith('-pixel')) {
				antialiasing = false;
			} else {
				antialiasing = GlobalSettings.SPRITE_ANTIALIASING;
			}
		}
	}

	/**
	 * Small wrapper function for scaling the icons properly.
	 */
	public function scaleIcon(?value:Float):Void
	{
		if (!(value < 0)) {
			var mult:Float = value;
			updateHitbox();
			scale.set(mult, mult);
		} else {
			return;
		}
	}

	/**
	 * Small wrapper function for properly positioning icons.
	 */
	 public function offsetIcon(?offset:Int, ?playerIcon:Bool):Void
	{
		if (playerIcon) {
			// Offsets for BF / Player.
			x = PlayState.instance.healthBar.x + (PlayState.instance.healthBar.width * (FlxMath.remapToRange(PlayState.instance.healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * scale.x - 150) / 2 - offset;
		} else {
			// Offsets for Dad / Opponent.
			x = PlayState.instance.healthBar.x + (PlayState.instance.healthBar.width * (FlxMath.remapToRange(PlayState.instance.healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * scale.x) / 2 - offset * 2;
		}
	}

	/**
	 * Small wrapper function for updating and evaluating each player's health icon.
	 */
	public function updateHealthIcon():Void
	{
		var curAnimation:Int = 0;
		var health:Float = PlayState.instance.healthBar.percent; // NOTE TO SELF: IT'S HEALTHBAR.PERCENT NOT HEALTHBAR.VALUE !!!

		if (health < Constants.LOSING_PERCENT) // Losing Condition.
		{
			curAnimation = getIconAnimationString(
				((isPlayer) ? 'losing' : 'winning')
			);
		}
		else if (health > Constants.WINNING_PERCENT) // Winning Condition.
		{
			curAnimation = getIconAnimationString(
				((isPlayer) ? 'winning' : 'losing')
			);
		}
		else // Otherwise, stay neutral and funky.
		{
			curAnimation = getIconAnimationString('neutral');
		}

		animation.curAnim.curFrame = curAnimation;
	}

	/**
	 * A function that gets the animation index of an icon from a string ID.
	 */
	private function getIconAnimationString(?id:String = 'neutral'):Int
	{
		if (id != null && id != '')
		{
			switch (id.toLowerCase())
			{
				case 'neutral' | 'normal':
					return 0; // Index of Neutral Icon Animation.
				case 'losing' | 'lose':
					return 1; // Index of Losing Icon Animation.
				case 'winning' | 'win':
					return 2; // Index of Winning Icon Animation.
				default:
					return 0; // Returns to Neutral Animation.
			}
		}

		return 0;
	}

	/**
	 * Small wrapper function to call whenever wanting to bop the icons to the beat.
	 */
	public function bopToBeat(?curBeat:Null<Int>, ?beatMod:Null<Int>, ?scaleMod:Null<Float>, ?beatScaleMod:Null<Float>):Void
	{
		// Every beatMod beats, the scale should be much bigger compared to every beat.
		if ((curBeat % beatMod) == 0) {
			if (beatScaleMod >= 0 && beatScaleMod != null) {
				scale.set(beatScaleMod, beatScaleMod); // Use beatScaleMod when it is greater than 0 and not null.
			}
		} else {
			if (scaleMod >= 0 && scaleMod != null) {
				scale.set(scaleMod, scaleMod); // Use scaleMod when it is greater than 0 and not null.
			}
		}
		updateHitbox();
		// IMPORTANT NOTE: If both scaleMod and beatScaleMod are null or less than 0, then do nothing.
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String {
		return char;
	}
}
