INIT: {

	// various init processes

init:


sei
// copy rom charset  to 4800
// make char rom visible
lda $01
and #%11111000
ora #%00000011
sta $01





//.break


// bank out BASIC and kernel
//.break
lda $01
and #%11111000
ora #%00000101
sta $01

// set VIC Bank 01  (4000-7FFF)
lda $DD00
and #%11111100
ora #%00000010
sta $dd00

// set screen address
lda LABELS.vicmemory
and	#%00001111
ora #%00000000	// screen ram in first bank  $4000-$43ff
sta LABELS.vicmemory

// set character memory
lda LABELS.vicmemory
and	#%11110001
ora #%00000010	// char ram in first bank  $4800-$4fff
sta LABELS.vicmemory




//.break


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

lda #$88
sta ZP.mapicepos

jsr IRQ.irqinit

cli


//.break

// set 38 col mode
lda LABELS.viccontrol2
and #%11110111
sta LABELS.viccontrol2

//.break

// fill screen with chars
//ldx #250
//lda #$66   // 66 7f
//!:
//	sta LABELS.screenram,x
//	sta [LABELS.screenram + 250], x
//	sta [LABELS.screenram + 500], x
//	sta [LABELS.screenram + 750], x
//	dex
//bne !-

//.break

// fill colour ram
//ldx #250
//lda #$00
//!:
//	sta LABELS.screencolourram,x
//	sta [LABELS.screencolourram + 250], x
//	sta [LABELS.screencolourram + 500], x
//	sta [LABELS.screencolourram + 750], x
//	adc #$01
//	dex
//bne !-

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



//  /\
// /  \
///    \


// set hilltop2 (row 8-10) chars 
lda #$e9 //'/'
ldx #$20 //' '
ldy #$df //'\'

.for(var i=0; i<37; i+=6) {
	stx LABELS.screenram + 8*40 + i
	stx LABELS.screenram + 8*40 + i + 1
	sta LABELS.screenram + 8*40 + i + 2
	sty LABELS.screenram + 8*40 + i + 3
	stx LABELS.screenram + 8*40 + i + 4
	stx LABELS.screenram + 8*40 + i + 5
	}

ldx #$a0 // reverse space

.for(var i=0; i<37; i+=6) {
	stx LABELS.screenram + 9*40 + i
	sta LABELS.screenram + 9*40 + i + 1
	stx LABELS.screenram + 9*40 + i + 2
	stx LABELS.screenram + 9*40 + i + 3
	sty LABELS.screenram + 9*40 + i + 4
	stx LABELS.screenram + 9*40 + i + 5

	}

.for(var i=0; i<40; i+=6) {
	sta LABELS.screenram + 10*40 + i
	stx LABELS.screenram + 10*40 + i + 1
	stx LABELS.screenram + 10*40 + i + 2
	stx LABELS.screenram + 10*40 + i + 3
	stx LABELS.screenram + 10*40 + i + 4
	sty LABELS.screenram + 10*40 + i + 5
	}



// /\
///  \

// set hilltop2 colours
lda #DARK_GREY
.for(var j=8; j<11; j++){
	.for(var i=0; i<40; i++) {
		sta LABELS.screencolourram + j*40 + i
	}
}







jsr SCROLL.scrollicecharsleft

// set ice colours
lda #BLACK
.for(var j=11; j<19; j++){
	.for(var i=0; i<40; i++) {
		sta LABELS.screencolourram + j*40 + i
	}
}


// clear the sky
lda #$20 // space
.for(var j=0; j<6; j++){
	.for(var i=0; i<40; i++) {
		sta LABELS.screenram + j*40 + i
	}
}


//.break



lda #00
sta ZP.suncycle





// Enable sprite and set pointer
// sun
lda LABELS.sprEnableR
ora #%00000001
sta LABELS.sprEnableR
lda #$80
sta LABELS.sprPointerR

lda LABELS.sprPriorityR
ora #%00000001
sta LABELS.sprPriorityR

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
//.break
rts

//sunsteps:
//suny:
//	.fill 256, -sin((i/256) * PI*2) * 41 + 91
//sunx:
//	.fill 256, -cos((i/256) * PI*2) * 140 + 140 + 31
//sunmsb:
//	.fill 91, 0
//	.fill 75, 1
//	.fill 90, 0





}


