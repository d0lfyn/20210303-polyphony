# generalised functions

# chronomorphs

define :areAllChronomorphsFeatureless? do |pChronomorphs|
  return pChronomorphs.all? { |c| isChronomorphFeatureless?(c) }
end

define :createInitialChronomorph do |pSpan, pSettingsCreation|
  return makeChronomorph((evalChance?(pSettingsCreation[:chanceCreateNilFeature]) ? nil : 0), pSpan)
end

define :createNextBoundChronomorph do |pChronomorphs, pBounds, pSpan, pSettingsCreation|
  if areAllChronomorphsFeatureless?(pChronomorphs)
    return createInitialChronomorph(pSpan, pSettingsCreation)
  end

  previousDisplacement = getLastFeatureOfChronomorphs(pChronomorphs)
  displacementIntervals = makeArrayOfIntsFromRangePair(makeMirrorRangePair(pSettingsCreation[:displacementIntervalLimit]))
  displacementIntervals = filterDisplacementIntervalsForCompatibility(displacementIntervals, pChronomorphs, pBounds, pSettingsCreation)
  if evalChance?(pSettingsCreation[:chanceCreateNoConsecutivelyRepeatedDisplacements])
    displacementIntervals -= [0]
  end

  if (displacementIntervals.empty? || evalChance?(pSettingsCreation[:chanceCreateNilFeature]))
    return makeChronomorph(nil, pSpan)
  elsif pChronomorphs.last[:displacement].nil?
    return makeChronomorph((previousDisplacement + displacementIntervals.choose), pSpan)
  else
    return makeChronomorph((previousDisplacement + chooseAbsIntWithWeight(pSettingsCreation[:weightForDisplacementIntervals], displacementIntervals)), pSpan)
  end
end

define :filterDisplacementIntervalsForCompatibility do |pDisplacementIntervals, pChronomorphs, pBounds, pSettingsCreation|
  peak = getPeakOfChronomorphs(pChronomorphs)
  trough = getTroughOfChronomorphs(pChronomorphs)
  height = (peak - trough)

  leeway = (pSettingsCreation[:displacementLimit] - height)
  maxPeak = getMin((peak + leeway), pBounds[:high])
  minTrough = getMax((trough - leeway), pBounds[:low])

  previousDisplacement = getLastFeatureOfChronomorphs(pChronomorphs)

  return pDisplacementIntervals.select { |i| (previousDisplacement + i).between?(minTrough, maxPeak) }.freeze
end

define :getContourOfChronomorphs do |pChronomorphs|
  return pChronomorphs.map { |c| c[:displacement] }
end

define :getLastFeatureOfChronomorphs do |pChronomorphs|
  return pChronomorphs.reverse_each.detect { |c| isChronomorphFeatureful?(c) }[:displacement]
end

define :getPeakOfChronomorphs do |pChronomorphs|
  return getContourOfChronomorphs(pChronomorphs).compact.max
end

define :getTroughOfChronomorphs do |pChronomorphs|
  return getContourOfChronomorphs(pChronomorphs).compact.min
end

define :invertChronomorph do |pChronomorph|
  if isChronomorphFeatureless?(pChronomorph)
    return pChronomorph
  else
    return makeChronomorph(-pChronomorph[:displacement], pChronomorph[:span])
  end
end

define :invertChronomorphs do |pChronomorphs|
  return pChronomorphs.map { |c| invertChronomorph(c) }.freeze
end

define :isChronomorphFeatureful? do |pChronomorph|
  return !pChronomorph[:displacement].nil?
end

define :isChronomorphFeatureless? do |pChronomorph|
  return pChronomorph[:displacement].nil?
end

define :makeChronomorph do |pDisplacement, pSpan|
  assert (pDisplacement.nil? || pDisplacement.is_a?(Integer))
  assert (pSpan.nil? || (pSpan > 0))

  return {
    displacement: pDisplacement,
    span: pSpan,
  }.freeze
end

define :retrogradeChronomorphs do |pChronomorphs|
  return pChronomorphs.reverse.freeze
end

define :transposeChronomorph do |pChronomorph, pSteps|
  if isChronomorphFeatureless?(pChronomorph)
    return pChronomorph
  else
    return makeChronomorph((pChronomorph[:displacement] + pSteps), pChronomorph[:span])
  end
end

define :transposeChronomorphs do |pChronomorphs, pSteps|
  return (pSteps.zero? ? pChronomorphs : pChronomorphs.map { |c| transposeChronomorph(c, pSteps) }).freeze
end

define :zeroChronomorphs do |pChronomorphs|
  return transposeChronomorphs(pChronomorphs, -pChronomorphs.detect { |c| isChronomorphFeatureful?(c) }[:displacement]).freeze
end

# motifs

define :createBoundMotif do |pBounds, pNumUnitsPerMeasure, pSettingsCreation|
  chronomorphs = []
  while areAllChronomorphsFeatureless?(chronomorphs)
    divisions = divideUnitsRhythmically(pNumUnitsPerMeasure, pSettingsCreation[:weightForSpans])
    subdivisions = divisions.map { |division| ((division == 1) ? division : divideUnitsRhythmically(division, pSettingsCreation[:weightForSpans])) }.flatten.freeze
    subdivisions = mergeBriefStart(subdivisions) if pSettingsCreation[:shouldMergeBriefStart]
    chronomorphs = [createInitialChronomorph(subdivisions.first, pSettingsCreation)]
    subdivisions[1...subdivisions.length].each do |subdivision|
      chronomorphs.push(createNextBoundChronomorph(chronomorphs, pBounds, subdivision, pSettingsCreation))
    end
  end

  return makeMotif(chronomorphs)
end

define :createMotif do |pNumUnitsPerMeasure, pSettingsCreation|
  return createBoundMotif(makeMirrorRangePair(pSettingsCreation[:displacementLimit]), pNumUnitsPerMeasure, pSettingsCreation)
end

define :getAllMotifsPeak do |pMotifs|
  return pMotifs.map { |m| getPeakOfChronomorphs(m) }.max
end

define :getAllMotifsTrough do |pMotifs|
  return pMotifs.map { |m| getTroughOfChronomorphs(m) }.min
end

define :makeMotif do |pChronomorphs|
  assert_not areAllChronomorphsFeatureless?(pChronomorphs)

  return zeroChronomorphs(pChronomorphs).freeze
end

# infinitum

INFINITUM_CHRONOMORPH = makeChronomorph(0, nil)
INFINITUM_MOTIF = makeMotif([INFINITUM_CHRONOMORPH])

define :getInfinitumMotif do
  return INFINITUM_MOTIF
end

# specialised functions

define :createStateMotifs do
  numStateMotifs = get("settings/ideation")[:numStateMotifs]
  if numStateMotifs.zero?
    return [].freeze
  else
    return makeRangeArrayFromZero(numStateMotifs).map { |i| createMotif(get("settings/metronome")[:numUnitsPerMeasure], get("settings/ideation/creation")) }.freeze
  end
end

define :ideate do
  if (get("motifs").empty? || evalChance?(get("settings/ideation")[:chanceCreateMotif]))
    return createMotif(get("settings/metronome")[:numUnitsPerMeasure], get("settings/ideation/creation"))
  else
    prototype = get("motifs").choose

    if evalChance?(get("settings/ideation")[:chanceInvertMotif])
      prototype = invertChronomorphs(prototype)
    end
    if evalChance?(get("settings/ideation")[:chanceRetrogradeMotif])
      prototype = retrogradeChronomorphs(prototype)
    end

    return makeMotif(prototype)
  end
end
