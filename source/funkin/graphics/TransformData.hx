package funkin.graphics;

class TransformData
{
	public function new():Void {}

	public function incrementalValue(v:Null<Float>, ?iv:Null<Float> = 0.0):Float
	{
		return (v + iv);
	}
}
