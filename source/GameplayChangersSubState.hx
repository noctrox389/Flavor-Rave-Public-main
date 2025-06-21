package;

import Language.LanguageText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

using StringTools;

class GameplayChangersSubState extends MusicBeatSubstate
{
	var modifierData:Array<Array<Dynamic>> = [
		// internal, name, unlock, save, type, default, options
		['scrolltype', "Scroll Type", true, 'scrolltype', 'string', 'multiplicative', ["multiplicative", "constant"]],
		['scrollspeed', "Scroll Speed", true, 'scrollspeed', 'float', 1],
		['songspeed', "Playback Rate", true, 'songspeed', 'float', 1],
		['healthgain', "Health Gain", true, 'healthgain', 'float', 1],
		['healthloss', "Health Loss", true, 'healthloss', 'float', 1],
		['instakill', "Instakill on Miss", true, 'instakill', 'bool', false],
		['random', "Randomized Notes", true, 'random', 'bool', false],
		['mirror', "Mirrored Notes", true, 'mirror', 'bool', false],
		['practice', "Practice Mode", true, 'practice', 'bool', false],
		['botplay', "Botplay", true, 'botplay', 'bool', false]
	];

	var curSelected:Int = 0;
	var acceptInput:Bool = false;
	var menuBG:FlxSprite;
	var background:FlxSprite;

	var txtGrp:FlxTypedGroup<LanguageText> = new FlxTypedGroup<LanguageText>();

	public function new()
	{
		super();

		background = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		background.alpha = 0.001;
		FlxTween.tween(background, {alpha: 0.4}, 0.2);
		add(background);

		menuBG = new FlxSprite(0, 720).loadGraphic(Paths.image('freeplay/modifiersmenu'));
		menuBG.antialiasing = ClientPrefs.globalAntialiasing;
		FlxTween.tween(menuBG, {y: 0}, 0.25, {ease: FlxEase.quadOut});
		add(menuBG);

		for (i in 0...modifierData.length)
		{
			var modText:LanguageText = new LanguageText(280, 720, 714, Language.option.get('setting_' + modifierData[i][1], modifierData[i][1]), 26, 'krungthep');
			modText.setStyle(FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			modText.ID = i;
			txtGrp.add(modText);
			FlxTween.tween(modText, {y: 113 + (i * 36)}, 0.25, {ease: FlxEase.quadOut, startDelay: 0.05 + (i * 0.05)});
		}
		add(txtGrp);

		new FlxTimer().start(0.1, function(tmr:FlxTimer)
		{
			acceptInput = true;
		});

		#if mobile
		addVirtualPad(FULL,B_X);
		#end
		changeSelection();
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (acceptInput)
		{
			if (controls.BACK #if mobile || _virtualpad.buttonB.justPressed #end)
			{
			    	_virtualpad.visible = false;
				acceptInput = false;
				exitState();
			}

			if (controls.UI_UP_P #if mobile || _virtualpad.buttonUp.justPressed #end)
				changeSelection(-1);
			if (controls.UI_DOWN_P #if mobile || _virtualpad.buttonDown.justPressed #end)
				changeSelection(1);

			// LEFT, RIGHT
			if (FlxG.keys.pressed.SHIFT ? (controls.UI_LEFT #if mobile || _virtualpad.buttonLeft.pressed #end) : (controls.UI_LEFT_P #if mobile || _virtualpad.buttonLeft.justPressed #end))
				changeModifier(-1);
			if (FlxG.keys.pressed.SHIFT ? (controls.UI_RIGHT #if mobile || _virtualpad.buttonRight.pressed #end) : (controls.UI_RIGHT_P #if mobile || _virtualpad.buttonRight.justPressed #end))
				changeModifier(1);

			if (FlxG.keys.justPressed.R #if mobile || _virtualpad.buttonX.pressed #end)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				setValue(modifierData[curSelected][5]);
				updateText();
			}
		}
	}

	function exitState()
	{
		FlxTween.cancelTweensOf(menuBG);
		FlxTween.cancelTweensOf(background);
		for (item in txtGrp.members)
		{
			FlxTween.cancelTweensOf(item);
			FlxTween.tween(item, {y: 720}, 0.25, {ease: FlxEase.quadOut});
		}
		FlxTween.tween(menuBG, {y: 720}, 0.25, {ease: FlxEase.quadOut});
		FlxTween.tween(background, {alpha: 0}, 0.2);
		ClientPrefs.saveSettings();
		FlxG.sound.play(Paths.sound('cancelMenu'));

		new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			#if mobile
			closeSs();
			#else
			close();
                        #end
		});
	}

	function changeSelection(amt:Int = 0):Void
	{
		var prevSelected:Int = curSelected;
		curSelected += amt;

		if (prevSelected != curSelected)
			FlxG.sound.play(Paths.sound('scrollMenu'));

		if (curSelected >= modifierData.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = modifierData.length - 1;

		updateText();
	}

	function updateText():Void
	{
		txtGrp.forEach(function(txt:LanguageText)
		{
			txt.alpha = (txt.ID == curSelected) ? 1 : 0.4;

			var langText:String = Language.option.get('setting_' + modifierData[txt.ID][1], modifierData[txt.ID][1]);

			if (txt.ID == curSelected)
				txt.text = '> $langText: < ${displayValue(txt.ID)} >';
			else
				txt.text = '$langText: < ${displayValue(txt.ID)} >';
		});
	}

	function changeModifier(amt:Int = 0):Void
	{
		switch (modifierData[curSelected][4])
		{
			case 'bool':
			{
				setValue(!getValue());
			}
			case 'int':
			{
				var min:Int = 0;
				var max:Int = 1;

				switch (modifierData[curSelected][0])
				{
					case 'death':
					{
						max = 2;
					}
				}

				setValue(getValue() + amt);

				if (getValue() > max)
					setValue(min);
				if (getValue() < min)
					setValue(max);
			}
			case 'float':
			{
				var min:Float = 0;
				var max:Float = 1;
				var trueAmt:Float = amt;

				switch (modifierData[curSelected][0])
				{
					case 'scrollspeed':
					{
						min = 0.35;
						max = 3;
						trueAmt *= 0.05;
					}
					case 'songspeed':
					{
						min = 0.5;
						max = 3;
						trueAmt *= 0.05;
					}
					case 'healthloss' | 'healthgain':
					{
						min = 0.5;
						max = 5;
						trueAmt *= 0.1;
					}
				}

				setValue(getValue() + trueAmt);

				if (getValue() < min)
					setValue(min);
				if (getValue() > max)
					setValue(max); 
			}
			case 'string':
			{
				var options:Array<String> = modifierData[curSelected][6];
				var num:Int = options.indexOf(getValue()) + amt;

				if (num < 0)
					num = options.length - 1;
				else if (num >= options.length)
					num = 0;

				setValue(options[num]);
			}
		}

		if (!FlxG.keys.pressed.SHIFT)
			FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();
	}

	function onMouseOver(txt:LanguageText):Void
	{
		if (acceptInput && curSelected != txt.ID)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			curSelected = txt.ID;
			changeSelection();
		}
	}

	function onMouseDown(txt:LanguageText):Void
	{
		if (acceptInput && modifierData[curSelected][4] != 'float')
			changeModifier(1);
	}

	function setValue(value:Dynamic)
	{
		if (modifierData[curSelected][4] == 'float')
			value = FlxMath.roundDecimal(value, 2);

		ClientPrefs.gameplaySettings.set(modifierData[curSelected][3], value);
	}

	function getValue(ID:Null<Int> = null):Dynamic
	{
		if (ID == null)
			ID = curSelected;

		return ClientPrefs.gameplaySettings.get(modifierData[ID][3]);
	}

	function displayValue(ID:Int):String
	{
		var value:Dynamic = getValue(ID);
		var display:String = '';

		switch (modifierData[ID][0])
		{
			default:
			{
				if (modifierData[ID][4] == 'bool')
				{
					display = (value ? Language.gameplay.get('setting-on', "On") : Language.gameplay.get('setting-off', "Off")).toUpperCase();
				}
				else
				{
					display = Language.gameplay.get("setting_" + modifierData[ID][0] + '-$value', value);
				}
			}
			case 'scrolltype':
			{
				display = Language.gameplay.get("setting_" + modifierData[ID][0] + '-$value', value).toUpperCase();
			}
			case 'scrollspeed':
			{
				if (getValue(0) == "multiplicative")
					display = '${value}x';
				else
					display = value;
			}
			case 'songspeed' | 'healthgain' | 'healthloss':
			{
				display = '${value}x';
			}
		}

		return display;
	}
}
