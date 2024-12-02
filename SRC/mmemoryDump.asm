

msg04   db 0Dh,0Ah,"<ESC>Fim, <Enter>Continua: ", 0
msg05   db 0Dh,0Ah,"ES: ", 0

;=================================
; Dump memory
; Segment address: ES
; Memory  address: bx
;         
dump:
        call    readAddress
NewBlock:
        push    BX
        mov     si, msg05
        call    pstr
        mov     AX, ES
        call    print_hex      
        mov     al, ':'
        call    cout
        pop     BX
        mov     AX, BX
        call    print_hex      

        mov  CL, 16
        call newLine
dump_01:        
        mov  AX, BX
        call print_hex
        mov  al, ':'
        call cout
        MOV  AL, ' '
        CALL cout
        
        ;;Write 16 bytes em hexadecimal
        MOV  CH, 16
dump_02:
        MOV  AL, ES:[BX]
        CALL byte_to_hex_str
        PUSH AX
        CALL cout
        POP  AX
        MOV  AL, AH
        CALL cout
        MOV  AL, ' '
        CALL cout
        INC  BX
        DEC  CH
        JNZ  dump_02
        ;;Wrote 16 bytes

        MOV  AL, ' '
        CALL cout

        SUB  BX, 16

        ;;Write 16 bytes em ASCII
        MOV  CH, 16
dump_03:
        MOV  AL, ES:[BX]
        CMP  AL, 0x20
        JC  printPonto ; Flag carry set to 1 AL < 0x20
        CMP  AL, 0x80
        JnC  printPonto ; Flag carry set to 0 AL > 0x80
        CALL cout
        INC  BX
        DEC  CH
        JNZ  dump_03
        jmp  dump_Fim
printPonto:        
        MOV  AL, '.'
        CALL cout
        INC  BX
        DEC  CH
        JNZ  dump_03
        ;;Wrote 16 bytes

dump_Fim:
        call newLine
        DEC  CL
        JNZ  dump_01
        ;;mov  AX, 0F000h
        ;;mov  DS, AX
        jmp continua
        ret

printPrompt:
        mov al, '>'
        call cout
        ret

continua:
        push BX
        mov  si, msg04
        call pstr
        XOR  AX, AX
        pop  BX
        call cin_blct
        cmp  al, cr
        je   NewBlock
        ret


