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


// 9a to e7 is below the horizon, so move sprite offsreen
lda #$ff
ldx #$9a
hidesun:
sta suny,x
inx
cpx #$e7
bne hidesun


mainloop:
	lda ZP.gameloop
	beq mainloop

	dec ZP.gameloop  // clear loop for current frame

	// increase gen counter tick once per frame
	inc ZP.general_counter

//	lda ZP.suncycle
//	clc
//	adc #$01
//	cmp #$32
//	bne nosunupdate  // only going to update every x cycles
//	// got here, so need to update the sun
//	clc
//	lda ZP.sunpos + 0
//	clc
//	adc #$01
//	bne
//	// set msb
//	lda #$01


	// check if time to move the sun
	lda ZP.general_counter
	and #%00000111
	bne nomovesun

	// move the sun
	inc ZP.sunpos
	ldx ZP.sunpos
	lda sunx, x
	sta LABELS.sprXLO




	// set msb	

	//  msb needed sunpos 5b to a6
	lda ZP.sunpos
	cmp #$5b
	bne sunmsboff
	// set msb
	lda LABELS.sprXHIbitsR
	ora #%00000001
	jmp sunendmsb
	// clear msb
	sunmsboff:
	lda ZP.sunpos
	cmp #$a6
	bne sunendmsb2
	lda LABELS.sprXHIbitsR
	and #%11111110
	sunendmsb:
	sta LABELS.sprXHIbitsR
	sunendmsb2:

	// set y pos
	lda suny, x
	sta LABELS.sprY

	// change sky colour at certain points
	lda ZP.sunpos
	cmp #$E0
	bne skycolcheck2
	lda #DARK_GREY
	jmp setskycol
	skycolcheck2:
	cmp #$F0
	bne skycolcheck3
	lda #BLUE
	jmp setskycol
	skycolcheck3:
	cmp #$00
	bne skycolcheck4
	lda #PURPLE
	jmp setskycol
	skycolcheck4:
	cmp #$10
	bne skycolcheck5
	lda #LIGHT_BLUE
	jmp setskycol
	skycolcheck5:
	cmp #$80
	bne skycolcheck6
	lda #PURPLE
	jmp setskycol
	skycolcheck6:
	cmp #$90
	bne skycolcheck7
	lda #BLUE
	jmp setskycol
	skycolcheck7:
	cmp #$a0
	bne skycolcheck8
	lda #DARK_GREY
	jmp setskycol
	skycolcheck8:
	cmp #$b0
	bne nomovesun
	lda #BLACK
	setskycol:
	sta IRQ.skycol + 1
 //black  dg  db purp      lb    purp  db   dg  purple    black
	nomovesun:


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


sunsteps:
suny:
	.fill 256, -sin((i/256) * PI*2) * 41 + 91
*=* "sunx"	
sunx:
	.fill 256, -cos((i/256) * PI*2) * 140 + 140 + 31


*=* "Init"
#import "init.asm"
*=* "IRQs"
#import "IRQs.asm"
*=* "joystick.asm"
#import "joystick.asm"
*=* "scrolls"
#import "scroll.asm"


*=$4800 "charset"
.import binary "sealchar8.bin"

// sprite data - 21 bits high, 24 wide

*=$6000 "Sprite data" // put sprite data at 8192 (128th * 64)

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



//----------------------------------------------------------

#import "map.asm"
