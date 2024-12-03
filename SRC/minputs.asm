msg01	db 0Dh,0Ah,"Digite o endereco: ", 0
msg02   db 0Dh,0Ah,"<ESC>para novo segment <Enter>continua ES: ", 0
msg03   db 0Dh,0Ah,"Novo segment ES: ", 0


inputAddress:
        call readLine
        call convertWordToHex
	mov 	ah, byte es:[buff_write]
	mov	al, byte es:[buff_write+1]
        ret

loadBX:
        push    ES
        mov     AX, 0x0
        mov     ES, AX
        mov     si, msg01
        call    pstr
        call    inputAddress
        mov     BX, AX
        ;call    print_hex
        pop     ES
        ret        
showES:
        push BX
        mov  si, msg02
        call pstr
        mov  AX, ES
        call print_hex
        XOR  AX, AX
        call cin_blct
        cmp  al, 0x0d
        je   .retorna
        call    changeES
.retorna:
        pop BX
        ret

changeES:
        push    BX
        xor     AX, AX
        mov     ES, AX
        mov     si, msg03
        call    pstr
        call    inputAddress
        mov     ES, AX
        pop     BX
        ret

;Return the address in: ES:BX
readAddress:
        call    showES
        call    loadBX
        ret

readByteHexX:
        clc
        call cin_blct
        cmp  al, 0x1b
        je   readByteHexEnd   
        call to_hex
        mov  ah, al
        call print_digit
        call cin_blct
        cmp  al, 0x1b
        je   readByteHexEnd   
        call to_hex
        shl  ah, 1
        shl  ah, 1
        shl  ah, 1
        shl  ah, 1
        or   al, ah
        call  print_digit
        stc
readByteHexEnd:        
        ret          


;Return byte in hexadecmal in: AL
inputData:
        call readLine
        call convertByteToHex
        mov  al, byte es:[buff_write]
        ret
           
