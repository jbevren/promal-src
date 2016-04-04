
;
; PROMAL for the Commodore 64
; Copyright (C) 1985, SMA, Inc.
; Re-source (C) 2015 jbevren
;

; program state variables: Orignally $b00-bff

; version 0
; status: 


; loader table: Contains information on loaded programs
PTYPE   .BYTE $00,$00,$00,$00,$00,$00,$00,$00

; Base address and number of pages for program code
PBAh    .BYTE $00,$00,$00,$00,$00,$00,$00,$00
PPPAGES .BYTE $00,$00,$00,$00,$00,$00,$00,$00

; Base address and number of pages for scalar(?) vars
PVARSh  .BYTE $00,$00,$00,$00,$00,$00,$00,$00
PVPAGES .BYTE $00,$00,$00,$00,$00,$00,$00,$00

; Checksum for each program
Pcksuml .BYTE $00,$00,$00,$00,$00,$00,$00,$00
Pcksumh .BYTE $00,$00,$00,$00,$00,$00,$00,$00

; P-code return address used when calling overlays
pRTSL   .BYTE $00,$00,$00,$00,$00,$00,$00,$00
pRTSh   .BYTE $00,$00,$00,$00,$00,$00,$00,$00

; ML return address used when calling overlays
mlRTSL  .BYTE $00,$00,$00,$00,$00,$00,$00,$00
mlRTSh  .BYTE $00,$00,$00,$00,$00,$00,$00,$00

; CPU stack pointers
Pstkptr .BYTE $00,$00,$00,$00,$00,$00,$00,$00

; Floating point stack pointers
Pfltptr .BYTE $00,$00,$00,$00,$00,$00,$00,$00
Pheappq .BYTE $00,$00,$00,$00,$00,$00,$00,$00
Pheapl  .BYTE $00,$00,$00,$00,$00,$00,$00,$00
Pldflags .BYTE $00,$00,$00,$00,$00,$00,$00,$00
Pparent .BYTE $00,$00,$00,$00,$00,$00,$00,$00
PDATEd  .BYTE $00,$00,$00,$00,$00,$00,$00,$00
PDATEm  .BYTE $00,$00,$00,$00,$00,$00,$00,$00
PDATEy  .BYTE $00,$00,$00,$00,$00,$00,$00,$00

; Vectors to each command's name.  Interestingly, these never get written to; just referenced.
PCOMDvl .BYTE <PNAME0,<PNAME1,<PNAME2,<PNAME3,<PNAME4,<PNAME5,<PNAME6,<PNAME7
PCOMDvh .BYTE >PNAME0,>PNAME1,>PNAME2,>PNAME3,>PNAME4,>PNAME5,>PNAME6,>PNAME7
ldname  .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00
RelHdr  .BYTE $00
RelHtyp .BYTE $00
relsz   .WORD $0000
ldnochk .BYTE $00
xsav    .BYTE $00
PrgBit  .BYTE $00
LDCHAIN .BYTE $00
LDPRCLR .BYTE $00
LDRELD  .BYTE $00
LDRECLM .BYTE $00
LDNOGO  .BYTE $00
LDUNLD  .BYTE $00
LDbit6  .BYTE $00
LDbit7  .BYTE $00
LDRESUME .BYTE $00
OWNFlag .BYTE $00
ldflags .BYTE $00
p0BCE   .BYTE $00
CUsctch .BYTE $00
p0BD0   .BYTE $00
p0BD1   .BYTE $2E
relEsz  .BYTE $00
p0BD3   .BYTE $00
p0BD4   .BYTE $00
pjsrv   .WORD $0000
spsav   .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00
p0BEB   .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00
