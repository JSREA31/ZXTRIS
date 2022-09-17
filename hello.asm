;
;
;
;==============================================
;    ZXTRIS 
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
;update I'm alive counter
	LD A,($4034)
	AND $0f
	ld (Display+1),a
;end of I'm alive counter

;delay loop		
	ld a, (delay_counter)
	dec a
	ld (delay_counter),a
	jp nz, 1F
		ld a,LEVEL1_DELAY
		ld (delay_counter),a
		call move_y
1	
	
	call get_keyboard
	
	;code to display keypress
	
	cp a,$FF
	jp z, 1F	

	cp a,$72
	jp nz, 2F
		ld a,$13
		ld (Display+34),a
		jp 1F
2	
	cp a,$73
	jp nz, 3F
		ld a,$12
		ld (Display+34),a
		jp 1F
3
	cp a, $39
	jp nz, 1F
		call get_tetro
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
	ld de,TETRO_BLOCK*4
1	
		adc hl,de
		dec a
		jp nz,1B
2

;step 2 which rotation state
	ld a,(tetro_rotation)
	cp a,0
	jp z,2F
	ld de,TETRO_BLOCK
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
	ld de,WELL_WIDTH+2	
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
	ld b,TETRO_SIZE
1
	push bc
	ld b,TETRO_SIZE	
2		
		ld a,(de)
		cp a, $40
		jp z,3F	
		cp a,$23
		jp nz,3F
			ld a,WELL_WAL_CHAR
			ld (hl),a
3		
		inc hl
		inc de
		djnz 2B
	push de
	ld de, WELL_WIDTH+2-TETRO_SIZE
	add hl,de
	pop de
	pop bc
	djnz 1B
	ret


;****************************************************************
;****    render_playfield:render playfield to Display        ****
;*****************************************************************
render_playfield

;get start position in screen memory
	ld hl,Display
	ld de,(START_ROW * SCREEN_WIDTH)+START_COLUMN+1
	add hl,de

;get start of playfield
	ld de,playfield	
	ld b, WELL_HEIGHT+1
next_row_render
	ld c, WELL_WIDTH+2
next_column_render
		ld a,(de)
		ld (hl),a
		inc hl
		inc de
		dec c
		jp nz,next_column_render
		push de
	ld de, SCREEN_WIDTH-(WELL_WIDTH+2)
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
	ld b, WELL_HEIGHT
next_row_well
	ld c, WELL_WIDTH+2
next_column_well
		ld (hl),WELL_SPACE
		inc hl
		dec c
		jp nz,next_column_well
	dec b
	jp nz, next_row_well

;draw walls

	ld hl,playfield
	ld b,WELL_HEIGHT+1
	ld de,WELL_WIDTH+1
next_row_wall
	ld (hl), WELL_WAL_CHAR	
	add hl,de
	ld (hl),WELL_WAL_CHAR
	inc hl
	dec b
	jp nz,next_row_wall

;do bottom row	
	or a
	sbc hl,de
	ld b,WELL_WIDTH
floor
	ld (hl),WELL_WAL_CHAR
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
	call spawn
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
	ld a,LEVEL1_DELAY
	ld (delay_counter), a
	ld a, $01
	ld (level),a

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
;****        spawn: random tetro number                   ****
;*****************************************************************
spawn
	call get_tetro
	
	ret



;****************************************************************
;****        get_tetro: random tetro number                   ****
;*****************************************************************
get_tetro
	ld a,($4034)
	and $07
	ld (current_tetro),a
	ret

;****************************************************************
;****        move_y: move tetro_down                     ****
;*****************************************************************
move_y
	
	call undraw_tetro
	
	ld a,(tetro_y)
	inc a
	ld (tetro_y),a
	
	
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

;****************************************************************
;****    undraw_tetro:delete tetro from Playfield              ****
;*****************************************************************
undraw_tetro


;Find out tetro start, using tetro number and rotation state

;step 1 which tetro
	ld hl,tetrominoZero
	ld a,(current_tetro)
	cp a,0
	jp z,2F
	ld de,TETRO_BLOCK*4
1	
		adc hl,de
		dec a
		jp nz,1B
2

;step 2 which rotation state
	ld a,(tetro_rotation)
	cp a,0
	jp z,2F
	ld de,TETRO_BLOCK
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
	ld de,WELL_WIDTH+2	
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
	ld b,TETRO_SIZE
1
	push bc
	ld b,TETRO_SIZE	
2		
		ld a,(de)
		cp a, $40
		jp z,3F	
		cp a,$23
		jp nz,3F
			ld a,WELL_SPACE
			ld (hl),a
3		
		inc hl
		inc de
		djnz 2B
	push de
	ld de, WELL_WIDTH+2-TETRO_SIZE
	add hl,de
	pop de
	pop bc
	djnz 1B
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
						