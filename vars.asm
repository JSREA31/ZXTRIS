
playfield 
		BLOCK ((well_height+1)*(well_width+2)),$ff

hello_txt
		DEFM	"HELLO WORLD"
		DEFB 	$FF

tetro_counter
		DEFB $00
current_tetro
		DEFB 0
tetro_rotation
		DEFB 0
next_tetro
		DEFB 0		
tetro_x
		DEFB 5
tetro_y
		DEFB 15

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