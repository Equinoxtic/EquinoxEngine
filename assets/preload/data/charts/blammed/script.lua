function onUpdate(elapsed)
	local songPos = getPropertyFromClass('Conductor', 'songPosition')
	local curBpm = getPropertyFromClass('Conductor', 'bpm')
	local currentBeat = (songPos / 100) / (curBpm / 70)

	if (curStep >= 512 and curStep < 768) then
		doTweenX('hudX', 'camHUD', 0 - 2 * math.cos((currentBeat * 0.25) * math.pi), 0.1)
		doTweenY('hudY', 'camHUD', 0 - 4 * math.cos((currentBeat * 0.25) * math.pi), 0.1)
		doTweenAngle('hudAngle', 'camHUD', -1 * 1 * math.sin((currentBeat+1)+300), 0.1)
		doTweenX('gameX', 'camGame', 0 - 2 * math.cos((currentBeat * 0.25) * math.pi))
		doTweenY('gameY', 'camGame', 0 - 4 * math.cos((currentBeat * 0.25) * math.pi), 0.1)
		doTweenAngle('gameAngle', 'camGame', -1 * 1 * math.sin((currentBeat+1)+300), 0.1)
	end

	if (curStep == 768) then
		setProperty('camHUD.angle', 0)
		cancelTween('hudX') ; cancelTween('hudY') ; cancelTween('hudAngle')
		cancelTween('gameX') ; cancelTween('gameY') ; cancelTween('gameAngle')
	end
end
