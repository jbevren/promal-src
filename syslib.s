
;
; PROMAL for the Commodore 64
; Copyright (C) 1985, SMA, Inc.
; Re-source (C) 2015 jbevren
;

; PROMAL system library routines

; version 
; status: 

; TODO: name and document zp usage


; unnamed zp usage:
;  count location
;     36 z2C : commonly used with z2D as a buffer pointer
;     35 z2D 
;      1 z2F : variable base address pointer for current program
;      2 z30 : pointer into the system heap
;     44 z34
;     51 z35
;     32 z36
;     35 z37
;     68 z38
;     38 z39
;     24 z3A
;     24 z3B
;     12 z3C
;     12 z3D
;     16 z3E
;     12 z3F
;      2 z40
;      1 z41
;      7 z67

        ; defines for system library
Stringv =$2c    ; WORD: commonly used as a pointer to string buffer
zrelsz  =$67    ; WORD: temp storage for relocation table size
maxparms=$69    ; BYTE: getprm maximum number of paramemters
numparms=$6a    ; BYTE: getprm number of parameters
minparms=$6b    ; BYTE: getprm minimum parameters
getpmsk =$6c    ; BYTE: getprm bitmask
Parent  =$3a    ; WORD: storage for caller address
GParent =$6d    ; WORD: storage for caller's caller address

getprm  PLA
        STA Parent
        PLA
        STA Parent+1
        PLA
        STA GParent
        PLA
        STA GParent+1
        STY numparms
        LDY #$01
        LDA (Parent),Y
        AND #$0F
        STA maxparms
        CMP numparms
        BCC _error
        LDA (Parent),Y
        BEQ _finish
        LSR
        LSR
        LSR
        LSR
        STA minparms
        CMP numparms
        BEQ _ok
        BCC _ok
_error  JMP esys
_ok     INY
        LDA (Parent),Y
        STA getpmsk
_loop   DEC maxparms
        BMI _finish
        INY
        LDA (Parent),Y
        TAX
        LDA maxparms
        CMP minparms
        BCC _pull
        BIT getpmsk
        BMI _isword
        INY
        LDA (Parent),Y
        STA 00,X
_isword LDA maxparms
        CMP numparms
        BCS _defalt
_pull   PLA
        BIT getpmsk
        BPL _isbyte
        STA 01,X
_isbyte PLA
        STA 00,X
_defalt ASL getpmsk
        JMP _loop
_finish TYA
        CLC
        ADC Parent
        TAX
        LDA Parent+1
        ADC #$00
        PHA
        TXA
        PHA
        LDA GParent
        STA Parent
        LDA GParent+1
        STA Parent+1
        RTS

getverz JSR getprm    ; page 4-24: word=GETVER
        .BYTE $00     ; no prameters
        LDA #$21
        PHA
        LDA #$01
        JMP retbyte

p100fz  JSR getprm    ; undocumented: word=p100f
        .BYTE $00     ; no prameters
        LDA #$0F
        PHA
        LDA #$10      ; return $100F
        JMP retbyte

getkeyz JSR getprm    ; page 4-20: byte=GETKEY [(#variable)]
        .BYTE $01,$80 ; 0-1 parm: Wxxx xxxx
        .BYTE z2C     ; store word on stack at z2C: #variable
        JSR IsCapLk
        JMP j18B5     ; use getcz to finish

getcz   JSR getprm    ; page 4-19: byte=GETC[(#variable)]
        .BYTE $01,$80 ; 0-1 parm: Wxxx xxxx
        .BYTE z2C     ; store word on stack at z2C: #variable
        JSR hkeyin
j18B5   LDY numparms
        BEQ g18BD
        LDX #$00
        STA (Stringv,X)
g18BD   JMP retbyte

getcfz  PLA           ; page 4-20: flagbyte=GETCF(handle, #variable)
        STA Parent
        PLA
        STA Parent+1
        CPY #$02
        BEQ _ok
        JMP esys
_ok     PLA
        STA Stringv+1
        PLA
        STA Stringv
        PLA
        STA z35
        PLA
        STA z34
        JSR ckfh
        JSR rdck
        JSR hgetin
        LDX #$00
        STA (Stringv,X)
        BCS _exit
        LDA #$01
_exit   JMP retbyte

        ; determine if a file can be written
wrtck   CMP #$57      ; 'W': write
        BEQ rwok
        CMP #$41      ; 'A': append
        BEQ rwok
        CMP #$42      ; 'B': both
        BEQ rwok
rwbad   JMP eredio    ; not okay.

        ; determine if a file can be read
rdck    CMP #$52      ; 'R': read
        BEQ rwok
        CMP #$42      ; 'B': both
        BNE rwbad
rwok    LDA #$00      ; it's okay.
        STA dioerr
        RTS

cpstrng STX z34       ; copy string from (.Y.X) to (stringv)
        STY z35
        LDY #$FF
_loop   INY
        LDA (z34),Y
        STA (Stringv),Y
        BNE _loop
        DEY
        RTS

getlz   JSR getprm    ; page 4-21: GETL #buffer [,limit]
        .BYTE $12,$40 ; 1-2 parms: BWxx xxxx
        .BYTE z38,$50 ; store byte on stack or 50 at z38: limit
        .BYTE z2C     ; store word on stack at z2C      : #buffer
        LDA z38
        JSR hgetln
        JSR cpstrng
        JMP return

getlfz  PLA           ; page 4-22: flagbyte=getlf(handle, #buffer [, limit])
        STA Parent
        PLA
        STA Parent+1
        LDA #$50
        CPY #$03
        BNE _1parm
        PLA
        PLA
        DEY
_1parm  STA z38
        CPY #$02
        BEQ _ok
        JMP esys
_ok     PLA
        STA Stringv+1
        PLA
        STA Stringv
        PLA
        STA z35
        PLA
        STA z34
        JSR ckfh
        JSR rdck
        STX z37
        LDA z38
        JSR hgetlf
        JSR cpstrng
        LDA #$01
        BCC _exit
        LDA #$00
_exit   JMP retbyte

putz    PLA           ; page 4-45: PUT item [,item...]
        STA Parent
        PLA
        STA Parent+1
j196F   CPY #$00
        BNE _ok
        JMP esys
_ok     TSX
        STX z38
        TYA
        ASL
        CLC
        ADC z38
        STA z39
        TAX
_loop   LDA cpustk,X
        STA Stringv
        DEX
        STX z34
        LDA cpustk,X
        BEQ _schar
        STA Stringv+1
        LDY #$00
_char   STY z35
        LDA (Stringv),Y
        BEQ _eos
        JSR hconout
        LDY z35
        INY
        BNE _char
_schar  LDA Stringv
        JSR hconout
_eos    LDX z34
        DEX
        CPX z38
        BNE _loop
        LDX z39
        TXS
        JMP return

putfz   PLA           ; page 4-47: PUTF handle, item [, item...]
        STA Parent
        PLA
        STA Parent+1
j19B8   CPY #$02
        BCS _ok
        JMP esys
_ok     TSX
        STX z38
        TYA
        ASL
        CLC
        ADC z38
        STA z39
        TAX
        LDA cpustk,X
        STA z34
        DEX
        LDA cpustk,X
        STA z35
        DEX
        STX z37
        JSR ckfh
        JSR wrtck
        STX z36
        LDX z37
_loop   LDA cpustk,X
        STA Stringv
        DEX
        LDA cpustk,X
        BEQ _char
        STA Stringv+1
        LDY #$00
        STX z37
_loop1  STY z3E
        LDA (Stringv),Y
        BEQ _next
        LDX z36
        JSR hputf
        LDY z3E
        INY
        BNE _loop1
        BEQ _next
_char   LDA Stringv
        STX z37
        LDX z36
        JSR hputf
_next   LDX z37
        DEX
        CPX z38
        BNE _loop
        LDX z39
        TXS
        JMP return

outputz PLA           ; page 4-41: OUTPUT Formatstring [, item...]
        STA Parent
        PLA
        STA Parent+1
        CPY #$00
        BNE _ok
        JMP esys
_ok     TSX
        STX z38
        TYA
        ASL
        CLC
        ADC z38
        TAX
        STX hxsav2
        LDA cpustk,X
        STA z34
        DEX
        LDA cpustk,X
        STA z35
        DEX
        STX z37
        JSR txtfmt
        LDX hxsav2
        TXS
        LDA #$00
        PHA
        LDA #$0A
        PHA
        LDY #$01
        JMP j196F

outputfz PLA          ; page 4-43: OUTPUTF Handle, formatstring [, item...]
        STA Parent
        PLA
        STA Parent+1
        CPY #$02
        BCS _ok
        JMP esys
_ok     DEY
        TSX
        STX z38
        TYA
        ASL
        CLC
        ADC z38
        TAX
        STX hxsav2
        LDA cpustk,X
        STA z34
        DEX
        LDA cpustk,X
        STA z35
        DEX
        STX z37
        JSR txtfmt
        LDX hxsav2
        TXS
        LDA #$00
        PHA
        LDA #$0A
        PHA
        LDY #$02
        JMP j19B8

txtfmt  LDY #$FF      ; format text for outputz and outputfz
        LDX #$00
_char   INY
        LDA #$FF
        STA p4362
        LDA #$00
        STA z38
        LDA (z34),Y
        BEQ _exit
        CMP #$23      ; '#' for format code?
        BEQ _format
_wchar  STA scratchpad,X
        INX
        BNE _char
_exm1   DEX
_exit   LDA #$00
        STA scratchpad,X
        RTS
_format INY
        LDA (z34),Y
        BNE _fmtok
        DEX
        LDA #$23
_fmtok  CMP #$23      ; '#' to print a #?
        BEQ _wchar
        JSR Ndigit
        BCC _fmtdo
        JSR a2nb
        CMP #$2E
        BNE _fmtdo
        LDA z38
        PHA
        LDA #$00
        STA z38
        INY
        LDA (z34),Y
        JSR a2nb
        LDA z38
        STA p4362
        PLA
        STA z38
        LDA (z34),Y
_fmtdo  JSR ToUpper1
        CMP #$43      ; 'C' for carriage return?
        BNE _chkB
        LDA z38
        BNE _wchar
        LDA #$0D
        BNE _wchar
_chkB   CMP #$42      ; 'B' for blank space(s)?
        BNE _fmtU
        LDA z38
        BNE _fmtsp
        INC z38
_fmtsp  LDA #$20
        STA scratchpad,X
        INX
        BEQ _estr
        DEC z38
        BNE _fmtsp
        JMP _char
_fmtU   PHA
        STX z2C
        LDA #$0A
        STA Stringv+1
        LDA #$00
        STA z36
        LDA #$0A
        STA z3C
        LDA #$20
        STA z39
        LDX z37
        LDA cpustk,X
        STA z3E
        DEX
        LDA cpustk,X
        STA z3F
        DEX
        STX z37
        STY hysav2
        PLA
        CMP #$53      ; 'S' for string?
        BNE _chkH
        LDX z2C
        LDY #$00
        LDA z3F
        BEQ _fchar
_gstr   LDA (z3E),Y
        BEQ _fspc
        STA scratchpad,X
        INY
        INX
        BNE _gstr
        BEQ _estr
_fchar  LDA z3E
        STA scratchpad,X
        INY
        INX
_fspc   TYA
        SEC
        SBC z38
        BCS _cont
        TAY
        LDA #$20
_fspcl  STA scratchpad,X
        INX
        BEQ _estr
        INY
        BNE _fspcl
        BEQ _cont
_estr   JMP _exm1
_cont   LDY hysav2
        JMP _char
_chkH   CMP #$48      ; 'H' for hex word?
        BNE _chkI
        LDA #$10
        STA z3C
        LDA #$30
        STA z39
        BNE _n2a
_chkI   CMP #$49      ; 'I' for int?
        BNE _chkW
        DEC z36
        BNE _n2a
_chkw   CMP #$57      ; 'W' for word?
        BNE _chkE
_n2a    JSR n2a
_nxtf   TYA
        LDY hysav2
        CLC
        ADC z2C
        TAX
        BCC _fnxt
        LDX #$00
        BEQ _estr
_fnxt   JMP _char
_chkE   CMP #$45      ; 'E' for scientific?
        BNE _chkR
_freal  LDA z38
        STA p4363
        DEC p4363
        LDA z3E
        JSR rpull1
        JSR s4861
        JMP _nxtf
_chkR   CMP #$52      ; 'R' for real?
        BEQ _freal
        LDY hysav2
        LDX z2C
        JMP _wchar

a2nb    PHA           ; fast convert ascii value in (z34) to byte
        LDA z38       ; multiply z38 by 10:
        ASL           ;   mul 2 (2 total)
        ASL           ;   mul 2 (4 total)
        CLC
        ADC z38       ;   add 1 (5 total)
        ASL           ;   mul 2 (10 total)
        STA z38       ;   save
        PLA           ; restore new digit
        SEC
        SBC #$30      ; subtract ascii '0'
        CLC
        ADC z38       ; add z38
        STA z38       ; save
        INY           ; increment string index
        LDA (z34),Y   ; get next char
        JSR Ndigit    ; check for non-digit
        BCS a2nb      ; it's a digit, loop.
        RTS

strvalz JSR getprm    ; page 4-53: byte=STRVAL(String, #variable [,Radix [,Maxfield]])
        .BYTE $24,$30 ; 2-4 parms: BBWW xxxx
        .BYTE z38,$FF ; store $ff or byte on stack at z38: Maxfield
        .BYTE z3E,$0A ; store $0a or byte on stack at z3E: Radix
        .BYTE z2C     ; store word on stack at z2C       : #variable
        .BYTE z34     ; store word on stack at z34       : String
        LDY #$00
        STY z37
        STY z3F
        STY z3C
        STY z3D
        DEY
        STY z36
_next   INY
        CPY z38
        BEQ _exit
        LDA (z34),Y
        CMP #$20      ; space?
        BEQ _space
        CMP #$2D      ; '-'?
        BEQ _sign
        CMP #$2B      ; '+'?
        BEQ _sign
        JSR ToUpper1
        SEC
        SBC #$30
        BCC _exit
        CMP #$0A
        BCC _ov10
        SEC
        SBC #$07
        CMP #$0A
        BCC _exit
_ov10   CMP z3E
        BCS _exit
        STA z36
        JSR Mul16
        LDA z40
        ORA z41
        BNE _err
        LDA z3C
        CLC
        ADC z36
        STA z3C
        BCC _next
        INC z3D
        BNE _next
_err    LDA #$00
        STA z37
        STA z3D
        BEQ _save
_sign   BIT z36
        BPL _exit
        BIT z37
        BVS _err
        SEC
        ROR z37
        CMP #$2D
        ROR z37
        JMP _next
_space  BIT z36
        BMI _next
_exit   BIT z36
        BMI _err
        BIT z37
        BPL _ispos
        BIT z3D
        BMI _err
        LDA #$00
        SEC
        SBC z3C
        STA z3C
        LDA #$00
        SBC z3D
        STA z3D
_ispos  STY z37
        LDA z3C
_save   LDY #$00
        STA (Stringv),Y
        INY
        LDA z3D
        STA (Stringv),Y
        LDA z37
        JMP retbyte

intstrz SEC           ; page 4-28: INTSTR Value, #Buf[,Radix[,Minfield[,Padding]]]
        BCS tostr     ; set carry and use wordstrz

wordstrz CLC          ; page 4-57: WORDSTR Value, #Buf[,Radix[,Minfield[,Padding]]]
tostr   ROR z36
        JSR getprm
        .BYTE $25,$18 ; 2-5 parms: BBBW Wxxx
        .BYTE z39,$20 ; store $20 or byte on stack at z39
        .BYTE z38,$00 ; store $00 or byte on stack at z38
        .BYTE z3C,$0A ; store $0a or byte on stack at z3C
        .BYTE z2C     ; store word on stack at z2C
        .BYTE z3E     ; store word on stack at z3E
        JSR n2a
        LDA #$00
        STA (Stringv),Y
        JMP return

n2a     LDX #$00      ; convert number to ascii
        STX z3D
        LDA z36
        BPL _word
        LDA #$00
        BIT z3F
        BPL _word
        SEC
        SBC z3E
        STA z3E
        LDA #$00
        SBC z3F
        STA z3F
        INX
        LDA #$80
_word   STA z36
_next   LDA z3E
        CMP z3C
        LDA z3F
        SBC z3D
        BCC _last
        JSR Div32
        LDA z40
        PHA
        INX
        BNE _next
_last   LDA z3E
        PHA
        INX
        LDY #$00
_pad    CPX z38
        BCS _sign
        LDA z39
        STA (Stringv),Y
        INY
        DEC z38
        BNE _pad
_sign   BIT z36
        BPL _2asc
        LDA #$2D
        STA (Stringv),Y
        INY
        DEX
_2asc   PLA
        CLC
        ADC #$30
        CMP #$3A
        BCC _store
        ADC #$06
_store  STA (Stringv),Y
        INY
        DEX
        BNE _2asc
        RTS

gNxtFH  LDA z34       ; Advance to next handle or return carry
        CLC
        ADC #$16      ; file handle field size
        STA z34
        BCC _skip
        INC z35
_skip   CLC
        ADC #$16      ; file handle field size
        TAY
        LDA z35
        ADC #$00
        CMP FHTabE+1
        BCC _ok
        BNE _err
        CPY FHTabE
        BCC _ok
        BEQ _ok
_err    LDY #$00
        SEC
        RTS
_ok     LDY #$00
        CLC
        RTS

openz   LDA bfiltyp   ; page 4-36: word=OPEN (filename [,mode [,nocheck [,type]]])
        STA z36
        LDA nofnchk
        STA z34
        JSR getprm
        .BYTE $14,$D0 ; 1-4 parms: WWBW xxxx
        .BYTE z36     ; store word on stack at z36             : type
        .BYTE z34     ; store word on stack at z34             : nocheck
        .BYTE z38,$52 ; store $52 ('R') or byte on stack at z38: mode
        .BYTE z2C     ; store word on stack at z2C             : filename
        LDA z34       ; nocheck
        BEQ _nochk
        LDA #$80
_nochk  STA z37
        LDA z36       ; type
        JSR ToUpper1
        STA z36
        LDA z38       ; mode
        JSR ToUpper1
        LDX #$03
_loop   CMP _abrw,X
        BEQ _open
        DEX
        BPL _loop
        LDA #$01
        JMP ioerr
_abrw    .BYTE $41,$42,$52,$57 ; 'ABRW'
_open   STA z38
        JSR sfck
        JSR bldFNam
        JSR sfck
        BCC _fnok
        LDA #$02
        JMP ioerr
_fnok   CPX #$02
        BCS _nspc
        JSR qSpcNam
        JMP spec
_nspc   LDA FHtabB
        STA z34
        LDA FHtabB+1
        STA z35
        LDY #$00
_newfh  LDA (z34),Y
        BEQ _fhbad
_nchr   LDA (z34),Y
        BEQ _empty
        CMP FName,Y
        BNE _fhbad
        INY
        BNE _nchr
_empty  LDA FName,Y
        BNE _fhbad
        INY
        INY
        LDA (z34),Y
        TAX
        JSR hcleanup
        LDA #$00
        TAY
        STA (z34),Y
        JMP _openf
_fhbad  JSR gNxtFH
        BCC _newfh
        LDA FHtabB
        STA z34
        LDA FHtabB+1
        STA z35
_fhok   LDA (z34),Y
        BEQ _openf
        JSR gNxtFH
        BCC _fhok
        LDA #$06
        JMP ioerr
_openf  LDA z38       ; mode
        JSR styp      ; swap filetype with ours
        JSR s36E8     ; check for special disk file
        JSR styp      ; swap back
        CMP #$00      ; no file?
        BNE ioerr     ; error
        LDY #$00
_fnam   LDA FName,Y
        STA (z34),Y
        BEQ _fnend
        INY
        BNE _fnam
_fnend  INY
        LDA z38
        STA (z34),Y
        INY
        TXA
        STA (z34),Y
        LDA z34
        PHA
        LDA z35
        JMP retbyte
ioerr   STA ioerror   ; recycled code: not a local label
        LDA #$00
        PHA
        JMP retbyte
spec    LDA z38
        JSR s37D6
        BCS ioerr
        LDY #$08      ; offset for L file pointers
        LDA SName,X
	.if ldrv + wdrv
        CMP #$4C      ; 'L' file?
        BEQ _W     ; yes, keep current offset
        LDY #$00      ; offset for W file pointers
        CMP #$57      ; 'W' file?
        BNE _A
_W      LDA z38       ; mode
        CMP #$41      ; 'A' for append?
        BEQ _A
        CMP #$52      ; 'R' for read?
        BEQ _R
        ; reset EOF pointer, effectively erasing file
        LDA worg,Y    ; .Y may be 8, directing these to lorg et.al
        STA weof,Y
        LDA worg+1,Y  ; get origin of file
        STA weof+1,Y  ; store at end of file to clear it
        ; reset file pointer, resetting file for read
_R      LDA worg,Y    ; get origin of file
        STA wptr,Y    ; store at current offset to reset it
        LDA worg+1,Y
        STA wptr+1,Y
	.fi ;ldrv or wdrv
        ; file is open, set up file handle
_A      TXA
        CLC
        ADC #<SName   ; $D8
        PHA
        LDA #>SName   ; $0F
        ADC #$00
        JMP retbyte

sfck    LDA nofnchk   ; swap nofnck with specified value
        LDY z37
        STA z37
        STY nofnchk
        RTS

styp    PHA           ; swap bfiltyp with specified value
        LDA bfiltyp
        PHA
        LDA z36
        STA bfiltyp
        PLA
        STA z36
        PLA
        RTS

FNameLen LDY #$00     ; Find length of string at (Stringv) and put on stack
-       LDA (Stringv),Y
        CMP #$20      ; space
        BNE _push     ; not space, push char
        INC Stringv
        BNE -         ; next char
        INC Stringv+1
        BNE -         ; next char
_push   PHA           ; put char on stack
-       LDA (Stringv),Y
        BEQ _exit     ; end of string? exit
        INY
        BNE -    ; more chars? loop back
_exit   PLA           ; pull first char off stack
        RTS

qUConv  BIT nofnchk   ; Convert character to uppercase if nofnchk is valid
        BMI +
        JSR ToUpper1
+       STA FName,X   ; add to filename
        INX
        RTS

FAddXt  STX xsav2     ; optionally add default extension to filename
-       DEX
        CPX #$02
        BCC _eonam
        LDA FName,X   ; get byte from filename
        CMP #$2E      ; '.'
        BEQ _dot      ; filename has a . in it, exit
        BNE -
_eonam  LDX xsav2
        LDA #$2E      ; '.'
        JSR qUConv    ; add to filename
        LDA dfext     ; default extension
        JSR qUConv    ; add to filename
        LDA #$00
        STA FName,X   ; terminate filename with null
        RTS
_dot    LDX xsav2
        RTS

bldFNam JSR FNameLen  ; Build filename from program input
        LDX #$00
        CPY #$00      ; filename has zero length?
        BNE _go       ; No, proceed
        LDA #$02
        JMP _err      ; set carry and return
_go     CPY #$01      ; Filename has one character?
        BNE _norm     ; No, proceed normally
        JSR qUConv    ; convert filename to uppercase and store in ca5
        LDA #$00
        STA p0CA6
        JSR qSpcNam   ; check for special files(?)
        BCC _Apfx
        LDX #$01
        BNE _exit     ; always branches (ldx #1)
_norm   LDY #$01
        LDX #$00
        LDA (Stringv),Y
        CMP #$3A      ; ':'
        BNE _Apfx
        DEY
        LDA (Stringv),Y
        CMP #$30      ; '0'
        BEQ _fnuc
        CMP #$31      ; '1'
        BEQ _fnuc
_Apfx   LDA prefix    ; add prefix
        STA FName
        LDA #$3A      ; ':'
        STA p0CA6
        LDX #$02
_fnuc   LDY #$FF      ; preset for increment
_loop   INY           ; uppercase filename
        LDA (Stringv),Y
        BEQ _done
        JSR qUConv
        CPX #$12
        BCC _loop
        LDA #$02
        BNE _err
_done   STA FName,X
        CPX #$03
        BCC _err
        BIT nofnchk
        BMI _exit
        JSR FAddXt
_exit   CLC
        RTS
_err    SEC
        RTS

qSpcNam LDA FName     ; Determine if filename indicates a special device
        JSR ToUpper1
        LDX #$00
-       CMP SName,X
        BEQ +
        INX
        INX
        INX
        INX           ; special name table is 4 bytes per entry
        CPX #$20
        BCC -
        CLC
+       RTS

closez  JSR getprm    ; page 4-7: CLOSE handle
        .BYTE $11,$80 ; 1 parm: Wxxx xxxx
        .BYTE z34     ; store word on stack at z34
        JSR ckfh      ; validate file handle
        CPX #$F0      ; special file?
        BCS +         ; yes, exit
        JSR hcleanup  ; close file
        JSR s1F41     ; reset stdio
+       JMP return    ; return

s1F41   LDY #$00      ; reset standard IO handles
        TYA
        STA (z34),Y
        LDX #$06
-       LDA stdin,X   ; check IO handle
        CMP z34       ; compare with file handle
        BNE +         ; no match, next IO handle
        LDA stdin+1,X
        CMP z35
        BNE +
        LDA reddefs,X ; match: reset from default
        STA stdin,X
        LDA reddefs+1,X
        STA stdin+1,X
+       DEX
        DEX
        BPL -         ; continue for all IO handles
        RTS

clsallz JSR getprm    ; cloase all files (prosys.s): CLSALL
        .BYTE $00     ; no prameters
        LDA FHtabB    ; get first file handle entry
        STA z34
        LDA FHtabB+1
        STA z35       ; set to current file handle
        LDY #$00
-       LDA (z34),Y   ; check handle
        BEQ ++        ; empty? get next handle
        JSR ckfh      ; validate handle
        CPX #$F0      ; special file?
        BCS ++        ; yes, skip close
        LDA z34       ; get file handle
        CMP stderi    ; compare with stderr handle
        BNE +         ; no match, close the file
        LDA z35
        CMP stderi+1
        BEQ ++
+       JSR hcleanup  ; close file
        JSR s1F41     ; fix IO handles
+       JSR gNxtFH    ; get next file handle
        BCC -         ; file handle valid? continue
        JMP return

mlgetz  LDA #$00      ; page 4-32: word=MLGET(filename [,loadaddress])
        STA z34
        STA z35       ; set loadaddress to default 0
        JSR getprm
        .BYTE $12,$C0 ; 1-2 parms: WWxx xxxx
        .BYTE z34     ; store word on stack at z34: loadaddress
        .BYTE z2C     ; store word on stack at z2C: filename
        LDA nofnchk
        PHA
        SEC
        ROR nofnchk
        JSR bldFNam
        TAX
        PLA
        STA nofnchk
        TXA
        BCS +
        JSR hmlget
        CMP #$00
        BNE +
        LDA z34
        PHA
        LDA z35
        JMP retbyte
+       JMP ioerr

redirectz JSR getprm  ; page 4-49: REDIRECT {#stdin|#stdout} [,Handle]
        .BYTE $12,$C0 ; 1-2 parms, WWxx xxxx
        .BYTE z34     ; store word on stack at z34: Handle
        .BYTE z2C     ; store word on stack at z2C: #stdin or #stdout
        DEC numparms
        BEQ +
        JSR ckfh
        STA z37
+       LDA Stringv
        SEC
        SBC #$00
        TAX
        LDA Stringv+1
        SBC #$0C
        BNE ++
        CPX #$07
        BCS ++
        LDA numparms
        BEQ +
        LDA z34
        STA stdin,X
        LDA z35
        STA stdin+1,X
        JMP return
+       LDA reddefs,X
        STA stdin,X
        LDA reddefs+1,X
        STA stdin+1,X
        JMP return
+       JMP eiored

ckfh    LDA z34       ;Get file handle (from getlfz)
        CMP FHtabB
        LDA z35
        SBC FHtabB+1
        BCC _stdin     ; Less than first open file handle? check for stdin
        LDA z34
        CMP FHTabE
        LDA z35
        SBC FHTabE+1
        BCC _fhok     ; Good file handle, proceed
_stdin  LDA z34
        CMP #<skdev   ; $D8
        LDA z35
        SBC #>skdev   ; $0F
        BCC _err      ; Is it the K device?
        LDA z34
        CMP #<dstdin  ; $F8
        LDA z35
        SBC #>dstdin  ; $0F
        BCS _err      ; is it stdin?
_fhok   LDY #$FF
_fnam   INY
        LDA (z34),Y   ; Get file name
        BNE _fnam     ; zero byte: end of name
        CPY #$01
        BCC _err      ; less than two bytes? error out
        INY
        INY
        LDA (z34),Y
        TAX
        DEY
        LDA (z34),Y   ; return file handle
        RTS
_err    JMP efileh    ; invalid handle exception

toupperz PLA          ; page 4-56: bytevar=TOUPPER(Char)
        STA Parent
        PLA
        STA Parent+1
        CPY #$01
        BEQ _ok
        JMP esys
_ok     PLA
        PLA
        JSR ToUpper1  ; falls through to redbyte.

        ; return from library routine
retbyte PHA           ; put result on stack
return  LDA Parent+1  ; get caller address
        PHA
        LDA Parent
        PHA           ; put on stack
        RTS           ; return to caller

ToUpper1              ; convert character to uppercase
        CMP #$7B      ; 'z'+1
        BCS +         ; too high, exit
        CMP #$61      ; 'a'
        BCC +         ; too low, exit
        SBC #$20      ; subtract 'a' - 'A' difference
+       RTS

fillz   JSR getprm    ; page 4-14: FILL #From, Count [,Byteval]
        .BYTE $23,$60 ; 2-3 parms, BWWx xxxx
        .BYTE z38,$00 ; store $00 or byte on stack at z38: Byteval
        .BYTE z34     ; store word on stack at z34       : Count
        .BYTE z2C     ; store word on stack at z2C       : #From
        LDA z38
        LDY #$00
        LDX z35
        BEQ _frac
_full   STA (Stringv),Y
        INY
        BNE _full
        INC Stringv+1
        DEX
        BNE _full
_frac   LDX z34
        BEQ _exit
_loop   STA (Stringv),Y
        INY
        DEX
        BNE _loop
_exit   JMP return

setFold LDA z35       ; set z35 (fold) to $80 if it's nonzero
        BEQ +
        LDA #$80
        STA z35
+       RTS

cmpstrz JSR getprm    ; page 4-8: CMPSTR(String1, Op, String2 [,Fold [,Limit]])
        .BYTE $35,$38 ; 3-5 parms: BBWW Wxxx
        .BYTE z34,$FF ; store $ff or byte on stack at z34: Limit
        .BYTE z35,$00 ; store $00 or byte on stack at z35: Fold
        .BYTE z38     ; store word on stack at z38       : String2
        .BYTE z36     ; store word on stack at z36       : Op
        .BYTE z2C     ; store word on stack at z2C       : String1
        JSR setFold
        LDY #$00
        LDA (z36),Y
        CMP #$3C      ; '<' (less than?)
        BNE _ckGt
        INY
        LDA (z36),Y
        BEQ _islt
        CMP #$3E     ; '>' (not equal?)
        BEQ _isne
        CMP #$3D     ; '=' (less than or equal?)
        BEQ _isle
_err    JMP elibarg
_ckGt   CMP #$3E      ; '>' (greater than?)
        BNE _ckEq
        INY
        LDA (z36),Y
        BNE _CkE1
        JSR chkStr    ; check greater than
        BEQ _false
        BCS _itrue
        BCC _false
_CkE1   CMP #$3D      ; '=' (greater than or equal?)
        BNE _err 
        JSR chkStr    ; check greater/equal
        BEQ _itrue
        BCS _itrue
        BCC _false
_ckEq   CMP #$3D      ; '=' (equal?)
        BNE _err 
        JSR chkStr
        BEQ _itrue
        BNE _false
_islt   JSR chkStr    ; check less than
        BEQ _false
        BCS _false
        BCC _itrue
_isne   JSR chkStr    ; check not equal
        BEQ _false
_itrue  LDA #$01
        BNE _true
_isle   JSR chkStr    ; check less than or equal
        BEQ _itrue
        BCC _itrue
_false  LDA #$00
_true   JMP retbyte

substrz JSR getprm    ; page 4-55: bytevar=SUBSTR(Want, Try, [,Fold [,Max [,Limit]]])
        .BYTE $25,$18 ; 2-5 parms, BBBW Wxxx
        .BYTE z34,$FF ; store $ff or byte on stack at z34: Limit
        .BYTE z36,$FF ; store $ff or byte on stack at z36: Max
        .BYTE z35,$00 ; store $00 or byte on stack at z35: Fold
        .BYTE z38     ; store word on stack at z38       : Try
        .BYTE Stringv ; store word on stack at z2C       : Want
        LDX z36
        BNE _fold
        LDA #$FF
        STA z36
_fold   JSR setFold
        LDY #$00
_Ctry   LDA (z38),Y   ; measure Try's length
        BEQ _Etry
        INY
        BNE _Ctry
_Etry   STY z37       ; store Try's length
        LDY #$00
_Cwant  LDA (Stringv),Y; measure Want's length
        BEQ _Ewant
        INY
        BNE _Cwant
_Ewant  TYA
        CMP z34       ; Limit
        BCC _short
        LDA z34
_short  STA z34
        CLC
        SBC z37       ; Try's length
        BCS _notF
        STA z37
        LDX #$01
        SEC
        LDA #$00
        SBC z36
        CMP z37
        BCC _cmpS
        STA z37
_cmpS   JSR chkStr
        BEQ _found
        INC z38
        BNE _cont
        INC z39
_cont   INX
        INC z37
        BNE _cmpS     ; continue searching
_notF   LDA #$00      ; not found
        BEQ _exit
_found  TXA
_exit   JMP retbyte

chkStr  LDY #$FF      ; compare and search strings
_loop   INY
        CPY z34
        BEQ _equal
        LDA (z38),Y
        BEQ _less
        BIT z35
        BPL _nfold
        JSR ToUpper1
_nfold  STA hysav2
        LDA (Stringv),Y
        BEQ _more
        BIT z35
        BPL _nfold1
        JSR ToUpper1
_nfold1 CMP hysav2
        BEQ _loop
_equal  RTS
_less   LDA (Stringv),Y
        SEC
        RTS
_more   CMP #$01
        RTS

blkmovz JSR getprm    ; page 4-6: BLKMOV #From, #To, Count
        .BYTE $33,$E0 ; 3 parms: WWWx xxxx
        .BYTE z38     ; store word on stack at z38: Count
        .BYTE z34     ; store word on stack at z34: #To
        .BYTE z2C     ; store word on stack at z2C: #From
        LDA z34
        SEC
        SBC Stringv
        TAY
        LDA z35
        SBC Stringv+1
        TAX
        TYA
        CMP z38
        TXA
        SBC z39
        BCS _up
        LDA z39
        CLC
        ADC Stringv+1
        STA Stringv+1
        LDA z39
        CLC
        ADC z35
        STA z35
        LDY z38
        BEQ _Bdn
_down   DEY
        LDA (Stringv),Y
        STA (z34),Y
        CPY #$00
        BNE _down
_Bdn    LDX z39
        BEQ _exit
_pgdn   DEC Stringv+1
        DEC z35
_cPdn   DEY
        LDA (Stringv),Y
        STA (z34),Y
        CPY #$00
        BNE _cPdn
        DEX
        BNE _pgdn
        BEQ _exit
_up     LDY #$00
        LDX z39
        BEQ _count
_Bup    LDA (Stringv),Y
        STA (z34),Y
        INY
        BNE _Bup
        INC Stringv+1
        INC z35
        DEX
        BNE _Bup
_count  LDX z38
        BEQ _exit
_cPup   LDA (Stringv),Y
        STA (z34),Y
        INY
        DEX
        BNE _cPup
_exit   JMP return

lenstrz PLA           ; page 4-29: bytevar=LENSTR(String)
        STA Parent
        PLA
        STA Parent+1
        CPY #$01
        BEQ +
        JMP esys
+       PLA
        STA Stringv+1
        PLA
        STA Stringv
        LDY #$00
-       LDA (Stringv),Y
        BEQ +
        INY
        BNE -    
+       TYA
        JMP retbyte

movstrz PLA           ; page 4-33: MOVSTR FromString, ToString [,Limit]
        STA Parent
        PLA
        STA Parent+1
        LDA #$FF
        CPY #$03
        BNE _is2p
        PLA
        PLA
        DEY
_is2p   STA z38
        CPY #$02
        BEQ _ok
        JMP esys
_ok     PLA
        STA z35
        PLA
        STA z34
        PLA
        STA Stringv+1
        PLA
        STA Stringv
        LDA z34
        SEC
        SBC Stringv
        TAX
        LDA z35
        SBC Stringv+1
        BNE _count
        TXA
        CMP z38
        BCS _count
        LDY #$00
_loop   LDA (Stringv),Y
        BEQ _copyz
        INY
        CPY z38
        BCC _loop
        LDA #$00
        BEQ _cpwr
_copy   DEY
_copyz  LDA (Stringv),Y
_cpwr   STA (z34),Y
        CPY #$00
        BNE _copy
        BEQ _exit
_count  LDY #$00
        LDA z38
        BEQ _save
_cpup   LDA (Stringv),Y
        STA (z34),Y
        BEQ _exit
        INY
        CPY z38
        BCC _cpup
        LDA #$00
_save   STA (z34),Y
_exit   JMP return

alphaz  PLA           ; page 4-6: bytevar=ALPHA(Char)
        STA Parent
        PLA
        STA Parent+1
        CPY #$01
        BEQ g22AC
        JMP esys
g22AC   PLA
        PLA
        JSR IsAlpha
        BCC g22B8
g22B3   LDA #$01
        JMP retbyte
g22B8   LDA #$00
        JMP retbyte

numericz PLA         ; page 4-34: bytevar=NUMERIC(Char)
        STA Parent
        PLA
        STA Parent+1
        CPY #$01
        BEQ g22CA
        JMP esys
g22CA   PLA
        PLA
        JSR Ndigit
        BCC g22B8
        BCS g22B3

        ; determine if a character is not a digit
Ndigit  CMP #$3A     ;:
        BCS g22E8
        CMP #$30     ;0
        BCC g22E8
g22DB   SEC
        RTS

        ; determine if a character is an alphabet character
IsAlpha JSR ToUpper1
        CMP #$41
        BCC g22E8
        CMP #$5B
        BCC g22DB
g22E8   CLC
        RTS

getblkfz JSR getprm   ; page 4-18: wordvar=GETBLKF(Handle, #Start, Maxsize)
        .BYTE $33,$E0 ; 3 parms: WWWx xxxx
        .BYTE z38     ; store word on stack at z38: Maxsize
        .BYTE z36     ; store word on stack at z36: #Start
        .BYTE z34     ; store word on stack at z34: Handle
        JSR ckfh      ; validate file handle
        JSR rdck      ; ensure file can be read
        LDY #$36
        JSR hgetblkf  ; call HAL to load block
        TXA
        PHA
        TYA
        JMP retbyte   ; return with transfer size on stack

putblkfz JSR getprm   ; page 4-45: PUTBLKF Handle, #Start, Size
        .BYTE $33,$E0 ; 3 parms: WWWx xxxx
        .BYTE z38     ; store word on stack at z38: Size
        .BYTE z36     ; store word on stack at z36: #Start
        .BYTE z34     ; store word on stack at z34: Handle
        JSR ckfh
        JSR wrtck
        LDY #$36
        JSR hputblkf
        STX pblkcnt
        STY pblkcnt+1
        JMP return

inlistz LDA #$20      ; page 4-25: Word=INLIST(String,Listend[,Fold[,Limit[,Safety]]])
        STA z3F
        LDA #$00
        STA z3E
        JSR getprm
        .BYTE $25,$98 ; 2-5 parms: WBBW Wxxx
        .BYTE z3E     ; store word on stack at z3E       : Safety
        .BYTE z34,$FF ; store $ff or byte on stack at z34: Limit
        .BYTE z35,$00 ; store $00 or byte on stack at z35: Fold
        .BYTE z38     ; store word on stack at z38       : Listend
        .BYTE z2C     ; store word on stack at z2C       : String
        JSR setFold
        LDA #$00      ; invert Safety
        SEC
        SBC z3E
        STA z3E
        LDA #$00
        SBC z3F
        STA z3F
_loop   INC z3E       ; increment Safety
        BNE _search
        INC z3F
        BNE _search
        LDA #$00
        PHA
        BEQ _exit
_search LDA z38
        SEC
        SBC #$02
        STA z36
        LDA z39
        SBC #$00
        STA z37
        LDY #$01
        LDA (z36),Y
        STA z39
        DEY
        LDA (z36),Y
        STA z38
        ORA z39
        BEQ _found
        JSR chkStr
        BNE _loop
_found  LDA z38
        PHA
        LDA z39
_exit   JMP retbyte

lookstrz LDA #$FF     ; page 4-30: intvar=LOOKSTR(String,Plist[,Nstr[,Fold[,Limit]]])
        STA z36
        STA z37
        JSR getprm
        .BYTE $25,$38 ; 2-5 parms: BBWW Wxxx
        .BYTE z34,$FF ; store $ff or byte on stack at z34: Limit
        .BYTE z35,$00 ; store $00 or byte on stack at z35: Fold
        .BYTE z36     ; store word on stack at z36       : Nstr
        .BYTE z3E     ; store word on stack at z3E       : Plist
        .BYTE z2C     ; store word on stack at z2C       : String
        JSR setFold
        LDA #$00
        STA z3C
        STA z3D
_loop   LDA z36
        ORA z37
        BEQ _ebad
        LDY #$01      ; prepare to call chkStr
        LDA (z3E),Y
        STA z39
        DEY
        LDA (z3E),Y
        STA z38
        ORA z39
        BEQ _ebad
        JSR chkStr    ; compare strings
        BEQ _found
        LDA z3E
        CLC
        ADC #$02
        STA z3E
        BCC _Nstr
        INC z3F
_Nstr   LDA z36
        BNE _Nstrz
        DEC z37
_Nstrz  DEC z36
        INC z3C
        BNE _loop
        INC z3D
        BNE _loop
_ebad   LDA #$FF
        PHA
        BMI _exit     ; always branches
_found  LDA z3C
        PHA
        LDA z3D
_exit   JMP retbyte

cursetz PLA           ; page 4-10: CURSET column, line
        STA Parent
        PLA
        STA Parent+1
        CPY #$02
        BEQ +
        JMP esys
+       PLA
        PLA
        TAY
        PLA
        PLA
        TAX
        JSR hcurset
        JMP return

curcolz PLA           ; page 4-9: bytevar=CURCOL
        STA Parent
        PLA
        STA Parent+1
        CPY #$00
        BEQ +
        JMP esys
+       JSR hcurget
        TXA
        JMP retbyte

curlinez PLA          ; page 4-9: bytevar=CURLINE
        STA Parent
        PLA
        STA Parent+1
        CPY #$00
        BEQ +
        JMP esys
+       JSR hcurget
        TYA
        JMP retbyte

insetz  JSR getprm    ; page 4-27: bytevar=INSET(Char, String [,Meta])
        .BYTE $23,$40 ; 2-3 parms: BWBx xxxx
        .BYTE z38,$00 ; store $00 or byte on stack at z38: Meta
        .BYTE z34     ; store word on stack at z34       : String
        .BYTE z39     ; store byte on stack at z39       : Char (required)
        LDY #$FF
_loop   INY
        LDA (z34),Y
        BEQ _notf
_search INY
        BEQ _notf
        CMP z39
        BEQ _found
        CMP z38
        BEQ _check
        LDA (z34),Y
        BEQ _notf
        CMP z38
        BNE _search
        DEY
        LDA z39
        CMP (z34),Y
        INY
        BCC _loop
        INY
_check  LDA (z34),Y
        BEQ _found
        INY
        CMP z39
        BEQ _found
        DEY
        BCS _found
        BCC _loop
_notf   LDY #$00
_found  TYA
        JMP retbyte

randomz PLA           ; page 4-47: Wordvar=RANDOM [(Seed)]
        STA Parent
        PLA
        STA Parent+1
        CPY #$01
        BNE +
        PLA
        STA randwd+1
        PLA
        STA randwd
        DEY
+       CPY #$00
        BEQ +
        JMP esys
+       LDX #$08
-       LDA randwd
        LSR
        EOR randwd
        LSR
        LSR
        EOR randwd
        LSR
        EOR randwd+1
        LSR
        LSR
        LSR
        LSR
        ROL randwd+1
        ROL randwd
        DEX
        BNE -
        LDA randwd
        PHA
        LDA randwd+1
        JMP retbyte

testkeyz JSR getprm   ; page 4-55: bytevar=TESTKEY [(#Char)]
        .BYTE $01,$80 ; one parm: Wxxx xxxx
        .BYTE z2C     ; store word on stack at z2C: #Char
        JSR hconin
        LDY numparms
        BEQ +
        LDX #$00
        STA (Stringv,X)
+       JMP retbyte

minz    PLA           ; page 4-32: Wordvar=MIN(Val1, Val2 [,...])
        STA Parent
        PLA
        STA Parent+1
        CPY #$02
        BCS +
        JMP esys
+       PLA
        STA z39
        PLA
        STA z38
        DEY
-       PLA
        STA z35
        PLA
        TAX
        CMP z38
        LDA z35
        SBC z39
        BCS +
        STX z38
        LDA z35
        STA z39
+       DEY
        BNE -
        LDA z38
        PHA
        LDA z39
        JMP retbyte

maxz    PLA           ; page 4-31: wordvar=MAX(Val1, Val2 [,...])
        STA Parent
        PLA
        STA Parent+1
        CPY #$02
        BCS +
        JMP esys
+       PLA
        STA z39
        PLA
        STA z38
        DEY
-       PLA
        STA z35
        PLA
        TAX
        CMP z38
        LDA z35
        SBC z39
        BCC +
        STX z38
        LDA z35
        STA z39
+       DEY
        BNE -
        LDA z38
        PHA
        LDA z39
        JMP retbyte

inlinez CLC           ; page 4-25: bytevar=INLINE(String [,Limit [,Mode]])
        BCC g2516
edlinez SEC           ; page 4-12: bytevar=EDLINE(String [,Limit [,Mode [,#Col]]])
g2516   ROR z34
        LDA #<EdSCol
        STA z36
        LDA #>EdSCol
        STA z37
        LDA #$00
        STA EdSCol
        JSR getprm
        .BYTE $14,$90 ; 1-4 parms: WBBW xxxx
        .BYTE z36     ; store word on stack at z36       : #Col
        .BYTE z38,$00 ; store $00 or byte on stack at z38: Mode
        .BYTE z39,$50 ; store $50 or byte on stack at z39: Limit
        .BYTE z2C     ; store word on stack at z2C       : String
        LDA z38
        STA EdlnMode
        LDA z39
        BNE +
        LDA #$50
        STA z39
+       LDX Stringv
        LDY #$00
        LDA (z36),Y
        STA EdSCol
        TYA
        BIT z34
        BMI +
        STA (Stringv),Y
+       LDY Stringv+1
        LDA z39
        JSR hedline
        PHA
        LDY #$00
        LDA EdSCol
        STA (z36),Y
        JMP return

getargsz JSR getprm   ; page 4-17: bytevar=GETARGS(Argline, #Ptrlist [,Limit [,Sep]])
        .BYTE $24,$30 ; 2-4 parms: BBWW xxxx
        .BYTE z38,$20 ; store $20 or byte on stack at z38: Sep
        .BYTE z39,$08 ; store $08 or byte on stack at z39: Limit
        .BYTE z2C     ; store word on stack at z2C       : #Ptrlist
        .BYTE z34     ; store word on stack at z34       : Argline
        LDX #$00
        LDY #$FF
-       INY
        CPX z39
        BCS ++
        LDA (z34),Y
        BEQ ++
        CMP #$20
        BEQ -
        TYA
        STY z36
        CLC
        ADC z34
        PHA
        LDA z35
        ADC #$00
        PHA
        TXA
        ASL
        TAY
        INY
        PLA
        STA (Stringv),Y
        DEY
        PLA
        STA (Stringv),Y
        INX
        LDY z36
-       LDA (z34),Y
        BEQ ++
        CMP z38
        BEQ +
        INY
        BNE -
+       LDA #$00
        STA (z34),Y
        JMP --
+       TXA
        JMP retbyte

zapfilez JSR getprm   ; page 4-57: bytevar=ZAPFILE (Filename [,Wildflag])
        .BYTE $12,$40 ; 1-2 parms: BWxx xxxx
        .BYTE z38,$00 ; store $00 or byte on stack at z38: Wildflag
        .BYTE z2C     ; store word on stack at z2C       : Filename
        JSR bldFNam
        BCS +
	.if wdrv
        CPX #$01
        BEQ +
	.fi ;wdrv
        JSR hzapfile
        JMP retbyte
+       LDA FName
	.if wdrv
        CMP #$57      ; 'W' file
        BEQ +
	.fi ;wdrv
        LDA #$02
        JMP retbyte
	.if wdrv
+       LDA worg
        STA weof
        STA wptr
        LDA worg+1
        STA weof+1
        STA wptr+1
        LDA #$00
        JMP retbyte
	.fi ;wdrv

chksumz JSR getprm    ; page 4-7: wordvar=CHKSUM(#Start, Size)
        .BYTE $22,$C0 ; 2 parms: WWxx xxxx
        .BYTE z34     ; store word on stack at z34: Size
        .BYTE z36     ; store word on stack at z36: #Start
        LDX z34       ; Size low
        LDY #$00
        STY z39
        LDA z35       ; Size high
        BEQ _byte
        LDA #$00
_page   CLC
        ADC (z36),Y
        BCC _pagez
        INC z39
_pagez  INY
        BNE _page
        INC z37
        DEC z35
        BNE _page
_byte   CPX #$00      ; nothing to checksum (0 size)?
        BEQ _exit
_sum    CLC
        ADC (z36),Y
        BCC _sumz
        INC z39
_sumz   INY
        DEX
        BNE _sum
_exit   PHA
        LDA z39
        JMP retbyte

drvcmdz LDA prefix    ; undocumented: bytevar=DRVCMD(#command [, Drive])
        STA z38
        JSR getprm
        .BYTE $12,$C0 ; 1-2 parms: WWxx xxxx
        .BYTE z38     ; store word on stack at z38: Drive
        .BYTE z36     ; store word on stack at z36: #command
        LDX z36
        LDY z37
        LDA z38
        JSR hdrvcmd   ; send command to drive and get response
        STA ioerror   ; save the drive's error code (in binary)
        JMP return

dirz    LDA #$00      ; page 4-10: intvar=DIR(Pattern [,Mode])
        STA z35
        LDA #$01
        STA z34       ; set mode to 1
        JSR getprm
        .BYTE $12,$C0 ; 1-2 parms: WWxx xxxx
        .BYTE z34     ; store word on stack at z34: Mode
        .BYTE z2C     ; store word on stack at z2C: Pattern
        JSR bldFNam
        BCS _err
        LDA z35
        BNE _pat
        LDA #$00
        SEC
        SBC z34
        BEQ _hdir
        CMP #$FF
        BEQ _hdir
        LDA #$01
        BNE _err
_hdir   JSR hdir
        JMP _done
_pat    JSR ckfh
        TXA
        JSR hdir
_done   BCS _err
        PHA
        LDA #$00
        BEQ _exit     ; always branches
_err    STA z38
        LDA #$00
        SEC
        SBC z38
        PHA
        LDA #$FF
_exit   JMP retbyte

renamez JSR getprm    ; page 4-50: bytevar=RENAME(Oldfile, Newfile)
        .BYTE $22,$C0 ; 2 parms: WWxx xxxx
        .BYTE z34     ; store word on stack at z34: Newfile
        .BYTE z2C     ; store word on stack at z2c: Oldfile
        JSR bldFNam
        BCS +
        CPX #$01
        BEQ +
        JSR s3CEC
        LDA z34
        STA Stringv
        LDA z35
        STA Stringv+1
        JSR FNameLen
        JSR hrename
        JMP retbyte
+       LDA #$02
        JMP retbyte

fkeysetz PLA          ; page 4-16: FKEYSET Keynumber, String
        STA Parent
        PLA
        STA Parent+1
        CPY #$02
        BEQ +
        JMP esys
+       PLA
        TAY
        PLA
        TAX
        PLA
        PLA
        JSR hfkset
        JMP return

fkeygetz PLA          ; page 4-15: FKEYGET Keynumber, #String
        STA Parent
        PLA
        STA Parent+1
        CPY #$02
        BEQ +
        JMP esys
+       PLA
        TAY
        PLA
        TAX
        PLA
        PLA
        JSR hfkget
        JMP return

abortz  LDA #$01      ; page 4-5: ABORT [Arglist]
        BNE exitz1

exitz   LDA #$00      ; page 4-14: EXIT [Arglist]
exitz1  STA exitcode
        PLA
        PLA
        CPY #$00
        BEQ +
        JSR OUTPUT    ; use OUTPUT to handle Arglist
+       JMP r283e     ; abort current program

loadz   LDX PrgPtr    ; page 4-30: LOAD Progname [,Flags]
        PLA           ; save current state (.X contains current program ID)
        STA mlRTSL,X
        PLA
        STA mlRTSh,X
        LDA PBase
        STA pRTSL,X
        LDA PBase+1
        STA pRTSh,X
        LDA #$00
        STA LDRESUME
        STA lderr
        STA errtyp
        STA exitcode
        STA OWNFlag
        CPY #$02     ; LDFLAGS provided?
        BNE _dflt    ; no, load with defaults
        PLA
        PLA          ; get ldflags
        DEY
_dflt   STA ldflags
        CPY #$01
        BEQ _load    ; Correct number of parms; continue
        JMP esys
_load   PLA          ; set up file name vector
        STA Stringv+1
        PLA
        STA Stringv
        TSX           ; get stack pointer
        TXA
        LDX PrgPtr    ; get program ID again
        STA Pstkptr,X ; save current program state
        LDA fltptr
        STA Pfltptr,X
        LDA Heapptrq
        STA Pheappq,X
        LDA HeapVec
        STA Pheapl,X
	.if ldrv
        CPX #$00      ; are we program ID 0?
        BNE _skipL
        JSR fixLptrs
	.fi ;ldrv
_skipL  JSR s28F3     ; set up LDFLAGs and filename
        LDA LDUNLD
        BPL _unld
        JSR chknam
        BCS _exit
        JSR cleanup
_exit   JMP startprg
_unld   LDA LDPRCLR
        BPL _clear
        STA LDCHAIN
_clear  LDA LDCHAIN
        BPL _chain
        STA LDRELD
        LDX PrgPtr
        BIT LDPRCLR
        BPL _clearz
        LDX numprgsq
_clearz JSR cleanup
        LDX #$00
        STX PrgPtr
        BEQ _open
_chain  JSR qinmem
        BCS _open
        BIT LDRELD
        BPL _reld
        JSR cleanup
        JMP _open
_reld   BIT LDNOGO
        BMI _nogo
        SEC
        ROR LDRESUME
        JSR MMUcpy
        STX PrgPtr
_nogo   JMP startprg
_open   LDA Stringv
        PHA
        LDA Stringv+1
        PHA
        LDY #$01
        JSR OPEN
        PLA
        STA LoadFH+1
        PLA
        STA LoadFH
        ORA LoadFH+1
        BEQ _err1
        JSR gheader
        BCS _err2    ;carry set if header <$20 bytes
        CMP #$CE     ;$CE = promal program
        BEQ _isprg
        CMP #$CD
        BNE _err2
_isprg  LDA FHCDBA+1
        STA p0BEB
        LDA newvarb  ; contains OWN flag during header load
        CMP #$FF
        BEQ _notown
        DEC OWNFlag
_notown JSR Ldalloc
        BCS _err3
        JSR getblob
        BCC _blobOK
        LDX xsav
        JSR cleanup
        JMP _err2
_blobOK JSR relocate ; perform relocation on loaded program
        BCC _cksum   ; relocation ok? set program checksum.
        LDX xsav
        JSR cleanup  ; close file
        JMP _err4
_cksum  LDX xsav     ; set program checksum and store in loader table
        JSR Chksprg
        LDX xsav
        STA Pcksuml,X
        TYA
        STA Pcksumh,X
        BIT LDNOGO
        BMI _dontgo
        SEC
        ROR LDRESUME
        STX PrgPtr
        JMP _dontgo
_err4   INC lderr
_err3   INC lderr
_err2   INC lderr
_err1   INC lderr
_dontgo LDA LoadFH
        ORA LoadFH+1
        BEQ _closed
        LDA LoadFH
        PHA
        LDA LoadFH+1
        PHA
        LDY #$01
        JSR CLOSE
_closed JMP startprg

r283ez  CLD           ; exit or abort program and handle exception
        LDA #$00
        STA LDRESUME
        LDX PrgPtr
        LDA Pldflags,X
        AND #$08      ; LDRECLM?
        BEQ _reclm
        JSR cleanup
_reclm  LDX PrgPtr
        LDA exitcode
        BEQ _unld
        CPX #$00
        BNE _abort
        JMP trap3     ; trap 3: program abort
_abort  LDA #$00
        BEQ _start
_unld   LDA Pparent,X
        CMP nlt
        BCC _start
        LDA #$00
_start  STA PrgPtr    ; follows through to startprg.

startprg CLD          ; start or resume program
        LDA #$00
        STA PrgBit
        LDX PrgPtr
        LDA PVARSh,X
        STA varbase+1
        LDA Pfltptr,X
        STA fltptr
        LDA Pheappq,X
        STA Heapptrq
        LDA Pheapl,X
        STA HeapVec
        LDA Pstkptr,X
        TAX
        TXS
        LDX PrgPtr
        BIT LDRESUME
        BPL _resume
        LDA ldflags
        STA Pldflags,X
        LDY #$00
        STY PBase
        STA pRTSL,X
        LDA PBAh,X
        STA PBase+1
        STA pRTSh,X
        LDA PTYPE,X
        AND #$01
        BNE _ml
        JMP Pnext
_resume .if ldrv
	CPX #$00      ; program ID 0 (editor)?
        BNE _skipL
        JSR fixLptrs
        LDX PrgPtr
_skipL  .fi ;ldrv
	LDA pRTSL,X
        STA PBase
        LDA pRTSh,X
        STA PBase+1
        LDA mlRTSh,X
        PHA
        LDA mlRTSL,X
        PHA
        RTS
_ml     LDA #$0F
        PHA
        LDA #$02
        PHA
        JMP (PBase)
trap3   LDX #$FF
        TXS
        LDA #<_trap3
        STA PBase
        LDA #>_trap3
        STA PBase+1
        LDY #$00
        JMP Pnext
_trap3  .BYTE $56,$03 ; p-code: 'REFUGE 03'
        .BYTE $00

s28F3   JSR FNameLen  ; set filename and ldflags
_loop   DEY
        BMI _done
        LDA (Stringv),Y
        CMP #$FF
        BEQ _done
        CMP #$3A     ;':'
        BNE _loop    ;Search backwards for :
_done   LDX #$00
_ucase  INY
        LDA (Stringv),Y
        BEQ _end
        JSR ToUpper1 ;Convert file name to upper case
        STA ldname,X
        CMP #$2E     ;'.'
        BEQ _end
        INX
        CPX #$0C     ;12 = max file len?
        BNE _ucase
        DEX
_end    LDA #$00
        STA ldname,X
        LDX #$00
        LDA ldflags
_flag   LSR
        ROR LDCHAIN,X
        INX
        CPX #$08
        BCC _flag
        RTS

        ; Check to see if a program is already in the loader tables.
chknam  LDX nlt        ; Get number of table entries
        BEQ _ntfnd     ; None? Error out.
        DEX
_next   LDA PCOMDvl,X  ; Set vector
        STA z34        ;   up for
        LDA PCOMDvh,X  ;   program name
        STA z35        ;   compare
        LDY #$FF       ; pre-decrement for wraparound
_char   INY
        LDA (z34),Y    ; Get file name from name table
        BEQ _EOnam     ; Check for end of ascii-z string
        CMP ldname,Y   ; Check name in load attempt
        BEQ _char      ; Same, continue
_nnam   DEX
        BPL _next      ; x > 0; more filenames to check
        BMI _ntfnd     ; x < 0; out of names to check
_EOnam  CMP ldname,Y   ; loaded name ended too?
        BNE _nnam      ; No, continue.
        CLC
        RTS
_ntfnd  SEC
        RTS


        ; Determine if a program's already loaded.
        ; BUG: setting ldnochk prevents promal from checking edres
qinmem  JSR chknam    ; Is command name in tables?
        BCS _error    ; No, set error and return.
        STX xsav      ; Save .X
        LDA ldnochk   ; Verify checksum?
        BNE _isok     ; No, skip to 'ok' status
        LDA PTYPE,X   ; Get program type from table
        AND #$01      ; is ML program? (p-code progs use even types)
        BNE _isok     ; Yes, indicate OK.
        CPX #$01      ; Is matched program ID 1? (editor)
        BNE _chkp     ; No, continue to checksum
        LDA edres     ; Is the editor loaded?
        BEQ _clnup    ; No, cleanup and indicate error.
_chkp   JSR Chksprg   ; Run a checksum on program's memory area
        LDX xsav      ; Restore .X
        CMP Pcksuml,X ; Match from table?
        BNE _clnup    ; No, error.
        TYA
        CMP Pcksumh,X ; Match from table?
        BNE _clnup    ; No, cleanup and indicate error.
_isok   CLC
        RTS
_clnup  JSR cleanup   ; Clean up table entry for damaged program
_error  SEC
        RTS

        ; Verify a program's checksum in memory.
Chksprg LDA #$00      ; All programs start at $xx00
        PHA
        LDA PBAh,X    ; Get page program starts at
        PHA
        LDA #$00      ; Always check full page
        PHA
        LDA PPPAGES,X ; Get size of program in pages
        PHA
        LDY #$02      ; 2 parameters for chksum
        JSR CHKSUM    ; chksum (program base, program size)
        PLA
        TAY
        PLA
        RTS

	.if wdrv
fxWfile TXA           ; adjust W file after cleanup
        PHA
        LDA Stringv
        PHA
        LDA Stringv+1
        PHA
        LDA worg
        STA wlim
        PHA
        LDA worg+1
        STA wlim+1
        PHA
        LDA #$00
        STA worg
        PHA
        CMP wsize
        LDA gvorg+1
        SBC wsize+1
        STA worg+1
        PHA
        SEC
        LDA weof
        SBC wlim
        PHA
        LDA weof+1
        SBC wlim+1
        PHA
        LDY #$03
        JSR blkmov
        SEC
        LDA worg
        SBC wlim
        STA wlim
        LDA worg+1
        SBC wlim+1
        STA wlim+1
        CLC
        LDA wptr
        ADC wlim
        STA wptr
        LDA wptr+1
        ADC wlim+1
        STA wptr+1
        CLC
        LDA weof
        ADC wlim
        STA weof
        LDA weof+1
        ADC wlim+1
        STA weof+1
        LDA wsize
        STA wlim
        LDA gvorg+1
        STA wlim+1
        PLA
        STA Stringv+1
        PLA
        STA Stringv
        PLA
        TAX
        LDA worg+1
        RTS
	.fi ;wdrv

cleanup CPX nlt       ; close file and release handle
        BCS _exit
        CPX PrgPtr
        BCS _npar
        LDA Pparent,X
        STA PrgPtr
_npar   CPX numprgsq
        BCC _done
        STX nlt
        LDA PBAh,X
        STA lofree+1
        LDA himem+1
        STA CUsctch
        LDX #$00
        STX lofree
        STX hifree
        LDX numprgsq
        DEX
_find   INX
        CPX nlt
        BEQ _setm
        LDA PVARSh,X
        CMP lofree+1
        BCC _find
        CMP CUsctch
        BCS _find
        STA CUsctch
_setm   LDA CUsctch
        STA gvorg+1
	.if wdrv
        JSR fxWfile
	.fi ;wdrv
        STA hifree+1
_exit   RTS
_done   LDA #$00
        SEC
_loop   ROR
        DEX
        BPL _loop
        STA PrgBit
        RTS

ldrAlloc JSR calcmem  ; prep for memory allocation
        CLC
        ADC lofree+1
        STA PVARSh,X
        BIT OWNFlag
        BPL _ownF
        CLC
        ADC PVPAGES,X
_ownF   CMP hifree+1
        BEQ _ok
        BCS _err
_ok     STA p0BCE
        BIT OWNFlag
        BMI _ownFS
        LDA himem+1
        SEC
        SBC PVPAGES,X
        STA PVARSh,X
        CMP p0BCE
        BCC _err
        LDA #$00
        CMP wsize
        LDA PVARSh,X
        SBC wsize+1
        CMP p0BCE
        BCC _err
_ownFS  LDA FTYPE
        LSR
        BCC _skip
        LDA lofree+1
        STA PVARSh,X
        CLC
_skip   RTS
_err    SEC
        RTS

calcmem LDA FHscvar   ; calculate variable and code space needs
        CLC
        ADC FHshvar
        TAY
        LDA FHshvar+1
        ADC #$00
        STA PVPAGES,X
        TYA
        BEQ g2AF7
        INC PVPAGES,X
g2AF7   LDY FHCDSZ+1
        INY
        TYA
        STA PPPAGES,X
        RTS

Ldalloc LDX nlt       ; allocate memory for loader
        LDA PrgBit
        BEQ g2B0B
        JMP j2BCB
g2B0B   CPX #$08
        BCS g2B14
        JSR ldrAlloc
        BCC g2B30
g2B14   LDA FTYPE
        AND #$04
        BEQ g2B1E
        JMP j2BA9
g2B1E   LDX nlt
        DEX
        CPX numprgsq
        BCS g2B2A
        JMP j2BA9
g2B2A   JSR cleanup
        JMP g2B0B
g2B30   LDA lofree+1
        STA PBAh,X
        LDA p0BCE
        STA lofree+1
        LDA PVARSh,X
        BIT OWNFlag
        BMI g2B55
        CMP gvorg+1
        BCS g2B55
        STA gvorg+1
	.if wdrv
        JSR fxWfile
	.fi ;wdrv
        STA hifree+1
        LDA gvorg+1
g2B55   STA newvarb
        INC nlt
j2B5B   LDA #$00
        STA lofree
        STA hifree
        STA gvorg
        STA FHCDBA
        STA FHbyte08
        LDA PCOMDvl,X
        STA Stringv
        LDA PCOMDvh,X
        STA Stringv+1
        LDY #$0B      ;11 chars in command name
g2B78   LDA FHCOMD,Y
        JSR ToUpper1
        STA (Stringv),Y
        DEY
        BPL g2B78
        LDA FTYPE
        STA PTYPE,X
        JSR MMUcpy
        LDA FHDATEd
        STA PDATEd,X
        LDA FHDATEm
        STA PDATEm,X
        LDA FHDATEy
        STA PDATEy,X
        LDA PBAh,X
        STA FHCDBA+1
        STX xsav
        CLC
        RTS
j2BA9   SEC
        RTS

MMUcpy  LDY PrgPtr    ; copy loader table entry
        TYA
        STA Pparent,X
        LDA Pstkptr,Y
        STA Pstkptr,X
        LDA Pfltptr,Y
        STA Pfltptr,X
        LDA Pheappq,Y
        STA Pheappq,X
        LDA Pheapl,Y
        STA Pheapl,X
        RTS

j2BCB   LDX #$00
        BIT PrgBit
        BMI g2BFB
        LDA #$01
        STA edres
        LDA #<edload  ;$1C
        PHA
        LDA #>edload  ;$2C
        PHA
        LDY #$01
        JSR PUT
        LDX #$01
        JSR calcmem
        LDA #$D0
        SEC
        SBC PPPAGES,X
        CMP osorg+1
        BCC j2BA9
        LDA osorg+1
        SEC
        SBC PVPAGES,X
        BNE g2C0D
g2BFB   JSR calcmem
        CLC
        LDA osorg+1
        ADC PPPAGES,X
        PHA
        ADC PVPAGES,X
        STA lorg+1	; l file
        PLA
g2C0D   STA newvarb
        STA PVARSh,X
        LDA osorg+1
        STA PBAh,X
        JMP j2B5B
edload  .BYTE $0D
        .TEXT "LOADING EDITOR"
        .BYTE $00

gheader LDA LoadFH    ; get program header
        PHA
        LDA LoadFH+1  ; File name location
        PHA
        LDA #<FHEAD   ; $2F
        PHA
        LDA #>FHEAD   ; $0C; Place file header at 0c2f
        PHA
        LDA #$20
        PHA
        LDA #$00      ; load max $20 bytes
        PHA
        LDY #$03      ; 3 parameters
        JSR GETBLKF   ; GETBLKF (<handle>, FHEAD, $0020)
        PLA
        PLA
        CMP #$20      ; got a full header
        BNE g2C50     ; no, something went wrong
        LDA FHEAD
        CLC
        RTS           ; return with file type and clear carry
g2C50   SEC
        RTS

getblob LDA LoadFH    ; get program code data
        PHA
        LDA LoadFH+1
        PHA
        LDA FHCDBA    ; Destination (gets filled during load)
        PHA
        LDA FHCDBA+1
        PHA
        LDA FHCDSZ    ; Size to load (from file header loaded by gheader)
        PHA
        LDA FHCDSZ+1
        PHA
        LDY #$03
        JSR GETBLKF   ; getblkf (<handle>, progbase, progsize)
        PLA
        CMP FHCDSZ+1  ; Check for correct blob size
        BNE g2C7D
        PLA
        CMP FHCDSZ
        BNE g2C7E
        CLC
        RTS
g2C7D   PLA
g2C7E   SEC
        RTS

relocz  JSR greloctbl ; Get next relocation table
        BCS relErr    ; Pass error status upstream as needed
        LDA RelHtyp   ; Get relocation header type
        BEQ relDone   ; if type=null, we're done
        CMP #$46      ; Type 'F'?
        BNE relNF     ; No, check for next type
        JSR RelocF    ; Process table type F.  This table has been reverse engineered.
        JMP relocz    ; Loop back for next table
relNF   CMP #$4C      ; Type 'L'?
        BNE relNL     ; No, check for next type
        JSR RelocL    ; Process table type L.  Undocumented table type.
        JMP relocz    ; Loop back for next table
relNL   CMP #$49      ; Type 'I'?
        BNE relNI     ; No, check for next type
        JSR RelocI    ; Process table type I.  Undocumented table type.
        BCS relErr    ; Pass error upstream as needed
        JMP relocz    ; Loop back for next table
relNI   CMP #$41      ; Type 'A'?
        BNE relErr    ; No, error out.
        JSR RelocA    ; Process table type A.  Documented in appendix I.
        JMP relOK     ; Finished relocating
relDone JSR s2CBB
relOK   CLC
        RTS
relErr  SEC
        RTS

s2CBB   LDA FHCDBA    ; Get base address low from header
        STA Stringv   ; drop it in our favorite vector
        CLC
        ADC FHCDSZ    ; Add FHCDBA(base)+FHCDSZ(size)
        STA progend   ; Store for later use
        LDA FHCDBA+1  ; Get base address high from header
        STA Stringv+1 ; finish up our favorite vector
        ADC FHCDSZ+1  ; add the other half of base+size
        STA progend+1 ; Save for later use
        LDY #$00
        JMP j2CDF
j2CD7   LDY #$00
g2CD9   INC Stringv
        BNE j2CDF
        INC Stringv+1
j2CDF   LDA Stringv    ; See if we're past end of program
        CMP progend
        LDA Stringv+1
        SBC progend+1
        BCC g2CEE     ; clear=not yet
        JMP j2D7A
g2CEE   LDA (Stringv),Y;Get byte from blob
        LSR
        BCC g2D2D     ; Is it even?  Skip to 2d2d
        ROL
        CMP #$01      ; Is it 1?
        BNE g2D0F     ; No, check some more
        INY
        LDA (Stringv),Y; Get next byte (low)
        CLC
        ADC FHCDBA    ; Add base address
        TAX
        INY
        LDA (Stringv),Y; Get next byte (high)
        ADC FHCDBA+1   ; Add base address
        STA Stringv+1  ; Store new address in our vector
        STX Stringv
        LDY #$00
        JMP j2CDF      ; repeat
g2D0F   CMP #$63
        BCC g2D1A
        SBC #$63
        STA (Stringv),Y
        JMP RAdVbas
g2D1A   CMP #$33
        BCC g2D25
        SBC #$33
        STA (Stringv),Y
        JMP j2D52
g2D25   SEC
        SBC #$03
        STA (Stringv),Y
        JMP j2D39
g2D2D   CMP #$2D      ; is it > 2d? (was it > 5A before LSR?)
        BCS g2CD9     ; Only $2d entries in the table at 2da8, skip
        TAX
        LDA Roper,X   ; Get relocation opcode(?)
        CMP #$00      ; No operation (skip opsize bytes)
        BNE RAdPbas   ; No, check for 3
j2D39   LDA (Stringv),Y; Get byte from program
        LDY #$00      ; Clear Y
        LSR
        TAX
        LDA Ropsz,X   ; Get operand size in bytes
        SEC
        ADC Stringv   ; Set pointer to target
        STA Stringv
        BCC j2CDF
        INC Stringv+1
        JMP j2CDF     ; repeat
RAdPbas CMP #$03      ; Add.w base address of program to (vector+1)
        BNE RAdVbas
j2D52   LDX FHCDBA+1
        LDA FHCDBA
        JMP RAddax
; Opers can be 0, 2, or 3.  0 and 3 are already checked, this is default (2)
RAdVbas LDX newvarb   ; Add variables' base address to (vector+1)
        LDA FHscvar   ; This byte is only written duing header load
RAddax  INC Stringv   ; add word .x.a to (from)+1 and loop
        BNE g2D67
        INC Stringv+1
g2D67   CLC
        ADC (Stringv),Y
        STA (Stringv),Y
        INC Stringv
        BNE g2D72
        INC Stringv+1
g2D72   TXA
        ADC (Stringv),Y
        STA (Stringv),Y
        JMP j2CD7
j2D7A   RTS
Ropsz   .BYTE $00,$02,$02,$02,$02,$02,$02,$02
        .BYTE $02,$02,$02,$02,$02,$02,$02,$02
        .BYTE $02,$02,$02,$03,$02,$02,$02,$01
        .BYTE $01,$02,$06,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$02,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01
Roper   .BYTE $00,$02,$02,$02,$02,$02,$02,$02
        .BYTE $02,$02,$02,$02,$02,$02,$02,$02
        .BYTE $02,$03,$03,$00,$03,$03,$03,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00

RelocF  LDA #$05
        STA relEsz
        LDA zrelsz
        ORA zrelsz+1
        BEQ g2E12
g2DE0   LDY #$00
        LDA (Stringv),Y
        PHA
        JSR Inc2c
        JSR RcpPtr
        PLA
        BEQ g2DFE
        LDA (Stringv),Y
        STA (z34),Y
        INY
        CLC
        LDA (Stringv),Y
        ADC FHCDBA+1
        STA (z34),Y
        JMP j2E07
g2DFE   LDA (Stringv),Y
        STA (z34),Y
        INY
        LDA (Stringv),Y
        STA (z34),Y
j2E07   JSR Inc2c
        JSR Inc2c
        JSR subrelsz
        BNE g2DE0
g2E12   RTS

RelocI  LDA #$01
        STA relEsz
        LDY #$FF
g2E1A   INY
        JSR subrelsz
        BEQ g2E97
        LDA (Stringv),Y
        STA ldname,Y
        BNE g2E1A
        TYA
        SEC
        ADC Stringv
        PHA
        LDA Stringv+1
        ADC #$00
        PHA
        LDA #$05
        STA relEsz
        JSR chknam
        PLA
        STA Stringv+1
        PLA
        STA Stringv
        BCS g2E99
g2E41   LDY #$00
        LDA (Stringv),Y
        PHA
        JSR Inc2c
        JSR RcpPtr
g2E4C   LDY #$00
        LDA (z34),Y
        STA p0BD3
        INY
        LDA (z34),Y
        STA p0BD4
        PLA
        PHA
        CMP #$FF
        BNE g2E65
        LDA PBAh,X
        JMP j2E68
g2E65   LDA PVARSh,X
j2E68   CLC
        ADC (Stringv),Y
        STA (z34),Y
        DEY
        LDA (Stringv),Y
        STA (z34),Y
        LDA p0BD4
        CLC
        ADC FHCDBA+1
        STA z35
        LDA p0BD3
        STA z34
        CMP #$FF
        BNE g2E4C
        LDA p0BD4
        CMP #$FF
        BNE g2E4C
        PLA
        JSR Inc2c
        JSR Inc2c
        JSR subrelsz
        BNE g2E41
g2E97   CLC
        RTS
g2E99   SEC
        RTS

RelocL  LDA #$02
        STA relEsz
        LDA zrelsz
        ORA zrelsz+1
        BEQ g2EBB
g2EA6   JSR RcpPtr
        LDA (z34),Y
        STA (z34),Y
        INY
        CLC
        LDA (z34),Y
        ADC FHCDBA+1
        STA (z34),Y
        JSR subrelsz
        BNE g2EA6
g2EBB   RTS

RelocA  LDA FHCDBA+1
        SEC
        SBC p0BEB
        STA p0BEB
        LDA #$02
        STA relEsz
        LDA zrelsz
        ORA zrelsz+1
        BEQ g2EE1
g2ED1   JSR RcpPtr
        LDA (z34),Y
        CLC
        ADC p0BEB
        STA (z34),Y
        JSR subrelsz
        BNE g2ED1
g2EE1   RTS

subrelsz LDA zrelsz
        SEC
        SBC relEsz
        STA zrelsz
        LDA zrelsz+1
        SBC #$00
        STA zrelsz+1
        ORA zrelsz
        RTS

RcpPtr  LDY #$00
        LDA (Stringv),Y
        STA z34
        JSR Inc2c
        CLC
        LDA (Stringv),Y
        ADC FHCDBA+1
        STA z35
Inc2c   INC Stringv
        BNE g2F0A
        INC Stringv+1
g2F0A   RTS

greloctbl LDA LoadFH  ; load relocation table
        PHA
        LDA LoadFH+1
        PHA
        LDA FHEAD     ; get filetype
        CMP #$CD      ; PROMAL file type
        BNE g2F2E     ;
        LDA #$52      ; 'R'
        STA RelHdr
        LDA #$4C      ; 'L'
        STA RelHtyp
        LDA #$BE
        PHA
        LDA #$0B
        PHA
        LDA #$02
        BNE g2F36
g2F2E   LDA #<RelHdr  ; $BC
        PHA
        LDA #>RelHdr  ; $0B
        PHA
        LDA #$04      ; 4 bytes
g2F36   PHA
        LDA #$00
        PHA
        LDY #$03      ; 3 parameters
        JSR GETBLKF   ; getblkf (<handle>, RelHdr, $0004)
        PLA
        PLA
        BNE g2F48
        STA RelHtyp
        BEQ g2F85
g2F48   LDA RelHdr    ; get header type
        CMP #$52      ; 'R'?
        BNE g2F88     ; invalid header, error out
        JSR RChkMem   ; enough free memory to load the table?
        BCS g2F88     ; no, error.
        LDA LoadFH
        PHA
        LDA LoadFH+1
        PHA
        LDA lofree
        STA Stringv
        PHA
        LDA lofree+1
        STA Stringv+1
        PHA
        LDA relsz
        STA zrelsz
        PHA
        LDA relsz+1
        STA zrelsz+1
        PHA
        LDY #$03
        JSR GETBLKF   ; getblkf (handle, lofree, relsz)
        PLA
        CMP relsz+1
        BNE g2F87
        PLA
        CMP relsz     ; did we get the full table?
        BNE g2F88     ; no, error out
g2F85   CLC
        RTS
g2F87   PLA
g2F88   SEC
        RTS

RChkMem LDA hifree    ; ensure enough memory is available for relocation table
        SEC
        SBC lofree
        STA maxparms  ; temporary storage
        LDA hifree+1
        SBC lofree+1
        STA numparms  ; temporary storage
        LDA relsz
        CMP maxparms
        LDA relsz+1
        SBC numparms
        .if wdrv
	BCC g2FEA
        LDA weof
        CMP worg
        BNE g2FB7
        LDA weof+1
        CMP worg+1
        BEQ g2FCF
g2FB7   LDA LDbit7
        SEC
        BEQ g2FEA
        LDA worg
        STA wptr
        STA weof
        LDA worg+1
        STA wptr+1
        STA weof+1
g2FCF   LDA wlim
        SEC
        SBC lofree
        STA maxparms
        LDA wlim+1
        SBC lofree+1
        STA numparms
        LDA relsz
        CMP maxparms
        LDA relsz+1
        SBC numparms
g2FEA   .fi ;wdrv
	RTS

swpmemz JSR getprm    ; undocumented: swpmem (area1base, area2base, size) ; all words
        .BYTE $33,$E0 ; 3 parms: WWWx xxxx
        .BYTE z38     ; store word on stack at z38: size
        .BYTE z36     ; store word on stack at z36: area2base
        .BYTE z34     ; store word on stack at z34: area1base
        LDX z35
        LDA z34
        LDY #$36
        JSR hswpmem
        JMP return

	.if ldrv
fixLptrs LDA PrgBit    ; was s2FFF: Adjust library pointers
        BMI g305A
        LDA osorg
        PHA
        LDA osorg+1
        PHA
        LDA maxmem
        PHA
        LDA maxmem+1
        PHA
        LDA ESwpSz
        PHA
        LDA ESwpSz+1
        PHA
        LDY #$03
        JSR swpmem
        LDA Exres
        EOR #$80
        STA Exres
        LDX #$06
g302B   LDA lorg,X
        BIT Exres
        BPL g3046
        CLC
        ADC p0BD0
        STA lorg,X
        LDA lorg+1,X
        ADC p0BD1
        STA lorg+1,X
        JMP j3056
g3046   SEC
        SBC p0BD0
        STA lorg,X
        LDA lorg+1,X
        SBC p0BD1
        STA lorg+1,X
j3056   DEX
        DEX
        BPL g302B
g305A   RTS
	.fi ;ldrv

norealz LDX #$00      ; disable real math routines and free their memory
g305D   LDY realcodes,X
        BEQ g306F
        LDA #<eillop
        STA dsptchl,Y
        LDA #>eillop
        STA dsptchh,Y
        INX
        BNE g305D
g306F   LDX #$00
g3071   LDA realjmps,X
        STA Stringv
        INX
        LDA realjmps,X
        BEQ g308C
        STA Stringv+1
        LDY #$01
        LDA #<erun
        STA (Stringv),Y
        INY
        LDA #>erun
        STA (Stringv),Y
        INX
        BNE g3071
g308C   LDA #$00
        STA lomem
        STA lofree
        LDX #>floatstart
        LDA #<floatstart
        BEQ g309B
        INX
g309B   STX lomem+1
        STX lofree+1
        RTS
realcodes .BYTE $08,$0E,$14,$1A,$20,$34,$3C,$44
        .BYTE $4C,$52,$58,$78,$80,$86,$8C,$94
        .BYTE $9C,$A0,$A6,$AC,$B0,$B6,$D2,$D4
        .BYTE $D6,$DA,$DC,$DE,$E4,$F4,$00
realjmps .BYTE $A8,$0F,$AB,$0F,$00,$00

pjsrz   PLA           ; page 4-29: JSR [Address [,Areg [,Xreg [,Yreg [,Flags ]]]]]
        STA pjsrv
        PLA
        STA pjsrv+1
        LDA regf
        AND #$E7
        STA regf
        CPY #$06
        BCC g30DE
        JMP esys
g30DE   CPY #$02
        BCC g30EA
        PLA
        PLA
        STA mlp,Y
        DEY
        BNE g30DE
g30EA   CPY #$01
        BNE g30F6
        PLA
        STA mlp+1
        PLA
        STA mlp
g30F6   LDA regf
        PHA
        LDA rega
        LDX regx
        LDY regy
        PLP
        JSR s311F
        PHP
        CLD
        STA rega
        STX regx
        STY regy
        PLA
        STA regf
        LDA pjsrv+1
        PHA
        LDA pjsrv
        PHA
        RTS
s311F   JMP (mlp)

gettstz PLA           ;page 4-24: bytevar=GETTST(IOflag)
        STA Parent
        PLA
        STA Parent+1
        CPY #$01
        BEQ g312F
        JMP esys
g312F   PLA
        PLA
        JSR hgettst
        LDA #$00
        ROL
        JMP retbyte

PNAMEtbl =*
PNAME0  .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; program 0 name
PNAME1  .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; program 1 name
PNAME2  .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; program 2 name
PNAME3  .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; program 3 name
PNAME4  .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; program 4 name
PNAME5  .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; program 5 name
PNAME6  .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; program 6 name
PNAME7  .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; program 7 name
FHTable .BYTE $00,$00,$00,$00,$00,$00,$00,$00 ; file handles
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00
FHTableE =*

