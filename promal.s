;
; PROMAL for the Commodore 64
;
; Split files to enhance build-ability.

; assemble this file.

; goal: PROMAL modules (bytecode, library, etc) in separate files

; -----------------------------------------------
;
; configuration section
;
; -----------------------------------------------

	dyno=	true		; set false to disable dyno
	ldrv=	true		; set false to dsiable 'l' ramdisk driver
	wdrv=	true		; set false to disable 'w' ramdisk driver
	tdrv=	true		; set false to disable 't' rs232 driver
	pdrv=	true		; set false to disable 'p' printer driver


; -----------------------------------------------
;
; build section
;
; -----------------------------------------------
	

.include "sysdefs.s"            ; defines for promal, firmware, and hardware

        *=      $0801           ; beginning of basic; also contains FP stack
.include "basic.s"              ; basic stub

        *=      $0900           ; system heap; also contains init code
.include "next.s"               ; bytecode fetch loop ($900)
.include "init.s"               ; system init code

        *=      $0b00
.include "pstatevar.s"          ; system state variables

        *=      $0c00
.include "halvars.s"            ; HAL storage and scratch area

        *=      $0d00
.include "specvars.s"           ; Commandline and special variables/pointers

        *=      $0e00
.include "dispatch_table.s"     ; dispatch table

        *=      $0f00
.include "library_table.s"      ; system library jump table.  THIS CANNOT BE MOVED.
.include "devices.s"            ; special file handles and default redirects
.include "keydefs.s"            ; special keycode definitions
.include "copyright.s"          ; contains SMA's original copyright for PROMAL
.include "exception.s"          ; system exception handler
.include "interpreter.s"        ; bytecode interpreter core
.include "syslib.s"             ; system library routines
.include "hal.s"                ; hardware abstraction layer
.include "real.s"               ; real (floating point) math routines
.include "trailer.s"            ; defs that belong at the end of assembly
