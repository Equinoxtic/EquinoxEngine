package funkin.graphics;

#if (VIDEOS_ALLOWED)
import vlc.MP4Handler;
#end

class FunkinVideo
{
	public function new():Void {}

	public function start(path:String, ?callback:Null<Void->Void>):Void
	{
		#if (VIDEOS_ALLOWED)
		if (!FileUtil.fileExists(Paths.video(path))) {
			FlxG.log.warn('Couldnt find video file: $path');
			callback();
			return;
		}

		var video:MP4Handler = new MP4Handler();
		video.playVideo(Paths.video(path));
		video.finishCallback = function() {
			callback();
			return;
		}
		#else
		FlxG.log.warn('Platform not supported!');
		callbacK();
		return;
		#end
	}
}
