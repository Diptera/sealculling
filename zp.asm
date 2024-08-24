// zp items

ZP: {

.label gameloop = $02	// flag to indicate okay to run a frame
.label general_counter = $03 // framecounter


// scroll settings
// scroll register 7 to 0 moves chars left per pixel

.label scrollpos_hilltop1 = $04
.label scrollercounter_hilltop1 = $05
.label scrollercounteroriginal_hilltop1 = $06

.label scrollpos_hilltop2 = $07
.label scrollercounter_hilltop2 = $08
.label scrollercounteroriginal_hilltop2 = $09

.label scrollpos_ice = $0a
.label scrollercounter_ice = $0b
.label scrollercounteroriginal_ice = $0c


.label end_col_colour = $0d  // temp holding space when scrolling colours
	//.byte $00, $00, $00, $00, $00, $00, $00

.label NEXTVALUE = $15

}

