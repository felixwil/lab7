	.text

	.global lab7

	.global uart_init
	.global output_character
	.global output_string

beginColorEscape: .string "[3", 0
endColorEscape:   .string ";1;1m", 0
ptr_to_beginColorEscape: .word beginColorEscape
ptr_to_endColorEscape: .word endColorEscape
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

lab7:
	PUSH {lr}   ; Store lr to stack

	BL uart_init

	MOV r0, #4 ; set color to blue
	BL setColor

	MOV r0, #0x6f
	BL output_character

		; Your code is placed here.
 		; Sample test code starts here

mainloop:
	B mainloop
		; Sample test code ends here


	POP {lr}	  ; Restore lr from stack
	mov pc, lr

printBoard:
	; Screen size is 23x19, board edges are 23x18, inner board is 21x16

	; Print the score string and score value

	; Print the upper boarder

<<<<<<< HEAD
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
setColor:
	PUSH {lr, r4-r11}

	MOV r0, #27
	BL output_character
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
	PUSH {lr, r4-r11}
	POP  {lr, r4-r11}	  ; Restore lr from stack
	mov pc, lr

; clears the board and resets all the bricks, the ball, and the paddle
levelClear:
	PUSH {lr, r4-r11}
	POP  {lr, r4-r11}	  ; Restore lr from stack
	mov pc, lr
=======
	; Print the side walls
>>>>>>> b775a3d63818cdf3b3f527b0dd6a88fde4eb99d9

	; Print the lower boarder
	
	.end
