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

// set hilltop1 (row 6-7) chars 
lda #$e9 //'/'
ldx #$20 //' '
ldy #$df //'\'

.for(var i=0; i<40; i+=4) {
	stx LABELS.screenram + 6*40 + i
	sta LABELS.screenram + 6*40 + i + 1
	sty LABELS.screenram + 6*40 + i + 2
	stx LABELS.screenram + 6*40 + i + 3
	}

ldx #$a0 // reverse space

.for(var i=0; i<40; i+=4) {
	sta LABELS.screenram + 7*40 + i
	stx LABELS.screenram + 7*40 + i + 1
	stx LABELS.screenram + 7*40 + i + 2
	sty LABELS.screenram + 7*40 + i + 3
	}

// /\
///  \

// set hilltop1 colours
lda #LIGHT_GREY
.for(var j=6; j<8; j++){
	.for(var i=0; i<40; i++) {
		sta LABELS.screencolourram + j*40 + i
	}
}

// Enable sprite and set pointer
// sun
lda LABELS.sprEnableR
ora #%00000001
sta LABELS.sprEnableR
lda #$80
sta LABELS.sprPointerR

// player
lda LABELS.sprEnableR
ora #%00000010
sta LABELS.sprEnableR
lda #$81
sta LABELS.sprPointerR + 1



// initial position sprites
//sun
lda #70
sta LABELS.sprXLO
lda #70
sta LABELS.sprY
lda #YELLOW
sta LABELS.sprcolour

//player
lda #100
sta ZP.playerx
lda #150
sta ZP.playery
lda #BLACK
sta LABELS.sprcolour + 1



mainloop:
	lda ZP.gameloop
	beq mainloop

	dec ZP.gameloop  // clear loop for current frame

	// increase gen counter tick once per frame
	inc ZP.general_counter

	// draw player
	lda ZP.playerx
	sta [LABELS.sprXLO + 2]
	lda ZP.playery
	sta [LABELS.sprY + 2]

	jsr JOYSTICK.processjoystick


	jsr SCROLL.mainscroll



	lda #GREEN
	sta LABELS.border

	jmp mainloop

rts



*=* "IRQs"
#import "IRQs.asm"
*=* "joystick.asm"
#import "joystick.asm"
*=$3000 "scrolls"
#import "scroll.asm"

// sprite data - 21 bits high, 24 wide

*=$2000 "Sprite data" // put sprite data at 8192 (128th * 64)

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
.byte %11111111, %11111111, %11111111
.byte %11111111, %11111111, %11111111
.byte %11111111, %11111111, %11111111
.byte %11111111, %11111111, %11111111
.byte %11111111, %11111111, %11111111
.byte %11111111, %11111111, %11111111
.byte %11111111, %11111111, %11111111
.byte %11111111, %11111111, %11111111
.byte %11111111, %11111111, %11111111
.byte %11111111, %11111111, %11111111
.byte %11111111, %11111111, %11111111
.byte %11111111, %11111111, %11111111
.byte %11111111, %11111111, %11111111
.byte %11111111, %11111111, %11111111
.byte %11111111, %11111111, %11111111
.byte %11111111, %11111111, %11111111
.byte %11111111, %11111111, %11111111
.byte %11111111, %11111111, %11111111
.byte %11111111, %11111111, %11111111
.byte %11111111, %11111111, %11111111
.byte %11111111, %11111111, %11111111
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

