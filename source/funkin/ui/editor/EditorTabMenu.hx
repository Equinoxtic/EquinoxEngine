package funkin.ui.editor;

import flixel.addons.ui.interfaces.IFlxUIButton;
import flixel.addons.ui.FlxUITabMenu;

typedef EditorTabMenuOptions = {
	var tabs:Array<{name:String, label:String}>; // wtf syntax in haxe???
	@:optional var width:Float;
	@:optional var height:Float;
}

class EditorTabMenu extends FlxUITabMenu
{
	public function new(?x:Float, ?y:Float, ?options:Null<EditorTabMenuOptions>):Void
	{
		super(null, options.tabs, true);

		this.setPosition(x, y);
		this.resize(options.width, options.height);
		this.scrollFactor.set();
	}
}
