	.text

	.global lab7

	brickState:  	.word 0x0
	xDelta:  		.byte 0xFF
	yDelta: 		.byte 0x00
	score: 			.word 0x0
	ballxPosition:  .byte 0x0B
	ballyPosition:  .byte 0x08
	paddlePosition: .byte 0x09
	ballColor:  	.byte 0x00
	lives:  		.byte 0x04
	level:  		.byte 0x01
	pauseState:  	.byte 0x00


lab7:
	PUSH {lr}   ; Store lr to stack

		; Your code is placed here.
 		; Sample test code starts here


		; Sample test code ends here


	POP {lr}	  ; Restore lr from stack
	mov pc, lr

printBoard:
	; Board is 23 characters wide, displayed edge to displayed edge, interior is 21
	; Board is 19 characters high, 18 characters edge to edge, interior is 17

	; Clear the screen

	; Print the score string and current score

	; Print the upper boundry

	; Print the side walls

	; Print the lower boundry

	.end
