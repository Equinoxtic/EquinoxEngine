package funkin.play.scoring;

import funkin.play.scoring.Highscore;

class Ranking
{
	/**
	 * Calculates the accuracy given the percentage. (i.e. ``1.0 -> 100.00``)
	 * @param percentage The percentage of the accuracy. Ranges from ``0.0 - 1.0``
	 * @return Float
	 */
	public static function calculateAccuracy(?percentage:Null<Float>):Float
	{
		return Highscore.floorDecimal(percentage * 100, 2);
	}

	/**
	 * Evaluates the FC rating, given the amount of misses, bads, sicks, etc.
	 * @param misses The amount of the player's ``"misses"`` during a song.
	 * @param shits The amount of the player's ``"shit"`` during a song.
	 * @param bads The amount of the player's ``"bad"`` during a song.
	 * @param goods The amount of the player's ``"goods"`` during a song.
	 * @param sicks The amount of the player's ``"sicks"`` during a song.
	 * @param marvs The amount of the player's ``"marvs"`` during a song.
	 * @return String
	 */
	public static function evaluateRatingFC(?misses:Null<Int>, ?shits:Null<Int>, ?bads:Null<Int>, ?goods:Null<Int>, ?sicks:Null<Int>, ?marvs:Null<Int>):String
	{
		/**
		 * The array for the rating FCs.
		 * - DEFAULT VALUES:
		 * 'PFC' - misses = 0, shits = 0, bads = 0, goods = 0, sicks >= 0, marvs >= 0,
		 * 'SFC' - misses = 0, shits = 0, bads = 0, goods >= 1, sicks >= 0, marvs >= 0,
		 * 'GFC' - misses = 0, shits = 0, bads >= 1, goods >= 0, sicks >= 0 && marvs >= 0,
		 * 'FC' - misses = 0,
		 * 'CLEAR' - misses >= 10,
		 */
		final ratings:Array<Dynamic> = [
			['PFC', (misses == 0 && shits == 0 && bads == 0 && goods == 0 && sicks >= 0 && marvs >= 0)],
			['SFC', (misses == 0 && shits == 0 && bads == 0 && goods >= 1 && sicks >= 0 && marvs >= 0)],
			['GFC', (misses == 0 && shits == 0 && bads >= 1 && goods >= 0 && sicks >= 0 && marvs >= 0)],
			['FC', (misses == 0)],
			['SDCB', (misses < 10)],
			['CLEAR', (misses >= 10)]
		];

		var ratingKey:String = '';

		for (rating in 0...ratings.length)
		{
			if (ratings[rating][1]) {
				ratingKey = ratings[rating][0];
				break;
			}
		}

		return ratingKey;
	}

	/**
	 * Evaluates the (letter) ranking, given the accuracy.
	 * @param accuracy The accuracy of the player.
	 * @return String
	 */
	public static function evaluateLetterRanking(?accuracy:Null<Float>):String
	{
		/**
		 * The array for the letter rankings.
		 * - DEFAULT VALUES:
		 * 'P' - 99.98%,
		 * 'SSS' - 99.00%,
		 * 'SS' - 98.00%,
		 * 'S' - 93.00%,
		 * 'A' - 90.00%,
		 * 'B' - 80.00%,
		 * 'C' - 73.50%,
		 * 'D' - 65.00%,
		 * 'E' - 60.00%,
		 * 'F' - <50.00%
		 */
		final ranks:Array<Dynamic> = [
			['P', (accuracy >= 99.98)],
			['SSS', (accuracy >= 99.00)],
			['SS', (accuracy >= 98.00)],
			['S', (accuracy >= 93.00)],
			['A', (accuracy >= 90.00)],
			['B', (accuracy >= 80.00)],
			['C', (accuracy >= 73.50)],
			['D', (accuracy >= 65.00)],
			['E', (accuracy >= 60.00)],
			['F', (accuracy < 60.00)]
		];

		var rankingKey:String = '';

		for (ranking in 0...ranks.length)
		{
			if (ranks[ranking][1]) {
				rankingKey = ranks[ranking][0];
				break;
			}
		}

		return rankingKey;
	}
}
