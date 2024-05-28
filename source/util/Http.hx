package util;

import haxe.Http as HaxeHTTP;

using StringTools;

/**
 * From CNE (Codename Engine)
 * 
 * Source: https://github.com/FNF-CNE-Devs/CodenameEngine/blob/main/source/funkin/backend/utils/HttpUtil.hx
 */
class Http
{
	public static var userAgent:String = 'request';

	public static function requestStringFrom(url:String)
	{
		var value:String = null;

		if (url != null && url != '')
		{
			var httpData:HaxeHTTP = new HaxeHTTP(url);
			
			httpData.setHeader('User-Agent', userAgent);

			httpData.onData = function(data:String):Void
			{
				if (value == null) {
					value = data.split('\n')[0].trim();
				}
			}

			httpData.onError = function(err:Dynamic):Void
			{
				throw err;
			}

			httpData.request();
		}

		return value;
	}
}
