# specialised functions

define :areAllVoicesFree? do |pVoiceType|
	getAllVoicesNumbersRange(pVoiceType).each do |n|
		return false if isVoiceActive?(pVoiceType, n)
	end

	return true
end

define :clearAllVoices do |pVoiceType|
	getAllVoicesNumbersRange(pVoiceType).each do |n|
		clearVoice(pVoiceType, n)
	end
end

define :clearVoice do |pVoiceType, pNumber|
	set("#{pVoiceType}/#{pNumber.to_s}", nil)
end

define :countVoicesActive do |pVoiceType|
	count = 0
	getAllVoicesNumbersRange(pVoiceType).each do |n|
		count += 1 if isVoiceActive?(pVoiceType, n)
	end

	return count
end

define :getAllActiveSyntheses do
	allSyntheses = []
	get("settings/voices")[:selection].each do |voiceType|
		allSyntheses += getAllActiveVoicesSyntheses(voiceType)
	end

	return allSyntheses.freeze
end

define :getAllActiveVoicesSyntheses do |pVoiceType|
	allActiveSyntheses = []
	getAllVoicesNumbersRange(pVoiceType).each do |n|
		synthesis = getVoiceSynthesis(pVoiceType, n)
		allActiveSyntheses.push(synthesis) unless synthesis.nil?
	end

	return allActiveSyntheses.freeze
end

define :getAllSyntheses do
	allSyntheses = []
	get("settings/voices")[:selection].each do |voiceType|
		allSyntheses += getAllVoicesSyntheses(voiceType)
	end

	return allSyntheses.freeze
end

define :getAllVoicesNumbersArray do |pVoiceType|
	if get("settings/voices/#{pVoiceType}")[:performance][:useMIDI]
		return makeRangeArrayFromZero(get("settings/voices/#{pVoiceType}")[:performance][:midi][:ensemble].length)
	else
		return makeRangeArrayFromZero(get("settings/voices/#{pVoiceType}")[:performance][:spi][:ensemble].length)
	end
end

define :getAllVoicesNumbersRange do |pVoiceType|
	if get("settings/voices/#{pVoiceType}")[:performance][:useMIDI]
		return (0...get("settings/voices/#{pVoiceType}")[:performance][:midi][:ensemble].length).freeze
	else
		return (0...get("settings/voices/#{pVoiceType}")[:performance][:spi][:ensemble].length).freeze
	end
end

define :getAllVoicesSyntheses do |pVoiceType|
	allSyntheses = []
	getAllVoicesNumbersRange(pVoiceType).each do |n|
		allSyntheses.push(getVoiceSynthesis(pVoiceType, n))
	end

	return allSyntheses.freeze
end

define :getVoiceInstrument do |pVoiceType, pNumber|
	if get("settings/voices/#{pVoiceType}")[:performance][:useMIDI]
		return getVoiceMIDIInstrument(pVoiceType, pNumber)
	else
		return getVoiceSPiInstrument(pVoiceType, pNumber)
	end
end

define :getVoiceSPiInstrument do |pVoiceType, pNumber|
	return get("settings/voices/#{pVoiceType}")[:performance][:spi][:ensemble][pNumber]
end

define :getVoiceMIDIInstrument do |pVoiceType, pNumber|
	return get("settings/voices/#{pVoiceType}")[:performance][:midi][:ensemble][pNumber]
end

define :getVoiceSynthesis do |pVoiceType, pNumber|
	return get("#{pVoiceType}/#{pNumber.to_s}")
end

define :isVoiceActive? do |pVoiceType, pNumber|
	return !getVoiceSynthesis(pVoiceType, pNumber).nil?
end

define :isVoiceFree? do |pVoiceType, pNumber|
	return getVoiceSynthesis(pVoiceType, pNumber).nil?
end

define :setAllVoicesSyntheses do |pVoiceType, pSyntheses|
	getAllVoicesNumbersRange(pVoiceType).each do |n|
		setVoiceSynthesis(pVoiceType, n, pSyntheses[n])
	end
end

define :setVoiceSynthesis do |pVoiceType, pNumber, pSynthesis|
	set("#{pVoiceType}/#{pNumber.to_s}", pSynthesis)
end
