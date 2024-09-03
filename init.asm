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


// default scroll values
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


// set hilltop1 (row 6-7) chars 
// /\
///  \
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


// set hilltop1 colours
lda #DARK_GREY
.for(var j=6; j<8; j++){
	.for(var i=0; i<40; i++) {
		sta LABELS.screencolourram + j*40 + i
	}
}





// set hilltop2 (row 8-10) chars 
//  /\
// /  \
///    \
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
	ldx #$20 //' '
	stx LABELS.screenram + 9*40 + i
	sta LABELS.screenram + 9*40 + i + 1
	ldx #$a0 // reverse space
	stx LABELS.screenram + 9*40 + i + 2
	stx LABELS.screenram + 9*40 + i + 3
	sty LABELS.screenram + 9*40 + i + 4
	ldx #$20 //' '
	stx LABELS.screenram + 9*40 + i + 5

	}

ldx #$a0 // reverse space

.for(var i=0; i<40; i+=6) {
	sta LABELS.screenram + 10*40 + i
	stx LABELS.screenram + 10*40 + i + 1
	stx LABELS.screenram + 10*40 + i + 2
	stx LABELS.screenram + 10*40 + i + 3
	stx LABELS.screenram + 10*40 + i + 4
	sty LABELS.screenram + 10*40 + i + 5
	}

// set hilltop2 colours
lda #GREY
.for(var j=8; j<11; j++){
	.for(var i=0; i<40; i++) {
		sta LABELS.screencolourram + j*40 + i
	}
}






jsr SCROLL.redrawicechars

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


// clear the ocean
lda #$20 // space
.for(var j=19; j<22; j++){
	.for(var i=0; i<40; i++) {
		sta LABELS.screenram + j*40 + i
	}
}



// clear the hud
lda #$20 // space
.for(var j=22; j<25; j++){
	.for(var i=0; i<40; i++) {
		sta LABELS.screenram + j*40 + i
	}
}

// set hud text
ldx #$27
huddraw:
lda hudtext,x
sta LABELS.screenram + 23 * 40, x
dex
bne huddraw

// colour the temperature gauge
// RRRYYYYGGGGG
lda #RED
sta LABELS.screencolourram + [23 * 40] + 8
sta LABELS.screencolourram + [23 * 40] + 9
sta LABELS.screencolourram + [23 * 40] + 10
lda #YELLOW
sta LABELS.screencolourram + [23 * 40] + 11
sta LABELS.screencolourram + [23 * 40] + 12
sta LABELS.screencolourram + [23 * 40] + 13
sta LABELS.screencolourram + [23 * 40] + 14
lda #GREEN
sta LABELS.screencolourram + [23 * 40] + 15
sta LABELS.screencolourram + [23 * 40] + 16
sta LABELS.screencolourram + [23 * 40] + 17
sta LABELS.screencolourram + [23 * 40] + 18
sta LABELS.screencolourram + [23 * 40] + 19


//.break





lda #00
sta ZP.suncycle

lda #$74
sta ZP.playertemperature
lda #50
sta ZP.playertemperaturetick



// Enable sprite and set pointer

// left border fade
lda LABELS.sprEnableR
ora #%00000001
sta LABELS.sprEnableR
lda #$83
sta LABELS.sprPointerR 

// right border fade
lda LABELS.sprEnableR
ora #%00010000
sta LABELS.sprEnableR
lda #$84
sta LABELS.sprPointerR + 4



// sun
lda LABELS.sprEnableR
ora #%10000000
sta LABELS.sprEnableR
lda #$80
sta LABELS.sprPointerR + 7

lda LABELS.sprPriorityR
ora #%10000000
sta LABELS.sprPriorityR

// player
lda LABELS.sprEnableR
ora #%00000010
sta LABELS.sprEnableR
lda #$81
sta LABELS.sprPointerR + 1


// cloud1
lda LABELS.sprEnableR
ora #%00000100
sta LABELS.sprEnableR
lda #$82
sta LABELS.sprPointerR + 2

// cloud2
lda LABELS.sprEnableR
ora #%00001000
sta LABELS.sprEnableR
lda #$82
sta LABELS.sprPointerR + 3



// initial position sprites

// left border fade
lda #31
sta LABELS.sprXLO + 0
lda #93
sta LABELS.sprY + 0
lda #WHITE
sta LABELS.sprcolour + 0


// right border fade
lda #55
sta LABELS.sprXLO + 8
lda LABELS.sprXHIbitsR
ora #%00010000
sta LABELS.sprXHIbitsR
lda #93
sta LABELS.sprY + 8
lda #WHITE
sta LABELS.sprcolour + 4


//sun
lda #70
sta LABELS.sprXLO + 14
lda #70
sta LABELS.sprY + 14
lda #YELLOW
sta LABELS.sprcolour + 7

//player
lda #100
sta ZP.playerx
lda #150
sta ZP.playery
lda #BLACK
sta LABELS.sprcolour + 1
//.break

//cloud1
lda #180
sta LABELS.sprXLO + 4
lda #60
sta LABELS.sprY + 4
lda #WHITE
sta LABELS.sprcolour + 2

//cloud2
lda #83
sta LABELS.sprXLO + 6
lda #67
sta LABELS.sprY + 6
lda #WHITE
sta LABELS.sprcolour + 3






rts


hudtext:
	 .text "  temp:               cash:             "

// hud temp chars - blank to full
// 32, 101, 116, 117, 97, 246, 231, 234, 160
// 13 char spaces * 8 pixels = $74

// RRRYYYYGGGGG


}


