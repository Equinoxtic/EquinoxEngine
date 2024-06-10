package funkin.graphics.shaders;

import flixel.system.FlxAssets.FlxShader;

class Effect
{
	public function setValue(shader:FlxShader, variable:String, value:Float):Void
	{
		Reflect.setProperty(Reflect.getProperty(shader, 'variable'), 'value', [value]);
	}

	public function update(elapsed:Float):Void
	{
		// Does nothing yet.
	}
}
