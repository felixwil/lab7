	.text

	.global lab7

	.global uart_init
	.global output_character
	.global output_string

welcomestring: .string "welcome!", 0
beginColorEscape: .string 27, "[3", 0
endColorEscape:   .string ";1;1m", 0
resetColorString:   .string 27, "[0m", 0
ptr_to_beginColorEscape: .word beginColorEscape
ptr_to_endColorEscape: .word endColorEscape
ptr_to_welcomestring: .word welcomestring
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

ptr_to_resetColorString:   .word resetColorString

lab7:
	PUSH {lr}   ; Store lr to stack

	BL uart_init

	MOV r0, #6 ; set color to blue
	BL setColor
	MOV r0, #0x6f
	BL output_character

	BL resetColor

	ldr r0, ptr_to_welcomestring
	BL output_string

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
