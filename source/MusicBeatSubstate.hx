package;

import Conductor.BPMChangeEvent;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.tweens.FlxTween;
import flixel.addons.transition.FlxTransitionableState;

class MusicBeatSubstate extends FlxSubState
{
	public function new()
	{
		super();
	}

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();


		super.update(elapsed);
	}

	#if mobile
 	var _virtualpad:FlxVirtualPad;
 
 	public function addVirtualPad(?DPad:FlxDPadMode, ?Action:FlxActionMode) {
 		_virtualpad = new FlxVirtualPad(DPad, Action);
 		add(_virtualpad);
 	}
 
     	public function addVirtualPadCamera() {
 		var virtualpadcam = new flixel.FlxCamera();
 		virtualpadcam.bgColor.alpha = 0;
 		FlxG.cameras.add(virtualpadcam, false);
 		_virtualpad.cameras = [virtualpadcam];
     	}
 
 	public function removeVirtualPad() {
 		remove(_virtualpad);
 	}
 	public function closeSs() {
 		FlxTransitionableState.skipNextTransOut = true;
 		FlxG.resetState();
 	}
 	#end

	override function destroy():Void
	{
		cancelTweens();
		super.destroy();
	}

	private function cancelTweens():Void
	{
		for (member in members)
		{
			if (member != null) FlxTween.cancelTweensOf(member);
		}
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep/4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - ClientPrefs.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}
}
