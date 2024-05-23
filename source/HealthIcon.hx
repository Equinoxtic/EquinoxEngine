package;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	public function swapOldIcon():Void
	{
		if(isOldIcon = !isOldIcon) changeIcon('bf-old');
		else changeIcon('bf');
	}

	private var iconOffsets:Array<Float> = [0, 0];

	public function changeIcon(char:String):Void
	{
		if(this.char != char) {
			var name:String = 'icons/' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; //Older versions of psych engine's support
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon
			var file:Dynamic = Paths.image(name);

			loadGraphic(file); //Load stupidly first for getting the file size
			loadGraphic(file, true, 150, 150); //Then load it fr
			iconOffsets[0] = (width - 150) / 2;
			iconOffsets[1] = (width - 150) / 2;
			updateHitbox();

			animation.add(char, [0, 1, 2], 0, false, isPlayer);
			animation.play(char);
			this.char = char;

			antialiasing = ClientPrefs.globalAntialiasing;
			if(char.endsWith('-pixel')) {
				antialiasing = false;
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
			x = PlayState.instance.healthBar.x + (PlayState.instance.healthBar.width * (FlxMath.remapToRange(PlayState.instance.healthBar.value, 0, 2, 100, 0) * 0.01)) + (150 * scale.x - 150) / 2 - offset;
		} else {
			// Offsets for Dad / Opponent.
			x = PlayState.instance.healthBar.x + (PlayState.instance.healthBar.width * (FlxMath.remapToRange(PlayState.instance.healthBar.value, 0, 2, 100, 0) * 0.01)) - (150 * scale.x) / 2 - offset * 2;
		}
	}

	/**
	 * Small wrapper function for updating and evaluating each player's health icon.
	 */
	public function updateHealthIcon():Void
	{
		var curAnimation:Int = 0;
		var health:Float = PlayState.instance.healthBar.percent; // NOTE TO SELF: IT'S HEALTHBAR.PERCENT NOT HEALTHBAR.VALUE !!!

		if (health < 20) // Losing Condition.
		{
			curAnimation = getIconAnimationString(
				((isPlayer) ? 'losing' : 'winning')
			);
		}
		else if (health > 80) // Winning Condition.
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
	public static function bopIconsToBeat(?healthIconGroup:Null<FlxTypedGroup<HealthIcon>>, ?curBeat:Null<Int>, ?beatMod:Null<Int>, ?scaleMod:Null<Float>, ?beatScaleMod:Null<Float>):Void
	{
		if (healthIconGroup != null)
		{
			healthIconGroup.forEach(function(spr)
			{
				// Every beatMod beats, the scale should be much bigger compared to every beat.
				if ((curBeat % beatMod) == 0) {
					if (beatScaleMod >= 0 && beatScaleMod != null) {
						spr.scale.set(beatScaleMod, beatScaleMod); // Use beatScaleMod when it is greater than 0 and not null.
					}
				} else {
					if (scaleMod >= 0 && scaleMod != null) {
						spr.scale.set(scaleMod, scaleMod); // Use scaleMod when it is greater than 0 and not null.
					}
				}
				spr.updateHitbox();
				// IMPORTANT NOTE: If both scaleMod and beatScaleMod are null or less than 0, then do nothing.
			});
		}
		else
		{
			trace('Uhh no health icon group????');
		}
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
