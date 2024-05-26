package util;

import util.Constants as Constants;

class Rating
{
	public var name:String = '';
	public var image:String = '';
	public var counter:String = '';
	public var hitWindow:Null<Int> = 0; //ms
	public var ratingMod:Float = 1;
	public var score:Int = 700;
	public var healthGain:Float = Constants.HEALTH_MARVELOUS_BONUS;
	public var noteSplash:Bool = true;

	public function new(name:String)
	{
		this.name = name;
		this.image = name;
		this.counter = name + 's';
		this.hitWindow = Reflect.field(ClientPrefs, name + 'Window');
		if(hitWindow == null)
		{
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
	public static function initPlayStateRatings(dataArray:Null<Array<Rating>>):Void
	{
		if (dataArray != null || !(dataArray.length < 0))
		{
			/**
			 * 'Marvelous!' Rating.
			 */
			dataArray.push(new Rating('marv'));

			/**
			 * 'Sick!' Rating.
			 */
			var ratingSick:Rating = new Rating('sick');
			ratingSick.ratingMod = 1.0;
			ratingSick.score = 350;
			ratingSick.healthGain = Constants.HEALTH_SICK_BONUS;
			ratingSick.noteSplash = true;
		
			/**
			 * 'Good!' Rating.
			 */
			var ratingGood:Rating = new Rating('good');
			ratingGood.ratingMod = 0.7;
			ratingGood.score = 200;
			ratingGood.healthGain = Constants.HEALTH_GOOD_BONUS;
			ratingGood.noteSplash = false;
			
			/**
			 * 'Bad.' Rating.
			 */
			var ratingBad:Rating = new Rating('bad');
			ratingBad.ratingMod = 0.4;
			ratingBad.score = 100;
			ratingBad.healthGain = Constants.HEALTH_BAD_BONUS;
			ratingBad.noteSplash = false;
			
			/**
			 * 'Shit.' Rating.
			 */
			var ratingShit:Rating = new Rating('shit');
			ratingShit.ratingMod = 0;
			ratingShit.score = 50;
			ratingShit.healthGain = Constants.HEALTH_SHIT_BONUS;
			ratingShit.noteSplash = false;
			
			dataArray.push(ratingSick);
			dataArray.push(ratingGood);
			dataArray.push(ratingBad);
			dataArray.push(ratingShit);
		}
	}
}
