;-------------------------------------------------------------------------
%define MIN_RAM_SIZE    64              ; At least 32 KiB to boot the system
testMem:        db      0Dh,0Ah,"Testing memory:",0Dh , 0
bloco01:        db      0Dh,0Ah,"10000 to 1FFFF", 0     ;128k
bloco02:        db      0Dh,0Ah,"20000 to 2FFFF", 0     ;192k
bloco03:        db      0Dh,0Ah,"30000 to 3FFFF", 0     ;256k
bloco04:        db      0Dh,0Ah,"40000 to 4FFFF", 0     ;320k
bloco05:        db      0Dh,0Ah,"50000 to 5FFFF", 0     ;384k
bloco06:        db      0Dh,0Ah,"60000 to 6FFFF", 0     ;448k
bloco07:        db      0Dh,0Ah,"70000 to 7FFFF", 0     ;512k
bloco08:        db      0Dh,0Ah,"80000 to 8FFFF", 0     ;640k
bloco09:        db      0Dh,0Ah,"90000 to 9FFFF", 0     ;768k


blocoOK:        db      " segment OK.",0
blocoNOK:       db      " segment DO NOT exist.", 0Dh, 0Ah,0
totalMem:       db      0Dh,0Ah,"Total of memory: ",0
qtdMem0:        db      "064.000 KBytes.", 0Dh, 0Ah, 0
qtdMem1:        db      "131.072 KBytes.", 0Dh, 0Ah, 0
qtdMem2:        db      "196.608 KBytes.", 0Dh, 0Ah, 0
qtdMem3:        db      "262.144 KBytes.", 0Dh, 0Ah, 0
qtdMem4:        db      "327.680 KBytes.", 0Dh, 0Ah, 0
qtdMem5:        db      "393.216 KBytes.", 0Dh, 0Ah, 0
qtdMem6:        db      "458.752 KBytes.", 0Dh, 0Ah, 0
qtdMem7:        db      "524.288 KBytes.", 0Dh, 0Ah, 0
qtdMem8:        db      "655.360 KBytes.", 0Dh, 0Ah, 0
qtdMem9:        db      "786.432 KBytes.", 0Dh, 0Ah, 0


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
	jne	low_ram_fail1
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
	jne	low_ram_fail1
	loop	.2
	xor	di,di
	xor	ax,ax			; zero
	mov	cx,MIN_RAM_SIZE*512	; RAM size to test in words
    rep stosw				; zero the memory
	jmp	ram_ok		; test passed
low_ram_fail1:
	STC 
	ret
;-------------------------------------------------------------------------
;-------------------------------------------------------------------------
; Low memory test passed

ram_ok:
;        mov ax, 0xF000
;        mov ds, ax
;        mov  bx, blocoOK
;        call print2

        mov     bx, 0x401
        mov     byte ds:[bx], al
		CLC
        ret
;I know it could be better but I'm lazy and besides 
;I have a lot of flash memory so don't criticize me

memoryTest:
		push DS
		mov	 ax,0x0
		mov  es, ax
		mov  al,0
		mov  byte es:[flagMemOk], al
		mov  si, testMem
		call pstr

		;Block 1 64K
		mov  si, bloco01
		call pstr
		mov  ax, 0x1000
		mov  ds, ax
		mov  es, ax
		call test64kb
		jc	 memoryTestEnd
		call segmentOK
		mov	 ax,0x0
		mov  es, ax
		inc byte es:[flagMemOk]

		;Block 2 64K
		mov  si, bloco02
		call pstr
		mov  ax, 0x2000
		mov  ds, ax
		mov  es, ax
		call    test64kb
		jc	memoryTestEnd
		call segmentOK
		mov	 ax,0x0
		mov  es, ax
		inc byte es:[flagMemOk]

		;Block 3 64K
		mov  si, bloco03
		call pstr
		mov  ax, 0x3000
		mov  ds, ax
		mov  es, ax
		call    test64kb
		jc	memoryTestEnd
		call segmentOK
		mov	 ax,0x0
		mov  es, ax
		inc byte es:[flagMemOk]

		;Block 4 64K
		mov  si, bloco04
		call pstr
		mov  ax, 0x4000
		mov  ds, ax
		mov  es, ax
		call    test64kb
		jc	memoryTestEnd
		call segmentOK
		mov	 ax,0x0
		mov  es, ax
		inc byte es:[flagMemOk]

		;Block 5 64K
		mov  si, bloco05
		call pstr
		mov  ax, 0x5000
		mov  ds, ax
		mov  es, ax
		call    test64kb
		jc	memoryTestEnd
		call segmentOK
		mov	 ax,0x0
		mov  es, ax
		inc byte es:[flagMemOk]

		;Block 6 64K
		mov  si, bloco06
		call pstr
		mov  ax, 0x6000
		mov  ds, ax
		mov  es, ax
		call    test64kb
		jc	memoryTestEnd
		call segmentOK
		mov	 ax,0x0
		mov  es, ax
		inc byte es:[flagMemOk]

		;Block 7 64K
		mov  si, bloco07
		call pstr
		mov  ax, 0x7000
		mov  ds, ax
		mov  es, ax
		call    test64kb
		jc	memoryTestEnd
		call segmentOK
		mov	 ax,0x0
		mov  es, ax
		inc byte es:[flagMemOk]

		;Block 8 64K
		mov  si, bloco08
		call pstr
		mov  ax, 0x8000
		mov  ds, ax
		mov  es, ax
		call    test64kb
		jc	memoryTestEnd
		call segmentOK
		mov	 ax,0x0
		mov  es, ax
		inc byte es:[flagMemOk]

		;Block 9 64K
		mov  si, bloco09
		call pstr
		mov  ax, 0x9000
		mov  ds, ax
		mov  es, ax
		call    test64kb
		jc	memoryTestEnd
		call segmentOK
		mov	 ax,0x0
		mov  es, ax
		inc byte es:[flagMemOk]


memoryTestEnd:
		pop  	ds
		mov 	ax, 0x0
		mov 	es, ax

		mov		al, byte es:[flagMemOk]
		cmp		al, 7
		jz      onlyTotal

		mov		si, blocoNOK
		call	pstr
onlyTotal:		

		mov		si, totalMem
		call	pstr
		mov     ax, 18
		mov		cl, byte es:[flagMemOk]
		mul		cl
		;call	print_hex
		mov		si, qtdMem0
		add		si, ax
		call 	pstr

		ret
	

segmentOK:
        mov		ax, 0xF000
        mov		ds, ax
        mov		si, blocoOK
        call	pstr
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
