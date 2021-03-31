module Polyphony
  #
  # Global constants.
  #
  module Settings
    extend self
    include Polyphony::Ensembles
    include Polyphony::Ideation
    include Polyphony::Space
    include Polyphony::Utils
    include SonicPi::Lang::WesternTheory

    MIDI_INSTRUMENTS = {
      bbcsoBassoon: MIDIInstrument.new({
        shortSwitches: [4].freeze,
        midSwitches: [4, 5].freeze,
        longSwitches: [1].freeze,
        legatoSwitches: [0].freeze,
        ccNums: [1, 11].freeze,
        playingRangePair: RangePairI.new(note(:Bb1), note(:C5)).freeze,
      }.freeze).freeze,
      bbcsoCeleste: MIDIInstrument.new({
        shortSwitches: [1].freeze,
        midSwitches: [1, 2].freeze,
        longSwitches: [0].freeze,
        legatoSwitches: [0].freeze,
        ccNums: [1, 11].freeze,
        playingRangePair: RangePairI.new(note(:C3), note(:C8)).freeze,
      }.freeze).freeze,
      bbcsoCelloBow: MIDIInstrument.new({
        shortSwitches: [19].freeze,
        midSwitches: [19].freeze,
        longSwitches: [1, 2, 3, 11, 18].freeze,
        legatoSwitches: [0].freeze,
        ccNums: [1, 11].freeze,
        playingRangePair: RangePairI.new(note(:C2), note(:G5)).freeze,
      }.freeze).freeze,
      bbcsoCelloPluck: MIDIInstrument.new({
        shortSwitches: [6].freeze,
        midSwitches: [6].freeze,
        longSwitches: [1, 2, 3, 11, 18].freeze,
        legatoSwitches: [6].freeze,
        ccNums: [1, 11].freeze,
        playingRangePair: RangePairI.new(note(:C2), note(:G5)).freeze,
      }.freeze).freeze,
      bbcsoClarinet: MIDIInstrument.new({
        shortSwitches: [4].freeze,
        midSwitches: [4, 5].freeze,
        longSwitches: [1].freeze,
        legatoSwitches: [0].freeze,
        ccNums: [1, 11].freeze,
        playingRangePair: RangePairI.new(note(:D3), note(:D6)).freeze,
      }.freeze).freeze,
      bbcsoFlute: MIDIInstrument.new({
        shortSwitches: [4].freeze,
        midSwitches: [4, 5].freeze,
        longSwitches: [1].freeze,
        legatoSwitches: [0].freeze,
        ccNums: [1, 11].freeze,
        playingRangePair: RangePairI.new(note(:C4), note(:G6)).freeze,
      }.freeze).freeze,
      bbcsoFrenchHorn: MIDIInstrument.new({
        shortSwitches: [2].freeze,
        midSwitches: [3].freeze,
        longSwitches: [1, 4, 5].freeze,
        legatoSwitches: [0].freeze,
        ccNums: [1, 11].freeze,
        playingRangePair: RangePairI.new(note(:C3), note(:C5)).freeze,
      }.freeze).freeze,
      bbcsoGlockenspiel: MIDIInstrument.new({
        shortSwitches: [0].freeze,
        midSwitches: [0].freeze,
        longSwitches: [0].freeze,
        legatoSwitches: [0].freeze,
        ccNums: [1, 11].freeze,
        playingRangePair: RangePairI.new(note(:F5), note(:C8)).freeze,
      }.freeze).freeze,
      bbcsoMarimba: MIDIInstrument.new({
        shortSwitches: [0].freeze,
        midSwitches: [0].freeze,
        longSwitches: [0].freeze,
        legatoSwitches: [0].freeze,
        ccNums: [1, 11].freeze,
        playingRangePair: RangePairI.new(note(:C2), note(:C7)).freeze,
      }.freeze).freeze,
      bbcsoOboe: MIDIInstrument.new({
        shortSwitches: [4].freeze,
        midSwitches: [4, 5].freeze,
        longSwitches: [1].freeze,
        legatoSwitches: [0].freeze,
        ccNums: [1, 11].freeze,
        playingRangePair: RangePairI.new(note(:C4), note(:C6)).freeze,
      }.freeze).freeze,
      bbcsoTenorTrombone: MIDIInstrument.new({
        shortSwitches: [2].freeze,
        midSwitches: [3].freeze,
        longSwitches: [1, 4, 5].freeze,
        legatoSwitches: [0].freeze,
        ccNums: [1, 11].freeze,
        playingRangePair: RangePairI.new(note(:G1), note(:D5)).freeze,
      }.freeze).freeze,
      bbcsoTrumpet: MIDIInstrument.new({
        shortSwitches: [2].freeze,
        midSwitches: [3].freeze,
        longSwitches: [1, 4, 5].freeze,
        legatoSwitches: [0].freeze,
        ccNums: [1, 11].freeze,
        playingRangePair: RangePairI.new(note(:E3), note(:C6)).freeze,
      }.freeze).freeze,
      bbcsoTuba: MIDIInstrument.new({
        shortSwitches: [2].freeze,
        midSwitches: [3].freeze,
        longSwitches: [1, 4, 5].freeze,
        legatoSwitches: [0].freeze,
        ccNums: [1, 11].freeze,
        playingRangePair: RangePairI.new(note(:D1), note(:E4)).freeze,
      }.freeze).freeze,
      bbcsoVibraphone: MIDIInstrument.new({
        shortSwitches: [0].freeze,
        midSwitches: [0].freeze,
        longSwitches: [0].freeze,
        legatoSwitches: [0].freeze,
        ccNums: [1, 11].freeze,
        playingRangePair: RangePairI.new(note(:F3), note(:F6)).freeze,
      }.freeze).freeze,
      bbcsoViolaBow: MIDIInstrument.new({
        shortSwitches: [19].freeze,
        midSwitches: [19].freeze,
        longSwitches: [1, 2, 3, 11, 18].freeze,
        legatoSwitches: [0].freeze,
        ccNums: [1, 11].freeze,
        playingRangePair: RangePairI.new(note(:C3), note(:C6)).freeze,
      }.freeze).freeze,
      bbcsoViolaPluck: MIDIInstrument.new({
        shortSwitches: [6].freeze,
        midSwitches: [6].freeze,
        longSwitches: [1, 2, 3, 11, 18].freeze,
        legatoSwitches: [6].freeze,
        ccNums: [1, 11].freeze,
        playingRangePair: RangePairI.new(note(:C3), note(:C6)).freeze,
      }.freeze).freeze,
      bbcsoViolinBow: MIDIInstrument.new({
        shortSwitches: [19].freeze,
        midSwitches: [19].freeze,
        longSwitches: [1, 2, 3, 11, 18].freeze,
        legatoSwitches: [0].freeze,
        ccNums: [1, 11].freeze,
        playingRangePair: RangePairI.new(note(:G3), note(:G6)).freeze,
      }.freeze).freeze,
      bbcsoViolinPluck: MIDIInstrument.new({
        shortSwitches: [6].freeze,
        midSwitches: [6].freeze,
        longSwitches: [1, 2, 3, 11, 18].freeze,
        legatoSwitches: [6].freeze,
        ccNums: [1, 11].freeze,
        playingRangePair: RangePairI.new(note(:G3), note(:G6)).freeze,
      }.freeze).freeze,
      bbcsoXylophone: MIDIInstrument.new({
        shortSwitches: [0].freeze,
        midSwitches: [0].freeze,
        longSwitches: [0].freeze,
        legatoSwitches: [0].freeze,
        ccNums: [1, 11].freeze,
        playingRangePair: RangePairI.new(note(:F4), note(:C8)).freeze,
      }.freeze).freeze,
      niYangqin: MIDIInstrument.new({
        shortSwitches: [].freeze,
        midSwitches: [nil, note(:E1), note(:Fs1), note(:G1), note(:A1)].freeze,
        longSwitches: [].freeze,
        legatoSwitches: [].freeze,
        ccNums: [].freeze,
        playingRangePair: RangePairI.new(note(:F2), note(:A6)).freeze,
      }.freeze).freeze,
      pianoteqHarpsichord: MIDIInstrument.new({
        shortSwitches: [].freeze,
        midSwitches: [].freeze,
        longSwitches: [].freeze,
        legatoSwitches: [].freeze,
        ccNums: [].freeze,
        playingRangePair: RangePairI.new(note(:F1), note(:F6)).freeze,
      }.freeze).freeze,
      pianoteqPiano: MIDIInstrument.new({
        shortSwitches: [].freeze,
        midSwitches: [].freeze,
        longSwitches: [].freeze,
        legatoSwitches: [].freeze,
        ccNums: [].freeze,
        playingRangePair: RangePairI.new(note(:C1), note(:C8)).freeze,
      }.freeze).freeze,
      serum: MIDIInstrument.new({
        shortSwitches: [].freeze,
        midSwitches: [].freeze,
        longSwitches: [].freeze,
        legatoSwitches: [].freeze,
        ccNums: [].freeze,
        playingRangePair: RangePairI.new(note(:C1), note(:C8)).freeze,
      }.freeze).freeze,
    }.freeze

    SPI_INSTRUMENTS = {
      alto: SPiInstrument.new({
        synth: :saw,
        playingRangePair: RangePairI.new(note(:G3), note(:C5)).freeze,
      }.freeze).freeze,
      bass: SPiInstrument.new({
        synth: :pulse,
        playingRangePair: RangePairI.new(note(:F2), note(:C4)).freeze,
      }.freeze).freeze,
      soprano: SPiInstrument.new({
        synth: :square,
        playingRangePair: RangePairI.new(note(:Bb3), note(:E5)).freeze,
      }.freeze).freeze,
      tenor: SPiInstrument.new({
        synth: :tri,
        playingRangePair: RangePairI.new(note(:C3), note(:G4)).freeze,
      }.freeze).freeze,
    }.freeze

    ENSEMBLES = {
      bbcsoBrass4: [
        MIDI_INSTRUMENTS[:bbcsoTrumpet], MIDI_INSTRUMENTS[:bbcsoFrenchHorn], MIDI_INSTRUMENTS[:bbcsoTenorTrombone], MIDI_INSTRUMENTS[:bbcsoTuba],
      ].freeze,
      bbcsoMallets3: [
        MIDI_INSTRUMENTS[:bbcsoGlockenspiel], MIDI_INSTRUMENTS[:bbcsoXylophone], MIDI_INSTRUMENTS[:bbcsoMarimba],
      ].freeze,
      bbcsoStrings4: [
        MIDI_INSTRUMENTS[:bbcsoViolinBow], MIDI_INSTRUMENTS[:bbcsoViolinBow], MIDI_INSTRUMENTS[:bbcsoViolaBow], MIDI_INSTRUMENTS[:bbcsoCelloBow],
      ].freeze,
      bbcsoVibraphone1: [
        MIDI_INSTRUMENTS[:bbcsoVibraphone],
      ].freeze,
      bbcsoWinds4: [
        MIDI_INSTRUMENTS[:bbcsoFlute], MIDI_INSTRUMENTS[:bbcsoOboe], MIDI_INSTRUMENTS[:bbcsoClarinet], MIDI_INSTRUMENTS[:bbcsoBassoon],
      ].freeze,
      bbcsoWinds5: [
        MIDI_INSTRUMENTS[:bbcsoFlute], MIDI_INSTRUMENTS[:bbcsoOboe], MIDI_INSTRUMENTS[:bbcsoClarinet], MIDI_INSTRUMENTS[:bbcsoFrenchHorn], MIDI_INSTRUMENTS[:bbcsoBassoon],
      ].freeze,
      pianoteqHarpsichord1: [
        MIDI_INSTRUMENTS[:pianoteqHarpsichord]
      ].freeze,
      pianoteqPiano1: [
        MIDI_INSTRUMENTS[:pianoteqPiano],
      ].freeze,
      serum1: [
        MIDI_INSTRUMENTS[:serum],
      ].freeze,
      spiSATB4: [
        SPI_INSTRUMENTS[:soprano], SPI_INSTRUMENTS[:alto], SPI_INSTRUMENTS[:tenor], SPI_INSTRUMENTS[:bass],
      ].freeze,
    }.freeze

    # making ideas
    CREATION = {
      chanceCreateNilFeature: 0, # [0, 1]
      chanceCreateNoConsecutivelyRepeatedDisplacements: 0, # [0, 1]

      displacementLimit: 5, # int [0,]
      displacementIntervalLimit: 5, # int [0,]
      weightForDisplacementIntervals: 0, # [0, 1] # negative for small intervals, positive for large intervals

      shouldMergeBriefStart: true,

      weightForSpans: 0, # [-1, 1] # negative for small spans, positive for large spans
    }.freeze

    # preparing finished ideas
    IDEATION = {
      chanceCreateOneTimeMotif: 0.2, # [0, 1]

      chanceInvertMotif: 0.1, # [0, 1]
      chanceRetrogradeMotif: 0.1, # [0, 1]

      rangeNumMotifsToIdeate: RangePairI.new(1, 2).freeze, # int [0,]
    }.freeze

    # making syntheses
    COMPOSITION = {
      chanceArrange: 0.95, # [0, 1]
      chanceImprovise: 0.8, # [0, 1]

      degreeOfOverlap: 2, # 0: none; 1: edges; 2: spaces; 3: positions

      generalPositionsOfChord: [0, 1, 2, 4, 6].freeze, # int [0, tonicity] # positions are zero-indexed and diatonic

      proximityLimit: 40, # [0,] # in Hz

      specificDissonances: [1, 2, 13].freeze, # int [0,] # positions are chromatic
    }.freeze

    # enable to log
    LOGGING = {
      shouldLogCues: false,
      shouldLogDebug: false,
      shouldLogMessages: true,
      shouldLogMIDI: false,
    }.freeze

    # random seed
    RANDOM = {
      seed: Time.now.to_i, # int [0,]
    }.freeze

    # key/chord management
    SPACE = {
      chanceModulate: 0.15, # [0, 1]
      chanceModulateWithPivot: 0.5, # [0, 1]

      chanceProgress: 0.8, # [0, 1]
      chanceReturnToRoot: 0.2, # [0, 1]
      diminishedScales: [:locrian, :super_locrian].freeze, # [any heptatonic scale]
      majorScales: [:ionian, :lydian, :mixolydian].freeze, # [any heptatonic scale]
      minorScales: [:dorian, :phrygian, :aeolian, :harmonic_minor, :melodic_minor].freeze, # [any heptatonic scale]
      progressions: nil, # int [0, tonicity] # nil permits all progressions

      initialKey: makeKey(0, :aeolian), # int 0-11, [any heptatonic scale]
      numOctaves: 10, # int [1,]

      maxPositionInterval: 5, # int [0,]
      weightForPositionIntervals: -0.8, # int [-1,1] # -ve for small intervals, +ve for large intervals

      numMeasuresInitialDelay: 4, # int [0,]
    }.freeze

    # motif management
    STATE = {
      chanceCreateNewStateMotif: 0.005, # [0, 1]

      customStateMotifs: [
        # makeMotifFromArrays([[0, 4], [1, 4], [3, 4], [2, 4]]),
      ].freeze,

      maxNumStateMotifs: 4, # int [0,]
      numInitialStateMotifs: 2, # int [0,]
      numStateMotifsToKeep: 2, # int [0,]

      numMeasuresInitialDelay: 40, # int [0,]
    }.freeze

    # regulates tempo and time
    TIMEKEEPING = {
      numUnitsPerMeasure: 16, # int [1,]

      numSubunits: 4, # int [1,]

      timeLimitInUnits: nil, # int [0,] | nil for no limit

      unitsPerMinute: 360, # (0,)
    }.freeze

    # sections of playing styles
    VOICES = {
      selection: [ # comment out undesired sections
        "articulated".freeze,
        "sustained".freeze,
      ].freeze,
    }.freeze

    # MIDI information
    MIDI = {
      numChannelsPerPort: 16,
    }.freeze

    # articulated playing style
    ARTICULATED = {
      chanceAddVoices: 0.5, # [0, 1]
      maxNumVoicesActive: 4, # int [0,]
      rangeNumVoicesToAddPerMeasure: RangePairI.new(0, 1).freeze, # int [0,]

      performance: {
        chanceRecalculate: 0.95, # [0, 1]
        chanceRepeat: 0.75, # [0, 1]

        ensemble: ENSEMBLES[:SPI_SATB_4], # (select ensemble from ensembles)

        rangeNumRhythmicDivisions: RangePairI.new(1, 4).freeze, # int [0,]
        rangeNumRhythmsInPolyrhythm: RangePairI.new(1, 2).freeze, # int [0,]

        midi: {
          chanceLegato: 0, # [0, 1]
          legatoSpanThreshold: 8, # int [1,]

          ports: [
            "polyphony-articulated-0_2",
          ],

          cc: {
            base: 0.6, # [0, 1]
            maxHeight: 0.15, # [0, 1]
            rangeNumMeasuresInPeriod: RangePairI.new(2, 4).freeze, # int [0,]
          }.freeze,
          legato: {
            velocityOff: {
              base: 0.75, # [0, 1]
              rangeRandom: RangePairF.new(0.1).freeze, # [-1, 1]
            }.freeze,
            velocityOn: {
              accent: 0, # [0, 1]
              base: 1, # [0, 1]
              rangeRandom: RangePairF.new(-0.9, 0).freeze, # [-1, 1]
            }.freeze,
          }.freeze,
          shortMid: {
            durationMid: 2, # int [1,]

            velocityOff: {
              base: 0.75, # [0, 1]
              rangeRandom: RangePairF.new(0.1).freeze, # [-1, 1]
            }.freeze,
            velocityOn: {
              accent: 0.1, # [0, 1]
              base: 0.5, # [0, 1]
              rangeRandom: RangePairF.new(0.1).freeze, # [-1, 1]
            }.freeze,
          }.freeze,
        }.freeze,

        spi: {
          shortMid: {
            amp: {
              accent: 0.1, # [0, 1]
              base: 0.5, # [0, 1]
              rangeRandom: RangePairF.new(0.1).freeze, # [-1, 1]
            }.freeze,

            panWidth: 1 # [0, 2]
          }.freeze,
        }.freeze,
      }.freeze,
    }.freeze

    # sustained playing style
    SUSTAINED = {
      chanceAddVoices: 1, # [0, 1]
      maxNumVoicesActive: 4, # int [0,]
      rangeNumVoicesToAddPerMeasure: RangePairI.new(0, 3).freeze, # int [0,]

      performance: {
        ensemble: ENSEMBLES[:SPI_SATB_4], # (select ensemble from ensembles)

        rangeNumMeasuresToSustain: RangePairI.new(3, 4).freeze, # int [0,]

        midi: {
          ports: [
            "polyphony-sustained-0_3",
          ].freeze,

          cc: {
            base: 0.6, # [0, 1]
            maxHeight: 0.15 # [0, 1]
          }.freeze,
          long: {
            velocityOff: {
              base: 0.75, # [0, 1]
              rangeRandom: RangePairF.new(0.1).freeze, # [-1, 1]
            }.freeze,
            velocityOn: {
              base: 0.3, # [0, 1]
              rangeRandom: RangePairF.new(0.1).freeze, # [-1, 1]
            }.freeze,
          }.freeze,
        }.freeze,

        spi: {
          long: {
            amp: {
              base: 0.25, # [0, 1]
              rangeRandom: RangePairF.new(0.1).freeze, # [-1, 1]
            }.freeze,

            panWidth: 1 # [0, 2]
          }.freeze,
        }.freeze,
      }.freeze,
    }.freeze
  end
end
