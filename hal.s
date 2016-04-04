
;
; PROMAL for the Commodore 64
; Copyright (C) 1985, SMA, Inc.
; Re-source (C) 2015 jbevren
;

; hardware abstraction layer and drivers for PROMAL

; version 0
; status: matches original

; defines for HAL:
Cblnktim=$CD

; initz sets this up as the irq routine after copying the default to $ca0
sysirq  CLD 
        LDY brkflag
        BNE dousrbrk
        LDA stopflag
        BMI contirq
        CMP #$7B     ;ctrl-stop pressed?
        BEQ ctrlbrk
        INC brkflag
ctrlbrk INC brkflag
        LDA #$32     ;push fake return address...
        PHA 
        LDA #$61     ;...to stall system until next irq
        PHA 
        PHP 
        PLA 
        AND #$FB     ;%1111 1101 = Clear irq flag for RTI
        PHA 
        PHA 
        PHA 
        PHA 
contirq JMP (dfltirq)

dousrbrk LDA stopflag
        BPL contirq
        PLA 
        PLA 
        PLA 
        PLA 
        PLA 
        PLA 
        LDY brkflag
        LDA #$00
        STA brkflag
        DEY 
        BNE contirq
        CLI 
        LDX #$01
        JSR hcleanup ;Close file ID 1
        JMP usrbrk

stallbrk JMP stallbrk

CkPETSCII PHA 
        LDA $D018    ;VIC Memory Control Register
        LSR 
        LSR 
        PLA 
        BCS ToLower
        RTS 

ToLower CMP #$41     ;'A'
        BCC g3278
        CMP #$5B     ;'['
        BCS hToUpper
        ORA #$20     ;to lower case
g3278   RTS 

hToUpper CMP #$61     ;'a'
        BCC g3283
        CMP #$7B     ;'{'
        BCS g3283
        AND #$DF     ;to upper case
g3283   RTS 

ToASCII CMP #$A0     ;Shift-space
        BNE g328A
        LDA #$20     ;' '
g328A   CMP #$C1     ;shift-A (PETSCII)
        BCC g3294
        CMP #$DB     ;Shift-[ (PETSCII)
        BCS g3294
        EOR #$A0     ;Flip 80+20 = cbm to ascii?
g3294   RTS 

s3295   PHA 
        LDX hfileN
        LDA kernST
        CLC 
        BEQ g32BD
        CMP #$40
        BNE g32AE
        LDA hFHeof,X
        BMI g32B8
        SEC 
        ROR hFHeof,X
        CLC 
        BCC g32BD
g32AE   LDA hFHeof,X
        BMI g32B8
        LDA #$02
        STA dioerr
g32B8   PLA 
        LDA #$00
        SEC 
        PHA 
g32BD   PLA 
        RTS 

IsCapLk JMP IsCpLk

IsCpLk  LDY crsrcol
j32C4   JSR GCurs
        CMP bkeyalk
        BNE g32D7
        LDA alphalk
        EOR #$80
        STA alphalk
        JMP j32C4

g32D7   BIT alphalk
        BPL g32DF
        JSR hToUpper
g32DF   RTS 

        LDY crsrcol
GCurs   LDA Cblnkrat
        BEQ g3325
        JSR StColrP
        LDA ccolor
        STA (zF3),Y
        LDA (zD1),Y
        PHA 
        EOR #$80
        STA (zD1),Y
        TYA 
        PHA 
j32F8   LDX Cblnkrat
        STX Cblnktim
g32FD   JSR hconin
        CMP #$00
        BNE g331D
        DEC p0CD3
        BNE g32FD
        BIT Cblnktim
        BMI g32FD
        DEC Cblnktim
        BNE g32FD
        PLA 
        PHA 
        TAY 
        LDA (zD1),Y
        EOR #$80
        STA (zD1),Y
        JMP j32F8

g331D   TAX 
        PLA 
        TAY 
        PLA 
        STA (zD1),Y
        TXA 
        RTS 

g3325   STY scrpos
g3328   JSR hconin
        BEQ g3328
        LDY scrpos
        RTS 

hconin  JSR $FFCC    ;ROM_CLRCHN - restore default devices          
        JSR $FFE4    ;ROM_GETIN  - get a byte from channel          
        JSR ToASCII
        JMP CkPETSCII

hgetin  STX hxsav1
        STY hysav1
        CPX #$F0
        BCC g334A
        JMP hspcFin

g334A   STX hfileN
        JSR $FFC6    ;ROM_CHKIN  - open channel for input           
        JSR $FFCF    ;ROM_CHRIN  - input character                  
        JSR s3295
        PHA 
        PHP 
        JSR $FFCC    ;ROM_CLRCHN - restore default devices          
        PLP 
        PLA 
        LDX hxsav1
        LDY hysav1
        RTS 

hspcFin STX hxsav
        STY hysav
        TXA 
        CLC 
        ADC #$10
        TAX 
        LDA l338C,X
        STA p338A
        LDA l338D,X
        STA p338B
        JSR s3389
        BCC g3382
        LDA #$00
g3382   LDY hysav
        LDX hxsav
        RTS 

p338A   =*+$01
p338B   =*+$02
s3389   JMP erun     ;selfmod

l338D	=*+1
l338C   
        .if pdrv	; just for completeness
	.WORD eredio	; $107D ; P is a device
	.else
	.WORD hredio	; $107D ; P is a disk file
	.fi ;pdrv
	.if tdrv
	.WORD hgetT	; $33FA ; T is a device
	.else
	.WORD hredio	; $107D ; T is a disk file
	.fi ;tdrv
	.if ldrv
	.WORD hReadL	; $33B1 ; L is a device
	.else
	.WORD hredio	; $107D ; L is a disk file
	.fi ;ldrv
	.if wdrv
	.WORD hReadW	; $33B5 ; W is a device
	.else
	.WORD hredio	; $107D ; W is a disk file
	.fi ;wdrv
	.WORD hretCS	; $33AD ; N device
	.WORD eredio	; $107D ; E device
	.WORD eredio	; $107D ; S device
	.WORD hkeyin	; $338C ; K device

hkeyin  JSR IsCapLk
        CMP #$1A
        BEQ hretCS
        PHA 
        JSR CkPETSCII
        JSR $FFD2    ;ROM_CHROUT - output character                 
        PLA 
        CLC 
        RTS 


hretCS  LDA #$00
        SEC 
        RTS 


	.if ldrv
hReadL  LDX #$08
        BNE g33B7
	.fi ;ldrv

	.if wdrv
hReadW  LDX #$00
g33B7   STY ysav1
        LDY #$00
        LDA z16
        PHA 
        LDA z17
        PHA 
        LDA wptr,X
        STA z16
        CMP weof,X
        LDA wptr+1,X
        STA z17
        SBC weof+1,X
        BCS g33EF
        PHP 
        SEI 
        LDA pport
        PHA 
        AND #$FC     ;All ram
        STA pport
        LDY #$00
        LDA (z16),Y
        TAY 
        PLA 
        STA pport
        PLP 
        INC wptr,X
        BNE g33EE
        INC wptr+1,X
g33EE   CLC 
g33EF   PLA 
        STA z17
        PLA 
        STA z16
        TYA 
        LDY ysav1
        RTS 
	.fi ;wdrv

	.if tdrv
hgetT   LDX #$02
        JSR $FFC6    ;ROM_CHKIN  - open channel for input           
g33FF   JSR hgTinST
        BCS g340A
        BEQ g33FF
g3406   LDA #$00
        BEQ g3430
g340A   JSR $FFE4    ;ROM_GETIN  - get a byte from channel          
        PHA 
        LDA htST
        ORA tdevst
        STA tdevst
        PLA 
        BIT tdevraw
        BMI g342F
        CMP teofch
        BEQ g3406
        CMP #$00
        BEQ g33FF
        CMP #$0A
        BNE g342F
        BIT tdevalf
        BVS g340A
g342F   CLC 
g3430   PHP 
        PHA 
        JSR $FFCC    ;ROM_CLRCHN - restore default devices          
        PLA 
        PLP 
        RTS 
	.fi ;tdrv

hputspc STA hasav    ;Handle special file for h.putf and h.putblkf?
        STX hxsav
        STY hysav
        TXA 
        CLC 
        ADC #$10
        TAX 
        LDA l346C,X
        STA z346A
        LDA l346D,X
        STA z346B
        LDA hasav
        JSR s3469
        BCC g345F
        LDA #$01
        STA dioerr
g345F   LDY hysav
        LDX hxsav
        LDA hasav
        RTS 

z346A   =*+$01
z346B   =*+$02
s3469   JMP erun     ;Selfmod code (set up at 3446,344c) boo

l346D	=*+1
l346C   
	.if pdrv
	.WORD hWriteP	; $351B ; P device
	.else
	.WORD eredio	; $107D ; P device
	.fi ;pdrv
	.if tdrv
	.WORD hWriteT	; $3532 ; T device
	.else
	.WORD eredio	; $107D ; T device
	.fi ;tdrv
	.if ldrv
	.WORD hWriteL	; $347C ; L device
	.else
	.WORD eredio	; $107D ; L device
	.fi ;ldrv
	.if wdrv
	.WORD hWriteW	; $3480 ; W device
	.else
	.WORD eredio	; $107D ; W device
	.fi ;wdrv
	.WORD hRetCC	; $3530 ; N device
	.WORD hPutScr	; $34EE ; E device
	.WORD hconout	; $34DD ; S device
	.WORD eredio	; $107D ; K device

; Referred to by table at 346c
hWriteL LDX #$08
        BNE g3482

; Referred to by table at 346c
hWriteW LDX #$00
g3482   STY ysav1
        TAY 
        LDA z16
        PHA 
        LDA z17
        PHA 
        LDA wptr,X
        STA z16
        CMP wlim,X
        LDA wptr+1,X
        STA z17
        SBC wlim+1,X
        BCS g34D3
        PHP 
        SEI 
        LDA pport
        PHA 
        AND #$FC     ;All ram
        STA pport
        TYA 
        LDY #$00
        STA (z16),Y
        PLA 
        STA pport
        PLP 
        INC wptr,X
        BNE g34B8
        INC wptr+1,X
g34B8   LDA wptr,X
        CMP weof,X
        LDA wptr+1,X
        SBC weof+1,X
        BCC g34D2
        LDA wptr,X
        STA weof,X
        LDA wptr+1,X
        STA weof+1,X
g34D2   CLC 
g34D3   PLA 
        STA z17
        PLA 
        STA z16
        LDY ysav1
        RTS 


; Referred to by table at 346c
hconout PHA 
        JSR $FFCC    ;ROM_CLRCHN - restore default devices          
        PLA 
        CMP #$0C
        BNE g34E8
        LDA #$93
g34E8   JSR CkPETSCII
        JMP $FFD2    ;ROM_CHROUT - output character                 


; Referred to by table at 346c
hputScr PHA 
        LDA $D011    ;VIC Control Register 1
        AND #$60
        BEQ g350D
        LDA #$1B
        STA $D011    ;VIC Control Register 1
        LDA #$17
        STA $D018    ;VIC Memory Control Register
        LDA #$C8
        STA $D016    ;VIC Control Register 2
        LDA $DD00    ;CIA2: Data Port Register A
        ORA #$03     ;Set vic bank to 0000-3fff
        STA $DD00    ;CIA2: Data Port Register A
g350D   LDA $D018    ;VIC Memory Control Register
        ROR 
        ROR 
        PLA 
        BCS hconout
        JSR hToUpper
        JMP hconout


; Referred to by table at 346c
hWriteP LDX #$03
        BIT c64pul   ;c64 printer case flip flag
        BPL g3525
        JSR CkPETSCII
g3525   PHA 
        JSR $FFC9    ;ROM_CHKOUT - open channel for output          
        PLA 
        JSR $FFD2    ;ROM_CHROUT - output character                 
        JSR $FFCC    ;ROM_CLRCHN - restore default devices          

; Referred to by table at 346c
hRetCC  CLC 
        RTS 


; Referred to by table at 346c
hWriteT LDX #$02
        PHA 
        JSR $FFC9    ;ROM_CHKOUT - open channel for output          
        PLA 
        BIT tdevraw
        BMI g354C
        CMP #$0D
        BNE g354C
        BIT tdevalf
        BPL g354C
        JSR $FFD2    ;ROM_CHROUT - output character                 
        LDA #$0A
g354C   JSR $FFD2    ;ROM_CHROUT - output character                 
        JSR $FFCC    ;ROM_CLRCHN - restore default devices          
        CLC 
        RTS 

hputf   CPX #$F0     ;special file?
        BCC g355B    ;no, process kernal file
        JMP hputspc

g355B   STX hfileN
        PHA 
        JSR $FFC9    ;ROM_CHKOUT - open channel for output          
        PLA 
        JSR $FFD2    ;ROM_CHROUT - output character                 
        JSR $FFCC    ;ROM_CLRCHN - restore default devices          
        LDX hfileN
        RTS 

hgetln  CMP #$50
        BCC g3573
        LDA #$50
g3573   LDX #$00
        STX EdlnMode ;Mode=0 (see edline in manual)
        STX p41E6    ;start with empty string
        LDX #<p41E6  ; address for buffer $E6
        LDY #>p41E6  ; $41
        JSR hedline  ;buffer: 41e6 (x/y); limit in .A
        LDX #<p41E6  ; address for buffer $E6
        LDY #>p41E6  ; $41
        RTS 

hgetlf  CMP #$7F
        BCC g358D
        LDA #$7F
g358D   STA hglflim
        LDY #$00
        CPX #$F0     ;stdin?
        BCC g3599
        JMP j35C6

g3599   JSR hgetin
        BCS g35B7
        CMP #$0D
        CLC 
        BEQ g35BC
        CPY hglflim
        BCS g35AE
        STA p41E6,Y
        INY 
        BCC g3599
g35AE   JSR hgetin
        BCS g35B7
        CMP #$0D
        BNE g35AE
g35B7   TYA 
        CLC 
        BNE g35BC
        SEC 
g35BC   LDA #$00
        STA p41E6,Y
        LDX #<p41E6 ;$E6
        LDY #>p41E6 ;$41
        RTS 

j35C6   CPX #$FE
        BNE g35CD
        JMP hgetln

g35CD   JSR hspcFin
        BCS g35B7
        STA p41E6,Y
        CMP #$0D
        CLC 
        BEQ g35BC
        CPY hglflim
        BCS g35CD
        INY 
        BCC g35CD
sendcmd LDA hSerID
        JSR $FFB1    ;ROM_LISTEN - make SERIAL device listen        
        LDA #$6F
        JSR $FF93    ;ROM_SECOND - send secondary addr after listen 
g35ED   LDA l3645,Y
        JSR $FFA8    ;ROM_CIOUT  - output byte to SERIAL            
        INY 
        DEX 
        BNE g35ED
        RTS 

prepsend JSR sendcmd
        JMP $FFAE    ;ROM_UNLSN  - unlisten all SERIAL devices      


; Send $fb bytes to drive:$0300
sendcode LDA drvcode
        STA z16
        LDA drvcode+1
        STA z17
        ORA z16
        BEQ g3643
        LDY #$00
g360E   STY z18
        LDX #$03
        LDY #$00
        JSR sendcmd  ;send M-W
        LDY z18
        TYA 
        JSR $FFA8    ;ROM_CIOUT  - output byte to SERIAL            
        LDA #$03
        JSR $FFA8    ;ROM_CIOUT  - output byte to SERIAL            
        LDA #$FB     ;Calculate remaining bytes to send...
        SEC 
        SBC z18
        CMP #$23
        BCC g362D
        LDA #$23     ; ...but only send $23 at a time.
g362D   TAX 
        JSR $FFA8    ;ROM_CIOUT  - output byte to SERIAL            
g3631   LDA (z16),Y  ;Read drive code
        JSR $FFA8    ;ROM_CIOUT  - output byte to SERIAL            
        INY 
        DEX 
        BNE g3631
        JSR $FFAE    ;ROM_UNLSN  - unlisten all SERIAL devices      
        CPY #$FB     ;Loop until $FB bytes are sent
        BCC g360E
        SEC 
        RTS 

g3643   CLC 
        RTS 


; Drive: M-W
l3645   .BYTE $4D,$2D,$57,$90,$00,$03
p364B   .BYTE $00
p364C   .BYTE $00

; 364e: drvcode: M-E 0300; 3653: M-E 0305; 3658: M-E 038d
drvcmds .BYTE $00,$4D,$2D,$45,$00,$03,$4D,$2D
        .BYTE $45,$50,$03,$4D,$2D,$45,$59,$03
hcpyFN  STA Szl
        LDY #$00
g3662   LDA FName,Y
        STA hFNam,Y
        BEQ g3674
        INY 
        CPY #$12
        BCC g3662
        LDA #$00
        STA hFNam,Y
g3674   RTS 

s3675   LDA hFNam    ;unit number?
        SEC 
        SBC #$30     ;'0'
        TAX 
        LDA c64ddv0,X ;Get hardwre ID for unit
        STA hSerID
        CPX #$01
        BNE g3690
        CMP c64ddv0
        BEQ g3690
        LDA #$30
        STA hFNam
g3690   RTS 

s3691   LDA hSerID
        AND #$01
        EOR #$FF
        SEC 
        ADC #$0F
        TAX 
        RTS 

chkdyno LDA c64n1541
        BNE g36A9
        LDA c64dyno
        CMP #$00
        BNE g36BB
g36A9   LDA DynoRdy
        BPL g36BA
        LDA #$00
        STA DynoRdy
        LDY #$13
        LDX #$05
        JSR prepsend
g36BA   CLC 
g36BB   RTS 

setTfnam LDA tstopb
        LSR 
        ROR 
        LDX tdatab
        ORA l36D7,X
        ORA tbaud
        STA hFNam
        LDX tparity
        LDA l36DB,X
        STA p0C6C
        RTS 

l36D7   .BYTE $10,$30,$50,$70
l36DB   .BYTE $00,$20,$60,$A0,$E0
setkrnnam TYA 
        LDX #$6B
        LDY #$0C
        JMP $FFBD    ;ROM_SETNAM - set file name                    

s36E8   JSR hcpyFN
        LDA #$00
        STA hfileN
        JSR s3675
        LDA p0C6D
        CMP #$23
        BNE g3704
        STA Szl
        STA hFNam
        LDY #$01
        BNE g3749
g3704   CMP #$25
        BNE g3711
        JSR chkdyno
        JSR s3691
        JMP j3799

g3711   CMP #$24
        BNE g372F
        LDX hFNam
        STA hFNam
        STX p0C6C
        LDA #$3A
        STA p0C6D
        LDA Szl
        CMP #$52
        BEQ g372F
        LDA #$01
        JMP j37B8

g372F   LDA #$2C
        STA hFNam,Y
        INY 
        LDA bfiltyp
        STA hFNam,Y
        INY 
        LDA #$2C
        STA hFNam,Y
        INY 
        LDA Szl
        STA hFNam,Y
        INY 
g3749   JSR hCkKfh
s374C   JSR setkrnnam
        TAY 
        LDA hfileN
        LDX hSerID
        TAY 
        CMP #$01
        BNE g375D
        LDY #$00
g375D   JSR $FFBA    ;ROM_SETLFS - set file parameters              
        JSR chkdyno
        BCC g3779
        LDA DynoRdy
        BMI g3772
        JSR sendcode
        BCC g3779
        ROR DynoRdy
g3772   LDY #$0E
        LDX #$05
        JSR prepsend
g3779   JSR $FFC0    ;ROM_OPEN   - open log.file after SETLFS,SETNAM
        BCS g379C
        LDA kernST
        BEQ g3786
        LDA #$04
        BNE g379C
g3786   LDX hSerID
        JSR s389D
        CMP #$00
        BNE g379C
        LDX hfileN
        LDA Szl
        STA hKFHmap,X
j3799   LDA #$00
        RTS 

g379C   LDX hfileN
        BEQ g37A6
        PHA 
        JSR hcleanup
        PLA 
g37A6   LDX #$0D
        STA p37BA
g37AB   CMP p37BA,X
        BEQ g37B5
        DEX 
        BNE g37AB
        BEQ j37B8
g37B5   LDA l37C8,X
j37B8   SEC 
        RTS 

p37BA   .BYTE $00,$01,$02,$04,$05,$1A,$1E,$21
        .BYTE $3E,$3F,$40,$46,$48,$4A
l37C8   .BYTE $00,$06,$05,$04,$03,$07,$02,$02
        .BYTE $04,$05,$04,$06,$06,$03
s37D6   STA Szl
        STX p0CBA
        LDA SFhand,X
        TAX 
        PHA 
        JSR hcleanup
        PLA 
        CMP #$F0     ;Printer?
        BEQ OpenP
        CMP #$F2     ;rs232?
        BNE OpenT
        JMP j383C

OpenT   LDX p0CBA
        CLC 
        RTS 

OpenP   LDY #$00     ;filename length=0
        JSR setkrnnam ;Set up filename from C6B, length=.Y
        LDX c64pdv   ;Get printer device
        LDY c64psa   ;Get printer secondary addr
        LDA #$03     ;kernal file number
        STA hfileN
j3805   STX hSerID
        JSR $FFBA    ;ROM_SETLFS - set file parameters              
        JSR $FFC0    ;ROM_OPEN   - open log.file after SETLFS,SETNAM
        BCC g382A
        CMP #$F0
        BNE g3825
        STA zA9
        LDX hfileN
        JSR $FFC6    ;ROM_CHKIN  - open channel for input           
        JSR $FFE4    ;ROM_GETIN  - get a byte from channel          
        JSR $FFCC    ;ROM_CLRCHN - restore default devices          
        JMP j382E

g3825   LDA #$05
        JMP g379C

g382A   LDA kernST
        BNE g3825
j382E   LDA Szl
        LDX hfileN
        STA hKFHmap,X
        LDX p0CBA
        CLC 
        RTS 

j383C   LDX #$02     ;kernal file number
        STX hfileN   ;save for later
        LDA #$00
        STA hFHeof,X
        LDA lofree  ;get start of free mem to allocate rs232 buffers
        LDY lofree+1
        STY p0CB8
        STA zF9      ;rs232 out buf
        STY zFA
        INY 
        STA zF7      ;rs232 in buf
        STY zF8
        INY 
        CPY hifree+1  ;out of memory?
        BCC g3860    ;no, we're ok
        BNE g3878    ;set carry and return error
g3860   STY lofree+1  ;allocate memory
        STY p0CB9
        JSR setTfnam ;build c64 kernal file name for rs232
        LDY #$02     ;name=2 chars
        JSR setkrnnam
        LDA hfileN   ;=2 (383e)
        LDX #$02     ;rs232 device
        LDY #$00     ;rs232 secondary addr
        JMP j3805    ;Recycle OpenP's code to open the file

g3878   LDA #$00     ;clean up failed rs232 open
        STA zF8
        STA zFA
        LDA #$06
        JMP j37B8

hCkKfh  LDX #$04
g3885   LDA hKFHmap,X
        BEQ g3894
        INX 
        CPX #$0E
        BCC g3885
        LDA #$06
        JMP j37B8

g3894   STX hfileN
        LDA #$00
        STA hFHeof,X
        RTS 

s389D   LDA #$00
        STA hDrvErr
        JSR s3691
        JSR $FFC6    ;ROM_CHKIN  - open channel for input           
        LDY #$00
g38AA   JSR $FFCF    ;ROM_CHRIN  - input character                  
        STA l4237,Y
        CMP #$0D
        BEQ g38B9
        INY 
        CPY #$2F
        BCC g38AA
g38B9   LDA #$00
        STA l4237,Y
        JSR $FFCC    ;ROM_CLRCHN - restore default devices          
        LDA l4237
        CMP #$30
        BNE g38D2
        LDA p4238
        CMP #$30
        BNE g38E4
        JMP j38EF

g38D2   SEC 
        SBC #$30
        TAX 
        LDA #$00
        CLC 
g38D9   ADC #$0A
        DEX 
        BNE g38D9
        STA hDrvErr
        LDA p4238
g38E4   SEC 
        SBC #$30
        CLC 
        ADC hDrvErr
        CMP #$14
        BCS g38F1
j38EF   LDA #$00
g38F1   STA hDrvErr
        RTS 

hcleanup CPX #$F0
        BCS g390E
g38F9   LDA #$00
        STA hFHeof,X
        CPX #$0E
        BEQ g390D
        CPX #$0F
        BEQ g390D
        STA hKFHmap,X
        TXA 
        JSR $FFC3    ;ROM_CLOSE  - close a logical file             
g390D   RTS 

g390E   CPX #$F0
        BNE g3916
        LDX #$03
        BNE g38F9
g3916   CPX #$F2
        BNE g390D
        LDX #$02
g391C   LDA tICR
        AND #$01
        BNE g391C
        LDA lofree+1
        CMP p0CB9
        BNE g3931
        LDA p0CB8
        STA lofree+1
g3931   JMP g38F9

hmlget  JSR hcpyFN
        JSR s3675
        TYA 
        LDX #$6B
        LDY #$0C
        JSR $FFBD    ;ROM_SETNAM - set file name                    
        LDY #$00
        STY hfileN
        LDA z34
        ORA z35
        BNE g394E
        INY 
g394E   LDA hSerID
        TAX 
        JSR $FFBA    ;ROM_SETLFS - set file parameters              
        LDA #$00
        LDX z34
        LDY z35
        JSR $FFD5    ;ROM_LOAD   - load after call SETLFS,SETNAM    
        STX z34
        STY z35
        BCC g3967
        JMP g379C

g3967   JSR s389D
        CMP #$00
        BEQ g3971
        JMP g379C

g3971   RTS 

hdrvcmd STA hFNam    ;prefix
        STX z16      ;Drive
        JSR s3675    ;Put unit number in C9E
        LDX z16
j397C   STX z16
        STY z17
        JSR s3691    ;Select kernal file 14 or 15 depending on Drive
        JSR $FFC9    ;ROM_CHKOUT - open channel for output          
        LDY #$00
g3988   LDA (z16),Y  ;send command to drive
        BEQ g3992
        JSR $FFD2    ;ROM_CHROUT - output character                 
        INY 
        BNE g3988
g3992   LDA #$0D     ;send carriage return
        JSR $FFD2    ;ROM_CHROUT - output character                 
        JSR $FFCC    ;ROM_CLRCHN - restore default devices          
        JSR s389D
        CMP #$00
        BEQ g39A9
        LDX #$00
        STX hfileN
        JMP g37A6

g39A9   RTS 

hgetblkf JSR s3AD8
        BNE g39B2
        JMP j3A13

g39B2   LDX hfileN
        CPX #$F0
        BCS g39D4
        JSR $FFC6    ;ROM_CHKIN  - open channel for input           
        LDX hfileN
        CPX #$0E
        BCS g39D4
        LDA hKFHmap,X
        CMP #$23
        BEQ g39D4
        LDA c64dyno
        BEQ g39D4
        BIT DynoRdy
        BMI g3A1B
g39D4   LDY #$00
g39D6   LDX hfileN
        CPX #$F0
        BCC g39E6
        JSR hspcFin
        BCS g3A0A
        STA (z16),Y
        BCC g39F0
g39E6   JSR $FFCF    ;ROM_CHRIN  - input character                  
        STA (z16),Y
        JSR s3295
        BCS g3A07
g39F0   INY 
        BNE g39F5
        INC z17
g39F5   INC hblksz
        BNE g39FD
        INC hblksz+1
g39FD   INC Szh
        BNE g39D6
        INC p0CBF
        BNE g39D6
g3A07   JSR $FFCC    ;ROM_CLRCHN - restore default devices          
g3A0A   LDA hblksz
        ORA hblksz+1
        SEC 
        BEQ g3A14
j3A13   CLC 
g3A14   LDX hblksz
        LDY hblksz+1
        RTS 

g3A1B   LDA Szh
        STA p364B
        LDA p0CBF
        STA p364C
        LDA zB9
        AND #$0F
        STA drvcmds
        LDY #$00
        LDX #$09
        JSR prepsend
        LDY #$09
        LDX #$05
        JSR prepsend
        SEI 
        LDY #$00
        STY kernST
g3A41   JSR RdDyno
        STA (z16),Y
        BVC g3A61
        INY 
        BNE g3A4D
        INC z17
g3A4D   INC Szh
        BNE g3A57
        INC p0CBF
        BEQ g3A6E
g3A57   INC hblksz
        BNE g3A41
        INC hblksz+1
        BNE g3A41
g3A61   JSR RdDyno
        CMP #$01
        LDA #$40
        BCC g3A6C
        LDA #$10
g3A6C   STA kernST
g3A6E   JSR s3295
        BCS g3A7B
        INC hblksz
        BNE g3A7B
        INC hblksz+1
g3A7B   CLI 
        JMP g3A07

RdDyno  JSR SetATN
g3A82   JSR GetIECB
        BPL g3A82
        PHP 
        JSR ClrATN
        LDX #$08
g3A8D   DEX 
        BNE g3A8D
        LDX #$04
g3A92   JSR SetlIEC
        PHA 
        JSR SetATN
        JSR ClrATN
        PLA 
        ASL 
        PHP 
        ASL 
        ROL zFF
        PLP 
        ROL zFF
        DEX 
        BNE g3A92
        LDA zFF
        EOR #$FF
        PHA 
g3AAD   JSR GetIECB
        BMI g3AAD
        PLA 
        PLP 
        RTS 

SetATN  LDA $DD00    ;CIA2: Data Port Register A
        ORA #$08
        STA $DD00    ;CIA2: Data Port Register A
        RTS 

ClrATN  LDA $DD00    ;CIA2: Data Port Register A
        AND #$F7
        STA $DD00    ;CIA2: Data Port Register A
        RTS 

SetlIEC LDA $DD00    ;CIA2: Data Port Register A
        CMP $DD00    ;CIA2: Data Port Register A
        BNE SetlIEC
        RTS 

GetIECB JSR SetlIEC
        STA zFF
        BIT zFF
        RTS 

s3AD8   STX hfileN
        LDA #$00
        STA hblksz
        STA hblksz+1
        LDA z00,Y
        STA z16
        LDA z01,Y
        STA z17
        LDA #$00
        SEC 
        SBC z02,Y
        STA Szh
        LDA #$00
        SBC z03,Y
        STA p0CBF
        ORA Szh
        RTS 

hputblkf JSR s3AD8
        BNE g3B0A
        JMP j3B53

g3B0A   BCS g3B0F
        JSR $FFC9    ;ROM_CHKOUT - open channel for output          
g3B0F   LDY #$00
g3B11   LDX hfileN
        LDA (z16),Y
        CPX #$F0
        BCC g3B21
        JSR hputspc
        BCS j3B53
        BCC g3B3C
g3B21   JSR $FFD2    ;ROM_CHROUT - output character                 
        LDA kernST
        BEQ g3B3C
        LDA #$03
        STA dioerr
        JSR s389D
        CMP #$48
        BNE g3B3C
        LDA #$01
        STA dioerr
        JMP j3B53

g3B3C   INY 
        BNE g3B41
        INC z17
g3B41   INC hblksz
        BNE g3B49
        INC hblksz+1
g3B49   INC Szh
        BNE g3B11
        INC p0CBF
        BNE g3B11
j3B53   JSR $FFCC    ;ROM_CLRCHN - restore default devices          
        LDX hblksz
        LDY hblksz+1
        RTS 

hcurset CPX #$28
        BCC g3B69
        INY 
        TXA 
        SEC 
        SBC #$28
        TAX 
        BCS hcurset
g3B69   STX z18
        STY z19
        CPY #$18
        BEQ g3B89
        BCC g3B89
        LDY #$00
        LDX #$18
        CLC 
        JSR $FFF0    ;ROM_PLOT   - read/set cursor position         
        LDX z19
g3B7D   LDA #$0D
        JSR $FFD2    ;ROM_CHROUT - output character                 
        DEX 
        CPX #$18
        BNE g3B7D
        STX z19
g3B89   LDY z18
        LDX z19
        CLC 
        JMP $FFF0    ;ROM_PLOT   - read/set cursor position         

hcurget SEC 
        JSR $FFF0    ;ROM_PLOT   - read/set cursor position         
        STX z18      ;Save row
        TYA 
        CMP #$28     ;Is Y position >40?
        BCC g3B9F    ;No, skip ahead
        SEC 
        SBC #$28     ;Roll cursor back 40 to cover for linked lines in screen handler
g3B9F   TAX 
        LDY z18      ;Swap x/y so they make sense in quadrant IV systems like computers
        RTS 

proquitz JMP ($fffc)    ;Bad behavior.  Should always jmp (fffc)!

s3BA6   JSR hcpyFN
        JSR s3675
        TYA 
        TAX 
g3BAE   LDA hFNam,X
        STA p0C6C,X
        DEX 
        BPL g3BAE
        LDA Szl
        STA hFNam
        INY 
        RTS 

dirparsln LDX #$01
        JSR $FFC6    ;ROM_CHKIN  - open channel for input           
        JSR $FFCF    ;ROM_CHRIN  - input character                  
        JSR $FFCF    ;ROM_CHRIN  - input character                  
        LDA kernST
        BNE g3BEC
        JSR $FFCF    ;ROM_CHRIN  - input character                  
        STA p0CC4
        JSR $FFCF    ;ROM_CHRIN  - input character                  
        STA p0CC5
        LDY #$00
g3BDC   JSR $FFCF    ;ROM_CHRIN  - input character                  
        STA p41E6,Y
        INY 
        CMP #$00
        BNE g3BDC
        JSR $FFCC    ;ROM_CLRCHN - restore default devices          
        CLC 
        RTS 

g3BEC   JSR $FFCC    ;ROM_CLRCHN - restore default devices          
        SEC 
        RTS 

dirszdig LDY #$00
g3BF3   SEC 
        LDA p0CC4
        SBC l3C12,X
        PHA 
        LDA p0CC5
        SBC l3C17,X
        BCC g3C0D
        STA p0CC5
        PLA 
        STA p0CC4
        INY 
        BNE g3BF3
g3C0D   PLA 
        TYA 
        ADC #$30
        RTS 

l3C12   .BYTE $01,$0A,$64,$E8,$10
l3C17   .BYTE $00,$00,$00,$03,$27
dirputc LDX p0CC3
        BEQ g3C24
        JSR hputf
g3C24   RTS 

dirputsz LDX #$04
        STX p0CC6
        SEC 
        ROR p0CC7
g3C2E   LDX p0CC6
        JSR dirszdig
        CMP #$30
        BNE g3C3D
        BIT p0CC7
        BMI g3C43
g3C3D   LSR p0CC7
        JSR dirputc
g3C43   DEC p0CC6
        BPL g3C2E
        BIT p0CC7
        BPL g3C52
        LDA #$30
        JSR dirputc
g3C52   LDA #$20
        JMP dirputc

hdir    CMP #$FF
        BNE g3C5D
        LDA #$FC
g3C5D   STA p0CC3
        LDA #$24
        JSR s3BA6
        LDX #$01
        JSR hcleanup
        LDA #$FF
        STA Szl
        LDA #$01
        STA hfileN
        JSR s374C
        CMP #$00
        BNE g3CC7
        LDX #$01
        JSR $FFC6    ;ROM_CHKIN  - open channel for input           
        JSR $FFCF    ;ROM_CHRIN  - input character                  
        JSR $FFCF    ;ROM_CHRIN  - input character                  
        JSR $FFCC    ;ROM_CLRCHN - restore default devices          
        LDA #$00
        STA Szh
        LDA p0CC3
        CMP #$FA
        BCC g3C9A
g3C95   LDA #$0D
        JSR dirputc
g3C9A   JSR dirparsln
        BCS g3CB7
        INC Szh
        LDA p0CC3
        BEQ g3C95
        JSR dirputsz
        LDY #$00
g3CAC   LDA p41E6,Y
        BEQ g3C95
        JSR dirputc
        INY 
        BNE g3CAC
g3CB7   DEC Szh
        DEC Szh
        LDX #$01
        JSR hcleanup
        LDA Szh
        CLC 
        RTS 

g3CC7   SEC 
        RTS 

hzapfile LDX #$FF
        LDA z38
        BNE g3CE0
g3CCF   INX 
        LDA FName,X
        BEQ g3CE0
        CMP #$3F
        BEQ g3CDD
        CMP #$2A
        BNE g3CCF
g3CDD   LDA #$02
        RTS 

g3CE0   LDA #$53
        JSR s3BA6
        LDX #$6B
        LDY #$0C
        JMP j397C


; Build rename command for renamez
s3CEC   LDA #$3D     ;'='
        JMP s3BA6

hrename JSR bldFNam
        BCC g3CF9
        LDA #$02
        RTS 

g3CF9   LDY #$00
        LDA #$52     ;'R'
        STA p41E6    ;command buffer
        LDX #$01
g3D02   LDA FName,Y
        BEQ g3D0E
        STA p41E6,X
        INX 
        INY 
        BNE g3D02
g3D0E   LDY #$00
g3D10   LDA hFNam,Y
        STA p41E6,X
        BEQ g3D1C
        INX 
        INY 
        BNE g3D10
g3D1C   LDA p0C6C
        STA p41E7
        LDX #$E6
        LDY #$41
        JMP j397C

StColrP LDA zD1
        STA zF3
        LDA scrnptr+1
        AND #$03
        ORA #$D8
        STA colrptr+1
        RTS 

s3D36   TYA 
        CLC 
        ADC zD1
        STA zD1
        STA zF3
        LDA scrnptr+1
        ADC #$00
        STA scrnptr+1
        STA colrptr+1
        LDX #$FF
g3D48   INX 
        LDA zF3
        SEC 
        SBC #$28
        STA zF3
        LDA colrptr+1
        SBC #$00
        STA colrptr+1
        CMP scrnbase
        BCS g3D48
        LDA zF3
        ADC #$28
        STA crsrcol
        STX crsrrow
        JSR StColrP
        RTS 

s3D67   STX p0CD5
        STY p0CD6
        LDA zD1
        STA p0CD7
        LDA scrnptr+1
        STA p0CD8
        LDA scrnbase
        STA scrnptr+1
        STA colrptr+1
        JSR s3DBA
        LDA #$D8
        STA scrnptr+1
        STA colrptr+1
        JSR s3DBA
        LDA #$C0
        STA zD1
        LDA #$03
        CLC 
        ADC scrnbase
        STA scrnptr+1
        LDY #$00
g3D98   LDA #$20
        STA (zD1),Y
        INY 
        CPY #$28
        BNE g3D98
        LDA p0CD7
        SEC 
        SBC #$28
        STA zD1
        LDA p0CD8
        SBC #$00
        STA scrnptr+1
        JSR StColrP
        LDX p0CD5
        LDY p0CD6
        RTS 

s3DBA   LDA #$28
        STA zD1
        LDY #$00
        STY zF3
        LDX #$03
g3DC4   LDA (zD1),Y
        STA (zF3),Y
        INY 
        BNE g3DC4
        INC scrnptr+1
        INC colrptr+1
        DEX 
        BNE g3DC4
        LDX #$C0
g3DD4   LDA (zD1),Y
        STA (zF3),Y
        INY 
        DEX 
        BNE g3DD4
        RTS 

s3DDD   PHA 
        AND #$7F
        CMP #$20
        BCS g3DE6
        LDA #$20
g3DE6   CMP #$40
        BCC g3E1A
        BNE g3DF0
        LDA #$00
        BEQ g3E1A
g3DF0   CMP #$7B
        BCS g3E0D
        PHA 
        LDA $D018    ;VIC Memory Control Register
        LSR 
        LSR 
        PLA 
        BCC g3E09
        CMP #$5B
        BCC g3E1A
        CMP #$60
        BCC g3E12
        BEQ g3E0D
        BCS g3E17
g3E09   CMP #$60
        BCC g3E12
g3E0D   SEC 
        SBC #$20
        BCS g3E1A
g3E12   SEC 
        SBC #$40
        BCS g3E1A
g3E17   SEC 
        SBC #$60
g3E1A   ORA EdRvsF
        STA (zD1),Y
        LDA ccolor
        STA (zF3),Y
        INY 
        TYA 
        CLC 
        ADC zD1
        STA p0CD9
        LDA scrnptr+1
        ADC #$00
        STA p0CDA
        LDA p0CD9
        CMP #$E8
        LDA p0CDA
        SBC #$03
        CMP scrnbase
        BCC g3E45
        JSR s3D67
g3E45   PLA 
        RTS 

g3E47   AND #$7F
        BNE g3E4F
        LDA #$40
        BNE g3E47
g3E4F   CMP #$20
        BCS g3E5E
        CMP #$1B
        BCS g3E5B
        ADC #$60
        BNE g3E5E
g3E5B   CLC 
        ADC #$40
g3E5E   RTS 

hedline STX z16
        STY z17
        STA EdLimit
        LDA #$00
        STA EdRvsF
        LDA EdlnMode
        ROR 
        ROR EdRvsF
        ROR 
        ROR EdRawF
        ROR 
        ROR EdUnkF
        ROR 
        ROR EdColF
        LDA HBPos
        STA p0CDC
        LDA zD1
        CLC 
        ADC crsrcol
        STA zD1
        BCC g3E8F
        INC scrnptr+1
g3E8F   JSR StColrP
        LDY #$00
        STY EdEOL
j3E97   CPY EdLimit
        BEQ g3EB3
        LDA (z16),Y
        BEQ g3EA9
        JSR s3DDD
        STY EdEOL
        JMP j3E97

g3EA9   LDA #$20
        JSR s3DDD
        CPY EdLimit
        BCC g3EA9
g3EB3   LDY EdEOL
        BIT EdColF
        BPL g3EC6
        LDY EdSCol
        CPY EdEOL
        BCC g3EC6
        LDY EdEOL
g3EC6   LDA #$00
        STA EdInsF
g3ECB   JSR j32C4
        CMP #$0D
        BNE g3ED5
        JMP j4028

g3ED5   CMP bkeybs
        BNE g3EF8
        CPY #$00
        BEQ g3ECB
        CPY EdEOL
        DEY 
        BCS g3EEC
        BIT EdInsF
        BPL g3EEF
        JMP j3F74

g3EEC   DEC EdEOL
g3EEF   LDA #$20
        JSR s3DDD
        DEY 
        JMP g3ECB

g3EF8   CMP bkeylft
        BNE g3F05
        CPY #$00
        BEQ g3ECB
        DEY 
        JMP g3EC6

g3F05   CMP bkeyrt
        BNE g3F13
        CPY EdEOL
        BEQ g3EC6
        INY 
        JMP g3EC6

g3F13   CMP bkeyins
        BNE g3F23
        LDA EdInsF
        EOR #$80
        STA EdInsF
        JMP g3ECB

g3F23   CMP bkeycel
        BNE g3F43
        CPY EdEOL
        BCS g3F40
        STY EdSCol
g3F30   LDA #$20
        JSR s3DDD
        CPY EdEOL
        BCC g3F30
        LDY EdSCol
        STY EdEOL
g3F40   JMP g3EC6

g3F43   CMP bkeyjs
        BNE g3F4D
        LDY #$00
        JMP g3EC6

g3F4D   CMP bkeyje
        BNE g3F58
        LDY EdEOL
        JMP g3EC6

g3F58   CMP bkeycan
        BNE g3F65
        LDY #$00
        TYA 
        STA (z16),Y
        JMP g3E8F

g3F65   CMP bkeydel
        BNE g3F97
        LDA #$00
        STA EdInsF
        CPY EdEOL
        BEQ g3F94
j3F74   STY EdSCol
        JMP j3F80

g3F7A   LDA (zD1),Y
        DEY 
        STA (zD1),Y
        INY 
j3F80   INY 
        CPY EdEOL
        BCC g3F7A
        LDA #$20
        ORA EdRvsF
        DEY 
        STA (zD1),Y
        DEC EdEOL
        LDY EdSCol
g3F94   JMP g3ECB

g3F97   CMP bkeybt
        BNE g3FA4
        JSR GetHstBuf
        LDY #$00
        JMP g3E8F

g3FA4   CMP bkeyfk1
        BCC g3FBD
        CMP bkeyfkl
        BCS g3FBD
        BIT EdRawF
        BMI j4028
        LDY #$00
        JSR s40E4
        LDY #$00
        JMP g3E8F

g3FBD   CMP bkeyeof
        BNE g3FD3
        LDX EdEOL
        BNE g3FD3
        LDY #$00
        TYA 
        STA (z16),Y
        SEC 
        STY EdSCol
        JMP j4061

g3FD3   CMP #$20
        BCC g3FDB
        CMP #$80
        BCC g3FE3
g3FDB   BIT EdUnkF
        BMI j4028
        JMP g3ECB

g3FE3   CPY EdLimit
        BCS g4017
        CPY EdEOL
        BCS g401A
        BIT EdInsF
        BPL g401A
        STY EdSCol
        LDY EdEOL
        CPY EdLimit
        BCC g4003
        LDY EdSCol
        JMP g3ECB

g4003   PHA 
g4004   DEY 
        LDA (zD1),Y
        INY 
        STA (zD1),Y
        DEY 
        CPY EdSCol
        BNE g4004
        PLA 
        JSR s3DDD
        INC EdEOL
g4017   JMP g3ECB

g401A   JSR s3DDD
        CPY EdEOL
        BCC g4017
        STY EdEOL
        JMP g3ECB

j4028   STA hasav2
        STY EdSCol
        LDY #$00
        CPY EdEOL
        BEQ g4042
g4035   LDA (zD1),Y
        JSR g3E47
        STA (z16),Y
        INY 
        CPY EdEOL
        BNE g4035
g4042   LDA #$00
        STA (z16),Y
        LDY EdSCol
        JSR s3D36
        LDA hasav2
        CMP #$0D
        BNE g4060
        JSR s4062
        LDY EdSCol
        LDA #$0D
        JSR hconout
        LDA #$0D
g4060   CLC 
j4061   RTS 

s4062   LDY #$FF
        LDX HBPos
g4067   INY 
        INX 
        LDA (z16),Y
        JSR WrHstBuf
        BNE g4067
        STX HBPos
        RTS 


; WrHstBuf: Platform specific code for writing the history buffer
WrHstBuf STA asav
        PHP 
        SEI 
        LDA pport
        PHA 
        AND #$FC     ;All ram
        STA pport
        LDA asav
        STA HistBuf,X
        PLA 
        STA pport
        PLP 
        LDA asav
        RTS 


; RdHstBuf: Platform specific code for reading the history buffer
RdHstBuf PHP 
        SEI 
        LDA pport
        PHA 
        AND #$FC     ;All ram
        STA pport
        LDA HistBuf,X
        STA asav
        PLA 
        STA pport
        PLP 
l40A1   LDA asav
        RTS 

GetHstBuf LDY #$FF
        LDX p0CDC
g40AA   DEX 
        CPX HBPos
        BEQ g40C2
        JSR RdHstBuf
        BEQ g40C2
        CMP #$FF
        BNE g40AA
        LDA HBPos
        STA p0CDC
        JMP j40C5

g40C2   STX p0CDC
j40C5   INX 
        INY 
        CPY EdLimit
        BCC g40D0
        LDA #$00
        BEQ g40D3
g40D0   JSR RdHstBuf
g40D3   STA (z16),Y
        BNE j40C5
        RTS 


; do.fkget: Platform specific code to handle retrieving function key strings
hfkget  JSR fkprep   ;Set up vectors
        LDY #$20     ;Max length
        STY EdLimit
        LDY #$00     ;Start counting
        BEQ g40E7
s40E4   JSR s4120    ;todo: What is .X used for here?
g40E7   JSR rdfkey   ;Get a byte
        BEQ g40F7    ;End of string?
        STA (z16),Y  ;Store to destination
        INX 
        INY 
        CPY EdLimit  ;Max length?
        BCC g40E7    ;No, continue
        LDA #$00     ;End of string
g40F7   STA (z16),Y  ;Store end of string
        RTS 


; do.fkset: Platform specific code to handle setting function key strings
hfkset  JSR fkprep   ;from fkeysetz
        LDY #$00     ;Start counting
g40FF   LDA (z16),Y  ;Get a byte
        BEQ g410E    ;zero? End of string.
        JSR wrfkey   ;Write a byte
        INX 
        INY 
        CPY #$1F     ;Max length?
        BNE g40FF    ;No, continue
        LDA #$00     ;End of string
g410E   JSR wrfkey   ;Store last byte
        RTS 


; fk.prep: shared code for do.fkget and do.fkset
fkprep  STX z16
        STY z17 ;Set up vector to buffer
        SEC 
        SBC #$01     ;Adjust base-one to base-zero
        ASL 
        ASL 
        ASL 
        ASL 
        ASL 
        TAX 
        RTS 

s4120   TAX 
        LDA l40A1,X
        TAX 
        RTS 

        .BYTE $00,$40,$80,$C0,$20,$60,$A0,$E0

; wr.fkey: Platform specific code for writing a byte to fkey storage space
wrfkey  STA asav
        PHP 
        SEI 
        LDA pport
        PHA 
        AND #$FC     ;All ram
        STA pport
        LDA asav
        STA KeyDefsi,X
        PLA 
        STA pport
        PLP 
        LDA asav
        RTS 


; rd.fkey: Platorm specific code for reading a byte from fkey storage space
rdfkey  PHP 
        SEI 
        LDA pport
        PHA 
        AND #$FC     ;All ram
        STA pport
        LDA KeyDefsi,X
        STA asav
        PLA 
        STA pport
        PLP 
        LDA asav
        RTS 


; Only called from swpmemz.  Parameters are in the comments before MSBlp
hswpmem STA z16      ;Buffer 'a' low
        STX z17 ;Buffer 'a' high
        LDA z00,Y   ;Y=$36 from the only routine that calls here
        STA z18      ;Buffer 'b' low
        LDA z01,Y    ;$37
        STA z19 ;Buffer 'b' high
        LDA z02,Y  ;$38
        STA Szl      ;Size (low)
        LDA z03,Y  ;$39
        STA Szh      ;Size (high)
        PHP 
        SEI 
        LDA pport      ;Get current map
        PHA 
        AND #$FC     ;All ram
        STA pport      ;Set map
        LDY #$00     ;Process full pages first...
        LDX Szh      ;How many full pages?
        BEQ MSsml    ;None? Skip to partial page
MSBlp   LDA (z16),Y
        PHA 
        LDA (z18),Y
        STA (z16),Y
        PLA 
        STA (z18),Y
        INY 
        BNE MSBlp    ;If done with 256 bytes, increment buffer addresses
        INC z17
        INC z19
        DEX 
        BNE MSBlp    ;More pages to transfer?
MSsml   LDX Szl      ;Now process the last partial page
        BEQ MSfin    ;None?  Jump to end of routine.
MSSlp   LDA (z16),Y
        PHA 
        LDA (z18),Y
        STA (z16),Y
        PLA 
        STA (z18),Y
        INY 
        DEX 
        BNE MSSlp    ;More bytes to do?
MSfin   PLA 
        STA pport      ;Restore map from 417d
        PLP 
        RTS 


; 0=test input status, 1=test output status
hgettst CMP #$00
        BEQ hgTinST
        LDX RSOutC
        INX 
        CPX RSOutP
        JMP j41C9

hgTinST LDX RSInP    ;Test T input status
        CPX RSInC
j41C9   BNE g41D3
        LDA htST
        ORA #$08
        CLC 
        BCC g41DC
g41D3   LDA htST
        ORA tdevst
        AND #$F7
        SEC 
g41DC   AND #$FE
        STA tdevst
        BIT p41E5
        RTS 

p41E5   .BYTE $80
p41E6   .BYTE $00
p41E7   .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
l4237   .BYTE $00
p4238   .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00

; Drive-side fastloader code.  $FB bytes gets uploaded by code at $35fe
drvcode1 =*
        .logical $0300
        ; drive code is sent to $0300 by sendcode.

        SEI 
        LDX z92
        LDA $022B,X
        STA z8D
        TAY 
        TAX 
        JSR $DF95
        STA z8C
        ASL 
        TAX 
        LDA #$00
        STA z8B
        LDA $023E,Y
        PHA 
        LDA $00F2,Y
        AND #$08
        BEQ g42A8
        LDA z8B
        BNE g42A8
        INC kernST
        BNE g4293
        INC stopflag
        BEQ g429E
g4293   PLA 
        CLC 
        JSR $03BD
        JSR $0360
        JMP $0318    ;NMI

g429E   JSR $0360
        STA $023E,Y
        PLA 
        CLC 
        BCC g42AF
g42A8   PLA 
        SEC 
        JSR $03BD
        LDA z8B
g42AF   JSR $03BD
        LDA #$00
        STA $7c
        CLI 
        LDA $024F
        ORA #$01
        STA $024F
        RTS 

        LSR $024F
        ASL $024F
g42C6   RTS 

        JSR $03A6
        BNE g42C6
        BCS g42C6
        PHA 
        JSR $D13A
        STA z06,X
        JSR $D13A
        STA z07,X
        LDA #$00
        STA z99,X
        STA z30
        LDA z9A,X
        STA z31
        LDY z8C
        LDA #$80
        STA z00,Y
        CLI 
g42EB   LDA z00,Y
        BMI g42EB
        SEI 
        CMP #$02
        BCC g42F7
        STA z8B
g42F7   LDY z8D
        JSR $D13A
        CMP #$00
        BNE g4308
        JSR $D13A
        STA $0244,Y
        PLA 
        RTS 

g4308   JSR $D13A
        PLA 
        RTS 

        JSR $D13A
        BNE g4322
        PHA 
        LDA $0244,Y
        BEQ g431F
        JSR $D162
        PLA 
        CPY z8D
        RTS 

g431F   PLA 
        CPY z8D
g4322   CLC 
        RTS 

        STA $7c
        TXA 
        PHA 
g4328   LDA $1800
        BPL g4328
        LDA #$10
        BCC g4333
        ORA #$08
g4333   STA $1800
g4336   LDA $1800
        BMI g4336
        LDX #$04
g433D   LDA #$00
        ASL $7c
        ROL 
        ASL 
        ASL $7c
        ROL 
        ASL 
        STA $1800
g434A   LDA $1800
        BPL g434A
g434F   LDA $1800
        BMI g434F
        DEX 
        BNE g433D
        LDA #$0F
        STA $1800
        PLA 
        TAX 
        RTS 
        
        .here ; end of drive code

        .BYTE $00,$00,$00

; $4267+$FB = 4362.  Drive code ends here
p4362   .BYTE $00
p4363   .BYTE $00



