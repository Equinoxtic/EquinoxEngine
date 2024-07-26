package funkin.play.stage;

import funkin.ui.display.FunkinSprite.SpriteType;

class BackgroundStageSprite extends FunkinSprite
{
	private var idleAnim:String;
	public function new(key:String, x:Float = 0, y:Float = 0, ?scrollX:Float = 1, ?scrollY:Float = 1, ?animArray:Array<String> = null, ?loop:Bool = false, ?levelOfDetail:Bool = false):Void
	{
		super(x, y, levelOfDetail);

		if (animArray != null)
		{
			setAtlasSpriteType(key, SpriteType.SPARROW);
			for (i in 0...animArray.length) {
				var anim:String = animArray[i];
				addAnimatedSprite([[anim, anim]], 24, loop, null);
				if (idleAnim == null) {
					idleAnim = anim;
					animation.play(anim);
				}
			}
		}
		else
		{
			if (key != null) {
				loadSprite(key);
			}
			active = false;
		}

		scrollFactor.set(scrollX, scrollY);
	}

	public function dance(?forceplay:Bool = false):Void
	{
		if (idleAnim != null) {
			animation.play(idleAnim, forceplay);
		}
	}
}
