# generalised functions

define :calculateVelocity do |pSettingsVelocity|
  return (pSettingsVelocity[:base] + rrand(pSettingsVelocity[:rangeRandom][:low], pSettingsVelocity[:rangeRandom][:high]))
end

# specialised functions

define :launchCCArticulated do |pVoiceNumber, pInstrument|
  in_thread(name: "articulated#{pVoiceNumber.to_s}CC".to_sym) do
    scc = get("settings/voices/articulated")[:performance][:midi][:cc]

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
    scc = get("settings/voices/sustained")[:performance][:midi][:cc]

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

define :performMIDIArticulated do |pPitch, pDuration, pVelocityOn, pVelocityOff|
  in_thread do
    midi_note_on(pPitch, vel_f: pVelocityOn)
    waitNumUnitsQuantised(pDuration)
    midi_note_off(pPitch, vel_f: pVelocityOff)
  end
end

define :performMIDIArticulatedConclusion do |pSynthesis, pInstrument|
  hypothesis = pSynthesis[:hypotheses].choose
  spaceDomain = getCurrentSpaceDomain()
  span = get("settings/metronome")[:numUnitsPerMeasure]
  if evalChance?(get("settings/voices/articulated")[:performance][:midi][:chanceLegato])
    performMIDILegatoHypothesisForSpan(pSynthesis[:position], hypothesis, span, spaceDomain, pInstrument)
  else
    performMIDIShortMidHypothesisForSpan(pSynthesis[:position], hypothesis, span, spaceDomain, pInstrument)
  end
end

define :performMIDIArticulatedSynthesis do |pVoiceNumber|
  instrument = getVoiceInstrument("articulated".freeze, pVoiceNumber)
  svap = get("settings/voices/articulated")[:performance]
  synthesis = getVoiceSynthesis("articulated".freeze, pVoiceNumber)

  with_midi_defaults(port: selectPort(pVoiceNumber, svap[:midi][:ports]), channel: selectChannel(pVoiceNumber)) do
    sync_bpm("time/subunit") # 4
    sync_bpm("time/subunit") # 0
    launchCCArticulated(pVoiceNumber, instrument) unless instrument[:CC_NUMS].empty?
    while evalChance?(svap[:chanceContinue])
      compositeRhythm = getCompositeRhythm(getIntInRangePair(svap[:rangeNumRhythms]), svap[:rangeNumRhythmicDivisions], get("settings/metronome")[:numUnitsPerMeasure])
      compositeRhythmSpans = convertOffsetsToSpans(compositeRhythm, get("settings/metronome")[:numUnitsPerMeasure])
      hypothesis = synthesis[:hypotheses].choose
      while evalChance?(svap[:chanceRepeat])
        spaceDomain = getCurrentSpaceDomain()
        compositeRhythmSpans.each do |span|
          if ((span >= svap[:midi][:legatoSpanThreshold]) && evalChance?(svap[:midi][:chanceLegato]))
            performMIDILegatoHypothesisForSpan(synthesis[:position], hypothesis, span, spaceDomain, instrument)
          else
            performMIDIShortMidHypothesisForSpan(synthesis[:position], hypothesis, span, spaceDomain, instrument)
          end
        end
        synthesis = getVoiceSynthesis("articulated".freeze, pVoiceNumber)
        break if synthesis.nil?
      end
      unless synthesis.nil?
        performMIDIArticulatedConclusion(synthesis, instrument)
      else
        break
      end
    end
    unless synthesis.nil?
      performMIDIArticulatedConclusion(synthesis, instrument)
    end
  end
end

define :performMIDILegatoHypothesisForSpan do |pPosition, pHypothesis, pSpan, pSpaceDomain, pInstrument|
  svapl = get("settings/voices/articulated")[:performance][:midi][:legato]

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
      performMIDIArticulated(pitch, (duration + 1), velocityOn, velocityOff)
    else
      performMIDIArticulated(pitch, duration, velocityOn, velocityOff)
    end
    waitNumUnitsQuantised(duration)

    isOnFirstUnit = false
    break if unitsLeft.zero?
  end
  switchKeyswitchOff(keyswitch)
end

define :performMIDIShortMidHypothesisForSpan do |pPosition, pHypothesis, pSpan, pSpaceDomain, pInstrument|
  svaps = get("settings/voices/articulated")[:performance][:midi][:shortMid]

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
    performMIDIArticulated(pitch, duration, velocityOn, velocityOff)
    waitNumUnitsQuantised(duration)
    switchKeyswitchOff(keyswitch)

    isOnFirstUnit = false
    break if unitsLeft.zero?
  end
end

define :performMIDISustainedSynthesis do |pVoiceNumber|
  svsp = get("settings/voices/sustained")[:performance]

  instrument = getVoiceInstrument("sustained".freeze, pVoiceNumber)
  keyswitch = instrument[:LONG_SWITCHES].choose

  numMeasuresRemaining = getIntInRangePair(svsp[:rangeNumMeasuresToSustain])

  startingChordRoot = get("space/chordRoot")
  stableChordRoot = startingChordRoot
  startingKey = get("space/key")

  synthesis = getVoiceSynthesis("sustained".freeze, pVoiceNumber)
  pitch = calculatePitch(synthesis[:position], getCurrentSpaceDomain())

  with_midi_defaults(port: selectPort(pVoiceNumber, svsp[:midi][:ports]), channel: selectChannel(pVoiceNumber)) do
    sync_bpm("time/subunit") # 4
    sync_bpm("time/subunit") # 0
    launchCCSustained(pVoiceNumber, instrument, numMeasuresRemaining) unless instrument[:CC_NUMS].empty?

    sync_bpm("time/subunit")
    switchKeyswitchOn(keyswitch)

    sync_bpm("time/subunit")
    midi_note_on(pitch, vel_f: calculateVelocity(svsp[:midi][:long][:velocityOn]))
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
    midi_note_off(pitch, vel_f: calculateVelocity(svsp[:midi][:long][:velocityOff]))

    switchKeyswitchOff(keyswitch)
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

define :setCC do |pInstrument, pCCValue|
  for ccn in pInstrument[:CC_NUMS]
    midi_cc(ccn, val_f: pCCValue)
  end
end

define :signalAllActivePortsOff do
  get("settings/voices")[:selection].each do |voiceType|
    get("settings/voices/#{voiceType}")[:performance][:midi][:ports].each do |port|
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
