# specialised functions

define :activateVoices do |pVoiceType|
	numVoicesToAdd = 0
  numVoicesToAdd = getIntInRangePair(get("settings/voices/#{pVoiceType}")[:rangeNumToAddPerMeasure]) if evalChance?(get("settings/voices/#{pVoiceType}")[:chanceAddVoices])
  numVoicesActive = countVoicesActive(pVoiceType)
	numVoicesToAdd += 1 if (numVoicesActive.zero? && numVoicesToAdd.zero?)
	numVoicesRemaining = (get("settings/voices/#{pVoiceType}")[:maxNumVoicesActive] - numVoicesActive)
	numVoicesToAdd = getMin(numVoicesToAdd, numVoicesRemaining)

	unless numVoicesToAdd.zero?
		getAllVoicesNumbersArray(pVoiceType).shuffle.each do |vn|
			if (isVoiceFree?(pVoiceType, vn) && send("prepare#{pVoiceType.capitalize}Synthesis?", vn))
				generateVoice(pVoiceType, vn)
				numVoicesToAdd -= 1
				break if numVoicesToAdd.zero?
			end
		end
	end
end

define :generateVoice do |pVoiceType, pVoiceNumber|
	in_thread(name: "#{pVoiceType}#{pVoiceNumber.to_s}".to_sym, sync_bpm: "time/measure") do
		if isVoiceActive?(pVoiceType, pVoiceNumber)
			logOptional("#{pVoiceType} #{pVoiceNumber.to_s} playing #{getVoiceSynthesis(pVoiceType, pVoiceNumber).to_s}")

			if get("settings/voices/#{pVoiceType}")[:performance][:ensemble][pVoiceNumber].has_key?(:SYNTH)
				send("performSPi#{pVoiceType.capitalize}Synthesis", pVoiceNumber)
			else
				send("performMIDI#{pVoiceType.capitalize}Synthesis", pVoiceNumber)
			end
			clearVoice(pVoiceType, pVoiceNumber)

			logOptional("#{pVoiceType} #{pVoiceNumber.to_s} done")
		end
	end
end

define :initialiseVoices do
	get("settings/voices")[:selection].each do |voiceType|
		clearAllVoices(voiceType)
	end
end

define :prepareArticulatedSynthesis? do |pVoiceNumber|
	hypotheses = makeRangeArrayFromZero(getIntInRangePair(get("settings/ideation")[:rangeNumMotifsToIdeate])).map { |i| ideate() }
	synthesis = arrangeArticulatedVoice(pVoiceNumber, hypotheses) if evalChance?(get("settings/composition")[:chanceCompose])
	synthesis = improviseArticulatedVoice(pVoiceNumber) if (synthesis.nil? && evalChance?(get("settings/composition")[:chanceImprovise]))

	unless synthesis.nil?
		setVoiceSynthesis("articulated".freeze, pVoiceNumber, synthesis)

		logOptional("articulated #{pVoiceNumber.to_s} preparing to play #{synthesis.to_s}")

		return true
	else
		logOptional("no room for articulated #{pVoiceNumber.to_s}")

		return false
	end
end

define :prepareSustainedSynthesis? do |pVoiceNumber|
	hypothesis = [getInfinitumMotif()].freeze
	synthesis = arrangeSustainedVoice(pVoiceNumber, hypothesis)

	unless synthesis.nil?
		setVoiceSynthesis("sustained".freeze, pVoiceNumber, synthesis)

		logOptional("sustained #{pVoiceNumber.to_s} preparing to play")

		return true
	else
		logOptional("no room for sustained #{pVoiceNumber.to_s}")

		return false
	end
end
