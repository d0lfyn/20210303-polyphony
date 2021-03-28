module Polyphony
  #
  # Methods for outputting to console.
  #
  module Logging
    # impure functions

    #
    # Outputs time information.
    #
    def activateLogging
      puts(-"----------------------------------------------------------------")
      puts("start of measure #{((get(-"time/unitsElapsed") / Settings::TIMEKEEPING[:numUnitsPerMeasure]) + 1).to_s}")
      puts("units elapsed: #{get(-"time/unitsElapsed").to_s}")
    end

    #
    # Outputs motifs in array format.
    #
    def diagnoseMotifs
      puts(-"motifs:")
      get(-"motifs").each do |motif|
        puts(-"#{makeArraysFromMotif(motif).to_s}")
      end
    end

    #
    # Outputs seed information.
    #
    def diagnoseSeed
      puts(-"random seed: #{Settings::RANDOM[:seed].to_s}")
    end

    #
    # Outputs all diagnoses.
    #
    def diagnose
      diagnoseSeed()
      diagnoseMotifs()
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
