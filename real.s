
;
; PROMAL for the Commodore 64
; Copyright (C) 1985, SMA, Inc.
; Re-source (C) 2015 jbevren
;

; Real (floating point) math routines for PROMAL

; version 
; status: 

floatstart = *


;Floating point register a (wrong-endian)
rFPrega =$57            ; 57
rFPsa   =rFPrega        ; 57
rFPea   =rFPsa+1        ; 58
rFPm4a  =rFPea+1        ; 59
rFPm3a  =rFPm4a+1       ; 5a
rFPm2a  =rFPm3a+1       ; 5b
rFPm1a  =rFPm2a+1       ; 5c
rFPm0a  =rFPm1a+1       ; 5d
rFPoa   =rFPm0a+1       ; 5e
;Floating point register b (wrong-endian)
rFPregb =$5f            ; 5f
rFPsb   =rFPregb        ; 5f
rFPeb   =rFPsb+1        ; 60
rFPm4b  =rFPeb+1        ; 61
rFPm3b  =rFPm4b+1       ; 62
rFPm2b  =rFPm3b+1       ; 63
rFPm1b  =rFPm2b+1       ; 64
rFPm0b  =rFPm1b+1       ; 65
rFPob   =rFPm0b+1       ; 66



p4364   .BYTE $00
p4365   .BYTE $00
p4366   .BYTE $00
p4367   .BYTE $00
p4368   .BYTE $00
p4369   .BYTE $00
p436A   .BYTE $00
p436B   .BYTE $00
l436C   .BYTE $30
l436D   .BYTE $30,$30,$30,$30,$30,$30,$30,$30
        .BYTE $30,$30,$30,$30,$30,$30,$30,$30
rSwpReg STY p4368
        LDX #$07
g4382   LDA rFPrega,X
        LDY rFPregb,X
        STY rFPrega,X
        STA rFPregb,X
        DEX 
        BPL g4382
        LDY p4368
        RTS 

raddM   CLC 
        LDA rFPoa
        ADC rFPob
        STA rFPoa
s4398   LDA rFPm0a
        ADC rFPm0b
        STA rFPm0a
        LDA rFPm1a
        ADC rFPm1b
        STA rFPm1a
        LDA rFPm2a
        ADC rFPm2b
        STA rFPm2a
        LDA rFPm3a
        ADC rFPm3b
        STA rFPm3a
        LDA rFPm4a
        ADC rFPm4b
        STA rFPm4a
        RTS 

rsubM   SEC 
        LDA rFPoa
        SBC rFPob
        STA rFPoa
        LDA rFPm0a
        SBC rFPm0b
        STA rFPm0a
        LDA rFPm1a
        SBC rFPm1b
        STA rFPm1a
        LDA rFPm2a
        SBC rFPm2b
        STA rFPm2a
        LDA rFPm3a
        SBC rFPm3b
        STA rFPm3a
        LDA rFPm4a
        SBC rFPm4b
        STA rFPm4a
        RTS 

rsub    LDA #$80
        EOR rFPsb
        STA rFPsb
radd    CLD 
        LDA rFPeb
        BNE g43E9
        RTS 

g43E9   LDA rFPea
        BNE g43F7
        LDX #$07
g43EF   LDA rFPregb,X
        STA rFPrega,X
        DEX 
        BPL g43EF
        RTS 

g43F7   SEC 
        SBC rFPeb
        BCC g4424
        BNE g4433
        LDA rFPm4a
        CMP rFPm4b
        BCC g4424
        BNE g446A
        LDA rFPm3a
        CMP rFPm3b
        BCC g4424
        BNE g446A
        LDA rFPm2a
        CMP rFPm2b
        BCC g4424
        BNE g446A
        LDA rFPm1a
        CMP rFPm1b
        BCC g4424
        BNE g446A
        LDA rFPm0a
        CMP rFPm0b
        BCS g446A
g4424   JSR rSwpReg
        LDA rFPea
        SEC 
        SBC rFPeb
        BEQ g446A
        CMP #$2A
        BCC g4433
        RTS 

g4433   TAX 
        BEQ g446A
        CPX #$08
        BCC g4458
        LDX rFPm0b
        STX rFPob
        LDX rFPm1b
        STX rFPm0b
        LDX rFPm2b
        STX rFPm1b
        LDX rFPm3b
        STX rFPm2b
        LDX rFPm4b
        STX rFPm3b
        LDX #$00
        STX rFPm4b
        SEC 
        SBC #$08
        JMP g4433

g4458   LDA rFPm4b
g445A   LSR 
        ROR rFPm3b
        ROR rFPm2b
        ROR rFPm1b
        ROR rFPm0b
        ROR rFPob
        DEX 
        BNE g445A
        STA rFPm4b
g446A   LDA rFPsa
        EOR rFPsb
        BMI g4488
        JSR raddM
        BCC g44A1
        ROR rFPm4a
        ROR rFPm3a
        ROR rFPm2a
        ROR rFPm1a
        ROR rFPm0a
        ROR rFPoa
        INC rFPea
        BNE g44A1
        JMP j1068

g4488   JSR rsubM
        BNE g44A3
        LDA rFPm3a
        BNE g44A1
        LDA rFPm2a
        BNE g44A1
        LDA rFPm1a
        BNE g44A1
        LDA rFPm0a
        BNE g44A1
        LDA rFPoa
        BEQ g44EC
g44A1   LDA rFPm4a
g44A3   BMI g44B8
g44A5   DEC rFPea
        BEQ rClrFP1
        ASL rFPoa
        ROL rFPm0a
        ROL rFPm1a
        ROL rFPm2a
        ROL rFPm3a
        ROL 
        BPL g44A5
        STA rFPm4a
g44B8   LDX #$00
        LDA rFPoa
        STX rFPoa
        BPL g44DF
        INC rFPm0a
        BNE g44DF
        INC rFPm1a
        BNE g44DF
        INC rFPm2a
        BNE g44DF
        INC rFPm3a
        BNE g44DF
        INC rFPm4a
        BNE g44DF
        INC rFPea
        BNE g44DB
        JMP j1068

g44DB   LDA #$80
        STA rFPm4a
g44DF   RTS 

rClrFP1 LDA #$00
        STA rFPm4a
        STA rFPm3a
        STA rFPm2a
        STA rFPm1a
        STA rFPm0a
g44EC   STA rFPea
        STA rFPsa
        RTS 

rmul    LDA rFPea
        BEQ rClrFP1
        LDA rFPeb
        BEQ rClrFP1
        TYA 
        PHA 
        LDY #$00
        LDX #$05
g44FF   LDA rFPm4b,X
        BNE g4504
        INY 
g4504   DEX 
        BPL g44FF
        STY p4368
        LDY #$00
        LDX #$05
g450E   LDA rFPm4a,X
        BNE g4513
        INY 
g4513   DEX 
        BPL g450E
        CPY p4368
        BCS g451E
        JSR rSwpReg
g451E   PLA 
        TAY 
        LDA rFPea
        SEC 
        SBC #$7F
        STA rFPea
        LDA rFPeb
        SEC 
        SBC #$7F
        CLC 
        ADC rFPea
        BVC g4536
        BPL rClrFP1
        JMP j1068

g4536   CLC 
        ADC #$7F
        STA rFPea
        LDA rFPsa
        EOR rFPsb
        STA rFPsa
        LDX rFPm0a
        STX z6B
        LDX rFPm1a
        STX z6A
        LDX rFPm2a
        STX z69
        LDX rFPm3a
        STX z68
        LDX rFPm4a
        STX z67
        LDX #$00
        STX rFPm4a
        STX rFPm3a
        STX rFPm2a
        STX rFPm1a
        STX rFPm0a
        STX rFPoa
        STY p4368
        LDY #$04
        CLC 
g4569   LDA z67,Y
        BNE g4576
        DEY 
        BPL g4569
        BMI g4593
g4573   LDA z67,Y
g4576   LDX #$08
g4578   ROR rFPm4a
        ROR rFPm3a
        ROR rFPm2a
        ROR rFPm1a
        ROR rFPm0a
        ROR rFPoa
        ROR 
        BCC g458D
        PHA 
        CLC 
        JSR s4398
        PLA 
g458D   DEX 
        BNE g4578
        DEY 
        BPL g4573
g4593   LDY p4368
        BCC g45AB
        ROR rFPm4a
        ROR rFPm3a
        ROR rFPm2a
        ROR rFPm1a
        ROR rFPm0a
        ROR rFPoa
        INC rFPea
        BNE g45AB
        JMP j1068

g45AB   JMP g44B8

rdiv    LDA rFPeb
        BEQ g45C8
        SEC 
        SBC #$7F
        STA z67
        LDA rFPea
        BNE g45BE
g45BB   JMP rClrFP1

g45BE   SEC 
        SBC #$7F
        SEC 
        SBC z67
        BVC g45CB
        BPL g45BB
g45C8   JMP j1068

g45CB   CLC 
        ADC #$7F
        BEQ g45BB
        STA rFPea
        LDA rFPsa
        EOR rFPsb
        STA rFPsa
        LDA #$00
        STA z67
        STA z68
        STA z69
        STA z6A
        STA z6B
        STA z6C
        LSR rFPm4a
        ROR rFPm3a
        ROR rFPm2a
        ROR rFPm1a
        ROR rFPm0a
        ROR rFPoa
        LSR rFPm4b
        ROR rFPm3b
        ROR rFPm2b
        ROR rFPm1b
        ROR rFPm0b
        ROR rFPob
        LDX #$28
g4600   LDA rFPm4a
        CMP rFPm4b
        BCC g4631
        BNE g462E
        LDA rFPm3a
        CMP rFPm3b
        BCC g4631
        BNE g462E
        LDA rFPm2a
        CMP rFPm2b
        BCC g4631
        BNE g462E
        LDA rFPm1a
        CMP rFPm1b
        BCC g4631
        BNE g462E
        LDA rFPm0a
        CMP rFPm0b
        BCC g4631
        BNE g462E
        LDA rFPoa
        CMP rFPob
        BCC g4631
g462E   JSR rsubM
g4631   ROL z6B
        ROL z6A
        ROL z69
        ROL z68
        ROL z67
        ASL rFPoa
        ROL rFPm0a
        ROL rFPm1a
        ROL rFPm2a
        ROL rFPm3a
        ROL rFPm4a
        DEX 
        BNE g4600
        LDA z67
        STA rFPm4a
        LDA z68
        STA rFPm3a
        LDA z69
        STA rFPm2a
        LDA z6A
        STA rFPm1a
        LDA z6B
        STA rFPm0a
        LDA #$00
        STA rFPoa
        JMP g44A1

rCp12   LDX #$07
g4667   LDA rFPrega,X
        STA rFPregb,X
        DEX 
        BPL g4667
        RTS 

ri2r    STX rFPm4a
        STA rFPm3a
        CPX #$00
        BPL g468C
        LDA #$00
        SEC 
        SBC rFPm3a
        STA rFPm3a
        LDA #$00
        SBC rFPm4a
        STA rFPm4a
        LDA #$80
        BNE g468E
rw2r    STX rFPm4a
        STA rFPm3a
g468C   LDA #$00
g468E   STA rFPsa
        LDA #$00
        STA rFPm2a
        STA rFPm1a
        STA rFPm0a
        STA rFPoa
        LDA #$8E
        STA rFPea
        JMP g44A1

rr2w    LDA rFPea
        SEC 
        SBC #$7F
        STA rFPea
        BCS g46AE
        LDA #$00
        TAX 
        RTS 

g46AE   CMP #$0F
        BCC g46BB
        BNE g46B8
        BIT rFPsa
        BPL g46DE
g46B8   JMP j1068

g46BB   LDA #$0F
        SEC 
        SBC rFPea
        TAX 
        BEQ g46DE
        LDA rFPm4a
g46C5   LSR 
        ROR rFPm3a
        DEX 
        BNE g46C5
        BIT rFPsa
        BPL g46DC
        STA rFPm4a
        LDA #$00
        SEC 
        SBC rFPm3a
        STA rFPm3a
        LDA #$00
        SBC rFPm4a
g46DC   STA rFPm4a
g46DE   LDX rFPm4a
        LDA rFPm3a
        RTS 

absz    PLA 
        STA z3A
        PLA 
        STA z3B
        CPY #$01
        BEQ g46F0
        JMP esys

g46F0   PLA 
        PLA 
        TAX 
        LDA fpstack,X
        AND #$7F
        STA fpstack,X
        TXA 
        JMP retbyte

rstrreal LDA #$00
        STA p4366
        STA p4364
        STA p4365
        STA z6E
        JSR rClrFP1
        DEY 
g4710   INY 
        LDA (z34),Y
        CMP #$20
        BEQ g4710
        CMP #$2B
        BEQ g4722
        CMP #$2D
        BNE g4723
        ROR p4364
g4722   INY 
g4723   LDA (z34),Y
        CMP #$3A
        BCS g473F
        CMP #$30
        BCC g473F
        SBC #$30
        JSR s47B9
        DEC p4366
        BIT p4365
        BPL g4722
        DEC z6E
        JMP g4722

g473F   CMP #$2E
        BNE g474B
        ROR p4365
        BIT p4365
        BVC g4722
g474B   JSR s4799
        ASL p4364
        ROR rFPsa
        LDA (z34),Y
        CMP #$65
        BEQ g475D
        CMP #$45
        BNE g47AE
g475D   INY 
        LDA (z34),Y
        CMP #$2B
        BEQ g476B
        CMP #$2D
        BNE g476E
        ROR p4364
g476B   INY 
        LDA (z34),Y
g476E   SEC 
        SBC #$30
        BCC g47AE
        CMP #$0A
        BCS g47AE
        STA z6E
        INY 
        LDA (z34),Y
        SEC 
        SBC #$30
        BCC g478D
        CMP #$0A
        BCS g478D
        LDX z6E
        ADC l47AF,X
        STA z6E
        INY 
g478D   BIT p4364
        BPL s4799
        LDA #$00
        SEC 
        SBC z6E
        STA z6E
s4799   LDA z6E
        BEQ g47AE
        BMI g47A7
        JSR rMul10
        DEC z6E
        JMP s4799

g47A7   JSR RDiv10
        INC z6E
        BNE g47A7
g47AE   RTS 
l47AF   .BYTE 0,10,20,30,40,50,60,70,80,90

s47B9   PHA 
        JSR rMul10
        JSR rCp12
        PLA 
        LDX #$00
        JSR rw2r
        JMP radd

rMul10  JSR rSet210
        JMP rmul

RDiv10  JSR rSet210
        JMP rdiv

rSet210 LDA #$00
        STA rFPsb
        LDA #$82
        STA rFPeb
        LDA #$A0
        STA rFPm4b
        LDA #$00
        STA rFPm3b
        STA rFPm2b
        STA rFPm1b
        STA rFPm0b
        STA rFPob
        RTS 

strrealz JSR getprm
        .BYTE $22,$C0,$2C,$34
        LDY #$00
        JSR rstrreal
        TYA 
        PHA 
        LDA rFPm4a
        ASL 
        ASL rFPsa
        ROR rFPea
        ROR 
        LDY #$01
        STA (z2C),Y
        INY 
        LDA rFPm3a
        STA (z2C),Y
        INY 
        LDA rFPm2a
        STA (z2C),Y
        INY 
        LDA rFPm1a
        STA (z2C),Y
        INY 
        LDA rFPm0a
        STA (z2C),Y
        LDY #$00
        LDA rFPea
        STA (z2C),Y
        JMP return

realstrz PLA 
        STA z3A
        PLA 
        STA z3B
        LDA #$FF
        CPY #$04
        BNE g4834
        DEY 
        PLA 
        PLA 
g4834   STA p4362
        LDA #$00
        CPY #$03
        BNE g4840
        DEY 
        PLA 
        PLA 
g4840   TAX 
        DEX 
        STX p4363
        CPY #$02
        BEQ g484C
        JMP esys

g484C   PLA 
        STA z2D
        PLA 
        STA z2C
        PLA 
        PLA 
        JSR rpull1
        JSR s4861
        LDA #$00
        STA (z2C),Y
        JMP return

s4861   LDA fltptr
        BEQ g486A
        SEC 
        SBC #$06
        STA fltptr
g486A   LDA #$00
        STA z6E
j486E   LDA rFPea
        BNE g4883
        STA z67
        STA z68
        STA z69
        STA z6A
        STA z6B
        STA z6C
        STA z6D
        JMP j48DD

g4883   CMP #$A6
        BEQ g48BA
        BCC g4891
        JSR RDiv10
        INC z6E
        JMP j486E

g4891   JSR rMul10
        DEC z6E
        LDA rFPea
        CMP #$A6
        BEQ g48BA
        BCC g4891
        JSR RDiv10
        INC z6E
j48A3   LDA rFPea
        CMP #$A6
        BEQ g48BA
        LSR rFPm4a
        ROR rFPm3a
        ROR rFPm2a
        ROR rFPm1a
        ROR rFPm0a
        ROR rFPoa
        INC rFPea
        JMP j48A3

g48BA   LDA rFPoa
        BPL g48D0
        INC rFPm0a
        BNE g48D0
        INC rFPm1a
        BNE g48D0
        INC rFPm2a
        BNE g48D0
        INC rFPm3a
        BNE g48D0
        INC rFPm4a
g48D0   JSR s4906
        LDA z6E
        CLC 
        ADC #$0C
        STA z6E
        JSR s4930
j48DD   LDA p4363
        BPL g48E5
        JSR s4AC6
g48E5   LDA p4362
        CMP #$0B
        BCS g48FE
        JSR s4A0C
        LDY #$01
        LDA (z2C),Y
        CMP #$2A
        BNE g4901
        LDY p4363
        CPY #$06
        BCC g4901
g48FE   JSR s4A67
g4901   LDY p4363
        INY 
        RTS 

s4906   TYA 
        PHA 
        LDA #$00
        LDX #$06
g490C   STA z67,X
        DEX 
        BPL g490C
        LDY #$28
        SED 
g4914   ASL rFPm0a
        ROL rFPm1a
        ROL rFPm2a
        ROL rFPm3a
        ROL rFPm4a
        LDX #$06
g4920   LDA z67,X
        ADC z67,X
        STA z67,X
        DEX 
        BPL g4920
        DEY 
        BNE g4914
        CLD 
        PLA 
        TAY 
        RTS 

s4930   LDA z67
        AND #$F0
        BEQ g494C
        LDX #$04
g4938   LSR 
        ROR z68
        ROR z69
        ROR z6A
        ROR z6B
        ROR z6C
        ROR z6D
        DEX 
        BNE g4938
        STA z67
        INC z6E
g494C   LDA z67
        BNE g4966
        LDX #$04
g4952   ASL z6D
        ROL z6C
        ROL z6B
        ROL z6A
        ROL z69
        ROL z68
        ROL 
        DEX 
        BNE g4952
        STA z67
        DEC z6E
g4966   RTS 

s4967   LDX #$00
        LDY #$00
g496B   LDA z67,X
        AND #$0F
        CLC 
        ADC #$30
        STA l436C,Y
        INY 
        INX 
        LDA z67,X
        LSR 
        LSR 
        LSR 
        LSR 
        CLC 
        ADC #$30
        STA l436C,Y
        INY 
        CPY #$0C
        BCC g496B
        RTS 

s4989   LDA #$05
        CLC 
g498C   ADC l436C,X
        CMP #$3A
        BCC g4995
        LDA #$30
g4995   STA l436C,X
        LDA #$00
        DEX 
        BPL g498C
        BCC g49B0
        LDX #$0A
g49A1   LDA l436C,X
        STA l436D,X
        DEX 
        BPL g49A1
        LDA #$31
        STA l436C
        SEC 
g49B0   RTS 

s49B1   LDY p4363
        LDA #$30
        DEX 
        BMI g49BC
g49B9   LDA l436C,X
g49BC   CPY p4369
        BNE g49C8
        PHA 
        LDA #$2E
        STA (z2C),Y
        PLA 
        DEY 
g49C8   STA (z2C),Y
        DEY 
        BMI g49D4
        DEX 
        BPL g49B9
        LDA #$30
        BNE g49BC
g49D4   INY 
        DEX 
        BPL g49DE
        LDA (z2C),Y
        CMP #$30
        BEQ g49F0
g49DE   LDA #$2A
        CPY p4369
        BNE g49E6
        INY 
g49E6   STA (z2C),Y
        INY 
        CPY p4363
        BCC g49DE
        BEQ g49DE
g49F0   LDY #$00
        LDA #$20
        STA (z2C),Y
        INY 
g49F7   LDA (z2C),Y
        CMP #$30
        BNE g4A0B
        INY 
        CPY p4363
        BCS g4A0B
        DEY 
        LDA #$20
        STA (z2C),Y
        INY 
        BNE g49F7
g4A0B   RTS 

s4A0C   CLC 
s4A0D   ROR p4367
        JSR s4967
        LDY p4363
        CPY #$0C
        BCS g4A1E
        CPY #$02
        BCS g4A21
g4A1E   JMP elibarg

g4A21   TYA 
        SEC 
        SBC p4362
        STA p4369
        LDA z6E
        SEC 
        ADC p4362
        CMP #$0C
        BMI g4A35
        LDA #$0C
g4A35   STA p436A
        TAX 
        BMI g4A4E
        JSR s4989
        BCC g4A4E
        BIT p4367
        BMI g4A4B
        INC p436A
        JMP g4A4E

g4A4B   INC p436B
g4A4E   LDX p436A
        JSR s49B1
        LDY #$00
g4A56   INY 
        LDA (z2C),Y
        CMP #$20
        BEQ g4A56
        DEY 
        LDA #$2D
        BIT rFPsa
        BPL g4A66
        STA (z2C),Y
g4A66   RTS 

s4A67   LDA p4363
        SEC 
        SBC #$04
        STA p4363
        LDA z6E
        STA p436B
        LDA #$00
        STA z6E
        LDA p4363
        SEC 
        SBC #$02
        STA p4362
        SEC 
        JSR s4A0D
        LDY p4363
        INY 
        LDA #$45
        STA (z2C),Y
        INY 
        LDA #$2B
        BIT p436B
        BPL g4AA1
        LDA #$00
        SEC 
        SBC p436B
        STA p436B
        LDA #$2D
g4AA1   STA (z2C),Y
        INY 
        LDX #$00
        LDA p436B
        SEC 
g4AAA   SBC #$0A
        BCC g4AB1
        INX 
        BNE g4AAA
g4AB1   ADC #$0A
        PHA 
        TXA 
        CLC 
        ADC #$30
        STA (z2C),Y
        INY 
        PLA 
        CLC 
        ADC #$30
        STA (z2C),Y
        STY p4363
        INY 
        RTS 

s4AC6   LDA #$0B
        STA p4363
        LDA z6E
        CLC 
        ADC #$07
        BMI g4ADD
        CMP #$0E
        BCS g4ADD
        TAX 
        LDA l4AE3,X
        JMP j4ADF

g4ADD   LDA #$FF
j4ADF   STA p4362
        RTS 

l4AE3   .BYTE $09,$09,$09,$09,$09,$09,$09,$09
        .BYTE $08,$07,$06,$05,$04,$03

PPreal  LDA fltptr
        PHA 
        TAX 
        CLC 
        ADC #$06
        STA fltptr
g4AFA   LDA (PBase),Y
        STA fpstack,X
        INY 
        BNE g4B04
        INC PBase+1
g4B04   INX 
        CPX fltptr
        BCC g4AFA
        JMP Pnext

PpeekR  LDA (PBase),Y
        STA z2C
        INY 
        BNE g4B15
        INC PBase+1
g4B15   LDA (PBase),Y
        STA z2D
j4B19   STY ysav
        LDY #$00
        LDA fltptr
        PHA 
        TAX 
        CLC 
        ADC #$06
        STA fltptr
        LDA (z2C),Y
        STA fpstack,X
        INY 
        LDA (z2C),Y
        STA fpstack+1,X
        INY 
        LDA (z2C),Y
        STA fpstack+2,X
        INY 
        LDA (z2C),Y
        STA fpstack+3,X
        INY 
        LDA (z2C),Y
        STA fpstack+4,X
        INY 
        LDA (z2C),Y
        STA fpstack+5,X
        LDY ysav
        JMP Pskip

Pc3C    LDA (PBase),Y
        STY ysav
        TAY 
        LDA (z30),Y
        PHA 
        LDA #$08
        LDY ysav
        JMP PnextP

Pc44    LDA (PBase),Y
        STY ysav
        TAY 
        LDA (z30),Y
        TAY 
        LDA fltptr
        PHA 
        TAX 
        CLC 
        ADC #$06
        STA fltptr
g4B6E   LDA fpstack,Y
        STA fpstack,X
        INY 
        INX 
        CPX fltptr
        BCC g4B6E
        LDY ysav
        JMP Pskip

Pc0E    PLA 
        TAX 
        PLA 
        JSR s4B88
        JMP j4B19

s4B88   STX z2D
        ASL 
        ROL z2D
        STA z2C
        STA z38
        LDA z2D
        STA z39
        ASL z38
        ROL 
        STA z39
        LDA z38
        CLC 
        ADC z2C
        STA z38
        LDA z39
        ADC z2D
        STA z39
        LDA (PBase),Y
        INY 
        BNE g4BAE
        INC PBase+1
g4BAE   CLC 
        ADC z38
        STA z2C
        LDA (PBase),Y
        ADC z39
        STA z2D
        RTS 

Pc20    PLA 
        TAX 
        PLA 
        JSR s4B88
        LDA z2C
        PHA 
        LDA z2D
        JMP PnextP

PcF4    PLA 
        STA z2D
        PLA 
        STA z2C
        CPY #$00
        BNE g4BD4
        DEC PBase+1
g4BD4   DEY 
        JMP j4B19

PpokeR  LDA (PBase),Y
        STA z2C
        INY 
        BNE g4BE1
        INC PBase+1
g4BE1   LDA (PBase),Y
        STA z2D
        STY ysav
        LDY #$00
        PLA 
        STA fltptr
        TAX 
g4BED   LDA fpstack,X
        STA (z2C),Y
        INX 
        INY 
        CPY #$06
        BCC g4BED
        LDY ysav
        JMP Pskip

Pc52    PLA 
        PHA 
        TAX 
        LDA (PBase),Y
        STY ysav
        TAY 
        LDA (z30),Y
        TAY 
g4C08   LDA fpstack,X
        STA fpstack,Y
        INY 
        INX 
        CPX fltptr
        BCC g4C08
        PLA 
        STA fltptr
        LDY ysav
        JMP Pskip

Pc1A    PLA 
        STA fltptr
        PLA 
        TAX 
        PLA 
        JSR s4B88
        STY ysav
        LDY #$00
        LDX fltptr
g4C2B   LDA fpstack,X
        STA (z2C),Y
        INX 
        INY 
        CPY #$06
        BCC g4C2B
        LDY ysav
        JMP Pskip

Paddr   PLA 
        TAX 
        PLA 
        JSR rpull2
        JSR radd

rpush   LDX fltptr
        LDA rFPm4a
        ASL 
        ASL rFPsa
        ROR rFPea
        ROR 
        STA fpstack+1,X
        LDA rFPea
        STA fpstack,X
        LDA rFPm3a
        STA fpstack+2,X
        LDA rFPm2a
        STA fpstack+3,X
        LDA rFPm1a
        STA fpstack+4,X
        LDA rFPm0a
        STA fpstack+5,X
        TXA 
        PHA 
        CLC 
        ADC #$06
        STA fltptr
        JMP Pnext

rpull2  PHA 
        LDA fpstack+5,X
        STA rFPm0b
        LDA fpstack+4,X
        STA rFPm1b
        LDA fpstack+3,X
        STA rFPm2b
        LDA fpstack+2,X
        STA rFPm3b
        LDA fpstack+1,X
        STA rFPm4b
        LDA fpstack,X
        ASL rFPm4b
        ROL 
        STA rFPeb
        ROR rFPsb
        SEC 
        ROR rFPm4b
        LDA #$00
        STA rFPob
        PLA 
rpull1a STA fltptr
rpull1  TAX 
        LDA fpstack+5,X
        STA rFPm0a
        LDA fpstack+4,X
        STA rFPm1a
        LDA fpstack+3,X
        STA rFPm2a
        LDA fpstack+2,X
        STA rFPm3a
        LDA fpstack+1,X
        STA rFPm4a
        LDA fpstack,X
        ASL rFPm4a
        ROL 
        STA rFPea
        ROR rFPsa
        SEC 
        ROR rFPm4a
        LDA #$00
        STA rFPoa
        RTS 

Psubr   PLA 
        TAX 
        PLA 
        JSR rpull2
        JSR rsub
        JMP rpush

Pmulr   PLA 
        TAX 
        PLA 
        JSR rpull2
        JSR rmul
        JMP rpush

Pdivr   PLA 
        TAX 
        PLA 
        JSR rpull2
        JSR rdiv
        JMP rpush

PcA0    PLA 
        TAX 
        LDA fpstack,X
        ORA fpstack+1,X
        BEQ g4D04
        LDA fpstack,X
        EOR #$80
        STA fpstack,X
g4D04   TXA 
        PHA 
        JMP Pnext

Pi2r    PLA 
        TAX 
        PLA 
        JSR ri2r
        JMP rpush

Pb2r    LDA #$00
        PHA 

Pw2r    PLA 
        TAX 
        PLA 
        JSR rw2r
        JMP rpush

PcDE    PLA 
        PHA 
        TAX 
g4D21   LDA fpstack,X
        STA fpstack+6,X
        INX 
        CPX fltptr
        BCC g4D21
        PLA 
        STA fltptr
        PLA 
        TAX 
j4D31   PLA 
        JSR rw2r
j4D35   LDX fltptr
        LDA rFPm4a
        ASL 
        ASL rFPsa
        ROR rFPea
        ROR 
        STA fpstack+1,X
        LDA rFPea
        STA fpstack,X
        LDA rFPm3a
        STA fpstack+2,X
        LDA rFPm2a
        STA fpstack+3,X
        LDA rFPm1a
        STA fpstack+4,X
        LDA rFPm0a
        STA fpstack+5,X
        TXA 
        PHA 
        CLC 
        ADC #$06
        PHA 
        CLC 
        ADC #$06
        STA fltptr
        JMP Pnext

PcDC    PLA 
        PHA 
        TAX 
g4D6C   LDA fpstack,X
        STA fpstack+6,X
        INX 
        CPX fltptr
        BCC g4D6C
        PLA 
        STA fltptr
        PLA 
        TAX 
        PLA 
        JSR ri2r
        JMP j4D35

PcDA    PLA 
        PHA 
        TAX 
g4D86   LDA fpstack,X
        STA fpstack+6,X
        INX 
        CPX fltptr
        BCC g4D86
        PLA 
        STA fltptr
        LDX #$00
        JMP j4D31

Pr2w    PLA ;ce
        JSR rpull1a
        JSR rr2w
        PHA 
        TXA 
        PHA 
        JMP Pnext

Pc4C    LDA (PBase),Y
        STY ysav
        TAY 
        LDA fltptr
        STA (z30),Y
        CLC 
        ADC #$06
        STA fltptr
        LDY ysav
        JMP Pskip

Pc58    LDA fltptr
        SEC 
        SBC (PBase),Y
        STA fltptr
        JMP Pskip

PcE4    LDX z30 ;e4
        LDA heap,X
        STA z30
        DEX 
        LDA heap,X
        STA PBase+1
        DEX 
        LDA heap,X
        STA PBase
        STX Heapptrq
        PLA 
        TAX 
        LDA fltptr
        PHA 
        TAY 
        CLC 
        ADC #$06
        STA fltptr
g4DE3   LDA fpstack,X
        STA fpstack,Y
        INY 
        INX 
        CPY fltptr
        BCC g4DE3
        LDY #$00
        JMP Pnext

PisLTr  PLA 
        PLA 
        JSR rcmp
        BEQ rfalse
g4DFB   BCC rtrue
        BCS rfalse

PisLEr  PLA 
        PLA 
        JSR rcmp
        BNE g4DFB
rtrue   LDA #$01
        PHA 
        JMP Pnext

PisNEr  PLA 
        PLA 
        JSR rcmp
        BNE rtrue
rfalse  LDA #$00
        PHA 
        JMP Pnext

PisEQr  PLA 
        PLA 
        JSR rcmp
        BEQ rtrue
        BNE rfalse

PisGEr  PLA 
        PLA 
        JSR rcmp
        BEQ rtrue
        BNE g4E32

PisGTr  PLA 
        PLA 
        JSR rcmp
        BEQ rfalse
g4E32   BCS rtrue
        BCC rfalse

rcmp    STA fltptr
        TAX 
        LDA fpstack,X
        EOR fpstack+6,X
        BPL g4E5C
        LDA fpstack+1,X
        ASL 
        LDA fpstack,X
        ROL 
        BNE g4E56
        LDA fpstack+7,X
        ASL 
        LDA fpstack+6,X
        ROL 
        BNE g4E56
        RTS 

g4E56   LDA fpstack+6,X
        SEC 
        ROL 
        RTS 

g4E5C   LDA fpstack,X
        BPL g4E6C
        JSR g4E6C
        BEQ g4E9A
        ROR 
        EOR #$80
        SEC 
        ROL 
        RTS 

g4E6C   LDA fpstack,X
        CMP fpstack+6,X
        BNE g4E9A
        LDA fpstack+1,X
        CMP fpstack+7,X
        BNE g4E9A
        LDA fpstack+2,X
        CMP fpstack+8,X
        BNE g4E9A
        LDA fpstack+3,X
        CMP fpstack+9,X
        BNE g4E9A
        LDA fpstack+4,X
        CMP fpstack+10,X
        BNE g4E9A
        LDA fpstack+5,X
        CMP fpstack+11,X
g4E9A   RTS 

