module Polyphony
  #
  # Utility methods.
  #
  module Utils

    #
    # Allows evaluation of chance based on numeric value
    #
    module Chance
      #
      # Evaluates chance based on self
      #
      # @return [TrueClass, FalseClass] true if chance of self evaluates true
      #
      def evalChance?
        return ((self >= 1) || ((self > 0) && (rand() < self)))
      end
    end

    #
    # Allows generation of range array from zero
    #
    module IntegerUtils
      #
      # Convert integer self to range array from zero
      #
      # @return [Array<Integer>] range array from zero to self
      #
      def toRangeAFromZero
        return (0...self).to_a.freeze
      end

      #
      # Convert integer self to range from zero
      #
      # @return [Range] range from zero to self
      #
      def toRangeFromZero
        return (0...self).freeze
      end
    end

    #
    # Pair of min and max
    #
    class RangePair
      attr_reader :min, :max

      #
      # Creates RangePair with min and max values, or mirror of first value if only one value is given
      #
      # @param [Numeric] pMin minimum
      # @param [Numeric, NilClass] pMax maximum
      #
      def initialize(pMin, pMax = nil)
        if pMax.nil?
          # @type [Numeric]
          @min = -(pMin.abs)
          # @type [Numeric]
          @max = pMin.abs
        else
          # @type [Numeric]
          @min = pMin
          # @type [Numeric]
          @max = pMax
        end
      end
    end

    #
    # Pair of min and max floats
    #
    class RangePairF < RangePair
      #
      # Gets random float value between min and max
      #
      # @return [Float] random value between min and max
      #
      def get
        return rrand(@min, @max)
      end

      #
      # Returns true if objects share the same min and max and are both RangePairF objects
      #
      # @param [Object] pOther object to compare with this
      #
      # @return [TrueClass, FalseClass] true if objects share the same min and max and are both RangePairF objects
      #
      def ==(pOther)
        return false if pOther.nil?
        return false unless pOther.instance_of?(RangePairF)
        return (@min == pOther.min) && (@max == pOther.max)
      end
    end

    #
    # Pair of min and max ints
    #
    class RangePairI < RangePair
      #
      # Gets random int value between min and max
      #
      # @return [Integer] random value between min and max
      #
      def get
        return rrand_i(@min, @max)
      end

      #
      # Gets range between min and max
      #
      # @return [RangePair] range between min and max
      #
      def toRange
        return (@min..@max).freeze
      end

      #
      # Gets range array between min and max
      #
      # @return [Array<Integer>] array of int values between min and max
      #
      def toRangeA
        return toRange().to_a.freeze
      end

      #
      # Returns true if objects share the same min and max and are both RangePairI objects
      #
      # @param [Object] pOther object to compare with this
      #
      # @return [TrueClass, FalseClass] true if objects share the same min and max and are both RangePairI objects
      #
      def ==(pOther)
        return false if pOther.nil?
        return false unless pOther.instance_of?(RangePairI)
        return @min == pOther.min && @max == pOther.max
      end
    end

    #
    # Chooses int from given values, favouring large or small absolute values depending on whether weight is positive or negative
    #
    # @param [Float] pWt weight between -1 and 1
    # @param [Array<Integer>] pInts array of ints to choose from
    #
    # @return [Integer] selection
    #
    def chooseAbsIntWithWeight(pWt, pInts)
      if (pWt.zero? || (pInts.length < 2))
        return pInts.choose
      else
        # @type [Integer]
        minAbsInt = pInts.min { |a, b| (a.abs <=> b.abs) }.abs
        # @type [Integer]
        maxAbsInt = pInts.max { |a, b| (a.abs <=> b.abs) }.abs
        # @type [Array<Integer>]
        weightedPool = []
        while weightedPool.empty?
          if (pWt < 0)
            weightedPool = pInts.select { |i| (i.abs <= rrandIWithWeight(pWt, minAbsInt, maxAbsInt)) }
          else
            weightedPool = pInts.select { |i| (i.abs >= rrandIWithWeight(pWt, minAbsInt, maxAbsInt)) }
          end
        end

        return weightedPool.choose
      end
    end

    #
    # Get larger value
    #
    # @param [Numeric] pA value
    # @param [Numeric] pB other value
    #
    # @return [Numeric] larger value
    #
    def getMax(pA, pB)
      return ((pA > pB) ? pA : pB)
    end

    #
    # Get smaller value
    #
    # @param [Numeric] pA value
    # @param [Numeric] pB other value
    #
    # @return [Numeric] smaller value
    #
    def getMin(pA, pB)
      return ((pA < pB) ? pA : pB)
    end

    #
    # Returns array of contiguous ranges from the given ascending array
    #
    # @param [Array<Integer>] pAscendingArray ascending integers
    #
    # @return [Array<Array<Integer>>] array of contiguous ranges
    #
    def getRangeArraysInAscendingArray(pAscendingArray)
      if pAscendingArray.empty?
        return [].freeze
      end

      # @type [Integer]
      i = 0
      # @type [Array<RangePairI>]
      ranges = []
      pAscendingArray.length.times do
        start = i
        while (((i + 1) != pAscendingArray.length) && ((pAscendingArray[i + 1] - pAscendingArray[i]) == 1))
          i += 1
        end
        ranges.push((pAscendingArray[start]..pAscendingArray[i]).to_a.freeze)
        if ((i + 1) == pAscendingArray.length)
          break
        else
          i += 1
        end
      end

      return ranges.freeze
    end

    #
    # Gets indices of true in Sonic Pi ring of boolean values
    #
    # @param [Ring] pBoolsRing Sonic Pi ring of boolean values
    #
    # @return [Array<Integer>] indices of true
    #
    def getTrueIndices(pBoolsRing)
      return pBoolsRing.to_a.each_index.select { |i| pBoolsRing[i] }.freeze
    end

    #
    # Returns random int between 0 and given max, favouring large or small values depending on whether weight is positive or negative
    #
    # @param [Float] pWt weight between -1 and 1
    # @param [Integer] pMax max value inclusive
    #
    # @return [Integer] random int between 0 and given max, favouring large or small values depending on whether weight is positive or negative
    #
    def randIWithWeight(pWt, pMax = 1)
      return randWithWeight(pWt, (pMax + 1)).to_i
    end

    #
    # Returns random float between 0 and given max, favouring large or small values depending on whether weight is positive or negative
    #
    # solution adapted from Jochen Hertle: https://in-thread.sonic-pi.net/t/choosing-random-ints-favouring-large-small/5234/2?u=d0lfyn
    #
    # @param [Float] pWt weight between -1 and 1
    # @param [Float] pMax max value exclusive
    #
    # @return [Float] random float between 0 and given max, favouring large or small values depending on whether weight is positive or negative
    #
    def randWithWeight(pWt, pMax = 1)
      if ((pWt < -1) || (pWt > 1))
        return nil
      elsif pWt.zero?
        return rand(pMax)
      else
        return (pMax * (0.5 * (pWt + Math.sqrt(pWt**2 + 4*pWt*rand() - 2*pWt + 1) - 1) / pWt.to_f))
      end
    end

    #
    # Returns random int between min and max, favouring large or small values depending on whether weight is positive or negative
    #
    # @param [Float] pWt weight between -1 and 1
    # @param [Integer] pMin min value inclusive
    # @param [Integer] pMax max value inclusive
    #
    # @return [Integer] random int between min and max, favouring large or small values depending on whether weight is positive or negative
    #
    def rrandIWithWeight(pWt, pMin, pMax)
      return (randIWithWeight(pWt, (pMax - pMin)) + pMin)
    end

    #
    # Returns random float between min and max, favouring large or small values depending on whether weight is positive or negative
    #
    # @param [Float] pWt weight between -1 and 1
    # @param [Float] pMin min value inclusive
    # @param [Float] pMax max value exclusive
    #
    # @return [Float] random float between min and max, favouring large or small values depending on whether weight is positive or negative
    #
    def rrandWithWeight(pWt, pMin, pMax)
      return (randWithWeight(pWt, (pMax - pMin)) + pMin)
    end
  end
end

Integer.include Polyphony::Utils::IntegerUtils
Numeric.include Polyphony::Utils::Chance
