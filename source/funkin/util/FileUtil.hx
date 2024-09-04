package funkin.util;

import haxe.Json;
import openfl.net.FileReference;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
#if (sys)
import sys.io.File;
import sys.FileSystem;
#else
import openfl.utils.Assets as Assets;
#end

using StringTools;

class FileUtil
{
	private static var m_JSON:FileReference;

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

	public static function saveJSON(v:Dynamic, filename:Null<String>):Void
	{
		var data:String = Json.stringify(v, "\t");

		if ((data != null) && (data.length > 0))
		{
			m_JSON = new FileReference();
			m_JSON.addEventListener(Event.COMPLETE, m_onSaveComplete);
			m_JSON.addEventListener(Event.CANCEL, m_onSaveCancel);
			m_JSON.addEventListener(IOErrorEvent.IO_ERROR, m_onSaveError);
			m_JSON.save(data.trim(), filename + '.json');
		}
	}

	private static function m_onSaveComplete(_):Void
	{
		m_JSON.removeEventListener(Event.COMPLETE, m_onSaveComplete);
		m_JSON.removeEventListener(Event.CANCEL, m_onSaveCancel);
		m_JSON.removeEventListener(IOErrorEvent.IO_ERROR, m_onSaveError);
		m_JSON = null;
	}

	private static function m_onSaveCancel(_):Void
	{
		m_JSON.removeEventListener(Event.COMPLETE, m_onSaveComplete);
		m_JSON.removeEventListener(Event.CANCEL, m_onSaveCancel);
		m_JSON.removeEventListener(IOErrorEvent.IO_ERROR, m_onSaveError);
		m_JSON = null;
	}

	private static function m_onSaveError(_):Void
	{
		m_JSON.removeEventListener(Event.COMPLETE, m_onSaveComplete);
		m_JSON.removeEventListener(Event.CANCEL, m_onSaveCancel);
		m_JSON.removeEventListener(IOErrorEvent.IO_ERROR, m_onSaveError);
		m_JSON = null;
	}
}
