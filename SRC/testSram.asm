;-------------------------------------------------------------------------
%define MIN_RAM_SIZE    64              ; At least 32 KiB to boot the system
;-------------------------------------------------------------------------
; Test first 64 KiB (MIN_RAM_SIZE) of RAM
testFirst64kb:
	;mov	al,e_low_ram_test
	;out	post_reg,al
	xor	si,si
	xor	di,di
	mov	ds,di
	mov	es,di

;Inicio da carga do valor de AX
	mov	ax,55AAh		; first test pattern
	mov	cx,MIN_RAM_SIZE*512	; RAM size to test in words
    rep	stosw				; store test pattern
;Fim da carga do valor de AX        
;inicio da comparação    
;lodsw CX=total repetição, SI=Endereço a ser lido AX recebe o dado
	mov	cx,MIN_RAM_SIZE*512	; RAM size to test in words
.1:
	lodsw
	cmp	ax,55AAh		; compare to the test pattern
	jne	low_ram_fail
	loop	.1
;Fim da comparação        
	xor	si,si
	xor	di,di
	mov	ax,0AA55h		; second test pattern
	mov	cx,MIN_RAM_SIZE*512	; RAM size to test in words
    rep stosw				; store test pattern
	mov	cx,MIN_RAM_SIZE*512	; RAM size to test in words
.2:
	lodsw
	cmp	ax,0AA55h		; compare to the test pattern
	jne	low_ram_fail
	loop	.2
	xor	di,di
	xor	ax,ax			; zero
	mov	cx,MIN_RAM_SIZE*512	; RAM size to test in words
    rep stosw				; zero the memory
	jmp	low_ram_ok		; test passed

low_ram_fail:
	;mov	al,e_low_ram_fail	; test failed
	;out	post_reg,al
    jmp     led2blinks

;-------------------------------------------------------------------------
;-------------------------------------------------------------------------
; Low memory test passed

low_ram_ok:
        mov     bx, 0x401
        mov     byte ds:[bx], al
        jmp     initBios

;-------------------------------------------------------------------------
; Test of 64k bytes of memory
; Reg ds = segment to test
;	  es = segment to test
;
test64kb:
	;mov	al,e_low_ram_test
	;out	post_reg,al
	xor	si,si
	xor	di,di

;Inicio da carga do valor de AX
	mov	ax,55AAh		; first test pattern
	mov	cx,MIN_RAM_SIZE*512	; RAM size to test in words
    rep	stosw				; store test pattern
;Fim da carga do valor de AX        
;inicio da comparação    
;lodsw CX=total repetição, SI=Endereço a ser lido AX recebe o dado
	mov	cx,MIN_RAM_SIZE*512	; RAM size to test in words
.1:
	lodsw
	cmp	ax,55AAh		; compare to the test pattern
	jne	low_ram_fail
	loop	.1
;Fim da comparação        
	xor	si,si
	xor	di,di
	mov	ax,0AA55h		; second test pattern
	mov	cx,MIN_RAM_SIZE*512	; RAM size to test in words
    rep stosw				; store test pattern
	mov	cx,MIN_RAM_SIZE*512	; RAM size to test in words
.2:
	lodsw
	cmp	ax,0AA55h		; compare to the test pattern
	jne	low_ram_fail
	loop	.2
	xor	di,di
	xor	ax,ax			; zero
	mov	cx,MIN_RAM_SIZE*512	; RAM size to test in words
    rep stosw				; zero the memory
	jmp	ram_ok		; test passed

;-------------------------------------------------------------------------
;-------------------------------------------------------------------------
; Low memory test passed

ram_ok:
        mov ax, 0xF000
        mov ds, ax
        mov  bx, blocoOK
        call print2

        mov     bx, 0x401
        mov     byte ds:[bx], al
        ret

;-------------------------------------------------------------------------
;  Low memory error: beep - pause - beep - pause ... - 400 Hz
beep:
;	mov	al,0B6h
;	out	pit_ctl_reg,al		; PIT - channel 2 mode 3
;	mov	ax,pic_freq/400		; 400 Hz signal
;	out	pit_ch2_reg,al
;	mov	al,ah
;	out	pit_ch2_reg,al
;	in	al,ppi_pb_reg
;.1:
;	or	al,3			; turn speaker on and enable
;	out	ppi_pb_reg,al		; PIT channel 2 to speaker
;	mov	cx,0
;.2:
;	nop
;	loop	.2
;	and	al,0FCh			; turn of speaker
;	out	ppi_pb_reg,al
;	mov	cx,0
;.3:
;	nop
;	loop	.3
;	jmp	.1
