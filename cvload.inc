; ------------------------------------------------------------------------------
; CVLOAD V0.2
;
; Definitions used in ColecoVision Game Loader for CP/M on Z180
; ------------------------------------------------------------------------------

; Directives
		;DEFINE	STARTSCM		; Starts with SCM prompt instead of Coleco game
		;DEFINE	TESTKEY			; Echo all accepted keys on ASCI 0 terminal 

		DEFINE	VSYNC			; Synchronise timer with video vsync
		DEFINE	SPRITE_FIX		; Fix for propeller tms9918a emulator bug
		DEFINE	GAMECTL			; Include game controller support
		DEFINE	SN76489			; Include SN76489A PSG support

		;DEFINE YM2149			; Include YM21949/AY-3-8910 conversion (todo)

		DEFINE	HALFSPEED		; When using this option also set full speed baudrate 
						; to 57600 (not 115200) otherwise adjusting baudrate for 
						; asci 0 will fail.

; Z180 Settings
IFDEF HALFSPEED
CPUKHZ:		EQU	9216			; Clock speed divided by 2
ELSE
CPUKHZ:		EQU	18432			; Clock speed
ENDIF
Z180_BASE:	EQU	$00			; I/O Base address for internal registers

; Propeller Graphics Card / TMS9918A settings
VDPIO0:		EQU	$40			; VDP I/O data port (Coleco: $BE)
VDPIO1:		EQU	$41			; VDP I/O control port (Coleco: $BF)
VDPIO2:		EQU	$42			; VDP I/O programming (reserved)
VDPIO3:		EQU	$43			; VDP I/O sync port

; Z180 internal I/O ports
Z180_CNTLA0	EQU	Z180_BASE + $00		; ASCI 0 control A
Z180_CNTLB0	EQU	Z180_BASE + $02		; ASCI 0 control B 
Z180_STAT0	EQU	Z180_BASE + $04		; ASCI 0 status
Z180_TDR0	EQU	Z180_BASE + $06		; ASCI 0 transmit
Z180_RDR0	EQU	Z180_BASE + $08		; ASCI 0 receive
Z180_TCR:	EQU	Z180_BASE + $10		; Timer control
Z180_TMDR1L:	EQU	Z180_BASE + $14		; Timer 1 data low byte
Z180_TMDR1H:	EQU	Z180_BASE + $15		; Timer 1 data high byte
Z180_RLDR1L:	EQU	Z180_BASE + $16		; Timer 1 reload low byte
Z180_RLDR1H:	EQU	Z180_BASE + $17		; Timer 1 reload high byte
Z180_CCR	EQU	Z180_BASE + $1F		; CPU control
Z180_DCNTL	EQU	Z180_BASE + $32		; DMA/WAIT control
Z180_IL		EQU	Z180_BASE + $33		; Interrupt vector load




  
