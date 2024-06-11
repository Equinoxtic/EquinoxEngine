package source;

#if (sys)
import sys.io.FileOutput;
import sys.io.File;

/**
 * A script which executes before the game is built.
 *
 * From: https://github.com/FunkinCrew/Funkin/blob/main/source/Prebuild.hx
 */
class PreBuild
{
	static inline final FILE:String = ".BUILD_TIME";

	static function main():Void
	{
		var s:String = '';

		s += "\n\t### [ Building Equinox Engine... ] ###\n\n"

			+ "    <--------------------------------------------------------------------------------------->\n\n"

			+ "\t* Special thanks to the Psych Engine team.\n"
			+ "\t  - Check out PE's repository here: https://github.com/ShadowMario/FNF-PsychEngine\n\n"

			+ "\t* Custom Sound System [FunkinSound.hx] for vocal separation made by @Equinoxtic !!!\n\n"
			+ "\t( Some FNF V-Slice features are added in this engine, i.e. ERECT mode and etc. )\n\n"
			+ "\t> Check out Equinox Engine here: https://github.com/Equinoxtic/EquinoxEngine/tree/master\n\n"

			+ "    <--------------------------------------------------------------------------------------->\n\n"
		;

		Sys.stdout().writeString(s);

		save();
	}

	static function save():Void
	{
		var f:FileOutput = File.write(FILE);

		if (f != null)
		{
			var t_now:Float = Sys.time();
			f.writeDouble(t_now);
			f.close();
		}
		else
		{
			return;
		}
	}
}
#end
