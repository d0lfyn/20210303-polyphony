# generalised functions

define :calculateVelocity do |pSettingsVelocity|
	return (pSettingsVelocity[:base] + rrand(pSettingsVelocity[:rangeRandom][:low], pSettingsVelocity[:rangeRandom][:high]))
end

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

define :areAllVoicesFree? do |pVoiceType|
	getAllVoicesNumbersRange(pVoiceType).each do |n|
		return false if isVoiceActive?(pVoiceType, n)
	end

	return true
end

define :clearAllVoices do |pVoiceType|
	getAllVoicesNumbersRange(pVoiceType).each do |n|
		clearVoice(pVoiceType, n)
	end
end

define :clearVoice do |pVoiceType, pNumber|
	set("#{pVoiceType}/#{pNumber.to_s}", nil)
end

define :countVoicesActive do |pVoiceType|
	count = 0
	getAllVoicesNumbersRange(pVoiceType).each do |n|
		count += 1 if isVoiceActive?(pVoiceType, n)
	end

	return count
end

define :generateVoice do |pVoiceType, pVoiceNumber|
	in_thread(name: "#{pVoiceType}#{pVoiceNumber.to_s}".to_sym, sync_bpm: "time/measure") do
		if isVoiceActive?(pVoiceType, pVoiceNumber)
			logOptional("#{pVoiceType} #{pVoiceNumber.to_s} playing #{getVoiceSynthesis(pVoiceType, pVoiceNumber).to_s}")

			send("perform#{pVoiceType.capitalize}Synthesis", pVoiceNumber)
			clearVoice(pVoiceType, pVoiceNumber)

			logOptional("#{pVoiceType} #{pVoiceNumber.to_s} done")
		end
	end
end

define :getAllActiveSyntheses do
	allSyntheses = []
	get("settings/voices")[:selection].each do |voiceType|
		allSyntheses += getAllActiveVoicesSyntheses(voiceType)
	end

	return allSyntheses.freeze
end

define :getAllActiveVoicesSyntheses do |pVoiceType|
	allActiveSyntheses = []
	getAllVoicesNumbersRange(pVoiceType).each do |n|
		synthesis = getVoiceSynthesis(pVoiceType, n)
		allActiveSyntheses.push(synthesis) unless synthesis.nil?
	end

	return allActiveSyntheses.freeze
end

define :getAllSyntheses do
	allSyntheses = []
	get("settings/voices")[:selection].each do |voiceType|
		allSyntheses += getAllVoicesSyntheses(voiceType)
	end

	return allSyntheses.freeze
end

define :getAllVoicesNumbersArray do |pVoiceType|
	return makeRangeArrayFromZero(get("settings/voices/#{pVoiceType}")[:performance][:ensemble].length)
end

define :getAllVoicesNumbersRange do |pVoiceType|
	return (0...get("settings/voices/#{pVoiceType}")[:performance][:ensemble].length).freeze
end

define :getAllVoicesSyntheses do |pVoiceType|
	allSyntheses = []
	getAllVoicesNumbersRange(pVoiceType).each do |n|
		allSyntheses.push(getVoiceSynthesis(pVoiceType, n))
	end

	return allSyntheses.freeze
end

define :getVoiceInstrument do |pVoiceType, pNumber|
	return get("settings/voices/#{pVoiceType}")[:performance][:ensemble][pNumber]
end

define :getVoiceSynthesis do |pVoiceType, pNumber|
	return get("#{pVoiceType}/#{pNumber.to_s}")
end

define :initialiseVoices do
	get("settings/voices")[:selection].each do |voiceType|
		clearAllVoices(voiceType)
	end
end

define :isVoiceActive? do |pVoiceType, pNumber|
	return !getVoiceSynthesis(pVoiceType, pNumber).nil?
end

define :isVoiceFree? do |pVoiceType, pNumber|
	return getVoiceSynthesis(pVoiceType, pNumber).nil?
end

define :launchCCArticulated do |pVoiceNumber, pInstrument|
	in_thread(name: "articulated#{pVoiceNumber.to_s}CC".to_sym) do
		scc = get("settings/voices/articulated")[:performance][:ccMIDI]

		ccValue = scc[:base]
		windUpCC(ccValue, pInstrument)
		while isVoiceActive?("articulated".freeze, pVoiceNumber)
			height = rand(scc[:maxHeight])
			numMeasures = getIntInRangePair(scc[:rangeNumMeasuresInPeriod])
			numSubunits = get("settings/metronome")[:numSubunits]
			periodUnits = dice(numMeasures * get("settings/metronome")[:numUnitsPerMeasure])
			periodSubunits = (periodUnits * numSubunits)
			(0...periodUnits).each do |u|
				(0...numSubunits).each do |su|
					setCC(pInstrument, ((height * (-Math.cos(((u * numSubunits) + su) * 2 * Math::PI / periodSubunits) + 1) / 2) + scc[:base]))
					sync_bpm("time/subunit")
				end
				break if isVoiceFree?("articulated".freeze, pVoiceNumber)
			end
			sync_bpm("time/subunit") # double-check ended
		end
		windDownCC(ccValue, pInstrument)
	end
end

define :launchCCSustained do |pVoiceNumber, pInstrument, pNumMeasures|
	in_thread(name: "sustained#{pVoiceNumber.to_s}CC".to_sym) do
		scc = get("settings/voices/sustained")[:performance][:ccMIDI]

		ccValue = scc[:base]
		windUpCC(ccValue, pInstrument)
		while isVoiceActive?("sustained".freeze, pVoiceNumber)
			height = rand(scc[:maxHeight])
			numSubunits = get("settings/metronome")[:numSubunits]
			periodUnits = (dice(pNumMeasures) * get("settings/metronome")[:numUnitsPerMeasure])
			periodSubunits = (periodUnits * numSubunits)
			(0...periodUnits).each do |u|
				(0...numSubunits).each do |su|
					ccValue = ((height * (-Math.cos(((u * numSubunits) + su) * 2 * Math::PI / periodSubunits) + 1) / 2) + scc[:base])
					setCC(pInstrument, ccValue)
					sync_bpm("time/subunit")
				end
				break if isVoiceFree?("sustained".freeze, pVoiceNumber)
			end
			sync_bpm("time/subunit") # double-check ended
		end
		windDownCC(ccValue, pInstrument)
	end
end

define :performArticulated do |pPitch, pDuration, pVelocityOn, pVelocityOff|
	in_thread do
		midi_note_on(pPitch, vel_f: pVelocityOn)
		waitNumUnitsQuantised(pDuration)
		midi_note_off(pPitch, vel_f: pVelocityOff)
	end
end

define :performArticulatedSynthesis do |pVoiceNumber|
	instrument = getVoiceInstrument("articulated".freeze, pVoiceNumber)
	svap = get("settings/voices/articulated")[:performance]
	synthesis = getVoiceSynthesis("articulated".freeze, pVoiceNumber)

	with_midi_defaults(port: selectPort(pVoiceNumber, svap[:midiPorts]), channel: selectChannel(pVoiceNumber)) do
		sync_bpm("time/subunit") # 4
		sync_bpm("time/subunit") # 0
		launchCCArticulated(pVoiceNumber, instrument)
		while evalChance?(svap[:chanceContinue])
			compositeRhythm = getCompositeRhythm(getIntInRangePair(svap[:rangeNumRhythms]), svap[:rangeNumRhythmicDivisions], get("settings/metronome")[:numUnitsPerMeasure])
			compositeRhythmSpans = convertOffsetsToSpans(compositeRhythm, get("settings/metronome")[:numUnitsPerMeasure])
			hypothesis = synthesis[:hypotheses].choose
			while evalChance?(svap[:chanceRepeat])
				spaceDomain = getCurrentSpaceDomain()
				compositeRhythmSpans.each do |span|
					if ((span >= svap[:legatoSpanThreshold]) && evalChance?(svap[:chanceLegato]))
						performLegatoHypothesisForSpan(synthesis[:position], hypothesis, span, spaceDomain, instrument)
					else
						performShortMidHypothesisForSpan(synthesis[:position], hypothesis, span, spaceDomain, instrument)
					end
				end

				synthesis = getVoiceSynthesis("articulated".freeze, pVoiceNumber)
				break if synthesis.nil?
			end
			unless synthesis.nil?
				hypothesis = synthesis[:hypotheses].choose
				spaceDomain = getCurrentSpaceDomain()
				span = get("settings/metronome")[:numUnitsPerMeasure]
				if evalChance?(svap[:chanceLegato])
					performLegatoHypothesisForSpan(synthesis[:position], hypothesis, span, spaceDomain, instrument)
				else
					performShortMidHypothesisForSpan(synthesis[:position], hypothesis, span, spaceDomain, instrument)
				end
			else
				break
			end
		end
		unless synthesis.nil?
			hypothesis = synthesis[:hypotheses].choose
			spaceDomain = getCurrentSpaceDomain()
			span = get("settings/metronome")[:numUnitsPerMeasure]
			if evalChance?(svap[:chanceLegato])
				performLegatoHypothesisForSpan(synthesis[:position], hypothesis, span, spaceDomain, instrument)
			else
				performShortMidHypothesisForSpan(synthesis[:position], hypothesis, span, spaceDomain, instrument)
			end
		end
	end
end

define :performLegatoHypothesisForSpan do |pPosition, pHypothesis, pSpan, pSpaceDomain, pInstrument|
	svapl = get("settings/voices/articulated")[:performance][:legatoMIDI]

	isOnFirstUnit = true
	keyswitch = pInstrument[:LEGATO_SWITCHES].choose
	unitsLeft = pSpan

	sync_bpm("time/subunit")
	switchKeyswitchOn(keyswitch)
	(0...pHypothesis.length).each do |i|
		chronomorph = pHypothesis[i]
		nextChronomorph = pHypothesis[i + 1]

		duration = getMin(chronomorph[:span], unitsLeft)
		unitsLeft -= duration

		pitch = nil
		pitch = calculatePitch((chronomorph[:displacement] + pPosition), pSpaceDomain) unless chronomorph[:displacement].nil?

		velocityOff = calculateVelocity(svapl[:velocityOff])
		velocityOn = calculateVelocity(svapl[:velocityOn])
		velocityOn += svapl[:velocityOn][:accent] if isOnFirstUnit

		sync_bpm("time/subunit") unless isOnFirstUnit
		sync_bpm("time/subunit")
		if ((unitsLeft > 0) && (nextChronomorph[:displacement] != chronomorph[:displacement]))
			performArticulated(pitch, (duration + 1), velocityOn, velocityOff)
		else
			performArticulated(pitch, duration, velocityOn, velocityOff)
		end
		waitNumUnitsQuantised(duration)

		isOnFirstUnit = false
		break if unitsLeft.zero?
	end
	switchKeyswitchOff(keyswitch)
end

define :performShortMidHypothesisForSpan do |pPosition, pHypothesis, pSpan, pSpaceDomain, pInstrument|
	svaps = get("settings/voices/articulated")[:performance][:shortMidMIDI]

	isOnFirstUnit = true
	unitsLeft = pSpan
	(0...pHypothesis.length).each do |i|
		chronomorph = pHypothesis[i]

		duration = getMin(chronomorph[:span], unitsLeft)
		unitsLeft -= duration

		keyswitch = selectShortMidKeyswitch(pInstrument, duration, svaps[:durationMid])

		pitch = nil
		pitch = calculatePitch((chronomorph[:displacement] + pPosition), pSpaceDomain) unless chronomorph[:displacement].nil?

		velocityOff = calculateVelocity(svaps[:velocityOff])
		velocityOn = calculateVelocity(svaps[:velocityOn])
		velocityOn += svaps[:velocityOn][:accent] if isOnFirstUnit

		sync_bpm("time/subunit")
		switchKeyswitchOn(keyswitch)
		sync_bpm("time/subunit")
		performArticulated(pitch, duration, velocityOn, velocityOff)
		waitNumUnitsQuantised(duration)
		switchKeyswitchOff(keyswitch)

		isOnFirstUnit = false
		break if unitsLeft.zero?
	end
end

define :performSustainedSynthesis do |pVoiceNumber|
	svsp = get("settings/voices/sustained")[:performance]

	instrument = getVoiceInstrument("sustained".freeze, pVoiceNumber)
	keyswitch = instrument[:LONG_SWITCHES].choose

	numMeasuresRemaining = getIntInRangePair(svsp[:rangeNumMeasuresToSustain])

	startingChordRoot = get("space/chordRoot")
	stableChordRoot = startingChordRoot
	startingKey = get("space/key")

	synthesis = getVoiceSynthesis("sustained".freeze, pVoiceNumber)
	pitch = calculatePitch(synthesis[:position], getCurrentSpaceDomain())

	with_midi_defaults(port: selectPort(pVoiceNumber, svsp[:midiPorts]), channel: selectChannel(pVoiceNumber)) do
		sync_bpm("time/subunit") # 4
		sync_bpm("time/subunit") # 0
		launchCCSustained(pVoiceNumber, instrument, numMeasuresRemaining)

		sync_bpm("time/subunit")
		switchKeyswitchOn(keyswitch)

		sync_bpm("time/subunit")
		midi_note_on(pitch, vel_f: calculateVelocity(get("settings/voices/sustained")[:performance][:longMIDI][:velocityOn]))
		sync_bpm("time/measure")
		numMeasuresRemaining -= 1
		while ((get("space/key") == startingKey) && (numMeasuresRemaining > 0))
			currentChordRoot = get("space/chordRoot")
			unless (currentChordRoot == stableChordRoot)
				if isPositionInGeneralChord?(synthesis[:position], currentChordRoot, getCurrentTonicity(), get("settings/composition")[:generalPositionsOfChord])
					stableChordRoot = currentChordRoot
				else
					numMeasuresRemaining = 0
				end
			end
			sync_bpm("time/measure")
			numMeasuresRemaining -= 1
		end
		midi_note_off(pitch, vel_f: calculateVelocity(get("settings/voices/sustained")[:performance][:longMIDI][:velocityOff]))

		switchKeyswitchOff(keyswitch)
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

define :selectChannel do |pVoiceNumber|
  return ((pVoiceNumber % get("settings/voices")[:numChannelsPerPort]) + 1)
end

define :selectShortMidKeyswitch do |pInstrument, pDuration, pDurationMid|
  if (pDuration < pDurationMid)
    return pInstrument[:SHORT_SWITCHES].choose
  else
    return pInstrument[:MID_SWITCHES].choose
  end
end

define :selectPort do |pVoiceNumber, pPorts|
  return pPorts[(pVoiceNumber / get("settings/voices")[:numChannelsPerPort]).to_i]
end

define :setAllVoicesSyntheses do |pVoiceType, pSyntheses|
	getAllVoicesNumbersRange(pVoiceType).each do |n|
		setVoiceSynthesis(pVoiceType, n, pSyntheses[n])
	end
end

define :setVoiceSynthesis do |pVoiceType, pNumber, pSynthesis|
	set("#{pVoiceType}/#{pNumber.to_s}", pSynthesis)
end

define :setCC do |pInstrument, pCCValue|
  for ccn in pInstrument[:CC_NUMS]
    midi_cc(ccn, val_f: pCCValue)
  end
end

define :signalAllActivePortsOff do
	get("settings/voices")[:selection].each do |voiceType|
    get("settings/voices/#{voiceType}")[:performance][:midiPorts].each do |port|
      midi_all_notes_off(port: port)
    end
  end
end

define :switchKeyswitchOff do |pKeyswitch|
	midi_note_off pKeyswitch, vel_f: 1
end

define :switchKeyswitchOn do |pKeyswitch|
	midi_note_on pKeyswitch, vel_f: 0.01
end

define :windDownCC do |pCCValue, pInstrument|
	numSubunits = (get("settings/metronome")[:numUnitsPerMeasure] * get("settings/metronome")[:numSubunits] / 2)
	(0...numSubunits).each do |su|
		setCC(pInstrument, (pCCValue / (1 + Math.exp(-(numSubunits - su)))))
		sync_bpm("time/subunit")
	end
end

define :windUpCC do |pBase, pInstrument|
	numSubunits = (get("settings/metronome")[:numUnitsPerMeasure] * get("settings/metronome")[:numSubunits] / 2)
	(0...numSubunits).each do |su|
		setCC(pInstrument, (pBase / (1 + Math.exp(-su))))
		sync_bpm("time/subunit")
	end
end
