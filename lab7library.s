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


output_string:
        PUSH {lr}   ; Store register lr on stack

        MOV r1, r0 ; copying the pointer

outputstringloop:
        LDRB r0, [r1] ; getting the char at the pointer (ptr[0])

        CMP r0, #0 ; if the char is null char, exit
        BEQ exitoutputstring

        BL output_character ; call the output char function to transmit r0 over uart

        ADD r1, r1, #1 ; increment char pointer

        B outputstringloop ; go back up

exitoutputstring:

        POP {lr}
        mov pc, lr
