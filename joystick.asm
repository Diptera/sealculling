JOYSTICK: {

	processjoystick:

	// read joystick, copy to ZP to keep, then determine actions
	lda LABELS.joystick2
	sta ZP.joystick2

	checkleft: 
	// left
	lda ZP.joystick2
	and #%00000100
	bne checkright
	jsr actionleft


	checkright:
	// right
	lda ZP.joystick2
	and #%00001000
	bne noaction
	jsr actionright




	noaction:

	rts


	actionleft:
	lda #01
	sta ZP.scrolldirection

	rts


	actionright:
	lda #00
	sta ZP.scrolldirection

	rts



}