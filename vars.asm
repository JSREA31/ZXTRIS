;*************************
;**** well dimensions ****
;*************************
well_width  = 10+2
well_height = 23+1
well_wall_char = $17

playfield 
		BLOCK (well_height*well_width),$00

hello_txt
		DEFM	"HELLO WORLD"
		DEFB 	$FF
inputA
		DEFB	30
inputB
		DEFB	6		
outputC
		DEFB	$00			