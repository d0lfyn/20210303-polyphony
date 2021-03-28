module Polyphony
  #
  # Class abstractions of instruments.
  #
  module Ensembles
    extend self

    #
    # Abstraction of instrument characteristics.
    #
    class Instrument
      attr_reader :playingRangePair

      #
      # Create an instrument with the given playing range.
      #
      # @param [RangePairI] pPlayingRangePair playing range
      #
      def initialize(pPlayingRangePair)
        # @type [RangePairI]
        @playingRangePair = pPlayingRangePair.freeze
      end

      #
      # Return a rangeI object containing this instrument's playing range as positions in the given space domain. Where this instrument's playing range has no corresponding position, the nearest position is selected instead, staying within the given space domain.
      #
      # @param [Ring] pSpaceDomain space domain
      #
      # @return [RangePairI] this instrument's playing range as positions
      #
      def getSpaceDomainRangePair(pSpaceDomain)
        return RangePairI.new(getPositionAtOrAbovePitch(@playingRangePair.min, pSpaceDomain), getPositionAtOrBelowPitch(@playingRangePair.max, pSpaceDomain)).freeze
      end
    end

    #
    # Abstraction of MIDI instrument.
    #
    class MIDIInstrument < Instrument
      attr_reader :shortSwitches, :midSwitches, :longSwitches, :legatoSwitches, :ccNums

      #
      # Create a MIDI instrument with the given options.
      #
      # @param [Hash] pOptions options containing shortSwitches, midSwitches, longSwitches, legatoSwitches, ccNums, and playingRangePair
      #
      def initialize(pOptions)
        super(pOptions[:playingRangePair])
        # @type [Array<Integer>]
        @shortSwitches = pOptions[:shortSwitches]
        # @type [Array<Integer>]
        @midSwitches = pOptions[:midSwitches]
        # @type [Array<Integer>]
        @longSwitches = pOptions[:longSwitches]
        # @type [Array<Integer>]
        @legatoSwitches = pOptions[:legatoSwitches]
        # @type [Array<Integer>]
        @ccNums = pOptions[:ccNums]
      end
    end

    #
    # Abstraction of Sonic Pi instrument.
    #
    class SPiInstrument < Instrument
      attr_reader :synth

      #
      # Create a Sonic Pi synth instrument with the given options.
      #
      # @param [Hash] pOptions options containing synth and playingRangePair
      #
      def initialize(pOptions)
        super(pOptions[:playingRangePair])
        # @type [Symbol]
        @synth = pOptions[:synth]
      end
    end
  end
end
