
;
; PROMAL for the Commodore 64
; Copyright (C) 1985, SMA, Inc.
; Re-source (C) 2015 jbevren
;

; system exception handler

; version 0
; status: matches original


domlbrk PLA 
        TAY 
        PLA 
        TAX 
        PLA 
        CLD 
        STA rega
        STX regx
        STY regy
        TSX 
        STX regs
        PLA 
        STA regf
        PLA 
        SEC 
        SBC #$02
        STA mlp
        PLA 
        SBC #$00
        STA mlp+1
        LDY #$00
        JMP emlbrk

        .BYTE $00,$00,$00,$00,$00,$00,$00,$00 ; these could be removed.
        .BYTE $00,$00,$00,$00
j1068   JMP e0div

Pbrk    JMP epbrk

cpubrk  JMP domlbrk

usrbrk  INC errtyp
eiored  INC errtyp
efileh  INC errtyp
elibarg INC errtyp
eredio  INC errtyp
esys    INC errtyp
erun    INC errtyp
        LDY #$00
e0div   INC errtyp
eillop  INC errtyp
StkErr  INC errtyp
        INC errtyp
epbrk   INC errtyp
emlbrk  INC errtyp
        TYA 
        CLC 
        ADC PBase
        STA ppp
        LDA PBase+1
        ADC #$00
        STA ppp+1
        DEC exitcode
        JMP r283e
