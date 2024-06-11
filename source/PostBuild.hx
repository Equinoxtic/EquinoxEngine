package source;

import sys.io.FileInput;
#if (sys)
import sys.FileSystem;
import sys.io.File;

using StringTools;

class PostBuild
{
	static inline final FILE:String = ".BUILD_TIME";
	static inline final REPOSITORY:String = "https://github.com/Equinoxtic/EquinoxEngine";

	static function main():Void
	{
		var s:String = '';

		s += '\n\t[ Finished Buiding Equinox Engine! ]\n\n'

			+ '\t* For future updates, check the repository here: ${REPOSITORY}\n\n'

			+ '\t[ INFO - EquinoxEngine - MAIN ]:\n'
			+ '\t> Name: \"Friday Night Funkin\': Equinox Engine\"'
			+ '\t> Version: NULL\n'
			+ '\t> Funkin\' Version: 0.3.3 (V-Slice)\n\n'
		;

		Sys.stdout().writeString(s);

		displayBuildTime();
	}

	static function displayBuildTime():Void
	{
		var e:Float = Sys.time();
		var t:Float = 0.0;

		if (FileSystem.exists(FILE))
		{
			var f:FileInput = File.read(FILE);

			if (f != null)
			{
				var s:Float = f.readDouble();
				f.close();
				FileSystem.deleteFile(FILE);

				t = roundToTwoDecimals(e - s);
			}

			Sys.print('> [POSTBUILD INFO]: Build time took ${t}s ... \n\n');
		}
	}

	static function roundToTwoDecimals(v:Float):Float
	{
		return Math.round(v * 100) / 100;
	}
}
#end
