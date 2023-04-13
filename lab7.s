	.text

	.global lab7

	.global uart_init
	.global output_character
	.global output_string

beginColorEscape: 	.string 27, "[3", 0
endColorEscape:   	.string ";1;1m", 0
resetColorString:   .string 27, "[0m", 0
brickState:  		.word 0x0
xDelta:  			.byte 0xFF
yDelta: 			.byte 0x00
score: 				.word 0x0
ballxPosition:  	.byte 0x0B
ballyPosition:  	.byte 0x08
paddlePosition: 	.byte 0x09
ballColor:  		.byte 0x00
lives:  			.byte 0x04
level:  			.byte 0x01
pauseState:  		.byte 0x00
scoreString:		.string "Score: ", 0
topBottomBorder:	.string "+---------------------+"

; Pointers to memory locations
ptr_to_beginColorEscape:		.word beginColorEscape
ptr_to_endColorEscape:			.word endColorEscape
ptr_to_brickState:				.word brickState
ptr_to_xDelta:					.word xDelta
ptr_to_yDelta:					.word yDelta
ptr_to_score:					.word score
ptr_to_ballxPosition:			.word ballxPosition
ptr_to_ballyPosition:			.word ballyPosition
ptr_to_paddlePosition:			.word paddlePosition
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

	MOV r0, #6 ; set color to blue
	BL setColor
	MOV r0, #0x6f
	BL output_character

	BL resetColor


		; Your code is placed here.
 		; Sample test code starts here

mainloop:
	B mainloop
		; Sample test code ends here


	POP {lr}	  ; Restore lr from stack
	mov pc, lr

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
	BL int2string				; Convert score to string
	BL output_string			; Output the score

	; Print the upper boarder
	MOV r0, #0
	MOV r0, #0
	BL setCursorxy				; Set cursor to beginning of second line
	LDR r0, ptr_to_topBottomBorder
	BL output_string			; Print the border

	; Print the side walls
	MOV r4, #1					; Variable to track row number
	MOV r5, #0x7C				; Vertical line
printWalls:
	MOV r0, #0
	MOV r0, r4
	BL setCursorxy				; Set the cursor position, (0, row)
	MOV r0, r5
	BL output_character			; Set character to print to be "|", then output it
	MOV r0, #22
	MOV r0, r4
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
	; Get the brick state

	; Loop over first 28 bits
	; Check bit value

	; If 1, generate random color value

	; Display brick

	; Jump back to loop

; return true/false if ball is touching a brick
btouchBrick:
	PUSH {lr, r4-r11}
	POP  {lr, r4-r11}	  ; Restore lr from stack
	mov pc, lr

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
