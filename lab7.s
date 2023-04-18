	.text

	.global lab7

	.global uart_init
	.global output_character
	.global output_string
    .global int2string
	
	.global uart_interrupt_init
    .global gpio_interrupt_init
    .global timer_interrupt_init

xescapeStringBuffer: .string 0,0,0
yescapeStringBuffer: .string 0,0,0
beginBackgroundEscape: .string 27, "[4", 0
beginColorEscape: 	.string 27, "[3", 0
endColorEscape:   	.string ";1;1m", 0
resetColorString:   .string 27, "[0m", 0
brickState:  		.word 0x0
xDelta:  			.byte 0xFF
yDelta: 			.byte 0x00
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

lab7:
	PUSH {lr}   ; Store lr to stack

	BL uart_init
	MOV r0, #0xc
	BL output_character

	BL printBoard

	MOV r0, #0x0
	;BL output_character

	MOV r1, #0
	BL setCursorxy

	MOV r0, #2 ; set color to yellow
	BL setBackground
	MOV r0, #0x20
	BL output_character
	MOV r0, #0x20
	BL output_character
	MOV r0, #0x20
	BL output_character

	BL resetColor

		; Your code is placed here.
 		; Sample test code starts here

mainloop:
	B mainloop
		; Sample test code ends here


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

	; Calculate the next position of the ball
	; Load x and y positions
	; Add x and y delta to their current position
	LDR r5, ptr_to_ballxPosition
	LDRB r5, [r5]
	LDR r6, ptr_to_ballyPosition
	LDRB r6, [r6]					; Load current x and y position into r5 and r6 (don't change these registers, need them later)
	LDR r7, ptr_to_xDelta
	LDRB r7, [r7]
	LDR r8, ptr_to_yDelta
	LDRB r8, [r8]					; Load current x and y deltas into r7 and r8 (change these to hold potential new position)
	ADD r9, r7, r5
	ADD r10, r8, r6					; Add x and y postions to their respective deltas and store into r9 and r10

	; Initialize inputs to touch functions
	MOV r2, r7
	MOV r3, r8						
	LDR r4, ptr_to_paddlePos
	LDRB r4, [r4]					; Pass potential x, y and paddle positions to touch functions

	; See if ball hits a wall
	; Call btouchSide, if r = 1, update deltas
	BL btouchSide
	CMP r1, #1
	BNE checkRoof					; If no touch, continue to next check
	SMUL r7, #-1					; Reverse x delta
	B checkDoubleBounce				; Jump to checkDoubleBounce for if it double bounces

checkRoof:
	; See if ball hits roof
	; Call btouchTop, if r = 1, update deltas
	BL btouchTop
	CMP r1, #1
	BNE checkBrick					; If no touch, continue to next check
	SMUL r7, #-1					; Reverse x delta
	B checkDoubleBounce				; Jump to checkDoubleBounce for if it double bounces

checkBrick:
	; See if ball hits brick
	; Call btouchBrick, if r1 = 1, update deltas, NEEDS TO KNOW IF HITTING VERTICAL OR HORIZONTAL FACE
	; Set brick state for that brick to 0, and erase the brick

checkBottom:
	; See if ball hits bottom
	; Call btouchBot, if r1 = 1 then lose life, reset paddle and ball position, and x,y delta's

checkPaddle:
	; See if ball hits paddle
	; Call btouchPaddle, if r1 = 1, call updateBallDeltaForPaddleBounce

	; Branch here after a bounce has occurred
checkDoubleBounce:
	; Recalculate position:
	LDR r7, ptr_to_xDelta
	LDRB r7, [r7]
	LDR r8, ptr_to_yDelta
	LDRB r8, [r8]					; Load current x and y deltas into r7 and r8
	ADD r7, r7, r5
	ADD r8, r8, r6					; Add x and y postions to their respective deltas
	; Run all bounce checks again to see if there are any double bounces:
	; Do the stuff here

	; Store the positions to memory
	LDR r9, ptr_to_ballxPosition
	STRB r7, [r9]
	LDR r10, ptr_to_ballyPosition
	LDRB r8, [r10]					; Store new x and y positions to memory

printBall:
	; Print " " where ball currently is to erase it (this is where we need r5 and r6 unchanged)
	MOV r0, r5
	MOV r1, r6
	BL setCursorxy					; Move cursor to current ball position
	MOV r0, #0x20					
	BL output_character				; Print a " " character

	; Print the ball in its new position
	MOV r0, r7
	MOV r1, r8
	BL setCursorxy					; Move cursor to new position
	MOV r0, #0x6F
	BL output_character				; Print a "o" character


    ; Update position based on direction stored in current_direction and switch_speed

    ; Restore the registers
    POP {lr, r4-r11}

	BX lr       	; Return


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

	ldr r4, ptr_to_xescapeStringBuffer
	PUSH {r1}
	MOV r1, r4
	BL int2string
	POP {r1}
	ldr r5, ptr_to_yescapeStringBuffer
	PUSH {r0, r1}
	MOV r0, r1
	MOV r1, r5
	POP {r0, r1}

	BL escapeSequence
	MOV r0, #0x48
	BL output_character

	CMP r4, #0x30
	BEQ noxshift
	BL escapeSequence
	MOV r0, r4
	BL output_string
	MOV r0, #0x43 ; column shift for x
	BL output_character
noxshift:

	CMP r5, #0x30
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
	; LDR r0, ptr_to_score
	;LDW r0, [r0]				; Load score
	;BL int2string				; Convert score to string
	; BL output_string			; Output the score

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
	MOV r0, #17
	BL setCursorxy				; Set cursor to beginning of second line
	LDR r0, ptr_to_topBottomBorder
	BL output_string			; Print the border

	POP {lr, r4-r11}
	mov pc, lr


; Prints the set amount of blocks in random colors
displayBricks:
	PUSH {lr, r4-r11}
	; Get the brick state
	ldr r0, ptr_to_brickState
	LDRW r4, [r0]				; Loads brickState into r4

	; Loop over first 28 bits
	MOV r5, #0				; Set bit position to be 0
	MOV r6, #1				; Create a mask
	; Check bit value
	AND r7, r5, r6
	; ldr r6, ptr_to_xDeltaLSR r4,
	CMP r7, r6


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
	PUSH {lr, r5}
	; return false if y is greater than 6 or equal to 1
	CMP r3, #1 ; y == 1
	BEQ btouchBrickfalse ; return false
	CMP r3, #6 ; y > 6
	BGT btouchBrickfalse ; return false
	; shift brickState by x*7 places
	ldr r1, ptr_to_brickState
	ldrw r1, [r1]
	MOV r5, #7
	MUL r5, r2, r5 ; r5 = x*7
	LSR r1, r1, r5 ; brickstate >>= r5
	AND r1, r1, #1 ; brickstate & 1

	POP  {pc, r5}

btouchBrickfalse:

	MOV r1, #0
	POP  {pc, r5}


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

	SUB r1, r2, r4
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

	ldr r2, ptr_to_xDelta
	ldr r3, ptr_to_yDelta

	CMP r1, #2
	ITTT EQ
	MOVEQ r2, #0
	MOVEQ r3, #-1
	BEQ exitUpdateBallDelta

	CMP r2, #0
	ITE LT
	MOVLT r2, #-1
	MOVGE r2, #1

	CMP r1, #3
	IT EQ
	MOVEQ r1, #1
	CMP r1, #4
	IT EQ
	MOVEQ r1, #0

	CMP r1, #1
	ITT EQ
	MOVEQ r3, #0xfe
	BEQ exitUpdateBallDelta

	CMP r1, #0
	ITT EQ
	MOVEQ r3, #-1
	BEQ exitUpdateBallDelta

exitUpdateBallDelta:
	PUSH {r6}
	ldr r6, ptr_to_xDelta
	strb r2, [r6]
	ldr r6, ptr_to_yDelta
	strb r3, [r6]
	POP {r6}

exitBallDeltaCheck:
	POP {pc}

; change ball velocity
bounceBall:
	PUSH {lr, r4-r11}
	POP  {lr, r4-r11}	  ; Restore lr from stack
	mov pc, lr

; update paddle position
movePaddle:
	PUSH {lr, r4-r11}
	POP  {lr, r4-r11}	  ; Restore lr from stack
	mov pc, lr

; set putty terminal color
; 1..5 = red, green, yellow, blue, purple
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
