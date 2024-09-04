
// cycle the time of day
// move sun, set split colours

TOD: {

	tod:

	// check if time to move the sun
	lda ZP.general_counter
	and #%00000111
	beq domovesun
	jmp nomovesun
	domovesun:
	// move the sun
	inc ZP.sunpos
	ldx ZP.sunpos
	// set y pos
	lda suny, x
	sta LABELS.sprY + 14
	// set x low byte
	lda sunx, x
	sta LABELS.sprXLO + 14
	// set msb - msb needed sunpos 5b to a6
	lda ZP.sunpos
	cmp #$5b
	bne sunmsboff
	// set msb
	lda LABELS.sprXHIbitsR
	ora #%10000000
	jmp sunendmsb
	// clear msb
	sunmsboff:
	lda ZP.sunpos
	cmp #$a6
	bne sunendmsb2
	lda LABELS.sprXHIbitsR
	and #%01111111
	sunendmsb:
	sta LABELS.sprXHIbitsR
	sunendmsb2:


	// change sky/sun colour at certain points
	ldx #YELLOW // default sun colour, override as needed.
	ldy #WHITE // default ice colour, override as needed

	lda ZP.sunpos
	cmp #$e0
	bne skycolcheck2
	lda #DARK_GREY
	ldx #RED
	ldy #GREY
	jmp setskycol
	skycolcheck2:
	cmp #$f0
	bne skycolcheck3
	lda #BLUE
	ldx #RED
	ldy #LIGHT_GREY
	jmp setskycol
	skycolcheck3:
	cmp #$00
	bne skycolcheck4
	lda #PURPLE
	ldx #ORANGE
	jmp setskycol
	skycolcheck4:
	cmp #$10
	bne skycolcheck5
	lda #LIGHT_BLUE
	jmp setskycol
	skycolcheck5:
	cmp #$70
	bne skycolcheck6
	lda #PURPLE
	ldx #ORANGE
	jmp setskycol
	skycolcheck6:
	cmp #$80
	bne skycolcheck7
	lda #BLUE
	ldx #RED
	ldy #LIGHT_GREY
	jmp setskycol
	skycolcheck7:
	cmp #$90
	bne skycolcheck8
	lda #DARK_GREY
	ldx #RED
	ldy #GREY
	jmp setskycol
	skycolcheck8:
	cmp #$a0
	bne nomovesun
	lda #BLACK
	ldy #DARK_GREY
	setskycol:
	sta IRQ.skycol + 1
	//sta LABELS.sprcolour + 0  // edge fade sprite
	stx LABELS.sprcolour + 7
	sty IRQ.icecol + 1
 //black  dg  db purp      lb    purp  db   dg  purple    black
	nomovesun:



	// tick player temp down
	dec ZP.playertemperaturetick
	bpl notemptick  
	lda #50
	sta ZP.playertemperaturetick
	dec ZP.playertemperature

	// been a tick, so redraw
	// draw player temperature (val $74-$0) starting at r23c8
	//.break
	ldx #$00 // start of draw location
	lda ZP.playertemperature
	nexttempchar:
	cmp #$08 // can we subtract 8 from it?
	bcs drawfull
	// no, grab final char from table
	tay
	lda playertemperaturechars,y
	sta LABELS.screenram + [23 * 40] + 08, x
	// bung a blank space after to remove any residual
	lda #32
	inx
	sta LABELS.screenram + [23 * 40] + 08, x
	jmp plottempend  // saves iterating through remaining char spaces
	drawfull:
	// more than 8, so plot a full char and subtract 8
	sec
	sbc #$08
	tay			// temp store A as need to use it to plot a char
	lda #160  // full 8 pixel char
	plottempchar:
	sta LABELS.screenram + [23 * 40] + 08, x
	tya			// restore the saved A
	inx			// move to next charspace
	cpx #12
	bne nexttempchar
	plottempend:
	notemptick:

/*
	6f and 6e draw same

	start  	cmp	NVZC   	expected			actual
	(112) 	70   9 			14 * 8
	(111)   6f  9           13 * 8, 7
	(110)   6e   9          13 * 8, 6
	(109)    6d    9        12 * 8, 5
	(108)    6c   9         12 * 8, 4
	    0a	 9	0001 	8 2
		09	 9  0011    8 1
		08  9   1000    8  
		07  9   1000    7
		06  9            
		05  9
		04  9
		03  9
		02  9
		01  9
		00 	9  1000     nothing		

*/




rts


sunsteps:
suny:
	.fill 256, -sin((i/256) * PI*2) * [41+16] + 91 + 16
*=* "sunx"	
sunx:
	.fill 256, -cos((i/256) * PI*2) * 140 + 140 + 31


playertemperaturechars: // 0 - 8 lines
.byte 32 
.byte 101, 116, 117, 97, 246, 231, 234
.byte 160  // full
.byte 32


}