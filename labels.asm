LABELS: {

//----------------------------------------------------------
//				Variables
//----------------------------------------------------------
//.var			debug = true
//.var			musicEnabled = false
//.const 			irqpointer = $0314
//----------------------------------------------------------

.label screenram	= $0400
.label screencolourram = $d800

.label border 		= $d020
.label background 	= $d021

.label loraster 	= $d012
.label hiraster 	= $d011




.label basicloirq	= $0314
.label basichiirq	= $0315

.label loirq		= $FFFE
.label hiirq		= $FFFF

.label interruptR	= $d019
.label interruptE	= $d01a

.label basicstart 	= $0801

.label VICbank		= $DD00 	// lowest 2 bits 	00 	C000-FFFF
								//					01	8000-BFFF
								//					10	4000-7FFF
								//					11	0000-3FFF

.label viccontrol2	= $D016		// bits 0-2 hscroll
								// bit3 sceen width (38/40 cols)
								// bit4 multicolour mode
								// default %11001000

//----------------------------------------------------------
//				SPRITE labels
//----------------------------------------------------------
.label sprPointerR	= $07F8 // 2040
.label sprEnableR	= $D015	// 53269

.label sprXLO		= $D000	// 53248
.label sprY			= $D001 // 53249
.label sprXHIbitsR	= $D010 // 53264

.label sprColour	= $D027	// 53287
.label sprMCol1R	= $D025 // 53285
.label sprMCol2R	= $D026	// 53286

.label sprDHeightR	= $D017	// 53271
.label sprDWidthR	= $D01D	// 53277

.label sprPriorityR	= $D01B
.label sprMultiColR	= $D01C	// 53276
.label sprCollideSR	= $D01E
.label sprCollideBR	= $D01F
//----------------------------------------------------------


}
