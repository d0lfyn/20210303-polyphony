module Polyphony
  #
  # Methods for regulating time.
  #
  module Timekeeping
    # impure functions

    #
    # Concludes MIDI and stops timekeeping loop.
    #
    def finishPiece
      signalAllSelectedPortsOff()
      stop()
    end

    #
    # @return [TrueClass, FalseClass] false if global time limit is nil or greater than units elapsed
    #
    def isTimeUp?
      if Settings::TIMEKEEPING[:timeLimitInUnits].nil?
        return false
      else
        return get("time/unitsElapsed") >= Settings::TIMEKEEPING[:timeLimitInUnits]
      end
    end

    #
    # Waits until the given number of units elapses, regardless of which subunit waiting begins.
    #
    # @param [Integer] pNumUnits units to wait
    #
    def waitNumUnitsQuantised(pNumUnits)
      currentUnitsElapsed = get("time/unitsElapsed")
      pNumUnits.times do
        Settings::TIMEKEEPING[:numSubunits].times do
          sync_bpm("time/subunit")
          break if currentUnitsElapsed < get("time/unitsElapsed")
        end
        currentUnitsElapsed += 1
      end
    end

    #
    # Signals measure, units, and subunits until time is up, whereafter piece is finished.
    #
    def activateTimekeeping
      subunitDuration = 1 / Settings::TIMEKEEPING[:numSubunits].to_f
      cue(-"time/measure")
      Settings::TIMEKEEPING[:numUnitsPerMeasure].times do
        set("time/unitsElapsed", (tick() + 1))
        Settings::TIMEKEEPING[:numSubunits].toRangeFromZero.each do |subunit|
          set("time/subunit", subunit)
          wait(subunitDuration)
        end
        finishPiece() if isTimeUp?()
      end
    end
  end
end
