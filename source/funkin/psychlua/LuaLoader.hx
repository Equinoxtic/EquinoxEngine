package funkin.psychlua;

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

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('scripts/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods('${Paths.currentModDirectory}/scripts/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods('${mod}/scripts/'));
		#end

		for (folder in foldersToCheck) {
			if (FileSystem.exists(folder)) {
				for (file in FileSystem.readDirectory(folder)) {
					if (file.endsWith('.lua') && !filesPushed.contains(file)) {
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
		if (song == null || song == '') return;

		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('data/charts/${Paths.formatToSongPath(song)}/scripts/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('data/charts/${Paths.formatToSongPath(song)}/scripts/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/${'data/charts/${Paths.formatToSongPath(song)}/scripts/'}'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + 'data/charts/${Paths.formatToSongPath(song)}/scripts/'));// using push instead of insert because these should run after everything else
		#end

		for (folder in foldersToCheck) {
			if (FileSystem.exists(folder)) {
				for (file in FileSystem.readDirectory(folder)) {
					if (PlayState.instance.erectMode) {
						if (file.endsWith('.lua') && !filesPushed.contains(file)) {
							PlayState.instance.luaArray.push(new FunkinLua('${folder}${file}'));
							filesPushed.push(file);
						}
					} else {
						if (file.endsWith('.lua') && file.contains(Std.string('${FunkinSound.erectModeSuffix()}')) && !filesPushed.contains(file)) {
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
}
