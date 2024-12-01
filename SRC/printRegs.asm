	CPU 8086
;=========================================================================
; print_hex - print 16-bit number in hexadecimal
; Input:
;	AX - number to print
; Output:
;	none
;-------------------------------------------------------------------------
print_hex:
    push    AX
	xchg	al,ah
	call	print_byte		; print the upper byte
	xchg	al,ah
	call	print_byte		; print the lower byte
    pop     AX
	ret
;=========================================================================
; print_digit - print hexadecimal digit
; Input:
;	AL - bits 3...0 - digit to print (0...F)
; Output:
;	none
;-------------------------------------------------------------------------
print_digit:
	push	ax
	push	bx
	and	al,0Fh
	add	al,'0'			; convert to ASCII
	cmp	al,'9'			; less or equal 9?
	jna	.1
	add	al,'A'-'9'-1		; a hex digit
.1:
    call    cout
	pop	bx
	pop	ax
	ret
;=========================================================================
; print_byte - print a byte in hexadecimal
; Input:
;	AL - byte to print
; Output:
;	none
;-------------------------------------------------------------------------
print_byte:
	rol	al,1
	rol	al,1
	rol	al,1
	rol	al,1
	call	print_digit
	rol	al,1
	rol	al,1
	rol	al,1
	rol	al,1
	call	print_digit
	ret
;=========================================================================
;byte_to_hex_str
;This function return in AX the ascii code for hexadecimal number from 0 to F
;Parameters:
;               AL = imput
;               AX = output
;This routines expands the data 1 byte returns 2 bytes
;Ex.: 0xA5 returns 4135 41 = 'A' 35 = '5' 
;
;Changes CL
byte_to_hex_str:
        PUSH CX
        mov ah, al
        mov cl, 4
        shr al, cl
        and ax, 0x0f0f
        cmp al, 0x09
        jbe .11
        add al, 'A' - '0' - 10
.11:
        cmp ah, 0x09
        jbe .22
        add ah, 'A' - '0' - 10
.22:
        add ax, "00"
.ret:
        POP CX
        ret

;==========================================================================
;hex_str_to_hex
;Parameters: DX = data to be converted
;            bh = return data
;
;This routines compress the data 2 bytes returns 1 byte
;Ex.: A5 in memory 41 35 41 = 'A' 35 = '5' returns 0xA5  A=1010 and 5 = 0101 
;
;A crude and simple implementation is to split 
;the byte into two nibbles and then use each 
;nibble as an index into a hex character "table".
; cdecl calling convention (google if you're not familiar with)
HEX_CHARSET		db 0,1,2,3,4,5,6,7,8,9,0xA,0xB,0xC,0xD,0xE,0xF

; void byteToHex(byte val, char* buffer)
hex_str_to_hex:
    ; nibble 1
	xor		BX, BX
    mov 	ax,	dx
	call	getNibble
	shl		ah, 1
	shl		ah, 1
	shl		ah, 1
	shl		ah, 1
	mov		bh, ah
    ; nibble 2
    mov 	ax,	dx
	mov		ah, al
	call	getNibble
	and		ah, 0x0F
	or		bh, ah
	ret
		
getNibble:	
	cmp ah, 0x41
	jge getHexSuperior
	sub ah, 0x30
	ret
getHexSuperior:
	sub ah, 0x37
	ret

;=======================================================	
;nibbleToHex
;Parameters AX = data to be converted
;Return data in AL
nibbleToHex:
	and AX, 0Fh ; 
	lea si, ds:[HEX_CHARSET]
	add si, ax
	lodsb
	ret

convertAddrToHex:
	;mov		si, reg_buff_read
	;call	pstr_sram

	mov		dh, byte es:[reg_buff_read]
	mov		dl, byte es:[reg_buff_read+1]

	call	hex_str_to_hex
	mov		byte es:[reg_buff_write], bh

	mov		dh, byte es:[reg_buff_read+2]
	mov		dl, byte es:[reg_buff_read+3]

	call	hex_str_to_hex
	mov		byte es:[reg_buff_write+1], bh

	ret
