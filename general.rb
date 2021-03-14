# generalised functions

define :chooseAbsIntWithWeight do |pWt, pInts|
  if (pWt.zero? || (pInts.length < 2))
    return pInts.choose
  else
    minAbsInt = pInts.min { |a, b| (a.abs <=> b.abs) }.abs
    maxAbsInt = pInts.max { |a, b| (a.abs <=> b.abs) }.abs
    weightedPool = []
    while weightedPool.empty?
      if (pWt < 0)
        weightedPool = pInts.select { |i| (i.abs <= rrandIWithWeight(pWt, minAbsInt, maxAbsInt)) }
      else
        weightedPool = pInts.select { |i| (i.abs >= rrandIWithWeight(pWt, minAbsInt, maxAbsInt)) }
      end
    end

    return weightedPool.choose
  end
end

define :evalChance? do |pChance|
  return ((pChance >= 1) || ((pChance > 0) && (rand() < pChance)))
end

define :getIntInRangePair do |pRangePair|
  return rrand_i(pRangePair[:low], pRangePair[:high])
end

define :getInRangePair do |pRangePair|
  return rrand(pRangePair[:low], pRangePair[:high])
end

define :getMax do |pA, pB|
  return ((pA > pB) ? pA : pB)
end

define :getMin do |pA, pB|
  return ((pA < pB) ? pA : pB)
end

define :getRangeArraysInAscendingArray do |pAscendingArray|
	if pAscendingArray.empty?
		return [].freeze
	end

  i = 0
  ranges = []
  pAscendingArray.length.times do
    start = i
    while (((i + 1) != pAscendingArray.length) && ((pAscendingArray[i + 1] - pAscendingArray[i]) == 1))
      i += 1
    end
    ranges.push((pAscendingArray[start]..pAscendingArray[i]).to_a.freeze)
    if ((i + 1) == pAscendingArray.length)
      break
    else
      i += 1
    end
  end

  return ranges.freeze
end

define :getTrueIndices do |pBoolsRing|
  return pBoolsRing.to_a.each_index.select { |i| pBoolsRing[i] }.freeze
end

define :makeArrayOfIntsFromRangePair do |pRangePair|
	return (pRangePair[:low]..pRangePair[:high]).to_a.freeze
end

define :makeRangeArrayFromZero do |pEndInt|
	return (0...pEndInt).to_a.freeze
end

define :makeMirrorRangePair do |pValue|
  return makeRangePair(-pValue, pValue)
end

define :makeRangePair do |pLow, pHigh|
  return {
		low: pLow,
		high: pHigh,
	}.freeze
end

define :randIWithWeight do |pWt, pMax = 1|
	return randWithWeight(pWt, (pMax + 1)).to_i
end

# solution adapted from Jochen Hertle: https://in-thread.sonic-pi.net/t/choosing-random-ints-favouring-large-small/5234/2?u=d0lfyn
define :randWithWeight do |pWt, pMax = 1|
	if ((pWt < -1) || (pWt > 1))
		return nil
	elsif pWt.zero?
		return rand(pMax)
	else
		return (pMax * (0.5 * (pWt + Math.sqrt(pWt**2 + 4*pWt*rand() - 2*pWt + 1) - 1) / pWt.to_f))
	end
end

define :rrandIWithWeight do |pWt, pMin, pMax|
	return (randIWithWeight(pWt, (pMax - pMin)) + pMin)
end

define :rrandWithWeight do |pWt, pMin, pMax|
	return (randWithWeight(pWt, (pMax - pMin)) + pMin)
end
