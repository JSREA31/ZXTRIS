
playfield 
		BLOCK ((WELL_HEIGHT+1)*(WELL_WIDTH+3)),$ff

hscoreandleveltext
		DEFM	"HIGH   L"
		DEFB 	$FF
scoretext
        DEFM    "SCORE"
        DEFB    $FF
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
        DEFM    "GAME OVER -- PRESS SPACE"
        DEFB    $FF
titlescreen2text
        DEFM    "PRESS SPACE TO START"
        DEFB    $FF 
instructions1text
        DEFM    176+27,170+27,190+27,184+27
        DEFB    $FF
instructions2text
        DEFM    167+27,47,"LEFT",53," ",178+27,47,"RIGHT",53," ",184+27,47,"DROP"
        DEFB    $FF
instructions3text
        DEFM    166+27,47,"ROTATE LEFT",53," ",169+27,47,"ROTATE RIGHT"
        DEFB    $FF   
instructions4text
        DEFM     181+27,47,"PAUSE",53," ",182+27,47,"QUIT"
        DEFB    $FF              
scrollingmessage
        DEFM    "                                              "
        DEFM    "ZXTRIS V",56,54,57, " BY STEVE SMITH ",57,55,57,57,54  
        DEFM    " I LEARNED TO CODE IN BASIC ON MY ZX",63,56," OVER ", 59,55," YEARS AGO BUT THIS IS MY FIRST EVER Z",63,55," PROGRAM",54
        DEFM    " WRITTEN WITH VSCODE",53," SJASMPLUS",53," DEZOG AND ZESARUX",54
        DEFM    " THANKS TO MUTANT CATERPILLAR AND RWAP FOR KEEPING MY ZX",63,56," ALIVE",54
        DEFM    "                                                "
        DEFB    $FF                          
gamekeys1
        DEFM    167+27," LEFT "
        DEFB    $FF
gamekeys2
        DEFM    178+27," RIGHT"
        DEFB    $FF
gamekeys3
        DEFM    166+27," ROT L"
        DEFB    $FF
gamekeys4
        DEFM    184+27," DROP"
        DEFB    $FF
gamekeys5
        DEFM    169+27," ROT R"
        DEFB    $FF
gamekeys6
        DEFM    181+27," PAUSE"
        DEFB    $FF
gamekeys7
        DEFM    182+27," QUIT"
        DEFB    $FF                
scrolldelay
        DEFB    45
scrolldelaycounter
        DEFB    $00        
   

logo2
        DEFM    $00,$80,$80,$80,$80,$80,$00,$80,$04,$00,$87,$80,$85,$80,$80,$80,$05,$80,$80,$80,$04,$00,$80,$80,$80,$00,$87,$80,$80,$82,$00,$00
        DEFM    $00,$00,$00,$87,$80,$01,$00,$02,$80,$83,$80,$01,$00,$00,$80,$00,$00,$80,$00,$00,$80,$00,$00,$80,$00,$00,$80,$05,$00,$03,$00,$00
        DEFM    $00,$00,$87,$80,$01,$00,$00,$00,$85,$80,$05,$00,$00,$00,$80,$00,$00,$80,$80,$80,$01,$00,$00,$80,$00,$00,$02,$80,$80,$04,$00,$00
        DEFM    $00,$87,$80,$01,$00,$00,$00,$87,$80,$03,$80,$04,$00,$00,$80,$00,$00,$80,$00,$02,$82,$00,$00,$80,$00,$00,$83,$00,$85,$80,$00,$00
        DEFM    $00,$80,$80,$80,$80,$80,$00,$80,$01,$00,$02,$80,$00,$00,$80,$00,$00,$80,$00,$00,$85,$05,$80,$80,$80,$00,$84,$80,$80,$01,$00,$00
        DEFB    $ff  

tetro_counter
		DEFB 0
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
		DEFB $00
delay_counter
		DEFB $00
last_keyp
        DEFB 10
current_tetro_char
        DEFB $00
next_tetro_char
        DEFB $00        
speed
        DEFB $00
keyboard_block
        DEFB $00
speed_store
        DEFB $00
can_move
        DEFB $00
first_tetro
        DEFB $00        
game_over
        DEFB $00
clearedrows
        DEFB $00
totalrows
        DEFW $0000       
full_row
        DEFB $00
scoredigits
        DEFB $00,$00,$00,$00,$00        
hscore
        DEFW $00000
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