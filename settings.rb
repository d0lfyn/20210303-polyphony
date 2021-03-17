set("settings/composition", {
	chanceCompose: 0.9, # [0,1]
	chanceImprovise: 0.8, # [0,1]

	degreeOfOverlap: 2, # 0: none; 1: edges; 2: spaces; 3: positions

	generalPositionsOfChord: [0, 1, 2, 4, 6].freeze, # [0,tonicity] | zero-indexed positions

	proximityLimit: 40, # [0,) Hz

	specificDissonances: [1, 2, 13].freeze, # int [0,) | chromatic
}.freeze)

set("settings/general", {
	seed: ((Time.new.to_i * 1e9).to_i + Time.new.nsec), # int [0,)
	seed: Time.new.to_i, # int [0,)
}.freeze)

set("settings/ideation", {
	chanceCreateMotif: 0.25, # [0,1]

	chanceInvertMotif: 0.1, # [0,1]
	chanceRetrogradeMotif: 0.1, # [0,1]

	numStateMotifs: 2, # int [0,)

	rangeNumMotifsToIdeate: makeRangePair(1, 1), # int [1,)
}.freeze)

set("settings/ideation/creation", {
	chanceCreateNilFeature: 0, # [0,1]
	chanceCreateNoConsecutivelyRepeatedDisplacements: 1, # [0,1]

	displacementLimit: 5, # int [0,)
	displacementIntervalLimit: 5, # int [0,)

	shouldMergeBriefStart: true,

	weightForDisplacementIntervals: 0, # [-1,1] | -ve for small intervals, +ve for large intervals

	weightForSpans: 0, # [-1,1] | -ve for small spans, +ve for large spans
}.freeze)

set("settings/logging", {
  shouldLogCues: false,
	shouldLogDebug: false,
  shouldLogMIDI: false,

	shouldLogOptional: true,
}.freeze)

set("settings/metronome", {
  numUnitsPerMeasure: 16, # int [1,)
	numSubunits: 4, # int [2,)
  unit: 1, # (0,)
  unitsPerMinute: 360, # (0,)

  startDelay: 2, # [0,)
  timeLimitInMinutes: nil, # [0,) | nil performs forever
}.freeze)

set("settings/space", {
	chanceModulate: 0.15, # [0,1]

	chanceProgress: 0.8, # [0,1]
	chanceReturnToRoot: 0.2, # [0,1]
	diminishedScales: [:locrian].freeze, # [any heptatonic scale]
	majorScales: [:ionian, :lydian, :mixolydian].freeze, # [any heptatonic scale]
	minorScales: [:dorian, :phrygian, :aeolian].freeze, # [any heptatonic scale]
	progressions: nil, # [0,tonicity] | nil permits all progressions

	initialKey: makeKey(0, :aeolian), # 0-11 [any heptatonic scale]
	numOctaves: 9, # int [1,)

	maxPositionInterval: 5, # int [0,)
	weightForPositionIntervals: -0.8, # int [-1,1] | -ve for small intervals, +ve for large intervals

	numMeasuresBeforeProgressionsBegin: 4, # int [0,)

	tuning: :equal, # refer to sonic pi tuning
}.freeze)

set("settings/voices", {
  selection: [
    "articulated".freeze,
    "sustained".freeze,
  ].freeze,

  numChannelsPerPort: 16,
}.freeze)

set("settings/voices/articulated", {
	chanceAddVoices: 0.5, # [0,1]
	maxNumVoicesActive: 4, # int [0,)
  rangeNumToAddPerMeasure: makeRangePair(0, 1), # int [0,)

  performance: {
		chanceContinue: 0.9, # [0,1]
		chanceRepeat: 0.75, # [0,1]

		ensemble: get("ensembles/fusion")[:FUSION_BBCSO_MALLETS_3_AND_SYNTHS_SATB_4],

		rangeNumRhythmicDivisions: makeRangePair(1, 8), # int [1,)
		rangeNumRhythms: makeRangePair(1, 2), # int [1,)

		midi: {
			chanceLegato: 0, # [0,1]
			legatoSpanThreshold: 8, # int [1,)

			ports: [
				"polyphony-articulated-0_2",
				# "polyphony-articulated-1_4",
			].freeze,

			cc: {
				base: 0.5, # [0,1]
				maxHeight: 0.15, # [0,1]
				rangeNumMeasuresInPeriod: makeRangePair(2, 4), # int [1,)
			},
			legato: {
				velocityOff: {
					base: 0.75, # [0,1]
					rangeRandom: makeMirrorRangePair(0.1), # [0,1]
				}.freeze,
				velocityOn: {
					accent: 0, # [0,1]
					base: 1, # [0,1]
					rangeRandom: makeRangePair(-0.9, 0), # [0,1]
				}.freeze,
			}.freeze,
			shortMid: {
				durationMid: 2,

				velocityOff: {
					base: 0.75, # [0,1]
					rangeRandom: makeMirrorRangePair(0.1), # [0,1]
				}.freeze,
				velocityOn: {
					accent: 0.1, # [0,1]
					base: 0.5, # [0,1]
					rangeRandom: makeMirrorRangePair(0.1), # [0,1]
				}.freeze,
			}.freeze,
		}.freeze,

		spi: {
			shortMid: {
				amp: {
					accent: 0.1, # [0,1]
					base: 0.5, # [0,1]
					rangeRandom: makeMirrorRangePair(0.1), # [0,1]
				}.freeze,
			}.freeze,
		}.freeze,
  }.freeze,
}.freeze)

set("settings/voices/sustained", {
	chanceAddVoices: 1, # [0,1]
	maxNumVoicesActive: 4, # int [0,)
  rangeNumToAddPerMeasure: makeRangePair(0, 3), # int [0,)

  performance: {
		rangeNumMeasuresToSustain: makeRangePair(3, 4), # int [1,)

		ensemble: get("ensembles/fusion")[:FUSION_BBCSO_VIBES_4_AND_SYNTHS_SATB_4],

		midi: {
			ports: [
				"polyphony-sustained-0_3",
				# "polyphony-sustained-0_5",
			].freeze,

			cc: {
				base: 0.5, # [0,1]
				maxHeight: 0.15, # [0,1]
			},
			long: {
				velocityOff: {
					base: 0.75, # [0,1]
					rangeRandom: makeMirrorRangePair(0.1), # [0,1]
				}.freeze,
				velocityOn: {
					base: 0.3, # [0,1]
					rangeRandom: makeMirrorRangePair(0.1), # [0,1]
				}.freeze,
			}.freeze,
		}.freeze,

		spi: {
			long: {
				amp: {
					base: 0.25, # [0,1]
					rangeRandom: makeMirrorRangePair(0.1), # [0,1]
				}.freeze,
			}.freeze,
		}.freeze,
  }.freeze,
}.freeze)
