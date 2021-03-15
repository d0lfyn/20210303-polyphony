# generalised functions

define :arePositionsDissonant? do |pPosition0, pPosition1, pSpaceDomain, pSpecificDissonances|
	absoluteInterval = (calculatePitch(pPosition1, pSpaceDomain) - calculatePitch(pPosition0, pSpaceDomain)).abs

	return pSpecificDissonances.any? { |d| (d == absoluteInterval) }
end

define :arePositionsProximate? do |pPosition0, pPosition1, pSpaceDomain, pProximityLimit|
	frequencyDifference = (midi_to_hz(calculatePitch(pPosition1, pSpaceDomain)) - midi_to_hz(calculatePitch(pPosition0, pSpaceDomain))).abs

	return (frequencyDifference <= pProximityLimit)
end

define :calculateModulationToChordRoot do |pSpaceDomain, pChordRoot|
  newTonic = ((calculatePitch(pChordRoot, pSpaceDomain) % 12))
  newThird =  ((calculatePitch((pChordRoot + 2), pSpaceDomain) % 12))
  newFifth =  ((calculatePitch((pChordRoot + 4), pSpaceDomain) % 12))

  if (((newThird - newTonic) == 4) || ((newTonic - newThird) == 8))
    return makeKey(newTonic, [:ionian, :lydian, :mixolydian].choose)
  else
    if (((newFifth - newTonic) == 6) || ((newTonic - newFifth) == 6))
      return makeKey(newTonic, :locrian)
    else
			return makeKey(newTonic, [:dorian, :phrygian, :aeolian].choose)
    end
  end
end

define :calculatePitch do |pPosition, pSpaceDomain|
  return pPosition.nil? ? nil : pSpaceDomain[pPosition]
end

define :getPositionAtOrAbovePitch do |pPitch, pSpaceDomain|
  position = (pSpaceDomain.index { |p| (p > pPitch) })
  if position.nil?
    return nil
  elsif position.zero?
    return 0
  elsif (pSpaceDomain[position - 1] < pPitch)
    return position
  else
    return (position - 1)
  end
end

define :getPositionAtOrBelowPitch do |pPitch, pSpaceDomain|
  spaceDomainReverse = pSpaceDomain.reverse
  position = (spaceDomainReverse.index { |p| (p < pPitch) })
  if position.nil?
    return nil
  elsif position.zero?
    return (pSpaceDomain.length - 1)
  elsif (spaceDomainReverse[position - 1] > pPitch)
    return ((pSpaceDomain.length - 1) - position)
  else
    return ((pSpaceDomain.length - 1) - (position - 1))
  end
end

define :getPositionInGeneralChord do |pPosition, pChordRoot, pTonicity|
	return (((pPosition - pChordRoot) + pTonicity) % pTonicity)
end

define :getSpaceDomain do |pKey, pNumOctaves|
	return scale(pKey[:tonic], pKey[:scale], num_octaves: pNumOctaves)
end

define :isPositionAGeneralRoot? do |pPosition, pChordRoot, pTonicity|
	return (getPositionInGeneralChord(pPosition, pChordRoot, pTonicity) == 0)
end

define :isPositionInGeneralChord? do |pPosition, pChordRoot, pTonicity, pGeneralPositionsOfChord|
	return pGeneralPositionsOfChord.any? { |gpc| (gpc == getPositionInGeneralChord(pPosition, pChordRoot, pTonicity)) }
end

define :makeKey do |pTonic, pScale|
	return {
		tonic: pTonic,
		scale: pScale,
	}.freeze
end

define :modulatePositionToKey do |pPosition, pOriginalKey, pNewKey|
	if (pOriginalKey == pNewKey)
		return pPosition
	else
		originalSpaceDomain = getSpaceDomain(pOriginalKey, get("settings/space")[:numOctaves])
		pitch = calculatePitch(pPosition, originalSpaceDomain)
		newSpaceDomain = getSpaceDomain(pNewKey, get("settings/space")[:numOctaves])
		if (pitch >= newSpaceDomain.first)
			return getPositionAtOrBelowPitch(pitch, newSpaceDomain)
		else
			return getPositionAtOrAbovePitch(pitch, newSpaceDomain)
		end
	end
end

# specialised functions

define :activateSpace do
	if evalChance?(get("settings/space")[:chanceProgress])
		startingKey = get("space/key")

		if (!get("space/chordRoot").zero? && evalChance?(get("settings/space")[:chanceReturnToRoot]))
			returnToRoot()
		else
			progress()
			modulate() if (!get("space/chordRoot").zero? && evalChance?(get("settings/space")[:chanceModulate]))
		end

		recompose(startingKey)
	end
end

define :getCurrentScale do
	return get("space/key")[:scale]
end

define :getCurrentSpaceDomain do
	return getSpaceDomain(get("space/key"), get("settings/space")[:numOctaves])
end

define :getCurrentTonicity do
	return (scale(:C0, getCurrentScale()).length - 1)
end

define :modulate do
	newKey = calculateModulationToChordRoot(getCurrentSpaceDomain(), get("space/chordRoot"))
	set("space/key", newKey)
	set("space/chordRoot", 0)

	logOptional("modulating to #{newKey.to_s}")
end

define :progress do
	tonicity = getCurrentTonicity()
	progressionsAvailable = get("settings/space")[:progressions].nil? ? makeRangeArrayFromZero(tonicity) : get("settings/space")[:progressions]
	nextChordRoot = ((get("space/chordRoot") + progressionsAvailable.choose) % tonicity)
	set("space/chordRoot", nextChordRoot)

	logOptional("progressing to #{get("space/chordRoot")}: #{note_info(calculatePitch(get("space/chordRoot"), getCurrentSpaceDomain())).to_s}")
end

define :returnToRoot do
	set("space/chordRoot", 0)

	logOptional("returning to 0: #{note_info(calculatePitch(0, getCurrentSpaceDomain())).to_s}")
end
