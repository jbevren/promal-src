
;
; PROMAL for the Commodore 64
; Copyright (C) 1985, SMA, Inc.
; Re-source (C) 2015 jbevren
;

; BASIC stub

; version 0: initial write
; status: Matches original basic stub; done


        * = $0801
bline1  .WORD bline2
        .WORD 10
        .BYTE $8F       ;REM
        .TEXT " PROMAL 2.1  10/14/86"
        .BYTE 0
bline2  .WORD bline3
        .WORD 15
        .BYTE $8F       ;REM
        .TEXT " COPYRIGHT (C) 1986 SMA INC."
        .BYTE 0
bline3  .WORD bline4
        .WORD 20
        .BYTE $9E       ;SYS
        .TEXT " 15"
        .BYTE $AC       ;*
        .TEXT "256"
        .BYTE 0
bline4  .WORD 0
