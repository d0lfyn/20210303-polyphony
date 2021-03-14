# generalised functions

define :convertOffsetsToSpans do |pOffsets, pNumUnits|
	offsets = pOffsets + [pNumUnits]
	spans = []
	(0...(offsets.length - 1)).each do |i|
		spans.push(offsets[i + 1] - offsets[i])
	end

	return spans.freeze
end

define :divideUnitsRhythmically do |pNumUnits, pWeightForSpans|
	numRhythmicDivisions = chooseAbsIntWithWeight(-pWeightForSpans, (1..pNumUnits).to_a)
	offsets = getTrueIndices(spread(numRhythmicDivisions, pNumUnits, rotate: rand_i(numRhythmicDivisions)))
	divisions = convertOffsetsToSpans(offsets, pNumUnits)

	return divisions.freeze
end

define :getCompositeRhythm do |pNumRhythms, pNumRhythmicDivisionsRangePair, pNumUnitsPerMeasure|
	compositeRhythm = []
	pNumRhythms.times do
		numRhythmicDivisions = getIntInRangePair(pNumRhythmicDivisionsRangePair)
		compositeRhythm = compositeRhythm.union(getTrueIndices(spread(numRhythmicDivisions, pNumUnitsPerMeasure, rotate: rand_i(numRhythmicDivisions))))
	end

	return compositeRhythm.sort.freeze
end

define :mergeBriefStart do |pDivisions|
	unless (pDivisions.first == 1)
		return pDivisions
	else
		divisions = pDivisions.drop(1)
		divisions[0] = (pDivisions[0] + pDivisions[1])

		return divisions.freeze
	end
end
