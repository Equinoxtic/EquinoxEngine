package funkin.psychlua;

class CustomSubstate extends MusicBeatSubstate
{
	public static var name:String = 'unnamed';
	public static var instance:CustomSubstate;

	override function create():Void
	{
		instance = this;
		PlayState.instance.callOnLuas('onCustomSubstateCreate', [name]);
		super.create();
		PlayState.instance.callOnLuas('onCustomSubstateCreatePost', [name]);
	}
	
	public function new(name:String):Void
	{
		CustomSubstate.name = name;
		super();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}
	
	override function update(elapsed:Float):Void
	{
		PlayState.instance.callOnLuas('onCustomSubstateUpdate', [name, elapsed]);
		super.update(elapsed);
		PlayState.instance.callOnLuas('onCustomSubstateUpdatePost', [name, elapsed]);
	}

	override function destroy():Void
	{
		PlayState.instance.callOnLuas('onCustomSubstateDestroy', [name]);
		super.destroy();
	}
}
