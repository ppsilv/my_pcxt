



printES:
        push ES
        mov al, 'E'
        call printCH
        mov al, 'S'
        call printCH
        mov     AX, ES
        call print_hex
        pop ES
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
        call    printCH
	pop	bx
	pop	ax
	ret

;=========================================================================
; print_hex - print 16-bit number in hexadecimal
; Input:
;	AX - number to print
; Output:
;	none
;-------------------------------------------------------------------------
print_hex:
	xchg	al,ah
	call	print_byte		; print the upper byte
	xchg	al,ah
	call	print_byte		; print the lower byte
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



;byte_to_hex_str
;This function return in AX the ascii code for hexadecimal number from 0 to F
;Parameters:
;               AL = imput
;               AX = output
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


