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

define :clearVoice do |pVoiceType, pVoiceNumber|
  set("#{pVoiceType}/#{pVoiceNumber.to_s}", nil)
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
  return makeRangeArrayFromZero(getEnsemble(pVoiceType).length)
end

define :getAllVoicesNumbersRange do |pVoiceType|
  return (0...getEnsemble(pVoiceType).length).freeze
end

define :getAllVoicesSyntheses do |pVoiceType|
  allSyntheses = []
  getAllVoicesNumbersRange(pVoiceType).each do |n|
    allSyntheses.push(getVoiceSynthesis(pVoiceType, n))
  end

  return allSyntheses.freeze
end

define :getEnsemble do |pVoiceType|
  return get("settings/voices/#{pVoiceType}")[:performance][:ensemble]
end 

define :getVoiceInstrument do |pVoiceType, pVoiceNumber|
  return getEnsemble(pVoiceType)[pVoiceNumber]
end

define :getVoiceSynthesis do |pVoiceType, pVoiceNumber|
  return get("#{pVoiceType}/#{pVoiceNumber.to_s}")
end

define :isVoiceActive? do |pVoiceType, pVoiceNumber|
  return !getVoiceSynthesis(pVoiceType, pVoiceNumber).nil?
end

define :isVoiceFree? do |pVoiceType, pVoiceNumber|
  return getVoiceSynthesis(pVoiceType, pVoiceNumber).nil?
end

define :setAllVoicesSyntheses do |pVoiceType, pSyntheses|
  getAllVoicesNumbersRange(pVoiceType).each do |n|
    setVoiceSynthesis(pVoiceType, n, pSyntheses[n])
  end
end

define :setVoiceSynthesis do |pVoiceType, pVoiceNumber, pSynthesis|
  set("#{pVoiceType}/#{pVoiceNumber.to_s}", pSynthesis)
end
