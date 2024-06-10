package funkin.play.scoring;

import funkin.util.Constants;

class Rating
{
	/**
	 * The name of the rating.
	 */
	public var name:String = '';

	/**
	 * The graphic/image of the rating.
	 */
	public var image:String = '';

	/**
	 * Used for counting the current rating, not much use for it, really.
	 */
	public var counter:String = '';

	/**
	 * The "hit window" for the rating in milliseconds. (ms)
	 */
	public var hitWindow:Null<Int> = 0;

	/**
	 * The amount of accuracy lost/gained from the rating.
	 */
	public var ratingMod:Float = 1.0;

	/**
	 * The amount of score gained from the rating.
	 */
	public var score:Int = 500;

	/**
	 * The amount of health gained from the rating.
	 */
	public var healthGain:Float = Constants.HEALTH_MARVELOUS_BONUS;

	/**
	 * Should the rating have the notesplashes appear?
	 */
	public var noteSplash:Bool = true;

	/**
	 * Should the rating count as a combo break/miss?
	 */
	public var comboBreak:Bool = false;

	public function new(name:String)
	{
		this.name = name;
		this.image = name;
		this.counter = name + 's';
		this.hitWindow = Reflect.field(Preferences, name + 'Window');
		if (hitWindow == null) {
			hitWindow = 0;
		}
	}

	public function increase(blah:Int = 1)
	{
		Reflect.setField(PlayState.instance, counter, Reflect.field(PlayState.instance, counter) + blah);
	}
}

class PlayStateRating
{
	/**
	 * The array for storing all the ratings.
	 */
	public static var ratingsData:Array<Rating> = [];

	/**
	 * Initializes all of the ratings. This should be put in PlayState where it could be utilized.
	 */
	public static function initPlayStateRatings():Void
	{
		/**
		* 'Marvelous!' Rating.
		*/
		ratingsData.push(new Rating('marv'));

		/**
		* 'Sick!' Rating.
		*/
		final ratingSick:Rating = new Rating('sick');
		ratingSick.ratingMod = 1.0;
		ratingSick.score = 350;
		ratingSick.healthGain = Constants.HEALTH_SICK_BONUS;
		ratingSick.noteSplash = true;
		ratingSick.comboBreak = false;

		/**
		* 'Good!' Rating.
		*/
		final ratingGood:Rating = new Rating('good');
		ratingGood.ratingMod = 0.7;
		ratingGood.score = 200;
		ratingGood.healthGain = Constants.HEALTH_GOOD_BONUS;
		ratingGood.noteSplash = false;
		ratingGood.comboBreak = false;

		/**
		* 'Bad.' Rating.
		*/
		final ratingBad:Rating = new Rating('bad');
		ratingBad.ratingMod = 0.4;
		ratingBad.score = 100;
		ratingBad.healthGain = Constants.HEALTH_BAD_BONUS;
		ratingBad.noteSplash = false;
		ratingBad.comboBreak = false;

		/**
		* 'Shit.' Rating.
		*/
		final ratingShit:Rating = new Rating('shit');
		ratingShit.ratingMod = 0;
		ratingShit.score = -100;
		ratingShit.healthGain = Constants.HEALTH_SHIT_BONUS;
		ratingShit.noteSplash = false;
		ratingShit.comboBreak = true;

		ratingsData.push(ratingSick);
		ratingsData.push(ratingGood);
		ratingsData.push(ratingBad);
		ratingsData.push(ratingShit);
	}
}
