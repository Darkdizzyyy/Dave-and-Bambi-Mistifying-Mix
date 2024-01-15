package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;

class MenuItemAltFreeplay extends FlxSprite
{
	public var targetX:Float = 0;

	public function new(x:Float, y:Float, categoryIcon:String = '')
	{
		super(x, y);
		loadGraphic(Paths.image('packs/' + categoryIcon));
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		x = FlxMath.lerp(x, (targetX * 1000) + 380, CoolUtil.boundTo(elapsed * 10.2, 0, 1));
	}
}