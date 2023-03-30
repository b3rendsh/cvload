; ------------------------------------------------------------------------------
; CVPATCH V0.1
;
; Colecovision BIOS patches for Z180 retrocomputer.
; ------------------------------------------------------------------------------

; Directives / constants

		INCLUDE	"CVLOAD.INC"

AMERICA:	EQU	$0069			; NMI frequency is 50Hz or 60Hz
POWER_UP:	EQU	$006E			; Colecovision power up routine
CV_STACK:	EQU	$73B9			; Colecovision top of stack
VDP0SAV:	EQU	$73C3			; VDP register 0 save value
VDP1SAV:	EQU	$73C4			; VDP register 1 save value
PULSECNT1:	EQU	$73EB			; Spinner 1 pulse counter
JOY1SAV:	EQU	$73EE			; Joystick 1 save value
KEY1SAV:	EQU	$73F0			; Keypad 1 save value
NMI_INT_VEC:	EQU	$8021			; Vector for Coleco game nmi routine

		ORG	$5000

; Jump/init table
		JP	cvpatch			; $5000 Start Colecovision patch
		DB	0			; $5003 Autostart the Coleco patch from SCM if set to $55
		JP	outputChar		; $5004 Output character in register A to ASCI 0


; ------------------------------------------------------------------------------
; Patch Coleco ROM
; Some games (and BIOS) may directly call the internal address instead of using 
; the jump table at the end of the Coleco BIOS therefore the internal addresses 
; are patched with a jump to the new routine.
; ------------------------------------------------------------------------------
cvpatch:	; VDP I/O routines 
		
		LD	DE,READ_REG
		LD	HL,$1D57
		CALL	patchHL

		LD	DE,FILL_VRAM
		LD	HL,$18D4
		CALL	patchHL

		LD	DE,WRITE_SPRITE
		LD	HL,$1C82
		CALL	patchHL

		LD	DE,WRITE_REG
		LD	HL,$1CCA
		CALL	patchHL

		LD	DE,WRITE_VRAM
		LD	HL,$1D01
		CALL	patchHL

		LD	DE,READ_VRAM
		LD	HL,$1D3E
		CALL	patchHL

		; Game controller routines

		LD	DE,CONT_SCAN
		LD	HL,$114A
		CALL	patchHL

		LD	DE,DECODER
		LD	HL,$118B
		CALL	patchHL

IFNDEF SN76489
		;Replace PSG I/O instructions: out ($ff),a --> nop
		XOR	A
		LD	($0172),A		; Sound subroutines
		LD	($0173),A
		LD	($017B),A
		LD	($017C),A
		LD	($018D),A
		LD	($018E),A

		LD	($023D),A		; NOSOUND
		LD	($023E),A
		LD	($0241),A
		LD	($0242),A
		LD	($0245),A
		LD	($0246),A
		LD	($0249),A
		LD	($024A),A

		LD	($0335),A		; DOSOUND
		LD	($0336),A
		LD	($0354),A
		LD	($0355),A
ENDIF

		; The intended use of the 'AMERICA' byte is to differentiate 
		; between 50Hz PAL and 60Hz NTSC systems,
		; games may or may not use this value for timing routines.
		LD	A,50
		LD	(AMERICA),A		; Set to 50Hz

		; Prevent NMI call during initialisation.
		LD	A,0
		LD	(VDP1SAV),A

		; Some games (e.g. Zaxxon) use following addresses in the READ_VRAM 
		; routine to get the VDP I/O port values.
		LD	A,VDPIO1
		LD	($1D43),A
		LD	A,VDPIO0
		LD	($1D47),A		

; patch end

; ------------------------------------------------------------------------------
; The propeller graphics card has no 50Hz vsync interrupt feature.
; This is emulated with a timer (used ROMWBW HBIOS timer code as example).
; ------------------------------------------------------------------------------
initTimer:	LD	A,IVT >> 8		; Load interrupt vector table..
		LD	I,A			; .. high byte in I register
		XOR	A
		OUT0	(Z180_IL),A		; .. low byte in Z180 IL register
		LD	HL,CPUKHZ		; 50HZ = 18432000 / 20 / 50 / X, so X = CPU KHZ
		OUT0	(Z180_TMDR1L),L		; Initialise timer 1 data register
		OUT0	(Z180_TMDR1H),H
		DEC	HL			; Reload occurs *after* zero
		OUT0	(Z180_RLDR1L),L		; Initialise timer 1 reload register
		OUT0	(Z180_RLDR1H),H
		LD	A,$22			; Set timer 1 interrupt / countdown bit..
		OUT0	(Z180_TCR),A		; .. in Z180 timer control register

; ------------------------------------------------------------------------------
; End initialisation and start Coleco BIOS. 
; Skip the first instructions at address $0000 so they can be patched with 
; a trap or breakpoint vector that calls the SCM breakpoint routine.
; ------------------------------------------------------------------------------

		EI
		LD	SP,CV_STACK		; First instructions of the Coleco BIOS
		JP	POWER_UP		; "

; ------------------------------------------------------------------------------
timer:		LD	(SPSAV),SP		; Save the stackpointer
		LD	SP,SPTIMER		; More stackspace needed for the extra code
		PUSH	AF
		XOR	A
		LD	(CHECK_EI),A		; set CHECK_EI instruction to NOP
		IN0	A,(Z180_TCR)		; Acknowledge Z180 timer interrupt
		IN0	A,(Z180_TMDR1L)		; "
IFNDEF INTKEY
		CALL	inputChar		; Poll ASCI 0 for a new key
ENDIF
		LD	A,(charkey1)
		OR	A
		JR	Z, checkNewChar
		LD	A,(holdkey)
		DEC	A
		LD	(holdkey),A
		JR	NZ,endChar
		LD	(charkey1),A		; Release key after 5/50Hz=100ms 
checkNewChar:	LD	A,(charkey)
		OR	A
		JR	Z,endChar
IFDEF TESTK1
		CALL	outputChar
ENDIF
		LD	(charkey1),A
		LD	A,5
		LD	(holdkey),A		; Hold the key for 100ms 
		XOR	A
		LD	(charkey),A		; Clear the received key
endChar:	LD	A,(VDP1SAV)
		BIT	5,A			; VDP interrupt bit set?
		CALL	NZ, NMI_INT_VEC		; Yes, call NMI routine (ends with RETN)
		LD	A,$FB
		LD	(CHECK_EI),A		; set CHECK_EI instruction to EI
		POP	AF
		LD	SP,(SPSAV)		; Restore the stackpointer
		EI
		RET				; Don't use RETI in Z180 internal peripheral interrupt

; ------------------------------------------------------------------------------
; Re-enable interrupts if a Coleco replacement routine is not called from the 
; NMI routine. The instruction at address CHECK_EI is either EI($FB) or NOP($00)
; ------------------------------------------------------------------------------
CHECK_EI:	EI				
		RET

; ------------------------------------------------------------------------------
; Alternative input via Z180 internal ASCI 0.
; The ASCI port should be initialised already. If the system clock is divided 
; by 2 then the baudrate is 57600. The input is intentionally unbuffered, only 
; the latest received character is saved. Only the left controller is emulated 
; with keyboard keys.
; ------------------------------------------------------------------------------
inputChar:	PUSH	AF
		IN0	A,(Z180_STAT0)
		PUSH	AF
		AND	$70			; Any errors?
		JR	Z,input1
		IN0	A,(Z180_CNTLA0)
		RES	3,A			; Clear error flag
		OUT	(Z180_CNTLA0),A
input1:		POP	AF
		BIT	7,A			; Receive data register full?
		JR	Z,endInput
		IN0	A,(Z180_RDR0)

		; Check if the key is in the list
		PUSH	HL
		AND	$7F			; Mask ASCII
		CP	'a'
		JR	C,input2
		AND	$5F			; Convert to upper case
input2:		LD	HL,keylist
repeatCheck:	CP	(HL)
		JR	Z,endCheck		; Key is in the list, update charkey
		INC	HL
		JR	NC,repeatCheck
		LD	A,(charkey)		; Key is not in the list, keep old value
endCheck:	POP	HL
		LD	(charkey),A
endInput:	POP	AF
IFDEF INTKEY	
		; Re-enable interrupts if using interrupt driven keyboard input
		EI
ENDIF				
		RET

charkey:	DB	0			; Latest received char
charkey1:	DB	0			; Latest copy of char
holdkey:	DB	0			; Counter for debounce emulation

; ------------------------------------------------------------------------------
; outputChar is used for testing purposes.
; ------------------------------------------------------------------------------
outputChar:	PUSH 	BC
		IN0	B,(Z180_STAT0)
		BIT	1,B			; Transmit data register empty?
		POP	BC
		RET	Z
		OUT0	(Z180_TDR0),A
		RET

; ------------------------------------------------------------------------------
; Coleco $1FDC-->$1D57 READ_REGISTER replacement routine.
; ------------------------------------------------------------------------------
READ_REG:	IN	A,(VDPIO1)
		RET

; ------------------------------------------------------------------------------
; Coleco $1F82-->$18D4 FILL_VRAM replacement routine.
; ------------------------------------------------------------------------------
FILL_VRAM:	DI
		LD	C,A
		LD	A,L
		OUT	(VDPIO1),A
		LD	A,H
		OR	$40
		OUT	(VDPIO1),A
LAB_18DD:	LD	A,C
		OUT	(VDPIO0),A
		DEC	DE
		LD	A,D
		OR	E
		JR	NZ,LAB_18DD
		IN	A,(VDPIO1)
		JP	CHECK_EI

; ------------------------------------------------------------------------------
; Coleco $1FC4-->$1C82  WR_SPR_NM_TBL replacement routine.
; ------------------------------------------------------------------------------
WRITE_SPRITE:	DI
		LD	IX,($8004)
		PUSH	AF
		LD	IY,$73F2
		LD	E,(IY+$00)
		LD	D,(IY+$01)
		LD	A,E
		OUT	(VDPIO1),A
		LD	A,D
		OR	$40
		OUT	(VDPIO1),A
		POP	AF
LAB_1C9A:	LD	HL,($8002)
		LD	C,(IX+$00)
		INC	IX
		LD	B,$00
		ADD	HL,BC
		ADD	HL,BC
		ADD	HL,BC
		ADD	HL,BC
		LD	B,$04
		LD	C,VDPIO0
LAB_1CAC:	OUTI
		;NOP				; VDP wait not required for emulator
		;NOP		
		JR	NZ,LAB_1CAC
		DEC	A
		JR	NZ,LAB_1C9A
		JP	CHECK_EI

; ------------------------------------------------------------------------------
; Coleco $1FD9-->$1CCA  WRITE_REGISTER replacement routine.
; ------------------------------------------------------------------------------
WRITE_REG:	DI
		LD	A,C
		OUT	(VDPIO1),A
		LD	A,B
		ADD	A,$80
		OUT	(VDPIO1),A
		LD	A,B
		CP	$00
		JR	NZ,LAB_1CDB
		LD	A,C
		LD	(VDP0SAV),A
LAB_1CDB:	LD	A,B
		CP	$01
		JR	NZ,LAB_1CE4
		LD	A,C
		LD	(VDP1SAV),A
LAB_1CE4:	JP	CHECK_EI

; ------------------------------------------------------------------------------
; Coleco $1FDF-->$1D01  WRITE_VRAM replacement routine.
; ------------------------------------------------------------------------------
WRITE_VRAM:	DI
		PUSH	HL
		PUSH	DE
		POP	HL
		LD	DE,$4000
		ADD	HL,DE
		LD	A,L
		OUT	(VDPIO1),A
		LD	A,H
		OUT	(VDPIO1),A
		PUSH	BC
		POP	DE
		POP	HL
		LD	C,VDPIO0
		LD	B,E
LAB_1D14:	OUTI
		;NOP				; VDP wait not required for emulator
		;NOP
		JR	NZ,LAB_1D14
		DEC	D
		JP	M,LAB_1D21
		JR	NZ,LAB_1D14		; Keep the bug (should be: JR LAB_1D14)
LAB_1D21:	JP	CHECK_EI

; ------------------------------------------------------------------------------
; Coleco $1FE2-->$1D3E READ_VRAM replacement routine.
; ------------------------------------------------------------------------------
READ_VRAM:	DI
		LD	A,E
		OUT	(VDPIO1),A
		LD	A,D
		OUT	(VDPIO1),A
		PUSH	BC
		POP	DE
		LD	C,VDPIO0
		LD	B,E
LAB_1D49:	INI
		;NOP				; VDP wait not required for emulator
		;NOP
		JP	NZ,LAB_1D49
		DEC	D
		JP	M,LAB_1D56
		JR	NZ,LAB_1D49
LAB_1D56:	JP	CHECK_EI

; ------------------------------------------------------------------------------
; Coleco $1F76-->$114A CONT_SCAN - Read Controller Raw data routine.
; Following routine emulates the left controller with the keyboard.
; ------------------------------------------------------------------------------
CONT_SCAN:	LD	A,(charkey1)
		OR	A			; Is there a key pressed?
		JR	Z,readColeco
IFDEF TESTK2
		CALL	outputChar		; Test
ENDIF
		PUSH	HL
		LD	HL,joytab
		CALL	conversion
		LD	(JOY1SAV),A
		LD	A,(charkey1)
		LD	HL,keytab
		CALL	conversion
		LD	(KEY1SAV),A
		POP	HL
		RET

IFDEF GAMECTL
readColeco:	IN	A,($FC)			; Commands that were overwritten by patch jump 
		CPL				; "  
		JP	$114D			; Continue in Coleco BIOS
ELSE
readColeco:	LD	A,$80			; Set values for no input
		LD	(JOY1SAV),A
		LD	(KEY1SAV),A
		RET
ENDIF

; ------------------------------------------------------------------------------
; Coleco $1F79-->$118B DECODER - Read Controller
; Input  H: 0=left, 1=right
;        L: 0=left fire, 1=right fire
; Output H: fire button status in bit 5
;        L: joystick directions or keycode
;        E: old pulse counter (only if L=0)
; ------------------------------------------------------------------------------
DECODER:	LD	A,H
		OR	A
		JP	NZ,ctlColeco		; Right controller

		LD	A,(charkey1)
		OR	A			; Is there a key pressed?
		JR	Z,ctlColeco
		PUSH	AF
IFDEF TESTK2
		CALL	outputChar		; Test
ENDIF
		LD	A,L
		CP	$01
		JR	Z,readKeypad
		LD	BC,PULSECNT1
		LD	A,(BC)
		LD	E,A
		XOR	A
		LD	(BC),A
		POP	AF
		PUSH	HL
		LD	HL,joytab
		CALL	conversion
		POP	HL
		JP	$11A0			; Continue in Coleco BIOS

readKeypad:	POP	AF
		PUSH	HL
		LD	HL,keytab
		CALL	conversion
		POP	HL
		LD	D,A
		JP	$11B2			; Continue in Coleco BIOS

IFDEF GAMECTL		
ctlColeco:	LD	A,L			; Commands that were overwritten by patch jump 
		CP	$01			; "
		JP	$118E			; Continue in Coleco BIOS
ELSE
ctlColeco:	LD	H,$00			; Return values for no input
		LD	A,L
		CP	$01
		JR	Z,writeKeypad
		LD	L,$00
		RET
writeKeypad:	LD	L,$0F
		RET
ENDIF

; ------------------------------------------------------------------------------
; Convert keyboard ASCII key to Coleco key code.
; ------------------------------------------------------------------------------
conversion:	CP	(HL)
		JR	Z,convertKey
		INC	HL
		INC	HL
		JR	NC,conversion
		LD	A,$80			; Key not in table
		RET
convertKey:	INC	HL
		LD	A,(HL)
		RET

; ------------------------------------------------------------------------------
; Patch (HL) with jump to (DE).
; ------------------------------------------------------------------------------
patchHL:	LD	A,$C3			; Jump instruction
		LD	(HL),A
		INC	HL
		LD	(HL),E
		INC	HL
		LD	(HL),D
		RET

; ------------------------------------------------------------------------------
; Conversion tables from keyboard ASCII code to Coleco controller raw code
; must be sorted in ascending order of keyboard code.
; ------------------------------------------------------------------------------
joytab:		DB	',',$C0		; Left fire
		DB	'A',$88		; Joystick left
		DB	'D',$82		; Joystick right
		DB	'W',$81		; Joystick up
		DB	'X',$84		; Joystick down
		DB	$FF,$80		; End of table

keytab:		DB	'#',$89		
		DB	'*',$86
		DB	'.',$C0		; Right fire
		DB	'0',$85		
		DB	'1',$82		
		DB	'2',$88
		DB	'3',$83
		DB	'4',$8D
		DB	'5',$8C
		DB	'6',$81
		DB	'7',$8A
		DB	'8',$8E
		DB	'9',$84
		DB	$FF,$80		; End of table

; List of acceptable keyboard characters, in ascending order
keylist:	DB	"#*,.0123456789ADWX"
		DB	$FF

; ------------------------------------------------------------------------------
; Interrupt vector table. Must be aligned to page.
; ------------------------------------------------------------------------------

		ALIGN	256

IVT:		DW	0			; 0 INT1
		DW	0			; 1 INT2
		DW	0			; 2 PRT0
		DW	timer			; 3 PRT1
		DW	0			; 4 DMA0
		DW	0			; 5 DMA1
		DW	0			; 6 CSIO
		DW	inputChar		; 7 ASCI0
		DW	0			; 8 ASCI1
		DW	0			; 9
		DW	0			; 10
		DW	0			; 11
		DW	0			; 12
		DW	0			; 13
		DW	0			; 14
		DW	0			; 15

; ------------------------------------------------------------------------------
; Stack space for extended interrupt routine.
; ------------------------------------------------------------------------------
SPSAV:		DW	0			; Saved stackpointer
		DS	640			; This should be enough stack space for any game
SPTIMER:
