package ui.game.rating;

import flixel.FlxCamera;

interface IRatingGraphic
{
	/**
	 * Loads the current rating's image/graphic.
	 */
	public function load(key:String, ?isPixel:Bool, ?camera:Null<FlxCamera>):Void;

	/**
	 * Loads rating images/graphics in numerical indexes.
	 */
	public function loadNumericalIndexes(indexes:Int, ?isPixel:Bool, ?camera:Null<FlxCamera>):Void;

	/**
	 * Sets the acceleration of the rating graphic.
	 */
	public function accelerateSprite(?rate:Float):Void;

	/**
	 * Sets the velocity of the rating graphic.
	 */
	public function velocitateSprite(?rate:Float):Void;

	/**
	 * Sets the scale/graphic size of the rating graphic.
	 */
	public function scaleSprite(?isPixel:Bool, ?pixelZoom:Float):Void;

	/**
	 * Plays the fading animation of the graphic, and destroys it.
	 */
	public function fadeAnimation(?rate:Float):Void;
}
