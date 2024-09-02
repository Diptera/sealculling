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
	nop
	nop
	nop
	nop
	nop
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

	// update screen hscroll
	lda LABELS.viccontrol2
	and #%11111000
	ora ZP.scrollpos_hilltop2
	nop	// allow raster to get to end of line before setting hscroll
	nop 
	nop 
	nop 
	nop 
	nop 
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

	restorestate()
	rti


ice:
	storestate()

 	lda #WHITE
 	sta LABELS.border	
  	sta LABELS.background

	// update hscroll pos
	lda LABELS.viccontrol2
	and #%11111000
	ora ZP.scrollpos_ice
	nop // allow raster to get to end of line before setting hscroll
	nop 
	nop 
	nop 
	nop 
	nop 
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

	restorestate()
	rti


ocean:
	storestate()

	lda #BLUE   
	sta LABELS.border
  	sta LABELS.background

	// temp reset hscroll until this one gets its own
	lda LABELS.viccontrol2
	and #%11111000
	//ora scrollpos_hilltop1
	nop // allow raster to get to end of line before setting hscroll
	nop
	nop 
	nop
	nop
	nop 
	nop 
	nop 
	nop 
	sta LABELS.viccontrol2


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
