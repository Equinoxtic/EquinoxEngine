package funkin.util;

import openfl.filters.BitmapFilter;
import flixel.FlxCamera;

class ShaderUtil
{
	public static function setShadersToCameraGroup(cameraList:Null<Array<FlxCamera>>, shaderList:Null<Array<BitmapFilter>>):Void
	{
		if (GlobalSettings.SHADERS)
		{
			if (cameraList == null || shaderList == null) {
				return;
			}

			for (camera in cameraList) {
				if (camera != null) {
					camera.setFilters(shaderList);
				}
			}
		}
	}
}
