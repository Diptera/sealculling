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
	pha        //store register A in stack
	txa
	pha        //store register X in stack
	tya
	pha        //store register Y in stack

	lda #RED
	sta LABELS.border

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

	jmp ack


sky:
	pha        //store register A in stack
	txa
	pha        //store register X in stack
	tya
	pha        //store register Y in stack

	lda #LIGHT_BLUE       
	sta LABELS.border

	lda #<hilltop1    // Push next interrupt routine address for when we're done
	sta LABELS.loirq
	lda #>hilltop1
	sta LABELS.hiirq
	lda #[50 + [6 * 8] ]    // Next IRQ 
	sta LABELS.loraster

	lda #$ff        // Acknowlege IRQ 
	sta LABELS.interruptR


	jmp ack         // Go to common code for IRQ handlers


hilltop1:
	pha        //store register A in stack
	txa
	pha        //store register X in stack
	tya
	pha        //store register Y in stack	

  	lda #DARK_GREY
  	sta LABELS.border

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
 	
	jmp ack         // Go to common code for IRQ handlers


hilltop2:
	pha        //store register A in stack
	txa
	pha        //store register X in stack
	tya
	pha        //store register Y in stack

  	lda #LIGHT_GREY
  	sta LABELS.border

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

	jmp ack


ice:
	pha        //store register A in stack
	txa
	pha        //store register X in stack
	tya
	pha        //store register Y in stack

 	lda #WHITE
 	sta LABELS.border	

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

 	jmp ack


ocean:
	pha        //store register A in stack
	txa
	pha        //store register X in stack
	tya
	pha        //store register Y in stack

	lda #BLUE   
	sta LABELS.border

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


	jmp ack

hud:
	pha        //store register A in stack
	txa
	pha        //store register X in stack
	tya
	pha        //store register Y in stack

	lda #BLACK
	sta LABELS.border

	lda #<vblank   // Push next interrupt routine address for when we're done
	sta LABELS.loirq
	lda #>vblank
	sta LABELS.hiirq
	lda #250	   	// Next IRQ line
	sta LABELS.loraster

	lda #$ff        // Acknowlege IRQ 
	sta LABELS.interruptR

	jmp ack


ack: 
	//lda #$ff        // Acknowlege IRQ 
	//sta LABELS.interruptR

	// restore registers and rti for the mid-screen interrupts
	pla				// pull Y
	tay				// restore Y
	pla				// pull X
	tax				// restore X
	pla				// restore A
	
	rti

}
