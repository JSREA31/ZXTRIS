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
    include game_constants.asm
	include line1.asm
;

;------------------------------------------------------------
; code starts here and gets added to the end of the REM 
;------------------------------------------------------------
code_start
	jp main_start

	include vars.asm

main_start	
	ld bc,10
	ld de,hello_txt
	call dispstring


	jp new_Well
	
;back to BASIC		
	ret


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
render_playfield

	

	ret



;****************************************************************
;****           new_Well:Create Empty TETRIS well            ****
;*****************************************************************
new_Well
;clear the entire playfied	
	ld hl,playfield
	ld b, well_height
next_row_well
	ld c, well_width+2
next_column_well
		ld (hl),well_space
		inc hl
		dec c
		jp nz,next_column_well
	dec b
	jp nz, next_row_well

;draw walls

	ld hl,playfield
	ld b,well_height+1
	ld de,well_width+1
next_row_wall
	ld (hl), well_wall_char	
	adc hl,de
	ld (hl),well_wall_char
	inc hl
	dec b
	jp nz,next_row_wall

;do bottom row	
	sbc hl,de
	ld b,well_width
floor
	ld (hl),well_wall_char
	inc hl
	dec b
	jp nz, floor	

	ret


; ===========================================================
; code ends
; ===========================================================
;end the REM line and put in the RAND USR line to call our 'hex code'
    include line2.asm

;display file defintion
    include screen.asm               

;close out the basic program
    include endbasic.asm
						