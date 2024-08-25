SCROLL: {

	mainscroll:


	// check direction
	ldx ZP.scrolldirection
	beq scrollleft
	dex
	beq scrollright

	rts

	// LEFT
	scrollleft: 

	// check scroll counter for hill 1 - update and refresh if needed
	dec ZP.scrollercounter_hilltop1
	bpl noscrollhill1left				// counter not elapsed, do nothing

	lda ZP.scrollercounteroriginal_hilltop1	// reset the scroll counter
	sta ZP.scrollercounter_hilltop1

	dec ZP.scrollpos_hilltop1		// move hscroll
	bpl noscrollhill1left

	lda #$07						// reset hscroll to 7
	sta ZP.scrollpos_hilltop1

	// scroll the colour data
	jsr scrollhill1colourleft
	jsr scrollhill1charsleft

	noscrollhill1left:

	// check scroll counter for hill 2 - update and refresh if needed
	dec ZP.scrollercounter_hilltop2
	bpl noscrollhill2left		// counter not elapsed, do nothing

	lda ZP.scrollercounteroriginal_hilltop2	// reset the scroll counter
	sta ZP.scrollercounter_hilltop2

	dec ZP.scrollpos_hilltop2			// move hscroll
	bpl noscrollhill2left

	lda #$07						// reset hscroll to 7
	sta ZP.scrollpos_hilltop2

	// scroll the colour data
	jsr scrollhill2colourleft

	noscrollhill2left:

	// check scroll counter for ice - update and refresh if needed
	dec ZP.scrollercounter_ice
	//bmi doscrolliceleft				// counter elapsed, scroll ice
	bpl noscrolliceleft

	doscrolliceleft:
	lda ZP.scrollercounteroriginal_ice	// reset the scroll counter
	sta ZP.scrollercounter_ice

	dec ZP.scrollpos_ice			// move hscroll
	//bmi doscrollice2left
	bpl noscrolliceleft

	doscrollice2left:
	lda #$07						// reset hscroll to 7
	sta ZP.scrollpos_ice
	
	// scroll the colour data
	jsr scrollicecolourleft

	noscrolliceleft:

	// clear scroll flag
	lda #$ff
	sta ZP.scrolldirection

	rts


	// RIGHT
	scrollright:
	// check scroll counter for hill 1 - update and refresh if needed
	
	dec ZP.scrollercounter_hilltop1
	bpl noscrollhill1right				// counter not elapsed, do nothing

	lda ZP.scrollercounteroriginal_hilltop1	// reset the scroll counter
	sta ZP.scrollercounter_hilltop1
	//.break
	lda ZP.scrollpos_hilltop1		// move hscroll
	clc
	adc #$01
	sta ZP.scrollpos_hilltop1
	cmp #$08

	bne noscrollhill1right

	lda #$00						// reset hscroll to 0
	sta ZP.scrollpos_hilltop1

	// scroll the colour data
	jsr scrollhill1colourright
	jsr scrollhill1charsright

	noscrollhill1right:

	// check scroll counter for hill 2 - update and refresh if needed
	dec ZP.scrollercounter_hilltop2
	bpl noscrollhill2right		// counter not elapsed, do nothing

	lda ZP.scrollercounteroriginal_hilltop2	// reset the scroll counter
	sta ZP.scrollercounter_hilltop2

	lda ZP.scrollpos_hilltop2			// move hscroll
	clc
	adc #$01
	sta ZP.scrollpos_hilltop2
	cmp #$08
	bne noscrollhill2right

	lda #$00						// reset hscroll to 0
	sta ZP.scrollpos_hilltop2

	// scroll the colour data
	jsr scrollhill2colourright

	noscrollhill2right:

	// check scroll counter for ice - update and refresh if needed
	dec ZP.scrollercounter_ice
	//bmi doscrolliceright				// counter elapsed, scroll ice
	bpl noscrolliceright

	//doscrolliceright:
	lda ZP.scrollercounteroriginal_ice	// reset the scroll counter
	sta ZP.scrollercounter_ice

	lda ZP.scrollpos_ice			// move hscroll
	clc
	adc #$01
	sta ZP.scrollpos_ice
	cmp #$08
	//bmi doscrollice2right
	bne noscrolliceright

	//doscrollice2right:
	lda #$00						// reset hscroll to 0
	sta ZP.scrollpos_ice
	
	// scroll the colour data
	jsr scrollicecolourright

	noscrolliceright:



	// clear scroll flag
	lda #$ff
	sta ZP.scrolldirection

	rts



// subroutines to scroll colour (unrolled code for speed)


// scroll LEFT
	scrollhill1colourleft:

	.for(var j=6; j<8; j++) {
		ldy LABELS.screencolourram + j*40
		.for(var i=1; i<40; i++) {
			lda LABELS.screencolourram + j*40 + i
			sta LABELS.screencolourram + j*40 + i - 1
		}
		sty LABELS.screencolourram + j * 40 + 39
	}

	rts

	scrollhill1charsleft:

	.for(var j=6; j<8; j++) {
		ldy LABELS.screenram + j*40
		.for(var i=1; i<40; i++) {
			lda LABELS.screenram + j*40 + i
			sta LABELS.screenram + j*40 + i - 1
		}
		sty LABELS.screenram + j * 40 + 39
	}

	rts


	scrollhill2colourleft:

	.for(var j=8; j<11; j++) {
		ldy LABELS.screencolourram + j*40
		.for(var i=1; i<40; i++) {
			lda LABELS.screencolourram + j*40 + i
			sta LABELS.screencolourram + j*40 + i - 1
		}
		sty LABELS.screencolourram + j * 40 + 39
	}

	rts


	scrollicecolourleft:

	.for(var j=11; j<19; j++) {
		ldy LABELS.screencolourram + j*40
		.for(var i=1; i<40; i++) {
			lda LABELS.screencolourram + j*40 + i
			sta LABELS.screencolourram + j*40 + i - 1
		}
		sty LABELS.screencolourram + j * 40 + 39
	}

	rts



// scroll RIGHT
	scrollhill1colourright:

	.for(var j=6; j<8; j++) {
		ldy LABELS.screencolourram + j*40 + 39
		.for(var i=38; i>-1; i--) {
			lda LABELS.screencolourram + j*40 + i
			sta LABELS.screencolourram + j*40 + i + 1
		}
		sty LABELS.screencolourram + j * 40 + 0
	}

	rts

	scrollhill1charsright:

	.for(var j=6; j<8; j++) {
		ldy LABELS.screenram + j*40 + 39
		.for(var i=38; i>-1; i--) {
			lda LABELS.screenram + j*40 + i
			sta LABELS.screenram + j*40 + i + 1
		}
		sty LABELS.screenram + j * 40 + 0
	}

	rts


	scrollhill2colourright:

	.for(var j=8; j<11; j++) {
		ldy LABELS.screencolourram + j*40 + 39
		.for(var i=38; i>-1; i--) {
			lda LABELS.screencolourram + j*40 + i
			sta LABELS.screencolourram + j*40 + i + 1
		}
		sty LABELS.screencolourram + j * 40 + 0
	}



	rts


	scrollicecolourright:

	.for(var j=11; j<19; j++) {
		ldy LABELS.screencolourram + j*40 + 39
		.for(var i=38; i>-1; i--) {
			lda LABELS.screencolourram + j*40 + i
			sta LABELS.screencolourram + j*40 + i + 1
		}
		sty LABELS.screencolourram + j * 40 + 0
	}


	rts


}

