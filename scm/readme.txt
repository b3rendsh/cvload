SCM 1.3 Coleco
==============

In this folder are modified SCM files for use with the SC203.

Assemble instructions:
1. Copy the asm files to the SCMonitor/Source (sub) folders
2. Assemble with SCWorkshop.exe
3. Copy the file Output/Binary.bin to cvload/scm.bin

Notes
-----

Some modifications have been made in the SCM sources.
They can be recognized with the assembler directive COLECO.

Following settings can be modified in config_J1_ColecoVision.asm:
Breakpoints use RST $00, this also catches illegal instruction traps.
The SCM console is set to the second ASCI port
ORG is set to $2000
Z180 base is set to $00 (this is also modified in SC111_native.asm)

In !Main.asm the above ColecoVision config is selected.

When starting SCM the selftest is skipped by jumping to address $200C.
If the autostart byte at $5003 is set to $55 the Coleco patch routine
at $5000 will be started after initialisation of SCM, if not then
the SCM command prompt will be displayed on ASCI 1 (i.e. 2nd port).




