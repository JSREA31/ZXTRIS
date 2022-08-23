/*
.disk [filename="PETRIS.d64", name="THE DISK", id="2021!" ]
{
[name="----------------", type="rel" ],
[name="PETRIS8032", type="prg", segments="TETRIS" ],
[name="----------------", type="rel" ],

}

 .segment TETRIS[]


 https://www.youtube.com/watch?v=k9SVvmfZTmE remember Cmd Shift +P

*/

.const wellWidth= 14
.const wellHeight = 24
.const screenstart = $8000
.const blockwidth = 16*4  //tetromino size in bytes   
.const solidsquare = $23  //the hash character - this is the solid square in the teromino rotations
.const fill_1 = $A0       //character fills for tetros when drawn to playfield
.const fill_2 = $66       //character fills for tetros wehn drawn to playfeld
.const rowsperlevel = 10
.const scoreforeachline = 10
.const scoreforeachtetro = 04
.const startcolumn=26
.const startrow=1
.const spacefiller = $20
.const loopsbeforedemo = 2
.const scrollspeed = 6

.const startplot = screenstart+startcolumn+(startrow*80)

//Zero page locations
.const twoX = $03
.const tempY= $04
.const rowcounter=$05
.const playfieldPointer = $42
.const drawPointer = $44
.const tetropointer = $46
.const xpos = $48
.const ypos= $49

*=$0400 "Basic Loader, sys 1040"
.byte $00, $0c, $04, $0a, $00, $9e, $20, $31, $30, $34, $30, $00, $00, $00

start: 
*=$0410 "main program"


//******************************
//start-screen
//*******************************
mainloop:


dostartscreen:
//set startscreen flag to on
lda #$ff
sta startscreenflag


//set demo mode flag to off
lda #$00
sta demoMode


//reset scroll message pointers to start of message
lda #<textscrollmessage
sta textscrollpointer
lda #>textscrollmessage
sta textscrollpointer+1


//draw startscreen and wait for spacebar
jsr drawstartscreen
jsr waitspacebar




//****************************
//set-up game
//*****************************
setupgame:


//initialise game variables
lda #$00
sta game_overflag
sta totalrows
sta levelincrement
sta startscreenflag
sta messagedelay
sta demoTetroPointer
sta counter
lda #$01
sta level


//set tetro on hold to ff - this mens on hold slot is empty/
lda #$ff
sta tetroOnHold


//routines that set-up game
jsr reset_score
jsr clearscreen
jsr generatePlayfield
jsr draw_screen_labels
jsr display_level
jsr display_score


//get random tetromino
jsr getrand
sta next_tetro


//set the inital speed, the delay counter and the speed_store (this gets used to restore speed after a tetromino has been dropped with space or 0)
lda #60
sta speed
sta delaycounter
sta speed_store


//set current tetro to ff (used by) spawn to figure out if this is the 1st tetro
lda #$ff
sta currenttetro


//get a random tetromino
jsr spawn


//draw the entire playfield array to the screen
jsr renderfast


//make sure keyboard is unblocked (gets block in drop mode)
lda #$00
sta keyboard_block




//****************************
//game-loop
//*****************************
gameLoop:
//I'm alive counter
//lda $8f
//sta $8000+79


    //check delaycounter - if zero then time to drop the tetro down one line
    dec delaycounter
    bne !branch+ 
        lda speed
        sta delaycounter
        jsr move_y
    !branch:


    //check if in drop mode (keyboard blocked) and if not read the keyboard and do actions like rotate, drop, hold etc
    lda keyboard_block
    bne keyboardislocked
        jsr readkeyboard
        jsr doactions
    keyboardislocked:


    //draw the tetromino to the playfield array
    jsr drawtetro


    //check to see if gameover
    lda game_overflag
    beq carryon
        jmp game_over
    carryon:


    //draw 5 lines to the screen (one above and the four lines of the tetromino)
    jsr render5


    //in counter (used for demo mode replay)
    inc counter


//back round the loop
jmp gameLoop




//*********************************************************************************
//*********************************************************************************
// 
//                       io subroutines
//
//*********************************************************************************
//*********************************************************************************


//****************************
//sub to read keyboard
//****************************
readkeyboard:
lda demoMode
beq notdemoMode
   jsr demoReplay   
   rts 
notdemoMode:
jsr $ffe4

rts


//*****************************
// do keyboard actions
//*****************************
doactions:


cmp # 'Q'
bne !checknext+
lda #$ff
    
    sta game_overflag
    rts


!checknext:
cmp # '4'
bne !checknext+
    jsr move_left
    rts


!checknext:
cmp # '6'
bne !checknext+
    jsr move_right
    rts


!checknext:
cmp # '5'
bne !checknext+
    jsr rotatetetroCW
    rts


!checknext:
cmp #'D'
bne !checknext+
    jsr rotatetetroCW
    rts


!checknext:
cmp #'A'
bne !checknext+
    jsr rotatetetroACW
    rts


!checknext:
cmp #'H'
bne !checknext+
    lda isOnHold
    bne !checknext+
    jsr holdtetro
    rts


!checknext:
cmp #'P'
bne !checknext+

    ldx #00
    !loop:
        lda textPause,X
        sta screenstart+31+(24*80),x
        inx
        cpx #17
    bne !loop-

    waitP:
        jsr readkeyboard
        cmp #'P'
    bne waitP
    jsr renderfast
    rts


!checknext:
cmp # ' '
bne !checknext+
    lda #$01
    sta delaycounter
    lda speed 
    sta speed_store
    lda #$03
    sta speed
    lda #$ff
    sta keyboard_block
    rts


!checknext:
cmp # '0'
bne !checknext+
    lda #$01
    sta delaycounter
    lda speed 
    sta speed_store
    lda #$03
    sta speed
    lda #$ff
    sta keyboard_block
    rts


!checknext:
rts


//**********************************
//replay keys from demo
//**********************************
demoReplay:


ldy #00
lda ($09),y
beq getkeyboard
cmp counter
bcc getkeyboard
    jmp end
getkeyboard:    
        
    lda #00
    sta counter
    ldy #01
    lda ($09),y
    tax
    clc
    lda $09
    adc #02
    sta $09
    lda $0A
    adc #00
    sta $0A
    txa 
    rts
    end:
    jsr $ffe4
    beq return
    jsr cleardemomessage
    lda #'Q'
    return:
    rts

rts


//**********************************
//get random number between 0 and 7
//**********************************
getrand:

lda demoMode
beq !notdemoMode+
//jump to get next demo mode peice goes here
    
    ldy demoTetroPointer
    lda ($07),y
    inc demoTetroPointer
    rts

!notdemoMode:
genrand:
    lda $8f
    and #%00000111
    cmp #$07
beq genrand
rts


//**********************************
//wait spacebar
//**********************************
waitspacebar:

.var waitspacerow = 20
.var waitspacecolumn = 30


lda demoMode
beq notdemo
    lda #00
    sta demoMode
    sta game_overflag
    rts
notdemo:

lda game_overflag
beq press_space
ldx #00
!textloop:
    lda game_over_text,X
    sta screenstart+(80*(waitspacerow))+waitspacecolumn-2,X
    lda #$20
    sta screenstart+(80*(waitspacerow-1))+waitspacecolumn-2,X
    sta screenstart+(80*(waitspacerow+1))+waitspacecolumn-2,X
    inx
    cpx #24

    
bne !textloop-

lda #$00
sta game_overflag

jmp wait

press_space:
ldx #00
!textloop:
    lda text,X
    sta screenstart+(80*(waitspacerow))+waitspacecolumn,X
    lda #$20
    sta screenstart+(80*(waitspacerow-1))+waitspacecolumn,X
    sta screenstart+(80*(waitspacerow+1))+waitspacecolumn,X
    inx
    cpx #21
bne !textloop-


wait:
    lda startscreenflag
    beq notstartscreen
        inc messagedelay
        lda messagedelay
        cmp #$ff
        bne notstartscreen
            jsr scrollmessage
            lda demoMode
            beq notstartscreen
            rts
    notstartscreen:
    jsr readkeyboard
    cmp #$20
    bne wait
rts


//**********************************
//Draw start screen
//**********************************
drawstartscreen:
jsr clearscreen

lda #00
sta timesroundloop

//change the character set
lda #12
sta 59468

///draw the logo
.var logoposX= 21
.var logoposY= 10
.var logolines = 7
.var logowidth = 36
.var text8032X = 29
.var text8032Y= 17

ldx #00
!loop:
    lda text8032,X
    sta screenstart+text8032X+(80*text8032Y),x
    inx
    cpx #25
bne !loop-


ldx #logowidth-1
drawlogo:
    .for (var i=0; i<logolines; i++)
    {
        lda #$00
        lda logoscreen+(logowidth*i), X
        sta screenstart+ (logoposY+i)*80 + logoposX,X
    }
    dex
bne drawlogo


rts



//**********************************
// do other screen labels
//***********************************
draw_screen_labels:



.var nextlabelrow = 8
.var nextlabelcolumn =56

ldx #00

!loop:
    lda text_next,X
    sta screenstart+nextlabelcolumn+ (80*nextlabelrow),X
    inx
    cpx #15
bne !loop-

ldx #00
!loop:
    lda text_on_hold,X
    sta screenstart+5+ (80*nextlabelrow),X
    inx
    cpx #19
bne !loop-

ldx #00

!loop:
    lda level_label_string,X
    sta screenstart+1,x
    inx
    cpx #5
bne !loop-


ldx #00

!loop:
    lda score_label_string,X
    sta screenstart+60,x
    inx
    cpx #5
bne !loop-


ldx #00

!loop:
    lda hscore_label_string,X
    sta screenstart+70,x
    inx
    cpx #10
bne !loop-

lda demoMode
beq nomessage
    jsr showdemomessage
nomessage:


rts

//****************************
//show demo message
//****************************
showdemomessage:

ldx #00
    !loop:
        lda demotext,X
        sta screenstart+26+(0*80),x
        inx
        cpx #28
    bne !loop-


rts

//****************************
//clear demo message
//****************************
cleardemomessage:

ldx #00
lda #$20
    !loop:
        sta screenstart+26+(0*80),x
        inx
        cpx #28
    bne !loop-


rts



//****************************
//sub to display Score
//****************************
displayScore:

.var scorelocation2 = $8000 +59 +80

//display to screen
ldx#$05
!loop:
    lda score_string, x
    clc
    adc#$30
    sta scorelocation2,x
    dex
bpl !loop-

rts

//****************************
//sub to display high Score
//****************************
displayHighScore:

.var scorelocation3 = $8000 +72 +80

//display to screen
ldx#$05
!loop:
    lda score_string, x
    clc
    adc#$30
    sta scorelocation3,x
    dex
bpl !loop-

rts


//****************************
//sub to display Level
//****************************
displayLevel:

.var levellocation = $8002 +80

lda level_string
clc
adc #$30
sta levellocation

lda level_string+1
clc
adc #$30
sta levellocation+1

rts



//****************************
//sub to clear the screen
//****************************
clearscreen: 

ldx #0
lda #32
!loop: 
    sta screenstart + 0*$100,x
    sta screenstart + 1*$100,x
    sta screenstart + 2*$100,x
    sta screenstart + 3*$100,x
    sta screenstart + 4*$100,x
    sta screenstart + 5*$100,x
    sta screenstart + 6*$100,x
    sta screenstart + 7*$100,x
    inx
bne !loop-
rts

//********************************
// render 5 lines around the tetro
//********************************

render5:



lda playfieldPointer
sta $54
lda playfieldPointer+1
sta $55

lda drawPointer
sta $56
lda drawPointer+1
sta $57

//subttract one row but only if not row zero
ldx ypos
bne subtractonerow
    //only draw 4 lines
    lda #04  
    sta rowcounter
    jmp newrow

subtractonerow:
sec
lda $54
sbc #wellWidth
sta $54
lda $55
sbc #$00
sta $55

sec
lda $56
sbc #80
sta $56
lda $57
sbc #$00
sta $57

//now draw five lines
lda #05  
sta rowcounter


newrow:
    ldx #00
    ldy #00
drawrowloop:


txa 
asl
sta twoX


lda ($54),y
bne !next+
    lda  #spacefiller
!next:


ldy twoX
sta ($56),y

//work out what 2nd tetro character should by
cmp #spacefiller
beq !done+

cmp #fill_1
bne !next+
    lda #97
    jmp !done+
!next:    
cmp #fill_2
    bne !next+
    lda #92
!next:
!done:


//add 1
iny
sta ($56),y


//increment x (column counter) - compare to wellwidth
inx
txa
tay
cpy #wellWidth
bne drawrowloop

dec rowcounter
beq endrender

clc
lda $54
adc #wellWidth
sta $54
lda $55
adc #$00
sta $55

clc
lda $56
adc #80
sta $56
lda $57
adc #$00
sta $57


jmp newrow
endrender:
rts


//********************************
// sub to render the entire screen (fast but fat = 600 bytes!)
//********************************

renderfast:


ldx #$00
ldy #$00
renderloop2:
.for (var i=0; i<wellHeight;i++)
{
    lda playfield+(i*wellWidth),X

    bne !next+
        lda  #spacefiller
        
    
    !next:
    sta screenstart+startcolumn+((startrow+i)*80),y
    cmp #fill_1
    bne !next+
        lda #97
        jmp !done+
    !next:    
        cmp #fill_2
        bne !next+
        lda #92
    !next:
    !done:
    sta screenstart+startcolumn+((startrow+i)*80)+1,y
}
inx
iny
iny
cpx #wellWidth
beq quitloop2
jmp renderloop2
quitloop2:
rts


//****************************
// game over
//****************************
game_over:

jsr waitspacebar
jmp  mainloop


//**********************************
//do scroll message
//**********************************
scrollmessage:


lda #00
sta messagedelay


inc messagedelay2
lda messagedelay2
cmp #scrollspeed
beq doscroll
rts
doscroll:

lda #$00
sta messagedelay2


reentry:
lda textscrollpointer
sta $54
lda textscrollpointer+1
sta $55

//get next 80 characters
ldy #79
!loop:


lda ($54),y
cmp #$ff
beq resettostart
sta $8000 +(24*80),y

dey
bne !loop-
jmp !branch+

resettostart:
lda #<textscrollmessage
sta textscrollpointer
lda #>textscrollmessage
sta textscrollpointer+1
inc timesroundloop
lda timesroundloop
cmp #loopsbeforedemo
bne carryonwithtexscroll
jsr setupDemoMode
rts
carryonwithtexscroll:
jmp reentry

//add one to the pointers
!branch:
clc
lda textscrollpointer
adc #$01
sta textscrollpointer
lda textscrollpointer+1
adc #00
sta textscrollpointer+1

rts


//***********************************************
// Set Up Demo Mode
//***********************************************
setupDemoMode:

lda #<tetroRecorder
sta $07
lda #>tetroRecorder
sta $08
lda #$00
sta demoTetroPointer

lda #<keyboardRecorder
sta $09
lda #>keyboardRecorder
sta $0A



lda #$ff
sta demoMode

rts


//*********************************************************************************
//*********************************************************************************
// 
//                       initialisation subroutines
//
//*********************************************************************************
//*********************************************************************************


//****************************
//sub to create an empty well
//****************************
generatePlayfield:
.var startPosition  = playfield
.var wallcharacter = 86+128

lda #wallcharacter

//draw walls
.for (var i=0; i<wellHeight-1;i++)
{
    ldx #$00
    sta playfield+(i* wellWidth),x
    ldx #wellWidth-1
    sta playfield+(i* wellWidth),x
}

//fill centre with spaces
ldx #wellWidth-2
lda #$00
fillwellwithspaces:
    .for (var i=0; i<wellHeight-1;i++)
    {
        sta playfield+(i* wellWidth),X
    }
    dex
bne fillwellwithspaces


//draw floor
lda #wallcharacter
ldx #00
floorloop:
    sta playfield+((wellHeight-1)* wellWidth),X
    inx
    cpx #wellWidth
bne floorloop
rts


//*********************************************************************************
//*********************************************************************************
// 
//                      TETRIS logic stuff
//
//*********************************************************************************
//*********************************************************************************


//*********************************
// sub to spawn a new tetromino
//*********************************
spawn:

//clear keyboard buffer
ldx #$10
clear:
    jsr $ffe4
    dex
bne clear

// //******************************************************
// //recorder stuff - remove
// ldy demoTetroPointer
// lda next_tetro
// sta ($07),y
// inc demoTetroPointer
// bne !next+    
// lda #00 
// sta counter
// !next:
// // //******************************************************

//tidy up from last tetro, clear the rows and if the ypos of the last tetro when it died was zero then game over
lda currenttetro
cmp #$ff 
beq isfirst
    jsr clearRow
    lda ypos
    bne isfirst
    lda #$ff
    sta game_overflag
    
isfirst:



//check to see if this is a hold swap
lda isOnHold
beq notOnHold
    jsr undraw
    lda currenttetro
    tax
    lda tetroOnHold
    sta currenttetro
    stx tetroOnHold
    
    
   
    lda #$00
    sta isOnHold
    lda #$ff
    sta holdLock
jmp !next+

notOnHold:
    
    lda next_tetro
    sta currenttetro
    jsr getrand
    sta next_tetro
    lda #$00
    sta holdLock

    lda fillpattern
        cmp #fill_1
    beq otherfill
        lda #fill_1
        sta fillpattern
        jmp !end+
    otherfill:
        lda #fill_2
        sta fillpattern
    !end:

!next:
//set starting x and y positions
lda #$00
sta ypos
lda #$06
sta xpos


lda speed_store
sta speed
sta delaycounter




lda #$00
sta rotationnumber

//step pointers to current tetro shape

lda #<tetrominoZero
sta tetropointer
lda #>tetrominoZero
sta tetropointer+1

ldx currenttetro
beq !done+

!loop:
    clc
    lda tetropointer
    adc #blockwidth
    sta tetropointer
    lda tetropointer+1
    adc #$00
    sta tetropointer+1
    dex
bne !loop-

!done:

jsr drawnext
jsr drawheld

lda #$00
sta keyboard_block

//reset pointers to playfield and screen
lda #<playfield
sta playfieldPointer
lda #>playfield
sta playfieldPointer+1

lda #<startplot
sta drawPointer
lda #>startplot
sta drawPointer+1

jsr renderfast
rts



//**************************************************
// sub to check rows to see if they can be cleared (calls clear this row if they can be)
//*************************************************
clearRow:

//score multiplier if multiple rows cleared in one go.
lda #$00
sta clearedrows


//load start of playfield
lda #<playfield
sta $56
lda #>playfield
sta $57

//go to bottom of playfield
ldx #wellHeight-2
!loop:
    clc
    lda $56
    adc #wellWidth
    sta $56
    lda $57
    adc #$00
    sta $57
    dex
bne !loop-


//start on the bottom row and see if it is blank
ldx #wellHeight-2
checkingtherows:
    ldy #01
    checkeachrow:
        lda ($56),y
        beq rownotfull
        iny
        cpy #wellWidth-1
    bne checkeachrow

    stx tempX
    jsr clearthisrow
    ldx tempX
    jmp checkingtherows

    rownotfull:
    sec
    lda $56
    sbc #wellWidth
    sta $56
    lda $57
    sbc #$00
    sta $57
    dex

bne checkingtherows
rts


//**********************************
//clear a row
//***********************************
clearthisrow:

inc clearedrows
inc totalrows


//creates a temp set of pointers to playfield as the clearrows sub needs these to stay intact
lda $56
sta $58
sta $01

lda $57
sta $59
sta $02

//subract one row from 01/02 (this is the row we will copy from), 58/59 is the copy to row.
sec
lda $01
sbc #wellWidth
sta $01
lda $02
sbc #$00
sta $02

ldx tempX

//move each row down one in the entire playfield
row:
    ldy #$01
    column:
        lda ($01),y
        sta ($58),y
        iny
        cpy #wellWidth-1
    bne column

    sec
    lda $58
    sbc #wellWidth
    sta $58
    lda $59
    sbc #$00
    sta $59

    sec
    lda $58
    sbc #wellWidth
    sta $01
    lda $59
    sbc #$00
    sta $02

    dex
    cpx #$02
bne row

jsr renderfast
jsr add_line_to_score

//play a sound
lda demoMode
bne dontplay

jsr $e6a7

dontplay:

//check to see if at next level
inc levelincrement
lda levelincrement
cmp #rowsperlevel
bne dontincrementlevel
    inc level
    
    jsr display_level


    lda #$00
    sta levelincrement
    lda speed_store
    sec
    sbc #$05
    bne notminimum
    lda #$05
    notminimum:
    sta speed_store
dontincrementlevel:

rts


//*********************************
//sub to move tetro left
//*********************************

move_left:
lda xpos
bne notedge
rts
notedge:

jsr undraw
dec xpos
jsr collisionCheck
lda can_move
beq itcanmovexL
    inc xpos
    jsr drawtetro //have to reddraw tetro as collison check deleted it.
itcanmovexL:
rts


//*********************************
//sub to move tetro right
//*********************************

move_right:
jsr undraw
inc xpos
jsr collisionCheck	//first check if it can move
lda can_move
beq itcanmovexR
    dec xpos
    jsr drawtetro //have to reddraw tetro as collison check deleted it.
itcanmovexR:
rts



//*********************************
//sub to move tetro down one line 
//*********************************

move_y:
jsr undraw

//add one row to playfiled pointer
clc
lda playfieldPointer
adc #wellWidth
sta playfieldPointer
lda playfieldPointer+1
adc #00
sta playfieldPointer+1

jsr collisionCheck 	//first check if it can move
lda can_move
beq itcanmove
    //move back one row as can't move
    sec
    lda playfieldPointer
    sbc #wellWidth
    sta playfieldPointer
    lda playfieldPointer+1
    sbc #00
    sta playfieldPointer+1

    jsr drawtetro //have to reddraw tetro as collison check deleted it.
    jsr bump_score
    jsr spawn
    rts

itcanmove:
//add one row to screen pointers, playfield pointer alrady been moved mbefore test

clc
lda drawPointer
adc #80
sta drawPointer
lda drawPointer+1
adc #$00
sta drawPointer+1
inc ypos


rts



//***************************************
// sub to undraw last tetro
//***************************************
undraw:
lda tetropointer
sta $54
lda tetropointer+1
sta $55


//load playfield row
lda playfieldPointer
sta $56
lda playfieldPointer+1
sta $57


// add x position 
clc
lda $56
adc xpos
sta $56
lda $57
adc #$00
sta $57


//now clear the tetromino squares
ldx #$04
ldy #$00

!loop:
    lda ($54), y
    cmp #solidsquare
    bne !loop+
        lda ($56),y
        beq !loop+
    lda #$00
    sta ($56), y
	!loop:
    iny
    cpy #$04
    bne !loop--
    dex
    beq !endloop+
    //add width of well to playfield pointer
    clc
    lda $56
    adc #wellWidth
    sta $56
    lda $57
    adc #$00
    sta $57
    //add width of tetromino (4) to tetromino pointer
    clc
    lda $54
    adc #$04
    sta $54
    lda $55
    adc #$00
    sta $55

    ldy #$00
jmp !loop--


!endloop:

rts


//********************************
// sub to render a tetromino
//********************************

drawtetro:
//pointer for current tetromino
lda tetropointer
sta $54
lda tetropointer+1
sta $55


//load playfield row
lda playfieldPointer
sta $56
lda playfieldPointer+1
sta $57


// add x position 
clc
lda $56
adc xpos
sta $56
lda $57
adc #$00
sta $57


//now draw the four rows to the playfield
ldx #$04
ldy #$00


!loop:
    lda ($54), y
    cmp #solidsquare
    bne !loop+
	lda ($56),y
    bne !loop+
    lda fillpattern	
    sta ($56), y
	!loop:
    iny
    cpy #$04
    bne !loop--
    dex
    beq !endloop+
    //add width of well to playfield pointer
    clc
    lda $56
    adc #wellWidth
    sta $56
    lda $57
    adc #$00
    sta $57
    //add width of tetromino (4) to tetromino pointer
    clc
    lda $54
    adc #$04
    sta $54
    lda $55
    adc #$00
    sta $55

    ldy #$00
jmp !loop--


!endloop:
rts



//********************************
// sub to hold a tetro
//********************************
holdtetro:

lda holdLock
bne onLock

    lda tetroOnHold
    cmp #$ff
    beq firsthold
        lda #$ff
        sta isOnHold
        jsr spawn
onLock:
rts

firsthold:
jsr undraw
lda currenttetro
sta tetroOnHold
lda #$ff
sta holdLock
lda fillpattern
sta holdFill
jsr spawn
rts

//********************************
// sub to render the "next tetro"
//********************************

drawnext:

//pointer for current tetromino
lda #<tetrominoZero
sta $54
lda #>tetrominoZero
sta $55

ldx next_tetro
beq !done+

!loop:
clc
lda $54
adc #blockwidth
sta $54
lda $55
adc #$00
sta $55
dex
bne !loop-
!done:


//load start of screen memory to display the "next" tetro
lda #$6a
sta $56
lda #$82
sta $57

//now draw the four rows to the playfield
ldx #$04
ldy #$00


!loop:
    lda ($54), y
    cmp #solidsquare
    bne spacefill
	    lda fillpattern
        cmp #fill_1
        bne swapfill
            lda #fill_2
            jmp !next+
        swapfill:
            lda #fill_1	
           jmp!next+
        spacefill:
            lda#$20
        !next:
    
    sta ($56), y
    inc $56
    cmp #fill_1
    bne !next+
        lda #97
        jmp !done+
    !next:    
        cmp #fill_2
        bne !next+
        lda #92
    !next:

    !done:

    sta ($56),y
    iny
    cpy #$04
    bne !loop-
    dex
    beq !endloop+
    //add width of well to playfield pointer
    clc
    lda $56
    adc #76
    sta $56
    lda $57
    adc #$00
    sta $57
    //add width of tetromino (4) to tetromino pointer
    clc
    lda $54
    adc #$04
    sta $54
    lda $55
    adc #$00
    sta $55

    ldy #$00
jmp !loop-


!endloop:

rts


//********************************
// sub to render the "held tetro"
//********************************

drawheld:

lda tetroOnHold
cmp #$ff
    bne notEmpty
    rts

notEmpty:

//pointer for current tetromino
lda #<tetrominoZero
sta $54
lda #>tetrominoZero
sta $55

ldx tetroOnHold
beq !done+

!loop:
clc
lda $54
adc #blockwidth
sta $54
lda $55
adc #$00
sta $55
dex
bne !loop-
!done:


//load start of screen memory to display the "next" tetro
lda #$3d
sta $56
lda #$82
sta $57

//now draw the four rows to the playfield
ldx #$04
ldy #$00


!loop:
    lda ($54), y
    cmp #solidsquare
    bne spacefill2
	    lda holdFill
        jmp!next+
    spacefill2:
        lda#$20
        !next:
    
    sta ($56), y
    inc $56
    cmp #fill_1
    bne !next+
        lda #97
        jmp !done+
    !next:    
        cmp #fill_2
        bne !next+
        lda #92
    !next:

    !done:

    sta ($56),y
    iny
    cpy #$04
    bne !loop-
    dex
    beq !endloop+
    //add width of well to playfield pointer
    clc
    lda $56
    adc #76
    sta $56
    lda $57
    adc #$00
    sta $57
    //add width of tetromino (4) to tetromino pointer
    clc
    lda $54
    adc #$04
    sta $54
    lda $55
    adc #$00
    sta $55

    ldy #$00
jmp !loop-


!endloop:

rts

//**************************************
// sub to rotate a tetromino Clock Wise
//**************************************
rotatetetroCW:
// increments rotation number and  bumps tetromino pointer on by one blocck of 16 bytes or resets it to rotation zero

jsr undraw

lda rotationnumber
sta temp_Rotation
lda tetropointer
sta temp_pointer_low
lda  tetropointer+1
sta temp_Pointer_high


lda rotationnumber
cmp #$03
beq resetanimationtozero
//add 16 to tetropointer
inc rotationnumber
clc
lda tetropointer
adc #$10
sta tetropointer
lda tetropointer+1
adc #$00
sta tetropointer+1

jsr checkrotation

rts

resetanimationtozero:
lda#$00
sta rotationnumber
//subtract 3x16 from tetropointer
sec
lda tetropointer
sbc #$30
sta tetropointer
lda tetropointer+1
sbc #$00
sta tetropointer+1

jsr checkrotation

rts


//**************************************
// sub to rotate a tetromino Anti Clock Wise
//**************************************
rotatetetroACW:
// increments rotation number and  bumps tetromino pointer on by one blocck of 16 bytes or resets it to rotation zero

jsr undraw

lda rotationnumber
sta temp_Rotation
lda tetropointer
sta temp_pointer_low
lda  tetropointer+1
sta temp_Pointer_high

lda rotationnumber
beq resetanimationto3
//sub 16 from tetropointer
dec rotationnumber
sec
lda tetropointer
sbc #$10
sta tetropointer
lda tetropointer+1
sbc #$00
sta tetropointer+1

jsr checkrotation

rts


resetanimationto3:
lda#$03
sta rotationnumber
//subtract 3x16 from tetropointer
clc
lda tetropointer
adc #$30
sta tetropointer
lda tetropointer+1
adc #$00
sta tetropointer+1

jsr checkrotation

rts


//*************************************
// sub to check a rotation (including wall collision)
//*************************************
checkrotation:

jsr collisionCheck

lda can_move
bne blocked
rts

blocked:
//try a wall kick
lda xpos
cmp #03
bcc tryleftwallkick
cmp #wellWidth-3
bcs tryrightwallkick

//id these fail or can't be done restore
restore:
lda temp_Rotation
sta rotationnumber
lda temp_pointer_low
sta tetropointer
lda temp_Pointer_high
sta tetropointer+1
rts

//try and rotate with a shift away from the wall (x+1)
tryleftwallkick:
inc xpos
jsr collisionCheck
dec xpos
lda can_move
bne restore
inc xpos
rts

//try and rotate with a shift away from the wall (x-1)
tryrightwallkick:

lda currenttetro
beq longtetro

dec xpos
jsr collisionCheck
inc xpos

lda can_move
bne restore
dec xpos
rts

//special case long tetro needs a shioft of (x-2)
longtetro:
dec xpos
dec xpos
jsr collisionCheck
inc xpos
inc xpos
lda can_move
bne restore
dec xpos
dec xpos
rts


//*************************************
// generic collisionCheck
//*************************************
collisionCheck:

lda #$00
sta can_move

lda tetropointer
sta $54
lda tetropointer+1
sta $55

//load Playfield pointer and add one row (need to check one row below)

lda playfieldPointer
sta $56
lda playfieldPointer+1
sta $57

//add xpos
clc
lda $56
adc xpos
sta $56
lda $57
adc #$00
sta $57


//for each filled square in tetro check the square one line below
ldx #$04
ldy #$00

!loop:
    lda ($54), y
	cmp #solidsquare
    bne !loop+
    	lda ($56),y
		beq !loop+
		lda#$ff
    	sta can_move
        rts
	!loop:
    iny
    cpy #$04
    bne !loop--
    dex
    beq !endloop+
    //add width of well to playfield pointer
    clc
    lda $56
    adc #wellWidth
    sta $56
    lda $57
    adc #$00
    sta $57
    //add width of tetromino (4) to tetromino pointer
    clc
    lda $54
    adc #$04
    sta $54
    lda $55
    adc #$00
    sta $55

    ldy #$00
jmp !loop--

!endloop:

rts

//*********************************
//bump score for each line cleared
//*********************************
add_line_to_score:

// add X for each level
lda #$00
ldx level
!loop:
    clc
    adc #scoreforeachline
    sta linescore
    lda linescore+1
    adc #$00
    sta linescore+1
dex
bne !loop-


// add it multiple times for each row 

lda clearedrows
asl
tax
!loop:
    clc
    lda score
    adc linescore
    sta score
    lda score+1
    adc linescore+1
    sta score+1
    lda score+2
    adc #00
    sta score+2
    dex
bne !loop-

jsr display_score

rts

//***************************************
//  bump the score for each peice dropped
//***************************************
bump_score:



// add x level
lda #$00
ldx level
!loop:
    clc
    adc #scoreforeachtetro
dex
bne !loop-

sta scorexlevel

clc
lda score
adc scorexlevel
sta score
lda score+1
adc#00
sta score+1
lda score+2
adc#00
sta score+2

jsr display_score
rts



//*******************************************
// convert score to string
//*******************************************
convertscore:

ldy #$00
!loop:
ldx #$00
!loop:
    sec
    lda scoretemp
    sbc lowbyte,y
    sta scoretemp
    lda scoretemp+1
    sbc midbyte,y
    sta scoretemp+1
    lda scoretemp+2
    sbc highbyte,y
    sta scoretemp+2
    inx
bcs !loop-
clc
lda scoretemp
adc lowbyte,y
sta scoretemp
lda scoretemp+1
adc midbyte,y
sta scoretemp+1
lda scoretemp+2
adc highbyte,y
sta scoretemp+2
dex
txa
sta score_string,y

iny
cpy #$05
bne !loop--

//do units
lda scoretemp
sta score_string,y


rts

highbyte:
.byte $01, $00, $00, $00, $00
midbyte:
.byte $86, $27, $03, $00, $00
lowbyte:
.byte $a0, $10, $e8, $64, $0a

//10        =   #$00000A
//100       =   #$000064
//1000      =   #$0003E8
//10000     =   #$002710
//100000    =   #$0186A0


//*******************************************
// display the score, convert hex into string
//*******************************************
display_score:

lda score
sta scoretemp
lda score+1
sta scoretemp+1
lda score+2
sta scoretemp+2

jsr convertscore

jsr displayScore

lda demoMode
bne indemomode
    jsr updatehighscore
indemomode:

rts


//********************************
// show level
//********************************
display_level:

lda level

sta leveltemp

//count tens
ldx #00
!loop:
    sec
    lda leveltemp
    sbc #$0a
    sta leveltemp
    inx
bcs !loop-
clc
lda leveltemp
adc #$0a
sta leveltemp
dex
txa
sta level_string

//do units
lda leveltemp
sta level_string+1

jsr displayLevel

rts


//*******************************
//  reset score
//********************************
reset_score:

lda #$00
sta score
sta score+1
sta score+2
rts

//*******************************
//  update high score
//********************************
updatehighscore:

//compare score to high score and update if it is greater

lda score+2
cmp hscore+2
beq !next+
bcs update

!next:
lda score+1
cmp hscore+1
beq !next+
bcs update

!next:
lda score
cmp hscore
beq !next+
bcs update

!next:
jmp dontupdate

update:
lda score
sta hscore
lda score+1
sta hscore+1
lda score+2
sta hscore+2

dontupdate:
lda hscore
sta scoretemp
lda hscore+1
sta scoretemp+1
lda hscore+2
sta scoretemp+2

jsr convertscore

jsr displayHighScore

rts


//******************************
//    storage area & data
//******************************

demoMode:
.byte 00

demoCounter:
.byte 00

counter:
.byte 00

currenttetro:
.byte 00

tetroOnHold:
.byte $ff

holdLock:
.byte 00

isOnHold:
.byte 00

holdFill:
.byte 00

// tetropointer:
// .byte 00
// .byte 00


rotationnumber:
.byte 00

speed:
.byte 50

speed_store:
.byte 00

delaycounter:
.byte 00

fillpattern:
.byte 00

clearedrows:
.byte 00

totalrows:
.byte 00

tempX:
.byte 00

next_tetro:
.byte 00

temp_Rotation:
.byte 00

temp_pointer_low:
.byte 00
 
temp_Pointer_high:
.byte 00

can_move:
.byte 00

keyboard_block:
.byte 00

game_overflag:
.byte 00

score:
.byte 00,00,00

scoretemp:
.byte 00,00,00

hscore:
.byte 00,00,00

level:
.byte 00

leveltemp:
.byte 00

scorexlevel:
.byte 00

levelincrement:
.byte 00

linescore:
.byte 00
.byte 00

textscrollpointer:
.byte 00
.byte 00

startscreenflag:
.byte 00

messagedelay:
.byte 00

timesroundloop:
.byte 0

messagedelay2:
.byte 00

demoTetroPointer:
.byte 00

demotext:
.text " demo mode - press any key "

text:
.text " press space to play "

text_next:
.text "<          next"

game_over_text:
.text " game over--press space "

text_on_hold:
.text "on hold         <->"

level_label_string:
.text "level"


score_label_string:
.text "score"

hscore_label_string:
.text "high score"

text8032:
.text "for the 80 column cbm pet"

textPause:
.text " paused: press p "

score_string:
.text "000000"

level_string:
.text "00"

//tetrominoes
tetrominoZero:

//rotation states of I tetromino 0
.text "@@@@"
.text "####"
.text "@@@@"
.text "@@@@"

.text "@#@@"
.text "@#@@"
.text "@#@@"
.text "@#@@"

.text "@@@@"
.text "@@@@"
.text "####"
.text "@@@@"

.text "@#@@"
.text "@#@@"
.text "@#@@"
.text "@#@@"

//rotation states of J 1
.text "#@@@"
.text "###@"
.text "@@@@"
.text "@@@@"

.text "@##@"
.text "@#@@"
.text "@#@@"
.text "@@@@"

.text "@@@@"
.text "###@"
.text "@@#@"
.text "@@@@"

.text "@#@@"
.text "@#@@"
.text "##@@"
.text "@@@@"

//rotation states of L 2
.text "@@#@"
.text "###@"
.text "@@@@"
.text "@@@@"

.text "@#@@"
.text "@#@@"
.text "@##@"
.text "@@@@"

.text "@@@@"
.text "###@"
.text "#@@@"
.text "@@@@"

.text "##@@"
.text "@#@@"
.text "@#@@"
.text "@@@@"

//rotation states of o 3
.text "@##@"
.text "@##@"
.text "@@@@"
.text "@@@@"

.text "@##@"
.text "@##@"
.text "@@@@"
.text "@@@@"

.text "@##@"
.text "@##@"
.text "@@@@"
.text "@@@@"

.text "@##@"
.text "@##@"
.text "@@@@"
.text "@@@@"

//rotation states of S 4
.text "@##@"
.text "##@@"
.text "@@@@"
.text "@@@@"

.text "@#@@"
.text "@##@"
.text "@@#@"
.text "@@@@"

.text "@@@@"
.text "@##@"
.text "##@@"
.text "@@@@"

.text "#@@@"
.text "##@@"
.text "@#@@"
.text "@@@@"


//rotation states of T 5
.text "@#@@"
.text "###@"
.text "@@@@"
.text "@@@@"

.text "@#@@"
.text "@##@"
.text "@#@@"
.text "@@@@"

.text "@@@@"
.text "###@"
.text "@#@@"
.text "@@@@"

.text "@#@@"
.text "##@@"
.text "@#@@"
.text "@@@@"

//rotation states of z 6
.text "##@@"
.text "@##@"
.text "@@@@"
.text "@@@@"

.text "@@#@"
.text "@##@"
.text "@#@@"
.text "@@@@"

.text "@@@@"
.text "##@@"
.text "@##@"
.text "@@@@"

.text "@#@@"
.text "##@@"
.text "#@@@"
.text "@@@@"



logoscreen:
    .byte	$20,$20,$20,$20,$E0,$E0,$E0,$E0,$20,$20,$E0,$E0,$E0,$E0,$20,$20,$E0,$E0,$E0,$E0,$E0,$20,$20,$E0,$E0,$E0,$E0,$20,$20,$E0,$20,$20,$E0,$E0,$E0,$E0
	.byte	$20,$20,$20,$20,$E0,$20,$20,$E0,$20,$20,$E0,$20,$20,$20,$20,$20,$20,$20,$E0,$20,$20,$20,$20,$E0,$20,$20,$E0,$20,$20,$E0,$20,$20,$E0,$20,$20,$20
    .byte	$20,$20,$20,$20,$E0,$20,$20,$E0,$20,$20,$E0,$20,$20,$20,$20,$20,$20,$20,$E0,$20,$20,$20,$20,$E0,$20,$20,$E0,$20,$20,$E0,$20,$20,$E0,$20,$20,$20
	.byte	$20,$20,$20,$20,$E0,$E0,$E0,$E0,$20,$20,$E0,$E0,$E0,$20,$20,$20,$20,$20,$E0,$20,$20,$20,$20,$E0,$E0,$E0,$E0,$20,$20,$E0,$20,$20,$E0,$E0,$E0,$E0
	.byte	$20,$20,$20,$20,$E0,$20,$20,$20,$20,$20,$E0,$20,$20,$20,$20,$20,$20,$20,$E0,$20,$20,$20,$20,$20,$E9,$E0,$E0,$20,$20,$E0,$20,$20,$20,$20,$20,$E0
	.byte	$20,$20,$20,$20,$E0,$20,$20,$20,$20,$20,$E0,$20,$20,$20,$20,$20,$20,$20,$E0,$20,$20,$20,$20,$E9,$E0,$69,$E0,$20,$20,$E0,$20,$20,$20,$20,$20,$E0
	.byte	$20,$20,$20,$20,$E0,$20,$20,$20,$20,$20,$E0,$E0,$E0,$E0,$20,$20,$20,$20,$E0,$20,$20,$20,$E9,$E0,$69,$20,$E0,$20,$20,$E0,$20,$20,$E0,$E0,$E0,$E0



textscrollmessage:
.fill 80,$20
.text "instructions: left=4, right=6, rotate=5, 0=drop, p=pause, h=hold/swap. you can also use a & d to rotate and space to drop in two handed mode!"
.fill 80, $20
.text " written during 2020 covid lockdown using vs code with the kickass plug-in (captain jinx) for the 6502 kick assembler (mads nielsen). debugged using vice for osx and the amazing sd2pet future from tfw8b. shout out to tynemouth software (for keeping my pet alive) SSS and to rick t for the encouragement.  "
.fill 80, $20
.byte $ff

//memory for playfield
playfield:
.fill wellHeight*wellWidth, 00  

tetroRecorder:
.byte 04, 00, 06, 01, 06, 00, 00, 03, 00, 05, 03, 05, 01, 01, 00, 01, 00, 01, 03, 00, 01, 00, 05, 06, 02, 00, 00, 05, 01, 02, 00, 00, 04, 02, 02, 00, 04, 01, 04, 01, 05, 05, 03, 00, 03, 02, 01, 02, 05, 03, 06, 06, 00, 02, 06      

keyboardRecorder:
.byte $f0, $34
.byte $20, $34
.byte $20, $34
.byte $20, $34
.byte $20, $35
.byte $20, $35
.byte $20, $20


.byte $60, $35
.byte $60, $36
.byte $50, $35
.byte $f0, $20

.byte $f0, $35 
.byte $f0, $34
.byte $10, $34
.byte $10, $34
.byte $10, $34
.byte $30, $34
.byte $40, $34
.byte $30, $20

.byte $80, $35
.byte $80, $35
.byte $80, $36
.byte $80, $36
.byte $80, $36
.byte $80, $20

.byte $80, $35
.byte $80, $34
.byte $f0, $20

.byte $70, $35
.byte $30, $36
.byte $30, $36
.byte $30, $36
.byte $30, $36
.byte $30, $36
.byte $79, $20

.byte $a0, $34
.byte $a0, $34
.byte $30, $35
.byte $50, $20

.byte $f0, $36
.byte $50, $36
.byte $50, $36
.byte $d0, $20

.byte $d0, $35
.byte $50, $36
.byte $A0, $20

.byte $50, $35
.byte $50, $34
.byte $50, $34
.byte $50, $34
.byte $20, $34
.byte $20, $34
.byte $20, $34
.byte $50, $20

.byte $50, $36
.byte $50, $36
.byte $50, $36
.byte $50, $36
.byte $a0, $20


.byte $50, $34
.byte $50, $34
.byte $50, $34
.byte $50, $35
.byte $50, $35
.byte $50, $35
.byte $90, $20


//random from here

.byte $60, $35
.byte $60, $36
.byte $50, $35
.byte $f0, $20

.byte $f0, $35 
.byte $f0, $34
.byte $10, $34
.byte $10, $34
.byte $10, $34
.byte $30, $34
.byte $40, $34
.byte $30, $20

.byte $80, $35
.byte $80, $35
.byte $80, $36
.byte $80, $36
.byte $80, $36
.byte $80, $20

.byte $80, $35
.byte $80, $34
.byte $f0, $20

.byte $70, $35
.byte $30, $36
.byte $30, $36
.byte $30, $36
.byte $30, $36
.byte $30, $36
.byte $79, $20

.byte $a0, $34
.byte $a0, $34
.byte $30, $35
.byte $50, $20

.byte $f0, $36
.byte $50, $36
.byte $50, $36
.byte $d0, $20

.byte $d0, $35
.byte $50, $36
.byte $A0, $20

.byte $50, $35
.byte $50, $34
.byte $50, $34
.byte $50, $34
.byte $20, $34
.byte $20, $34
.byte $20, $34
.byte $50, $20

.byte $60, $35
.byte $60, $36
.byte $50, $35
.byte $f0, $20

.byte $f0, $35 
.byte $f0, $34
.byte $10, $34
.byte $10, $34
.byte $10, $34
.byte $30, $34
.byte $40, $34
.byte $30, $20

.byte $80, $35
.byte $80, $35
.byte $80, $36
.byte $80, $36
.byte $80, $36
.byte $80, $20

.byte $80, $35
.byte $80, $34
.byte $f0, $20

.byte $70, $35
.byte $30, $36
.byte $30, $36
.byte $30, $36
.byte $30, $36
.byte $30, $36
.byte $79, $20

.byte $a0, $34
.byte $a0, $34
.byte $30, $35
.byte $50, $20

.byte $f0, $36
.byte $50, $36
.byte $50, $36
.byte $d0, $20

.byte $d0, $35
.byte $50, $36
.byte $A0, $20

.byte $50, $35
.byte $50, $34
.byte $50, $34
.byte $50, $34
.byte $20, $34
.byte $20, $34
.byte $20, $34
.byte $50, $20

.byte $60, $35
.byte $60, $36
.byte $50, $35
.byte $f0, $20

.byte $f0, $35 
.byte $f0, $34
.byte $10, $34
.byte $10, $34
.byte $10, $34
.byte $30, $34
.byte $40, $34
.byte $30, $20

.byte $80, $35
.byte $80, $35
.byte $80, $36
.byte $80, $36
.byte $80, $36
.byte $80, $20

.byte $80, $35
.byte $80, $34
.byte $f0, $20

.byte $70, $35
.byte $30, $36
.byte $30, $36
.byte $30, $36
.byte $30, $36
.byte $30, $36
.byte $79, $20

.byte $a0, $34
.byte $a0, $34
.byte $30, $35
.byte $50, $20

.byte $f0, $36
.byte $50, $36
.byte $50, $36
.byte $d0, $20

.byte $d0, $35
.byte $50, $36
.byte $A0, $20

.byte $50, $35
.byte $50, $34
.byte $50, $34
.byte $50, $34
.byte $20, $34
.byte $20, $34
.byte $20, $34
.byte $50, $20

.byte $60, $35
.byte $60, $36
.byte $50, $35
.byte $f0, $20

.byte $f0, $35 
.byte $f0, $34
.byte $10, $34
.byte $10, $34
.byte $10, $34
.byte $30, $34
.byte $40, $34
.byte $30, $20

.byte $80, $35
.byte $80, $35
.byte $80, $36
.byte $80, $36
.byte $80, $36
.byte $80, $20

.byte $80, $35
.byte $80, $34
.byte $f0, $20

.byte $70, $35
.byte $30, $36
.byte $30, $36
.byte $30, $36
.byte $30, $36
.byte $30, $36
.byte $79, $20

.byte $a0, $34
.byte $a0, $34
.byte $30, $35
.byte $50, $20

.byte $f0, $36
.byte $50, $36
.byte $50, $36
.byte $d0, $20

.byte $d0, $35
.byte $50, $36
.byte $A0, $20

.byte $50, $35
.byte $50, $34
.byte $50, $34
.byte $50, $34
.byte $20, $34
.byte $20, $34
.byte $20, $34
.byte $50, $20

//.import binary "keyboard.bin"

