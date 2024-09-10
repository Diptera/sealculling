.filenamespace sealcullingforbeginners

#import "macros.asm"
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


//.break

// init setup
jsr INIT.init

//.break


mainloop:
	lda ZP.gameloop
	beq mainloop

	dec ZP.gameloop  // clear loop for current frame

	// increase gen counter tick once per frame
	inc ZP.general_counter

	jsr TOD.tod		// move the sun, set split colours

	// draw player
	lda ZP.playerx
	sta [LABELS.sprXLO + 4]
	lda ZP.playery
	sta [LABELS.sprY + 4]


	jsr JOYSTICK.processjoystick

	jsr SCROLL.mainscroll


	lda #GREEN
	sta LABELS.border

	jmp mainloop

rts





*=* "Init"
#import "init.asm"
*=* "IRQs"
#import "IRQs.asm"
*=* "joystick.asm"
#import "joystick.asm"
*=* "scrolls"
#import "scroll.asm"
*=* "tod"
#import "tod.asm"


*=$4800 "charset"
.import binary "sealchar8.bin"

// sprite data - 21 bits high, 24 wide

*=$6000 "Sprite data" // put sprite data at 8192 (128th * 64)
.import binary "sealsprites.raw"

/*
	00 sun
	01 player
	02 cloud
	03 left fade
	04 right fade
	05 seal
	06 blank
*/



/*
// sun
.byte %00000000, %01111110, %00000000
.byte %00000011, %11111111, %11000000
.byte %00000111, %11111111, %11100000
.byte %00011111, %11111111, %11111000
.byte %00011111, %11111111, %11111000
.byte %00111111, %11111111, %11111100
.byte %01111111, %11111111, %11111110
.byte %01111111, %11111111, %11111110
.byte %11111111, %11111111, %11111110
.byte %11111111, %11111111, %11111111
.byte %11111111, %11111111, %11111111
.byte %11111111, %11111111, %11111111
.byte %11111111, %11111111, %11111111
.byte %01111111, %11111111, %11111110
.byte %01111111, %11111111, %11111110
.byte %00111111, %11111111, %11111100
.byte %00011111, %11111111, %11111000
.byte %00011111, %11111111, %11111000
.byte %00000111, %11111111, %11100000
.byte %00000011, %11111111, %11000000
.byte %00000000, %01111110, %00000000
.byte %00000000 // pad to 64 bytes

// temp player
.byte %00001111, %11111111, %11110000
.byte %01111111, %11111111, %11111110
.byte %11111111, %11111111, %11111111
.byte %11111111, %11111111, %11111111
.byte %11111111, %11111111, %11111111
.byte %01111111, %11111111, %11111110
.byte %00001111, %11111111, %11110000
.byte %00000000, %11111111, %00000000
.byte %11111111, %11111111, %11111111
.byte %11111111, %11111111, %11111111
.byte %11111111, %11111111, %11111111
.byte %00000000, %11111111, %00000000
.byte %00000000, %11111111, %00000000
.byte %11111111, %11111111, %11111111
.byte %11111111, %11111111, %11111111
.byte %11111111, %11111111, %11111111
.byte %11111111, %11100111, %11111111
.byte %11111111, %11100111, %11111111
.byte %11111111, %11100111, %11111111
.byte %11111111, %11100111, %11111111
.byte %11111111, %11100111, %11111111
.byte %00000000 // pad to 64 bytes


// temp cloud
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00011000, %00000000, %00000000
.byte %01111110, %00111000, %00011000
.byte %00111111, %11111110, %11111110
.byte %01111111, %11111111, %11111100
.byte %11111111, %11111111, %11111111
.byte %00111110, %01111100, %00111110
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000	// pad to 64 bytes

// left border fade
.byte %10101000, %00000000, %00000000
.byte %11010000, %00000000, %00000000
.byte %10000000, %00000000, %00000000
.byte %01100000, %00000000, %00000000
.byte %10000000, %00000000, %00000000
.byte %11011000, %00000000, %00000000
.byte %10100000, %00000000, %00000000
.byte %01000000, %00000000, %00000000
.byte %10100000, %00000000, %00000000
.byte %11010000, %00000000, %00000000
.byte %10001000, %00000000, %00000000
.byte %01000000, %00000000, %00000000
.byte %10100000, %00000000, %00000000
.byte %11010000, %00000000, %00000000
.byte %10000000, %00000000, %00000000
.byte %01101000, %00000000, %00000000
.byte %10000000, %00000000, %00000000
.byte %11010000, %00000000, %00000000
.byte %10100000, %00000000, %00000000
.byte %01000000, %00000000, %00000000
.byte %10001000, %00000000, %00000000
.byte %11100000	// pad to 64 bytes


// right border fade
.byte %00000000, %00000000, %00010101
.byte %00000000, %00000000, %00001011
.byte %00000000, %00000000, %00000001
.byte %00000000, %00000000, %00000110
.byte %00000000, %00000000, %00000001
.byte %00000000, %00000000, %00011011
.byte %00000000, %00000000, %00000101
.byte %00000000, %00000000, %00000010
.byte %00000000, %00000000, %00000101
.byte %00000000, %00000000, %00001011
.byte %00000000, %00000000, %00010001
.byte %00000000, %00000000, %00000010
.byte %00000000, %00000000, %00000101
.byte %00000000, %00000000, %00001011
.byte %00000000, %00000000, %00000001
.byte %00000000, %00000000, %00010110
.byte %00000000, %00000000, %00000001
.byte %00000000, %00000000, %00001011
.byte %00000000, %00000000, %00000101
.byte %00000000, %00000000, %00000010
.byte %00000000, %00000000, %00010001
.byte %00000000	// pad to 64 bytes



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



// blank sprite
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000	// pad to 64 bytes
*/


//----------------------------------------------------------

#import "map.asm"
