
;
; PROMAL for the Commodore 64
; Copyright (C) 1985, SMA, Inc.
; Re-source (C) 2015 jbevren
;

; Special vars and commandline (originally $d00)

; version 
; status: 


cline   .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00
ncarg   .BYTE $00
cargl   .BYTE $00
cargh   .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00
comd    .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00
        ; these below must be in this order
worg    .WORD $0000     ; W file origin
wptr    .WORD $0000     ; W file pointer
weof    .WORD $0000     ; W file EOF
wlim    .WORD $0000     ; W file limit
lorg    .WORD $0000     ; L file origin
lptr    .WORD $0000     ; L file pointer
leof    .WORD $0000     ; L file EOF
llim    .WORD $0000     ; L file limit
        ; items above must be in this order
        .WORD $0000
maxmem  .WORD $D000     ; highest allocatable memory +1
KeyDefs .WORD $FFFF     ; position of function key definitions
wsize   .WORD $0000     ; size of W file
gvorg   .WORD $A100     ; global variables origin
        .BYTE $00
c64ddv0 .BYTE $08
c64ddv1 .BYTE $09
c64n1541 .BYTE $00
c64dyno .BYTE $80,$00,$00,$00,$00,$00
tbaud   .BYTE $06
tparity .BYTE $00
tdatab  .BYTE $00
tstopb  .BYTE $00
teofch  .BYTE $1A
tdevalf .BYTE $00
tdevraw .BYTE $00
tdevst  .BYTE $00,$00,$00
c64psa  .BYTE $07
c64pul  .BYTE $80
c64pdv  .BYTE $04
drterr  .BYTE $00
FPsav   .BYTE $00,$00,$00,$00
drvcode .WORD $4267     ; origin of drive-side fastload code
pblkcnt .WORD $00
alphalk .BYTE $00
