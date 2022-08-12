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
    include zx81rom.asm
    include charcodes.asm
    include zx81sys.asm
    include line1.asm
;

;------------------------------------------------------------
; code starts here and gets added to the end of the REM 
;------------------------------------------------------------
	ld bc,1
	ld de,hello_txt
	call dispstring

;back to BASIC	
	ret

;Subroutines	
;display a string
dispstring
;write directly to the screen
	ld hl,(D_FILE)
	add hl,bc	
loop2
	ld a,(de)
	cp $ff
	jp z,loop2End
	ld (hl),a
	inc hl
	inc de
	jr loop2
loop2End	
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
						
