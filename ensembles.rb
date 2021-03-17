# generalised functions

define :getInstrumentSpaceDomainRangePair do |pInstrument, pSpaceDomain|
  return makeRangePair(
    getPositionAtOrAbovePitch(pInstrument[:RANGE][:low], pSpaceDomain),
    getPositionAtOrBelowPitch(pInstrument[:RANGE][:high], pSpaceDomain),
  )
end

# constants

MIDI_INSTRUMENTS = {
  BBCSO_BASSOON: {
		SHORT_SWITCHES: [4].freeze,
		MID_SWITCHES: [4, 5].freeze,
		LONG_SWITCHES: [1].freeze,
		LEGATO_SWITCHES: [0].freeze,
		CC_NUMS: [1, 11].freeze,
		RANGE: makeRangePair(note(:Bb2), note(:C5)),
	}.freeze,
  BBCSO_CLARINET: {
		SHORT_SWITCHES: [4].freeze,
		MID_SWITCHES: [4, 5].freeze,
		LONG_SWITCHES: [1].freeze,
		LEGATO_SWITCHES: [0].freeze,
		CC_NUMS: [1, 11].freeze,
		RANGE: makeRangePair(note(:D3), note(:D6)),
	}.freeze,
  BBCSO_CELLO_BOW: {
		SHORT_SWITCHES: [19].freeze,
		MID_SWITCHES: [19].freeze,
		LONG_SWITCHES: [1, 2, 3, 11, 18].freeze,
		LEGATO_SWITCHES: [0].freeze,
		CC_NUMS: [1, 11].freeze,
		RANGE: makeRangePair(note(:C2), note(:G5)),
	}.freeze,
  BBCSO_CELLO_PLUCK: {
		SHORT_SWITCHES: [6].freeze,
		MID_SWITCHES: [6].freeze,
		LONG_SWITCHES: [1, 2, 3, 11, 18].freeze,
		LEGATO_SWITCHES: [6].freeze,
		CC_NUMS: [1, 11].freeze,
		RANGE: makeRangePair(note(:C2), note(:G5)),
	}.freeze,
	BBCSO_FLUTE: {
		SHORT_SWITCHES: [4].freeze,
		MID_SWITCHES: [4, 5].freeze,
		LONG_SWITCHES: [1].freeze,
		LEGATO_SWITCHES: [0].freeze,
		CC_NUMS: [1, 11].freeze,
		RANGE: makeRangePair(note(:C4), note(:G6)),
	}.freeze,
	BBCSO_FRENCH_HORN: {
		SHORT_SWITCHES: [2].freeze,
		MID_SWITCHES: [3].freeze,
		LONG_SWITCHES: [1, 4, 5].freeze,
		LEGATO_SWITCHES: [0].freeze,
		CC_NUMS: [1, 11].freeze,
		RANGE: makeRangePair(note(:C3), note(:C5)),
	}.freeze,
	BBCSO_OBOE: {
		SHORT_SWITCHES: [4].freeze,
		MID_SWITCHES: [4, 5].freeze,
		LONG_SWITCHES: [1].freeze,
		LEGATO_SWITCHES: [0].freeze,
		CC_NUMS: [1, 11].freeze,
		RANGE: makeRangePair(note(:C4), note(:C6)),
	}.freeze,
	BBCSO_TENOR_TROMBONE: {
		SHORT_SWITCHES: [2].freeze,
		MID_SWITCHES: [3].freeze,
		LONG_SWITCHES: [1, 4, 5].freeze,
		LEGATO_SWITCHES: [0].freeze,
		CC_NUMS: [1, 11].freeze,
		RANGE: makeRangePair(note(:G1), note(:D5)),
	}.freeze,
	BBCSO_TRUMPET: {
		SHORT_SWITCHES: [2].freeze,
		MID_SWITCHES: [3].freeze,
		LONG_SWITCHES: [1, 4, 5].freeze,
		LEGATO_SWITCHES: [0].freeze,
		CC_NUMS: [1, 11].freeze,
		RANGE: makeRangePair(note(:E3), note(:C6)),
	}.freeze,
	BBCSO_TUBA: {
		SHORT_SWITCHES: [2].freeze,
		MID_SWITCHES: [3].freeze,
		LONG_SWITCHES: [1, 4, 5].freeze,
		LEGATO_SWITCHES: [0].freeze,
		CC_NUMS: [1, 11].freeze,
		RANGE: makeRangePair(note(:D1), note(:E4)),
	}.freeze,
	BBCSO_VIOLA_BOW: {
		SHORT_SWITCHES: [19].freeze,
		MID_SWITCHES: [19].freeze,
		LONG_SWITCHES: [1, 2, 3, 11, 18].freeze,
		LEGATO_SWITCHES: [0].freeze,
		CC_NUMS: [1, 11].freeze,
		RANGE: makeRangePair(note(:C3), note(:C6)),
	}.freeze,
  BBCSO_VIOLA_PLUCK: {
		SHORT_SWITCHES: [6].freeze,
		MID_SWITCHES: [6].freeze,
		LONG_SWITCHES: [1, 2, 3, 11, 18].freeze,
		LEGATO_SWITCHES: [6].freeze,
		CC_NUMS: [1, 11].freeze,
		RANGE: makeRangePair(note(:C3), note(:C6)),
	}.freeze,
	BBCSO_VIOLIN_BOW: {
		SHORT_SWITCHES: [19].freeze,
		MID_SWITCHES: [19].freeze,
		LONG_SWITCHES: [1, 2, 3, 11, 18].freeze,
		LEGATO_SWITCHES: [0].freeze,
		CC_NUMS: [1, 11].freeze,
		RANGE: makeRangePair(note(:G3), note(:G6)),
	}.freeze,
	BBCSO_VIOLIN_PLUCK: {
		SHORT_SWITCHES: [6].freeze,
		MID_SWITCHES: [6].freeze,
		LONG_SWITCHES: [1, 2, 3, 11, 18].freeze,
		LEGATO_SWITCHES: [6].freeze,
		CC_NUMS: [1, 11].freeze,
		RANGE: makeRangePair(note(:G3), note(:G6)),
	}.freeze,
	PIANOTEQ_HARPSICHORD: {
		SHORT_SWITCHES: [].freeze,
		MID_SWITCHES: [].freeze,
		LONG_SWITCHES: [].freeze,
		LEGATO_SWITCHES: [].freeze,
		CC_NUMS: [].freeze,
		RANGE: makeRangePair(note(:F1), note(:F6)),
	}.freeze,
	PIANOTEQ_PIANO: {
		SHORT_SWITCHES: [].freeze,
		MID_SWITCHES: [].freeze,
		LONG_SWITCHES: [].freeze,
		LEGATO_SWITCHES: [].freeze,
		CC_NUMS: [].freeze,
		RANGE: makeRangePair(note(:C1), note(:C8)),
	}.freeze,
	SERUM: {
		SHORT_SWITCHES: [].freeze,
		MID_SWITCHES: [].freeze,
		LONG_SWITCHES: [].freeze,
		LEGATO_SWITCHES: [].freeze,
		CC_NUMS: [].freeze,
		RANGE: makeRangePair(note(:C1), note(:C8)),
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
	}.freeze,
	BASS: {
		SYNTH: :fm,
		RANGE: makeRangePair(note(:F2), note(:C4)),
	}.freeze,
	SOPRANO: {
		SYNTH: :square,
		RANGE: makeRangePair(note(:Bb3), note(:E5)),
	}.freeze,
	TENOR: {
		SYNTH: :pulse,
		RANGE: makeRangePair(note(:C3), note(:G4)),
	}.freeze,
}.freeze

# time-state

set("ensembles/midi", {
	BBCSO_BRASS_4: [
    MIDI_INSTRUMENTS[:BBCSO_TRUMPET], MIDI_INSTRUMENTS[:BBCSO_FRENCH_HORN], MIDI_INSTRUMENTS[:BBCSO_TENOR_TROMBONE], MIDI_INSTRUMENTS[:BBCSO_TUBA],
  ].freeze,
	BBCSO_STRINGS_4: [
    MIDI_INSTRUMENTS[:BBCSO_VIOLIN_BOW], MIDI_INSTRUMENTS[:BBCSO_VIOLIN_BOW], MIDI_INSTRUMENTS[:BBCSO_VIOLA_BOW], MIDI_INSTRUMENTS[:BBCSO_CELLO_BOW],
  ].freeze,
  BBCSO_WINDS_4: [
    MIDI_INSTRUMENTS[:BBCSO_FLUTE], MIDI_INSTRUMENTS[:BBCSO_OBOE], MIDI_INSTRUMENTS[:BBCSO_CLARINET], MIDI_INSTRUMENTS[:BBCSO_BASSOON],
  ].freeze,
  BBCSO_WINDS_5: [
    MIDI_INSTRUMENTS[:BBCSO_FLUTE], MIDI_INSTRUMENTS[:BBCSO_OBOE], MIDI_INSTRUMENTS[:BBCSO_CLARINET], MIDI_INSTRUMENTS[:BBCSO_FRENCH_HORN], MIDI_INSTRUMENTS[:BBCSO_BASSOON],
  ].freeze,
	PIANOTEQ_HARPSICHORDS_4: Array.new(4, MIDI_INSTRUMENTS[:PIANOTEQ_HARPSICHORD]).freeze,
	PIANOTEQ_PIANOS_4: Array.new(4, MIDI_INSTRUMENTS[:PIANOTEQ_PIANO]).freeze,
	SERUMS_4: Array.new(4, MIDI_INSTRUMENTS[:SERUM]).freeze,
}.freeze)

set("ensembles/spi", {
	SYNTHS_SATB_4: [
		SPI_INSTRUMENTS[:SOPRANO], SPI_INSTRUMENTS[:ALTO], SPI_INSTRUMENTS[:TENOR], SPI_INSTRUMENTS[:BASS],
	].freeze,
	SYNTHS_SATB_8: [
		SPI_INSTRUMENTS[:SOPRANO], SPI_INSTRUMENTS[:ALTO], SPI_INSTRUMENTS[:TENOR], SPI_INSTRUMENTS[:BASS],
		SPI_INSTRUMENTS[:SOPRANO], SPI_INSTRUMENTS[:ALTO], SPI_INSTRUMENTS[:TENOR], SPI_INSTRUMENTS[:BASS],
	].freeze,
}.freeze)
