module Polyphony
  #
  # Methods for transitioning musical developments.
  #
  module Transition
    #
    # Stages a transition if enough measures have elapsed and the chance of transitioning evaluates true. Otherwise, increments the number of measures since the previous transition.
    #
    def activateTransition
      numMeasuresSinceTransition = get(-"numMeasuresSinceTransition")

      if ((numMeasuresSinceTransition > Settings::TRANSITION[:minNumMeasuresBetweenTransitions]) && (Settings::TRANSITION[:baseChanceTransition] * numMeasuresSinceTransition).evalChance?)

        logMessage(-"transitioning")

        set(-"numTransitionMeasureDivisions", Settings::TRANSITION[:rangeNumTransitionMeasureDivisions][0].get)
        (numMeasuresSinceTransition / Settings::TRANSITION[:rangeTransitionMeasureDivisors][0].get).times do
          sync_bpm(-"time/measure")
        end
        set(-"numTransitionMeasureDivisions", Settings::TRANSITION[:rangeNumTransitionMeasureDivisions][1].get)
        (numMeasuresSinceTransition / Settings::TRANSITION[:rangeTransitionMeasureDivisors][1].get).times do
          sync_bpm(-"time/measure")
        end
        set(-"numTransitionMeasureDivisions", Settings::TRANSITION[:rangeNumTransitionMeasureDivisions][2].get)
        (numMeasuresSinceTransition / Settings::TRANSITION[:rangeTransitionMeasureDivisors][2].get).times do
          sync_bpm(-"time/measure")
        end
        set(-"numTransitionMeasureDivisions", 1)
        sync_bpm(-"time/measure")
        set(-"numTransitionMeasureDivisions", nil)

        set(-"numMeasuresSinceTransition", 0)
      else
        set(-"numMeasuresSinceTransition", (numMeasuresSinceTransition + 1))
      end
    end
  end
end
