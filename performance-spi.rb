module Polyphony
  module Performance
    #
    # Methods for Sonic Pi synth performance.
    #
    module SPi
      # pure functions

      #
      # @param [Hash] pSettingsAmp amp settings
      #
      # @return [Float] amp determined by the given settings
      #
      def calculateAmp(pSettingsAmp)
        return (pSettingsAmp[:base] + pSettingsAmp[:rangeRandom].get)
      end

      #
      # Returns a pan value determined by the voice number, its ensemble, and the set pan width.
      #
      # @param [Integer] pVoiceNumber voice number
      # @param [Array<SPiInstrument>] pEnsemble array of SPi instruments
      # @param [Float] pPanWidth pan width
      #
      # @return [Float] pan determined by the given settings
      #
      def calculatePan(pVoiceNumber, pEnsemble, pPanWidth)
        return ((pVoiceNumber * (pPanWidth / pEnsemble.length.to_f)) - (pPanWidth / 2.to_f))
      end

      # impure functions

      #
      # Plays the given pitch for the given duration, at the given amp.
      #
      # @param [Integer] pPitch pitch
      # @param [Integer] pDuration duration
      # @param [Float] pAmp amp
      #
      def performSPiArticulated(pPitch, pDuration, pAmp)
        in_thread do
          play(pPitch, amp: pAmp, attack: 0.05, sustain: 0, release: pDuration)
          waitNumUnitsQuantised(pDuration)
        end
      end

      #
      # Plays an articulated hypothetical motif hash from the given synthesis hash once through, with parameters supplied by the current time-state and the given instrument.
      #
      # @param [Hash] pSynthesis synthesis hash
      # @param [SPiInstrument] pInstrument Sonic Pi instrument
      #
      def performSPiArticulatedConclusion(pSynthesis, pInstrument)
        # @type [Hash]
        hypothesis = pSynthesis[:hypotheses].choose
        # @type [Ring]
        spaceDomain = getCurrentSpaceDomain()
        # @type [Integer]
        span = Settings::TIMEKEEPING[:numUnitsPerMeasure]
        performSPiShortMidHypothesisForSpan(pSynthesis[:position], hypothesis, span, spaceDomain, pInstrument)
      end

      #
      # Performs the articulated synthesis of the given voice. Its hypothetical motif hashes are played rhythmically a number of times, interspersed with complete presentations of hypotheses, followed by a switch of hypothesis and rhythm.
      #
      # @param [Integer] pVoiceNumber voice number
      #
      def performSPiArticulatedSynthesis(pVoiceNumber)
        # @type [MIDIInstrument]
        instrument = getInstrument(-"articulated", pVoiceNumber)
        # @type [Hash]
        svap = Settings::ARTICULATED[:performance]
        # @type [Hash]
        synthesis = getVoiceSynthesis(-"articulated", pVoiceNumber)

        with_fx(:pan, pan: calculatePan(pVoiceNumber, getEnsemble(-"articulated"), svap[:spi][:shortMid][:panWidth])) do
          with_fx(:compressor, amp: 0.9) do
            with_synth(instrument.synth) do
              while svap[:chanceRecalculate].evalChance?
                # @type [Array<Integer>]
                compositeRhythm = getCompositeRhythm(svap[:rangeNumRhythmsInPolyrhythm].get, svap[:rangeNumRhythmicDivisions], Settings::TIMEKEEPING[:numUnitsPerMeasure])
                # @type [Array<Integer>]
                compositeRhythmSpans = convertOffsetsToSpans(compositeRhythm, Settings::TIMEKEEPING[:numUnitsPerMeasure])
                # @type [Hash]
                hypothesis = synthesis[:hypotheses].choose
                while svap[:chanceRepeat].evalChance?
                  # @type [Ring]
                  spaceDomain = getCurrentSpaceDomain()
                  compositeRhythmSpans.each do |span|
                    performSPiShortMidHypothesisForSpan(synthesis[:position], hypothesis, span, spaceDomain, instrument)
                  end
                  synthesis = getVoiceSynthesis(-"articulated", pVoiceNumber)
                  break if synthesis.nil?
                end
                unless synthesis.nil?
                  performSPiArticulatedConclusion(synthesis, instrument)
                else
                  break
                end
              end
              performSPiArticulatedConclusion(synthesis, instrument) unless synthesis.nil?
            end
          end
        end
      end

      #
      # Performs the given hypothetical motif hash with the given instrument's short-mid settings, for the given span, and at the given position in the given space domain.
      #
      # @param [Integer] pPosition position
      # @param [Hash] pHypothesis hypothetical motif hash
      # @param [Integer] pSpan span
      # @param [Ring] pSpaceDomain all positions available
      # @param [SPiInstrument] pInstrument Sonic Pi instrument
      #
      def performSPiShortMidHypothesisForSpan(pPosition, pHypothesis, pSpan, pSpaceDomain, pInstrument)
        # @type [Hash]
        svaps = Settings::ARTICULATED[:performance][:spi][:shortMid]

        # @type [TrueClass, FalseClass]
        isOnFirstUnit = true
        # @type [Integer]
        unitsLeft = pSpan
        pHypothesis[:notes].length.toRangeFromZero.each do |i|
          # @type [Hash]
          note = pHypothesis[:notes][i]

          # @type [Integer]
          duration = getMin(note[:span], unitsLeft)
          unitsLeft -= duration

          # @type [Integer]
          pitch = nil
          pitch = calculatePitch((note[:displacement] + pPosition), pSpaceDomain) unless note[:displacement].nil?

          # @type [Float]
          amp = calculateAmp(svaps[:amp])

          sync_bpm(-"time/subunit")
          sync_bpm(-"time/subunit")
          performSPiArticulated(pitch, duration, amp)
          waitNumUnitsQuantised(duration)

          isOnFirstUnit = false
          break if unitsLeft.zero?
        end
      end

      #
      # Performs the sustained synthesis of the given voice. Its hypothetical motif hash is held for a number of measures determined randomly from the sustained settings. If a key change occurs or a chord change occurs such that the sustained position no longer belongs to the new chord, then the sustained performance is terminated early.
      #
      # @param [Integer] pVoiceNumber voice number
      #
      def performSPiSustainedSynthesis(pVoiceNumber)
        # @type [Hash]
        svsp = Settings::SUSTAINED[:performance]

        # @type [MIDIInstrument]
        instrument = getInstrument(-"sustained", pVoiceNumber)

        # @type [Integer]
        numMeasuresRemaining = svsp[:rangeNumMeasuresToSustain].get
        # @type [Integer]
        numUnits = (numMeasuresRemaining * Settings::TIMEKEEPING[:numUnitsPerMeasure])

        # @type [Integer]
        startingChordRoot = get(-"space/chordRoot")
        # @type [Integer]
        stableChordRoot = startingChordRoot
        # @type [Hash]
        startingKey = get(-"space/key")

        # @type [Hash]
        synthesis = getVoiceSynthesis(-"sustained", pVoiceNumber)
        # @type [Integer]
        pitch = calculatePitch(synthesis[:position], getCurrentSpaceDomain())

        sync_bpm(-"time/subunit") # coordinate with MIDI

        sync_bpm(-"time/subunit") # coordinate with MIDI
        in_thread do
          with_fx(:pan, pan: calculatePan(pVoiceNumber, getEnsemble(-"sustained"), svsp[:spi][:long][:panWidth])) do
            with_fx(:compressor, amp: 0.9) do
              with_synth(instrument.synth) do
                play(pitch, amp: calculateAmp(svsp[:spi][:long][:amp]), attack: (numUnits * 0.1), sustain: 0, release: (numUnits * 0.9))
              end
            end
          end
        end
        sync_bpm(-"time/measure")
        numMeasuresRemaining -= 1
        while ((get(-"space/key") == startingKey) && (numMeasuresRemaining > 0))
          currentChordRoot = get(-"space/chordRoot")
          unless (currentChordRoot == stableChordRoot)
            if isPositionInGeneralChord?(synthesis[:position], currentChordRoot, getCurrentTonicity(), Settings::COMPOSITION[:generalPositionsOfChord])
              stableChordRoot = currentChordRoot
            else
              numMeasuresRemaining = 0
            end
          end
          sync_bpm(-"time/measure")
          numMeasuresRemaining -= 1
        end
      end
    end
  end
end
