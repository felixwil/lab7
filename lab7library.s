        .text
        .global uart_init
        .global gpio_btn_and_LED_init
        ;.global keypad_init ; Downloaded from the course website
        .global output_character
        .global read_character
        .global read_string
        .global output_string
        .global read_from_push_btns
        .global illuminate_LEDs
        .global illuminate_RGB_LED
        .global read_tiva_push_button
        .global read_from_keypad
        .global string2int
        .global int2string

	.global uart_interrupt_init
        .global gpio_interrupt_init
        .global timer_interrupt_init

uart_init:
        PUSH {lr, r0, r1}  ; Store register lr on stack

        ; copied comments from lab3wrapper.c obviously

        ;/* Provide clock to UART0  */
	; (*((volatile uint32_t *)(0x400FE618))) = 1;
        MOV r0, #0xe618
        MOVT r0, #0x400f
        MOV r1, #1
        STRW r1, [r0]

	;/* Enable clock to PortA  */
	; (*((volatile uint32_t *)(0x400FE608))) = 1;
        MOV r0, #0xe608
        MOVT r0, #0x400f
        MOV r1, #1
        STRW r1, [r0]

	;/* Disable UART0 Control  */
	; (*((volatile uint32_t *)(0x4000C030))) = 0;
        MOV r0, #0xc030
        MOVT r0, #0x4000
        MOV r1, #0
        STRW r1, [r0]

	;/* Set UART0_IBRD_R for 115,200 baud */
	; (*((volatile uint32_t *)(0x4000C024))) = 8;
	MOV r0, #0xc024
	MOVT r0, #0x4000
	MOV r1, #8
	STRW r1, [r0]

	;/* Set UART0_FBRD_R for 115,200 baud */
	; (*((volatile uint32_t *)(0x4000C028))) = 44;
        MOV r0, #0xc028
        MOVT r0, #0x4000
        MOV r1, #44
        STRW r1, [r0]

	;/* Use System Clock */
	; (*((volatile uint32_t *)(0x4000CFC8))) = 0;
        MOV r0, #0xcfc8
        MOVT r0, #0x4000
        MOV r1, #0
        STRW r1, [r0]

	;/* Use 8-bit word length, 1 stop bit, no parity */
	; (*((volatile uint32_t *)(0x4000C02C))) = 0x60;
        MOV r0, #0xc02c
        MOVT r0, #0x4000
        MOV r1, #0x60
        STRW r1, [r0]

	;/* Enable UART0 Control  */
	; (*((volatile uint32_t *)(0x4000C030))) = 0x301;
        MOV r0, #0xc030
        MOVT r0, #0x4000
        MOV r1, #0x0301
        STRW r1, [r0]

	;/* Make PA0 and PA1 as Digital Ports  */
	; (*((volatile uint32_t *)(0x4000451C))) |= 0x03;
        MOV r0, #0x451c
        MOVT r0, #0x4000
        LDRB r1, [r0]
        ORR r1, r1, #0x03
        STRW r1, [r0]

	;/* Change PA0,PA1 to Use an Alternate Function  */
	; (*((volatile uint32_t *)(0x40004420))) |= 0x03;
        MOV r0, #0x4420
        MOVT r0, #0x4000
        LDRB r1, [r0]
        ORR r1, r1, #0x03
        STRW r1, [r0]

	;/* Configure PA0 and PA1 for UART  */
	; (*((volatile uint32_t *)(0x4000452C))) |= 0x11;
        MOV r0, #0x452c
        MOVT r0, #0x4000
        LDRB r1, [r0]
        ORR r1, r1, #0x11
        STRW r1, [r0]

        POP {lr, r0, r1}
        mov pc, lr

uart_interrupt_init:
        PUSH {lr, r4-r11}          ; store regs
        ; Configure UART for interrupts
        
        MOV  r11, #0xc038
        MOVT r11, #0x4000          ; setting the address
        LDRW r4, [r11]             ; loading the data into r4
        
        ORR r4, r4, #16             ; r4 |= #8
        
        MOV  r11, #0xc038
        MOVT r11, #0x4000          ; setting the address
        STRW r4, [r11]             ; storing the data from r4
        ; Set processor to allow for interrupts from UART0
        
        MOV  r11, #0xe100
        MOVT r11, #0xe000          ; setting the address
        LDRW r4, [r11]             ; loading the data into r4
        
        ORR r4, r4, #32            ; r4 |= #16
        
        MOV  r11, #0xe100
        MOVT r11, #0xe000          ; setting the address
        STRW r4, [r11]             ; storing the data from r4
        
        POP {lr, r4-r11}           ; restore saved regs
        MOV pc, lr                 ; return to source call

gpio_interrupt_init:
        PUSH {lr, r4-r11}          ; store regs
        
        ; Set interrupt to be edge sensitive
        MOV  r11, #0x5404
        MOVT r11, #0x4002          ; setting the address
        LDRW r4, [r11]             ; loading the data into r4
        
        AND r4, r4, #0xfe          ; r4 &= #0xf7
        
        MOV  r11, #0x5404
        MOVT r11, #0x4002          ; setting the address
        STRW r4, [r11]             ; storing the data from r4
        
        ; Set trigger for interrupt to be single edge
        MOV  r11, #0x5408
        MOVT r11, #0x4002          ; setting the address
        LDRW r4, [r11]             ; loading the data into r4
        
        AND r4, r4, #0xfe          ; r4 &= #0xf7
        
        MOV  r11, #0x5408
        MOVT r11, #0x4002          ; setting the address
        STRW r4, [r11]             ; storing the data from r4
        
        ; Set the falling edge to be the trigger (triggers on press, not release)
        MOV  r11, #0x540c
        MOVT r11, #0x4002          ; setting the address
        LDRW r4, [r11]             ; loading the data into r4
        
        AND r4, r4, #0xfe          ; r4 &= #0xf7
        
        MOV  r11, #0x540c
        MOVT r11, #0x4002          ; setting the address
        STRW r4, [r11]             ; storing the data from r4
        
        ; Enable the the interrupt
        MOV  r11, #0x5410
        MOVT r11, #0x4002          ; setting the address
        LDRW r4, [r11]             ; loading the data into r4
        
        ORR r4, r4, #16          ; r4 |= #0x08
        
        MOV  r11, #0x5410
        MOVT r11, #0x4002          ; setting the address
        STRW r4, [r11]             ; storing the data from r4
        
        ; Set processor to allow interrupts from GPIO port F 
        MOV  r11, #0xe100
        MOVT r11, #0xe000          ; setting the address
        LDRW r4, [r11]             ; loading the data into r4
        
        ORR r4, r4, #0x40000000    ; r4 |= #0x20000000
        
        MOV  r11, #0xe100
        MOVT r11, #0xe000          ; setting the address
        STRW r4, [r11]             ; storing the data from r4

        
        POP {lr, r4-r11}           ; restore saved regs
        MOV pc, lr                 ; return to source call             ; return to source call

timer_interrupt_init:
        ; Connect clock to timer
        MOV r11, #0xE604
        MOVT r11, #0x400F   ; load address
        LDRW r4, [r11]      ; load value
        ORR r4, r4, #1      ; write 1 to bit 0
        STRW r4, [r11]      ; store back

        ; Disable timer
        MOV r11, #0x000C
        MOVT r11, #0x4003   ; load address
        LDRW r4, [r11]      ; load value
        AND r4, r4, #0xFE      ; write 1 to bit 0
        STRW r4, [r11]      ; store back

        ; Put timer into 32-bit mode
        MOV r11, #0x0000
        MOVT r11, #0x4003   ; load address
        LDRW r4, [r11]      ; load value
        AND r4, r4, #0xF8   ; write 0 to first 3 bits
        STRW r4, [r11]      ; write back

        ; Put timer into periodic mode
        MOV r11, #0x0004
        MOVT r11, #0x4003   ; load address
        LDRW r4, [r11]      ; load value
        AND r4, r4, #0xFE      ; write 2 to first two bits
        ORR r4, r4, #2      ; write 2 to first two bits
        STRW r4, [r11]      ; write back

        ; Set up interval period
        MOV r11, #0x0028
        MOVT r11, #0x4003   ; load address
        MOV r4, #0x2400
        MOVT r4, #0x00F4    ; load frequency
        STRW r4, [r11]      ; store frequency

        ; Enable timer to interrupt processor
        MOV r11, #0x0018
        MOVT r11, #0x4003   ; load address
        LDRW r4, [r11]      ; load value
        ORR r4, r4, #1      ; write 1 to bit 0
        STRW r4, [r11]      ; write back

        ; Configure processor to allow timer interrupts
        MOV r11, #0xE100
        MOVT r11, #0xE000   ; load address
        LDR r4, [r11]       ; load value
        ORR r4, r4, #1 << 19 ; 0x80000; write 1 to bit 19
        STRW r4, [r11]       ; write back

        ; Enable timer
        MOV r11, #0x000C
        MOVT r11, #0x4003  ; load address
        LDRW r4, [r11]      ; load value
        ORR r4, r4, #1      ; write 1 to bit 0
        STRW r4, [r11]

output_character:
        PUSH {lr, r4-r11}   ; Store register lr on stack

checkdisplay:
        MOV r7, #0xC018 ; r7 = checkaddr
        MOVT r7, #0x4000
        LDRB r4, [r7] 	  ; r3 = r7[0]
        AND r4, r4, #0x20 ; bit twiddling
        CMP r4, #0
        BGT checkdisplay

        MOV r8, #0xC000
        MOVT r8, #0x4000
        STRB r0, [r8] ; (r8 = 0x4000C000)[0] = r0

        POP {lr, r4-r11}
        mov pc, lr

output_string:
        PUSH {lr, r4-r11}   ; Store register lr on stack

        MOV r5, r0 ; copying the pointer

outputstringloop:
        LDRB r0, [r5] ; getting the char at the pointer (ptr[0])

        CMP r0, #0 ; if the char is null char, exit
        BEQ exitoutputstring

        BL output_character ; call the output char function to transmit r0 over uart

        ADD r5, r5, #1 ; increment char pointer

        B outputstringloop ; go back up

exitoutputstring:

        POP {lr, r4-r11}
        mov pc, lr

int2string:
        PUSH {lr, r4-r6}      ; Store register lr on stack

	; r0: int, r1: char*

        MOV r5, #10
        MOV r6, r0
        MOV r2, #0

charactercounterloop:

        ADD r2, r2, #1;  increment i
        SDIV r6, r6, r5; number //= 10 (floor divide by 10)

        CMP r6, #0;
        BGT charactercounterloop; return to the top

        ADD r1, r1, r2
        SUB r1, r1, #1
        STRB r6, [r1, #1]

nextplace:

        MOV r4, r0
        sdiv r2, r4, r5
        mul r3, r2, r5 ; r4 %= 10
        sub r4, r4, r3

        ; converting r4 from 0-9 to an ascii char '0'-'9'
	; 0x30 == '0' etc
        ADD r4, r4, #0x30
        STRB r4, [r1] ; storing into the buffer
        SUB r1, r1, #1 ; decrementing the pointer (because the digits are read in reverse)
        MOV r11, #10
        SDIV r0, r0, r11

        CMP r0, #0 ; same loop condition as above.  (r0 // 10) == 0 means we've exhausted all digits
        BNE nextplace  ; go back up

        POP {lr, r4-r6}
        mov pc, lr

        .end
