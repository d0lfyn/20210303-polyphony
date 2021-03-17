# generalised functions

define :finishPiece do
  signalAllActivePortsOff()
  stop()
end

define :isTimeUp? do
  return false if get("settings/metronome")[:timeLimitInMinutes].nil?

  return (get("time/units") >= (get("settings/metronome")[:timeLimitInMinutes] * get("settings/metronome")[:unitsPerMinute]))
end

define :waitNumUnitsQuantised do |pNumUnits|
  currentUnit = get("time/units")
  pNumUnits.times do
    get("settings/metronome")[:numSubunits].times do
      sync_bpm("time/subunit")
      break if (currentUnit != get("time/units"))
    end
    currentUnit += 1
  end
end

# specialised functions

define :activateMetronome do
  subunit = (get("settings/metronome")[:unit] / get("settings/metronome")[:numSubunits].to_f)
  cue("time/measure")
  get("settings/metronome")[:numUnitsPerMeasure].times do
    set("time/units", tick())
    (0...get("settings/metronome")[:numSubunits]).each do |su|
      set("time/subunit", su)
      wait(subunit)
    end
  end

  if isTimeUp?()
    finishPiece()
  end
end
