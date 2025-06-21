local dancetime = false;
local slowgroove = false;

function onCreate()

	posX = -705;
	posY = -360;
	scale = 1;
	
	makeLuaSprite('dramablack', '', -100, -100);
    makeGraphic('dramablack', 1280*2, 720*2, '000000');
    setScrollFactor('dramablack', 0, 0);
    screenCenter('dramablack');
    addLuaSprite('dramablack', true);
	
	makeLuaSprite('introlight', 'open-mic/neonlight', posX, posY);
	setScrollFactor('introlight', 1, 1);
	scaleObject('introlight', 1, 1);
	setProperty('introlight.alpha', 0.0001);
	addLuaSprite('introlight', true);
	
	makeAnimatedLuaSprite('daisy1', 'open-mic/DaisyIntro', 400, 700);
	addAnimationByPrefix('daisy1', 'idle', 'Daisy Puppet', 24, false);
	setScrollFactor('daisy1', 0, 0);
	scaleObject('daisy1', 1.2, 1.2);
	addLuaSprite('daisy1', true);
	setProperty('daisy1.alpha', 0.0001);

	makeAnimatedLuaSprite('boo', 'open-mic/Boo', 300, 580);
	addAnimationByPrefix('boo', 'idle', 'Boo_Idle', 24, false);
	setScrollFactor('boo', 0, 0);
	scaleObject('boo', 1.4, 1.4);
	addLuaSprite('boo', true);
	setProperty('boo.alpha', 0.0001);

	makeAnimatedLuaSprite('biggsbuggs', 'open-mic/BiggsBuggs', -300, 560);
	addAnimationByPrefix('biggsbuggs', 'idle', 'BiggsBuggs', 24, false);
	setScrollFactor('biggsbuggs', 0, 0);
	scaleObject('biggsbuggs', 1.4, 1.4);
	addLuaSprite('biggsbuggs', true);
	setProperty('biggsbuggs.alpha', 0.0001);
	
	makeAnimatedLuaSprite('daisy2', 'open-mic/DaisyIntro2', 900, 360);
	addAnimationByPrefix('daisy2', 'idle', 'DaisyAppear', 24, false);
	setScrollFactor('daisy2', 0, 0);
	scaleObject('daisy2', 1.2, 1.2);
	addLuaSprite('daisy2', true);
	setProperty('daisy2.alpha', 0.0001);

	makeAnimatedLuaSprite('bordersweet', 'closeup/sweetborder', 0, 0);
	addAnimationByPrefix('bordersweet', 'idle', 'SweetBorder', 30, true);
	playAnim('bordersweet', 'idle');
	setScrollFactor('bordersweet', 0, 0);
    screenCenter('bordersweet');
	addLuaSprite('bordersweet', false);
	setObjectCamera('bordersweet', 'effect');
	setProperty('bordersweet.alpha', 0.0001);

	setProperty('isCameraOnForcedPos', true);
	setProperty('camFollow.x', 750);
	setProperty('camFollow.y', 150);
	
end

function thingie(num)
	num = tonumber(num)
	if num == 20 then
		playAnim('daisy1', 'idle');
		setProperty('daisy1.alpha', 1);
	end
	if num == 21 then
		playAnim('daisy1', 'idle');
		doTweenY('daisy1', 'daisy1', 200, 0.3, "quadout");
	end
	if num == 42 then
		setProperty('introlight.alpha', 1);
	end
	if num == 43 then
		setProperty('introlight.alpha', 0.0001);
	end
	if num == 44 then
		setProperty('introlight.alpha', 1);
	end
	if num == 45 then
		setProperty('introlight.alpha', 0.0001);
	end
	if num == 49 then
		setProperty('introlight.alpha', 1);
	end
	if num == 50 then
		setProperty('introlight.alpha', 0.0001);
	end
	if num == 51 then
		setProperty('introlight.alpha', 1);
	end
	if num == 52 then
		playAnim('daisy2', 'idle');
		setProperty('daisy2.alpha', 1);
		setProperty('introlight.alpha', 0.0001);
	end
	if num == 53 then
		setProperty('introlight.alpha', 1);
	end
	if num == 64 then
		setProperty('camFollow.y', 200);
		setProperty('introlight.alpha', 0.0001);
		setProperty('dramablack.alpha', 0.0001);
		setProperty('daisy1.alpha', 0.0001);
		setProperty('daisy2.alpha', 0.0001);
	end
	if num == 96 then
		setProperty('isCameraOnForcedPos', false);
	end
	if num == 516 then
		doTweenAlpha('bordersweet', 'bordersweet', 1, 3.4);
		slowgroove = true;
	end
	if num == 768 then
		doTweenAlpha('bordersweet', 'bordersweet', 0.0001, 3.4);
		slowgroove = false;
	end
	if num == 1008 then
		setProperty('isCameraOnForcedPos', true);
		setProperty('camFollow.x', 770);
		setProperty('camFollow.y', 270);
	end
	if num == 1023 then
		setProperty('bordersweet.alpha', 1);
		dancetime = true;
	end
	if num == 1035 then
		doTweenAlpha('boo', 'boo', 1, 2);
	end
	if num == 1045 then
		doTweenAlpha('biggsbuggs', 'biggsbuggs', 1, 2);
	end
	if num == 1280 then
		dancetime = false;
		doTweenAlpha('bordersweet', 'bordersweet', 0.0001, 3.4);
	end
end

function onBeatHit()
	if curBeat % 2 == 0 then
		playAnim('biggsbuggs', 'idle');
		playAnim('boo', 'idle');
	end
	if curBeat % 2 == 0 then
		playAnim('tbone', 'idle');
		playAnim('sour', 'idle');
	end
	if curBeat % 2 == 0 and slowgroove then
		if danced then
			danced = false;
			playAnim('tbone', 'danceLeft');
			playAnim('sour', 'danceLeft');
		else
			danced = true;
			playAnim('tbone', 'danceRight');
			playAnim('sour', 'danceRight');
		end
	end
	if curBeat % 1 == 0 and dancetime then
		if danced then
			danced = false;
			playAnim('tbone', 'danceLeft');
			playAnim('sour', 'danceLeft');
		else
			danced = true;
			playAnim('tbone', 'danceRight');
			playAnim('sour', 'danceRight');
		end
	end
end