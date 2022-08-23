;
;
; sjasmplus hello
;
;==============================================
;    ZX81 assembler 'Hello World' 
;==============================================
;
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
	ld bc,10
	ld de,hello_txt
	call dispstring

;back to BASIC	
	jp new_Well
	jp code_start

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
	scf
	sbc $1A
	cp $05
	jp nz, notaspace
	ld a,$00
notaspace	
	ld (hl),a
	inc hl
	inc de
	jr loop2
loop2End	
	ret	


;****************************************************************
;****           new_Well:Create Empty TETRIS well            ****
;*****************************************************************
new_Well
;clear the entire playfield

	ld hl,playfield
	ld b, well_height+1
next_row
	ld c, well_width+1
next_column
		ld (hl),c
		inc hl
		dec c
		jp nz,next_column
	dec b
	jp nz, next_row



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
						