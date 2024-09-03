
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


rts


sunsteps:
suny:
	.fill 256, -sin((i/256) * PI*2) * [41+16] + 91 + 16
*=* "sunx"	
sunx:
	.fill 256, -cos((i/256) * PI*2) * 140 + 140 + 31


}