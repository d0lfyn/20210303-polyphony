module Polyphony
  module Performance
    #
    # Methods for voice management.
    #
    module Helpers
      # impure functions

      #
      # @param [String] pVoiceType voice type
      #
      # @return [TrueClass, FalseClass] true if all voices of given type are free
      #
      def areAllVoicesFree?(pVoiceType)
        getEnsemble(pVoiceType).length.toRangeFromZero.each do |vn|
          return false if isVoiceActive?(pVoiceType, vn)
        end

        return true
      end

      #
      # Clear all voices of given type in the time-state.
      #
      # @param [String] pVoiceType voice type
      #
      def clearAllVoices(pVoiceType)
        getEnsemble(pVoiceType).length.toRangeFromZero.each do |vn|
          clearVoice(pVoiceType, vn)
        end
      end

      #
      # Set voice of given type and number to nil in the time-state.
      #
      # @param [String] pVoiceType voice type
      # @param [Integer] pVoiceNumber voice number
      #
      def clearVoice(pVoiceType, pVoiceNumber)
        set("#{pVoiceType}/#{pVoiceNumber.to_s}", nil)
      end

      #
      # @param [String] pVoiceType voice type
      #
      # @return [Integer] number of voices of given type whose time-state is not nil
      #
      def countVoicesActive(pVoiceType)
        # @type [Integer]
        count = 0
        getEnsemble(pVoiceType).length.toRangeFromZero.each do |vn|
          count += 1 if isVoiceActive?(pVoiceType, vn)
        end

        return count
      end

      #
      # @return [Array<Hash>] all synthesis hashes of all types specified in the global list of voices
      #
      def getAllActiveSyntheses
        # @type [Array<Hash>]
        allActiveSyntheses = []
        Settings::VOICES[:selection].each do |voiceType|
          allActiveSyntheses += getAllActiveVoicesSyntheses(voiceType)
        end

        return allActiveSyntheses.freeze
      end

      #
      # @param [String] pVoiceType voice type
      #
      # @return [Array<Hash>] all non-nil synthesis hashes of given type
      #
      def getAllActiveVoicesSyntheses(pVoiceType)
        # @type [Array<Hash>]
        allActiveSyntheses = []
        getEnsemble(pVoiceType).length.toRangeFromZero.each do |vn|
          # @type [Hash]
          synthesis = getVoiceSynthesis(pVoiceType, vn)
          allActiveSyntheses.push(synthesis) unless synthesis.nil?
        end

        return allActiveSyntheses.freeze
      end

      #
      # @param [String] pVoiceType voice type
      #
      # @return [Array<Hash>] all synthesis hashes, including nils, of given type, in their original order
      #
      def getAllVoicesSyntheses(pVoiceType)
        # @type [Array<Hash>]
        allSyntheses = []
        getEnsemble(pVoiceType).length.toRangeFromZero.each do |n|
          allSyntheses.push(getVoiceSynthesis(pVoiceType, n))
        end

        return allSyntheses.freeze
      end

      #
      # @param [String] pVoiceType voice type
      #
      # @return [Array<Instrument>] the ensemble of the given voice type
      #
      def getEnsemble(pVoiceType)
        return Settings.const_get(-pVoiceType.upcase)[:performance][:ensemble]
      end

      #
      # @param [String] pVoiceType voice type
      # @param [Integer] pVoiceNumber voice number
      #
      # @return [Instrument] instrument of voice specified by givens
      #
      def getInstrument(pVoiceType, pVoiceNumber)
        return getEnsemble(pVoiceType)[pVoiceNumber]
      end

      #
      # @param [String] pVoiceType voice type
      # @param [Integer] pVoiceNumber voice number
      #
      # @return [Hash] time-state synthesis of voice specified by givens
      #
      def getVoiceSynthesis(pVoiceType, pVoiceNumber)
        return get("#{pVoiceType}/#{pVoiceNumber.to_s}")
      end

      #
      # @param [String] pVoiceType voice type
      # @param [Integer] pVoiceNumber voice number
      #
      # @return [TrueClass, FalseClass] true if voice specified by givens has a non-nil synthesis in the time-state
      #
      def isVoiceActive?(pVoiceType, pVoiceNumber)
        return !getVoiceSynthesis(pVoiceType, pVoiceNumber).nil?
      end

      #
      # @param [String] pVoiceType voice type
      # @param [Integer] pVoiceNumber voice number
      #
      # @return [TrueClass, FalseClass] true if voice specified by givens has a nil synthesis in the time-state
      #
      def isVoiceFree?(pVoiceType, pVoiceNumber)
        return getVoiceSynthesis(pVoiceType, pVoiceNumber).nil?
      end

      #
      # Sets the synthesis hashes of all voices in the time-state to the given synthesis hashes, one to one.
      #
      # @param [String] pVoiceType voice type
      # @param [Array<Hash>] pSyntheses synthesis hashes
      #
      def setAllVoicesSyntheses(pVoiceType, pSyntheses)
        getEnsemble(pVoiceType).length.toRangeFromZero.each do |vn|
          setVoiceSynthesis(pVoiceType, vn, pSyntheses[vn])
        end
      end

      #
      # Sets the synthesis of the voice specified by the given voice type and number to the given synthesis.
      #
      # @param [String] pVoiceType voice type
      # @param [Integer] pVoiceNumber voice number
      # @param [Hash] pSynthesis synthesis
      #
      def setVoiceSynthesis(pVoiceType, pVoiceNumber, pSynthesis)
        set("#{pVoiceType}/#{pVoiceNumber.to_s}", pSynthesis)
      end
    end
  end
end
