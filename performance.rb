module Polyphony
  #
  # Methods for using voices.
  #
  module Performance
    # impure functions

    #
    # Prepares and generates voices of the given type randomly if there is room to add them and if the chance of adding voices evaluates true. If a voice is to be added, the function will attempt to prepare free voices until either: one is successfully prepared (i.e. there is room for it), or until all voices have been tried.
    #
    # @param [String] pVoiceType voice type
    #
    def activateVoices(pVoiceType)
      # @type [Hash]
      s = Settings.const_get(-pVoiceType.upcase)
      # @type [Integer]
      numVoicesToAdd = 0
      numVoicesToAdd = s[:rangeNumVoicesToAddPerMeasure].get if s[:chanceAddVoices].evalChance?
      # @type [Integer]
      numVoicesActive = countVoicesActive(pVoiceType)
      numVoicesToAdd += 1 if (numVoicesActive.zero? && numVoicesToAdd.zero?)
      # @type [Integer]
      numVoicesRemaining = (s[:maxNumVoicesActive] - numVoicesActive)
      numVoicesToAdd = getMin(numVoicesToAdd, numVoicesRemaining)

      unless numVoicesToAdd.zero?
        getEnsemble(pVoiceType).length.toRangeAFromZero.shuffle.each do |vn|
          if (isVoiceFree?(pVoiceType, vn) && send(-"prepare#{pVoiceType.capitalize}Synthesis?", vn))
            generateVoice(pVoiceType, vn)
            numVoicesToAdd -= 1
            break if numVoicesToAdd.zero?
          end
        end
      end
    end

    #
    # At the beginning of the next measure, generates a thread for the voice specified by the givens, in which thread the voice will perform and clear when done.
    #
    # @param [String] pVoiceType voice type
    # @param [Integer] pVoiceNumber voice number
    #
    def generateVoice(pVoiceType, pVoiceNumber)
      in_thread do
        sync_bpm(-"time/measure")
        in_thread name: (-"#{pVoiceType}#{pVoiceNumber.to_s}").to_sym do
          if isVoiceActive?(pVoiceType, pVoiceNumber)
            logMessage("#{pVoiceType} #{pVoiceNumber.to_s} playing #{getVoiceSynthesis(pVoiceType, pVoiceNumber).to_s}")

            if Settings.const_get(-pVoiceType.upcase)[:performance][:ensemble][pVoiceNumber].is_a?(SPiInstrument)
              send(-"performSPi#{pVoiceType.capitalize}Synthesis", pVoiceNumber)
            else
              send(-"performMIDI#{pVoiceType.capitalize}Synthesis", pVoiceNumber)
            end

            logMessage(-"#{pVoiceType} #{pVoiceNumber.to_s} done")

            clearVoice(pVoiceType, pVoiceNumber)
          end
        end
      end
    end

    #
    # Clears all voices of all types selected in the settings.
    #
    def initVoices
      Settings::VOICES[:selection].each do |voiceType|
        clearAllVoices(voiceType)
      end
    end

    #
    # Attempts to prepare an articulated synthesis hash for the given voice by arranging or improvising depending on chance. Improvisation only occurs if arranging fails. If a synthesis is produced, the voice synthesis is set to it, and this function returns true. Otherwise, this function returns false.
    #
    # @param [Integer] pVoiceNumber voice number
    #
    # @return [TrueClass, FalseClass] true if a synthesis hash is successfully prepared and set for the given voice
    #
    def prepareArticulatedSynthesis?(pVoiceNumber)
      # @type [Hash]
      synthesis = nil
      # @type [TrueClass, FalseClass]
      tried = false
      if Settings::COMPOSITION[:chanceArrange].evalChance?
        # @type [Array<Hash>]
        hypotheses = Settings::IDEATION[:rangeNumMotifsToIdeate].get.toRangeAFromZero.map { |x| ideate() }
        tried = true
        synthesis = arrangeForArticulatedVoice(pVoiceNumber, hypotheses)
      end
      if synthesis.nil? && Settings::COMPOSITION[:chanceImprovise].evalChance?
        tried = true
        synthesis = improviseArticulatedVoice(pVoiceNumber)
      end

      unless synthesis.nil?
        setVoiceSynthesis(-"articulated", pVoiceNumber, synthesis)

        logMessage(-"articulated #{pVoiceNumber.to_s} preparing to play #{synthesis.to_s}")

        return true
      else
        logMessage(-"no room for articulated #{pVoiceNumber.to_s}") if tried
      end
      return false
    end

    #
    # Attempts to prepare a sustained synthesis hash for the given voice by arranging the infinitum motif. If a synthesis is produced, the voice synthesis is set to it, and this function returns true. Otherwise, this function returns false.
    #
    # @param [Integer] pVoiceNumber voice number
    #
    # @return [TrueClass, FalseClass] true if a synthesis hash is successfully prepared and set for the given voice
    #
    def prepareSustainedSynthesis?(pVoiceNumber)
      # @type [Array<Hash>]
      hypotheses = [Ideation::INFINITUM].freeze
      # @type [Hash]
      synthesis = arrangeForSustainedVoice(pVoiceNumber, hypotheses)

      unless synthesis.nil?
        setVoiceSynthesis(-"sustained", pVoiceNumber, synthesis)

        logMessage(-"sustained #{pVoiceNumber.to_s} preparing to play")

        return true
      else
        logMessage(-"no room for sustained #{pVoiceNumber.to_s}")

        return false
      end
    end
  end
end
