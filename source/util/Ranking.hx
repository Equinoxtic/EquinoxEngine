package util;

import Highscore;

class Ranking
{
	/**
	 * The string array for the rating FCs.
	 * - DEFAULT VALUES:
	 * [ 'PFC', 'SFC', 'GFC', 'FC', 'SDCB', 'DDCB', 'TDCB', 'QDCB' ],
	 */
	public static var ratingsArray:Array<String> = [
		'PFC', 'SFC', 'GFC', 'FC',
		'SDCB', 'DDCB', 'TDCB', 'QDCB'
	];

	/**
	 * The string array for the letter rankings.
	 * - DEFAULT VALUES:
	 * [ 'P', 'SSS', 'SS', 'S', 'A', 'B', 'C', 'D', 'E', 'F' ]
	 */
	public static var letterRanksArray:Array<String> =[
		'P', 'SSS', 'SS', 'S', 'A', 'B', 'C', 'D', 'E', 'F'
	];

	public static function calculateAccuracy(?percentage:Null<Float>):Float
	{
		return Highscore.floorDecimal(percentage * 100, 2);
	}

	public static function evaluateRatingFC(?misses:Null<Int>, ?bads:Null<Int>, ?shits:Null<Int>, ?goods:Null<Int>, ?sicks:Null<Int>, ?marvs:Null<Int>):String
	{
		var fcConditions:Array<Bool> = [
			(misses == 0 && bads == 0 && shits == 0 && goods == 0 && sicks >= 0 && marvs >= 0), // PFC (Perfect FC)
			(misses == 0 && bads == 0 && shits == 0 && goods >= 1 && sicks >= 0 && marvs >= 0), // SFC (Sick FC)
			(misses == 0 && bads >= 1 && shits == 0 && goods >= 0 && sicks >= 0 && marvs >= 0), // GFC (Good FC)
			(misses == 0), // FC (Full Combo)
			(misses < 10), // SDCB (Single Digit Combo Breaks)
			(misses >= 10), // DDCB (Double Digit Combo Breaks)
			(misses >= 100), // TDCB (Triple Digit Combo Breaks)
			(misses >= 1000) // QDCB (Quadruple Digit Combo Breaks)
		];

		var ratingKey:String = '';

		for (rating in 0...fcConditions.length)
		{
			if (fcConditions[rating]) {
				ratingKey = ratingsArray[rating];
				break;
			}
		}

		return ratingKey;
	}

	public static function evaluateLetterRanking(?accuracyValue:Null<Float>):String
	{
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
			if (accuracyConditions[ranking]) {
				rankingKey = letterRanksArray[ranking];
				break;
			}
		}
		
		return rankingKey;
	}
}
