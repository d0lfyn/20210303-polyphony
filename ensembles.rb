# generalised functions

define :getInstrumentSpaceDomainRangePair do |pInstrument, pSpaceDomain|
  return makeRangePair(
    getPositionAtOrAbovePitch(pInstrument[:RANGE][:low], pSpaceDomain),
    getPositionAtOrBelowPitch(pInstrument[:RANGE][:high], pSpaceDomain),
  )
end

# constants

INSTRUMENTS = {
  BASSOON: {
		SHORT_SWITCHES: [4].freeze,
		MID_SWITCHES: [4, 5].freeze,
		LONG_SWITCHES: [1].freeze,
		LEGATO_SWITCHES: [0].freeze,
		CC_NUMS: [1, 11].freeze,
		RANGE: makeRangePair(note(:Bb2), note(:C5)),
	}.freeze,
  BB_CLARINET: {
		SHORT_SWITCHES: [4].freeze,
		MID_SWITCHES: [4, 5].freeze,
		LONG_SWITCHES: [1].freeze,
		LEGATO_SWITCHES: [0].freeze,
		CC_NUMS: [1, 11].freeze,
		RANGE: makeRangePair(note(:D3), note(:D6)),
	}.freeze,
  CELLO_BOW: {
		SHORT_SWITCHES: [19].freeze,
		MID_SWITCHES: [19].freeze,
		LONG_SWITCHES: [1, 2, 3, 11, 18].freeze,
		LEGATO_SWITCHES: [0].freeze,
		CC_NUMS: [1, 11].freeze,
		RANGE: makeRangePair(note(:C2), note(:G5)),
	}.freeze,
  CELLO_PLUCK: {
		SHORT_SWITCHES: [6].freeze,
		MID_SWITCHES: [6].freeze,
		LONG_SWITCHES: [1, 2, 3, 11, 18].freeze,
		LEGATO_SWITCHES: [6].freeze,
		CC_NUMS: [1, 11].freeze,
		RANGE: makeRangePair(note(:C2), note(:G5)),
	}.freeze,
	FLUTE: {
		SHORT_SWITCHES: [4].freeze,
		MID_SWITCHES: [4, 5].freeze,
		LONG_SWITCHES: [1].freeze,
		LEGATO_SWITCHES: [0].freeze,
		CC_NUMS: [1, 11].freeze,
		RANGE: makeRangePair(note(:C4), note(:G6)),
	}.freeze,
	HARPSICHORD: {
		SHORT_SWITCHES: [].freeze,
		MID_SWITCHES: [].freeze,
		LONG_SWITCHES: [].freeze,
		LEGATO_SWITCHES: [].freeze,
		CC_NUMS: [].freeze,
		RANGE: makeRangePair(note(:F1), note(:F6)),
	}.freeze,
	OBOE: {
		SHORT_SWITCHES: [4].freeze,
		MID_SWITCHES: [4, 5].freeze,
		LONG_SWITCHES: [1].freeze,
		LEGATO_SWITCHES: [0].freeze,
		CC_NUMS: [1, 11].freeze,
		RANGE: makeRangePair(note(:C4), note(:C6)),
	}.freeze,
	PIANO: {
		SHORT_SWITCHES: [].freeze,
		MID_SWITCHES: [].freeze,
		LONG_SWITCHES: [].freeze,
		LEGATO_SWITCHES: [].freeze,
		CC_NUMS: [].freeze,
		RANGE: makeRangePair(note(:C1), note(:C8)),
	}.freeze,
	SYNTH: {
		SHORT_SWITCHES: [].freeze,
		MID_SWITCHES: [].freeze,
		LONG_SWITCHES: [].freeze,
		LEGATO_SWITCHES: [].freeze,
		CC_NUMS: [].freeze,
		RANGE: makeRangePair(note(:C1), note(:C8)),
	}.freeze,
	VIOLA_BOW: {
		SHORT_SWITCHES: [19].freeze,
		MID_SWITCHES: [19].freeze,
		LONG_SWITCHES: [1, 2, 3, 11, 18].freeze,
		LEGATO_SWITCHES: [0].freeze,
		CC_NUMS: [1, 11].freeze,
		RANGE: makeRangePair(note(:C3), note(:C6)),
	}.freeze,
  VIOLA_PLUCK: {
		SHORT_SWITCHES: [6].freeze,
		MID_SWITCHES: [6].freeze,
		LONG_SWITCHES: [1, 2, 3, 11, 18].freeze,
		LEGATO_SWITCHES: [6].freeze,
		CC_NUMS: [1, 11].freeze,
		RANGE: makeRangePair(note(:C3), note(:C6)),
	}.freeze,
	VIOLIN_BOW: {
		SHORT_SWITCHES: [19].freeze,
		MID_SWITCHES: [19].freeze,
		LONG_SWITCHES: [1, 2, 3, 11, 18].freeze,
		LEGATO_SWITCHES: [0].freeze,
		CC_NUMS: [1, 11].freeze,
		RANGE: makeRangePair(note(:G3), note(:G6)),
	}.freeze,
	VIOLIN_PLUCK: {
		SHORT_SWITCHES: [6].freeze,
		MID_SWITCHES: [6].freeze,
		LONG_SWITCHES: [1, 2, 3, 11, 18].freeze,
		LEGATO_SWITCHES: [6].freeze,
		CC_NUMS: [1, 11].freeze,
		RANGE: makeRangePair(note(:G3), note(:G6)),
	}.freeze,
	YANGQIN: {
		SHORT_SWITCHES: [].freeze,
		MID_SWITCHES: [nil, note(:E1), note(:Fs1), note(:G1), note(:A1)].freeze,
		LONG_SWITCHES: [].freeze,
		LEGATO_SWITCHES: [].freeze,
		CC_NUMS: [].freeze,
		RANGE: makeRangePair(note(:F2), note(:A6)),
	}.freeze,
}.freeze

# time-state

set("ensembles", {
	HARPSICHORDS: Array.new(16, INSTRUMENTS[:HARPSICHORD]).freeze,
	PIANOS: Array.new(16, INSTRUMENTS[:PIANO]).freeze,
  STRINGS: [
    INSTRUMENTS[:VIOLIN_BOW], INSTRUMENTS[:VIOLIN_BOW], INSTRUMENTS[:VIOLA_BOW], INSTRUMENTS[:CELLO_BOW],
    INSTRUMENTS[:VIOLIN_BOW], INSTRUMENTS[:VIOLIN_BOW], INSTRUMENTS[:VIOLA_BOW], INSTRUMENTS[:CELLO_BOW],
    INSTRUMENTS[:VIOLIN_BOW], INSTRUMENTS[:VIOLIN_BOW], INSTRUMENTS[:VIOLA_BOW], INSTRUMENTS[:CELLO_BOW],
    INSTRUMENTS[:VIOLIN_BOW], INSTRUMENTS[:VIOLIN_BOW], INSTRUMENTS[:VIOLA_BOW], INSTRUMENTS[:CELLO_BOW],
  ].freeze,
  STRINGS_AND_WINDS: [
    INSTRUMENTS[:VIOLIN_BOW], INSTRUMENTS[:VIOLIN_BOW], INSTRUMENTS[:VIOLA_BOW], INSTRUMENTS[:CELLO_BOW],
    INSTRUMENTS[:FLUTE], INSTRUMENTS[:OBOE], INSTRUMENTS[:BB_CLARINET], INSTRUMENTS[:BASSOON],
		INSTRUMENTS[:VIOLIN_BOW], INSTRUMENTS[:VIOLIN_BOW], INSTRUMENTS[:VIOLA_BOW], INSTRUMENTS[:CELLO_BOW],
    INSTRUMENTS[:FLUTE], INSTRUMENTS[:OBOE], INSTRUMENTS[:BB_CLARINET], INSTRUMENTS[:BASSOON],
  ].freeze,
  SYNTHS: Array.new(16, INSTRUMENTS[:SYNTH]).freeze,
}.freeze)
