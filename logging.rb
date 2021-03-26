module Polyphony
  #
  # Methods for outputting to console.
  #
  module Logging
    # impure functions

    #
    # Outputs seed and time information.
    #
    def activateLogging
      puts("start of measure #{((get(-"time/unitsElapsed") / Settings::TIMEKEEPING[:numUnitsPerMeasure]) + 1).to_s}")
      puts("units elapsed: #{get(-"time/unitsElapsed").to_s}")
      puts(-"random seed: #{Settings::RANDOM[:seed].to_s}")
    end

    #
    # Outputs message if global message logging is enabled.
    #
    # @param [String] pMessage message to output
    #
    def logMessage(pMessage)
      puts(pMessage) if Settings::LOGGING[:shouldLogMessages]
    end
  end
end
