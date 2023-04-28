
	.text
	.data

	.global lab7

	.global UART0_Handler
	.global Switch_Handler
	.global Timer_Handler

	.global uart_init
	.global output_character
	.global output_string
    .global int2string
	.global illuminate_LEDs
	.global read_character
	.global read_from_push_btns

	.global uart_interrupt_init
    .global gpio_interrupt_init
    .global timer_interrupt_init
	.global gpio_btn_and_LED_init
    .global disable_timer

uartresult:			.byte 0
gameStartOne:		.string "Controls: use a and d keys to move the paddle right and left", 0
gameStartTwo:		.string "Press and hold number of switches to choose the number of rows of bricks", 0
gameStartThree:		.string "Press any key on the board to continue and play", 0
gameOverStringOne:	.string "Game Over! Score: ",0
gameOverStringTwo:	.string "Press c to continue, or any other key to quit.", 0
gamePaused:			.string "Paused", 0
gameUnpaused:		.string "      ", 0
scorePlaceholder:	.string "       ", 0
xescapeStringBuffer: .string "                 ",0
yescapeStringBuffer: .string "                 ",0
beginBackgroundEscape: .string 27, "[4", 0
beginColorEscape: 	.string 27, "[3", 0
endColorEscape:   	.string ";1;1m", 0
resetColorString:   .string 27, "[0m", 0
brickState:  		.word 0x0
xDelta:  			.byte 0
yDelta: 			.byte 1
score: 				.word 0x0
ballxPosition:  	.byte 0x0B
ballyPosition:  	.byte 0x08
paddlePos: 			.byte 0x09
ballColor:  		.byte 0x00
lives:  			.byte 0x04
level:  			.byte 0x01
pauseState:  		.byte 0x00
scoreString:		.string "Score: ", 0
topBottomBorder:	.string "+---------------------+", 0

; Pointers to memory locations

ptr_to_uartresult:				.word uartresult
ptr_to_gameStartOne:			.word gameStartOne
ptr_to_gameStartTwo:			.word gameStartTwo
ptr_to_gameStartThree:			.word gameStartThree
ptr_to_gameOverStringOne:		.word gameOverStringOne
ptr_to_gameOverStringTwo:		.word gameOverStringTwo
ptr_to_gamePaused:				.word gamePaused
ptr_to_gameUnpaused:			.word gameUnpaused
ptr_to_scorePlaceholder:		.word scorePlaceholder
ptr_to_xescapeStringBuffer: 	.word xescapeStringBuffer
ptr_to_yescapeStringBuffer: 	.word yescapeStringBuffer
ptr_to_beginBackgroundEscape:	.word beginBackgroundEscape
ptr_to_beginColorEscape:		.word beginColorEscape
ptr_to_endColorEscape:			.word endColorEscape
ptr_to_brickState:				.word brickState
ptr_to_xDelta:					.word xDelta
ptr_to_yDelta:					.word yDelta
ptr_to_score:					.word score
ptr_to_ballxPosition:			.word ballxPosition
ptr_to_ballyPosition:			.word ballyPosition
ptr_to_paddlePos:				.word paddlePos
ptr_to_ballColor:				.word ballColor
ptr_to_lives:  					.word lives
ptr_to_level:					.word level
ptr_to_pauseState:				.word pauseState
ptr_to_scoreString:				.word scoreString
ptr_to_topBottomBorder:			.word topBottomBorder
ptr_to_resetColorString:   		.word resetColorString
a
lab7:
	PUSH {lr}   ; Store lr to stack

	; Initialization functions
	BL uart_init
	BL uart_interrupt_init
	BL gpio_btn_and_LED_init
	BL gpio_interrupt_init
	BL resetColor
	BL timer_interrupt_init
	BL disable_timer

restartGame:
	; Clear the page
	MOV r0, #0xc
	BL output_character

	; Print the game start instructions
	MOV r0, #0
	MOV r1, #0
	BL setCursorxy
	LDR r0, ptr_to_gameStartOne
	BL output_string					; Print first instruction
	MOV r0, #0
	MOV r1, #1
	BL setCursorxy					; Move cursor to next row
	LDR r0, ptr_to_gameStartTwo
	BL output_string					; Print second instruction
	MOV r0, #0
	MOV r1, #2
	BL setCursorxy					; Move cursor to next row
	LDR r0, ptr_to_gameStartThree
	BL output_string					; Print third instruction

	; Wait for keypress and then read buttons pressed
	BL read_character
	BL read_from_push_btns
	; r0 contains number of buttons pressed now, so put ones in needed spaces now
	LDR r4, ptr_to_brickState
	CMP r0, #2
	BLT oneRow
	BEQ twoRow
	CMP r0, #3
	BEQ threeRow
	BGT fourRow

	; This also serves as the catch in case no buttons are pressed
oneRow:
	; Insert one row of bricks into brickState
	MOV r5, #0x7F
	STR r5, [r4]
	B rowsDone
twoRow:
	; Insert two rows of bricks into brickState
	MOV r5, #0x3FFF
	STR r5, [r4]
	B rowsDone
threeRow:
	; Insert three rows of bricks into brickState
	MOV r5, #0xFFFF
	MOVT r5, #0x1F
	STR r5, [r4]
	B rowsDone
fourRow:
	; Insert one row of bricks into brickState
	MOV r5, #0xFFFF
	MOVT r5, #0xFFF
	STR r5, [r4]
rowsDone:

	; Clear the page
	MOV r0, #0xc
	BL output_character

	; Print the board and the bricks
	BL printBoard
	BL displayBricks

	; Reset the color and paddle positions
	BL resetColor
	MOV r2, #0
	BL movePaddle

<<<<<<< HEAD
	BL timer_interrupt_init
	; Your code is placed here.
 	; Sample test code starts here

resetLives:
	; Clear the page
=======
>>>>>>> b3ee4c046767e6d466dc2f9c28c282ed66661fe8
	; Reset lives to 4
	MOV r8, #4
	LDR r7, ptr_to_lives
	STRB r8, [r7]
<<<<<<< HEAD
	MOV r0, #0xc
	BL output_character

	; Print the board and the bricks
	BL printBoard
	BL displayBricks

	BL resetColor
	MOV r2, #0
	BL movePaddle
=======
>>>>>>> b3ee4c046767e6d466dc2f9c28c282ed66661fe8
	; Turn timer back on
	BL timerOn

mainloop:
	; Get lives and light up correct amount of LEDS
	LDR r5, ptr_to_lives
	LDRB r0, [r5]
	BL illuminate_LEDs
	CMP r0, #0
	BEQ gameOver 	; If no lives left, branch to game over
	B mainloop

gameOver:
	; Disable timer interruts
    BL disable_timer

	; Print Game over, score, and options
	MOV r0, #4
	MOV r1, #6
	BL setCursorxy
	LDR r0, ptr_to_gameOverStringOne
	BL output_string					; Print the first string

	LDR r0, ptr_to_score
	LDR r1, ptr_to_scorePlaceholder
	BL int2string
	LDR r0, ptr_to_scorePlaceholder
	BL output_string					; Print the score

	MOV r0, #4
	MOV r1, #7
	LDR r0, ptr_to_gameOverStringTwo
	BL output_string						; Print the second string

	BL read_character
	CMP r0, #0x63
	BEQ restartGame						; Branch if user wants to continue

	POP {lr}	  ; Restore lr from stack
	mov pc, lr


Timer_Handler:
    ; Save the registers
    PUSH {lr, r4-r11}

	; Clear the interrupt, using load -> or -> store to not overwrite other data

    MOV  r11, #0x0024
    MOVT r11, #0x4003			; Address for interrupt
    LDRB r4, [r11]          	; Load interrupt value
    ORR r4, r4, #1          	; Set bit 0 to 1
	STRB r4, [r11]				; Store back to clear interrupt

	; save cursor position
	BL escapeSequence
	MOV r0, #0x20 ; ' '
	BL output_character
	MOV r0, #0x37 ; 7
	BL output_character

	; Calculate the next position of the ball
	LDR r5, ptr_to_ballxPosition
	LDRB r5, [r5]
	LDR r6, ptr_to_ballyPosition
	LDRB r6, [r6]					; Load current x and y position into r5 and r6, DONT CHANGE THESE VALUES
	LDR r7, ptr_to_xDelta
	LDRSB r7, [r7]
	LDR r8, ptr_to_yDelta
<<<<<<< HEAD
	LDRSB r8, [r8]					; Load current x and y deltas into r7 and r8 (dont change these)
=======
	LDRSB r8, [r8]					; Load current x and y deltas into r7 and r8, DONT USE FOR ANYTHING OTHER THAN DELTAS
	CMP r8, #2

	IT EQ							; Could be source of error
	LSR r8, r8, #1
>>>>>>> b3ee4c046767e6d466dc2f9c28c282ed66661fe8

	ADD r9, r7, r5
	ADD r10, r8, r6					; Add x and y postions and deltas and store into r9 and r10
	; r5, r6 = current x and y | r7, r8 = x and y deltas | 

	; Initialize inputs to touch functions
	MOV r2, r9
	MOV r3, r10
	LDR r4, ptr_to_paddlePos
	LDRB r4, [r4]					; Pass potential x, y and paddle positions to touch functions

checkWall:
	; See if ball hits a wall
	; Call btouchSide, if r = 1, update deltas
	BL btouchSide
	CMP r1, #1
	BNE checkRoof					; If no touch, continue to next check

	MOV r9, #-1
	MULS r7, r7, r9					; Reverse x delta
	B checkDoubleBounce				; Jump to checkDoubleBounce for if it double bounces

checkRoof:
	; See if ball hits roof
	; Call btouchTop, if r = 1, update deltas
	PUSH {r2, r3, r4, r8}

	CMP r8, #2
	IT EQ
	LSREQ r8, r8, #1

	BL btouchTop
	POP {r2, r3, r4, r8}
	CMP r1, #1
	BNE checkBrick					; If no touch, continue to next check

	MOV r9, #-1
	MULS r8, r8, r9					; Reverse y delta

	B checkDoubleBounce				; Jump to checkDoubleBounce for if it double bounces

checkBrick:
	; See if ball hits brick
	; Call btouchBrick, if r1 = 1, update deltas
	; Set brick state for that brick to 0, erase the brick, update score
<<<<<<< HEAD
	PUSH {r8}
	CMP r8, #2
	IT EQ
	LSREQ r8, r8, #1
	POP {r8}
=======
	BL btouchBrick
	CMP r1, #1
	BNE checkBottom					; If no touch, jump to next check

	MOV r9, #-1
	MULS r8, r8, r9					; Reverse y delta
	; Set the hit brick's state to 0
	; Take ball  x and y positions
	; xpos * 3 gives line offset, next lowest y val
	; set to 0 to indicate done
	; print 3 spaces in that blocks position
	; increment score by level value
	B checkDoubleBounce				; Jump to checkDoubleBounce for if it double bounces
>>>>>>> b3ee4c046767e6d466dc2f9c28c282ed66661fe8

checkBottom:
	; See if ball hits bottom
	; Call btouchBot, if r1 = 1 then lose life, reset paddle and ball position, and x,y delta's
	PUSH {r8}
	CMP r8, #2
	IT EQ
	LSREQ r8, r8, #1

	BL btouchBot
	POP {r8}
	CMP r1, #1
	BNE checkPaddle					; If no touch, jump to next check

	LDR r7, ptr_to_lives
	LDRB r8, [r7]
	SUB r8, #1
	STRB r8, [r7]					; Load, subtract one, and store lives back to memory

	; Reset paddle and ball positions, and x,y deltas
	LDR r8, ptr_to_paddlePos
	MOV r7, #0x09
	STRB r7, [r8]					; Reset paddle position
	LDR r8, ptr_to_ballxPosition
	MOV r7, #0x0B
	STRB r7, [r8]					; Reset x position
	LDR r8, ptr_to_ballyPosition
	MOV r7, #0x08
	STRB r7, [r8]					; Reset y position
	LDR r8, ptr_to_xDelta
	MOV r7, #0x00
	STRB r7, [r8]					; Reset x delta
	LDR r8, ptr_to_yDelta
	MOV r7, #0x1
	STRB r7, [r8]					; Reset y delta

	; Clear the paddle row and reset its position
	MOV r0, #1
	MOV r1, #16
	BL setCursorxy
	BL wipe_row						; Set cursor position to the paddle row
	MOV r2, #0
	BL movePaddle					; Reset the paddle position

	B printBall						; Jump to printBall as no other events possible

checkPaddle:
	; See if ball hits paddle
	; Call btouchPaddle
	; return -1 if ball not on paddle, else the position on the paddle
	; which it is touching
	PUSH {r8}
	CMP r8, #-1
	IT LT
	LSRLT r8, r8, #1

	BL btouchPaddle
	POP {r8}
	CMP r1, #-1
	BEQ checkDoubleBounce

	BL updateBallDeltaForPaddleBounce
	B checkDoubleBounce

	; Branch here after a bounce has occurred
checkDoubleBounce:

	; Reload the current ball position and calculate new potential location
	LDR r4, ptr_to_ballxPosition
	LDRB r2, [r4]
	LDR r4, ptr_to_ballyPosition
	LDRB r3, [r4]					; Ball x and y into r2 and r3
	ADD r2, r7, r2
	ADD r3, r8, r3					; Calculate new positions by adding position and deltas

	; Run all bounce checks again to see if there are any double bounces:
	; Do the second checks here##########################

	; Now that bounce and double bounce are checked, save new deltas and positions to memory
	; Store the deltas to memory
	LDR r9, ptr_to_xDelta
	STRB r7, [r9]
	LDR r10, ptr_to_yDelta
	STRB r8, [r10]

	; Store the positions to memory
	MOV r7, r2
	MOV r8, r3
	LDR r9, ptr_to_ballxPosition
	STRB r7, [r9]
	LDR r10, ptr_to_ballyPosition
	STRB r8, [r10]					; Store new x and y positions to memory

printBall:
	; Print " " where ball currently is to erase it (this is where we need r5 and r6 unchanged)
	MOV r0, r5
	MOV r1, r6
	BL setCursorxy					; Move cursor to current ball position
	MOV r0, #0x20
	BL output_character				; Print a " " character

	; Print the ball in its new position
	LDR r5, ptr_to_ballxPosition
	LDRB r5, [r5]
	LDR r6, ptr_to_ballyPosition
	LDRB r6, [r6]					; Load current x and y position into r5 and r6 (don't change these registers, need them later)
	MOV r0, r5
	MOV r1, r6
	BL setCursorxy					; Move cursor to new position
	MOV r0, #0x6F
	BL output_character				; Print a "o" character
    ; Update position based on direction stored in current_direction and switch_speed

	; restore saved cursor position
	BL escapeSequence
	MOV r0, #0x20 ; ' '
	BL output_character
	MOV r0, #0x38 ; 8
	BL output_character

    ; Restore the registers
    POP {lr, r4-r11}
	BX lr       	; Return


wipe_row:
	PUSH {lr}
	MOV r0, #0x20
	BL output_character
	BL output_character
	BL output_character
	BL output_character
	BL output_character
	BL output_character
	BL output_character
	BL output_character
	BL output_character
	BL output_character
	BL output_character
	BL output_character
	BL output_character
	BL output_character
	BL output_character
	BL output_character
	BL output_character
	BL output_character
	BL output_character
	BL output_character
	BL output_character
	POP {pc}


UART0_Handler:
	; NEEDS TO MAINTAIN REGISTERS R4-R11, R0-R3;R12;LR;PC DONT NEED PRESERVATION
	; Save registers
	PUSH {lr, r4-r11}

	; Clear the interrupt, load -> or -> store
	MOV r11, #0xC044
	MOVT r11, #0x4000	; address load
	LDRB r4, [r11]		; data load
	ORR r4, r4, #8		; Or to set bit 4 to 1
	STRB r4, [r11]		; Store

	; Simple_read_character, store in r5 to return to lab5 later
	BL simple_read_character

	;   W
	; A S D

	;      0x77
	; 0x61 0x73 0x64
	LDR r2, ptr_to_paddlePos
	LDRB r1, [r2]
	CMP r0, #0x61 ; a
	BEQ apressed
	CMP r0, #0x64 ; d
	BEQ dpressed
apressed:
	ADD r1, r1, #-1
	B nonepressed
dpressed:
	ADD r1, r1, #1
nonepressed:

	; if r1 < 1 or r1 > 16
	CMP r1, #1
	BLT nopaddlemove
	CMP r1, #17
	BGT nopaddlemove

	STRB r1, [r2]
	BL movePaddle
nopaddlemove:

    ; Restore the registers
    POP {lr, r4-r11}
	BX lr       	; Return


Switch_Handler:
	; Save registers
    PUSH {lr, r4-r11}

    ; Clear the interrupt, using load -> or -> store to not overwrite other data
    MOV  r11, #0x541c
    MOVT r11, #0x4002			; Address for interrupt
    LDRB r4, [r11]          	; Load interrupt value
    ORR r4, r4, #0x10          	; Set bit 4 to 1
	STRB r4, [r11]				; Store back to clear interrupt

	; Load the pause state
	LDR r4, ptr_to_pauseState
	LDRB r5, [r4]
	CMP r5, #0					; Check if paused or unpaused
	BEQ pause

	; Change game state
	MOV r5, #0
	STRB r5, [r4]
	MOV r0, #7
	MOV r1, #9
	BL setCursorxy				; Set cursor to middle of the board
	LDR r0, ptr_to_gameUnpaused
	BL output_string			; Print unpause spaces
	BL timerOn					; Turn the timer back on
	B switchDone				; Exit handler

pause:
	; Turn off the timer
	BL disable_timer
	; Change game state
	MOV r5, #1
	STRB r5, [r4]
	; Set cursor to middle of the board
	MOV r0, #7
	MOV r1, #9
	BL setCursorxy
	; Print paused
	LDR r0, ptr_to_gamePaused
	BL output_string

switchDone:
	; Restore registers
    POP {lr, r4-r11}
	; Return to interrupted instruction
    BX lr


timerOn:
	PUSH {lr, r4-r11}
	; Enable timer interruts
    MOV r11, #0x000c
    MOVT r11, #0x4003   ; load address
    LDRW r4, [r11]      ; load value
    ORR r4, r4, #1      ; write 0 to bit 0
    STRW r4, [r11]      ; write back
    POP {lr, r4-r11}
	MOV pc, lr


simple_read_character:
    PUSH {lr, r11}          ; store regs

    MOV  r11, #0xc000
    MOVT r11, #0x4000          ; setting the address
    LDRB r0, [r11]             ; loading the data into r0

    POP {lr, r11}           ; restore saved regs
    MOV pc, lr                 ; return to source call


escapeSequence:
	PUSH {lr}
	MOV r0, #27
	BL output_character
	MOV r0, #0x5B
	BL output_character
	POP {pc}


; Sets the x,y position of the cursor, input r0=x, r1=y
setCursorxy:
	PUSH{lr, r4-r11}

	ADD r1, r1, #1

	ldr r4, ptr_to_xescapeStringBuffer
	PUSH {r0, r1}
	MOV r1, r4
	BL int2string
	POP {r0, r1}
	ldr r5, ptr_to_yescapeStringBuffer
	PUSH {r0, r1}
	MOV r0, r1
	MOV r1, r5
	BL int2string

	BL escapeSequence
	MOV r0, #0x48
	BL output_character

	POP {r0}
	CMP r0, #0
	BEQ noxshift

	BL escapeSequence
	MOV r0, r4
	BL output_string
	MOV r0, #0x43 ; column shift for x
	BL output_character

noxshift:

	POP {r1}
	CMP r1, #0
	BEQ noyshift

	BL escapeSequence
	MOV r0, r5
	BL output_string
	MOV r0, #0x42 ; row shift for y
	BL output_character
noyshift:

	POP {lr, r4-r11}
	mov pc, lr


; Prints the boundries of the board
printBoard:
	; Screen size is 23x19, board edges are 23x18, inner board is 21x16
	PUSH{lr, r4-r11}

	; Print the score string and score value
	MOV r0, #6
	MOV r1, #-1
	BL setCursorxy				; Set cursor to correct position
	LDR r0, ptr_to_scoreString
	BL output_string			; Print "Score: "
	LDR r0, ptr_to_score
	LDRW r0, [r0]				; Load score
	LDR r1, ptr_to_scorePlaceholder
	BL int2string				; Convert score to string
	LDR r0, ptr_to_scorePlaceholder
	BL output_string			; Output the score

	; Print the upper boarder
	MOV r0, #0
	MOV r1, #0
	BL setCursorxy				; Set cursor to beginning of second line
	LDR r0, ptr_to_topBottomBorder
	BL output_string			; Print the border

	; Print the side walls
	MOV r4, #1					; Variable to track row number
	MOV r5, #0x7C				; Vertical line
printWalls:
	MOV r0, #0
	MOV r1, r4
	BL setCursorxy				; Set the cursor position, (0, row)
	MOV r0, r5
	BL output_character			; Set character to print to be "|", then output it
	MOV r0, #22
	MOV r1, r4
	BL setCursorxy				; Set the cursor position, (22, row)
	MOV r0, r5
	BL output_character			; Set character to print to be "|", then output it
	ADD r4, r4, #1				; Increment row
	CMP r4, #17
	BEQ printBottom
	B printWalls				; If 16 rows printed, jump to next section, otherwise keep making the walls

printBottom:
	; Print the lower boarder
	MOV r0, #0
	MOV r1, #17
	BL setCursorxy				; Set cursor to beginning of second line
	LDR r0, ptr_to_topBottomBorder
	BL output_string			; Print the border

	POP {lr, r4-r11}
	mov pc, lr


; r2 = -1, or 1
movePaddle:
	PUSH {lr, r4}

	MOV r1, #16
	MOV r4, #6
	LDR r0, ptr_to_paddlePos
	LDRB r0, [r0]
	PUSH {r0}
	SUB r0, r0, #1
	BL setCursorxy
	POP {r0}
	MOV r3, r0
	CMP r3, #1
	ITE EQ
	MOVEQ r0, #0x7c
	MOVNE r0, #0x20
	BL output_character
	ADD r0, r3, r2
	BL printPaddle
	CMP r3, #17
	ITE EQ
	MOVEQ r0, #0x7c
	MOVNE r0, #0x20
	BL output_character
	POP {pc, r4}


printPaddle:
	PUSH {lr}
	MOV r0, #0x3d
	BL output_character
	MOV r0, #0x3d
	BL output_character
	MOV r0, #0x3d
	BL output_character
	MOV r0, #0x3d
	BL output_character
	MOV r0, #0x3d
	BL output_character
	POP {pc}


printBrick:
	PUSH {lr}
	BL setBackground
	MOV r0, #0x20
	BL output_character
	MOV r0, #0x20
	BL output_character
	MOV r0, #0x20
	BL output_character
	POP {pc}


; Prints the set amount of blocks in random colors
displayBricks:
	PUSH {lr, r4-r11}
	MOV r0, #1
	MOV r1, #2
	BL setCursorxy

	; Get the brick state
	ldr r0, ptr_to_brickState
	LDRW r4, [r0]				; Loads brickState into r4

	MOV r7, #7
	MOV r8, #3
	MOV r5, #-1				; Set bit position to be 0


displayBrickLoop:
	; Check bit value
	ADD r5, r5, #1
	LSR r6, r4, r5
	AND r6, r6, #1

	CMP r5, #28
	BEQ exitDisplayBrickLoop
	CMP r6, #1
	BNE displayBrickLoop

	SDIV r1, r5, r7
	MUL r9, r1, r7
	SUB r0, r5, r9
	MUL r0, r0, r8
	ADD r1, r1, #2
	ADD r0, r0, #1
	BL setCursorxy
	MOV r0, #1 ; set color to red
	BL printBrick
	B displayBrickLoop

exitDisplayBrickLoop:

	POP {pc, r4-r11}

	; If 1, generate random color value

	; Display brick

	; Jump back to loop


; needs to be called before any usage of the btouch methods
setupForBounceChecks:
	PUSH {lr}

	ldr r2, ptr_to_ballxPosition
	ldr r3, ptr_to_ballyPosition
	ldr r4, ptr_to_paddlePos

	POP {pc}


; return true/false if ball is on a brick
; x and y values in r2, r3, value returned in r1
btouchBrick:
	; Potential implementation:
	; Get the y delta, if 2 then add one to y position
	; Take x and y values, check which 'brick sector' they are in
	; Load the brickState, check the bit value for that 'brick sector'
	; If that bit value is 1, return 1 and exit
	; If that bit value is 0, subtract one from y position
	; Recalculate the 'brick sector'
	; Check bit value for that 'brick sector'
	; Return that value regardless of if its 1 or 0
	PUSH {lr, r5, r6}
	; return false if y is greater than 6 or equal to 1
	CMP r3, #1 ; y == 1
	BEQ btouchBrickfalse ; return false
	CMP r3, #6 ; y > 6
	BGT btouchBrickfalse ; return false
	; shift brickState by x*7 places
	ldr r1, ptr_to_brickState
	ldrw r1, [r1]
	MOV r5, #3
	DIV r6, r2, r5
	MOV r5, #7
	MUL r5, r6, r5 ; r5 = x*7
	LSR r1, r1, r5 ; brickstate >>= r5
	AND r1, r1, #1 ; brickstate & 1

	POP  {pc, r5, r6}

btouchBrickfalse:

	MOV r1, #0
	POP  {pc, r5, r6}


; return true/false if ball is on a side
; x and y values in r2, r3, value returned in r1
btouchSide:
	PUSH {lr}
	; return true if x is 0 or greater than 21
	CMP r2, #0
	BEQ btouchSidetrue
	CMP r2, #21
	BGT btouchSidetrue

	MOV r1, #0 	  ; false
	POP  {pc}	  ; Restore lr from stack

btouchSidetrue:
	MOV r1, #1
	POP  {pc}	  ; Restore lr from stack


; return true/false if ball is on the top
; x and y values in r2, r3, value returned in r1
btouchTop:
	PUSH {lr}
	CMP r3, #0
	ITE LE
	MOVLE r1, #1
	MOVGT r1, #0
	POP  {pc}


; return true/false if ball is on the bottom
; x and y values in r2, r3, value returned in r1
btouchBot:
	PUSH {lr}
	CMP r3, #17
	ITE GE
	MOVGE r1, #1
	MOVLT r1, #0
	POP  {pc}


; return -1 if ball not on paddle, else the position on the paddle
; which it is touching
; x and y values and paddlepos in r2, r3, r4 value returned in r1
btouchPaddle:
	PUSH {lr}
	; return true if y position = 16 and x < paddlepos or x > paddlepos+4
	CMP r3, #16 ; y != 16
	BNE btouchPaddlefalse ; return false

	CMP r2, r4 ; x < paddlepos
	BLT btouchPaddlefalse ; return false

	ADD r4, r4, #4
	CMP r2, r4 ; x > paddlepos + 4
	BGT btouchPaddlefalse ; return false

	SUB r1, r4, r2
	POP  {pc} ; return true


btouchPaddlefalse:
	MOV r1, #-1
	POP  {pc}


; needs btouch setup to be called before
; Alternatively, btouchPaddle can return 0 for no touch, 1 for left side, 2 for middle, 3 for right side
; and based on that value, (xD, yD) = (-1, 1), (0, 1), (1, 1) respectively
updateBallDeltaForPaddleBounce:
	PUSH {lr}
	BL btouchPaddle
	CMP r1, #-1
	BEQ exitUpdateBallDelta

	CMP r1, #2
	ITTT EQ
	MOVEQ r7, #0
	MOVEQ r8, #-1
	BEQ exitUpdateBallDelta

	CMP r7, #0
	ITE LT
	MOVLT r7, #-1
	MOVGE r7, #1

	CMP r1, #3
	IT EQ
	MOVEQ r1, #1
	CMP r1, #4
	IT EQ
	MOVEQ r1, #0

	CMP r1, #1
	ITT EQ
	MOVEQ r8, #0xfe
	BEQ exitUpdateBallDelta

	CMP r1, #0
	ITT EQ
	MOVEQ r8, #-1
	BEQ exitUpdateBallDelta

exitUpdateBallDelta:
	PUSH {r6}
	ldr r6, ptr_to_xDelta
	strb r7, [r6]
	ldr r6, ptr_to_yDelta
	strb r8, [r6]
	POP {r6}

exitBallDeltaCheck:
	POP {pc}


; set putty terminal color
; 1...5 = red, green, yellow, blue, purple
; 7 = white
setColor:
	PUSH {lr, r4-r11}

	PUSH {r0}
	ldr r0, ptr_to_beginColorEscape
	BL output_string
	POP {r0}
	ADD r0, r0, #0x30
	BL output_character
	PUSH {r0}
	ldr r0, ptr_to_endColorEscape
	BL output_string
	POP {r0}
	SUB r0, r0, #0x30

	POP  {lr, r4-r11}	  ; Restore lr from stack
	mov pc, lr

setBackground:
	PUSH {lr, r4-r11}

	PUSH {r0}
	ldr r0, ptr_to_beginBackgroundEscape
	BL output_string
	POP {r0}
	ADD r0, r0, #0x30
	BL output_character
	PUSH {r0}
	ldr r0, ptr_to_endColorEscape
	BL output_string
	POP {r0}
	SUB r0, r0, #0x30

	POP  {lr, r4-r11}	  ; Restore lr from stack
	mov pc, lr


; reset terminal color
resetColor:

	PUSH {lr}

	ldr r0, ptr_to_resetColorString
	BL output_string

	POP {pc}


; clears the board and resets all the bricks, the ball, and the paddle
levelClear:
	PUSH {lr, r4-r11}
	POP  {lr, r4-r11}	  ; Restore lr from stack
	mov pc, lr

	; Print the side walls

	; Print the lower boarder
	.end
