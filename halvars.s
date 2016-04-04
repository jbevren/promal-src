
;
; PROMAL for the Commodore 64
; Copyright (C) 1985, SMA, Inc.
; Re-source (C) 2015 jbevren
;

; HAL variables and scratch storage (originally $c00)

; version 0
; status: matches original


stdin   .WORD skdev 
stdout  .WORD ssdev
stderi  .WORD skdev   ; apparently stderr, but only referenced in clsallz
stdero  .WORD sedev
ioerror .BYTE $00
exitcode .BYTE $00
errtyp  .BYTE $00
bfiltyp .BYTE $53
dioerr  .BYTE $00
dfext   .BYTE $43,$00,$00,$0E,$0C
date    .BYTE $01,$01,$01,$00
lomem   .WORD ((>promalend)+1)*256 ;$4F
lofree  .WORD ((>promalend)+1)*256 ;$4F
hifree  .WORD $A100
himem   .WORD $A100
lderr   .BYTE $00
nlt     .BYTE $00
PrgPtr  .BYTE $00
numprgsq .BYTE $00
randwd  .WORD $15B2
        .BYTE $00,$00,$00,$00,$00
progend .WORD $0000
osorg   .WORD $A200
memlim  .WORD $D000
FHEAD   .BYTE $00

; File header loads here during loadz.  Labels from page I-14
FTYPE   .BYTE $00
FHCDBA  .WORD $0000
FHSET0  .BYTE $00,$00
FHCDSZ  .WORD $0000
FHbyte08 .BYTE $00
newvarb .BYTE $00
FHshvar .WORD $0000
        .BYTE $00
FHscvar .BYTE $00
FHDATEd .BYTE $01
FHDATEm .BYTE $01
FHDATEy .BYTE $01
FHSET4  .BYTE $04
FHCOMD  .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00
ppp     .WORD $0000
mlp     .WORD $0000 ; p0c52 is mlp+1
rega    .BYTE $00
regx    .BYTE $00
regy    .BYTE $00
regf    .BYTE $00
regs    .BYTE $FF
PBsav   .WORD $0000
HPsav   .BYTE $00
HVsav   .BYTE $00
        .BYTE $00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00
prefix  .BYTE $30,$3A,$00
hFNam   .BYTE $00
p0C6C   .BYTE $00
p0C6D   .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00
hKFHmap .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
hFHeof  .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
hSerID  .BYTE $00
hDrvErr .BYTE $00
dfltirq .BYTE $00
p0CA1   .BYTE $00
brkflag .BYTE $00
hfileN  .BYTE $00,$00
FName   .BYTE $00
p0CA6   .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00
p0CB8   .BYTE $00
p0CB9   .BYTE $00
p0CBA   .BYTE $00
hxsav1  .BYTE $00
hysav1  .BYTE $00
Szl     .BYTE $00
Szh     .BYTE $00
p0CBF   .BYTE $00
hblksz  .WORD $0000
ysav1   .BYTE $00
p0CC3   .BYTE $00
p0CC4   .BYTE $00
p0CC5   .BYTE $00
p0CC6   .BYTE $00
p0CC7   .BYTE $00
hglflim .BYTE $00
hasav   .BYTE $00
hxsav   .BYTE $00
hysav   .BYTE $00
EdInsF  .BYTE $00
EdRvsF  .BYTE $00
EdRawF  .BYTE $00
EdUnkF  .BYTE $00
EdColF  .BYTE $00
EdLimit .BYTE $00
EdEOL   .BYTE $00
p0CD3   .BYTE $00
scrpos  .BYTE $00
p0CD5   .BYTE $00
p0CD6   .BYTE $00
p0CD7   .BYTE $00
p0CD8   .BYTE $00
p0CD9   .BYTE $00
p0CDA   .BYTE $00
hasav2  .BYTE $00
p0CDC   .BYTE $00
HBPos   .BYTE $00
asav    .BYTE $00
DynoRdy .BYTE $00,$00,$00,$00
FHtabB  .WORD FHTable
FHTabE  .WORD FHTableE
        .BYTE $00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00
nofnchk .BYTE $00
xsav2   .BYTE $00
hysav2  .BYTE $00
hxsav2  .BYTE $00
LoadFH  .WORD $0000
        .BYTE $00
ESwpSz  .WORD $2E00
edres   .BYTE $00
EdlnMode .BYTE $00
EdSCol  .BYTE $00
Exres   .BYTE $00
Cblnkrat .BYTE $0A
