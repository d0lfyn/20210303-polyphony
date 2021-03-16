# generalised functions

define :calculateAmp do |pSettingsAmp|
	return (pSettingsAmp[:base] + rrand(pSettingsAmp[:rangeRandom][:low], pSettingsAmp[:rangeRandom][:high]))
end

# specialised functions

define :performSPiArticulated do |pPitch, pDuration, pAmp|
	in_thread do
		play(pPitch, amp: pAmp, attack: 0.05, sustain: 0, release: pDuration)
		waitNumUnitsQuantised(pDuration)
	end
end

define :performSPiArticulatedSynthesis do |pVoiceNumber|
	instrument = getVoiceSPiInstrument("articulated".freeze, pVoiceNumber)
	svap = get("settings/voices/articulated")[:performance]
	synthesis = getVoiceSynthesis("articulated".freeze, pVoiceNumber)

	with_synth(instrument[:SYNTH]) do
		sync_bpm("time/subunit") # 4
		sync_bpm("time/subunit") # 0
		while evalChance?(svap[:chanceContinue])
			compositeRhythm = getCompositeRhythm(getIntInRangePair(svap[:rangeNumRhythms]), svap[:rangeNumRhythmicDivisions], get("settings/metronome")[:numUnitsPerMeasure])
			compositeRhythmSpans = convertOffsetsToSpans(compositeRhythm, get("settings/metronome")[:numUnitsPerMeasure])
			hypothesis = synthesis[:hypotheses].choose
			while evalChance?(svap[:chanceRepeat])
				spaceDomain = getCurrentSpaceDomain()
				compositeRhythmSpans.each do |span|
					performSPiShortMidHypothesisForSpan(synthesis[:position], hypothesis, span, spaceDomain, instrument)
				end

				synthesis = getVoiceSynthesis("articulated".freeze, pVoiceNumber)
				break if synthesis.nil?
			end
			unless synthesis.nil?
				hypothesis = synthesis[:hypotheses].choose
				spaceDomain = getCurrentSpaceDomain()
				span = get("settings/metronome")[:numUnitsPerMeasure]
				performSPiShortMidHypothesisForSpan(synthesis[:position], hypothesis, span, spaceDomain, instrument)
			else
				break
			end
		end
		unless synthesis.nil?
			hypothesis = synthesis[:hypotheses].choose
			spaceDomain = getCurrentSpaceDomain()
			span = get("settings/metronome")[:numUnitsPerMeasure]
			performSPiShortMidHypothesisForSpan(synthesis[:position], hypothesis, span, spaceDomain, instrument)
		end
	end
end

define :performSPiShortMidHypothesisForSpan do |pPosition, pHypothesis, pSpan, pSpaceDomain, pInstrument|
	svaps = get("settings/voices/articulated")[:performance][:spi][:shortMid]

	isOnFirstUnit = true
	unitsLeft = pSpan
	(0...pHypothesis.length).each do |i|
		chronomorph = pHypothesis[i]

		duration = getMin(chronomorph[:span], unitsLeft)
		unitsLeft -= duration

		pitch = nil
		pitch = calculatePitch((chronomorph[:displacement] + pPosition), pSpaceDomain) unless chronomorph[:displacement].nil?

		amp = calculateAmp(svaps[:amp])

		sync_bpm("time/subunit")
		sync_bpm("time/subunit")
		performSPiArticulated(pitch, duration, amp)
		waitNumUnitsQuantised(duration)

		isOnFirstUnit = false
		break if unitsLeft.zero?
	end
end

define :performSPiSustainedSynthesis do |pVoiceNumber|
	svsp = get("settings/voices/sustained")[:performance]

	instrument = getVoiceSPiInstrument("sustained".freeze, pVoiceNumber)

	numMeasuresRemaining = getIntInRangePair(svsp[:rangeNumMeasuresToSustain])
	numUnits = (numMeasuresRemaining * get("settings/metronome")[:numUnitsPerMeasure])

	startingChordRoot = get("space/chordRoot")
	stableChordRoot = startingChordRoot
	startingKey = get("space/key")

	synthesis = getVoiceSynthesis("sustained".freeze, pVoiceNumber)
	pitch = calculatePitch(synthesis[:position], getCurrentSpaceDomain())

	with_synth(instrument[:SYNTH]) do
		sync_bpm("time/subunit") # 4
		sync_bpm("time/subunit") # 0

		sync_bpm("time/subunit") # coordinate with MIDI

		sync_bpm("time/subunit") # coordinate with MIDI
		in_thread do
			play(pitch, amp: calculateAmp(svsp[:spi][:long][:amp]), attack: (numUnits * 0.1), sustain: 0, release: (numUnits * 0.9))
		end
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
	end
end