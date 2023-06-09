﻿# cvload
Run Colecovision games on a Z180 retrocomputer:
- SC203 Modular Z180 computer 
- Propeller graphics card that emulates a TMS9918A
- Keyboard input via serial port to replace or in addition to game controller

Can it run Donkey Kong?
Basically all these components are different from a real Colecovision,
and only a limited number of games will be playable.
See: games.txt

## Loader steps
1. Load game ROM file from disk
2. Include Colecovision BIOS binary
3. Include SCM 1.3 binary
4. Include Colecovision patch program
4. Move loaded/included binaries to destination RAM locations
5. Apply system settings for speed and interrupts
6. Start Colecovision patcher or SCM

CP/M is only used to load the binaries.  
The Coleco rom file and scm binary must be added to compile the program.  

## Colecovision BIOS patches

- Replace VDP video i/o routines
- Extend game controller input routines
- Emulate TMS9918A vsync interrupt with 60Hz timer 
- Apply system patches
- Boot Colecovision BIOS

## SCM for Colecovision

Start game from scm prompt with:
g 5000

I did some hacks in the scm source code to make it work for this purpose.
Modified sources and config files are in the scm folder.

## Keyboard control

Default key assignment:  
A = Left  
D = Right  
W = Up  
X = Down  
, = Left fire  
. = Right fire  
P = Invoke SCM monitor  
  
Other keys:  
0..9,*,#   

## Todo
- Emulate SN76489A with an YM2149
- Load/save game state on disk(?)


## References
Colecovision Coding Guide:
https://archive.org/details/manualzilla-id-5667325

SCM V1.3:
https://smallcomputercentral.com/small-computer-monitor/

SC203 Modular Z180 Computer:
https://smallcomputercentral.com/sc203-modular-z180-computer/

Propeller Graphics Card:
https://github.com/maccasoft/propeller-graphics-card

Game controller card:
https://github.com/jblang/GameController
Part of the loader code is based on examples/z180load.asm

SN76489 Sound card:
https://github.com/jblang/SN76489

YM2149 card:
https://github.com/electrified/rc2014-ym2149

Example code to emulate SN76489: 
http://www.ricbit.com/mundobizarro/sic.php

