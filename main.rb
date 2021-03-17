DIRECTORY = "~/OneDrive/music-production/sonic-pi/20210303-polyphony".freeze
# order-dependent
eval_file(File.join(DIRECTORY, "general.rb"))
eval_file(File.join(DIRECTORY, "ensembles.rb"))
eval_file(File.join(DIRECTORY, "space.rb"))
eval_file(File.join(DIRECTORY, "settings.rb"))
# order-independent
eval_file(File.join(DIRECTORY, "composition.rb"))
eval_file(File.join(DIRECTORY, "ideation.rb"))
eval_file(File.join(DIRECTORY, "logging.rb"))
eval_file(File.join(DIRECTORY, "metronome.rb"))
eval_file(File.join(DIRECTORY, "performance-helpers.rb"))
eval_file(File.join(DIRECTORY, "performance-midi.rb"))
eval_file(File.join(DIRECTORY, "performance-spi.rb"))
eval_file(File.join(DIRECTORY, "performance.rb"))
eval_file(File.join(DIRECTORY, "time.rb"))

# setup

initialiseVoices()

signalAllActivePortsOff()

use_bpm(get("settings/metronome")[:unitsPerMinute])

use_tuning(get("settings/space")[:tuning])

use_random_seed(get("settings/general")[:seed])
use_cue_logging(get("settings/general")[:shouldLogCues])
use_debug(get("settings/general")[:shouldLogDebug])
use_midi_logging(get("settings/general")[:shouldLogMIDI])

# time-state

set("motifs", createStateMotifs())

set("space/chordRoot", 0)
set("space/key", get("settings/space")[:initialKey])

set("time/units", nil)

# live loops

live_loop(:maintainLog) do
  activateLogger()
  sync_bpm("time/measure")
end

live_loop(:maintainSpace, delay: (get("settings/space")[:numMeasuresBeforeProgressionsBegin] * get("settings/metronome")[:numUnitsPerMeasure])) do
  waitNumUnitsQuantised(get("settings/metronome")[:numUnitsPerMeasure] / 2)
  activateSpace()
  sync_bpm("time/measure")
end

live_loop(:measureTime, delay: get("settings/metronome")[:startDelay]) do
  activateMetronome()
end

live_loop(:maintainVoices, sync_bpm: "time/measure") do
  get("settings/voices")[:selection].each do |voiceType|
    in_thread(name: "#{voiceType}".to_sym) do
      activateVoices(voiceType)
    end
  end
  sync_bpm("time/measure")
end
