package animateatlas;
import animateatlas.JSONData.AnimationData;
import animateatlas.JSONData.AtlasData;
import animateatlas.displayobject.SpriteAnimationLibrary;
import animateatlas.displayobject.SpriteMovieClip;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import haxe.Json;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;

using StringTools;


class AtlasFrameMaker extends FlxFramesCollection
{
	//public static var widthoffset:Int = 0;
	//public static var heightoffset:Int = 0;
	//public static var excludeArray:Array<String>;
	/**
	
	* Creates Frames from TextureAtlas(very early and broken ok) Originally made for FNF HD by Smokey and Rozebud
	*
	* @param   key                 The file path.
	* @param   _excludeArray       Use this to only create selected animations. Keep null to create all of them.
	*
	*/

	public static function construct(key:String,?library:String,?_excludeArray:Array<String> = null, ?noAntialiasing:Bool = false):FlxFramesCollection
	{
		// widthoffset = _widthoffset;
		// heightoffset = _heightoffset;

		var frameCollection:FlxFramesCollection;
		var frameArray:Array<Array<FlxFrame>> = [];

		if (Paths.fileExists('images/$key/spritemap1.json', TEXT))
		{
			PlayState.instance.addTextToDebug("Only Spritemaps made with Adobe Animate 2018 are supported", FlxColor.RED);
			trace("Only Spritemaps made with Adobe Animate 2018 are supported");
			return null;
		}

		var animationData:AnimationData = Json.parse(Paths.getTextFromFile('images/$key/Animation.json'));
		var atlasData:AtlasData = Json.parse(Paths.getTextFromFile('images/$key/spritemap.json').replace("\uFEFF", ""));

		var graphic:FlxGraphic = Paths.image('$key/spritemap', library, false);
		var ss:SpriteAnimationLibrary = new SpriteAnimationLibrary(animationData, atlasData, graphic.bitmap);
		var t:SpriteMovieClip = ss.createAnimation(noAntialiasing);
		if(_excludeArray == null)
		{
			_excludeArray = t.getFrameLabels();
			//trace('creating all anims');
		}
		trace('Creating: ' + _excludeArray);

		frameCollection = new FlxFramesCollection(graphic, FlxFrameCollectionType.IMAGE);
		for(x in _excludeArray)
		{
			frameArray.push(getFramesArray(key, t, x));
		}

		for(x in frameArray)
		{
			for(y in x)
			{
				frameCollection.pushFrame(y);
			}
		}
		return frameCollection;
	}

	@:noCompletion static function getFramesArray(key:String,t:SpriteMovieClip,animation:String):Array<FlxFrame>
	{
		var sizeInfo:Rectangle = new Rectangle(0, 0);
		t.currentLabel = animation;
		var bitMapArray:Array<BitmapData> = [];
		var daFramez:Array<FlxFrame> = [];
		var firstPass = true;
		var frameSize:FlxPoint = new FlxPoint(0, 0);

		for (i in t.getFrame(animation)...t.numFrames)
		{
			t.currentFrame = i;
			if (t.currentLabel == animation)
			{
				sizeInfo = t.getBounds(t);
				var bitmapShit:BitmapData = new BitmapData(Std.int(sizeInfo.width + sizeInfo.x), Std.int(sizeInfo.height + sizeInfo.y), true, 0);
				bitmapShit.draw(t, null, null, null, null, true);
				if (ClientPrefs.gpuTextures) bitmapShit = Paths.convertBMP(bitmapShit, key);
				bitMapArray.push(bitmapShit);

				if (firstPass)
				{
					frameSize.set(bitmapShit.width,bitmapShit.height);
					firstPass = false;
				}
			}
			else break;
		}
		
		for (i in 0...bitMapArray.length)
		{
			var b = FlxGraphic.fromBitmapData(bitMapArray[i]);
			var theFrame = new FlxFrame(b);
			theFrame.parent = b;
			theFrame.name = animation + i;
			theFrame.sourceSize.set(frameSize.x,frameSize.y);
			theFrame.frame = new FlxRect(0, 0, bitMapArray[i].width, bitMapArray[i].height);
			daFramez.push(theFrame);
			//trace(daFramez);
		}
		return daFramez;
	}
}
