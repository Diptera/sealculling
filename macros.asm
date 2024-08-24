

.macro storestate() {
	// push registers to stack
	pha        //store register A in stack
	txa
	pha        //store register X in stack
	tya
	pha        //store register Y in stack
}

.macro restorestate() {
	// pull registers from stack
	pla				// pull Y
	tay				// restore Y
	pla				// pull X
	tax				// restore X
	pla				// restore A
}