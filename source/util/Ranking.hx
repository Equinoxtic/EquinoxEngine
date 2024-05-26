package util;

import Highscore;

class Ranking
{
	public static function calculateAccuracy(?percentage:Null<Float>):Float
	{
		return Highscore.floorDecimal(percentage * 100, 2);
	}

	public static function evaluateRatingFC():String
	{
		var fcConditions:Array<Bool> = [
			(PlayState.instance.songMisses == 0 && PlayState.instance.bads == 0 && PlayState.instance.shits == 0 && PlayState.instance.goods == 0), // PFC (Perfect FC)
			(PlayState.instance.songMisses == 0 && PlayState.instance.bads == 0 && PlayState.instance.shits == 0 && PlayState.instance.goods >= 1), // SFC (Sick FC)
			(PlayState.instance.songMisses == 0 && PlayState.instance.bads >= 1 && PlayState.instance.shits == 0 && PlayState.instance.goods >= 0), // GFC (Good FC)
			(PlayState.instance.songMisses == 0), // FC (Full Combo)
			(PlayState.instance.songMisses < 10), // SDCB (Single Digit Combo Breaks)
			(PlayState.instance.songMisses >= 10), // DDCB (Double Digit Combo Breaks)
			(PlayState.instance.songMisses >= 100), // TDCB (Triple Digit Combo Breaks)
			(PlayState.instance.songMisses >= 1000) // QDCB (Quadruple Digit Combo Breaks)
		];

		var ratingFcKey:String = '';

		for (rating in 0...fcConditions.length)
		{
			if (fcConditions[rating])
			{
				switch (rating)
				{
					case 0: ratingFcKey = 'PFC';
					case 1: ratingFcKey = 'SFC';
					case 2: ratingFcKey = 'GFC';
					case 3: ratingFcKey = 'FC';
					case 4: ratingFcKey = 'SDCB';
					case 5: ratingFcKey = 'CLEAR';
					case 6: ratingFcKey = 'TDCB';
					case 7: ratingFcKey = 'QDCB';
				}
				break;
			}
		}

		return ratingFcKey;
	}

	public static function evaluateLetterRanking(?accuracyValue:Null<Float>):String
	{
		if (accuracyValue == null) return 'ERR';

		var accuracyConditions:Array<Bool> = [
			accuracyValue >= 99.98,		// P (Perfect)
			accuracyValue >= 99.00,		// SSS
			accuracyValue >= 98.00,		// SS
			accuracyValue >= 93.00,   	// S
			accuracyValue >= 90.00,		// A
			accuracyValue >= 80.00,		// B
			accuracyValue >= 73.50,		// C
			accuracyValue >= 65.00,		// D
			accuracyValue >= 60.00,		// E
			accuracyValue < 50.00,		// F
		];

		var rankingKey:String = '';

		for (ranking in 0...accuracyConditions.length)
		{
			if (accuracyConditions[ranking])
			{
				switch (ranking)
				{
					case 0: rankingKey = 'P';
					case 1: rankingKey = 'SSS';
					case 2: rankingKey = 'SS';
					case 3: rankingKey = 'S';
					case 4: rankingKey = 'A';
					case 5: rankingKey = 'B';
					case 6: rankingKey = 'C';
					case 7: rankingKey = 'D';
					case 8: rankingKey = 'E';
					case 9: rankingKey = 'F';
				}
				break;
			}
		}
		
		return rankingKey;
	}
}
