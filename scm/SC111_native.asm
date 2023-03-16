; **********************************************************************
; **  Configuration file                        by Stephen C Cousins  **
; **  Module: SC111 native mode (Z180 module for RC2014 bus)          **
; **********************************************************************

; This card contains a Z180 CPU, ROM, RAM, Clock, Reset, Serial port

; Processor
#DEFINE     PROCESSOR Z180      ;Processor type "Z80", "Z180"
kCPUClock:  .SET 18432000       ;CPU clock speed in Hz
#IFDEF COLECO
kZ180Base:  .SET 0x00           ;Z180 internal register base address
#ELSE
kZ180Base:  .SET 0xC0           ;Z180 internal register base address
#ENDIF

; ROM filing system
kROMBanks:  .SET 1              ;Number of software selectable ROM banks

; Z180 ASCI
#IFNDEF     INCLUDE_ASCI_n1
kASCI1:     .SET kZ180Base+0x00 ;Base address of Z180 serial ports (CNTLA0)
#DEFINE     INCLUDE_ASCI_n1     ;Include ASCI #1 
#ENDIF



