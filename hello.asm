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
	jp main_loop
	include vars.asm

main_loop	
	
	;title screen - goes here
wait_spacebar
	call bump_tetro_counter ; sudo randon number for next tetro
	call get_keyboard
		cp a, $00
		jp nz,wait_spacebar

	call init_game



game_loop	
	call bump_tetro_counter ; sudo randon number for next tetro
;update I'm alive counter
	ld a,(tetro_counter)
	ld (Display+1),a
;end of I'm alive counter

	call get_keyboard
	;code to display keypress
		ld (Display+34),a
		cp a, $39
		jp nz, 1F
			ld a,(tetro_counter)
			ld(current_tetro),a
1	
	call render_tetro
	call render_playfield
	
	jp game_loop


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
;****    render_tetro:render tetro to Playfield              ****
;*****************************************************************
render_tetro


;Find out tetro start, using tetro number and rotation state

;step 1 which tetro
	ld hl,tetrominoZero
	ld a,(current_tetro)
	cp a,0
	jp z,2F
	ld de,tetro_block*4
1	
		adc hl,de
		dec a
		jp nz,1B
2

;step 2 which rotation state
	ld a,(tetro_rotation)
	cp a,0
	jp z,2F
	ld de,tetro_block
1	
		adc hl,de
		dec a
		jp nz,1B
2
	push hl

;get start of playfield plot area
	ld hl,playfield
	ld a,(tetro_y)
	cp a,0
	jp z,2F
	ld de,well_width+2	
1	
		adc hl,de
		dec a
		jp nz,1B
2
	ld a,(tetro_x)
	ld e,a
	ld d,0
	add hl,de
	inc hl

;now draw the tetro into playfield
	pop de
	ld b,tetro_size
1
	ld c,tetro_size	
2		
		ld a,(de)
		cp a, $40
		jp nz,3F
			ld a,$00
3		
		cp a,$23
		jp nz,4F
			ld a,well_wall_char
4		
		ld (hl),a
		inc hl
		inc de
		dec c
		jp nz, 2B
	push de
	ld de, well_width+2-tetro_size
	add hl,de
	pop de
	dec b
	jp nz,1B
	ret


;****************************************************************
;****    render_playfield:render playfield to Display        ****
;*****************************************************************
render_playfield

;get start position in screen memory
	ld hl,Display
	ld de,(start_row * screen_width)+start_column+1
	add hl,de

;get start of playfield
	ld de,playfield	
	ld b, well_height+1
next_row_render
	ld c, well_width+2
next_column_render
		ld a,(de)
		ld (hl),a
		inc hl
		inc de
		dec c
		jp nz,next_column_render
	push de
	ld de, screen_width-(well_width+2)
	add hl,de
	pop de
	dec b
	jp nz, next_row_render


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
	add hl,de
	ld (hl),well_wall_char
	inc hl
	dec b
	jp nz,next_row_wall

;do bottom row	
	or a
	sbc hl,de
	ld b,well_width
floor
	ld (hl),well_wall_char
	inc hl
	dec b
	jp nz, floor	

	ret

;****************************************************************
;****           start_screen:draw startscreen                 ****
;*****************************************************************
start_screen
	ret

;****************************************************************
;****           init_game:setup game variables                ****
;*****************************************************************
init_game
	;get randon 1st tetro
	call get_tetro
	;use this to work out next tetro (not quite randomn!)
	ld a,(current_tetro)
	inc a
	cp a, $07
	jp nz,1F
		ld a,$0
1	
	ld(next_tetro),a
	
	;clear the playfield
	call new_Well

	;set x and y

	;clear the score

	;clear the level


	ret
;****************************************************************
;****           clear_screen: clear the screen                 ****
;*****************************************************************
clear_screen
	ret

;****************************************************************
;****          get_keyboard: read and decode keyboard        ****
;*****************************************************************
get_keyboard
	call KSCAN
	ld b,h
	ld c,l
	ld d,c
	inc d
	jr z, 1F
	call DECODE
	ld a,(hl)
	ret
1
	ld a,$ff
	ret

;****************************************************************
;****        get_tetro: random tetro number                   ****
;*****************************************************************
get_tetro
	ld de,tetro_counter
			ld a,(tetro_counter)
	ret

;****************************************************************
;****     bump_tetro_counter: counts between 0 and 6          ****
;*****************************************************************
bump_tetro_counter
	ld a,(tetro_counter)
	inc a
	cp a,$07
	jp nz,carry_on
	ld a, $00
carry_on
	ld (tetro_counter),a
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
						