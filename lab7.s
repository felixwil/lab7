	.text

	.global lab7

	.global uart_init
	.global output_character
	.global output_string

begincolorescape: 	.string "\033[3", 0
endcolorescape:   	.string ";1;1m", 0
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
		; Your code is placed here.
 		; Sample test code starts here

mainloop:
	B mainloop
		; Sample test code ends here


	POP {lr}	  ; Restore lr from stack
	mov pc, lr

	.end
