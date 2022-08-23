;*************************
;**** well dimensions ****
;*************************


playfield 
		BLOCK ((well_height+1)*(well_width+2)),$ff

hello_txt
		DEFM	"HELLO WORLD"
		DEFB 	$FF
inputA
		DEFB	30
inputB
		DEFB	6		
outputC
		DEFB	$00			