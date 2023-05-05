
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
	.global illuminate_RGB_LED
	.global read_character
	.global read_from_push_btns

	.global uart_interrupt_init
    .global gpio_interrupt_init
    .global timer_interrupt_init
	.global gpio_btn_and_LED_init
    .global disable_timer

colorString:		.string "0000000000000000000000000000", 0
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
brickState:  		.word 0x7f
brickRows:			.byte 0x0
xDelta:  			.byte 0
yDelta: 			.byte 1
score: 				.word 0x0
ballxPosition:  	.byte 0x0B
ballyPosition:  	.byte 0x09
paddlePos: 			.byte 0x09
ballColor:  		.byte 0x07
lives:  			.byte 0x04
level:  			.byte 0x01
bounces:  			.byte 0x00
pauseState:  		.byte 0x00
scoreString:		.string "Score: ", 0
topBottomBorder:	.string "+---------------------+", 0

; Pointers to memory locations

ptr_to_bounces:  				.word bounces
ptr_to_colorString:				.word colorString
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
ptr_to_brickRows:				.word brickRows
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

lab7:
	PUSH {lr}   ; Store lr to stack

	; Initialization functions
	BL uart_init
	BL uart_interrupt_init
	BL gpio_btn_and_LED_init
	BL gpio_interrupt_init
	BL resetColor
	;BL timer_interrupt_init
	;BL disable_timer

restartGame:
	; Clear the page
	MOV r0, #0xc
	BL output_character

	; Turn off RGB LED for when the game starts
	MOV r0, #0
	BL illuminate_RGB_LED

	; Print the game start instructions
	MOV r0, #0
	MOV r1, #0
	BL setCursorxy
	LDR r0, ptr_to_gameStartOne
	BL output_string				; Print first instruction
	MOV r0, #0
	MOV r1, #1
	BL setCursorxy					; Move cursor to next row
	LDR r0, ptr_to_gameStartTwo
	BL output_string				; Print second instruction
	MOV r0, #0
	MOV r1, #2
	BL setCursorxy					; Move cursor to next row
	LDR r0, ptr_to_gameStartThree
	BL output_string				; Print third instruction

	; Wait for keypress and then read buttons pressed
	BL read_character
	BL read_from_push_btns
	LDR r5, ptr_to_brickRows
	STRB r0, [r5]
	; r0 contains number of buttons pressed now, so put ones in needed spaces now
	LDR r4, ptr_to_brickState
	CMP r0, #2
	BLT oneRow
	BEQ twoRow
	CMP r0, #3
	BEQ threeRow
	BGT fourRow

nextLevel:
	LDR r4, ptr_to_brickState
	ldr r5, ptr_to_brickRows
	ldrb r0, [r5]
	; This also serves as the catch in case no buttons are pressed
oneRow:
	; Insert one row of bricks into brickState
	MOV r5, #0x7F
	STR r5, [r4]
	B resetLives
twoRow:
	; Insert two rows of bricks into brickState
	MOV r5, #0x3FFF
	STR r5, [r4]
	B resetLives
threeRow:
	; Insert three rows of bricks into brickState
	MOV r5, #0xFFFF
	MOVT r5, #0x1F
	STR r5, [r4]
	B resetLives
fourRow:
	; Insert one row of bricks into brickState
	MOV r5, #0xFFFF
	MOVT r5, #0xFFF
	STR r5, [r4]

resetLives:
	; Reset lives to 4
	MOV r8, #4
	LDR r7, ptr_to_lives
	STRB r8, [r7]

	; Clear the page
	MOV r0, #0xc
	BL output_character

	; Reset the color and paddle positions
	ldr r2, ptr_to_ballxPosition
	MOV r3, #0xb
	strb r3, [r2]
	ldr r2, ptr_to_ballyPosition
	MOV r3, #0x9
	strb r3, [r2]
	ldr r2, ptr_to_xDelta
	MOV r3, #0x0
	strb r3, [r2]
	ldr r2, ptr_to_yDelta
	MOV r3, #0x1
	strb r3, [r2]


	BL resetColor
	MOV r2, #0
	BL movePaddle

	; Turn timer back on
	BL timer_interrupt_init
	; Print the board and the bricks
	BL printBoard
	BL displayBricks
	BL displayBricks ; we are using arbitrary uart communication to add
	BL displayBricks ; some unpredictable randomness
	BL generateRandomColors
	BL displayBricks

mainloop:
	; Get lives and light up correct amount of LEDS
	LDR r5, ptr_to_lives
	LDRB r0, [r5]

	; illuminate LEDs uses these regs not protected by 
	; APCS so we need to store them
	PUSH {r0, r1}
	BL illuminate_LEDs
	POP {r0, r1}

	CMP r0, #0
	BEQ gameOver 	; If no lives left, branch to game over

	; Check brickState and see if level complete
	ldr r5, ptr_to_brickState
	ldrb r5, [r5]
	CMP r5, #0
	BEQ levelComplete

	; Branch back to main loop
	B mainloop

levelComplete:
	; If level complete, increase level number, increase speed (if needed)
	LDR r5, ptr_to_level
	LDRB r6, [r5]
	ADD r6, r6, #0x1
	STRB r6, [r5]						; Load, increment, and store level

	; Check if refresh rate needs to be changed
	CMP r6, #4
	BGT afterRefresh 					; If past level 4 don't increment refresh rate anymore

	; Level:refreshRate => 1:0.2, 2:0.18, 3:0.16, 4:0.14
	; Calculate new period, then multiply tick rate by that and save
	SUB r6, r6, #1						; Subtract one from level
	LSL r6, r6, #1					; Multiply 0.02 by level
	MOV r7, #20
	SUB r6, r7, r6						; Subtract that from 0.2 to get refresh period
	MOV r7, #0x2400
	MOVT r7, #0x00F4					; Move 16,000,000 into r7
	MUL r6, r6, r7						; Multiply the refresh rate
	MOV r7, #100
	SDIV r6, r6, r7
	
	MOV r8, #0x0028
	MOVT r8, #0x4003					; Load frequency address
	STRW r6, [r8]						; Store the new refresh rate

afterRefresh:
	; Branch to next level (reprint the screen and the rows)
	B nextLevel

gameOver:
	; Disable timer interruts
    BL disable_timer

	; Print Game over, score, and options
	MOV r0, #4
	MOV r1, #6
	BL setCursorxy
	LDR r0, ptr_to_gameOverStringOne
	BL output_string					; Print the first string

	; Load the score into a string and print it to the screen
	LDR r0, ptr_to_score
	ldrb r0, [r0]
	LDR r1, ptr_to_scorePlaceholder
	BL int2string						; Convert score to string
	LDR r0, ptr_to_scorePlaceholder
	BL output_string					; Print the score

	; Print the last string for game end
	MOV r0, #4
	MOV r1, #7
	BL setCursorxy
	LDR r0, ptr_to_gameOverStringTwo
	BL output_string					; Print the second string

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


	MOV r7, #0
	LDR r8, ptr_to_bounces
	STRB r7, [r8]

	; Calculate the next position of the ball
	LDR r5, ptr_to_ballxPosition
	LDRB r5, [r5]
	LDR r6, ptr_to_ballyPosition
	LDRB r6, [r6]					; Load current x and y position into r5 and r6, DONT CHANGE THESE VALUES
	LDR r7, ptr_to_xDelta
	LDRSB r7, [r7]
	LDR r8, ptr_to_yDelta
	LDRSB r8, [r8]					; Load current x and y deltas into r7 and r8, DONT USE FOR ANYTHING OTHER THAN DELTAS

	ADD r9, r7, r5
	ADD r10, r8, r6					; Add x and y postions and deltas and store into r9 and r10
	; r5, r6 = current x and y | r7, r8 = x and y deltas | 

	; Initialize inputs to touch functions
	MOV r2, r9
	MOV r3, r10
	LDR r4, ptr_to_paddlePos
	LDRB r4, [r4]					; Pass potential x, y and paddle positions to touch functions

checkPaddle:
	; See if ball hits paddle
	; Call btouchPaddle
	; return -1 if ball not on paddle, else the position on the paddle
	; which it is touching

	; if yDelta is 2, we need to check 2, and 1.
	PUSH {r8, r3}
	CMP r8, #2
	ITT GE
	ASRGE r8, r8, #1 ; dividing r8 by 2
	ADDGE r3, r8, r6 ; readjusting r3 to match the adjusted delta
	BL btouchPaddle
	POP {r8, r3} ; restoring the unadjusted values after compare.

	; btouchpaddle returns -1 if not touching
	; this is using the comparison with the adjusted ydelta
	CMP r1, #-1
	IT NE
	BNE touchingPaddle

	; check for contact again, this time with
	; the unadjusted ydelta
	BL btouchPaddle
	CMP r1, #-1
	IT NE
	BNE touchingPaddle

	; we check one square below the ball for good measure.
	; this catches some extra edge cases like when the ball
	; contacts with the paddle and wall at the same time in the
	; corner.
	PUSH {r3, r6}
	ADD r3, r6, #1
	BL btouchPaddle
	POP {r3, r6}

	CMP r1, #-1
	ITE EQ
	BEQ checkWall
	BNE touchingPaddle

touchingPaddle:

	; if we touched the paddle in any of the above cases, 
	; update the deltas accordingly
	BL updateBallDeltaForPaddleBounce
	B checkDoubleBounce

checkWall:
	; See if ball hits a wall
	; Call btouchSide, if r = 1, updatae deltas
	BL btouchSide
	CMP r1, #1
	BNE checkRoof					; If no touch, continue to next check

	MOV r9, #-1
	MULS r7, r7, r9					; Reverse x delta
	B checkDoubleBounce				; Jump to checkDoubleBounce for if it double bounces

checkRoof:
	; See if ball hits roof
	; Call btouchTop, if r = 1, update deltas
	BL btouchTop
	CMP r1, #1
	BNE checkBrick					; If no touch, continue to next check

	MOV r9, #-1						; If touch:
	MULS r8, r8, r9					; Reverse y delta

	B checkDoubleBounce				; Jump to checkDoubleBounce for if it double bounces

checkBrick:
	; See if ball hits brick
	; Call btouchBrick, if r1 = 1, update deltas
	; Set brick state for that brick to 0, erase the brick, update score

	; btouchbrick returns 1 if brick contact has been made,
	; else 0.
	BL btouchBrick
	CMP r1, #1
	IT EQ
	BEQ touchingBrick

	; Checks for the if the ball's delta is 2.
	; We aren't checking if the balls' delta is -2, because
	; we initially thought it was impossible for a ball to contact with
	; -2 ydelta until the last day.
	PUSH {r8, r3}
	CMP r8, #2
	ITT EQ
	LSREQ r8, r8, #1
	ADDEQ r3, r8, r6

	; all of these need to be LTs :(
	CMP r8, #-1
	ITT EQ
	ASREQ r8, r8, #1
	ADDEQ r3, r8, r6

	BL btouchBrick
	POP {r8, r3} ; restoring the unadjusted values after compare.

	CMP r1, #1
	ITE EQ
	BEQ touchingBrick
	BNE checkBottom					; If no touch, jump to next check

touchingBrick:

	; If touch happens, reverse y direction and increment score
	MOV r9, #-1
	MULS r8, r8, r9					; Reverse y delta
	; increment score by level value
	LDR r11, ptr_to_level
	LDRB r11, [r11]					; Load the level
	LDR r10, ptr_to_score
	LDRB r9, [r10]					; Load the current score
	ADD r9, r9, r11					; Add level to the score
	STRB r9, [r10]					; Store the score

	; Print the new score at the top of the screen
	PUSH {r0, r1}					; Push these values so they arent overwritten
	MOV r0, #13
	MOV r1, #-1
	BL setCursorxy					; Position the cursor
	;LDR r10, ptr_to_scoreString
	;BL output_string				; Print "Score: "
	; Print the score value
	MOV r0, r9						; Move the score into r0
	LDR r1, ptr_to_scorePlaceholder	
	BL int2string						; Convert score to string
	LDR r0, ptr_to_scorePlaceholder
	BL output_string					; Print the score
	POP {r0, r1}					; Restore the values

	B checkDoubleBounce				; Jump to checkDoubleBounce for if it double bounces

checkBottom:
	; See if ball hits bottom
	; Call btouchBot, if r1 = 1 then lose life, reset paddle and ball position, and x,y delta's
	BL btouchBot
	CMP r1, #1
	BNE checkDoubleBounce					; If no touch, jump to next check

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

	; Branch here after a bounce has occurred
checkDoubleBounce:

	; Reload the current ball position and calculate new potential location
	LDR r4, ptr_to_ballxPosition
	LDRB r2, [r4]
	LDR r4, ptr_to_ballyPosition
	LDRB r3, [r4]					; Ball x and y into r2 and r3
	ADD r2, r7, r2
	ADD r3, r8, r3					; Calculate new positions by adding position and deltas

 	; just pushing to quickly mark whether we've
	; already bounced or not ( or how many times )
	; Not sure what registers are safe to use at this point, etc.
	PUSH {r7, r8}
	LDR r8, ptr_to_bounces
	LDRB r7, [r8]
	CMP r7, #2
	ADD r7, r7, #1
	STRB r7, [r8]
	POP {r7, r8} ; restoring from memory increment

	; If we haven't already, run the checks again.
	IT LT
	BLT checkPaddle ; going back to the top of all the checks

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
	BL resetColor

	; set color uses r0 so we need to store it.
	PUSH {r0}
	ldr r0, ptr_to_ballColor
	ldr r0, [r0]
	BL setColor
	POP {r0} ; restoring from setColor

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
	BL resetColor
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


; this is only called when the ball falls through the bottom
; and the game needs to be reset, so we don't have to clear the ball
; at the bottom and/or the paddle by-position.
wipe_row:
	PUSH {lr}
	; loop unrolling :D
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
	BL output_character ; prints a space per column on the board.
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

	;        W
	;   A    S    D

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
	; not allowing the paddle to move if it would go past
	; the edge of the board
	CMP r1, #1
	BLT nopaddlemove
	CMP r1, #17
	BGT nopaddlemove

	; storing paddle position
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
; r2 is indicating the direction of movement
movePaddle:
	PUSH {lr, r4}

	MOV r1, #16 ; these appear to not be used
	MOV r4, #6  ; these appear to not be used
	; but I'm not removing without being able to test.

	LDR r0, ptr_to_paddlePos
	LDRB r0, [r0]

	PUSH {r0} ; setCursoryxy needs to be adjusted by 1 x position
	SUB r0, r0, #1
	BL setCursorxy
	BL resetColor
	POP {r0}
	; we have to make sure we clear or print the necessary
	; characters at the left and right sides of the paddle.
	; ie: if it's on an edge, we need to print an edge character instead
	; of a space, for safety.

 	; output_character uses r0 so we have to do a slight
	; register spill for the following
	MOV r3, r0

	; printing the left edge of the paddle
	CMP r3, #1 ; left edge of the board
	ITE EQ
	MOVEQ r0, #0x7c ; the "|" edge character
	MOVNE r0, #0x20 ; space
	BL output_character
	ADD r0, r3, r2
	BL printPaddle ; just print 5 gray "="s

	; printing the right edge of the paddle
	CMP r3, #17 ; right edge of the board
	ITE EQ
	MOVEQ r0, #0x7c ; the "|" edge character
	MOVNE r0, #0x20 ; space
	BL output_character

	; exiting movepaddle
	POP {pc, r4}


; pretty self explanatory
; printing 5 gray "="s
; I guess we didn't need to MOV r0, #0x3d each time but oh well.
printPaddle:
	PUSH {lr}
	MOV r0, #0 ; 0 is gray
	BL setColor
	MOV r0, #0x3d ; "="
	BL output_character
	MOV r0, #0x3d
	BL output_character
	MOV r0, #0x3d
	BL output_character
	MOV r0, #0x3d
	BL output_character
	MOV r0, #0x3d
	BL output_character
	BL resetColor
	POP {pc}

; just print 3 spaces in the desired color.
; r0 needs to already be set to the needed color
; outside of this, in preparation for set_background
; I guess we didn't need to MOV r0, #0x3d each time but oh well.
printBrick:
	PUSH {lr}
	BL setBackground
	MOV r0, #0x20 ; " "
	BL output_character
	MOV r0, #0x20
	BL output_character
	MOV r0, #0x20
	BL output_character
	POP {pc}


; Prints the set amount of blocks in random colors
displayBricks:
	PUSH {lr, r4-r11}
	; setting the cursor to the upperleftmost brick
	MOV r0, #1
	MOV r1, #2
	BL setCursorxy

	; Get the brick state
	; Brick state contains the state of each brick (on/off),
	; as 32 bits.  (in reality only 28 are used)
	; this makes looping over it easy since we can just shift it.
	ldr r0, ptr_to_brickState
	LDRW r4, [r0]				; Loads brickState into r4

	ldr r10, ptr_to_colorString ; each byte is a color number

	MOV r7, #7
	MOV r8, #3 ; constants for multiplying in-loop
	MOV r5, #-1
	; we're adding 1 immediately so this is effectively
	; starting at 0

displayBrickLoop:

	; Check bit value
	ADD r5, r5, #1 ; adding one to our iterator "i"
	ADD r10, r10, #1 ; incrementing our colorString pointer
	LSR r6, r4, r5 ; incrementing/shifting the brickState value
	AND r6, r6, #1 ; getting the first bit of the brickState.

	CMP r5, #28 ; If i == 28, we're done.
	BEQ exitDisplayBrickLoop

	; we need to do i mod 7, because there are 7 bricks per row.
	; This gives us the x value of the brick we're currently
	; looking at.
	SDIV r1, r5, r7
	MUL r9, r1, r7
	SUB r0, r5, r9
	; store the result in r0

	; we need to multiply the calculated x value by 3, because
	; each brick takes up 3 spaces.
	MUL r0, r0, r8

	; we need to shift the cursor a bit because the bricks don't
	; start at 0, 0
	ADD r1, r1, #2
	ADD r0, r0, #1
	BL setCursorxy

	ldrb r0, [r10]
	CMP r6, #1
	BNE clearBrick
	BL printBrick
	B displayBrickLoop

exitDisplayBrickLoop:

	POP {pc, r4-r11}

	; If 1, generate random color value

	; Display brick

	; Jump back to loop

clearBrick:
	BL resetColor
	MOV r0, #0x20
	BL output_character
	BL output_character
	BL output_character

	B displayBrickLoop


; needs to be called before any usage of the btouch methods
; not actually used.
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
	PUSH {lr, r2-r11}
	; return false if y is greater than 6 or equal to 1
	CMP r3, #1 ; y == 1
	BEQ btouchBrickfalse ; return false
	CMP r3, #6 ; y > 6
	BGT btouchBrickfalse ; return false
	SUB r2, r2, #1
	; shift brickState by x*7 places
	ldr r4, ptr_to_brickState
	ldrw r1, [r4]
	MOV r5, #3
	SDIV r6, r2, r5 ; r6 = x/3
	MOV r5, #7
	SUB r3, r3, #2
	; basically just the mathematical inverse of the calculations in 
	; displayBricks.  Instead of converting an index to 2d coords,
	; we're converting 2d coords to an index
	MUL r5, r3, r5
	ADD r6, r6, r5
	; r6 = x/3+(y-2)*7
	; shifting the brickState by said index
	LSR r1, r1, r6 ; brickstate >>= r6

	AND r1, r1, #1 ; brickstate & 1

	; If we didn't touch a brick, return 0 in r0
	CMP r1, #1
	BNE btouchBrickfalse

	; The next few chunks are to handle the actual touching of a brick.
	; Best practice would have this be put in another subroutine.

	; we're loading a copy of the brick state and shifting a 
	; 1 to the right position to select that bit, so we can clear it.
	ldr r8, [r4]
	MOV r7, #1
	LSL r7, r7, r6 ; shifting by the calculated index
	MVN r7, r7     ; inverting
	AND r7, r7, r8 ; clearing
	strw r7, [r4]  ; storing the changes
	; BFC doesn't accept a reg as the index only immediates, so we
	; could not use that for the above.

	; copying the brick color into the ball color
	ldr r4, ptr_to_colorString
	ADD r4, r4, r6
	ldrb r5, [r4, #1]
	ldr r4, ptr_to_ballColor
	strb r5, [r4]

	; Set the rgb LED colora
	; 1...5 = red, green, yellow, blue, purple
	PUSH {r0}			; Push r0 so we can use in illuminate_RGB_LED
	CMP r5, #1
	IT EQ
	MOVEQ r0, #1			; Set red

	CMP r5, #2
	IT EQ
	MOVEQ r0, #4			; Set green

	CMP r5, #3
	IT EQ
	MOVEQ r0, #5			; Set yellow

	CMP r5, #4
	IT EQ
	MOVEQ r0, #2			; Set blue

	CMP r5, #5
	IT EQ
	MOVEQ r0, #3			; Set purple

	BL illuminate_RGB_LED		; Branch to illuminate_RGB_LED
	POP {r0}

	; re-displaying all the bricks to apply the changes.
	PUSH {r1}
	BL displayBricks
	POP {r1}

	POP  {pc, r2-r11}

btouchBrickfalse:

	; returning 0
	MOV r1, #0
	POP  {pc, r2-r11}


; return true/false if ball is on a side
; x and y values in r2, r3, value returned in r1
btouchSide:
	PUSH {lr}
	; return true if x is 0 or greater than 21
	CMP r2, #0
	BLE btouchSidetrue
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
	BLT btouchPaddlefalse ; return false

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
	;BL btouchPaddle
	CMP r1, #-1
	BEQ exitUpdateBallDelta

	CMP r1, #2 ; what side of paddle are we on
	ITE LT
	MOVLT r7, #1
	MOVGE r7, #-1

	MOV r8, #-1

	CMP r1, #1 ; hitting the second segment
	ITT EQ
	MOVEQ r8, #0
	SUBEQ r8, r8, #2

	CMP r1, #3 ; hitting the fourth segment
	ITT EQ
	MOVEQ r8, #0
	SUBEQ r8, r8, #2

	CMP r1, #2 ; hitting the third segment
	IT EQ
	MOVEQ r7, #0

exitUpdateBallDelta:
	PUSH {r6}
	ldr r6, ptr_to_xDelta
	strb r7, [r6]
	ldr r6, ptr_to_yDelta
	strb r8, [r6]
	POP {r6}

exitBallDeltaCheck:
	MOV pc, lr


; set putty terminal color
; 1...5 = red, green, yellow, blue, purple
; 7 = white
setColor:
	PUSH {lr, r4-r11}

	; output string is using r0 so we need to store it
	PUSH {r0}
	ldr r0, ptr_to_beginColorEscape
	BL output_string
	POP {r0}
	ADD r0, r0, #0x30 ; converting from byte to number character
	BL output_character

	PUSH {r0}
	ldr r0, ptr_to_endColorEscape
	BL output_string
	POP {r0}

 	; reversing the change we made to r0 earlier to preserve
	SUB r0, r0, #0x30

	POP  {lr, r4-r11}	  ; Restore lr from stack
	mov pc, lr

setBackground:
	PUSH {lr, r4-r11}

	; output string is using r0 so we need to store it
	PUSH {r0}
	ldr r0, ptr_to_beginBackgroundEscape
	BL output_string
	POP {r0}
	ADD r0, r0, #0x30 ; converting from byte to number character
	BL output_character

	PUSH {r0}
	ldr r0, ptr_to_endColorEscape
	BL output_string
	POP {r0}

	; reversing the change we made to r0 earlier to preserve
	SUB r0, r0, #0x30

	POP  {lr, r4-r11}	  ; Restore lr from stack
	mov pc, lr


; reset terminal color
resetColor:

	PUSH {lr}

	ldr r0, ptr_to_resetColorString
	BL output_string

	POP {pc}


; Generates random colors for the bricks
generateRandomColors:
	PUSH {lr, r4-r11}
	; Load the colors string
	LDR r4, ptr_to_colorString

	; Create a variable to loop over 28 times
	MOV r5, #0
	MOV r6, #0x0050
	MOVT r6, #0x4003		; Load the SYSTICK address into r6
	; Mask to remove bits 24-31
	MOV r8, #0xFFFF
	MOVT r8, #0xFF
colorGenLoop:
	; Read the value of the SYSTICK into r7
	LDR r7, [r6]
	; AND the value and mask to get just the SYSTICK value
	AND r7, r7, r8
	MOV r1, #5
	; Take the modulo of that value with 5, result in r2
	SDIV r2, r7, r1
	MUL r2, r2, r1
	SUB r2, r7, r2
	ADD r2, r2, #0x1 ; Add 0x3 to convert to ascii number, and 0x1 to match indexing for our colors
	; Now store this value to memory and increment the write position
	STRB r2, [r4]
	ADD r4, r4, #1			; Increments the write position by one byte
	; Increment the counter and check if done looping
	ADD r5, r5, #1
	CMP r5, #28
	BLT colorGenLoop

	POP {lr, r4-r11}
	MOV pc, lr
	.end
