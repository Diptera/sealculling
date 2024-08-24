.filenamespace sealcullingforbeginners


#import "labels.asm"
#import "zp.asm"



//----------------------------------------------------------
//				BASIC PROGRAM
// 	literal bytes to create BASIC program
// 	"10 SYS 2062"
//----------------------------------------------------------
* = $0801 "BASIC" // locate to start of BASIC RAM

.byte $0C, $0B 				// next line number location
.byte $0A, $00				// line number 10
.byte $9E					// SYS token
.byte $20					// SPACE
.byte $32, $30, $36, $32	// "2062" in PETSCII
.byte $00, $00, $00			// BRK (end of line), next line pointer

* = * "Assembly code"

//----------------------------------------------------------
//				Start of Machine Code
// $080E / 2062 is start of assembly code
// (immediately following the end of the BASIC program)
//----------------------------------------------------------


// Enable sprite and set pointer
//lda #$01
//sta LABELS.sprEnableR
//lda #$80
//sta LABELS.sprPointerR

// initial position sprite
//lda IRQ.sprx1 
//sta LABELS.sprXLO
//lda #70
//sta LABELS.sprY


//.break

// bank out BASIC and kernel

//.break
lda $01
and #%11111000
ora #%00000101
sta $01

// default values
lda #07
sta ZP.scrollpos_hilltop1
lda #08
sta ZP.scrollercounter_hilltop1
sta ZP.scrollercounteroriginal_hilltop1

lda #07
sta ZP.scrollpos_hilltop2
lda #04
sta ZP.scrollercounter_hilltop2
sta ZP.scrollercounteroriginal_hilltop2

lda #07
sta ZP.scrollpos_ice
lda #02
sta ZP.scrollercounter_ice
sta ZP.scrollercounteroriginal_ice


jsr IRQ.irqinit

//.break

// set 38 col mode
lda LABELS.viccontrol2
and #%11110111
sta LABELS.viccontrol2

//.break

// fill screen with chars
ldx #250
lda #$66   // 66 7f
!:
	sta LABELS.screenram,x
	sta [LABELS.screenram + 250], x
	sta [LABELS.screenram + 500], x
	sta [LABELS.screenram + 750], x
	dex
bne !-


//.break

// fill colour ram
ldx #250
lda #$00
!:
	sta LABELS.screencolourram,x
	sta [LABELS.screencolourram + 250], x
	sta [LABELS.screencolourram + 500], x
	sta [LABELS.screencolourram + 750], x
	adc #$01
	dex
bne !-




mainloop:
	lda ZP.gameloop
	beq mainloop

	dec ZP.gameloop  // clear loop for current frame

	// increase gen counter tick once per frame
	inc ZP.general_counter



	// check scroll counter for hill 1 - update and refresh if needed
	dec ZP.scrollercounter_hilltop1
	bpl noscrollhill1				// counter not elapsed, do nothing

	lda ZP.scrollercounteroriginal_hilltop1	// reset the scroll counter
	sta ZP.scrollercounter_hilltop1

	dec ZP.scrollpos_hilltop1			// move hscroll
	bpl noscrollhill1

	lda #$07						// reset hscroll to 7
	sta ZP.scrollpos_hilltop1

	// scroll the colour data
	// preserve end col colours
	lda [LABELS.screencolourram + [6 * 40] ]
	sta ZP.end_col_colour
	lda [LABELS.screencolourram + [6 * 40] + 1]
	sta [ZP.end_col_colour + 1]

	// scroll 2 rows of colour 
	ldx #$01
	!:
	lda [LABELS.screencolourram + [6 * 40] ], x
	dex
	sta [LABELS.screencolourram + [6 * 40] ], x
	inx
	lda [LABELS.screencolourram + [7 * 40] ], x
	dex
	sta [LABELS.screencolourram + [7 * 40] ], x
	inx
	inx
	cpx #$28
	bne !-

	// put saved end col into opposite end
	lda ZP.end_col_colour
	sta [LABELS.screencolourram + [6 * 40] + 39 ]
	lda [ZP.end_col_colour + 1]
	sta [LABELS.screencolourram + [7 * 40] + 39 ]

	noscrollhill1:



	// check scroll counter for hill 2 - update and refresh if needed
	dec ZP.scrollercounter_hilltop2
	bpl noscrollhill2		// counter not elapsed, do nothing

	lda ZP.scrollercounteroriginal_hilltop2	// reset the scroll counter
	sta ZP.scrollercounter_hilltop2

	dec ZP.scrollpos_hilltop2			// move hscroll
	bpl noscrollhill2

	lda #$07						// reset hscroll to 7
	sta ZP.scrollpos_hilltop2

	// scroll the colour data
	// preserve end col colours
	lda [LABELS.screencolourram + [8 * 40] ]
	sta ZP.end_col_colour
	lda [LABELS.screencolourram + [9 * 40] + 1]
	sta [ZP.end_col_colour + 1]
	lda [LABELS.screencolourram + [10 * 40] + 2]
	sta [ZP.end_col_colour + 2]

	// scroll 3 rows of colour 
	ldx #$01
	!:
	lda [LABELS.screencolourram + [8 * 40] ], x
	dex
	sta [LABELS.screencolourram + [8 * 40] ], x
	inx
	lda [LABELS.screencolourram + [9 * 40] ], x
	dex
	sta [LABELS.screencolourram + [9 * 40] ], x
	inx
	lda [LABELS.screencolourram + [10 * 40] ], x
	dex
	sta [LABELS.screencolourram + [10 * 40] ], x
	inx
	inx
	cpx #$28
	bne !-

	// put saved end col into opposite end
	lda ZP.end_col_colour
	sta [LABELS.screencolourram + [8 * 40] + 39 ]
	lda [ZP.end_col_colour + 1]
	sta [LABELS.screencolourram + [9 * 40] + 39 ]
	lda [ZP.end_col_colour + 2]
	sta [LABELS.screencolourram + [10 * 40] + 39 ]

	noscrollhill2:






	// check scroll counter for ice - update and refresh if needed
	dec ZP.scrollercounter_ice
	bmi doscrollice				// counter elapsed, scroll ice
	jmp noscrollice

	doscrollice:
	lda ZP.scrollercounteroriginal_ice	// reset the scroll counter
	sta ZP.scrollercounter_ice

	dec ZP.scrollpos_ice			// move hscroll
	bmi doscrollice2
	jmp noscrollice

	doscrollice2:
	lda #$07						// reset hscroll to 7
	sta ZP.scrollpos_ice
	
	// scroll the colour data
	// preserve end col colours
	lda [LABELS.screencolourram + [11 * 40] ]
	sta ZP.end_col_colour
	lda [LABELS.screencolourram + [12 * 40] + 1]
	sta [ZP.end_col_colour + 1]
	lda [LABELS.screencolourram + [13 * 40] + 2]
	sta [ZP.end_col_colour + 2]
	lda [LABELS.screencolourram + [14 * 40] + 3]
	sta [ZP.end_col_colour + 3]
	lda [LABELS.screencolourram + [15 * 40] + 4]
	sta [ZP.end_col_colour + 4]
	lda [LABELS.screencolourram + [16 * 40] + 5]
	sta [ZP.end_col_colour + 5]
	lda [LABELS.screencolourram + [17 * 40] + 6]
	sta [ZP.end_col_colour + 6]
	lda [LABELS.screencolourram + [18 * 40] + 7]
	sta [ZP.end_col_colour + 7]

	// scroll 8 rows of colour 
	ldx #$01
	!:
	lda [LABELS.screencolourram + [11 * 40] ], x
	dex
	sta [LABELS.screencolourram + [11 * 40] ], x
	inx
	lda [LABELS.screencolourram + [12 * 40] ], x
	dex
	sta [LABELS.screencolourram + [12 * 40] ], x
	inx
	lda [LABELS.screencolourram + [13 * 40] ], x
	dex
	sta [LABELS.screencolourram + [13 * 40] ], x
	inx
	lda [LABELS.screencolourram + [14 * 40] ], x
	dex
	sta [LABELS.screencolourram + [14 * 40] ], x
	inx
	lda [LABELS.screencolourram + [15 * 40] ], x
	dex
	sta [LABELS.screencolourram + [15 * 40] ], x
	inx
	lda [LABELS.screencolourram + [16 * 40] ], x
	dex
	sta [LABELS.screencolourram + [16 * 40] ], x
	inx
	lda [LABELS.screencolourram + [17 * 40] ], x
	dex
	sta [LABELS.screencolourram + [17 * 40] ], x
	inx
	lda [LABELS.screencolourram + [18 * 40] ], x
	dex
	sta [LABELS.screencolourram + [18 * 40] ], x
	inx
	inx
	cpx #$28
	bne !-

	// put saved end col into opposite end
	lda ZP.end_col_colour
	sta [LABELS.screencolourram + [11 * 40] + 39 ]
	lda [ZP.end_col_colour + 1]
	sta [LABELS.screencolourram + [12 * 40] + 39 ]
	lda [ZP.end_col_colour + 2]
	sta [LABELS.screencolourram + [13 * 40] + 39 ]
	lda [ZP.end_col_colour + 3]
	sta [LABELS.screencolourram + [14 * 40] + 39 ]
	lda [ZP.end_col_colour + 4]
	sta [LABELS.screencolourram + [15 * 40] + 39 ]
	lda [ZP.end_col_colour + 5]
	sta [LABELS.screencolourram + [16 * 40] + 39 ]
	lda [ZP.end_col_colour + 6]
	sta [LABELS.screencolourram + [17 * 40] + 39 ]
	lda [ZP.end_col_colour + 7]
	sta [LABELS.screencolourram + [18 * 40] + 39 ]
	lda [ZP.end_col_colour + 8]


	noscrollice:



	lda #GREEN
	sta LABELS.border

	jmp mainloop

rts




#import "IRQs.asm"



// sprite data - 21 bits high, 24 wide

*=$2000 "Sprite data" // put sprite data at 8192 (128th * 64)

.byte %00000000, %01111110, %00000000
.byte %00000011, %11111111, %11000000
.byte %00000111, %11111111, %11100000
.byte %00011111, %11111111, %11111000
.byte %00011111, %11111111, %11111000
.byte %00111111, %11111111, %11111100
.byte %01111111, %11000111, %11111110
.byte %01111111, %10111011, %11111110
.byte %11111111, %01101101, %11111110
.byte %11111110, %11000110, %11111111
.byte %11111101, %10000011, %01111111
.byte %11111110, %11000110, %11111111
.byte %11111111, %01101101, %11111111
.byte %01111111, %10111011, %11111110
.byte %01111111, %11000111, %11111110
.byte %00111111, %11111111, %11111100
.byte %00011111, %11111111, %11111000
.byte %00011111, %11111111, %11111000
.byte %00000111, %11111111, %11100000
.byte %00000011, %11111111, %11000000
.byte %00000000, %01111110, %00000000
.byte %00000000 // pad to 64 bytes

.byte %00000001, %01010101, %10101010
.byte %00000000, %01010101, %10101010
.byte %00000000, %01010101, %10101010
.byte %00000000, %01010101, %10101010
.byte %00000000, %01010101, %10101010
.byte %00000000, %01010101, %10101010
.byte %01000011, %01010101, %10101010
.byte %01010101, %10101010, %11111111
.byte %01010101, %10101010, %11111111
.byte %01010101, %10101010, %11111111
.byte %01010101, %10101010, %11111111
.byte %01010101, %10101010, %11111111
.byte %01010101, %10101010, %11111111
.byte %01010101, %10101010, %11111111
.byte %10101010, %11111111, %01000000
.byte %10101010, %11111111, %00000000
.byte %10101010, %11111111, %00000000
.byte %10101010, %11111111, %00000000
.byte %10101010, %11111111, %00000000
.byte %10101010, %11111111, %00000000
.byte %10101010, %11111111, %00000000
.byte %00000000	// pad to 64 bytes


//----------------------------------------------------------

