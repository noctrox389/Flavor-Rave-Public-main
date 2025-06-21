package;

#if discord_rpc
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.events.KeyboardEvent;
import openfl.events.TextEvent;
import openfl.ui.Keyboard;


using StringTools;

class PasswordState extends MusicBeatState
{
	var currentPassword:String = "";

	var bg:FlxSprite;
	var screenEffect:FlxBackdrop;
	var fg:FlxSprite;

	var enterCodeSprite:FlxSprite;
	var inputField:FlxSprite;

	var passwordText:FlxText;

	var acceptedInputs:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

	var canExit:Bool = true;

	var resultText:FlxText;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		WeekData.setDirectoryFromWeek();

		#if discord_rpc
		// Updating Discord Rich Presence
		DiscordClient.changePresence("[Accessing Database...]", null);
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('dlc/bg'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		bg.screenCenter();

		enterCodeSprite = new FlxSprite(385, 200);
		enterCodeSprite.frames = Paths.getSparrowAtlas('dlc/code');
		enterCodeSprite.animation.addByPrefix('idle', 'code', 2, true);
		enterCodeSprite.animation.play('idle', true);
		add(enterCodeSprite);

		inputField = new FlxSprite().loadGraphic(Paths.image('dlc/box_selected'));
		inputField.screenCenter();
		add(inputField);

		passwordText = new FlxText(0, 0, inputField.width - 30, "LIKE I SAID, I'M PSYCHIC!", 64);
		passwordText.setFormat(Language.font.get('despair'), 64, 0xFAFFFFF, CENTER);
		passwordText.screenCenter();
		add(passwordText);

		resultText = new FlxText(0, inputField.y + inputField.height + 25, inputField.width + 100, "PLACEHOLDER TEXT", 48);
		resultText.setFormat(Language.font.get('despair'), 48, 0xFFFFFFFF, CENTER);
		resultText.alpha = 0;
		resultText.screenCenter(X);
		add(resultText);

		screenEffect = new FlxBackdrop(Paths.image('dlc/screen'), Y);
		screenEffect.velocity.y = 5;
		screenEffect.blend = "screen";
		add(screenEffect);
		screenEffect.screenCenter();

		fg = new FlxSprite().loadGraphic(Paths.image('dlc/border'));
		fg.antialiasing = ClientPrefs.globalAntialiasing;
		add(fg);
		fg.screenCenter();

		FlxG.sound.play(Paths.sound('scrollMenu'));

		FlxG.mouse.visible = true;

		#if mobile
		addVirtualPad(NONE,A_B);
		#end
		super.create();

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onAnyKeyDown);
		FlxG.stage.addEventListener(TextEvent.TEXT_INPUT, onTextInput);
		if (FlxG.sound.music != null) FlxG.sound.music.fadeOut(0.7, 0.03);
	}

	override function update(elapsed)
	{
		super.update(elapsed);
		 if (FlxG.mouse.justPressed)
		{
			var px = FlxG.mouse.x;
			var py = FlxG.mouse.y;
			if (px > inputField.x && px < inputField.x + inputField.width
			        && py > inputField.y && py < inputField.y + inputField.height)
			{
			        FlxG.stage.window.textInputEnabled = true;
			}
		}
		if (FlxG.keys.justPressed.BACKSPACE)
		{
			if (currentPassword.length > 0) currentPassword = currentPassword.substr(0, currentPassword.length - 1);
		}
		else if (canExit && (controls.BACK #if mobile || _virtualpad.buttonB.justPressed #end))
		{
			currentPassword = "";
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.mouse.visible = false;
			MusicBeatState.switchState(new MainMenuState());
		}
		else if (controls.ACCEPT #if mobile || _virtualpad.buttonA.justPressed #end)
		{
			if (resultText.alpha != 0) FlxG.sound.play(Paths.sound('cancelMenu'));
			else runPasswordCheck(currentPassword);
		}
		else if (FlxG.keys.firstJustPressed() != FlxKey.NONE && currentPassword.length <= 20)
		{
			var keyPressed:FlxKey = FlxG.keys.firstJustPressed();
			var keyName:String = Std.string(keyPressed);
			//trace("JUST PRESSED: " + keyName);
			switch(keyName)
			{
				case "ZERO" | "NUMPADZERO": currentPassword = currentPassword + 0;
				case "ONE" | "NUMPADONE": currentPassword = currentPassword + 1;
				case "TWO" | "NUMPADTWO": currentPassword = currentPassword + 2;
				case "THREE" | "NUMPADTHREE": currentPassword = currentPassword + 3;
				case "FOUR" | "NUMPADFOUR": currentPassword = currentPassword + 4;
				case "FIVE" | "NUMPADFIVE": currentPassword = currentPassword + 5;
				case "SIX" | "NUMPADSIX": currentPassword = currentPassword + 6;
				case "SEVEN" | "NUMPADSEVEN": currentPassword = currentPassword + 7;
				case "EIGHT" | "NUMPADEIGHT": currentPassword = currentPassword + 8;
				case "NINE" | "NUMPADNINE": currentPassword = currentPassword + 9;
				default:
					if(acceptedInputs.contains(keyName))
					{
						currentPassword = (currentPassword + keyName);
					}
			}
			currentPassword = currentPassword.toUpperCase();
		}

		passwordText.text = currentPassword;
	}

	private function onAnyKeyDown(e:KeyboardEvent):Void {
	  switch (e.keyCode) {
	    case Keyboard.ENTER:
	      FlxG.stage.window.textInputEnabled = false;
	      runPasswordCheck(currentPassword);
	      e.preventDefault();
	    case Keyboard.BACKSPACE:
	      if (currentPassword.length > 0) currentPassword = currentPassword.substr(0, currentPassword.length - 1);
	      e.preventDefault();
	    default:
	      // nothing
	  }
	}
	private function onTextInput(e:TextEvent):Void {
	  var char = e.text.toUpperCase();
	  if (currentPassword.length < 20 && acceptedInputs.indexOf(char) >= 0) {
	    currentPassword += char;
	  }
	  passwordText.text = currentPassword;
	}
	function runPasswordCheck(pass:String)
	{
		// Many secrets to discover...
		// All but one won't be given to you so easily...
		// Good luck finding the rest of them source code viewer.
		// Are you challenging me? - Hero
		switch(pass)
		{
			case "GOKU":
				FlxG.sound.play(Paths.sound('confirmMenu'));
				CoolUtil.browserLoad("https://www.youtube.com/watch?v=0MW9Nrg_kZU");
			case "MONIKA":
				FlxG.sound.play(Paths.sound('confirmMenu'));
				queueText("STILL THE BEST GIRL.");
			case "SOUR":
				FlxG.sound.play(Paths.sound('confirmMenu'));
				queueText("STILL TOPPING ENZYNC CITY CHARTS");
			case "SWEET":
				FlxG.sound.play(Paths.sound('confirmMenu'));
				queueText("'SHE HAS A LOT TO LEARN... AND OTHERS HAVE A LOT TO LEARN FROM HER'");
			case "SHOWMAN":
				FlxG.sound.play(Paths.sound('confirmMenu'));
				queueText("CLASSIFIED INFORMATION.");
			case "SAVORY":
				FlxG.sound.play(Paths.sound('confirmMenu'));
				queueText("'JUST WAIT UNTIL 'HE' FINDS OUT WHERE YOU'VE BEEN.'");
			case "UMAMI":
				FlxG.sound.play(Paths.sound('confirmMenu'));
				queueText("SOON TO-BE COLLEGE GRADUATE");
			case "SPICY":
				FlxG.sound.play(Paths.sound('confirmMenu'));
				queueText("CURRENTLY SEEKING ANSWERS TO HER NEW ABILITIES");
			case "SMOKY":
				FlxG.sound.play(Paths.sound('confirmMenu'));
				queueText("'...AN ETERNAL LONER.'");
			case "SUNDRIED":
				FlxG.sound.play(Paths.sound('confirmMenu'));
				queueText("'A REFRESHING INNOCENCE IN A HECTIC WORLD.'");
			case "RIKA":
				FlxG.sound.play(Paths.sound('confirmMenu'));
				queueText("'WON'T CATCH ME DEAD OR ALIVE'");
			case "NIKKU":
				FlxG.sound.play(Paths.sound('confirmMenu'));
				queueText("FURTHER RESEARCH REQUIRED");
			case "DAISY":
				FlxG.sound.play(Paths.sound('confirmMenu'));
				queueText("FURTHER RESEARCH REQUIRED");
			case "TORRENT":
				FlxG.sound.play(Paths.sound('confirmMenu'));
				queueText("[ANTI VIRUS HAS BLOCKED THIS REQUEST]");
			case "NITRO":
				FlxG.sound.play(Paths.sound('confirmMenu'));
				queueText("[ANTI VIRUS HAS BLOCKED THIS REQUEST]");
			case "TANGY":
				FlxG.sound.play(Paths.sound('confirmMenu'));
				queueText("LOCATION UNKNOWN SINCE 'THAT NIGHT'");
			case "SALTY":
				FlxG.sound.play(Paths.sound('confirmMenu'));
				queueText("CONSISTENTLY EVADING THE COAST GUARD");
			case "BITTER":
				FlxG.sound.play(Paths.sound('confirmMenu'));
				queueText("A GLASS HALF EMPTY, SPILLING FURTHER AND FURTHER.");
			case "ACE":
				FlxG.sound.play(Paths.sound('confirmMenu'));
				queueText("LET'S CHILL!");
			case "FUNKY":
				FlxG.sound.play(Paths.sound('confirmMenu'));
				queueText("[DATA SCRUBBED]");
			case "SAUCY":
				FlxG.sound.play(Paths.sound('confirmMenu'));
				queueText("[DATA SCRUBBED]");
			case "TBDTAN":
				FlxG.sound.play(Paths.sound('confirmMenu'));
				queueText("'GOTTA SCRUB THEIR DATA... I DON'T WANNA BREAK CANON...'");
			case "LIBITINA":
				FlxG.sound.play(Paths.sound('confirmMenu'));
				queueText("WRONG MOD");
			case "":
				FlxG.sound.play(Paths.sound('cancelMenu'));
				queueText("FIELD CANNOT BE EMPTY");
			default:
				FlxG.sound.play(Paths.sound('cancelMenu'));
				queueText("[NO DATA FOUND]");
		}

		currentPassword = "";
	}

	function queueText(text)
	{
		resultText.text = text;
		FlxTween.tween(resultText, {alpha: 1}, 1, {
			ease: FlxEase.sineInOut,
			onComplete: function(twn){
				FlxTween.tween(resultText, {alpha: 0}, 1, {
					ease:FlxEase.sineInOut,
					startDelay: 2
				});
			}
		});
	}
}

