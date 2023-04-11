	.text

	.global lab7


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
