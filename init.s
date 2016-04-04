
;
; PROMAL for the Commodore 64
; Copyright (C) 1985, SMA, Inc.
; Re-source (C) 2015 jbevren
;

; init code, originally at $0917

; version 0
; status: matches original


initz   CLD 
        NOP 
        NOP 
        NOP 
        LDX #$FF
        TXS 
        JSR sysinit
        JSR setpfx
        LDX #nextsz     ; from next.s; size of Pnext routine
cpnext  LDA nextorg,X   ; from next.s; origin of unrelocated PNext
        STA PnextP,X    ; from next.s; destination of relocated PNext
        DEX 
        BPL cpnext
        LDA FHtabB      ; set up initial file handle
        STA z34
        LDA FHtabB+1
        STA z35
        LDY #$00        ; clear all file handles
g093A   TYA 
g093B   STA (z34),Y     ; clear file handle
        INY 
        CPY #$16
        BCC g093B
        JSR gNxtFH      ; get next file handle
        BCC g093A
        LDA #$00        ; prep pointers
        STA HeapVec     ; system heap vector
        STA Heapptrq    ; system heap pointer
        LDA #>heap      ; from sysdefs.s; heap origin
        STA HeapVec+1   ; from sysdefs.s; heap vector location
        LDA #$4C        ; JMP opcode
        STA Pjmp
        LDY #$00
        STY fltptr      ; floating point stack index
        LDA #<cpubrk    ; add custom BRK handler
        STA kBRK
        LDA #>cpubrk
        STA kBRK+1
        NOP 
        NOP 
        NOP 
        NOP 
        NOP 
        LDX #$02
        STX numprgsq
        LDX #$40
        STX PrgBit
        LDA #$00
        STA PrgPtr
        STA Exres       ; clear editor resident flag
        LDA #<tedit     ; load editor
        PHA 
        LDA #>tedit     ; "edit"
        PHA 
        LDA #$10        ; ldnogo
        PHA 
        LDA #$00        ; dummy byte
        PHA 
        LDY #$02        ; 2 parameters
        JSR load        ; LOAD "EDIT", LDNOGO (but don't run it)
        LDA lderr       
        BEQ g099F       ; no problem, skip error stuff
        CMP #$01        ; file not found?
        BNE stfail      ; no, big issue: panic.
        LDA #<tednfnd   ; print error message
        PHA 
        LDA #>tednfnd   ; "editor not found"
        PHA 
        LDY #$01        ; one parameter
        JSR PUT         ; PUT "EDITOR NOT FOUND"
g099F   LDA #$80
        STA PrgBit
        LDX #$00
        STX PrgPtr      ; set current program to 0
        LDA #<tldexec   ; print message
        PHA 
        LDA #>tldexec   ; "loading executive"
        PHA 
        LDY #$01        ; one parameter
        JSR PUT         ; PUT "LOADING EXECUTIVE"
        LDA #<texec     ; load executive
        PHA 
        LDA #>texec     ; "executive"
        PHA 
        LDY #$01        ; one parameter
        JSR load        ; LOAD "EXECUTIVE" (and run it)
        JMP stfail      ; big issues if we wound up here.

stfail  LDA #<tcntld    ; print panic message
        PHA 
        LDA #>tcntld    ; "can't load it."
        PHA 
        LDY #$01        ; one parameter
        JSR PUT         ; PUT "CAN'T LOAD IT."
panic   JMP panic       ; loop until reset

tldexec .BYTE $0D
        .TEXT "LOADING "
texec   .TEXT "EXECUTIVE"
        .BYTE $00
tedit   .TEXT "EDIT"
        .BYTE $00,$00,$00,$00,$00,$00
tcntld  .BYTE $0D
        .TEXT "CAN'T LOAD IT."
        .BYTE $0D,$00
tednfnd .BYTE $0D
        .TEXT "EDITOR NOT FOUND"
        .BYTE $00

; Sysinit takes care of system platform initialization.
sysinit CLD 
        LDX #$02
        LDA #$00
g0A15   STA hKFHmap,X   ; clear firmware to promal file map
        INX 
        CPX #$10
        BNE g0A15
        JSR kCLALL
        JSR kCINT
        LDA #$02        ; set this to 0 to avoid head bumps
        LDX #<ti0
        LDY #>ti0
        JSR kSETNAM
        LDA #$0F
        LDY #$0F
        LDX #$08
        JSR kSETLFS
        JSR kOPEN       ; command channel for drive 8
        LDA #$0E
        LDY #$0F
        LDX #$09
        JSR kSETLFS
        JSR kOPEN       ; command channel for drive 9
        LDA pport       ; get current configuration
        AND #$FC        ; mask off everything but ram
        ORA #$02        ; add kernal and I/O
        STA pport       ; set map
        SEI 
        LDA kIRQ        ; check IRQ vector
        CMP #<sysirq
        BNE g0A5B
        LDA kIRQ+1
        CMP #>sysirq
        BEQ g0A76
g0A5B   LDA kIRQ        ; set up custom IRQ routine
        STA dfltirq
        LDA kIRQ+1
        STA dfltirq+1
        LDA #<sysirq
        STA kIRQ
        LDA #>sysirq
        STA kIRQ+1
        LDA #$00
        STA brkflag     ; ensure BRK key isn't pressed
g0A76   CLI
        LDA #<maxmemi
        STA maxmem
        LDA #>maxmemi
        STA maxmem+1
        LDA #<KeyDefsi
        STA KeyDefs
        LDA #>KeyDefsi
        STA KeyDefs+1
        LDA #$FF
        LDX #$00
        JSR WrHstBuf
        TXA 
        INX 
        JSR WrHstBuf
        STX HBPos
        LDA VICmcr
        AND #$F1
        ORA #$06
        STA VICmcr
        RTS 

ti0     .BYTE $49,$30

; Setpfx sets up the default prefix for the runtime during init
setpfx  LDX #$00        ; preset current prefix
g0AA9   LDA DfltPrefx,X
        STA prefix,X
        BEQ g0AB4
        INX 
        BNE g0AA9
g0AB4   RTS 

DfltPrefx .TEXT "0:"
        .BYTE $00

