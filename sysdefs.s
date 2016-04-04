
;
; PROMAL for the Commodore 64
; Copyright (C) 1985, SMA, Inc.
; Re-source (C) 2015 jbevren
;

; System definitions

; version 0
; status: 

        ; firmware defines
kBRK    =$0316  ; firmware BRK vector
kIRQ    =$0314  ; firmware IRQ vector
kCLALL  =$FFE7  ; rom: close all files
kCINT   =$FF81  ; rom: init screen editor and vicII
kSETNAM =$FFBD  ; rom: set filename
kSETLFS =$FFBA  ; rom: set logical file parameters
kOPEN   =$FFC0  ; rom: open file
stopflag=$91
kernST  =$90
crsrcol =$d3
crsrrow =$d6
ccolor  =$0286
scrnptr =$D1
colrptr =$f3
scrnbase=$0288
htST    =$0297
tICR    =$02a1
RSOutC  =$029E
RSOutP  =$029D
RSInC   =$029c
RSInP   =$029b


        ; system defines
fpstack =$0800  ; floating point stack
heap    =$0900  ; system heap 
Heapptrq=$32    ; system heap pointer
HeapVec =$30    ; system heap vector
scratchpad=$a00 ; system scratch pad for string handling
fltptr  =$6f
Pjmp    =$2b
HistBuf = $FF00

        ; defines for init
KeyDefsi = $FE00
maxmemi =$d000  ; init is hardcoded to d000, blah.

        ; hardware defines
cpustk  =$0100  ; cpu stack location
VICmcr  =$D018
pport   =$01    ; memory map control

        ; zero page scratch defines
z00     =$00
z01     =$01
z02     =$02
z03     =$03
z06     =$06
z07     =$07
z16     =$16
z17     =$17
z18     =$18
z19     =$19
z2C     =$2c
z2D     =$2d
z2E     =$2e
z2F     =$2f
z30     =$30
z31     =$31
ysav    =$33
z34     =$34
z35     =$35
z36     =$36
z37     =$37
z38     =$38
z39     =$39
z3A     =$3a
z3B     =$3b
z3C     =$3c
z3D     =$3d
z3E     =$3e
z3F     =$3f
z40     =$40
z41     =$41
z57     =$57
z58     =$58
z59     =$59
z5A     =$5a
z5B     =$5b
z5C     =$5c
z5D     =$5d
z5E     =$5e
z5F     =$5f
z60     =$60
z61     =$61
z62     =$62
z63     =$63
z64     =$64
z65     =$65
z66     =$66
z67     =$67
z68     =$68
z69     =$69
z6A     =$6a
z6B     =$6b
z6C     =$6c
z6D     =$6d
z6E     =$6e
z78     =$78
z8B     =$8b
z8C     =$8c
z8D     =$8d
z92     =$92
z99     =$99
z9A     =$9a
zA9     =$a9
zB8     =$b8
zB9     =$b9
zD1     =$d1
zF3     =$f3
zF7     =$f7
zF8     =$f8
zF9     =$f9
zFA     =$fa
zFF     =$ff
