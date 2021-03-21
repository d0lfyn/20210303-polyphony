# generalised functions

# notes

define :areAllNotesFeatureless? do |pNotes|
  return pNotes.all? { |c| isNoteFeatureless?(c) }
end

define :createInitialNote do |pSpan, pSettingsCreation|
  return makeNote((evalChance?(pSettingsCreation[:chanceCreateNilFeature]) ? nil : 0), pSpan)
end

define :createNextBoundNote do |pNotes, pBounds, pSpan, pSettingsCreation|
  if areAllNotesFeatureless?(pNotes)
    return createInitialNote(pSpan, pSettingsCreation)
  end

  previousDisplacement = getLastFeatureOfNotes(pNotes)
  displacementIntervals = makeArrayOfIntsFromRangePair(makeMirrorRangePair(pSettingsCreation[:displacementIntervalLimit]))
  displacementIntervals = filterDisplacementIntervalsForCompatibility(displacementIntervals, pNotes, pBounds, pSettingsCreation)
  if evalChance?(pSettingsCreation[:chanceCreateNoConsecutivelyRepeatedDisplacements])
    displacementIntervals -= [0]
  end

  if (displacementIntervals.empty? || evalChance?(pSettingsCreation[:chanceCreateNilFeature]))
    return makeNote(nil, pSpan)
  elsif pNotes.last[:displacement].nil?
    return makeNote((previousDisplacement + displacementIntervals.choose), pSpan)
  else
    return makeNote((previousDisplacement + chooseAbsIntWithWeight(pSettingsCreation[:weightForDisplacementIntervals], displacementIntervals)), pSpan)
  end
end

define :filterDisplacementIntervalsForCompatibility do |pDisplacementIntervals, pNotes, pBounds, pSettingsCreation|
  peak = getPeakOfNotes(pNotes)
  trough = getTroughOfNotes(pNotes)
  height = (peak - trough)

  leeway = (pSettingsCreation[:displacementLimit] - height)
  maxPeak = getMin((peak + leeway), pBounds[:high])
  minTrough = getMax((trough - leeway), pBounds[:low])

  previousDisplacement = getLastFeatureOfNotes(pNotes)

  return pDisplacementIntervals.select { |i| (previousDisplacement + i).between?(minTrough, maxPeak) }.freeze
end

define :getContourOfNotes do |pNotes|
  return pNotes.map { |c| c[:displacement] }
end

define :getLastFeatureOfNotes do |pNotes|
  return pNotes.reverse_each.detect { |c| isNoteFeatureful?(c) }[:displacement]
end

define :getPeakOfNotes do |pNotes|
  return getContourOfNotes(pNotes).compact.max
end

define :getTroughOfNotes do |pNotes|
  return getContourOfNotes(pNotes).compact.min
end

define :invertNote do |pNote|
  if isNoteFeatureless?(pNote)
    return pNote
  else
    return makeNote(-pNote[:displacement], pNote[:span])
  end
end

define :invertNotes do |pNotes|
  return pNotes.map { |c| invertNote(c) }.freeze
end

define :isNoteFeatureful? do |pNote|
  return !pNote[:displacement].nil?
end

define :isNoteFeatureless? do |pNote|
  return pNote[:displacement].nil?
end

define :makeNote do |pDisplacement, pSpan|
  assert (pDisplacement.nil? || pDisplacement.is_a?(Integer))
  assert (pSpan.nil? || (pSpan > 0))

  return {
    displacement: pDisplacement,
    span: pSpan,
  }.freeze
end

define :retrogradeNotes do |pNotes|
  return pNotes.reverse.freeze
end

define :transposeNote do |pNote, pSteps|
  if isNoteFeatureless?(pNote)
    return pNote
  else
    return makeNote((pNote[:displacement] + pSteps), pNote[:span])
  end
end

define :transposeNotes do |pNotes, pSteps|
  return (pSteps.zero? ? pNotes : pNotes.map { |c| transposeNote(c, pSteps) }).freeze
end

define :zeroNotes do |pNotes|
  return transposeNotes(pNotes, -pNotes.detect { |c| isNoteFeatureful?(c) }[:displacement]).freeze
end

# motifs

define :createBoundMotif do |pBounds, pNumUnitsPerMeasure, pSettingsCreation|
  notes = []
  while areAllNotesFeatureless?(notes)
    divisions = divideUnitsRhythmically(pNumUnitsPerMeasure, pSettingsCreation[:weightForSpans])
    subdivisions = divisions.map { |division| ((division == 1) ? division : divideUnitsRhythmically(division, pSettingsCreation[:weightForSpans])) }.flatten.freeze
    subdivisions = mergeBriefStart(subdivisions) if pSettingsCreation[:shouldMergeBriefStart]
    notes = [createInitialNote(subdivisions.first, pSettingsCreation)]
    subdivisions[1...subdivisions.length].each do |subdivision|
      notes.push(createNextBoundNote(notes, pBounds, subdivision, pSettingsCreation))
    end
  end

  return makeMotif(notes)
end

define :createMotif do |pNumUnitsPerMeasure, pSettingsCreation|
  return createBoundMotif(makeMirrorRangePair(pSettingsCreation[:displacementLimit]), pNumUnitsPerMeasure, pSettingsCreation)
end

define :getAllMotifsPeak do |pMotifs|
  return pMotifs.map { |m| getPeakOfNotes(m) }.max
end

define :getAllMotifsTrough do |pMotifs|
  return pMotifs.map { |m| getTroughOfNotes(m) }.min
end

define :makeMotif do |pNotes|
  assert_not areAllNotesFeatureless?(pNotes)

  return zeroNotes(pNotes).freeze
end

define :makeMotifFromArrays do |pArrays|
  notes = pArrays.map { |array| makeNote(array[0], array[1]) }

  return makeMotif(notes)
end

# infinitum

INFINITUM_NOTE = makeNote(0, nil)
INFINITUM_MOTIF = makeMotif([INFINITUM_NOTE])

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
      prototype = invertNotes(prototype)
    end
    if evalChance?(get("settings/ideation")[:chanceRetrogradeMotif])
      prototype = retrogradeNotes(prototype)
    end

    return makeMotif(prototype)
  end
end
