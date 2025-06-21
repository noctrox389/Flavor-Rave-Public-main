#if VIDEOS_ALLOWED
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import hxvlc.flixel.FlxVideo;
import openfl.events.KeyboardEvent;
import openfl.events.TouchEvent;

class VideoHandler extends FlxVideo
{
	public var canSkip:Bool = false;
	public var skipKeys:Array<FlxKey> = [];

	public function new():Void
	{
		super();

		onEndReached.add(function()
		{
			dispose();
		});
	}

	override public function load(location:String, ?options:Array<String>):Bool
	{
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(TouchEvent.TOUCH_BEGIN, onScreenPress);
		return super.load(location, options);
	}

	override public function dispose():Void
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(TouchEvent.TOUCH_BEGIN, onScreenPress);
		super.dispose();
	}

	private function onKeyPress(event:KeyboardEvent):Void
	{
		if (!canSkip)
			return;

		if (skipKeys.contains(event.keyCode))
		{
			canSkip = false;
			onEndReached.dispatch();
		}
	}
	private function onScreenPress(event:TouchEvent):Void
	{
		if (!canSkip) 
			return;
		canSkip = false;
		onEndReached.dispatch();
	}
}
#end
