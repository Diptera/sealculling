IRQ: {


irqinit:
	sei             // Suspend interrupts during init

	lda #$7f        // Disable CIA
	sta $dc0d

	lda $dc0d		// ack CIA 1
	lda $dd0d		// ack CIA 2


	lda LABELS.interruptE  // Enable raster interrupts
	ora #$01
 	sta LABELS.interruptE

	lda LABELS.hiraster    // High bit of raster line cleared, we're
	and #$7f        	   // only working within single byte ranges
	sta LABELS.hiraster

	lda #100    	// Interrupt at the top line (100)
	sta LABELS.loraster

	lda #<vblank    // Push low and high byte of our routine into
	sta LABELS.loirq       // IRQ vector addresses
	lda #>vblank
	sta LABELS.hiirq

	cli             // Enable interrupts again
	rts



// irq handlers

vblank:
	//.break
	storestate()

	lda #RED
	sta LABELS.border
  	sta LABELS.background

	lda #$ff        // Acknowlege IRQ 
	sta LABELS.interruptR

	lda #<sky   // Push next interrupt routine address for when we're done
	sta LABELS.loirq
	lda #>sky
	sta LABELS.hiirq
	lda #50	   	// Next IRQ line
	sta LABELS.loraster


	lda #$01
	sta ZP.gameloop

	restorestate()
	rti


sky:
	storestate()

	skycol:
	lda #LIGHT_BLUE       
	sta LABELS.border
	sta LABELS.background
	sta LABELS.sprcolour + 0  // left edge fade sprite
	sta LABELS.sprcolour + 4 // right edge fade

  	// relocate edge fade sprite
  	lda #93
  	sta LABELS.sprY	+ 0
  	sta LABELS.sprY + 8



	lda #<hilltop1    // Push next interrupt routine address for when we're done
	sta LABELS.loirq
	lda #>hilltop1
	sta LABELS.hiirq
	lda #[50 + [6 * 8] ]    // Next IRQ 
	sta LABELS.loraster

	lda #$ff        // Acknowlege IRQ 
	sta LABELS.interruptR

	restorestate()
	rti


hilltop1:
	storestate()

	// keep colours from first split
  	//lda #DARK_GREY
  	//sta LABELS.border
  	//sta LABELS.background


	// update screen hscroll
	lda LABELS.viccontrol2
	and #%11111000
	ora ZP.scrollpos_hilltop1
	nop // allow raster to get to end of line before setting hscroll
	nop
	nop
	sta LABELS.viccontrol2

	lda #$ff        // Acknowlege IRQ 
	sta LABELS.interruptR

	lda #<hilltop2 	// Push next interrupt routine address for when we're done
	sta LABELS.loirq
	lda #>hilltop2
	sta LABELS.hiirq
	lda #[50 + [8 * 8] ]    	// Next IRQ line
	sta LABELS.loraster
 	
	restorestate()
	rti


hilltop2:
	storestate()

  	lda #LIGHT_GREY
  	sta LABELS.border
  	sta LABELS.background
  	sta LABELS.sprcolour + 0  // left edge fade sprite
  	sta LABELS.sprcolour + 4  // right edge fade

	// update screen hscroll
	lda LABELS.viccontrol2
	and #%11111000
	ora ZP.scrollpos_hilltop2
	nop	// allow raster to get to end of line before setting hscroll
	nop 
	nop 
	sta LABELS.viccontrol2

	// hide the sun as below the horizon
  	// save current settings to restore at ocean split
  	lda LABELS.sprXLO + 14
  	sta ZP.sunx
  	lda LABELS.sprXHIbitsR
  	and #%10000000
  	sta ZP.sunx + 1
  	// move sun offscreen
  	lda #$00
  	sta LABELS.sprXLO + 14
  	lda LABELS.sprXHIbitsR
  	and #%01111111
  	sta LABELS.sprXHIbitsR 

  	// relocate edge fade sprite
  	lda #93 + 21 + 2
  	sta LABELS.sprY	+ 0
  	sta LABELS.sprY + 8


	lda #<ice   // Push next interrupt routine address for when we're done
	sta LABELS.loirq
	lda #>ice
	sta LABELS.hiirq
	lda #[50 + [11 * 8] ]	   	// Next IRQ line
	sta LABELS.loraster

	lda #$ff        // Acknowlege IRQ 
	sta LABELS.interruptR

	restorestate()
	rti


ice:
	storestate()

	icecol:
 	lda #WHITE
 	sta LABELS.border	
  	sta LABELS.background
  	sta LABELS.sprcolour + 0  // left edge fade sprite
  	sta LABELS.sprcolour + 4  // right edge fade

	// update hscroll pos
	lda LABELS.viccontrol2
	and #%11111000
	ora ZP.scrollpos_ice
	nop // allow raster to get to end of line before setting hscroll
	nop 
	nop 
	nop 
	sta LABELS.viccontrol2


  	// relocate edge fade sprite
  	lda #93 + 21 + 66
  	sta LABELS.sprY	+ 0
  	sta LABELS.sprY + 8


	lda #<ocean   // Push next interrupt routine address for when we're done
	sta LABELS.loirq
	lda #>ocean
	sta LABELS.hiirq
	lda #[50 + [19 * 8] ]    	// Next IRQ is for the top again
	sta LABELS.loraster

	lda #$ff        // Acknowlege IRQ 
	sta LABELS.interruptR

	restorestate()
	rti


ocean:
	storestate()

	lda #BLUE   
	sta LABELS.border
  	sta LABELS.background
  	sta LABELS.sprcolour + 0  // left edge fade sprite
  	sta LABELS.sprcolour + 4  // right edge fade

	// temp reset hscroll until this one gets its own
	lda LABELS.viccontrol2
	and #%11111000
	//ora scrollpos_hilltop1
	nop // allow raster to get to end of line before setting hscroll
	nop
	nop 
	nop 
	nop 
	sta LABELS.viccontrol2


  	// relocate edge fade sprite
  	lda #93 + 21 + 87
  	sta LABELS.sprY	+ 0
  	sta LABELS.sprY + 8

  	// put the sun back where it belongs
  	lda ZP.sunx
  	sta LABELS.sprXLO + 14
  	lda LABELS.sprXHIbitsR
  	ora ZP.sunx+1
  	sta LABELS.sprXHIbitsR



	lda #<hud   // Push next interrupt routine address for when we're done
	sta LABELS.loirq
	lda #>hud
	sta LABELS.hiirq
	lda #[50 + [22 * 8]]	   	// Next IRQ line
	sta LABELS.loraster

	lda #$ff        // Acknowlege IRQ 
	sta LABELS.interruptR

	restorestate()
	rti


hud:
	storestate()

	lda #BLACK
	sta LABELS.border
  	sta LABELS.background

	lda #<vblank   // Push next interrupt routine address for when we're done
	sta LABELS.loirq
	lda #>vblank
	sta LABELS.hiirq
	lda #250	   	// Next IRQ line
	sta LABELS.loraster

	lda #$ff        // Acknowlege IRQ 
	sta LABELS.interruptR

	restorestate()
	rti


}
