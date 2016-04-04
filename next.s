
;
; PROMAL for the Commodore 64
; Copyright (C) 1985, SMA, Inc.
; Re-source (C) 2015 jbevren
;

; PNext routine compiled to run at 77

; version 0
; status: matches original

nextorg=*
        .logical $0073  ; Pcode fetch is expected to be at $73.

PnextP  PHA             ; save returned byte
Pskip   INY             ; increment bytecode index
        BEQ Pinc1       ; overflow? increment PBaseh
        PBase=*+1
Pnext   LDA (>promalend+256)*256,Y      ; fetch bytecode- selfmod code
        INY             ; increment bytecode index
        BEQ Pinc2       ; overflow? increment PBaseh
Pstore  STA Pcd         ; save bytecode in jump
        Pcd=*+1
        JMP (dsptchl)   ; jump to bytecode routine- selfmod code
Pinc1   INC PBase+1     ; increment PBaseh
        BNE Pnext       ; return to fetch bytecode
Pinc2   INC PBase+1     ; increment PBaseh
        BNE Pstore      ; return to store bytecode

        nextsz=*-PnextP ; for init

        .here           ; exit logical address
