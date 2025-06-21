package;

import Language.LanguageText;
import Metadata.MetadataSong;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;

typedef HUDData =
{
	var lyric:PosData;
	var time:PosData;
	var metadata:PosData;
	var health:PosData;
	var score:PosData;
	var p1:PosData;
	var p2:PosData;
}

typedef PosData =
{
	var position:Array<Float>;
	var positionDown:Array<Float>; // Downscroll (if needed)
	var scale:Null<Float>;
	var scaleMax:Null<Float>;
}

class FlavorHUD extends FlxSpriteGroup
{
	private var hudData:HUDData;
	private var playState:PlayState = PlayState.instance;
	private var healthPercent:Float = 1;
	private var songPercent:Float = 0;
	private var useLyrics:Bool = false;

	public var lyricBar:FlxSprite;
	public var timeBar:FlxBar;
	public var healthBar:FlxBar;
	public var bg:FlxSprite;
	public var pointer:FlxSprite;
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var metadata:LanguageText;
	public var score:LanguageText;
	public var lyrics:LanguageText;
	public var forceP1Frame:String = '';
	public var forceP2Frame:String = '';

	public var allowScroll:Bool = true;

	public function new(p1:Character, p2:Character, songMeta:Metadata):Void
	{
		super();
		hudData = cast Json.parse(Assets.getText(Paths.json('hudPosData')));

		timeBar = new FlxBar(hudData.time.position[0] - 2, hudData.time.position[1] - 2, LEFT_TO_RIGHT, 263 + 4, 22 + 4, this, 'songPercent', 0, 1);
		timeBar.numDivisions = Std.int(timeBar.width);

		var songData:MetadataSong = null;

		if (songMeta != null)
		{
			useLyrics = songMeta.control != null && songMeta.control.hasLyrics;
			songData = songMeta.song != null ? songMeta.song : null;
		}

		var songName:String = songData != null ? '${songData.name} - ${songData.artist}' : PlayState.SONG.song;
		metadata = new LanguageText(hudData.metadata.position[0], hudData.metadata.position[1], 0, songName, Std.int(hudData.metadata.scale), 'krungthep');
		metadata.setStyle(FlxColor.WHITE, LEFT);
		metadata.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5, 1.5);
		if (metadata.width > 255) resetMetadata(false);
		metadata.clipRect = new FlxRect(timeBar.x - metadata.x, timeBar.y - metadata.y, timeBar.width, timeBar.height);

		healthBar = new FlxBar(hudData.health.position[0] - 4, hudData.health.position[1] - 2, (playState.opponentPlay ? LEFT_TO_RIGHT : RIGHT_TO_LEFT),
			494 + 8, 22 + 4, this, 'healthPercent', 0, 2);
		healthBar.antialiasing = ClientPrefs.globalAntialiasing;
		healthBar.numDivisions = Std.int(healthBar.width);
		reloadHealth(p1, p2);

		lyricBar = new FlxSprite(hudData.lyric.position[0], hudData.lyric.position[1]).loadGraphic(Paths.image('FlavorHUDLyricBar'));
		lyricBar.antialiasing = ClientPrefs.globalAntialiasing;
		lyricBar.visible = useLyrics;

		bg = new FlxSprite();
		bg.frames = Paths.getSparrowAtlas('FlavorHUD');
		bg.animation.addByPrefix('bump', 'FRHUD', 24, false);
		bg.antialiasing = ClientPrefs.globalAntialiasing;

		pointer = new FlxSprite(385, 67).loadGraphic(Paths.image('healthpointer'));
		pointer.antialiasing = ClientPrefs.globalAntialiasing;

		lyrics = new LanguageText(lyricBar.x + 20, lyricBar.y + 8, 663, "", Std.int(hudData.lyric.scale), 'krungthep');
		lyrics.setStyle(FlxColor.WHITE, CENTER);
		lyrics.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5, 1.5);
		lyrics.visible = useLyrics;

		if (ClientPrefs.downScroll)
		{
			lyricBar.flipY = true;
			lyricBar.setPosition(hudData.lyric.positionDown[0], hudData.lyric.positionDown[1]);
			lyrics.setPosition(lyricBar.x + 20, lyricBar.y + 16);
		}

		score = new LanguageText(hudData.score.position[0], hudData.score.position[1], 0, "", Std.int(hudData.score.scale), 'krungthep');
		score.setStyle(FlxColor.WHITE, LEFT);

		iconP1 = new HealthIcon(p1.healthIcon, true);
		iconP1.scale.set(hudData.p1.scale, hudData.p1.scale);
		iconP1.updateHitbox();
		iconP1.setPosition(hudData.p1.position[0], hudData.p1.position[1]);

		iconP2 = new HealthIcon(p2.healthIcon, false);
		iconP2.scale.set(hudData.p2.scale, hudData.p2.scale);
		iconP2.updateHitbox();
		iconP2.setPosition(hudData.p2.position[0], hudData.p2.position[1]);

		add(timeBar);
		add(metadata);
		add(healthBar);
		add(lyricBar);
		add(bg);
		if (!playState.disableHealth) add(pointer);
		
		add(lyrics);
		add(score);
		add(iconP1);
		add(iconP2);
	}

	private var metadataScroll:Bool = false;

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// PlayState sync
		{
			songPercent = playState.songPercent;
			healthPercent = FlxMath.lerp(healthPercent, playState.health, 0.15);
		}

		// Pointer position
		{
			var pointerRange:Float = FlxMath.remapToRange(
				(healthPercent / 2) * 100,
				playState.opponentPlay ? 100 : 0,
				playState.opponentPlay ? 0 : 100,
				100, 0
			);

			pointer.x = healthBar.x + (healthBar.width * (pointerRange * 0.01)) + (150 * pointer.scale.x - 150) / 2 - 15;
			pointer.x = FlxMath.bound(pointer.x, healthBar.x - (pointer.width / 3), (healthBar.x + healthBar.width) - (pointer.width / 2) - 2) - 2;
		}

		// Metadata scroll
		if (allowScroll)
		{
			if (metadata.x + metadata.width < timeBar.x)
				resetMetadata();
			else if (metadataScroll)
				metadata.x -= FramerateTools.easeConvert(1.25);

			metadata.clipRect.x = timeBar.x - metadata.x;
			metadata.clipRect = metadata.clipRect;
		}

		// Score stretch
		{
			if (score.frameWidth > 252)
				score.scale.x = 252 / score.frameWidth;
			else
				score.scale.x = 1;

			score.updateHitbox();
		}

		// Icon scale + winning/losing
		{
			var mult:Float = FlxMath.lerp(hudData.p1.scale, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
			iconP1.scale.set(mult, mult);
			iconP1.updateHitbox();

			var mult:Float = FlxMath.lerp(hudData.p2.scale, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
			iconP2.scale.set(mult, mult);
			iconP2.updateHitbox();

			var iconP1Check:HealthIcon = (playState.opponentPlay ? iconP2 : iconP1);
			var iconP2Check:HealthIcon = (playState.opponentPlay ? iconP1 : iconP2);
			var songAcc:Float = (!PlayState.isStoryMode ? playState.accuracy : PlayState.campaignAccuracy);
			var totplayed:Int = (PlayState.isStoryMode ? PlayState.campaignTotalPlayed : playState.totalPlayed);


			if (!playState.disableHealth && healthBar.percent < 20 || playState.disableHealth && totplayed > 0 && songAcc < 65)
			{
				if (iconP2Check.winningIndex != -1)
					iconP2Check.animation.curAnim.curFrame = (!playState.happyEnding ? iconP2Check.winningIndex : iconP2Check.losingIndex);
				if (iconP1Check.losingIndex != -1)
					iconP1Check.animation.curAnim.curFrame = iconP1Check.losingIndex;
			}
			else if (!playState.disableHealth && healthBar.percent > 80 || playState.disableHealth && totplayed > 0 && songAcc > 90)
			{
				if (iconP1Check.winningIndex != -1)
					iconP1Check.animation.curAnim.curFrame = iconP1Check.winningIndex;
				if (iconP2Check.losingIndex != -1)
					iconP2Check.animation.curAnim.curFrame = (playState.happyEnding ? iconP2Check.winningIndex : iconP2Check.losingIndex);
			}
			else
			{
				iconP1Check.animation.curAnim.curFrame = iconP1Check.neutralIndex;
				iconP2Check.animation.curAnim.curFrame = iconP2Check.neutralIndex;
			}

			switch (forceP1Frame.toLowerCase())
			{
				case 'happy':
					iconP1Check.animation.curAnim.curFrame = iconP1Check.winningIndex;
				case 'angry':
					iconP1Check.animation.curAnim.curFrame = iconP1Check.losingIndex;
				case 'neutral':
					iconP1Check.animation.curAnim.curFrame = iconP1Check.neutralIndex;
			}

			switch (forceP2Frame.toLowerCase())
			{
				case 'happy':
					iconP2Check.animation.curAnim.curFrame = iconP2Check.winningIndex;
				case 'angry':
					iconP2Check.animation.curAnim.curFrame = iconP2Check.losingIndex;
				case 'neutral':
					iconP2Check.animation.curAnim.curFrame = iconP2Check.neutralIndex;
			}
		}
	}

	public var beatFrequency:Int = 4;

	public function stepHit(step:Int):Void
	{
		if (step % beatFrequency == 0)
		{
			bg.animation.play('bump', true);
	
			iconP1.scale.set(hudData.p1.scaleMax, hudData.p1.scaleMax);
			iconP2.scale.set(hudData.p2.scaleMax, hudData.p2.scaleMax);
			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}
	}

	private function resetMetadata(fadeIn:Bool = true):Void
	{
		if (fadeIn && !allowScroll)
			return;

		if (fadeIn)
		{
			metadataScroll = false;
			metadata.x = hudData.metadata.position[0] + this.x;

			metadata.alpha = 0;
			FlxTween.tween(metadata, {alpha: this.alpha}, 0.25, {ease: FlxEase.linear, startDelay: 1});
		}

		new FlxTimer().start(fadeIn ? 4 : 3, function(tmr:FlxTimer)
		{
			metadataScroll = true;
		});
	}

	public function reloadHealth(p1:Character, p2:Character):Void
	{
		// Health Bar
		{
			if (!playState.opponentPlay)
			{
				healthBar.createImageBar(p2.healthImage, p1.healthImage,
					FlxColor.fromRGB(p2.healthColorArray[0], p2.healthColorArray[1], p2.healthColorArray[2]),
					FlxColor.fromRGB(p1.healthColorArray[0], p1.healthColorArray[1], p1.healthColorArray[2]));
			}
			else
			{
				healthBar.createImageBar(p1.healthImage, p2.healthImage,
					FlxColor.fromRGB(p1.healthColorArray[0], p1.healthColorArray[1], p1.healthColorArray[2]),
					FlxColor.fromRGB(p2.healthColorArray[0], p2.healthColorArray[1], p2.healthColorArray[2]));
			}
	
			healthBar.updateBar();
		}

		// Time Bar
		{
			timeBar.createGradientBar([FlxColor.BLACK], [FlxColor.fromRGB(p1.healthColorArray[0], p1.healthColorArray[1], p1.healthColorArray[2]),
				FlxColor.fromRGB(p2.healthColorArray[0], p2.healthColorArray[1], p2.healthColorArray[2])]);
	
			timeBar.updateBar();
		}
	}
}