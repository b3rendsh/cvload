; **********************************************************************
; **  Build Small Computer Monitor Configuration ColecoVision         **
; **********************************************************************
#DEFINE     COLECO              ;Custom modifications for Coleco test setup

; Include standard configuration stuff
#INCLUDE    Config\Common\Config_Standard.asm

; Build date
#DEFINE     CDATE "20230305"    ;Build date is embedded in the code

; Configuration identifiers
kConfMajor: .SET 'J'            ;Config: Letter = official, number = user
kConfMinor: .SET '1'            ;Config: 1 to 9 = official, 0 = user
#DEFINE     CNAME "Coleco"      ;Configuration name (max 11 characters)

; Hardware ID (use HW_UNKNOWN if not for a very specified product)
kConfHardw: .SET HW_RCZ180_5    ;Hardware identifier (if known)


; **********************************************************************
; Included BIOS support for hardware

;SC114 SBC/Motherboard (Z80 CPU, RAM, ROM, Clock)
#INCLUDE    Config\Modules\SC111_native.asm

; Common RC2014 bus modules
#INCLUDE    Config\Common\Generic_RC2014.asm


; **********************************************************************
; Any required customisations should be here, eg:
; kSIO1:  .SET 0x80             ;Base address of serial Z80 SIO #1

; Processor
kCPUClock:  .SET 18432000       ;CPU clock speed in Hz
kZ180Base:  .SET 0x00           ;Z180 internal register base address

; Simple I/O ports
kPrtIn:     .SET 0x00           ;General input port
kPrtOut:    .SET 0x00           ;General output port

; Console devices
kConDef:    .SET 2              ;Default console device (1 to 6)
kBaud1Def:  .SET 0x11           ;Console device 1 default baud rate 
kBaud2Def:  .SET 0x11           ;Console device 2 default baud rate 
kBaud3Def:  .SET 0x11           ;Console device 3 default baud rate 
kBaud4Def:  .SET 0x11           ;Console device 4 default baud rate 

; Memory map
kCode:      .SET 0x2000         ;Typically 0x0000 or 0xE000
kData:      .SET 0x4C00         ;Typically 0xFC00 (to 0xFFFF)

; System options
;#DEFINE     ROM_ONLY            ;No option to assemble to upper memory
#DEFINE     EXTERNALOS          ;Run from external OS (eg. CP/M)
#DEFINE     BREAKPOINT 00       ;Breakpoint restart (00|08|10|18|20|28|30)

; Exclude
#UNDEFINE   IncludeRomFS        ;Do not include RomFS

#IFDEF      BUILD_AS_COM_FILE
kCode:      .SET 0x0100         ;Code starts at 0x0100 (not 0x0000)
#DEFINE     DO_NOT_REMAP_MEMORY ;Leave memory mapping hardware unchanged
#ENDIF

; **********************************************************************
; Build the code

#INCLUDE    System\Begin.asm

#INCLUDE    BIOS\SCZ180\Manager.asm

#INCLUDE    System\End.asm

#INCLUDE    Config\Common\ROM_Info_SC32k_NoApps.asm























