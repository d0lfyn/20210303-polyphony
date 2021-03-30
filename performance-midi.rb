module Polyphony
  module Performance
    #
    # Methods for MIDI performance.
    #
    module Midi
      # pure functions

      #
      # @param [Hash] pSettingsVelocity velocity settings
      #
      # @return [Float] velocity determined by the given settings
      #
      def calculateVelocity(pSettingsVelocity)
        return (pSettingsVelocity[:base] + pSettingsVelocity[:rangeRandom].get)
      end

      #
      # @param [MIDIInstrument] pInstrument MIDI instrument
      # @param [Integer] pDuration duration
      # @param [Integer] pDurationMid duration past which mid-switches are invoked
      #
      # @return [Integer] a keyswitch appropriate for the given duration
      #
      def selectShortMidKeyswitch(pInstrument, pDuration, pDurationMid)
        if (pDuration < pDurationMid)
          return pInstrument.shortSwitches.choose
        else
          return pInstrument.midSwitches.choose
        end
      end

      # impure functions

      #
      # Prepares MIDI.
      #
      def initMIDI
        signalAllSelectedPortsOff()
      end

      #
      # Launches a thread for the given articulated voice, in which MIDI CC is wound up and maintained until the voice is no longer active.
      #
      # @param [Integer] pVoiceNumber voice number
      # @param [MIDIInstrument] pInstrument MIDI instrument
      #
      def launchCCArticulated(pVoiceNumber, pInstrument)
        in_thread name: (-"articulated#{pVoiceNumber.to_s}CC").to_sym do
          # @type [Hash]
          scc = Settings::ARTICULATED[:performance][:midi][:cc]

          # @type [Float]
          ccValue = scc[:base]
          windUpCC(ccValue, pInstrument)
          while isVoiceActive?(-"articulated", pVoiceNumber)
            # @type [Float]
            height = rand(scc[:maxHeight])
            # @type [Integer]
            numMeasures = scc[:rangeNumMeasuresInPeriod].get
            # @type [Integer]
            numSubunits = Settings::TIMEKEEPING[:numSubunits]
            # @type [Integer]
            periodUnits = dice(numMeasures * Settings::TIMEKEEPING[:numUnitsPerMeasure])
            # @type [Integer]
            periodSubunits = (periodUnits * numSubunits)
            periodUnits.toRangeFromZero.each do |u|
              numSubunits.toRangeFromZero.each do |su|
                setCC(pInstrument, ((height * (-Math.cos(((u * numSubunits) + su) * 2 * Math::PI / periodSubunits) + 1) / 2) + scc[:base]))
                sync_bpm(-"time/subunit")
              end
            end
          end
        end
      end

      #
      # Launches a thread for the given sustained voice, in which MIDI CC is wound up and maintained until the voice is no longer active.
      #
      # @param [Integer] pVoiceNumber voice number
      # @param [MIDIInstrument] pInstrument MIDI instrument
      #
      def launchCCSustained(pVoiceNumber, pInstrument, pNumMeasures)
        in_thread name: (-"sustained#{pVoiceNumber.to_s}CC").to_sym do
          # @type [Hash]
          scc = Settings::SUSTAINED[:performance][:midi][:cc]

          # @type [Float]
          ccValue = scc[:base]
          windUpCC(ccValue, pInstrument)
          while isVoiceActive?(-"sustained", pVoiceNumber)
            # @type [Float]
            height = rand(scc[:maxHeight])
            # @type [Integer]
            numSubunits = Settings::TIMEKEEPING[:numSubunits]
            # @type [Integer]
            periodUnits = (dice(pNumMeasures) * Settings::TIMEKEEPING[:numUnitsPerMeasure])
            # @type [Integer]
            periodSubunits = (periodUnits * numSubunits)
            periodUnits.toRangeFromZero.each do |u|
              numSubunits.toRangeFromZero.each do |su|
                ccValue = ((height * (-Math.cos(((u * numSubunits) + su) * 2 * Math::PI / periodSubunits) + 1) / 2) + scc[:base])
                setCC(pInstrument, ccValue)
                sync_bpm(-"time/subunit")
              end
            end
          end
        end
      end

      #
      # Plays a MIDI note with the given pitch, duration, and velocities.
      #
      # @param [Integer] pPitch MIDI pitch
      # @param [Integer] pDuration duration
      # @param [Float] pVelocityOn velocity of note on
      # @param [Float] pVelocityOff velocity of note off
      #
      def performMIDIArticulated(pPitch, pDuration, pVelocityOn, pVelocityOff)
        in_thread do
          midi_note_on(pPitch, vel_f: pVelocityOn)
          waitNumUnitsQuantised(pDuration)
          midi_note_off(pPitch, vel_f: pVelocityOff)
        end
      end

      #
      # Plays an articulated hypothetical motif hash from the given synthesis hash once through, with parameters supplied by the current time-state and the given instrument.
      #
      # @param [Hash] pSynthesis synthesis hash
      # @param [MIDIInstrument] pInstrument MIDI instrument
      #
      def performMIDIArticulatedConclusion(pSynthesis, pInstrument)
        # @type [Hash]
        hypothesis = pSynthesis[:hypotheses].choose
        # @type [Ring]
        spaceDomain = getCurrentSpaceDomain()
        # @type [Integer]
        span = Settings::TIMEKEEPING[:numUnitsPerMeasure]
        if Settings::ARTICULATED[:performance][:midi][:chanceLegato].evalChance?
          performMIDILegatoHypothesisForSpan(pSynthesis[:position], hypothesis, span, spaceDomain, pInstrument)
        else
          performMIDIShortMidHypothesisForSpan(pSynthesis[:position], hypothesis, span, spaceDomain, pInstrument)
        end
      end

      #
      # Performs the articulated synthesis of the given voice. Its hypothetical motif hashes are played rhythmically a number of times, interspersed with complete presentations of hypotheses, followed by a switch of hypothesis and rhythm.
      #
      # @param [Integer] pVoiceNumber voice number
      #
      def performMIDIArticulatedSynthesis(pVoiceNumber)
        # @type [MIDIInstrument]
        instrument = getInstrument(-"articulated", pVoiceNumber)
        # @type [Hash]
        svap = Settings::ARTICULATED[:performance]
        # @type [Hash]
        synthesis = getVoiceSynthesis(-"articulated", pVoiceNumber)

        with_midi_defaults(port: selectPort(pVoiceNumber, svap[:midi][:ports]), channel: selectChannel(pVoiceNumber)) do
          launchCCArticulated(pVoiceNumber, instrument) unless instrument.ccNums.empty?
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
                if ((span >= svap[:midi][:legatoSpanThreshold]) && svap[:midi][:chanceLegato].evalChance?)
                  performMIDILegatoHypothesisForSpan(synthesis[:position], hypothesis, span, spaceDomain, instrument)
                else
                  performMIDIShortMidHypothesisForSpan(synthesis[:position], hypothesis, span, spaceDomain, instrument)
                end
              end
              synthesis = getVoiceSynthesis(-"articulated", pVoiceNumber)
              break if synthesis.nil?
            end
            unless synthesis.nil?
              performMIDIArticulatedConclusion(synthesis, instrument)
            else
              break
            end
          end
          unless synthesis.nil?
            performMIDIArticulatedConclusion(synthesis, instrument)
          end
        end
      end

      #
      # Performs the given hypothetical motif hash with the given instrument's legato settings, for the given span, and at the given position in the given space domain.
      #
      # @param [Integer] pPosition position
      # @param [Hash] pHypothesis hypothetical motif hash
      # @param [Integer] pSpan span
      # @param [Ring] pSpaceDomain all positions available
      # @param [MIDIInstrument] pInstrument MIDI instrument
      #
      def performMIDILegatoHypothesisForSpan(pPosition, pHypothesis, pSpan, pSpaceDomain, pInstrument)
        # @type [Hash]
        svapl = Settings::ARTICULATED[:performance][:midi][:legato]

        # @type [TrueClass, FalseClass]
        isOnFirstUnit = true
        # @type [Integer]
        keyswitch = pInstrument.legatoSwitches.choose
        # @type [Integer]
        unitsLeft = pSpan

        sync_bpm(-"time/subunit")
        switchKeyswitchOn(keyswitch)
        pHypothesis[:notes].length.toRangeFromZero.each do |i|
          # @type [Hash]
          note = pHypothesis[:notes][i]
          # @type [Hash]
          nextNote = pHypothesis[:notes][i + 1]

          # @type [Integer]
          duration = getMin(note[:span], unitsLeft)
          unitsLeft -= duration

          # @type [Integer]
          pitch = nil
          pitch = calculatePitch((note[:displacement] + pPosition), pSpaceDomain) unless note[:displacement].nil?

          # @type [Float]
          velocityOff = calculateVelocity(svapl[:velocityOff])
          # @type [Float]
          velocityOn = calculateVelocity(svapl[:velocityOn])
          velocityOn += svapl[:velocityOn][:accent] if isOnFirstUnit

          sync_bpm(-"time/subunit") unless isOnFirstUnit
          sync_bpm(-"time/subunit")
          if ((unitsLeft > 0) && (nextNote[:displacement] != note[:displacement]))
            performMIDIArticulated(pitch, (duration + 1), velocityOn, velocityOff)
          else
            performMIDIArticulated(pitch, duration, velocityOn, velocityOff)
          end
          waitNumUnitsQuantised(duration)

          isOnFirstUnit = false
          break if unitsLeft.zero?
        end
        switchKeyswitchOff(keyswitch)
      end

      #
      # Performs the given hypothetical motif hash with the given instrument's short-mid settings, for the given span, and at the given position in the given space domain.
      #
      # @param [Integer] pPosition position
      # @param [Hash] pHypothesis hypothetical motif hash
      # @param [Integer] pSpan span
      # @param [Ring] pSpaceDomain all positions available
      # @param [MIDIInstrument] pInstrument MIDI instrument
      #
      def performMIDIShortMidHypothesisForSpan(pPosition, pHypothesis, pSpan, pSpaceDomain, pInstrument)
        # @type [Hash]
        svaps = Settings::ARTICULATED[:performance][:midi][:shortMid]

        # @type [Integer]
        d = pHypothesis[:notes].first[:displacement]

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
          keyswitch = selectShortMidKeyswitch(pInstrument, duration, svaps[:durationMid])

          # @type [Integer]
          pitch = nil
          pitch = calculatePitch((d + pPosition), pSpaceDomain) unless d.nil?

          # @type [Float]
          velocityOff = calculateVelocity(svaps[:velocityOff])
          # @type [Float]
          velocityOn = calculateVelocity(svaps[:velocityOn])
          velocityOn += svaps[:velocityOn][:accent] if isOnFirstUnit

          sync_bpm(-"time/subunit")
          switchKeyswitchOn(keyswitch)
          sync_bpm(-"time/subunit")
          performMIDIArticulated(pitch, duration, velocityOn, velocityOff)
          waitNumUnitsQuantised(duration)
          switchKeyswitchOff(keyswitch)

          isOnFirstUnit = false
          break if unitsLeft.zero?

          d = chooseNextMarkovChainDisplacement(pHypothesis[:displacementMarkovChain], d)
        end
      end

      #
      # Performs the sustained synthesis of the given voice. Its hypothetical motif hash is held for a number of measures determined randomly from the sustained settings. If a key change occurs or a chord change occurs such that the sustained position no longer belongs to the new chord, then the sustained performance is terminated early.
      #
      # @param [Integer] pVoiceNumber voice number
      #
      def performMIDISustainedSynthesis(pVoiceNumber)
        # @type [Hash]
        svsp = Settings::SUSTAINED[:performance]

        # @type [MIDIInstrument]
        instrument = getInstrument(-"sustained", pVoiceNumber)
        # @type [Integer]
        keyswitch = instrument.longSwitches.choose

        # @type [Integer]
        numMeasuresRemaining = svsp[:rangeNumMeasuresToSustain].get

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

        with_midi_defaults(port: selectPort(pVoiceNumber, svsp[:midi][:ports]), channel: selectChannel(pVoiceNumber)) do
          launchCCSustained(pVoiceNumber, instrument, numMeasuresRemaining) unless instrument.ccNums.empty?

          sync_bpm(-"time/subunit")
          switchKeyswitchOn(keyswitch)

          sync_bpm(-"time/subunit")
          midi_note_on(pitch, vel_f: calculateVelocity(svsp[:midi][:long][:velocityOn]))
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
          midi_note_off(pitch, vel_f: calculateVelocity(svsp[:midi][:long][:velocityOff]))

          switchKeyswitchOff(keyswitch)
        end
      end

      #
      # @param [Integer] pVoiceNumber voice number
      #
      # @return [Integer] the MIDI channel for the given voice
      #
      def selectChannel(pVoiceNumber)
        return ((pVoiceNumber % Settings::MIDI[:numChannelsPerPort]) + 1)
      end

      #
      # @param [Integer] pVoiceNumber voice number
      # @param [Array<String>] pPorts port names
      #
      # @return [String] the MIDI port for the given voice
      #
      def selectPort(pVoiceNumber, pPorts)
        return pPorts[(pVoiceNumber / Settings::MIDI[:numChannelsPerPort]).to_i]
      end

      #
      # Sets each MIDI CC of the given instrument to the given CC value.
      #
      # @param [MIDIInstrument] pInstrument MIDI instrument
      # @param [Float] pCCValue CC value
      #
      def setCC(pInstrument, pCCValue)
        pInstrument.ccNums.each do |ccn|
          midi_cc(ccn, val_f: pCCValue)
        end
      end

      #
      # Turns all notes on all selected ports off.
      #
      def signalAllSelectedPortsOff
        Settings::VOICES[:selection].each do |voiceType|
          Settings.const_get(voiceType.upcase)[:performance][:midi][:ports].each do |port|
            midi_all_notes_off(port: port)
          end
        end
      end

      #
      # Turns off the given keyswitch note.
      #
      # @param [Integer] pKeyswitch keyswitch note
      #
      def switchKeyswitchOff(pKeyswitch)
        midi_note_off(pKeyswitch, vel_f: 1)
      end

      #
      # Turns on the given keyswitch note.
      #
      # @param [Integer] pKeyswitch keyswitch note
      #
      def switchKeyswitchOn(pKeyswitch)
        midi_note_on(pKeyswitch, vel_f: 0.01)
      end

      #
      # Gradually winds up the MIDI CC of the given instrument, up to the given CC value.
      #
      # @param [Float] pBase ending CC value
      # @param [MIDIInstrument] pInstrument MIDI instrument
      #
      def windUpCC(pBase, pInstrument)
        # @type [Integer]
        numSubunits = (Settings::TIMEKEEPING[:numUnitsPerMeasure] * Settings::TIMEKEEPING[:numSubunits] / 2)
        numSubunits.toRangeFromZero.each do |su|
          setCC(pInstrument, (pBase / (1 + Math.exp(-su))))
          sync_bpm(-"time/subunit")
        end
      end
    end
  end
end
