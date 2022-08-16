;
; To assembly this, either use the zxasm.bat file:
;
; zxasm hello
;
; or... assemble with the following options:
;
; tasm -80 -b -s hello.asm hello.p
;
;==============================================
;    ZX81 assembler 'Hello World' 
;==============================================
;
;defs
;INCLUDE zx81defs.asm
    ;include zx81defs.asm
    device	NOSLOT64K
	SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION

	
	include zx81rom.asm
    include charcodes.asm
    include zx81sys.asm
    include line1.asm
;

;------------------------------------------------------------
; code starts here and gets added to the end of the REM 
;------------------------------------------------------------
code_start	
	ld a,$10
	neg
	inc a
	ret
;include our variables
    include vars.asm

; ===========================================================
; code ends
; ===========================================================
;end the REM line and put in the RAND USR line to call our 'hex code'
    include line2.asm

;display file defintion
    include screen.asm               

;close out the basic program
    include endbasic.asm
						