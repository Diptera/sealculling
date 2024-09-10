// zp items

*=$02 "ZP" virtual

ZP: {

gameloop:			// flag to indicate okay to run a frame
	.byte 0 
general_counter:	// framecounter
	.byte 0 


// scroll settings
// scroll register 7 to 0 moves chars left per pixel
// scroll counter = number of frames before scroll happens
// scroll counter original = number to reset counter to when elapsed
scrollpos_hilltop1:
	.byte 0
scrollercounter_hilltop1:
	.byte 0
scrollercounteroriginal_hilltop1:
	.byte 0

scrollpos_hilltop2:
	.byte 0
scrollercounter_hilltop2:
	.byte 0
scrollercounteroriginal_hilltop2:
	.byte 0

scrollpos_ice:
	.byte 0
scrollercounter_ice:
	.byte 0
scrollercounteroriginal_ice:
	.byte 0

scrolldirection:	// 0 = left, 1 = right, ff = none
	.byte 0

joystick2:
	.byte 0
joystick1:
	.byte 0

playerx:
	.byte 0
playery:
	.byte 0

mapicepos:
	.byte 0

suncycle: // counter for how many frames between each sun pos
	.byte 0	
sunpos:		// current position of the sun 0 - 279
	.byte 0, 0
sunx:	// temp copy of x pos to restore after raster split hides it
	.byte 0, 0

playertemperature:  // health of player
	.byte 0
playertemperaturetick:  // ticks until health drops 1
	.byte 0, 0


max_seals:		// max number of seals that can be spawned concurrently
	.byte 0
current_seals:	// current number of seals
	.byte 0




}



//ZPold: {
//
//.label gameloop = $02	// flag to indicate okay to run a frame
//.label general_counter = $03 // framecounter


// scroll settings
// scroll register 7 to 0 moves chars left per pixel

//.label scrollpos_hilltop1 = $04
//.label scrollercounter_hilltop1 = $05
//.label scrollercounteroriginal_hilltop1 = $06

//.label scrollpos_hilltop2 = $07
//.label scrollercounter_hilltop2 = $08
//.label scrollercounteroriginal_hilltop2 = $09

//.label scrollpos_ice = $0a
//.label scrollercounter_ice = $0b
//.label scrollercounteroriginal_ice = $0c

//.label scrolldirection = $0d  // 0 = left, 1 = right, ff = none

//.label joystick2 = $0e
//.label joystick1 = $0f


//.label end_col_colour = $0d  // temp holding space when scrolling colours
	//.byte $00, $00, $00, $00, $00, $00, $00
//.label NEXTVALUE = $15

//}

