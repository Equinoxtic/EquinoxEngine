package funkin.util;

#if (sys)
import sys.io.File;
import sys.FileSystem;
#else
import openfl.utils.Assets as Assets;
#end

class FileUtil
{
	public static function getContentOfFile(path:String):String
	{
		#if (sys)
		return File.getContent(path);
		#else
		return Assets.getText(path);
		#end
	}

	public static function fileExists(path:String):Bool
	{
		#if (sys)
		return (FileSystem.exists(path));
		#else
		return (OpenFLAssets.exists(path));
		#end
	}

	public static function jsonExists(path:String):Bool
	{
		#if (MODS_ALLOWED)
		return (_modsJsonExists(path) || _fsJsonExists(path));
		#else
		return (OpenFlAssets.exists(Paths.json(path)));
		#end
	}

	#if (MODS_ALLOWED && sys)
	private static function _modsJsonExists(path:String):Bool
	{
		return (FileSystem.exists(Paths.modsJson(path)));
	}

	private static function _fsJsonExists(path:String):Bool
	{
		return (FileSystem.exists(Paths.json(path)));
	}
	#end
}
