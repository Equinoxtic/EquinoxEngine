package funkin.graphics.shaders;

import flixel.system.FlxAssets.FlxShader;

class Grayscale extends Effect
{
	public var shader(default, null):GrayscaleShader = new GrayscaleShader();
	public var strength:Float = 0.0;

	public function new():Void
	{
		shader.strength.value = [0];
	}

	override public function update(elapsed:Float):Void
	{
		shader.strength.value[0] = strength;
	}
}

class GrayscaleShader extends FlxShader
{
	@:glFragmentSource('
		// https://en.wikipedia.org/wiki/Grayscale

		#pragma header

		uniform float strength;

		void main()
		{
			vec2 uv = openfl_TextureCoordv;
			vec4 color = flixel_texture2D(bitmap, uv);
			float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114))
			gl_FragColor = mix(color, vec4(gray, gray, gray, color.a), strength);
		}
	')

	public function new():Void
	{
		super();
	}
}
