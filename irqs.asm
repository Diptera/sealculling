IRQ: {


irqinit:
	sei             // Suspend interrupts during init

	lda #$7f        // Disable CIA
	sta $dc0d

	lda LABELS.interruptE  // Enable raster interrupts
	ora #$01
 	sta LABELS.interruptE

	lda LABELS.hiraster    // High bit of raster line cleared, we're
	and #$7f        // only working within single byte ranges
	sta LABELS.hiraster

	lda #100    	// Interrupt at the top line (100)
	sta LABELS.loraster

	lda #<vblank    // Push low and high byte of our routine into
	sta LABELS.loirq       // IRQ vector addresses
	lda #>vblank
	sta LABELS.hiirq

	cli             // Enable interrupts again
	rts


// store two sprite x positions here
sprx1:
	.byte 60
sprx2:
	.byte 60	
spry1:
	.byte 60
spry2:
	.byte 133


// scroll settings
// scroll register 7 to 0 moves chars left per pixel

*=* "Counters"
general_counter:
	.byte 00

.byte $CC

scrollpos_hilltop1:
	.byte 07
scrollercounter_hilltop1:
	.byte $02
scrollercounteroriginal_hilltop1:	
	.byte $02

.byte $CC

scrollpos_hilltop2:
	.byte 07
scrollercounter_hilltop2:
	.byte $01
scrollercounteroriginal_hilltop2:	
	.byte $01

.byte $CC

scrollpos_ice:
	.byte 07
scrollercounter_ice:
	.byte $00
scrollercounteroriginal_ice:	
	.byte $00

end_col_colour:  // temp holding space when scrolling colours
	.byte $00, $00, $00, $00, $00, $00, $00




// irq handlers


vblank:
	lda #<sky   // Push next interrupt routine address for when we're done
	sta LABELS.loirq
	lda #>sky
	sta LABELS.hiirq
	lda #50	   	// Next IRQ line
	sta LABELS.loraster

	// increase gen counter tick once per frame
	inc general_counter

	lda #GREEN        // Colour value for green
	jmp fullack

sky:
	lda #<hilltop1    // Push next interrupt routine address for when we're done
	sta LABELS.loirq
	lda #>hilltop1
	sta LABELS.hiirq
	lda #[50 + [6 * 8] ]    // Next IRQ 
	sta LABELS.loraster

	lda #$ff        // Acknowlege IRQ 
	sta LABELS.interruptR
	

	lda #LIGHT_BLUE       // Set up to change colour to white
	sta LABELS.border

	// check scroll counter for hill 1 - update and refresh if needed
	dec scrollercounter_hilltop1
	bpl !+							// counter not elapsed, do nothing

	lda scrollercounteroriginal_hilltop1	// reset the scroll counter
	sta scrollercounter_hilltop1

	dec scrollpos_hilltop1			// move hscroll
	bpl !+

	lda #$07						// reset hscroll to 7
	sta scrollpos_hilltop1
	!:



	lda #LIGHT_BLUE       // Set up to change colour to white
	jmp ack         // Go to common code for IRQ handlers


hilltop1:
	
	// update screen hscroll
	lda LABELS.viccontrol2
	and #%11111000
	ora scrollpos_hilltop1
	nop // allow raster to get to end of line before setting hscroll
	nop
	sta LABELS.viccontrol2


	// if hscroll = 7 then scroll colours

	lda scrollpos_hilltop1
	cmp #$07
	bne noscroll


	//.break
	// preserve end col colours
	lda [LABELS.screencolourram + [6 * 40] ]
	sta end_col_colour
	lda [LABELS.screencolourram + [6 * 40] + 1]
	sta [end_col_colour + 1]

	// scroll row of colour 
	ldx #$01
	!:
	lda [LABELS.screencolourram + [6 * 40] ], x
	dex
	sta [LABELS.screencolourram + [6 * 40] ], x
	inx
	inx
	cpx #$06
	bne !-

	// put saved end col into opposite end
	lda end_col_colour
	sta [LABELS.screencolourram + [6 * 40] + 4 ]

noscroll:






	lda #<hilltop2 	// Push next interrupt routine address for when we're done
	sta LABELS.loirq
	lda #>hilltop2
	sta LABELS.hiirq
	lda #[50 + [8 * 8] ]    	// Next IRQ line
	sta LABELS.loraster

	lda #$ff        // Acknowlege IRQ 
	sta LABELS.interruptR



  	lda #DARK_GREY        // Set up to change colour to dark grey
  	sta LABELS.border


	// check scroll counter for hill 2 - update and refresh if needed
	dec scrollercounter_hilltop2
	bpl !+							// counter not elapsed, do nothing

	lda scrollercounteroriginal_hilltop2	// reset the scroll counter
	sta scrollercounter_hilltop2

	dec scrollpos_hilltop2			// move hscroll
	bpl !+

	lda #$07						// reset hscroll to 7
	sta scrollpos_hilltop2
	!:


  	lda #DARK_GREY        // Set up to change colour to dark grey
	jmp ack         // Go to common code for IRQ handlers


hilltop2:

	// update screen hscroll
	lda LABELS.viccontrol2
	and #%11111000
	ora scrollpos_hilltop2
	nop	// allow raster to get to end of line before setting hscroll
	nop 
	sta LABELS.viccontrol2


	lda #<ice   // Push next interrupt routine address for when we're done
	sta LABELS.loirq
	lda #>ice
	sta LABELS.hiirq
	lda #[50 + [11 * 8] ]	   	// Next IRQ line
	sta LABELS.loraster

	lda #$ff        // Acknowlege IRQ 
	sta LABELS.interruptR


  	lda #LIGHT_GREY        // Set up to change colour to dark grey
  	sta LABELS.border


	// check scroll counter for ice - update and refresh if needed
	dec scrollercounter_ice
	bpl !+							// counter not elapsed, do nothing

	lda scrollercounteroriginal_ice	// reset the scroll counter
	sta scrollercounter_ice

	dec scrollpos_ice			// move hscroll
	bpl !+

	lda #$07						// reset hscroll to 7
	sta scrollpos_ice
	!:


	lda #LIGHT_GREY        // Colour value for green
	jmp ack


ice:
	// update hscroll pos
	lda LABELS.viccontrol2
	and #%11111000
	ora scrollpos_ice
	nop // allow raster to get to end of line before setting hscroll
	nop 
	sta LABELS.viccontrol2


	lda #<ocean   // Push next interrupt routine address for when we're done
	sta LABELS.loirq
	lda #>ocean
	sta LABELS.hiirq
	lda #[50 + [19 * 8] ]    	// Next IRQ is for the top again
	sta LABELS.loraster

	lda #$ff        // Acknowlege IRQ 
	sta LABELS.interruptR

 	lda #WHITE        // Colour value for blue
 	sta LABELS.border	



 	lda #WHITE        // Colour value for blue
 	jmp ack


ocean:
	// temp reset hscroll until this one gets its own
	lda LABELS.viccontrol2
	and #%11111000
	//ora scrollpos_hilltop1
	nop // allow raster to get to end of line before setting hscroll
	nop
	nop // extra nop because no ORA on this split
	sta LABELS.viccontrol2


	lda #<hud   // Push next interrupt routine address for when we're done
	sta LABELS.loirq
	lda #>hud
	sta LABELS.hiirq
	lda #[50 + [22 * 8]]	   	// Next IRQ line
	sta LABELS.loraster

	lda #BLUE      // Colour value for green
	sta LABELS.border

	jmp ack

hud:
	lda #<vblank   // Push next interrupt routine address for when we're done
	sta LABELS.loirq
	lda #>vblank
	sta LABELS.hiirq
	lda #250	   	// Next IRQ line
	sta LABELS.loraster

	lda #BLACK        // Colour value for green
	sta LABELS.border

	jmp ack



ack:              	// Expects A to hold desired border colour
	//sta LABELS.border      // Set border
	//sta LABELS.background

	lda #$ff        // Acknowlege IRQ 
	sta LABELS.interruptR

	// restore registers and rti for the mid-screen interrupts
	pla				// pull Y
	tay				// restore Y
	pla				// pull X
	tax				// restore X
	pla				// restore A
	rti

fullack:
	//sta LABELS.border      // Set border

	lda #$ff        // Acknowlege IRQ 
	sta LABELS.interruptR

	jmp $ea31       // Continue with normal IRQ routine


}
