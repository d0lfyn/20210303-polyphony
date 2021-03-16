# generalised functions

define :getInstrumentSpaceDomainRangePair do |pInstrument, pSpaceDomain|
  return makeRangePair(
    getPositionAtOrAbovePitch(pInstrument[:RANGE][:low], pSpaceDomain),
    getPositionAtOrBelowPitch(pInstrument[:RANGE][:high], pSpaceDomain),
  )
end

# constants

MIDI_INSTRUMENTS = {
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

SPI_INSTRUMENTS = {
	ALTO: {
		SYNTH: :saw,
		RANGE: makeRangePair(note(:G3), note(:C5)),
		RANGE: makeRangePair(note(:C3), note(:C6)),
	}.freeze,
	BASS: {
		SYNTH: :fm,
		RANGE: makeRangePair(note(:F2), note(:C4)),
		RANGE: makeRangePair(note(:C2), note(:G5)),
	}.freeze,
	SOPRANO: {
		SYNTH: :square,
		RANGE: makeRangePair(note(:Bb3), note(:E5)),
		RANGE: makeRangePair(note(:G3), note(:G6)),
	}.freeze,
	TENOR: {
		SYNTH: :pulse,
		RANGE: makeRangePair(note(:C3), note(:G4)),
		RANGE: makeRangePair(note(:C3), note(:C6)),
	}.freeze,
}.freeze

# time-state

set("ensembles/midi", {
	HARPSICHORDS: Array.new(16, MIDI_INSTRUMENTS[:HARPSICHORD]).freeze,
	PIANOS: Array.new(16, MIDI_INSTRUMENTS[:PIANO]).freeze,
  STRINGS: [
    MIDI_INSTRUMENTS[:VIOLIN_BOW], MIDI_INSTRUMENTS[:VIOLIN_BOW], MIDI_INSTRUMENTS[:VIOLA_BOW], MIDI_INSTRUMENTS[:CELLO_BOW],
    MIDI_INSTRUMENTS[:VIOLIN_BOW], MIDI_INSTRUMENTS[:VIOLIN_BOW], MIDI_INSTRUMENTS[:VIOLA_BOW], MIDI_INSTRUMENTS[:CELLO_BOW],
    MIDI_INSTRUMENTS[:VIOLIN_BOW], MIDI_INSTRUMENTS[:VIOLIN_BOW], MIDI_INSTRUMENTS[:VIOLA_BOW], MIDI_INSTRUMENTS[:CELLO_BOW],
    MIDI_INSTRUMENTS[:VIOLIN_BOW], MIDI_INSTRUMENTS[:VIOLIN_BOW], MIDI_INSTRUMENTS[:VIOLA_BOW], MIDI_INSTRUMENTS[:CELLO_BOW],
  ].freeze,
  STRINGS_AND_WINDS: [
    MIDI_INSTRUMENTS[:VIOLIN_BOW], MIDI_INSTRUMENTS[:VIOLIN_BOW], MIDI_INSTRUMENTS[:VIOLA_BOW], MIDI_INSTRUMENTS[:CELLO_BOW],
    MIDI_INSTRUMENTS[:FLUTE], MIDI_INSTRUMENTS[:OBOE], MIDI_INSTRUMENTS[:BB_CLARINET], MIDI_INSTRUMENTS[:BASSOON],
		MIDI_INSTRUMENTS[:VIOLIN_BOW], MIDI_INSTRUMENTS[:VIOLIN_BOW], MIDI_INSTRUMENTS[:VIOLA_BOW], MIDI_INSTRUMENTS[:CELLO_BOW],
    MIDI_INSTRUMENTS[:FLUTE], MIDI_INSTRUMENTS[:OBOE], MIDI_INSTRUMENTS[:BB_CLARINET], MIDI_INSTRUMENTS[:BASSOON],
  ].freeze,
  SYNTHS: Array.new(16, MIDI_INSTRUMENTS[:SYNTH]).freeze,
}.freeze)

set("ensembles/spi", {
	SYNTHS_SATB: [
		SPI_INSTRUMENTS[:SOPRANO], SPI_INSTRUMENTS[:ALTO], SPI_INSTRUMENTS[:TENOR], SPI_INSTRUMENTS[:BASS],
		SPI_INSTRUMENTS[:SOPRANO], SPI_INSTRUMENTS[:ALTO], SPI_INSTRUMENTS[:TENOR], SPI_INSTRUMENTS[:BASS],
		SPI_INSTRUMENTS[:SOPRANO], SPI_INSTRUMENTS[:ALTO], SPI_INSTRUMENTS[:TENOR], SPI_INSTRUMENTS[:BASS],
		SPI_INSTRUMENTS[:SOPRANO], SPI_INSTRUMENTS[:ALTO], SPI_INSTRUMENTS[:TENOR], SPI_INSTRUMENTS[:BASS],
	].freeze,
}.freeze)
