
;
; PROMAL for the Commodore 64
; Copyright (C) 1985, SMA, Inc.
; Re-source (C) 2015 jbevren
;

; P-code intrepeter core for PROMAL engine

; version 
; status: 

; local defines
; 2016 4 apr: Set varbase and scratch2c to z2e and z2c to simply porting
varbase =z2e
scratch2c=z2c

PPzero1 LDA #$00     ;Push zero on stack (duplicate code, see PPzero)
        PHA 
        JMP Pnext

PPone   LDA #$01     ;Push a one to the stack
        PHA 
        JMP Pnext

PPtwo   LDA #$02     ;Push a two to the stack
        PHA 
        JMP Pnext

PPbyte  LDA (PBase),Y  ;Push an immediate byte to the stack
        JMP PnextP

PphBW   LDA (PBase),Y  ;Push an immediate byte to stack as a word
        PHA 
        LDA #$00
        JMP PnextP

PPword  LDA (PBase),Y  ;Push an immediate word to the stack
        PHA 
        INY 
        BEQ PPwordz
PPwordy LDA (PBase),Y
        JMP PnextP

PPwordz INC PBase+1
        BNE PPwordy

PVar2stB LDA (PBase),Y  ;Push byte variabe to stack
        STA varbase
        LDX #$00
        LDA (varbase,X)
        JMP PnextP

PGVarAd LDA (PBase),Y  ;Push pointer to variable to stack
        PHA 
        LDA varbase+1
        JMP PnextP

PVar2stW LDA (PBase),Y  ;Push word variable to stack
        STA varbase
        STY ysav
        LDY #$00
        LDA (varbase),Y
        PHA 
        INY 
        LDA (varbase),Y
        LDY ysav
        JMP PnextP

Ppeekb  LDA (PBase),Y  ;Pull byte from stack to variable
        STA scratch2c
        INY 
        BEQ Ppeekbx
Ppeekbz LDA (PBase),Y
        STA scratch2c+1
        LDX #$00
        LDA (scratch2c,X)
        JMP PnextP

Ppeekbx INC PBase+1
        BNE Ppeekbz

PpeekW  LDA (PBase),Y  ;Pull word from stack to variable
        STA scratch2c
        INY 
        BEQ PpeekWx
PpeekWz LDA (PBase),Y
        STA scratch2c+1
        STY ysav
        LDY #$00
        LDA (scratch2c),Y
        PHA 
        INY 
        LDA (scratch2c),Y
        LDY ysav
        JMP PnextP

PpeekWx INC PBase+1
        BNE PpeekWz

Pstkrib LDA (PBase),Y  ;Push byte from system heap to stack
        STY ysav
        TAY 
        LDA (HeapVec),Y
        LDY ysav
        JMP PnextP

Padd230 LDA (PBase),Y  ;Add immediate byte to heap pointer
        CLC 
        ADC HeapVec
        PHA 
        LDA HeapVec+1
        JMP PnextP

Pstkriw LDA (PBase),Y  ;Push word from system heap to stack
        STY ysav
        TAY 
        LDA (HeapVec),Y
        PHA 
        INY 
        LDA (HeapVec),Y
        LDY ysav
        JMP PnextP

Pstkpb  PLA 
        STA scratch2c+1
        PLA 
        STA scratch2c
        LDX #$00
        LDA (scratch2c,X)
        PHA 
        JMP Pnext

Pstkpw  PLA 
        STA scratch2c+1
        PLA 
        STA scratch2c
        STY ysav
        LDY #$00
        LDA (scratch2c),Y
        PHA 
        INY 
        LDA (scratch2c),Y
        PHA 
        LDY ysav
        JMP Pnext

PpeekWI PLA 
        TAX 
        PLA 
        CLC 
        ADC (PBase),Y
        STA scratch2c
        INY 
        BEQ PpeekWIx
PpeekWIz TXA 
        ADC (PBase),Y
        STA scratch2c+1
        LDX #$00
        LDA (scratch2c,X)
        JMP PnextP

PpeekWIx INC PBase+1
        BNE PpeekWIz

PLkLst  PLA 
        STA z38
        PLA 
        ASL 
        ROL z38
        CLC 
        ADC (PBase),Y
        STA scratch2c
        INY 
        BEQ PLkLstx
PLkLstz LDA (PBase),Y
        ADC z38
        STA scratch2c+1
        STY ysav
        LDY #$00
        LDA (scratch2c),Y
        PHA 
        INY 
        LDA (scratch2c),Y
        LDY ysav
        JMP PnextP

PLkLstx INC PBase+1
        BNE PLkLstz
Paddww  PLA 
        TAX 
        PLA 
        CLC 
        ADC (PBase),Y
        PHA 
        INY 
        BEQ Paddwwx
Paddwwz TXA 
        ADC (PBase),Y
        JMP PnextP

Paddwwx INC PBase+1
        BNE Paddwwz
Padd2sw PLA 
        STA z38
        PLA 
        ASL 
        ROL z38
        CLC 
        ADC (PBase),Y
        PHA 
        INY 
        BEQ Paddwwu
g11E6   LDA z38
        ADC (PBase),Y
        JMP PnextP

Paddwwu INC PBase+1
        BNE g11E6

Pst2varB LDA (PBase),Y
        STA varbase
        LDX #$00
        PLA 
        STA (varbase,X)
        JMP Pskip

Pst2varW LDA (PBase),Y
        STA varbase
        STY ysav
        LDY #$01
        PLA 
        STA (varbase),Y
        DEY 
        PLA 
        STA (varbase),Y
        LDY ysav
        JMP Pskip

PpokeB  LDA (PBase),Y
        STA scratch2c
        INY 
        BEQ PpokeBx
PpokeBz LDA (PBase),Y
        STA scratch2c+1
        LDX #$00
        PLA 
        STA (scratch2c,X)
        JMP Pskip

PpokeBx INC PBase+1
        BNE PpokeBz
PpokeW  LDA (PBase),Y
        STA scratch2c
        INY 
        BEQ PpokeWx
PpokeWz LDA (PBase),Y
        STA scratch2c+1
        STY ysav
        LDY #$01
        PLA 
        STA (scratch2c),Y
        DEY 
        PLA 
        STA (scratch2c),Y
        LDY ysav
        JMP Pskip

PpokeWx INC PBase+1
        BNE PpokeWz
Pstkwib LDA (PBase),Y
        STY ysav
        TAY 
        PLA 
        STA (HeapVec),Y
        LDY ysav
        JMP Pskip

Pstkwiw LDA (PBase),Y
        STY ysav
        TAY 
        INY 
        PLA 
        STA (HeapVec),Y
        DEY 
        PLA 
        STA (HeapVec),Y
        LDY ysav
        JMP Pskip

PPkIdx  PLA 
        TAX 
        PLA 
        STA z38
        PLA 
        CLC 
        ADC (PBase),Y
        STA scratch2c
        INY 
        BEQ g1282
g1274   LDA (PBase),Y
        ADC z38
        STA scratch2c+1
        TXA 
        LDX #$00
        STA (scratch2c,X)
        JMP Pskip

g1282   INC PBase+1
        BNE g1274
PFindSt TSX 
        LDA cpustk+4,X
        ASL 
        ROL cpustk+3,X
        CLC 
        ADC (PBase),Y
        STA scratch2c
        INY 
        BEQ g12AF
g1296   LDA cpustk+3,X
        ADC (PBase),Y
        STA scratch2c+1
        STY ysav
        LDY #$01
        PLA 
        STA (scratch2c),Y
        DEY 
        PLA 
        STA (scratch2c),Y
        PLA 
        PLA 
        LDY ysav
        JMP Pskip

g12AF   INC PBase+1
        BNE g1296
PisLTb  PLA 
        STA z38
        PLA 
        CMP z38
        BCC g12CF
        LDA #$00
        PHA 
        JMP Pnext

PisGEb  PLA 
        STA z38
        PLA 
        CMP z38
        BCS g12CF
        LDA #$00
        PHA 
        JMP Pnext

g12CF   LDA #$01
        PHA 
        JMP Pnext

PisLEb  PLA 
        TSX 
        CMP cpustk+1,X
        BCC g12E4
        LDA #$01
        STA cpustk+1,X
        JMP Pnext

g12E4   LDA #$00
        STA cpustk+1,X
        JMP Pnext

PisEQb  PLA 
        TSX 
        CMP cpustk+1,X
        BEQ g130A
        LDA #$00
        STA cpustk+1,X
        JMP Pnext

PisNEb  PLA 
        TSX 
        CMP cpustk+1,X
        BNE g130A
        LDA #$00
        STA cpustk+1,X
        JMP Pnext

g130A   LDA #$01
        STA cpustk+1,X
        JMP Pnext

PisGTb  PLA 
        TSX 
        CMP cpustk+1,X
        BCS g1321
        LDA #$01
        STA cpustk+1,X
        JMP Pnext

g1321   LDA #$00
        STA cpustk+1,X
        JMP Pnext

PisLEw  TSX 
        LDA cpustk+4,X
        CMP cpustk+2,X
        BNE g136E
        LDA cpustk+3,X
        SBC cpustk+1,X
        BCC g1376
        BEQ g1376
        LDA #$00
        STA cpustk+4,X
        INX 
        INX 
        INX 
        TXS 
        JMP Pnext

PisLEi  TSX 
        LDA cpustk+4,X
        CMP cpustk+2,X
        BNE g1389
        LDA cpustk+3,X
        SBC cpustk+1,X
        BMI g1376
        BEQ g1376
g135B   LDA #$00
        STA cpustk+4,X
        INX 
        INX 
        INX 
        TXS 
        JMP Pnext

PisLTw  TSX 
        LDA cpustk+4,X
        CMP cpustk+2,X
g136E   LDA cpustk+3,X
        SBC cpustk+1,X
        BCS g135B
g1376   LDA #$01
        STA cpustk+4,X
        INX 
        INX 
        INX 
        TXS 
        JMP Pnext

PisLTi  TSX 
        LDA cpustk+4,X
        CMP cpustk+2,X
g1389   LDA cpustk+3,X
        SBC cpustk+1,X
        BPL g135B
g1391   LDA #$01
        STA cpustk+4,X
        INX 
        INX 
        INX 
        TXS 
        JMP Pnext

PisGEw  TSX 
        LDA cpustk+4,X
        CMP cpustk+2,X
        LDA cpustk+3,X
        SBC cpustk+1,X
        BCS g1391
        LDA #$00
        STA cpustk+4,X
        INX 
        INX 
        INX 
        TXS 
        JMP Pnext

PisGEi  TSX 
        LDA cpustk+4,X
        CMP cpustk+2,X
        LDA cpustk+3,X
        SBC cpustk+1,X
        BPL g1391
        LDA #$00
        STA cpustk+4,X
        INX 
        INX 
        INX 
        TXS 
        JMP Pnext

PisGTw  TSX 
        LDA cpustk+2,X
        CMP cpustk+4,X
        LDA cpustk+1,X
        SBC cpustk+3,X
        BCC g1391
        LDA #$00
        STA cpustk+4,X
        INX 
        INX 
        INX 
        TXS 
        JMP Pnext

PisGTi  TSX 
        LDA cpustk+2,X
        CMP cpustk+4,X
        LDA cpustk+1,X
        SBC cpustk+3,X
        BMI g1391
        LDA #$00
        STA cpustk+4,X
        INX 
        INX 
        INX 
        TXS 
        JMP Pnext

PisEQw  PLA 
        TSX 
        CMP cpustk+2,X
        BNE g141F
        PLA 
        CMP cpustk+3,X
        BNE g142A
        PLA 
        LDA #$01
        STA cpustk+3,X
        JMP Pnext

g141F   INX 
        INX 
        TXS 
        LDA #$00
        STA cpustk+1,X
        JMP Pnext

g142A   PLA 
        LDA #$00
        STA cpustk+3,X
        JMP Pnext

PisNEi  PLA 
        TSX 
        CMP cpustk+2,X
        BNE g1449
        PLA 
        CMP cpustk+3,X
        BNE g1454
        PLA 
        LDA #$00
        STA cpustk+3,X
        JMP Pnext

g1449   INX 
        INX 
        TXS 
        LDA #$01
        STA cpustk+1,X
        JMP Pnext

g1454   PLA 
        LDA #$01
        STA cpustk+3,X
        JMP Pnext

Psgnflp TSX 
        LDA #$00
        SEC 
        SBC cpustk+2,X
        STA cpustk+2,X
        LDA #$00
        SBC cpustk+1,X
        STA cpustk+1,X
        JMP Pnext

Paddb   PLA 
        TSX 
        CLC 
        ADC cpustk+1,X
        STA cpustk+1,X
        JMP Pnext

Paddw   TSX 
        LDA cpustk+2,X
        CLC 
        ADC cpustk+4,X
        STA cpustk+4,X
        PLA 
        ADC cpustk+3,X
        STA cpustk+3,X
        PLA 
        JMP Pnext

Psubb   TSX 
        LDA cpustk+2,X
        SEC 
        SBC cpustk+1,X
        STA cpustk+2,X
        PLA 
        JMP Pnext

Psubw   TSX 
        LDA cpustk+4,X
        SEC 
        SBC cpustk+2,X
        STA cpustk+4,X
        LDA cpustk+3,X
        SBC cpustk+1,X
        STA cpustk+3,X
        INX 
        INX 
        TXS 
        JMP Pnext

Pmulw   LDX #$03
g14BF   PLA 
        STA z3C,X
        DEX 
        BPL g14BF
        JSR Mul16
        LDA z3C
        PHA 
        LDA z3D
        PHA 
        JMP Pnext

Pdivi   PLA 
        STA z3D
        PLA 
        STA z3C
        PLA 
        STA z3F
        PLA 
        STA z3E
        LDA z3D
        STA z34
        BPL g14F0
        LDA #$00
        SEC 
        SBC z3C
        STA z3C
        LDA #$00
        SBC z3D
        STA z3D
g14F0   LDA z3F
        BPL g1507
        LDA z34
        EOR #$80
        STA z34
        LDA #$00
        SEC 
        SBC z3E
        STA z3E
        LDA #$00
        SBC z3F
        STA z3F
g1507   JSR Div32
        BIT z34
        BPL g151C
        LDA #$00
        SEC 
        SBC z3E
        PHA 
        LDA #$00
        SBC z3F
        PHA 
        JMP Pnext

g151C   LDA z3E
        PHA 
        LDA z3F
        PHA 
        JMP Pnext

Pdivw   PLA 
        STA z3D
        PLA 
        STA z3C
        PLA 
        STA z3F
        PLA 
        STA z3E
        JSR Div32
        JMP g151C

Pdivmod PLA 
        STA z3D
        PLA 
        STA z3C
        PLA 
        STA z3F
        PLA 
        STA z3E
        JSR Div32
        LDA z40
        PHA 
        LDA z41
        PHA 
        JMP Pnext

Pshlb   PLA 
        BEQ g1559
        TAX 
        PLA 
g1554   ASL 
        DEX 
        BNE g1554
        PHA 
g1559   JMP Pnext

Pshlw   PLA 
        BEQ g156E
        STY ysav
        TAY 
        PLA 
        TSX 
g1564   ASL cpustk+1,X
        ROL 
        DEY 
        BNE g1564
        PHA 
        LDY ysav
g156E   JMP Pnext

Pshrb   PLA 
        BEQ g157B
        TAX 
        PLA 
g1576   LSR 
        DEX 
        BNE g1576
        PHA 
g157B   JMP Pnext

Pshrw   PLA 
        BEQ g1590
        STY ysav
        TAY 
        PLA 
        TSX 
g1586   LSR 
        ROR cpustk+1,X
        DEY 
        BNE g1586
        PHA 
        LDY ysav
g1590   JMP Pnext

Ppopb   PLA 
        JMP Pnext

Ppop1b  PLA 
        TSX 
        STA cpustk+1,X
        JMP Pnext

PPzero  LDA #$00
        PHA 
        JMP Pnext

Pnotb   PLA 
        BEQ g15AE
        LDA #$00
        PHA 
        JMP Pnext

g15AE   LDA #$01
        PHA 
        JMP Pnext

Pandb   PLA 
        TSX 
        AND cpustk+1,X
        STA cpustk+1,X
        JMP Pnext

Porb    PLA 
        TSX 
        ORA cpustk+1,X
        STA cpustk+1,X
        JMP Pnext

Pxorb   PLA 
        TSX 
        EOR cpustk+1,X
        STA cpustk+1,X
        JMP Pnext

Pselb   PLA 
        TSX 
        CMP cpustk+1,X
        BNE Pgoto
        PLA 
        INY 
        BEQ g1605
        JMP Pskip

Pselw   PLA 
        TSX 
        CMP cpustk+2,X
        BNE Pselwz
        PLA 
        CMP cpustk+3,X
        BNE Pgoto
        PLA 
        PLA 
        INY 
        BEQ g1605
        JMP Pskip

Pselwz  PLA 
        JMP Pgoto

Pbzero  PLA 
        BEQ Pgoto
        INY 
        BEQ g1605
        JMP Pskip

g1605   INC PBase+1
        JMP Pskip

Pgoto   LDA (PBase),Y
        TAX 
        INY 
        BEQ g161B
g1610   LDA (PBase),Y
        STA PBase+1
        STX PBase
        LDY #$00
        JMP Pnext

g161B   INC PBase+1
        BNE g1610

refuge  TSX 
        STX z38
        LDA (PBase),Y
        TAX 
        LDA z38
        STA spsav,X
        LDA fltptr
        STA FPsav,X
        TXA 
        ASL 
        ASL 
        INY 
        BNE g1637
        INC PBase+1
g1637   TAX 
        TYA 
        CLC 
        ADC PBase
        STA PBsav,X
        LDA PBase+1
        ADC #$00
        STA PBsav+1,X
        LDA Heapptrq
        STA HPsav,X
        LDA HeapVec
        STA HVsav,X
        JMP Pnext

escape  LDA (PBase),Y
        TAY 
        LDX spsav,Y
        TXS 
        LDA FPsav,Y
        STA fltptr
        TYA 
        ASL 
        ASL 
        TAY 
        LDA PBsav,Y
        STA PBase
        LDA PBsav+1,Y
        STA PBase+1
        LDA HPsav,Y
        STA Heapptrq
        LDA HVsav,Y
        STA HeapVec
        LDY #$00
        JMP Pnext

Pgosub  TYA 
        CLC 
        ADC PBase
        STA PBase
        BCC g1687
        INC PBase+1
        CLC 
g1687   ADC #$02
        LDX Heapptrq
        STA heap,X
        INX 
        BEQ StkErrj1
        LDA PBase+1
        ADC #$00
        STA heap,X
        INX 
        BEQ StkErrj1
        STX Heapptrq
        LDY #$01
        LDA (PBase),Y
        TAX 
        DEY 
        LDA (PBase),Y
        STA PBase
        STX PBase+1
        JMP Pnext

StkErrj1 JMP StkErr

pr16af  LDX Heapptrq
        LDA HeapVec
        STA heap,X
        STX HeapVec
        LDA (PBase),Y
        BEQ g16CE
        STY ysav
        TAY 
        CLC 
        ADC Heapptrq
        BCS StkErrj1
        STA Heapptrq
g16C6   PLA 
        STA (HeapVec),Y
        DEY 
        BNE g16C6
        LDY ysav
g16CE   INY 
        LDA (PBase),Y
        INY 
        SEC 
        ADC Heapptrq
        BCS StkErrj1
        STA Heapptrq
        JMP Pnext


; Promal RTS:  Return from function or procedure to calling routine
Prts    LDX HeapVec      ;Get heap vector pointer
        LDA heap,X   ;Fetch previous heap pointer
        STA HeapVec
        DEX 
        LDA heap,X   ;Fetch previous execution address
        STA PBase+1
        DEX 
        LDA heap,X
        STA PBase
        STX Heapptrq ;Store to system heap pointer
        LDY #$00     ;Y=0 to ensure correct promal return address
        JMP Pnext    ;and off we go!


; Promal JSR: call ML subroutine with parameters.  4-29
Pbjsr   LDA (PBase),Y  ;Subroutine low address
        STA scratch2c
        INY 
        BNE g16FF
        INC PBase+1
g16FF   LDA (PBase),Y  ;Subroutine high address
        STA scratch2c+1
        INY 
        BNE g1708
        INC PBase+1
g1708   LDA (PBase),Y  ;Number of parameters
        TAX 
        INY 
        BNE g1710
        INC PBase+1
g1710   TYA 
        CLC 
        ADC PBase      ;Skip parameter bytes in prep for return
        STA PBase
        BCC g171A
        INC PBase+1
g171A   TXA 
        TAY 
        JSR Pjmp     ;Target contains a 4c, JMP
        CLD 
        LDY #$00     ;Ensure a sane state
        JMP Pnext

Pend    LDY #$00
        JSR EXIT

Pwherew TYA 
        CLC 
        ADC PBase
        PHA 
        LDA PBase+1
        ADC #$00
        PHA 
        JMP Pnext

pr1737  STY ysav
        LDY #$00
        TSX 
        LDA cpustk+6,X
        STA scratch2c
        LDA cpustk+5,X
        STA scratch2c+1
        LDA (scratch2c),Y
        CMP cpustk+4,X
        INY 
        LDA (scratch2c),Y
        SBC cpustk+3,X
        BCS g1771
        DEY 
        LDA (scratch2c),Y
        ADC #$01
        STA (scratch2c),Y
        BCC g1764
        INY 
        LDA (scratch2c),Y
        ADC #$00
        STA (scratch2c),Y
        DEY 
g1764   LDA cpustk+2,X
        STA PBase
        LDA cpustk+1,X
        STA PBase+1
        JMP Pnext

g1771   TXA 
        CLC 
        ADC #$06
        TAX 
        TXS 
        LDY ysav
        JMP Pnext

Pdupw   TSX 
        LDA cpustk+2,X
        PHA 
        LDA cpustk+1,X
        PHA 
        JMP Pnext

Prolw   TSX 
        ASL cpustk+2,X
        ROL cpustk+1,X
        JMP Pnext

Pswapb  TSX 
        LDA cpustk+1,X
        PHA 
        LDA cpustk+2,X
        STA cpustk+1,X
        LDA #$00
        STA cpustk+2,X
        JMP Pnext

Ppopw   PLA 
Ppopb1  PLA 
        JMP Pnext

Ppopr   TSX 
        TXA 
        CLC 
        ADC #$06
        TAX 
        TXS 
        JMP Pnext

Mul16   LDX #$11     ;Multiply two 16 bit values at $3c and $3e, leaving result at $3c
        LDA #$00
        STA z40
        CLC 
g17BB   ROR 
        ROR z40
        ROR z3D
        ROR z3C
        DEX 
        BEQ g17D7
        BCC g17BB
        STA z41
        LDA z40
        CLC 
        ADC z3E
        STA z40
        LDA z41
        ADC z3F
        JMP g17BB

g17D7   STA z41
        RTS 

Div32   STX xsav2
        LDA z3C
        ORA z3D
        BNE g17E6
        JMP e0div

g17E6   LDX #$11
        LDA #$00
        STA z41
        CLC 
        BCC g1808
g17EF   ROL 
        ROL z41
        SEC 
        SBC z3C
        STA z40
        LDA z41
        SBC z3D
        BCS g1804
        LDA z40
        ADC z3C
        CLC 
        BCC g1808
g1804   STA z41
        LDA z40
g1808   ROL z3E
        ROL z3F
        DEX 
        BNE g17EF
        LDX xsav2
        STA z40
        RTS 
