module Polyphony
  #
  # Data and logic for musical ideas in the form of notes and motifs.
  #
  module Ideation
    extend self

    # pure functions

    # motif hashes

    #
    # Creates a random motif by dividing and subdividing the given number of measure units, with displacement intervals chosen by the given settings, keeping within the given displacement bounds.
    #
    # @param [RangePairI] pBounds displacement bounds
    # @param [Integer] pNumUnitsPerMeasure number of units in motif
    # @param [Hash] pSettingsCreation creation settings
    #
    # @return [Hash] a random motif respecting the givens
    #
    def createBoundMotif(pBounds, pNumUnitsPerMeasure, pSettingsCreation)
      # @type [Array<Hash>]
      notes = []
      while notes.all? { |note| note[:displacement].nil? }
        # @type [Array<Integer>]
        divisions = divideUnitsRhythmically(pNumUnitsPerMeasure, pSettingsCreation[:weightForSpans])
        # @type [Array<Integer>]
        subdivisions = divisions.map { |division| subdivideUnitsRhythmically(division, pSettingsCreation[:weightForSpans]) }.flatten.freeze
        subdivisions = mergeBriefStart(subdivisions) if pSettingsCreation[:shouldMergeBriefStart]
        # @type [Array<Hash>]
        notes = [createInitialNote(subdivisions.first, pSettingsCreation)]
        subdivisions[1...subdivisions.length].each do |subdivision|
          notes.push(createNextBoundNote(notes, pBounds,subdivision, pSettingsCreation))
        end
      end

      return makeMotif(notes)
    end

    #
    # Creates a motif bound by the given settings and taking up the given number of units.
    #
    # @param [Integer] pNumUnitsPerMeasure number of units in motif
    # @param [Hash] pSettingsCreation creation settings
    #
    # @return [Hash] a random motif respecting the given settings
    #
    def createMotif(pNumUnitsPerMeasure, pSettingsCreation)
      return createBoundMotif(RangePairI.new(pSettingsCreation[:displacementLimit]).freeze, pNumUnitsPerMeasure, pSettingsCreation)
    end

    #
    # @param [Array<Hash>] pMotifs motif hashes
    #
    # @return [Integer] max peak of given motif hashes
    #
    def getPeakOfMotifs(pMotifs)
      return pMotifs.max { |m0, m1| m0[:peak] <=> m1[:peak] }[:peak]
    end

    #
    # @param [Array<Hash>] pMotifs motif hashes
    #
    # @return [Integer] min trough of given motif hashes
    #
    def getTroughOfMotifs(pMotifs)
      return pMotifs.min { |m0, m1| m0[:trough] <=> m1[:trough] }[:trough]
    end

    #
    # Returns a motif hash with the inverse properties of the given motif.
    #
    # @param [Hash] pMotif motif
    #
    # @return [Hash] inverted motif
    #
    def invertMotif(pMotif)
      return makeMotif(pMotif[:notes].map { |note| invertNote(note) })
    end

    #
    # Used for diagnosis.
    #
    # @param [Hash] pMotif motif hash
    #
    # @return [Array<Array<Integer>>] array of arrays containing displacement and span at indices 0 and 1 respectively
    #
    def makeArraysFromMotif(pMotif)
      # @type [Array<Array<Integer>>]
      arrays = pMotif[:notes].map { |note| makeArrayFromNote(note) }.freeze

      return arrays
    end

    #
    # Used for custom motifs.
    #
    # @param [Array<Array<Integer>>] pArrays array of arrays containing displacement and span at indices 0 and 1 respectively
    #
    # @return [Hash] motif hash
    #
    def makeMotifFromArrays(pArrays)
      # @type [Array<Hash>]
      notes = pArrays.map { |array| makeNote(array[0], array[1]) }.freeze

      return makeMotif(notes)
    end

    #
    # Makes a motif hash from the given notes. A motif is a musical molecule. It has an array of featureful notes, a peak, and a trough.
    #
    # @param [Array<Hash>] pNotes array of note hashes
    #
    # @return [Hash] a motif hash
    #
    def makeMotif(pNotes)
      # @type [Array<Hash>]
      zeroedNotes = zeroNotes(pNotes)
      return {
        notes: zeroedNotes,
        peak: getPeakOfNotes(zeroedNotes),
        trough: getTroughOfNotes(zeroedNotes),
      }.freeze
    end

    #
    # Returns a motif hash with the retrograde properties of the given motif.
    #
    # @param [Hash] pMotif motif
    #
    # @return [Hash] retrograde motif
    #
    def retrogradeMotif(pMotif)
      return makeMotif(pMotif[:notes].reverse)
    end

    # note hashes

    #
    # Creates an initial note hash, which can have a nil displacement if the set chance of such evaluates true.
    #
    # @param [Integer] pSpan span
    # @param [Hash] pSettingsCreation creation settings
    #
    # @return [Hash] initial note hash
    #
    def createInitialNote(pSpan, pSettingsCreation)
      if pSettingsCreation[:chanceCreateNilFeature].evalChance?
        return makeNote(nil, pSpan)
      else
        return makeNote(0, pSpan)
      end
    end

    #
    # Creates a random note whose displacement is bound by preceding note hashes so as to not exceed a set displacement interval limit.
    #
    # @param [Array<Hash>] pNotes preceding note hashes
    # @param [RangePairI] pBounds max and min displacements
    # @param [Integer] pSpan span of note hash to create
    # @param [Hash] pSettingsCreation creation settings
    #
    # @return [Hash] a random note hash bound by preceding note hashes so as to not exceed the set displacement interval limit
    #
    def createNextBoundNote(pNotes, pBounds, pSpan, pSettingsCreation)
      return createInitialNote(pSpan, pSettingsCreation) if pNotes.all? { |note| note[:displacement].nil? }

      # @type [Integer]
      previousDisplacement = getLastFeatureOfNotes(pNotes)
      # @type [Array<Integer>]
      displacementIntervals = RangePairI.new(pSettingsCreation[:displacementIntervalLimit]).toRangeA.freeze
      displacementIntervals = filterDisplacementIntervalsForCompatibility(displacementIntervals, pNotes, pBounds, pSettingsCreation)
      displacementIntervals -= [0] if pSettingsCreation[:chanceCreateNoConsecutivelyRepeatedDisplacements].evalChance?

      # @type [Integer]
      displacement = nil
      unless displacementIntervals.empty? || pSettingsCreation[:chanceCreateNilFeature].evalChance?
        if pNotes.last[:displacement].nil?
          displacement = previousDisplacement + displacementIntervals.choose
        else
          displacement = previousDisplacement + chooseAbsIntWithWeight(pSettingsCreation[:weightForDisplacementIntervals], displacementIntervals)
        end
      end

      return makeNote(displacement, pSpan)
    end

    #
    # Filters the given displacement intervals so that the remaining intervals are within the set displacement limit when taken together with the given preceding note hashes.
    #
    # @param [Array<Integer>] pDisplacementIntervals displacement intervals
    # @param [Array<Hash>] pNotes preceding note hashes
    # @param [RangePairI] pBounds max and min displacements
    # @param [Hash] pSettingsCreation creation settings
    #
    # @return [Array<Integer>] intervals that are within the set displacement limit when taken together with the given preceding note hashes
    #
    def filterDisplacementIntervalsForCompatibility(pDisplacementIntervals, pNotes, pBounds, pSettingsCreation)
      # @type [Integer]
      peak = getPeakOfNotes(pNotes)
      # @type [Integer]
      trough = getTroughOfNotes(pNotes)
      # @type [Integer]
      distance = peak - trough
      # @type [Integer]
      leeway = pSettingsCreation[:displacementLimit] - distance
      # @type [Integer]
      maxPeak = getMin((peak + leeway), pBounds.max)
      # @type [Integer]
      minTrough = getMax((trough - leeway), pBounds.min)
      # @type [Integer]
      previousDisplacement = getLastFeatureOfNotes(pNotes)

      return pDisplacementIntervals.select { |di| (previousDisplacement + di).between?(minTrough, maxPeak) }.freeze
    end

    #
    # @param [Array<Hash>] pNotes note hashes
    #
    # @return [Array<Integer>] displacements of given note hashes
    #
    def getDisplacementsOfNotes(pNotes)
      return pNotes.map { |note| note[:displacement] }
    end

    #
    # @param [Array<Hash>] pNotes note hashes
    #
    # @return [Integer] last non-nil displacement of note hashes
    #
    def getLastFeatureOfNotes(pNotes)
      return pNotes.reverse_each.detect { |note| !note[:displacement].nil? }[:displacement]
    end

    #
    # @param [Array<Hash>] pNotes note hashes
    #
    # @return [Integer] max displacement of the given note hashes
    #
    def getPeakOfNotes(pNotes)
      return getDisplacementsOfNotes(pNotes).compact.max
    end

    #
    # @param [Array<Hash>] pNotes note hashes
    #
    # @return [Integer] min displacement of the given note hashes
    #
    def getTroughOfNotes(pNotes)
      return getDisplacementsOfNotes(pNotes).compact.min
    end

    #
    # Returns a note whose displacement is flipped from the given note.
    #
    # @param [Hash] pNote note hash
    #
    # @return [Hash] inverted note
    #
    def invertNote(pNote)
      return pNote if pNote[:displacement].nil?
      return makeNote(-pNote[:displacement], pNote[:span])
    end

    #
    # Used for diagnosis.
    #
    # @param [Hash] pNote note hash
    #
    # @return [Array<Integer>] array containing displacement and span at indices 0 and 1 respectively
    #
    def makeArrayFromNote(pNote)
      # @type [Array<Integer>]
      array = [pNote[:displacement], pNote[:span]].freeze

      return array
    end

    #
    # Creates a note hash. A note is a musical atom. It has a displacement and a span.
    #
    # @param [Integer, NilClass] pDisplacement spatial property
    # @param [Integer, NilClass] pSpan temporal property
    #
    # @return [Hash] note hash
    #
    def makeNote(pDisplacement, pSpan)
      return {
        displacement: pDisplacement,
        span: pSpan,
      }.freeze
    end

    #
    # @param [Hash] pNote note hash
    # @param [Integer] pDistance distance to transpose
    #
    # @return [Hash] note hash transposed by the given distance
    #
    def transposeNote(pNote, pDistance)
      return pNote if pNote[:displacement].nil? || pDistance.zero?

      return makeNote((pNote[:displacement] + pDistance), pNote[:span])
    end

    #
    # Transposes all the given note hashes by the given distance.
    #
    # @param [Array<Hash>] pNotes note hashes
    # @param [Integer] pDistance transposition distance
    #
    # @return [Array<Hash>] transposed note hashes
    #
    def transposeNotes(pNotes, pDistance)
      if pDistance.zero?
        return pNotes
      else
        return pNotes.map { |note| transposeNote(note, pDistance) }.freeze
      end
    end

    #
    # Transposes the given note hashes so that the first encountered feature has a displacement of zero.
    #
    # @param [Array<Hash>] pNotes note hashes
    #
    # @return [Array<Hash>] zeroed note hashes
    #
    def zeroNotes(pNotes)
      return transposeNotes(pNotes, -pNotes.detect { |note| !note[:displacement].nil? }[:displacement]).freeze
    end

    # impure functions

    #
    # Either creates a motif hash if none are in the time-state or the chance to create a one time motif evaluates true, or retrieves a time-state motif hash and transforms it if the chance to do so evaluates true.
    #
    # @return [Hash] original motif hash or possibly transformed time-state hash
    #
    def ideate
      if get(-"motifs").empty? || Settings::IDEATION[:chanceCreateOneTimeMotif].evalChance?
        return createMotif(Settings::TIMEKEEPING[:numUnitsPerMeasure], Settings::CREATION)
      else
        # @type [Hash]
        motif = get(-"motifs").choose

        if Settings::IDEATION[:chanceInvertMotif].evalChance?
          motif = invertMotif(motif)
        end
        if Settings::IDEATION[:chanceRetrogradeMotif].evalChance?
          motif = retrogradeMotif(motif)
        end

        return motif
      end
    end

    # constants

    # Motif with one note, which note is zeroed and indefinite.
    INFINITUM = makeMotif([makeNote(0, nil)].freeze)
  end
end
