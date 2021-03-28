require_relative "utils"

module Polyphony
  #
  # Methods for generating rhythmic patterns.
  #
  module Rhythm
    extend self
    include Polyphony::Utils
    include SonicPi::Lang::Core

    # pure functions

    #
    # @param [Array<Integer>] pOffsets offsets
    # @param [Integer] pNumUnits total number of units
    #
    # @return [Array<Integer>] spans based on offsets
    #
    def convertOffsetsToSpans(pOffsets, pNumUnits)
      # @type [Array<Integer>]
      offsets = pOffsets + [pNumUnits]
      # @type [Array<Integer>]
      spans = []
      (offsets.length - 1).toRangeFromZero.each do |i|
        spans.push(offsets[i + 1] - offsets[i])
      end

      return spans.freeze
    end

    #
    # @param [Integer] pNumUnits total number of units
    # @param [Float] pWeightForSpans weight affecting span value
    #
    # @return [Array<Integer>] rhythmic divisions of number of units
    #
    def divideUnitsRhythmically(pNumUnits, pWeightForSpans)
      return 1 if (pNumUnits == 1)

      # @type [Integer]
      numRhythmicDivisions = chooseAbsIntWithWeight(-pWeightForSpans, (1..(pNumUnits / 2)).to_a)
      # @type [Array<Integer>]
      offsets = getTrueIndices(spread(numRhythmicDivisions, pNumUnits, rotate: rand_i(numRhythmicDivisions)))
      # @type [Array<Integer>]
      divisions = convertOffsetsToSpans(offsets, pNumUnits)

      return divisions.freeze
    end

    #
    # @param [Integer] pNumRhythms number of rhythms forming the polyrhythm
    # @param [RangePairI] pRangeNumRhythmicDivisions range of rhythmic divisions
    # @param [Integer] pNumUnitsPerMeasure number of units per measure
    #
    # @return [Array<Integer>] composite rhythm calculated from parameters
    #
    def getCompositeRhythm(pNumRhythms, pRangeNumRhythmicDivisions, pNumUnitsPerMeasure)
      # @type [Array<Integer>]
      compositeRhythm = []
      pNumRhythms.times do
        # @type [Integer]
        numRhythmicDivisions = pRangeNumRhythmicDivisions.get
        compositeRhythm = compositeRhythm.union(getTrueIndices(spread(numRhythmicDivisions, pNumUnitsPerMeasure, rotate: rand_i(numRhythmicDivisions))))
      end

      return compositeRhythm.sort.freeze
    end

    #
    # @param [Array<Integer] pDivisions divisions
    #
    # @return [Array<Integer>] divisions whose first element is greater than 1, merged from the given
    #
    def mergeBriefStart(pDivisions)
      unless (pDivisions.first == 1)
        return pDivisions
      else
        # @type [Array<Integer>]
        divisions = pDivisions.drop(1)
        divisions[0] = (pDivisions[0] + pDivisions[1])

        return divisions.freeze
      end
    end

    #
    # @param [Integer] pNumUnits total number of units
    # @param [Float] pWeightForSpans weight affecting span value
    #
    # @return [Array<Integer>] rhythmic subdivisions of number of units
    #
    def subdivideUnitsRhythmically(pNumUnits, pWeightForSpans)
      return 1 if (pNumUnits == 1)

      # @type [Integer]
      numRhythmicSubdivisions = chooseAbsIntWithWeight(-pWeightForSpans, (1..pNumUnits).to_a)
      # @type [Array<Integer>]
      offsets = getTrueIndices(spread(numRhythmicSubdivisions, pNumUnits, rotate: rand_i(numRhythmicSubdivisions)))
      # @type [Array<Integer>]
      subdivisions = convertOffsetsToSpans(offsets, pNumUnits)

      return subdivisions.freeze
    end
  end
end
