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
		return ( FileSystem.exists(path) );
		#else
		return ( OpenFLAssets.exists(path) );
		#end
	}
}
