	.text

	.global lab7

	.global uart_init
	.global output_character
	.global output_string

beginColorEscape: .string "[3", 0
endColorEscape:   .string ";1;1m", 0
ptr_to_beginColorEscape: .word beginColorEscape
ptr_to_endColorEscape: .word endColorEscape
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


; generates a random integer
randInt:
	PUSH {lr, r4-r11}
	POP  {lr, r4-r11}	  ; Restore lr from stack
	mov pc, lr

; generates a random color value 1..5
randomColor:
	PUSH {lr, r4-r11}
	POP  {lr, r4-r11}	  ; Restore lr from stack
	mov pc, lr

; apply one time unit of velocity
moveBall:
	PUSH {lr, r4-r11}
	POP  {lr, r4-r11}	  ; Restore lr from stack
	mov pc, lr

; return true/false if ball is touching top, left, or right sides.
btouchWAD:
	PUSH {lr, r4-r11}
	POP  {lr, r4-r11}	  ; Restore lr from stack
	mov pc, lr

; return true/false if ball is touching bottom
btouchS:
	PUSH {lr, r4-r11}
	POP  {lr, r4-r11}	  ; Restore lr from stack
	mov pc, lr

; return true/false if ball is touching paddle
btouchPaddle:
	PUSH {lr, r4-r11}
	POP  {lr, r4-r11}	  ; Restore lr from stack
	mov pc, lr

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

	.end
