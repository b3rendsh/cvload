; ------------------------------------------------------------------------------
; CVLOAD V0.1
;
; ColecoVision Game Loader for CP/M on Z180
; ------------------------------------------------------------------------------

; Directives / constants

		INCLUDE	"CVLOAD.INC"
  
boot:		EQU	0		; Boot location
bdos:		EQU	5		; BDOS entry point
fcb:		EQU	$5c		; File Control Block
fcbcr:		EQU	fcb+$20		; FCB current record
buff:		EQU	$80		; DMA buffer
printf:		EQU	9		; BDOS print string function
openf:		EQU	15		; BDOS open file function
closef:		EQU	16		; BDOS close file function
readf:		EQU	20		; BDOS sequential read function

gametop:	EQU	$FFFF		; Max top of game cartridge location (himem)
gamelen:	EQU	$8000		; Max length of game cartridge

cr:		EQU	$0D		; Carriage Return
lf:		EQU	$0A		; Line Feed
eos:		EQU	'$'		; End of string marker

		ORG	$100		; Begin of CP/M application

; ------------------------------------------------------------------------------
; Load game
; ------------------------------------------------------------------------------
		LD	(oldsp),SP	; Save old stack pointer
		LD	SP,stack	; Set new stack pointer
		LD	DE,fcb		; Try to open file specified on command line
		CALL	open
		INC	A		; 255 indicates failure
		JR	Z,badfile
		LD	A,0		; Clear current record
		LD	(fcbcr),A
		LD	DE,gameaddr	; Set destination address
		LD	(dest),DE

loop:		LD	DE,fcb		; Read from file
		CALL	read
		OR	A
		JR	NZ,eof		; Non-zero A return value means end of file

		LD	HL,buff         ; Copy from DMA buffer to destination
		LD	DE,(dest)
		LD	BC,$80
		LDIR
		LD	(dest),DE	; Increment next destination address
		JR	loop

eof:		LD	DE,fcb		; Close the file
		CALL	close

		LD	DE,success	; Tell user that game was loaded
		CALL	print
		JP	rungame		; Copy the game to the final location and run

badfile:	LD	DE,nofile	; Print error if file is not found
		CALL	print
		LD	SP,(oldsp)      ; Restore stack pointer
		RET			; Return to CP/M

open:		LD	C,openf         ; BDOS call to open file
		JP	bdos

close:		LD	C,closef        ; BDOS call to close file
		JP	bdos

read:		LD	C,readf		; BDOS call to read file
		JP	bdos

print:		LD	C,printf        ; BDOS call to print string
		JP	bdos
        
nofile:		DB	"file not found",cr,lf,eos
success:	DB	"game loaded",eos


; ------------------------------------------------------------------------------
; Temporary RAM space for stack and included binaries.
; The end of the program should not exceed address $7FFF.
; ------------------------------------------------------------------------------
dest:		DW	gameaddr		; Destination pointer
oldsp:		DW	0			; Original stack pointer
        	DEFS	$40			; Space for stack
stack:						; Top of stack

bios:          	INCBIN	"coleco.rom"		; Include ColecoVision BIOS in program
endbios:

scm:		INCBIN	"scm.bin"		; Include SCM 1.30 Coleco version
endscm:

patch:		INCBIN	"cvpatch.bin"		; Include Colecovision patches
endpatch:

; ------------------------------------------------------------------------------
; Copy binaries to destination addressess and apply system settings
; ------------------------------------------------------------------------------
rungame:	DI				; No interrupts during loader process

; Load binaries
		LD	BC,gamelen		; Copy game to $8000-$FFFF (starting at himem!)
		LD	HL,gameaddr+gamelen-1
		LD	DE,gametop
		LDDR

		LD	BC,endbios-bios		; Copy ColecoVision BIOS to boot location
		LD	HL,bios 
		LD	DE,boot 
		LDIR

		LD	BC,endscm-scm		; Copy SCM to location $2000
		LD	HL,scm
		LD	DE,$2000
		LDIR

		LD	BC,endpatch-patch	; Copy cvpatch to location $5000
		LD	HL,patch
		LD	DE,$5000
		LDIR

; System settings
		LD	A,$00            	; Move Z180 I/O Base to $00
        	OUT0	($FF),A			; to avoid interference with Colecovision ports

IFDEF TEST
IFDEF SLOWPROC
		LD	A, $F0			; Set maximum memory and I/O wait states
		OUT0	($32),A
		LD	A,$00			; Divide clock by two
		OUT0	($1F),A			; this will also half the ASCI baudrate
		LD	A,$C0			; Enable refresh cycle every 10 T states
		OUT0	($36),A			; and make refresh wait 3 cycles long
						; this adds additional delay to the bus cycle
ELSE
		LD	A,$30			; Only set maximum I/O wait states (required for graphics card)
		OUT0	($32),A
		LD	A,$00
		OUT	($34),A			; Mask external interrupts
		OUT0	($36),A			; Turn off memory refresh
ENDIF
        	LD	A,$00			; Disable interrupts for unused internal peripherals
		OUT0	($10),A			; Timer
		OUT0	($30),A			; DMA controller
		OUT0	($0A),A			; CSI/O
		OUT0	($05),A			; ASCI 1
ENDIF

IFNDEF INTKEY
		IN0	A,($04)           	; ASCI 0
		AND	$F6			; Mask the receive/transmit interrupt bits
		OUT0	($04),A
ENDIF

; ------------------------------------------------------------------------------
; Start SCM or Colecovision game
; ------------------------------------------------------------------------------

IFDEF TEST
		JP	$5000			; Apply Colecovision patches and start game
ENDIF
IFNDEF STARTSCM
		LD	A,$55
		LD	($5003),A		; Set autostart Coleco patch
ENDIF
		JP	$200C			; Start SCM, skip selftest, and optionally autostart Coleco

; ------------------------------------------------------------------------------
; End of program
; ------------------------------------------------------------------------------
gameaddr:                   			; Temporarily load game at end of program