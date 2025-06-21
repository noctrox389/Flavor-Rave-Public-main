package;

import Conductor.BPMChangeEvent;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxTimer;

class MusicBeatState extends FlxUIState
{
	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	private var controls(get, never):Controls;

	public static var camBeat:FlxCamera;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function remove(Object:FlxBasic, Splice:Bool = false):FlxBasic
	{
		if (Std.isOfType(Object, FlxUI))
			return null;
		MasterObjectLoader.removeObject(Object);
		return super.remove(Object, Splice);
	}

	override function add(Object:FlxBasic):FlxBasic
	{
		if (Std.isOfType(Object, FlxUI))
			return null;
		MasterObjectLoader.addObject(Object);
		return super.add(Object);
	}

	#if mobile
	var _virtualpad:FlxVirtualPad;
	var _hitbox:FlxHitbox;

	public function addHitbox(?keyCount:Int = 3) {
		_hitbox = new FlxHitbox(keyCount);

		var camMobile = new FlxCamera();
	    camMobile.bgColor.alpha = 0;
		FlxG.cameras.add(camMobile, false);

		_hitbox.cameras = [camMobile];
 		add(_hitbox);
	}

	public function addVirtualPad(?DPad:FlxDPadMode, ?Action:FlxActionMode) {
        _virtualpad = new FlxVirtualPad(DPad, Action);
		add(_virtualpad);
	}

    	public function addVirtualPadCamera() {
		var virtualpadcam = new FlxCamera();
		virtualpadcam.bgColor.alpha = 0;
		FlxG.cameras.add(virtualpadcam, false);
		_virtualpad.cameras = [virtualpadcam];
    	}

	public function removeVirtualPad() {
		remove(_virtualpad);
	}
	#end
	
	override function create() {
		camBeat = FlxG.camera;
		var skip:Bool = FlxTransitionableState.skipNextTransOut;
		var speed:Float = 0.5;
		switch (FRFadeTransition.type)
		{
			case 'synsun':
				speed = 1.5;
			case 'songTrans':
				speed = 0.5;
		}
		super.create();

		if(!skip) {
			openSubState(new FRFadeTransition(speed, true));
		}
		FlxTransitionableState.skipNextTransOut = false;
		FRFadeTransition.type = 'hueh';

		if(Main.fpsVar != null) {
			Main.fpsVar.resetPeak();
		}
	}

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if(curStep > 0)
				stepHit();

			if(PlayState.SONG != null)
			{
				if (oldStep < curStep)
					updateSection();
				else
					rollbackSection();
			}
		}

		super.update(elapsed);
	}

	override function destroy():Void
	{
		cancelTweens();
		super.destroy();
	}

	private function updateSection():Void
	{
		if(stepsToDo < 1) stepsToDo = Math.round(getBeatsOnSection() * 4);
		while(curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	private function rollbackSection():Void
	{
		if(curStep < 0) return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if(stepsToDo > curStep) break;
				
				curSection++;
			}
		}

		if(curSection > lastSection) sectionHit();
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

	public static function switchState(nextState:FlxState) {
		// Custom made Trans in
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		var speed:Float = 0.35;
		switch (FRFadeTransition.type)
		{
			case 'synsun':
				speed = 2;
			case 'songTrans':
				speed = 0.5;
		}
		if(!FlxTransitionableState.skipNextTransIn) {
			leState.openSubState(new FRFadeTransition(speed, false));
			if(nextState == FlxG.state) {
				FRFadeTransition.finishCallback = function() {
					FlxG.resetState();
				};
				//trace('resetted');
			} else {
				FRFadeTransition.finishCallback = function() {
					FlxG.switchState(nextState);
				};
				//trace('changed state');
			}
			return;
		}
		FlxTransitionableState.skipNextTransIn = false;
		FlxG.switchState(nextState);
	}

	public static function resetState() {
		MusicBeatState.switchState(FlxG.state);
	}

	public static function getState():MusicBeatState {
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		return leState;
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//trace('Beat: ' + curBeat);
	}

	public function sectionHit():Void
	{
		//trace('Section: ' + curSection + ', Beat: ' + curBeat + ', Step: ' + curStep);
	}

	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if(PlayState.SONG != null && PlayState.SONG.notes[curSection] != null) val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}
}
