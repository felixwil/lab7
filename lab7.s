	.text

	.global lab7


lab7:
	PUSH {lr}   ; Store lr to stack

		; Your code is placed here.
 		; Sample test code starts here


		; Sample test code ends here


	POP {lr}	  ; Restore lr from stack
	mov pc, lr

	.end
