package funkin.ui.editor.group;

import flixel.addons.ui.FlxUI;

class EditorTabGroup extends FlxUI
{
	private var m_tabGroupChildren:Map<String, Dynamic> = [];

	private var m_tabMenu:EditorTabMenu;

	public function new(tabMenu:EditorTabMenu, name:Null<String>):Void
	{
		super(null, tabMenu);

		if (name == null || name == '') {
			name = "TAB_NAME";
		}

		this.name = name;
		this.m_tabMenu = tabMenu;
	}

	public function addChild(key:String, object:Dynamic):Void
	{
		if (key != null && object != null) {
			trace('Added $object with $key');
			m_tabGroupChildren.set(key, object);
		}
	}

	public function getChild(key:String):Dynamic
	{
		if (key == null || !m_tabGroupChildren.exists(key)) {
			return null;
		}
		return m_tabGroupChildren.get(key);
	}

	public function construct():Void
	{
		for (key => object in m_tabGroupChildren) {
			trace('Constructed object: $object (\"$key\")');
			this.add(object);
		}
		m_tabMenu.addGroup(this);
	}
}
