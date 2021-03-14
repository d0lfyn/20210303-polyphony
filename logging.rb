# specialised functions

define :activateLogger do
	puts(get("settings/general")[:seed])
end

define :logOptional do |pMessage|
	puts(pMessage) if get("settings/logging")[:shouldLogOptional]
end
