function onUpdate(elapsed)

	adddddddddds = 6.27

	if downscroll then
		adddddddddds = 1.27
	end

	songPos = getSongPosition()
	local currentBeat = (songPos/4000)*(curBpm/60)
	if curStep == 0 then
  		noteTweenY('defaultFPlayerStrumY0', 0, 720, 0.0000001)
		noteTweenY('defaultFPlayerStrumY1', 1, 720, 0.0000001)
		noteTweenY('defaultFPlayerStrumY2', 2, 720, 0.0000001)
		noteTweenY('defaultFPlayerStrumY3', 3, 720, 0.0000001)
		noteTweenX('defaultFPlayerStrumX0', 0, -720, 0.0000001)
		noteTweenX('defaultFPlayerStrumX1', 1, -720, 0.0000001)
		noteTweenX('defaultFPlayerStrumX2', 2, -720, 0.0000001)
		noteTweenX('defaultFPlayerStrumX3', 3, -720, 0.0000001)


		noteTweenX('halfbf0', 4, defaultPlayerStrumX0-defaultOpponentStrumY0/1.8, 0.0000001)
		noteTweenX('halfbf1', 5, defaultPlayerStrumX1-defaultOpponentStrumY1/1.8, 0.0000001)
		noteTweenX('halfbf2', 6, defaultPlayerStrumX2-defaultOpponentStrumY2/1.8, 0.0000001)
		noteTweenX('halfbf3', 7, defaultPlayerStrumX3-defaultOpponentStrumY3/1.8, 0.0000001)
	end

	if curStep >= 64 then

		noteTweenX(defaultPlayerStrumX0, 4, defaultPlayerStrumX0 - 716 + ((screenWidth / 2.62) - (157 / 2)) + (math.sin((songPos/400)) * 260), 0.011)
		noteTweenX(defaultPlayerStrumX1, 5, defaultPlayerStrumX1 - 722 + ((screenWidth / 2.62) - (157 / 2)) + (math.sin((songPos/400)) * 149), 0.008)
		noteTweenX(defaultPlayerStrumX2, 6, defaultPlayerStrumX2 - 712 + ((screenWidth / 2.62) - (157 / 2)) + (math.sin((songPos/400)) * 175), 0.001)
		noteTweenX(defaultPlayerStrumX3, 7, defaultPlayerStrumX3 - 706 + ((screenWidth / 2.62) - (157 / 2)) + (math.sin((songPos/400)) * 260), 0.009)
		
		noteTweenY('defaultPlayerStrumY0', 4, ((screenHeight / adddddddddds)) + (math.cos((songPos/367) + 0) * 40), 0.001)
		noteTweenY('defaultPlayerStrumY1', 5, ((screenHeight / adddddddddds)) + (math.cos((songPos/579) + 1) * 40), 0.001)
		noteTweenY('defaultPlayerStrumY2', 6, ((screenHeight / adddddddddds)) + (math.cos((songPos/452) + 2) * 40), 0.001)
		noteTweenY('defaultPlayerStrumY3', 7, ((screenHeight / adddddddddds)) + (math.cos((songPos/415) + 3) * 40), 0.001)
	end

end