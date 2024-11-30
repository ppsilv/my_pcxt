
msg01	db 0Dh,"Digite o endereco BX: ", 0
msg02   db 0Dh,"<ESC>para novo segment <Enter>continua ES: ", 0
msg03   db 0Dh,"Novo segment ES: ", 0
msg04   db 0Dh,"Continua <Enter>: ", 0
msg05   db 0Dh,"ES: ", 0

loadBX:
        push    ES
        mov     AX, 0x0
        mov     ES, AX
        mov     BX, msg01
        call    print2
        call    readAddress
	mov 	ah, byte es:[di]
	mov	al, byte es:[di+1]
        mov     BX, AX
        pop     ES
        ret        
showES:
        push BX
        mov  BX, msg02
        call print2
        mov  AX, ES
        call print_hex
        XOR  AX, AX
        call UART_RX_blct
        cmp  al, 0x0d
        je   .retorna
        call changeES
.retorna:
        pop BX
        ret

changeES:
        push    BX
        xor     AX, AX
        mov     ES, AX
        mov     BX, msg03
        call    print2
        call    readAddress
	mov 	ah, byte es:[di]
	mov	al, byte es:[di+1]
        mov     ES, AX
        pop     BX
        ret
;=================================
; Dump memory
; Segment address: ES
; Memory  address: bx
;         
dump:
        call    showES
        call    loadBX
Continua:
        push    BX
        mov     BX, msg05
        call    print2
        mov     AX, ES
        call    print_hex      
        mov     al, ':'
        call    UART_TX
        pop     BX
        mov     AX, BX
        call    print_hex      

        mov  CL, 16
dump_01:        
        mov  al, 0x0d
        call UART_TX
        mov  AX, BX
        call print_hex
        mov  al, ':'
        call UART_TX
        MOV  AL, ' '
        CALL UART_TX
        
        ;;Write 16 bytes em hexadecimal
        MOV  CH, 16
dump_02:
        MOV  AL, ES:[BX]
        CALL byte_to_hex_str
        PUSH AX
        CALL UART_TX
        POP  AX
        MOV  AL, AH
        CALL UART_TX
        MOV  AL, ' '
        CALL UART_TX
        INC  BX
        DEC  CH
        JNZ  dump_02
        ;;Wrote 16 bytes

        MOV  AL, ' '
        CALL UART_TX

        SUB  BX, 16

        ;;Write 16 bytes em ASCII
        MOV  CH, 16
dump_03:
        MOV  AL, ES:[BX]
        CMP  AL, 0x20
        JC  printPonto ; Flag carry set to 1 AL < 0x20
        CMP  AL, 0x80
        JnC  printPonto ; Flag carry set to 0 AL > 0x80
        CALL UART_TX
        INC  BX
        DEC  CH
        JNZ  dump_03
        jmp  dump_Fim
printPonto:        
        MOV  AL, '.'
        CALL UART_TX
        INC  BX
        DEC  CH
        JNZ  dump_03
        ;;Wrote 16 bytes

dump_Fim:
        DEC  CL
        JNZ  dump_01
        call newLine
        mov  AX, 0F000h
        mov  DS, AX
        jmp continua
        ret

printPrompt:
        mov al, '>'
        call UART_TX
        ret


readAddress:
        call NewReadLine
        call convertAddrToHex
        ret

continua:
        push BX
        mov  BX, msg04
        call print2
        XOR  AX, AX
        pop  BX
        call UART_RX_blct
        cmp  al, 0x0d
        je   Continua
        call NewReadLine
        ret
