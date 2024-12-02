        CPU 8086
   

; Port
COM1:	DW		0x3F8
; Here are the port numbers for various UART registers:
uart_tx_rx 		EQU  0x3f8 ; 0 DLAB = 0 for Regs. TX and RX
uart_DLL 		EQU  0x3f8 ; 0 DLAB = 1 Divisor lacth low
uart_IER 		EQU  0x3f9 ; 1 DLAB = 0 Interrupt Enable Register
uart_DLH 		EQU  0x3f9 ; 1 DLAB = 1 Divisor lacth high
uart_ISR 		EQU  0x3fa ; 2 IIR Interrupt Ident. Register READ ONLY
uart_FCR 		EQU  0x3fa ; 2 Fifo Control Resgister WRITE ONLY
uart_LCR 		EQU  0x3fb ; 3 Line Control Register
uart_MCR 		EQU  0x3fc ; 4 Modem Control Register
uart_LSR 		EQU  0x3fd ; 5 Line Status Register
uart_MSR 		EQU  0x3fe ; 6 Modem Status Register
uart_scratch 	EQU  0x3ff ; 7 SCR Scratch Register

UART_FREQUENCY		equ 4915000
;Fomula UART_FREQUENCY/(  9600 * 16)
;Baudrates
UART_BAUD_9600		EQU 32
UART_BAUD_19200		EQU 16
UART_BAUD_38400		EQU  8
UART_BAUD_56800		EQU  5
UART_BAUD_115200	EQU  3
UART_BAUD_230400	EQU  1

UART_TX_WAIT		EQU	0x7fff		; Count before a TX times out

msg0_01:   db "Serial driver for 16C550",0
;configure_uart
;Parameters:None
;			
;			
configure_uart:
			mov cx, 0x1fff
			call	basicDelay
			MOV		AL,0x0	 		;
			MOV		DX, uart_IER
			OUT  	DX,	AL	; Disable interrupts

			mov cx, 0x1f
			call	basicDelay

			MOV		AL, 0x80			;
			MOV		DX, uart_LCR
			OUT     DX,	AL 	; Turn DLAB on
			mov cx, 0x1f
			call	basicDelay

			MOV		AL, UART_BAUD_38400 ;0x08
			MOV		DX, uart_DLL
			OUT     DX,   AL	; Set divisor low
			mov cx, 0x1f
			call	basicDelay

			MOV		AL, 0x00		;
			MOV		DX, uart_DLH
			OUT     DX,	AL	; Set divisor high
			mov cx, 0x1f
			call	basicDelay

			MOV     AL, 0x03	; AH	
			MOV		DX, uart_LCR
			OUT     DX,	AL	; Write out flow control bits 8,1,N
			mov cx, 0x1f
			call	basicDelay

			MOV 	AL,0x81			;
			MOV		DX, uart_ISR
			OUT     DX,	AL	; Turn on FIFO, with trigger level of 8.
								                ; This turn on the 16bytes buffer!
			RET

newLine:
	mov  al, 0Dh
	call cout
	mov  al, 0Ah
	call cout
	ret
	
basicDelay:
        dec cx
        jnz basicDelay
        ret

readLine:
		push	DI
		push	DX
        mov  	DI,  buff_read   
		mov		cl, 0x0     
.loopP:  ;RX blocante
        call 	cin_blct       
		stosb
		inc		cl
        call 	cout
        CMP  	AL, cr
        JNZ  	.loopP
		mov  	al,0x0
		stosb
		pop		DX
		pop 	DI
        ret

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;Mais funções
; send string to terminal
; entry: si

eos	equ 0
cr	equ 13
lf	equ 10

pstr:   
		mov al,cs:[si]
		cmp al,eos
		jnz pstr1
		ret
pstr1:
		call cout
		inc si
		jmp pstr

pstr_sram:
		mov ax, 0x0
        mov ES, AX 
		mov al,es:[si]
		cmp al,eos
		jnz .pstr1
		ret
.pstr1:
		call cout
		inc si
		jmp pstr_sram

;=================================================================================
;cout
; send 8-bit character in al to terminal
; entry: al
cout:
		push 		ax
		mov 		dx,	uart_LSR
cout1:	
		in  al,		dx
		and al, 	0x60	; Check for TX empty
		jz 	cout1			; wait until TXE = 1
		pop ax
		mov dx,		uart_tx_rx
		out dx,		al
		ret
;=================================================================================
;cin:
;Parameters: 
;			AL = return the available character
;			If al returns with a valid char flag carry is set, otherwise
;			flag carry is clear
cin:	
			MOV DX, uart_LSR
			IN	AL, DX	 		; Get the line status register
			AND AL, 0x01		; Check for characters in buffer
			CLC 				; Clear carry
			JZ	.end			; Just ret (with carry clear) if no characters
			MOV DX, uart_tx_rx
			IN	AL, DX			; Read the character from the UART receive buffer
			STC 				; Set the carry flag
.end:			
			RET

cin_blct:	
			MOV DX, uart_LSR
			IN	AL, DX	 		; Get the line status register
			AND AL, 0x01		; Check for characters in buffer
			JZ	cin_blct		; Just loopif no characters
			MOV DX, uart_tx_rx
			IN	AL, DX			; Read the character from the UART receive buffer
			RET

space:  
			mov al," "
	    	call cout
	    	ret

get_hex: 
		call cin
		call to_hex
		rol al,1
		rol al,1
		rol al,1
		rol al,1
		mov ah,al
		call cin
		call to_hex
		add al, ah
		ret			