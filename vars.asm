
playfield 
		BLOCK ((WELL_HEIGHT+1)*(WELL_WIDTH+3)),$ff

scoreandleveltext
		DEFM	"SCORE  L"
		DEFB 	$FF
nexttext
        DEFM	"NEXT"
		DEFB 	$FF
zxtristext
        DEFM	"ZXTRIS"
		DEFB 	$FF
pausetext
        DEFM    "PAUSED -- P TO PLAY OR Q TO QUIT"
        DEFB    $FF
deletepausetext
        DEFM    "                                "
        DEFB    $FF                
gameovertext
        DEFM    "GAME OVER - PRESS SPACE"
        DEFB    $FF
titlescreen2text
        DEFM    "PRESS SPACE TO START"
        DEFB    $FF              
logo
        DEFM    "11111010001011111011100111001110"
        DEFM    "00010001010000100010010010010000"
        DEFM    "00100000100000100011100010001100"
        DEFM    "01000001010000100010010010000010"
        DEFM    "11111010001000100010010111011100"
        DEFB    $ff       
tetro_counter
		DEFB $00
current_tetro
		DEFB 0
tetro_rotation
		DEFB 0
temp_rotation
        DEFB 0        
next_tetro
		DEFB 0		
tetro_x
		DEFB 3
tetro_y
		DEFB 0
level
		DEFB 00
delay_counter
		DEFB 00
last_keyp
        DEFB 10
current_tetro_char
        DEFB 00
next_tetro_char
        DEFB 00        
speed
        DEFB 00
keyboard_block
        DEFB 00
speed_store
        DEFB 00
can_move
        DEFB 00
first_tetro
        DEFB 00        
game_over
        DEFB 00
clearedrows
        DEFB 00
totalrows
        DEFW 0000        
full_row
        DEFB 00
scoredigits
        DEFB 00,00,00,00,00
score 
    DEFW 12345
tetrominoZero

;//rotation states of I tetromino 0
	DEFM "@@@@"
	DEFM "####"
	DEFM "@@@@"
	DEFM "@@@@"

	DEFM "@#@@"
	DEFM "@#@@"
	DEFM "@#@@"
	DEFM "@#@@"

	DEFM "@@@@"
	DEFM "@@@@"
	DEFM "####"
	DEFM "@@@@"

	DEFM "@#@@"
	DEFM "@#@@"
	DEFM "@#@@"
	DEFM "@#@@"

;//rotation states of J 1
	DEFM "#@@@"
	DEFM "###@"
	DEFM "@@@@"
	DEFM "@@@@"

	DEFM "@##@"
	DEFM "@#@@"
	DEFM "@#@@"
	DEFM "@@@@"

	DEFM "@@@@"
	DEFM "###@"
	DEFM "@@#@"
	DEFM "@@@@"

	DEFM "@#@@"
	DEFM "@#@@"
	DEFM "##@@"
	DEFM "@@@@"

;//rotation states of L 2
	DEFM "@@#@"
	DEFM "###@"
	DEFM "@@@@"
	DEFM "@@@@"

	DEFM "@#@@"
	DEFM "@#@@"
	DEFM "@##@"
	DEFM "@@@@"

	DEFM "@@@@"
	DEFM "###@"
	DEFM "#@@@"
	DEFM "@@@@"

	DEFM "##@@"
	DEFM "@#@@"
	DEFM "@#@@"
	DEFM "@@@@"

;//rotation states of o 3
	DEFM "@##@"
	DEFM "@##@"
	DEFM "@@@@"
	DEFM "@@@@"

	DEFM "@##@"
	DEFM "@##@"
	DEFM "@@@@"
	DEFM "@@@@"

	DEFM "@##@"
	DEFM "@##@"
	DEFM "@@@@"
	DEFM "@@@@"

	DEFM "@##@"
	DEFM "@##@"
	DEFM "@@@@"
	DEFM "@@@@"

;//rotation states of S 4
	DEFM "@##@"
	DEFM "##@@"
	DEFM "@@@@"
	DEFM "@@@@"

	DEFM "@#@@"
	DEFM "@##@"
	DEFM "@@#@"
	DEFM "@@@@"

	DEFM "@@@@"
	DEFM "@##@"
	DEFM "##@@"
	DEFM "@@@@"

	DEFM "#@@@"
	DEFM "##@@"
	DEFM "@#@@"
	DEFM "@@@@"


;//rotation states of T 5
	DEFM "@#@@"
	DEFM "###@"
	DEFM "@@@@"
	DEFM "@@@@"

	DEFM "@#@@"
	DEFM "@##@"
	DEFM "@#@@"
	DEFM "@@@@"

	DEFM "@@@@"
	DEFM "###@"
	DEFM "@#@@"
	DEFM "@@@@"

	DEFM "@#@@"
	DEFM "##@@"
	DEFM "@#@@"
	DEFM "@@@@"

;//rotation states of z 6
	DEFM "##@@"
	DEFM "@##@"
	DEFM "@@@@"
	DEFM "@@@@"

	DEFM "@@#@"
	DEFM "@##@"
	DEFM "@#@@"
	DEFM "@@@@"

	DEFM "@@@@"
	DEFM "##@@"
	DEFM "@##@"
	DEFM "@@@@"

	DEFM "@#@@"
	DEFM "##@@"
	DEFM "#@@@"
	DEFM "@@@@"		