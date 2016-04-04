
;
; PROMAL for the Commodore 64
; Copyright (C) 1985, SMA, Inc.
; Re-source (C) 2015 jbevren
;

; special file definitions and default redirects

; version 0
; status: 

        ; special files' handles.  The HAL and library check for these
        ; with cmp $F0.

SFhand  =*+3
SName   =*
skdev   .BYTE "K",$00,$52,$FE   ; K device: R/O handle $FE
ssdev   .BYTE "S",$00,$57,$FC   ; S device: W/O handle $FC
sedev   .BYTE "E",$00,$57,$FA   ; E device: W/O handle $FA
sndev   .BYTE "N",$00,$57,$F8   ; N device: R/W handle $F8
	.if wdrv
swdev   .BYTE "W",$00,$42,$F6   ; W device: R/W handle $F6
	.else
swdev   .BYTE $00,$00,$00,$00   ; W device disabled
	.fi
	.if ldrv
sldev   .BYTE "L",$00,$42,$F4   ; L device: R/W handle $F4
	.else
sldev   .BYTE $00,$00,$00,$00   ; L device disabled
	.fi
	.if tdrv
stdev   .BYTE "T",$00,$42,$F2   ; T device: R/W handle $F2
	.else
stdev   .BYTE $00,$00,$00,$00   ; T device disabled
	.fi
	.if pdrv
spdev   .BYTE "P",$00,$57,$F0   ; P device: W/O handle $F0
	.else
spdev   .BYTE $00,$00,$00,$00   ; P device disabled
	.fi

        ; default assignments for redirection.

reddefs =*
dstdin  .WORD skdev             ; default stdin
dstdout .WORD ssdev             ; default stdout
dstderi .WORD skdev             ; default stderr in
dstdero .WORD sedev             ; default stderr out

