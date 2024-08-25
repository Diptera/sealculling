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
	jmp endjoystick



	actionleft:
	//.break
	lda ZP.playerx
	sec
	sbc #01
	cmp #90

	bne moveplayerleft
	clc
	adc #01 	// lock to 70
	sta ZP.playerx

	lda #01
	sta ZP.scrolldirection
	rts


	moveplayerleft:
	sta ZP.playerx

	rts




	actionright:
	lda ZP.playerx
	clc
	adc #01
	cmp #250

	bne moveplayerright
	sec
	sbc #01  // lock to position ff
	sta ZP.playerx

	lda #00
	sta ZP.scrolldirection
	rts

	moveplayerright:
	sta ZP.playerx
	rts




	endjoystick:

	// clearstick
	lda #%00011111
	sta ZP.joystick2

	rts
}