printFromDram:
        mov  al,byte es:[bx]
        cmp  al,0h
        jz   fimPrintFromDram
contFromDram:
	call UART_TX
	JNC	contFromDram
        inc  bx
        jmp  printFromDram
fimPrintFromDram:  
	ret	

ReadLine:
        mov cl,0x0
        mov  bx,  reg_buff_read

        call printPrompt
loopP:  ;RX blocante
        call UART_RX_blct       
        call printch

        mov  byte es:[bx], al 
        mov  byte es:[bx+1], 0x0 
        inc  bx

        CMP  AL, 0x0A
        JNZ  loopP
        MOV  AL, 0x0D
        mov  byte es:[bx], al 
        mov  byte es:[bx+1], 0x0 
        mov  BX, reg_buff_read
        call printFromDram
        ret
str_8088        db      0Dh, 0Ah,"Cpu  8088  sem  FPU",0
str_v20         db      0Dh, 0Ah,"Cpu Nec V20 sem FPU",0
cpu_check:
	xor	al, al				; Clean out al to set ZF
	mov	al, 40h				; mul on V20 does not affect the zero flag
	mul	al				;   but on an 8088 the zero flag is used
	jz	.have_v20			; Was zero flag set?
	mov	si, offset str_8088		;   No, so we have an 8088 CPU
        call    pstr
	ret
.have_v20:
	mov	si, offset str_v20		;   Otherwise we have a V20 CPU
        call    pstr
	ret        


