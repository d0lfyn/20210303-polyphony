module Polyphony
  #
  # Methods for managing state motifs.
  #
  module State
    # impure functions

    #
    # Adds new state motif if there is room for the new motif, removing an old motif if possible, and if chance of adding a new motif evaluates true.
    #
    def activateState
      # @type [Array<Hash>]
      stateMotifs = get(-"motifs")
      # @type [TrueClass, FalseClass]
      roomForMoreExists = ((stateMotifs.length < Settings::STATE[:maxNumStateMotifs]) || (Settings::STATE[:numStateMotifsToKeep] < Settings::STATE[:maxNumStateMotifs]))
      if (roomForMoreExists && Settings::STATE[:chanceCreateNewStateMotif].evalChance?)
        # @type [Hash]
        newMotif = createMotif(Settings::TIMEKEEPING[:numUnitsPerMeasure], Settings::CREATION)
        if (stateMotifs.length == Settings::STATE[:maxNumStateMotifs])
          # @type [Hash]
          motifToRemove = stateMotifs.drop(Settings::STATE[:numStateMotifsToKeep]).choose
          stateMotifs -= [motifToRemove]
        end
        set(-"motifs", (stateMotifs + [newMotif]))

        logMessage("motif added: #{makeArraysFromMotif(newMotif).to_s}")
      end
    end

    #
    # Sets the time-state motifs to motif hashes generated from global settings.
    #
    def initState
      # @type [Array<Hash>]
      motifs = []
      motifs += Settings::STATE[:customStateMotifs]

      (Settings::STATE[:numInitialStateMotifs] - motifs.length).times do
        motifs.push(createMotif(Settings::TIMEKEEPING[:numUnitsPerMeasure], Settings::CREATION))
      end

      set(-"motifs", motifs)
    end
  end
end
