# specialised functions

define :activateLogger do
  puts("seed: #{get("settings/general")[:seed].to_s}".freeze)
  puts("minutes elapsed: #{(get("time/units") / get("settings/metronome")[:unitsPerMinute].to_f).round(4).to_s}")
end

define :logOptional do |pMessage|
  puts(pMessage) if get("settings/logging")[:shouldLogOptional]
end
