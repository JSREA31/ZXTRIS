
;****************************************************************
;****************************************************************
;****                     ZXTRIS                             ****
;****************************************************************
;****************************************************************
    device	NOSLOT64K
	SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION

	include zx81rom.asm
    include charcodes.asm
    include zx81sys.asm
    include game_constants.asm
	include line1.asm


;****************************************************************
;****************************************************************
;****    Code starts here after the REM statement           ****
;****************************************************************
;****************************************************************
code_start
	jp main_loop
	include vars.asm

main_loop	
	call title_screen
    
	call init_game


game_loop	

;check for end of gamaae
    ld a,(game_over)
    cp a, $ff
    jr nz, 2F
    jp endofgame
2
;update I'm alive counter
	;LD A,($4034)
	;AND $0f
	;ld (Display+1),a
;end of I'm alive counter
		
	ld a, (delay_counter)
	dec a
	ld (delay_counter),a
	jp nz, 1F
		ld a,(speed)
		ld (delay_counter),a
		call move_y
1	
	
	call get_keyboard
	call doactions

	
	call render_tetro
	call render_playfield
    call display_score
    call display_level
	
	jp game_loop

    
;****************************************************************
;****************************************************************
;****    render_tetro:render tetro to Playfield              ****
;****************************************************************
;****************************************************************
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
	cp a,$0
	jp z,2F
	ld de,WELL_WIDTH+3	
1	
		adc hl,de
		dec a
		jp nz,1B
2
	ld a,(tetro_x)
	ld e,a
	ld d,0
	add hl,de
	;inc hl

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
			ld a,(current_tetro_char)
			ld (hl),a
3		
		inc hl
		inc de
		djnz 2B
	push de
	ld de, WELL_WIDTH+3-TETRO_SIZE
	add hl,de
	pop de
	pop bc
	djnz 1B
	ret


;****************************************************************
;****************************************************************
;****    render_playfield:render playfield to Display        ****
;****************************************************************
;****************************************************************
render_playfield

;get start position in screen memory
	ld hl,Display
	ld de,(START_ROW * SCREEN_WIDTH)+START_COLUMN+1
	add hl,de

;get start of playfield
	ld de,playfield	
	ld b, WELL_HEIGHT+1
next_row_render
	ld c, WELL_WIDTH+3
next_column_render
		ld a,(de)
		ld (hl),a
		inc hl
		inc de
		dec c
		jp nz,next_column_render
		push de
	ld de, SCREEN_WIDTH-(WELL_WIDTH+3)
	add hl,de
	pop de
	dec b
		jp nz, next_row_render


	ret


;****************************************************************
;****************************************************************
;****           new_Well:Create Empty TETRIS well            ****
;****************************************************************
;****************************************************************
new_Well
;clear the entire playfied	
	ld hl,playfield
	ld b, WELL_HEIGHT+1
next_row_well
	ld c, WELL_WIDTH+3
next_column_well
		ld (hl),WELL_SPACE
		inc hl
		dec c
		jp nz,next_column_well
	dec b
	jp nz, next_row_well
    
;draw walls

	ld hl,playfield
	ld b,WELL_HEIGHT
	ld de,WELL_WIDTH+1
next_row_wall
	ld (hl), $00
    inc hl
    ld (hl),WELL_WAL_CHAR	
	add hl,de
	ld (hl),WELL_WAL_CHAR
	inc hl
	dec b
	jp nz,next_row_wall

;do bottom row	
	or a
	;sbc hl,de
	ld b,WELL_WIDTH+2
    ld (hl),$00
    inc hl
floor
	ld (hl),WELL_WAL_CHAR
	inc hl
	dec b
	jp nz, floor	

	ret


;****************************************************************
;****************************************************************
;****           start_screen:draw startscreen                 ***
;****************************************************************
;****************************************************************
start_screen
	ret

;****************************************************************
;****************************************************************
;****           display_level:show level                     ***
;****************************************************************
;****************************************************************
display_level
    ld hl,Display+30+33
    ld a,(level)
    add $1C
    ld (hl),a
	ret

;****************************************************************
;****************************************************************
;****          title_screen: title screen                    ***
;****************************************************************
;****************************************************************
title_screen
;draw logo
    ld de,Display+(SCREEN_WIDTH*2)+1
    ld hl,logo2
    ld b,0
1
    ld a,(hl)
    cp a, $FF
    jr z, 5F
3   ld (de),a
    inc hl
    inc de
    inc b
    ld a,b
    cp a, 32
    jr nz, 4F
        ld b,0
        inc de
4    
    jp 1B
5

    ld hl,titlescreen2text
    ld de,Display+(SCREEN_WIDTH*13)+7
    call print_string 

2   call get_keyboard
    cp a, $00
	jp nz,2B
    call CLS
	ret

;****************************************************************
;****************************************************************
;****           end of game: manage end of game               ***
;****************************************************************
;****************************************************************
endofgame
    ;display game over text
    ld hl,gameovertext
    ld de,Display+(SCREEN_WIDTH*18)+4
    call print_string 
2   call get_keyboard
    cp a, $00
	jp nz,2B
    call CLS
    jp main_loop
	ret


;****************************************************************
;****************************************************************
;****           init_game:setup game variables                ***
;****************************************************************
;****************************************************************
init_game
	
    ;use this to work out next tetro (not quite randomn!) but only if this is the first tetro
	call get_tetro
    ld (next_tetro),a


    ;clear the playfield
	call new_Well

    ;clear the score
    ld hl,0
    ld(score),hl
    ld (totalrows),hl

	;clear the level
	ld a,LEVEL1_DELAY
    ld (speed),a
    ld (speed_store),a
	ld (delay_counter), a
	
    ld a, $01
	ld (level),a

    ld a,$00
    ld (keyboard_block),a
    ld (game_over),a

    ld a,$ff
    ld (first_tetro),a
    

	;draw tetro and set x,y
	call spawn

    ;score and level text
    ld hl,scoreandleveltext
    ld de,Display+23
    call print_string 
	
    ;next tero label
    ld hl,nexttext
    ld de,Display+(SCREEN_WIDTH*8)+2
    call print_string 

    ;zxtris tero label
    ld hl,zxtristext
    ld de,Display+1
    call print_string 

    ret


;****************************************************************    
;****************************************************************
;****   display_score: convert score to text and display     ****
;***************************************************************
;****************************************************************
display_score

    ld hl,(score)
    ld de,TENTHOUSAND
    ld a,0
1       
    sbc hl,de
    inc a
    jr nc,1B
    dec a
    ld (scoredigits),a
    add hl,de
    CCF

    ld de,THOUSAND
    ld a,0
1       
    sbc hl,de
    inc a
    jr nc,1B
    dec a
    ld (scoredigits+1),a
    add hl,de
    CCF


    ld de,HUNDRED
    ld a,0
1       
    sbc hl,de
    inc a
    jr nc,1B
    dec a
  
    ld (scoredigits+2),a
    add hl,de
    CCF


    ld de,TEN
    ld a,0
1       
    sbc hl,de
    inc a
    jr nc,1B
    dec a
    ld (scoredigits+3),a
    add hl,de
    CCF


    ld a,l
    ld (scoredigits+4),a
    
    ld hl,Display+23+33
    ld de,scoredigits
    ld b,5
1
    ld a,(de)
    add $1C
    ld (hl),a
    inc hl
    inc de
    djnz 1B


    ret


;****************************************************************
;****************************************************************
;****          get_keyboard: read and decode keyboard        ****
;****************************************************************
;****************************************************************
get_keyboard
	ld a,(keyboard_block)
    cp a, $ff
    jr z,1F

    call KSCAN
	ld b,h
	ld c,l
	ld d,c
	inc d
    ld a,$ff
	jr z, 1F
		call DECODE
		ld a,(hl)   
        ld b,a
        ld a,(last_keyp)
        cp b
        ld a,b
        jr z, 2F
        ld (last_keyp),a
        ret

1    
        ld (last_keyp),a
        ret

2
        ld a,$ff
        ret


;****************************************************************
;****************************************************************
;****        doactions: key board actions                    ****
;****************************************************************
;****************************************************************
doactions
    
    cp $36 ;Q = Quit
    jr nz,1F
        ld a, $ff
        ld (game_over),a
        ret

1   cp $72 ; < = left
    jr nz,1F
        call move_left
        ret

1   cp $73; >  = right
    jr nz, 1F
        call move_right
        ret

1   cp $26; A = rotate CW
    jr nz, 1F
        call rotateCW
        ret

1   cp $29; D = rotate ACW
    jr nz, 1F
        call rotateACW
        ret

1   cp $38; S = Drop
    jr nz, 1F
        
        ld a,$01
        ld (delay_counter),a
        ld a,(speed)
        ld (speed_store),A
        ld a, DROP_SPEED
        ld (speed),A
        ld a, $ff
        ld (keyboard_block),a
        ret

1   cp $35; P = Pause
    jr nz, 1F
        ;pause label
        ld hl,pausetext
        ld de,Display+(SCREEN_WIDTH*18)+1
        call print_string 
2       call get_keyboard
        cp a, $35
		jp nz,3F
            ld hl,deletepausetext
            ld de,Display+(SCREEN_WIDTH*18)+1
            call print_string 
            call render_playfield
            call render_tetro
            ret
3       cp a, $36
		jp nz,4F
            ld hl,deletepausetext
            ld de,Display+(SCREEN_WIDTH*18)+1
            call print_string 
            call render_playfield
            call render_tetro
            ld a,$ff
            ld (game_over),a
            ret 
4        jp 2B 

1        ret



;****************************************************************
;****************************************************************
;****        move_left: try and move left                    ****
;****************************************************************
;****************************************************************
move_left
    ld a,(tetro_x)
    cp a, $00
    jr z,1F
    call undraw_tetro
    ld a, (tetro_x)
    dec A
    ld (tetro_x),a
    call collisioncheck
    ld a, (can_move)
    cp $00
    jr z, 1F
    ld a, (tetro_x)
    inc A
    ld (tetro_x),a
    
1   call render_tetro    
    ret


;****************************************************************
;****************************************************************
;****        move_right: try and move left                    ***
;****************************************************************
;****************************************************************
move_right
    ld a,(tetro_x)

    call undraw_tetro
    ld a, (tetro_x)
    inc A
    ld (tetro_x),a
    call collisioncheck
    ld a, (can_move)
    cp $00
    jr z, 1F
    ld a, (tetro_x)
    dec A
    ld (tetro_x),a
    
1       
    call render_tetro
    ret


;****************************************************************
;****************************************************************
;****        rotateCW: try and rotate CW                      ***
;****************************************************************
;****************************************************************
rotateCW
    call undraw_tetro
    
    ld a, (tetro_rotation)
    ld (temp_rotation),A

    cp $03
    jr z, 1F
        inc A
        ld (tetro_rotation),A
        call checkrotation
        ret  

1       ld a, $00
        ld (tetro_rotation),A
        call checkrotation    
    ret


;****************************************************************
;****************************************************************
;****        rotateACW: try and rotate ACW                    ***
;****************************************************************
;****************************************************************
rotateACW
    call undraw_tetro
    
    ld a, (tetro_rotation)
    ld (temp_rotation),A

    cp $00
    jr z, 1F
        dec A
        ld (tetro_rotation),A
        call checkrotation
        ret  

1       ld a, $03
        ld (tetro_rotation),A
        call checkrotation    
    
    ret


;****************************************************************
;****************************************************************
;****        checkrotation: can it rotate                    ****
;****************************************************************
;****************************************************************
checkrotation
    call collisioncheck
    
    ld a,(can_move)
    cp a, $FF
    jr nz,1F
    ;if it can't move then put things back to how they were
    ld a,(temp_rotation)
    ld (tetro_rotation),a
    call render_tetro
1    
    ret


;****************************************************************
;****************************************************************
;****       collision check: does does it collide             ***
;****************************************************************
;****************************************************************
collisioncheck
    ld a, $00
    ld (can_move), A
    
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
	cp a,$0
	jp z,2F
	ld de,WELL_WIDTH+3	
1	
		adc hl,de
		dec a
		jp nz,1B
2
	ld a,(tetro_x)
	ld e,a
	ld d,0
	add hl,de
	;inc hl

;now check each each filled square of tetro in playfield
	pop de
	ld b,TETRO_SIZE
1
	push bc
	ld b,TETRO_SIZE	
2		
		ld a,(de)
		cp a, $40
		jr z,3F	
		ld a,(hl)
        cp a,$00
        jr z, 3F
        ld a,$ff
        ld (can_move),a
3		
		inc hl
		inc de
		djnz 2B
	push de
	ld de, WELL_WIDTH+3-TETRO_SIZE
	add hl,de
4	pop de
	pop bc
	djnz 1B
	ret
    
;****************************************************************
;****************************************************************
;****        spawn: new tetro and do some checks             ****
;****************************************************************
;****************************************************************
spawn
	;check for last tetro on row zero
	ld (first_tetro),a
    cp a, $ff
    jr z,3F
    call clear_rows
    ld a,(tetro_y)
    cp a, $00
    jr nz, 3F
    
    ld a,$ff
    ld (game_over),a
    ret

3    
    ld a,$00
    ld (first_tetro),a

    ;set current tetro to next tetro
    ld a,(next_tetro)
    ld (current_tetro),a
    call get_tetro_char
    ld (current_tetro_char),a

    ;get randon next tetro
    call get_tetro
    ld (next_tetro),a
    call get_tetro_char
    ld (next_tetro_char),a
    
    ;display current tetro and next tetro
    ;add a,$1C
    ;ld (Display+35),a
    ;ld a,(current_tetro)
    ;add a, $1C
    ;ld (Display+34),a

    ld a,$0
    ld (tetro_y),a
    ld (tetro_rotation),a
    ld a,$04
    ld (tetro_x),a
    
    ld a,(speed_store)
    ld (speed),a
    ld (delay_counter),a
    ld a,$00
    ld (keyboard_block),a

    call render_nexttetro
	ret


;****************************************************************
;****************************************************************
;****    get tetro char: tetro in via a, char out via a      ****
;****************************************************************
;****************************************************************
get_tetro_char
    ;set tetro character for drawing tetro
    cp $00
    jr nz,1F
        ld a,$97 ; inverese star  
        jr 7F
1   cp $01
    jr nz,2F
        ld a,$08 ;inverse checkerboard
         jr 7F
2   cp $02
    jr nz,3F
        ld a,$B4 ;inverse O
         jr 7F
3   cp $03
    jr nz,4F
        ld a,$34 ; 0 
         jr 7F
4   cp $04
    jr nz,5F
        ld a,$BD ; inverse X
         jr 7F
5   cp $05
    jr nz,6F
        ld a,$08 ;checkerboard
        jr 7F
6
    ld a,$95; inverse + 

7

    ret

;****************************************************************
;****************************************************************
;****    clear_rows: check to see if any rows are full       ****
;****************************************************************
;****************************************************************
clear_rows
    ;clear the score multiplier
    ld a,$00
    ld (clearedrows),a
    
    ;move to bottom row of playfield
    ld hl,playfield
	ld de,(WELL_WIDTH+3)*(WELL_HEIGHT-1)	
	add hl,de
    inc hl
    
    ;now check every row to see if it is complete
    ld b,WELL_HEIGHT-1
    ld de,WELL_WIDTH+3
  
1
    push hl
    ld c,$00
2
    inc hl
    inc c
    ld a,(hl)
    cp a,$00
    jr z,3F
    ld a,c
    cp a,WELL_WIDTH    
    jr nz,2B
    ld a,(clearedrows)
    inc a
    ld (clearedrows),a
    pop hl
    push hl
    push de
    push bc
    call remove_row
    pop bc
    pop de
    pop hl
    push hl
    ld c,$00
    jp 2B
3  
    pop hl
	sub hl,de
    djnz 1B
    ret


;****************************************************************
;****************************************************************
;****   remove_row: remove a specific row because it is full  ***
;****************************************************************
;****************************************************************
remove_row

;playfield address is in hl
;row is in b

    
    ld a,b
    ld (full_row),a
    inc hl
    ld de,hl
    ld bc,WELL_WIDTH+3
    sbc hl,bc
    
    ;row to move down = hl
    ;row to be cleared = de
  


    ld a,(full_row)
    ld b,a    
1
    ld c,$00
2
    ld a,(hl)
    ld (de),a
    inc de
    inc hl
    inc c
    ld a,c
    cp a, WELL_WIDTH
    jr nz,2B
    
    ld a,(2*WELL_WIDTH)+3
    ld e,a
	ld d,0
	sbc hl,de
    push hl
    ld a,WELL_WIDTH+3
    ld e,a
	ld d,0
	adc hl,de
    ld de,hl
    pop hl 
    djnz 1B

;add  to score

    ld a,(level)
    ld b,a
    xor a
1   add $05
    djnz 1B    

    push af
    
    ld a,(level)
    ld b,a

    pop af
1   add a
    djnz 1B

    
    ld d,0
    ld e,a
    ld hl,(score)
    add hl,de
    ld (score),hl

;add to total rows
    ld hl,(totalrows)
    inc hl
    ld (totalrows),hl

;check level (every 10 rows cleared level increases)
    ld a,(totalrows)
    cp 6
    jr c, 3F
        ld a,0
        ld (totalrows),a
        ld a,(level)
        inc a
        cp a,11
        jr c, 2F
        ld a,10
        ld (level),a
        ret
;adjust speed
2       ld (level),a
        ld a,(speed_store)
        sub 5
        ld (speed),a
        ld (speed_store),a

3
    ret



;****************************************************************
;****************************************************************
;****        update_score: bump score when tetro drops        ***
;****************************************************************
;****************************************************************
update_score
    ld hl,(score)
    ld a,(level)
    ld b,a
1   inc hl
    ld(score),hl
	djnz 1B
    ret


;****************************************************************
;****************************************************************
;****     print string: write string from hl to de until ff   ***
;****************************************************************
;****************************************************************
print_string
1
    ld a,(hl)
    cp a, $FF
    jr z, 2F
    sub 27
    cp a,$5
    jr nz,3F
    ld a,$00
3    ld (de),a
    inc hl
    inc de
    jp 1B
2

ret    

;****************************************************************
;****************************************************************
;****        get_tetro: random tetro number                  ****
;****************************************************************
;****************************************************************
get_tetro
1	
    ld a,($4034)
	and $07
    cp a,$07
	jr z, 1B
    
	ret


;****************************************************************
;****************************************************************
;****        move_y: move tetro_down                         ****
;****************************************************************
;****************************************************************
move_y
	
	call undraw_tetro
	
	ld a,(tetro_y)
	inc a
	ld (tetro_y),a
	
    call collisioncheck

    ld a,(can_move)
    cp a, $ff
    jr nz, 1F
    ld a,(tetro_y)
    dec a
    ld (tetro_y),a
    call render_tetro
    call update_score
    call spawn
1
	ret

 
;****************************************************************
;****************************************************************
;****    undraw_tetro:delete tetro from Playfield            ****
;****************************************************************
;****************************************************************
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
	ld de,WELL_WIDTH+3	
1	
		adc hl,de
		dec a
		jp nz,1B
2
	ld a,(tetro_x)
	ld e,a
	ld d,0
	add hl,de
	;inc hl

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
	ld de, WELL_WIDTH+3-TETRO_SIZE
	add hl,de
	pop de
	pop bc
	djnz 1B
	ret
;****************************************************************
;****************************************************************
;****    render_nexttetro:render next tetro to Screen        ****
;****************************************************************
;****************************************************************
render_nexttetro
;Find out tetro start, using tetro number and rotation state

;step 1 which tetro
	ld hl,tetrominoZero
	ld a,(next_tetro)
	cp a,0
	jp z,2F
	ld de,TETRO_BLOCK*4
1	
		adc hl,de
		dec a
		jp nz,1B
2
	push hl

;get start of plot area
	ld hl,Display+(SCREEN_WIDTH*10)+2
	ld a,(tetro_y)
	cp a,$0
	jp z,2F
	ld de,SCREEN_WIDTH
1	
		adc hl,de
		dec a
		jp nz,1B
2


;now draw the tetro onto screen
	pop de
	ld b,TETRO_SIZE
1
	push bc
	ld b,TETRO_SIZE	
2		
		ld a,(de)
		cp a, $40
		jp z,3F
			ld a,(next_tetro_char)
            jp 4F
3       ld a,$00 
4		ld (hl),a
        inc hl
		inc de
		djnz 2B
	push de
	ld de, SCREEN_WIDTH-TETRO_SIZE
	add hl,de
	pop de
	pop bc
	djnz 1B
	ret


code_end
;****************************************************************
;****************************************************************
;****    Code ends here and REM statements completes         ****
;****************************************************************
;****************************************************************
;end the REM line and put in the RAND USR line to call our 'hex code'
    include line2.asm

;display file defintion
    include screen.asm               

;close out the basic program
    include endbasic.asm
						