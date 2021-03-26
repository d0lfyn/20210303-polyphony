module Polyphony
  #
  # Methods for arranging and improvising musical ideas to form symbols.
  #
  module Composition
    extend self

    # pure functions

    #
    # @param [Array<Hash>] pSyntheses array of synthesis hashes
    # @param [Integer] pChordRoot chord root
    # @param [Integer] pTonicity tonicity
    #
    # @return [TrueClass, FalseClass] true if any of the given synthesis hashes' positions is a general chord root
    #
    def areAnySynthesesOnRoot?(pSyntheses, pChordRoot, pTonicity)
      return pSyntheses.any? { |s| isPositionAGeneralRoot?(s[:position], pChordRoot, pTonicity) }
    end

    #
    # Creates a synthesis and its associated motif hypotheses with the given settings.
    #
    # @param [Integer] pPosition synthesis position
    # @param [RangePairI] pBounds min and max displacements
    # @param [Hash] pSettingsCreation creation settings
    # @param [Hash] pSettingsIdeation ideation settings
    # @param [Hash] pSettingsTimekeeping timekeeping settings
    #
    # @return [Hash] synthesis respecting the given settings
    #
    def createBoundSynthesis(pPosition, pBounds, pSettingsCreation, pSettingsIdeation, pSettingsTimekeeping)
      # @type [Array<Hash>]
      hypotheses = pSettingsIdeation[:rangeNumMotifsToIdeate].get.toRangeAFromZero.map { |x| createBoundMotif(pBounds, pSettingsTimekeeping[:numUnitsPerMeasure], pSettingsCreation) }

      unless hypotheses.nil?
        return makeSynthesis(pPosition, hypotheses)
      else
        return nil
      end
    end

    #
    # Removes all positions from the given that would be unreachable by the given hypotheses, because of internal gaps or bounds out of reach.
    #
    # @param [Array<Integer>] pPositionsAvailable positions available
    # @param [Array<Hash>] pHypotheses hypotheses
    #
    # @return [Array<Integer>] positions reachable by the given hypotheses
    #
    def eliminateAllUnreachablePositions(pPositionsAvailable, pHypotheses)
      # @type [Array<Array<Integer>>]
      positionRangesRemaining = getRangeArraysInAscendingArray(pPositionsAvailable)
      positionRangesRemaining = positionRangesRemaining.map { |ra| eliminateUnreachablePositionsAtBounds(ra, pHypotheses) }.freeze

      return positionRangesRemaining.flatten.freeze
    end

    #
    # Removes all positions from the given such that the remaining positions would not overlap with the given hypotheses.
    #
    # @param [Array<Integer>] pPositionsAvailable positions available
    # @param [Array<Hash>] pSyntheses synthesis hashes
    # @param [Array<Hash>] pHypotheses hypotheses
    #
    # @return [Array<Integer>] remaining positions that wouldn't overlap with the given hypotheses
    #
    def eliminateHypotheticalOverlap(pPositionsAvailable, pSyntheses, pHypotheses)
      # @type [Array<Integer>]
      positionsRemaining = eliminateOverlap(pPositionsAvailable, pSyntheses)
      positionsRemaining = eliminateAllUnreachablePositions(positionsRemaining, pHypotheses)

      return positionsRemaining
    end

    #
    # Removes all positions from the given such that the remaining positions would not overlap with the given hypotheses except at edges.
    #
    # @param [Array<Integer>] pPositionsAvailable positions available
    # @param [Array<Hash>] pSyntheses synthesis hashes
    # @param [Array<Hash>] pHypotheses hypotheses
    #
    # @return [Array<Integer>] remaining positions that wouldn't overlap with the given hypotheses except at edges
    #
    def eliminateHypotheticalOverlapExceptEdges(pPositionsAvailable, pSyntheses, pHypotheses)
      # @type [Array<Integer>]
      positionsRemaining = eliminateOverlapExceptEdges(pPositionsAvailable, pSyntheses)
      positionsRemaining = eliminateAllUnreachablePositions(positionsRemaining, pHypotheses)

      return positionsRemaining
    end

    #
    # Removes all positions from the given such that the remaining positions would not spatially conflict with the given hypotheses.
    #
    # @param [Array<Integer>] pPositionsAvailable positions available
    # @param [Array<Hash>] pSyntheses synthesis hashes
    # @param [Array<Hash>] pHypotheses hypotheses
    #
    # @return [Array<Integer>] remaining positions that wouldn't conflict spatially with the given hypotheses
    #
    def eliminateHypotheticalOverlapExceptSpaces(pPositionsAvailable, pSyntheses, pHypotheses)
      # @type [Array<Integer>]
      positionsRemaining = eliminateOverlap(pPositionsAvailable, pSyntheses)

      # @type [Array<Integer>]
      positionsReachable = eliminateOverlapExceptSpaces(pPositionsAvailable, pSyntheses)
      # @type [Array<Integer>]
      positionsReachable = eliminateAllUnreachablePositions(positionsReachable, pHypotheses)

      return positionsRemaining.intersection(positionsReachable).freeze
    end

    #
    # Removes all positions from the given that are covered by the given synthesis hashes.
    #
    # @param [Array<Integer>] pPositionsAvailable positions available
    # @param [Array<Hash>] pSyntheses synthesis hashes
    #
    # @return [Array<Integer>] positions remaining
    #
    def eliminateOverlap(pPositionsAvailable, pSyntheses)
      # @type [Array<Integer>]
      positionsCovered = getPositionsCoveredBySyntheses(pSyntheses)
      # @type [Array<Integer>]
      positionsRemaining = (pPositionsAvailable - positionsCovered).freeze

      return positionsRemaining
    end

    #
    # Removes all positions from the given that are covered by the given synthesis hashes, excluding their edges.
    #
    # @param [Array<Integer>] pPositionsAvailable positions available
    # @param [Array<Hash>] pSyntheses synthesis hashes
    #
    # @return [Array<Integer>] positions remaining
    #
    def eliminateOverlapExceptEdges(pPositionsAvailable, pSyntheses)
      # @type [Array<Integer>]
      positionsCovered = getInnerPositionsCoveredBySyntheses(pSyntheses)
      # @type [Array<Integer>]
      positionsRemaining = (pPositionsAvailable - positionsCovered).freeze

      return positionsRemaining
    end

    #
    # Removes only the positions of the given synthesis hashes.
    #
    # @param [Array<Integer>] pPositionsAvailable positions available
    # @param [Array<Hash>] pSyntheses synthesis hashes
    #
    # @return [Array<Integer>] positions remaining
    #
    def eliminateOverlapExceptSpaces(pPositionsAvailable, pSyntheses)
      # @type [Array<Integer>]
      positionsReachable = (pPositionsAvailable - getSyntheticPositions(pSyntheses)).freeze

      return positionsReachable
    end

    #
    # Removes all positions from the given that would be unreachable by the given hypotheses, because of bounds out of reach.
    #
    # @param [Array<Integer>] pPositionsAvailable positions available
    # @param [Array<Hash>] pHypotheses hypotheses
    #
    # @return [Array<Integer>] positions reachable by the given hypotheses
    #
    def eliminateUnreachablePositionsAtBounds(pPositionsAvailable, pHypotheses)
      # @type [Integer]
      allMotifsPeak = getPeakOfMotifs(pHypotheses)
      # @type [Integer]
      allMotifsTrough = getTroughOfMotifs(pHypotheses)
      # @type [Array<Integer>]
      positionsRemaining = ((-allMotifsTrough < pPositionsAvailable.length) ? pPositionsAvailable.drop(-allMotifsTrough) : []).freeze
      positionsRemaining = ((allMotifsPeak < positionsRemaining.length) ? positionsRemaining.take((positionsRemaining.length - allMotifsPeak)) : []).freeze

      return positionsRemaining
    end

    #
    # Returns a synthesis created to fill a space domain gap determined with the given synthesis hashes and settings. This involves finding space and determining an appropriate position in that space. If no space is available, returns nil.
    #
    # @param [Array<Hash>] pSyntheses synthesis hashes
    # @param [Ring] pSpaceDomain all positions available
    # @param [Integer] pTonicity tonicity (e.g. heptatonic = 7)
    # @param [RangePairI] pInstrumentSpaceDomainRangePair positions playable by an instrument
    # @param [Integer] pChordRoot chord root
    # @param [Hash] pSettingsComposition composition settings
    # @param [Hash] pSettingsCreation creation settings
    # @param [Hash] pSettingsIdeation ideation settings
    # @param [Hash] pSettingsTimekeeping timekeeping settings
    #
    # @return [Hash, NilClass] synthesis that fills an appropriate gap, or nil if no such gap exists
    #
    def fillGapInSyntheses(pSyntheses, pSpaceDomain, pTonicity, pInstrumentSpaceDomainRangePair, pChordRoot, pSettingsComposition, pSettingsCreation, pSettingsIdeation, pSettingsTimekeeping)
      # @type [Array<Integer>]
      spaceAvailable = pInstrumentSpaceDomainRangePair.toRangeA
      spaceAvailable = removeSynthesisPositions(spaceAvailable, pSyntheses, pSettingsComposition)
      # @type [Array<Array<Integer>>]
      spaceRangeArrays = getRangeArraysInAscendingArray(spaceAvailable)

      # @type [Array<Integer>]
      positionsAvailable = eliminateOverlap(spaceAvailable, pSyntheses)
      positionsAvailable = removeProximatePositions(positionsAvailable, pSyntheses, pSpaceDomain, pSettingsComposition)
      positionsAvailable = removeNonChordPositions(positionsAvailable, pChordRoot, pTonicity, pSettingsComposition)
      positionsAvailable = removeNonRootPositions(positionsAvailable, pChordRoot, pTonicity) unless areAnySynthesesOnRoot?(pSyntheses, pChordRoot, pTonicity)
      positionsAvailable = removeDissonantPositions(positionsAvailable, pSyntheses, pSpaceDomain, pSettingsComposition)

      if positionsAvailable.empty?
        return nil
      else
        # @type [Integer]
        positionChosen = positionsAvailable.choose
        # @type [Array<Integer>]
        spaceRangeChosen = spaceRangeArrays[spaceRangeArrays.index { |sra| sra.include?(positionChosen) }]
        # @type [RangePairI]
        spaceRangePair = RangePairI.new((spaceRangeChosen.first - positionChosen), (spaceRangeChosen.last - positionChosen)).freeze

        return createBoundSynthesis(positionChosen, spaceRangePair, pSettingsCreation, pSettingsIdeation, pSettingsTimekeeping)
      end
    end

    #
    # Returns all positions in the space domain that can fit the given hypotheses, after removing all inappropriate positions, as determined from the settings.
    #
    # @param [Array<Hash>] pHypotheses hypothetical motif hashes
    # @param [Array<Hash>] pSyntheses synthesis hashes
    # @param [Ring] pSpaceDomain all positions available
    # @param [Integer] pTonicity tonicity (e.g. heptatonic = 7)
    # @param [RangePairI] pInstrumentSpaceDomainRangePair positions playable by instrument
    # @param [Integer] pChordRoot chord root
    # @param [Hash] pSettingsComposition composition settings
    #
    # @return [Array<Integer>] all positions available to fit the given hypotheses
    #
    def getAllPositionsFittingHypotheses(pHypotheses, pSyntheses, pSpaceDomain, pTonicity, pInstrumentSpaceDomainRangePair, pChordRoot, pSettingsComposition)
      # @type [Array<Integer>]
      positionsAvailable = pInstrumentSpaceDomainRangePair.toRangeA
      positionsAvailable = removePreliminaryPositions(positionsAvailable, pHypotheses, pSyntheses, pSettingsComposition)
      positionsAvailable = removeProximatePositions(positionsAvailable, pSyntheses, pSpaceDomain, pSettingsComposition)
      positionsAvailable = removeNonChordPositions(positionsAvailable, pChordRoot, pTonicity, pSettingsComposition)
      positionsAvailable = removeNonRootPositions(positionsAvailable, pChordRoot, pTonicity) unless areAnySynthesesOnRoot?(pSyntheses, pChordRoot, pTonicity)
      positionsAvailable = removeDissonantPositions(positionsAvailable, pSyntheses, pSpaceDomain, pSettingsComposition)

      return positionsAvailable
    end

    #
    # @param [Array<Hash>] pSyntheses synthesis hashes
    #
    # @return [Array<Integer>] inner positions (i.e. not including edges) covered by the given synthesis hashes
    #
    def getInnerPositionsCoveredBySyntheses(pSyntheses)
      return pSyntheses.map { |s| getInnerPositionsCoveredBySynthesis(s) }.flatten.uniq.freeze
    end

    #
    # @param [Hash] pSynthesis synthesis hash
    #
    # @return [Array<Integer>] all positions covered by the given synthesis, excluding edges
    #
    def getInnerPositionsCoveredBySynthesis(pSynthesis)
      return ((pSynthesis[:trough] + 1)...pSynthesis[:peak]).to_a.freeze
    end

    #
    # @param [Array<Hash>] pSyntheses synthesis hashes
    #
    # @return [Array<Integer>] positions (i.e. including edges) covered by the given synthesis hashes
    #
    def getPositionsCoveredBySyntheses(pSyntheses)
      return pSyntheses.map { |s| getPositionsCoveredBySynthesis(s) }.flatten.uniq.freeze
    end

    #
    # @param [Hash] pSynthesis synthesis hash
    #
    # @return [Array<Integer>] all positions covered by the given synthesis, including edges
    #
    def getPositionsCoveredBySynthesis(pSynthesis)
      return (pSynthesis[:trough]..pSynthesis[:peak]).to_a.freeze
    end

    #
    # @param [Array<Hash>] pSyntheses synthesis hashes
    #
    # @return [Array<Integer>] positions of the given synthesis hashes
    #
    def getSyntheticPositions(pSyntheses)
      return pSyntheses.map { |s| s[:position] }.freeze
    end

    #
    # @param [Integer] pPosition position
    # @param [Array<Hash>] pHypotheses hypothetical motif hashes
    #
    # @return [Hash] synthesis hash, containing a position, hypotheses, peak, and trough
    #
    def makeSynthesis(pPosition, pHypotheses)
      return {
        position: pPosition,
        hypotheses: pHypotheses,

        peak: pPosition + getPeakOfMotifs(pHypotheses),
        trough: pPosition + getTroughOfMotifs(pHypotheses),
      }.freeze
    end

    #
    # Removes all positions of the given that are dissonant with respect to the given synthesis hashes' positions.
    #
    # @param [Array<Integer>] pPositionsAvailable positions available
    # @param [Array<Hash>] pSyntheses synthesis hashes
    # @param [Ring] pSpaceDomain all positions available
    # @param [Hash] pSettingsComposition composition settings
    #
    # @return [Array<Integer>] all positions of the given that are consonant
    #
    def removeDissonantPositions(pPositionsAvailable, pSyntheses, pSpaceDomain, pSettingsComposition)
      return pPositionsAvailable.reject { |p| pSyntheses.any? { |s| arePositionsDissonant?(s[:position], p, pSpaceDomain, pSettingsComposition[:specificDissonances]) } }.freeze
    end

    #
    # Removes all positions of the given that do not belong to the chord whose root is the given and whose general positions are determined by the given settings.
    #
    # @param [Array<Integer>] pPositionsAvailable positions available
    # @param [Integer] pChordRoot chord root
    # @param [Integer] pTonicity tonicity (e.g. heptatonic = 7)
    # @param [Hash] pSettingsComposition composition settings
    #
    # @return [Array<Integer>] all positions of the given that belong to the chord specified by the givens
    #
    def removeNonChordPositions(pPositionsAvailable, pChordRoot, pTonicity, pSettingsComposition)
      return pPositionsAvailable.select { |p| isPositionInGeneralChord?(p, pChordRoot, pTonicity, pSettingsComposition[:generalPositionsOfChord]) }.freeze
    end

    #
    # Removes all positions of the given that are not chord roots, as specified by the givens.
    #
    # @param [Array<Integer>] pPositionsAvailable positions available
    # @param [Integer] pChordRoot chord root
    # @param [Integer] pTonicity tonicity (e.g. heptatonic = 7)
    #
    # @return [Array<Integer>] all positions of the given that are chord roots as specified by the givens
    #
    def removeNonRootPositions(pPositionsAvailable, pChordRoot, pTonicity)
      return pPositionsAvailable.select { |p| isPositionAGeneralRoot?(p, pChordRoot, pTonicity) }.freeze
    end

    #
    # Eliminates all positions of the given that are inappropriate, as specified by the given setting and as determined by the characteristics of the given hypotheses.
    #
    # @param [Array<Integer>] pPositionsAvailable positions available
    # @param [Array<Hash>] pHypotheses hypothetical motif hashes
    # @param [Array<Hash>] pSyntheses synthesis hashes
    # @param [Hash] pSettingsComposition composition settings
    #
    # @return [Array<Integer>] all appropriate positions of the given, as specified by the given setting and as determined by the characteristics of the given hypotheses
    #
    def removePreliminaryPositions(pPositionsAvailable, pHypotheses, pSyntheses, pSettingsComposition)
      case pSettingsComposition[:degreeOfOverlap]
      when 0
        return eliminateHypotheticalOverlap(pPositionsAvailable, pSyntheses, pHypotheses)
      when 1
        return eliminateHypotheticalOverlapExceptEdges(pPositionsAvailable, pSyntheses, pHypotheses)
      when 2
        return eliminateHypotheticalOverlapExceptSpaces(pPositionsAvailable, pSyntheses, pHypotheses)
      when 3
        return eliminateUnreachablePositions(pPositionsAvailable, pHypotheses)
      end
    end

    #
    # Removes all positions of the given that are too close to the given synthesis hashes' positions, frequency-wise.
    #
    # @param [Array<Integer>] pPositionsAvailable positions available
    # @param [Array<Hash>] pSyntheses synthesis hashes
    # @param [Ring] pSpaceDomain all positions available
    # @param [Hash] pSettingsComposition composition settings
    #
    # @return [Array<Integer>] all positions of the given that are not too close to the given synthesis hashes' positions, frequency-wise
    #
    def removeProximatePositions(pPositionsAvailable, pSyntheses, pSpaceDomain, pSettingsComposition)
      return pPositionsAvailable.reject { |p| pSyntheses.any? { |s| arePositionsProximate?(s[:position], p, pSpaceDomain, pSettingsComposition[:proximityLimit]) } }.freeze
    end

    #
    # Eliminates all inappropriate positions of the given, as specified by the given setting.
    #
    # @param [Array<Integer>] pPositionsAvailable positions available
    # @param [Array<Hash>] pSyntheses synthesis hashes
    # @param [Hash] pSettingsComposition composition settings
    #
    # @return [Array<Integer>] appropriate positions of the given, as specified by the given setting
    #
    def removeSynthesisPositions(pPositionsAvailable, pSyntheses, pSettingsComposition)
      case pSettingsComposition[:degreeOfOverlap]
      when 0
        return eliminateOverlap(pPositionsAvailable, pSyntheses)
      when 1
        return eliminateOverlapExceptEdges(pPositionsAvailable, pSyntheses)
      when 2
        return eliminateOverlapExceptSpaces(pPositionsAvailable, pSyntheses)
      when 3
        return pPositionsAvailable
      end
    end

    # impure functions

    #
    # Returns either a synthesis hash created by fitting the given hypotheses among the currently active synthesis hashes, accounting for the limits of the given voice's instrument, or nil if the given hypotheses cannot fit.
    #
    # @param [Integer] pVoiceNumber voice number
    # @param [Array<Hash>] pHypotheses hypothetical motif hashes
    #
    # @return [Hash, NilClass] synthesis hash that fits
    #
    def arrangeForArticulatedVoice(pVoiceNumber, pHypotheses)
      # @type [Ring]
      spaceDomain = getCurrentSpaceDomain()
      # @type [Array<Hash>]
      allActiveSyntheses = getAllActiveSyntheses()
      # @type [RangePairI]
      instrumentSpaceDomainRangePair = getInstrument(-"articulated", pVoiceNumber).getSpaceDomainRangePair(spaceDomain)

      # @type [Array<Integer>]
      positionsAvailable = getAllPositionsFittingHypotheses(pHypotheses, allActiveSyntheses, spaceDomain, getCurrentTonicity(), instrumentSpaceDomainRangePair, get(-"space/chordRoot"), Settings::COMPOSITION)
      # @type [Integer]
      position = positionsAvailable.choose

      unless position.nil?
        return makeSynthesis(position, pHypotheses) unless position.nil?
      else
        return nil
      end
    end

    #
    # Returns either a synthesis hash created by fitting the given hypotheses among the currently active synthesis hashes, accounting for the limits of the given voice's instrument, or nil if the given hypotheses cannot fit.
    #
    # @param [Integer] pVoiceNumber voice number
    # @param [Array<Hash>] pHypotheses hypothetical motif hashes
    #
    # @return [Hash, NilClass] synthesis hash that fits
    #
    def arrangeForSustainedVoice(pVoiceNumber, pHypotheses)
      # @type [Ring]
      spaceDomain = getCurrentSpaceDomain()
      # @type [Array<Hash>]
      allActiveSyntheses = getAllActiveSyntheses()
      # @type [RangePairI]
      instrumentSpaceDomainRangePair = getInstrument(-"sustained", pVoiceNumber).getSpaceDomainRangePair(spaceDomain)

      # @type [Array<Integer>]
      positionsAvailable = getAllPositionsFittingHypotheses(pHypotheses, allActiveSyntheses, spaceDomain, getCurrentTonicity(), instrumentSpaceDomainRangePair, get(-"space/chordRoot"), Settings::COMPOSITION)
      # @type [Integer]
      position = positionsAvailable.choose

      unless position.nil?
        return makeSynthesis(position, pHypotheses) unless position.nil?
      else
        return nil
      end
    end

    #
    # Creates a synthesis hash for the instrument of the given voice, to fill a gap among the currently active synthesis hashes in the current space domain. If no such gap exists, returns nil.
    #
    # @param [Integer] pVoiceNumber voice number
    #
    # @return [Hash, NilClass] synthesis that fills a gap, or nil if no such gap exists
    #
    def improviseArticulatedVoice(pVoiceNumber)
      # @type [Ring]
      spaceDomain = getCurrentSpaceDomain()
      # @type [Array<Hash>]
      allActiveSyntheses = getAllActiveSyntheses()
      # @type [RangePairI]
      instrumentSpaceDomainRangePair = getInstrument(-"articulated", pVoiceNumber).getSpaceDomainRangePair(spaceDomain)

      # @type [Hash]
      synthesis = fillGapInSyntheses(allActiveSyntheses, spaceDomain, getCurrentTonicity(), instrumentSpaceDomainRangePair, get(-"space/chordRoot"), Settings::COMPOSITION, Settings::CREATION, Settings::IDEATION, Settings::TIMEKEEPING)

      return synthesis
    end

    #
    # Sets all articulated voices' synthesis hashes to newly positioned synthesis hashes determined by the current time-state, or to nil if there is no place for an old synthesis hash in the current time-state.
    #
    # @param [Hash] pOriginalKey previous key signature
    #
    def rearrangeArticulatedVoices(pOriginalKey)
      # @type [Ring]
      spaceDomain = getCurrentSpaceDomain()
      # @type [Integer]
      tonicity = getCurrentTonicity()
      # @type [Array<Hash>]
      allArticulatedSyntheses = getAllVoicesSyntheses(-"articulated")
      # @type [Array<Hash>]
      allNewArticulatedSyntheses = Array.new(allArticulatedSyntheses.length, nil)
      # @type [Array<Hash>]
      addedSyntheses = []

      allArticulatedSyntheses.length.toRangeAFromZero.shuffle.each do |i|
        unless allArticulatedSyntheses[i].nil?
          # @type [RangePairI]
          instrumentSpaceDomainRangePair = getInstrument(-"articulated", i).getSpaceDomainRangePair(spaceDomain)

          # @type [Integer]
          oldPosition = allArticulatedSyntheses[i][:position]
          oldPosition = modulatePositionToKey(oldPosition, pOriginalKey, get(-"space/key"), Settings::SPACE)
          # @type [Array<Hash>]
          hypotheses = allArticulatedSyntheses[i][:hypotheses]

          # @type [Array<Integer>]
          newPositionsAvailable = getAllPositionsFittingHypotheses(hypotheses, addedSyntheses, spaceDomain, tonicity, instrumentSpaceDomainRangePair, get(-"space/chordRoot"), Settings::COMPOSITION)
          # @type [Array<Integer>]
          newPositionIntervalsAvailable = newPositionsAvailable.map { |np| (np - oldPosition) }.freeze
          newPositionIntervalsAvailable = newPositionIntervalsAvailable.reject { |npi| (npi.abs > Settings::SPACE[:maxPositionInterval]) }.freeze
          # @type [Integer]
          newPosition = (oldPosition + chooseAbsIntWithWeight(Settings::SPACE[:weightForPositionIntervals], newPositionIntervalsAvailable)) unless newPositionIntervalsAvailable.empty?

          unless newPosition.nil?
            # @type [Hash]
            newSynthesis = makeSynthesis(newPosition, hypotheses)
            allNewArticulatedSyntheses[i] = newSynthesis
            addedSyntheses.push(newSynthesis)
          end

          logMessage("articulated #{i.to_s} switching from #{oldPosition.to_s} to #{newPosition.to_s}")
        end
      end

      setAllVoicesSyntheses(-"articulated", allNewArticulatedSyntheses)
    end

    #
    # Rearranges articulated voices' synthesis hashes based on the current time-state.
    #
    # @param [Hash] pOriginalKey previous key signature
    #
    def recompose(pOriginalKey)
      rearrangeArticulatedVoices(pOriginalKey)
    end
  end
end
