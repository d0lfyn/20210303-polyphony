module Polyphony
  #
  # Methods for managing space relationships.
  #
  module Space
    extend self

    # pure functions

    #
    # Given two positions, a space domain, and specific dissonances, the positions are evaluated to determine if they are dissonant with respect to each other. True is returned if they are.
    #
    # @param [Integer] pPosition0 position
    # @param [Integer] pPosition1 other position
    # @param [Ring] pSpaceDomain all positions available
    # @param [Array<Integer>] pSpecificDissonances specific dissonances
    #
    # @return [TrueClass, FalseClass] true if the positions are dissonant with respect to each other
    #
    def arePositionsDissonant?(pPosition0, pPosition1, pSpaceDomain, pSpecificDissonances)
      # @type [Integer]
      absoluteInterval = (calculatePitch(pPosition1, pSpaceDomain) - calculatePitch(pPosition0, pSpaceDomain)).abs

      return pSpecificDissonances.any? { |d| (d == absoluteInterval) }
    end

    #
    # Given two positions, a space domain, and a proximity limit, the positions are evaluated to determine if they are too close to each other frequency-wise. True is returned if they are.
    #
    # @param [Integer] pPosition0 position
    # @param [Integer] pPosition1 other position
    # @param [Ring] pSpaceDomain all positions available
    # @param [Float] pProximityLimit closest permissible distance
    #
    # @return [TrueClass, FalseClass] true if the positions are too close to each other
    #
    def arePositionsProximate?(pPosition0, pPosition1, pSpaceDomain, pProximityLimit)
      # @type [Float]
      frequencyDifference = (midi_to_hz(calculatePitch(pPosition1, pSpaceDomain)) - midi_to_hz(calculatePitch(pPosition0, pSpaceDomain))).abs

      return frequencyDifference <= pProximityLimit
    end

    #
    # Calculates the resulting key of a modulation to the given chord root position. The resulting modulation may either be through a pivot chord or a common-tone chord.
    #
    # @param [Ring] pSpaceDomain all positions available prior to the modulation
    # @param [Integer] pChordRoot chord root
    # @param [Hash] pSettingsSpace space settings
    #
    # @return [Hash] a new key
    #
    def calculateModulationToChordRoot(pSpaceDomain, pChordRoot, pSettingsSpace)
      # @type [Integer]
      newTonic = ((calculatePitch(pChordRoot, pSpaceDomain) % 12))
      # @type [Integer]
      newThird =  ((calculatePitch((pChordRoot + 2), pSpaceDomain) % 12))
      # @type [Integer]
      newFifth =  ((calculatePitch((pChordRoot + 4), pSpaceDomain) % 12))

      if pSettingsSpace[:chanceModulateWithPivot].evalChance?
        if (((newThird - newTonic) == 4) || ((newTonic - newThird) == 8))
          return makeKey(newTonic, pSettingsSpace[:majorScales].choose)
        else
          if (((newFifth - newTonic) == 6) || ((newTonic - newFifth) == 6))
            return makeKey(newTonic, pSettingsSpace[:diminishedScales].choose)
          else
            return makeKey(newTonic, pSettingsSpace[:minorScales].choose)
          end
        end
      else
        return makeKey(newTonic, (pSettingsSpace[:majorScales] + pSettingsSpace[:minorScales] + pSettingsSpace[:diminishedScales]).choose)
      end
    end

    #
    # @param [Integer, NilClass] pPosition position
    # @param [Ring] pSpaceDomain all positions available
    #
    # @return [Integer, NilClass] the pitch of the given position in the given space domain
    #
    def calculatePitch(pPosition, pSpaceDomain)
      return pPosition.nil? ? nil : pSpaceDomain[pPosition]
    end

    #
    # Converts from a pitch to the nearest equal or higher position within the given space domain. Returns nil if the pitch is beyond the space domain.
    #
    # @param [Integer] pPitch pitch
    # @param [Ring] pSpaceDomain all positions available
    #
    # @return [Integer, NilClass] nearest equal or higher position within the given space domain
    #
    def getPositionAtOrAbovePitch(pPitch, pSpaceDomain)
      position = (pSpaceDomain.index { |p| (p > pPitch) })
      if position.nil?
        return nil
      elsif position.zero?
        return 0
      elsif (pSpaceDomain[position - 1] < pPitch)
        return position
      else
        return position - 1
      end
    end

    #
    # Converts from a pitch to the nearest equal or lower position within the given space domain. Returns nil if the pitch is beyond the space domain.
    #
    # @param [Integer] pPitch pitch
    # @param [Ring] pSpaceDomain all positions available
    #
    # @return [Integer, NilClass] nearest equal or lower position within the given space domain
    #
    def getPositionAtOrBelowPitch(pPitch, pSpaceDomain)
      spaceDomainReverse = pSpaceDomain.reverse
      position = (spaceDomainReverse.index { |p| (p < pPitch) })
      if position.nil?
        return nil
      elsif position.zero?
        return pSpaceDomain.length - 1
      elsif (spaceDomainReverse[position - 1] > pPitch)
        return (pSpaceDomain.length - 1) - position
      else
        return (pSpaceDomain.length - 1) - (position - 1)
      end
    end

    #
    # @param [Integer] pPosition position
    # @param [Integer] pChordRoot chord root
    # @param [Integer] pTonicity tonicity (e.g. heptatonic = 7)
    #
    # @return [Integer] position in the general chord with the given root
    #
    def getPositionInGeneralChord(pPosition, pChordRoot, pTonicity)
      return ((pPosition - pChordRoot) + pTonicity) % pTonicity
    end

    #
    # @param [Hash] pKey key hash
    # @param [Integer] pNumOctaves number of octaves
    #
    # @return [Ring] space domain specified by given settings
    #
    def getSpaceDomain(pKey, pNumOctaves)
      return scale(pKey[:tonic], pKey[:scale], num_octaves: pNumOctaves)
    end

    #
    # @param [Integer] pPosition position
    # @param [Integer] pChordRoot chord root
    # @param [Integer] pTonicity tonicity (e.g. heptatonic = 7)
    #
    # @return [TrueClass, FalseClass] true if the given position is a general root of the given chord
    #
    def isPositionAGeneralRoot?(pPosition, pChordRoot, pTonicity)
      return getPositionInGeneralChord(pPosition, pChordRoot, pTonicity) == 0
    end

    #
    # @param [Integer] pPosition position
    # @param [Integer] pChordRoot chord root
    # @param [Integer] pTonicity tonicity (e.g. heptatonic = 7)
    # @param [Array<Integer>] pGeneralPositionsOfChord general chord positions
    #
    # @return [TrueClass, FalseClass] true if the given position belongs in the given chord
    #
    def isPositionInGeneralChord?(pPosition, pChordRoot, pTonicity, pGeneralPositionsOfChord)
      return pGeneralPositionsOfChord.any? { |gpc| (gpc == getPositionInGeneralChord(pPosition, pChordRoot, pTonicity)) }
    end

    #
    # @param [Integer] pTonic tonic pitch
    # @param [Symbol] pScale Sonic Pi scale symbol
    #
    # @return [Hash] key hash
    #
    def makeKey(pTonic, pScale)
      return {
        tonic: pTonic,
        scale: pScale,
      }.freeze
    end

    #
    # @param [Integer] pPosition position
    # @param [Hash] pOriginalKey original key hash
    # @param [Hash] pNewKey new key hash
    # @param [Hash] pSettingsSpace space settings
    #
    # @return [Integer] new position of original pitch (or nearest pitch in new key) in the new key
    #
    def modulatePositionToKey(pPosition, pOriginalKey, pNewKey, pSettingsSpace)
      if (pOriginalKey == pNewKey)
        return pPosition
      else
        originalSpaceDomain = getSpaceDomain(pOriginalKey, pSettingsSpace[:numOctaves])
        pitch = calculatePitch(pPosition, originalSpaceDomain)
        newSpaceDomain = getSpaceDomain(pNewKey, pSettingsSpace[:numOctaves])
        if (pitch >= newSpaceDomain.first)
          return getPositionAtOrBelowPitch(pitch, newSpaceDomain)
        else
          return getPositionAtOrAbovePitch(pitch, newSpaceDomain)
        end
      end
    end

    # impure functions

    #
    # Has a chance of progressing the time-state chord root. Modulates if in the final stage of transition. Repositions all musical symbols if a progression/modulation occurs.
    #
    def activateSpace
      if Settings::SPACE[:chanceProgress].evalChance?
        startingKey = get(-"space/key")

        if !get(-"space/chordRoot").zero? && Settings::SPACE[:chanceReturnToRoot].evalChance?
          returnToTonic()
        else
          progress()
          modulate() if (get(-"numTransitionMeasureDivisions") == 1)
        end

        recompose(startingKey)
      end
    end

    #
    # @return [Ring] all positions currently available
    #
    def getCurrentSpaceDomain
      return getSpaceDomain(get(-"space/key"), Settings::SPACE[:numOctaves])
    end

    #
    # @return [Integer] current tonicity (e.g. heptatonic = 7)
    #
    def getCurrentTonicity
      return (scale(0, get(-"space/key")[:scale]).length - 1)
    end

    #
    # Modulates keys in the time-state to a key whose tonic is the current chord root, and resets the chord root to zero to reflect the tonic of the new key.
    #
    def modulate
      # @type [Hash]
      newKey = calculateModulationToChordRoot(getCurrentSpaceDomain(), get(-"space/chordRoot"), Settings::SPACE)
      set(-"space/key", newKey)
      set(-"space/chordRoot", 0)

      logMessage("modulating to #{newKey.to_s}")
    end

    #
    # Changes chord roots using a set progression.
    #
    def progress
      # @type [Integer]
      tonicity = getCurrentTonicity()
      # @type [Array<Integer>]
      progressionsAvailable = Settings::SPACE[:progressions].nil? ? tonicity.toRangeAFromZero : Settings::SPACE[:progressions]
      # @type [Integer]
      nextChordRoot = ((get(-"space/chordRoot") + progressionsAvailable.choose) % tonicity)
      set(-"space/chordRoot", nextChordRoot)

      logMessage("progressing to #{get(-"space/chordRoot")}: #{note_info(calculatePitch(get(-"space/chordRoot"), getCurrentSpaceDomain())).pitch_class.to_s}")
    end

    #
    # Sets the time-state chord root to the tonic chord root.
    #
    def returnToTonic
      set(-"space/chordRoot", 0)

      logMessage("returning to 0: #{note_info(calculatePitch(0, getCurrentSpaceDomain())).pitch_class.to_s}")
    end
  end
end
