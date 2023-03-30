; ------------------------------------------------------------------------------
; CVLOAD V0.1
;
; Definitions used in ColecoVision Game Loader for CP/M on Z180
; ------------------------------------------------------------------------------

; Directives

		;DEFINE	STARTSCM		; Starts with SCM prompt instead of Coleco game

		; Test
		;DEFINE TEST			; Test initialisation without SCM
		;DEFINE	SLOWPROC		; Slow down processor (test option)
		;DEFINE	TESTK1			; Echo all accepted keys on ASCI 0 terminal
		;DEFINE	TESTK2			; Echo processed keys on ASCI 0 terminal
		;DEFINE	INTKEY			; Interrupt driven keyboard input (experimental)

		DEFINE	GAMECTL			; Include game controller support

		DEFINE	SN76489			; Include SN76489A PSG support
		;DEFINE YM2149			; Include YM21949/AY-3-8910 conversion (todo)

; Z180 Settings
CPUKHZ:		EQU	18432 			; Clock speed
Z180_BASE:	EQU	$00			; I/O Base address for internal registers

; Propeller Graphics Card / TMS9918A settings
VDPIO0:		EQU	$40			; VDP I/O data port (Coleco: $BE)
VDPIO1:		EQU	$41			; VDP I/O control port (Coleco: $BF)

; Z180 internal I/O ports
Z180_CNTLA0	EQU	Z180_BASE + $00		; ASCI 0 control A
Z180_STAT0	EQU	Z180_BASE + $04		; ASCI 0 status
Z180_TDR0	EQU	Z180_BASE + $06		; ASCI 0 transmit
Z180_RDR0	EQU	Z180_BASE + $08		; ASCI 0 receive
Z180_TCR:	EQU	Z180_BASE + $10		; Timer control
Z180_TMDR1L:	EQU	Z180_BASE + $14		; Timer 1 data low byte
Z180_TMDR1H:	EQU	Z180_BASE + $15		; Timer 1 data high byte
Z180_RLDR1L:	EQU	Z180_BASE + $16		; Timer 1 reload low byte
Z180_RLDR1H:	EQU	Z180_BASE + $17		; Timer 1 reload high byte
Z180_IL		EQU	Z180_BASE + $33		; Interrupt vector load




  
