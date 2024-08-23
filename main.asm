.filenamespace sealcullingforbeginners

#import "labels.asm"




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

jsr IRQ.irqinit

// set 38 col mode
lda LABELS.viccontrol2
and #%11110111
sta LABELS.viccontrol2


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





jmp *

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

