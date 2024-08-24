SCROLL: {

	mainscroll:


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
	jsr scrollhill1colour
	jsr scrollhill1chars

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
	jsr scrollhill2colour

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
	jsr scrollicecolour

	noscrollice:

	rts


// subroutines to scroll colour (unrolled code for speed)

	scrollhill1colour:

	.for(var j=6; j<8; j++) {
		ldy LABELS.screencolourram + j*40
		.for(var i=1; i<40; i++) {
			lda LABELS.screencolourram + j*40 + i
			sta LABELS.screencolourram + j*40 + i - 1
		}
		sty LABELS.screencolourram + j * 40 + 39
	}

	rts

	scrollhill1chars:

	.for(var j=6; j<8; j++) {
		ldy LABELS.screenram + j*40
		.for(var i=1; i<40; i++) {
			lda LABELS.screenram + j*40 + i
			sta LABELS.screenram + j*40 + i - 1
		}
		sty LABELS.screenram + j * 40 + 39
	}

	rts




	scrollhill2colour:

	.for(var j=8; j<11; j++) {
		ldy LABELS.screencolourram + j*40
		.for(var i=1; i<40; i++) {
			lda LABELS.screencolourram + j*40 + i
			sta LABELS.screencolourram + j*40 + i - 1
		}
		sty LABELS.screencolourram + j * 40 + 39
	}

	rts


	scrollicecolour:

	.for(var j=11; j<19; j++) {
		ldy LABELS.screencolourram + j*40
		.for(var i=1; i<40; i++) {
			lda LABELS.screencolourram + j*40 + i
			sta LABELS.screencolourram + j*40 + i - 1
		}
		sty LABELS.screencolourram + j * 40 + 39
	}

	rts

}