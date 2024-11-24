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


