@echo off
rem Assemble with z88dk assembler
z80asm -mz180 -b -m cvpatch.asm
z80asm -mz180 -b -m cvload.asm -o=cvload.com

