# generalised functions

define :areAnySynthesesOnRoot? do |pSyntheses, pChordRoot, pTonicity|
	return pSyntheses.any? { |s| isPositionAGeneralRoot?(s[:position], pChordRoot, pTonicity) }
end

define :createBoundSynthesis do |pPosition, pBounds, pSettingsIdeation, pSettingsMetronome, pSettingsCreation|
	hypotheses = makeRangeArrayFromZero(getIntInRangePair(pSettingsIdeation[:rangeNumMotifsToIdeate])).map { |i| createBoundMotif(pBounds, pSettingsMetronome[:numUnitsPerMeasure], pSettingsCreation) }

	unless hypotheses.nil?
		return makeSynthesis(pPosition, hypotheses)
	else
		return nil
	end
end

define :eliminateOverlap do |pPositionsAvailable, pAllActiveSyntheses|
	allPositionsCovered = getAllPositionsCoveredBySyntheses(pAllActiveSyntheses)
	positionsLeft = (pPositionsAvailable - allPositionsCovered).freeze

	return positionsLeft.freeze
end

define :eliminateOverlapWithHypotheses do |pPositionsAvailable, pHypotheses, pAllActiveSyntheses|
	allPositionsCovered = getAllPositionsCoveredBySyntheses(pAllActiveSyntheses)
	positionsLeft = (pPositionsAvailable - allPositionsCovered).freeze
	rangeArraysLeft = getRangeArraysInAscendingArray(positionsLeft)
	rangeArraysLeft = rangeArraysLeft.map { |ra| eliminateUnreachablePositions(ra, pHypotheses) }.freeze

	return rangeArraysLeft.flatten.freeze
end

define :eliminateOverlapExceptEdges do |pPositionsAvailable, pAllActiveSyntheses|
	allPositionsCovered = getAllInnerPositionsCoveredBySyntheses(pAllActiveSyntheses)
	positionsLeft = (pPositionsAvailable - allPositionsCovered).freeze

	return positionsLeft
end

define :eliminateOverlapExceptEdgesWithHypotheses do |pPositionsAvailable, pHypotheses, pAllActiveSyntheses|
	allPositionsCovered = getAllInnerPositionsCoveredBySyntheses(pAllActiveSyntheses)
	positionsLeft = (pPositionsAvailable - allPositionsCovered).freeze
	rangeArraysLeft = getRangeArraysInAscendingArray(positionsLeft)
	rangeArraysLeft = rangeArraysLeft.map { |ra| eliminateUnreachablePositions(ra, pHypotheses) }.freeze

	return rangeArraysLeft.flatten.freeze
end

define :eliminateOverlapExceptSpaces do |pPositionsAvailable, pAllActiveSyntheses|
	positionsUnclaimed = (pPositionsAvailable - getAllSyntheticPositions(pAllActiveSyntheses)).freeze

	return positionsUnclaimed
end

define :eliminateOverlapExceptSpacesWithHypotheses do |pPositionsAvailable, pHypotheses, pAllActiveSyntheses|
	allPositionsCovered = getAllPositionsCoveredBySyntheses(pAllActiveSyntheses)
	positionsUncovered = (pPositionsAvailable - allPositionsCovered).freeze

	positionsUnclaimed = (pPositionsAvailable - getAllSyntheticPositions(pAllActiveSyntheses)).freeze
	rangeArraysUnclaimed = getRangeArraysInAscendingArray(positionsUnclaimed)
	rangeArraysUnclaimed = rangeArraysUnclaimed.map { |ra| eliminateUnreachablePositions(ra, pHypotheses) }.freeze
	positionsUnclaimed = rangeArraysUnclaimed.flatten.freeze

	return positionsUncovered.intersection(positionsUnclaimed).freeze
end

define :eliminateUnreachablePositions do |pPositionsAvailable, pHypotheses|
	allMotifsPeak = getAllMotifsPeak(pHypotheses)
	allMotifsTrough = getAllMotifsTrough(pHypotheses)
	positionsLeft = ((-allMotifsTrough < pPositionsAvailable.length) ? pPositionsAvailable.drop(-allMotifsTrough) : []).freeze
	positionsLeft = ((allMotifsPeak < positionsLeft.length) ? positionsLeft.take((positionsLeft.length - allMotifsPeak)) : []).freeze

	return positionsLeft
end

define :fillGapInSyntheses do |pAllActiveSyntheses, pSpaceDomain, pTonicity, pInstrumentSpaceDomainRangePair, pChordRoot, pSettingsSynthesis, pSettingsIdeation, pSettingsMetronome, pSettingsCreation|
	spaceAvailable = makeArrayOfIntsFromRangePair(pInstrumentSpaceDomainRangePair)
	spaceAvailable = removeSyntheticPositions(spaceAvailable, pAllActiveSyntheses, pSettingsSynthesis)
	spaceRangeArrays = getRangeArraysInAscendingArray(spaceAvailable)

	positionsAvailable = eliminateOverlap(spaceAvailable, pAllActiveSyntheses)
	positionsAvailable = removeProximatePositions(positionsAvailable, pAllActiveSyntheses, pSpaceDomain, pSettingsSynthesis)
	positionsAvailable = removeNonChordPositions(positionsAvailable, pChordRoot, pTonicity, pSettingsSynthesis)
	positionsAvailable = removeNonRootPositions(positionsAvailable, pChordRoot, pTonicity) unless areAnySynthesesOnRoot?(pAllActiveSyntheses, pChordRoot, pTonicity)
	positionsAvailable = removeDissonantPositions(positionsAvailable, pAllActiveSyntheses, pSpaceDomain, pSettingsSynthesis)

	if positionsAvailable.empty?
		return nil
	else
		positionChosen = positionsAvailable.choose
		spaceRangeChosen = spaceRangeArrays[spaceRangeArrays.index { |sra| sra.include?(positionChosen) }]
		spaceRangePair = makeRangePair((spaceRangeChosen.first - positionChosen), (spaceRangeChosen.last - positionChosen))

		return createBoundSynthesis(positionChosen, spaceRangePair, pSettingsIdeation, pSettingsMetronome, pSettingsCreation)
	end
end

define :getAllInnerPositionsCoveredBySyntheses do |pSyntheses|
	return pSyntheses.map { |s| getInnerPositionsCoveredBySynthesis(s) }.flatten.freeze
end

define :getAllPositionsCoveredBySyntheses do |pSyntheses|
	return pSyntheses.map { |s| getPositionsCoveredBySynthesis(s) }.flatten.freeze
end

define :getAllPositionsFittingHypotheses do |pHypotheses, pAllActiveSyntheses, pSpaceDomain, pTonicity, pInstrumentSpaceDomainRangePair, pChordRoot, pSettingsSynthesis|
	positionsAvailable = makeArrayOfIntsFromRangePair(pInstrumentSpaceDomainRangePair)
	positionsAvailable = removePreliminaryPositions(positionsAvailable, pHypotheses, pAllActiveSyntheses, pSettingsSynthesis)
	positionsAvailable = removeProximatePositions(positionsAvailable, pAllActiveSyntheses, pSpaceDomain, pSettingsSynthesis)
	positionsAvailable = removeNonChordPositions(positionsAvailable, pChordRoot, pTonicity, pSettingsSynthesis)
	positionsAvailable = removeNonRootPositions(positionsAvailable, pChordRoot, pTonicity) unless areAnySynthesesOnRoot?(pAllActiveSyntheses, pChordRoot, pTonicity)
	positionsAvailable = removeDissonantPositions(positionsAvailable, pAllActiveSyntheses, pSpaceDomain, pSettingsSynthesis)

	return positionsAvailable
end

define :getAllSyntheticPositions do |pAllActiveSyntheses|
	return pAllActiveSyntheses.map { |s| s[:position] }.freeze
end

define :getInnerPositionsCoveredBySynthesis do |pSynthesis|
	return ((getSynthesisTrough(pSynthesis) + 1)...getSynthesisPeak(pSynthesis)).to_a
end

define :getPositionsCoveredBySynthesis do |pSynthesis|
	return (getSynthesisTrough(pSynthesis)..getSynthesisPeak(pSynthesis)).to_a
end

define :getSynthesisPeak do |pSynthesis|
	return (getAllMotifsPeak(pSynthesis[:hypotheses]) + pSynthesis[:position])
end

define :getSynthesisTrough do |pSynthesis|
	return (getAllMotifsTrough(pSynthesis[:hypotheses]) + pSynthesis[:position])
end

define :makeSynthesis do |pPosition, pHypotheses|
	assert_not pPosition.nil?
	assert_not pHypotheses.nil?

	return {
		position: pPosition,
		hypotheses: pHypotheses,
	}.freeze
end

define :removeDissonantPositions do |pPositionsAvailable, pAllActiveSyntheses, pSpaceDomain, pSettingsSynthesis|
	return pPositionsAvailable.reject { |p| pAllActiveSyntheses.any? { |s| arePositionsDissonant?(s[:position], p, pSpaceDomain, pSettingsSynthesis[:specificDissonances]) } }.freeze
end

define :removeNonChordPositions do |pPositionsAvailable, pChordRoot, pTonicity, pSettingsSynthesis|
	return pPositionsAvailable.select { |p| isPositionInGeneralChord?(p, pChordRoot, pTonicity, pSettingsSynthesis[:generalPositionsOfChord]) }.freeze
end

define :removeNonRootPositions do |pPositionsAvailable, pChordRoot, pTonicity|
	return pPositionsAvailable.select { |p| isPositionAGeneralRoot?(p, pChordRoot, pTonicity) }.freeze
end

define :removePreliminaryPositions do |pPositionsAvailable, pHypotheses, pAllActiveSyntheses, pSettingsSynthesis|
	case pSettingsSynthesis[:degreeOfOverlap]
	when 0
		return eliminateOverlapWithHypotheses(pPositionsAvailable, pHypotheses, pAllActiveSyntheses)
	when 1
		return eliminateOverlapExceptEdgesWithHypotheses(pPositionsAvailable, pHypotheses, pAllActiveSyntheses)
	when 2
		return eliminateOverlapExceptSpacesWithHypotheses(pPositionsAvailable, pHypotheses, pAllActiveSyntheses)
	when 3
		return eliminateUnreachablePositions(pPositionsAvailable, pHypotheses)
	end
end

define :removeProximatePositions do |pPositionsAvailable, pAllActiveSyntheses, pSpaceDomain, pSettingsSynthesis|
	return pPositionsAvailable.reject { |p| pAllActiveSyntheses.any? { |s| arePositionsProximate?(s[:position], p, pSpaceDomain, pSettingsSynthesis[:proximityLimit]) } }.freeze
end

define :removeSyntheticPositions do |pPositionsAvailable, pAllActiveSyntheses, pSettingsSynthesis|
	case pSettingsSynthesis[:degreeOfOverlap]
	when 0
		return eliminateOverlap(pPositionsAvailable, pAllActiveSyntheses)
	when 1
		return eliminateOverlapExceptEdges(pPositionsAvailable, pAllActiveSyntheses)
	when 2
		return eliminateOverlapExceptSpaces(pPositionsAvailable, pAllActiveSyntheses)
	when 3
		return pPositionsAvailable
	end
end

# specialised functions

define :arrangeArticulatedVoice do |pVoiceNumber, pHypotheses|
	spaceDomain = getCurrentSpaceDomain()
	allActiveSyntheses = getAllActiveSyntheses()
	instrumentSpaceDomainRangePair = getInstrumentSpaceDomainRangePair(getVoiceInstrument("articulated".freeze, pVoiceNumber), spaceDomain)

	positionsAvailable = getAllPositionsFittingHypotheses(pHypotheses, allActiveSyntheses, spaceDomain, getCurrentTonicity(), instrumentSpaceDomainRangePair, get("space/chordRoot"), get("settings/composition"))
	position = positionsAvailable.choose

	unless position.nil?
		return makeSynthesis(position, pHypotheses) unless position.nil?
	else
		return nil
	end
end

define :arrangeSustainedVoice do |pVoiceNumber, pHypotheses|
	spaceDomain = getCurrentSpaceDomain()
	allActiveSyntheses = getAllActiveSyntheses()
	instrumentSpaceDomainRangePair = getInstrumentSpaceDomainRangePair(getVoiceInstrument("sustained".freeze, pVoiceNumber), spaceDomain)

	positionsAvailable = getAllPositionsFittingHypotheses(pHypotheses, allActiveSyntheses, spaceDomain, getCurrentTonicity(), instrumentSpaceDomainRangePair, get("space/chordRoot"), get("settings/composition"))
	position = positionsAvailable.choose

	unless position.nil?
		return makeSynthesis(position, pHypotheses) unless position.nil?
	else
		return nil
	end
end

define :improviseArticulatedVoice do |pVoiceNumber|
	spaceDomain = getCurrentSpaceDomain()
	allActiveSyntheses = getAllActiveSyntheses()
	instrumentSpaceDomainRangePair = getInstrumentSpaceDomainRangePair(getVoiceInstrument("articulated".freeze, pVoiceNumber), spaceDomain)

	synthesis = fillGapInSyntheses(allActiveSyntheses, spaceDomain, getCurrentTonicity(), instrumentSpaceDomainRangePair, get("space/chordRoot"), get("settings/composition"), get("settings/ideation"), get("settings/metronome"), get("settings/ideation/creation"))

	return synthesis
end

define :rearrangeArticulatedVoices do |pOriginalKey|
	spaceDomain = getCurrentSpaceDomain()
	tonicity = getCurrentTonicity()
	allArticulatedSyntheses = getAllVoicesSyntheses("articulated".freeze)
	allNewArticulatedSyntheses = Array.new(allArticulatedSyntheses.length, nil)
	addedSyntheses = []

	makeRangeArrayFromZero(allArticulatedSyntheses.length).shuffle.each do |i|
		unless allArticulatedSyntheses[i].nil?
			instrumentSpaceDomainRangePair = getInstrumentSpaceDomainRangePair(getVoiceInstrument("articulated".freeze, i), spaceDomain)

			oldPosition = allArticulatedSyntheses[i][:position]
			oldPosition = modulatePositionToKey(oldPosition, pOriginalKey, get("space/key"))
			hypotheses = allArticulatedSyntheses[i][:hypotheses]

			newPositionsAvailable = getAllPositionsFittingHypotheses(hypotheses, addedSyntheses, spaceDomain, tonicity, instrumentSpaceDomainRangePair, get("space/chordRoot"), get("settings/composition"))
			newPositionIntervalsAvailable = newPositionsAvailable.map { |np| (np - oldPosition) }.freeze
			newPositionIntervalsAvailable = newPositionIntervalsAvailable.reject { |npi| (npi.abs > get("settings/space")[:maxPositionInterval]) }.freeze
			newPosition = (oldPosition + chooseAbsIntWithWeight(get("settings/space")[:weightForPositionIntervals], newPositionIntervalsAvailable)) unless newPositionIntervalsAvailable.empty?

			unless newPosition.nil?
				newSynthesis = makeSynthesis(newPosition, hypotheses)
				allNewArticulatedSyntheses[i] = newSynthesis
				addedSyntheses.push(newSynthesis)
			end

			puts("articulated #{i.to_s} switching from #{oldPosition.to_s} to #{newPosition.to_s}") if get("settings/general")[:shouldLogOptional]
		end
	end

	setAllVoicesSyntheses("articulated".freeze, allNewArticulatedSyntheses)
end

define :recompose do |pOriginalKey|
	rearrangeArticulatedVoices(pOriginalKey)
end
