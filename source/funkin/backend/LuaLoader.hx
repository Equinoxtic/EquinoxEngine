package funkin.backend;

#if (sys)
import sys.FileSystem;
#end

import funkin.sound.FunkinSound;

import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class LuaLoader
{
	public static function loadLuaPath(path:Null<String>):Void
	{
		#if MODS_ALLOWED
		var file:String = Paths.modFolders('$path.lua');
		if (FileSystem.exists(file)) {
			PlayState.instance.luaArray.push(new FunkinLua(file));
		} else {
			file = Paths.getPreloadPath('$path.lua');
			if (FileSystem.exists(file)) {
				PlayState.instance.luaArray.push(new FunkinLua(file));
			}
		}
		#elseif (sys)
		var file:String = Paths.getPreloadPath('$path.lua');
		if (OpenFlAssets.exists(file)) {
			PlayState.instance.luaArray.push(new FunkinLua(file));
		}
		#end
	}

	public static function loadGlobalScripts():Void
	{
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('scripts/')];

		final path:String = 'scripts/';

		m_insertDirectoryToFolderChecks(foldersToCheck, path, Paths.currentModDirectory);

		for (folder in foldersToCheck) {
			if (FileSystem.exists(folder)) {
				for (file in FileSystem.readDirectory(folder)) {
					if (m_checkLuaPath(file, filesPushed)) {
						PlayState.instance.luaArray.push(new FunkinLua('${folder}${file}'));
						filesPushed.push(file);
					}
				}
			}
		}
		#end
	}

	public static function loadStageScripts(curStage:Null<String>):Void
	{
		#if (MODS_ALLOWED && LUA_ALLOWED)
		if (curStage == null || curStage == '') return;

		var push:Bool = false;
		var file:String = 'stages/$curStage.lua';
		if (FileSystem.exists(Paths.modFolders(file))) {
			file = Paths.modFolders(file);
			push = true;
		} else {
			file = Paths.getPreloadPath(file);
			if (FileSystem.exists(file)) {
				push = true;
			}
		}

		if (push) {
			PlayState.instance.luaArray.push(new FunkinLua(file));
		}
		#end
	}

	public static function loadSongScripts(song:Null<String>):Void
	{
		#if LUA_ALLOWED
		if (song == null || song == '')
			return;

		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('data/charts/${Paths.formatToSongPath(song)}/scripts/')];

		final path:String = 'data/charts/${Paths.formatToSongPath(song)}/scripts/';

		m_insertDirectoryToFolderChecks(foldersToCheck, path, Paths.currentModDirectory);

		for (folder in foldersToCheck) {
			if (FileSystem.exists(folder)) {
				for (file in FileSystem.readDirectory(folder)) {
					if (PlayState.instance.erectMode) {
						if (m_checkLuaPath(file, filesPushed)) {
							PlayState.instance.luaArray.push(new FunkinLua('${folder}${file}'));
							filesPushed.push(file);
						}
					} else {
						if (m_checkLuaPath(file, filesPushed) && file.contains(Std.string('${FunkinSound.erectModeSuffix()}'))) {
							PlayState.instance.luaArray.push(new FunkinLua('${folder}${file}'));
							filesPushed.push(file);
						}
					}
				}
			}
		}
		#end
	}

	public static function loadCharacterScript(name:Null<String>):Void
	{
		#if LUA_ALLOWED
		if (name == null || name == '') return;

		var push:Bool = false;
		var file:String = 'characters/$name.lua';
		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modFolders(file))) {
			file = Paths.modFolders(file);
			push = true;
		} else {
			file = Paths.getPreloadPath(file);
			if(FileSystem.exists(file)) {
				push = true;
			}
		}
		#else
		file = Paths.getPreloadPath(file);
		if (Assets.exists(file)) {
			push = true;
		}
		#end

		if (push)
		{
			for (script in PlayState.instance.luaArray) {
				if (script.scriptName == file) {
					return;
				}
			}
			PlayState.instance.luaArray.push(new FunkinLua(file));
		}
		#end
	}

	@:noPrivateAccess
	private static function m_insertDirectoryToFolderChecks(folders:Array<String>, directory:String, modDirectory:String):Void
	{
		#if (MODS_ALLOWED)
		folders.insert(0, Paths.mods(directory));

		if (modDirectory != null && modDirectory.length > 0) {
			folders.insert(0, Paths.mods('$modDirectory/$directory'));
		}

		for (mod in Paths.getGlobalMods()) {
			folders.insert(0, Paths.mods('$mod/$directory'));
		}
		#end
	}

	@:noPrivateAccess
	private static function m_checkLuaPath(file:String, ?fileArray:Array<String>):Bool
	{
		return (file.endsWith('.lua') && !fileArray.contains(file));
	}
}
