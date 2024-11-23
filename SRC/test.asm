cpu	8086

%include "macro.inc"

%define	START		0x0000		
%define DATE		'22/11/24'
%define MODEL_BYTE	0FEh		; IBM PC/XT
%define VERSION		'1.0.00'	; BIOS version

org	START		


welcome		db	"XT 8088 BIOS, Version "
		db	VERSION
		db	". ", 0Dh
		db	"Paulo Silva(pgordao) - Copyright (C) 2024", 0Dh
		db	"CPU 8088-2   board: 8088BOAD2447-RA  ", 0Dh
		db	"8088 MonitorV0 V ",VERSION ," 2447A 512 Sram Rom at29C512", 0Dh
                db      0dh,"A total of 64k minimum are ok..", 0Dh, 0

testMem:        db      "Testing memory:",0Dh , 0
bloco01:        db      "10000 to 1FFFF", 0     ;128k
bloco02:        db      "20000 to 2FFFF", 0     ;192k
bloco03:        db      "30000 to 3FFFF", 0     ;256k
bloco04:        db      "40000 to 4FFFF", 0     ;320k
bloco05:        db      "50000 to 5FFFF", 0     ;384k
bloco06:        db      "60000 to 6FFFF", 0     ;448k
bloco07:        db      "70000 to 7FFFF", 0     ;512k
blocoOK:        db      " segment OK", 0Dh, 0
totalMem:       db      "Total of memory: ",0
qtdMem1:        db      "131.072 KBytes.", 0Dh, 0
qtdMem2:        db      "196.608 KBytes.", 0Dh, 0
qtdMem3:        db      "262.144 KBytes.", 0Dh, 0
qtdMem4:        db      "327.680 KBytes.", 0Dh, 0
qtdMem5:        db      "393.216 KBytes.", 0Dh, 0
qtdMem6:        db      "458.752 KBytes.", 0Dh, 0
qtdMem7:        db      "524.288 KBytes.", 0Dh, 0


setloc	0E000h
reset:
                cli
    		mov ax,0x40
    		mov ds,ax
		mov word [0x72],0x0
    		xor ax,ax
    		jc l0xb3
    		jo l0xb3
    		js l0xb3
    		jnz l0xb3
    		jpo l0xb3
    		add ax,0x1
    		jz l0xb3
    		jpe l0xb3
    		sub ax,0x8002
    		js l0xb3
    		inc ax
    		jno l0xb3
    		shl ax,1
    		jnc l0xb3
    		jnz l0xb3
    		shl ax,1
    		jc l0xb3   
    		mov bx,0x5555
l0x8f:    	mov bp,bx
    		mov cx,bp
    		mov sp,cx
    		mov dx,sp
    		mov ss,dx
    		mov si,ss
    		mov es,si
    		mov di,es
    		mov ds,di
    		mov ax,ds
    		cmp ax,0x5555
    		jnz l0xae
    		not ax
    		mov bx,ax
    		jmp short l0x8f
l0xae: 		xor ax,0xaaaa
    		jz l0xb4
l0xb3: 		jmp led3blinks
l0xb4: 		cld                     
                ;Verify if the board has at least 32kbytes of RAM
                jmp testFirst64kb

initBios:
        mov ax, 0x0000
        mov es, ax
        mov ss, ax                  ; Segmento Stack
        mov ax, 0xF000
        mov ds, ax
	mov cs, ax
        ;Put 0x8000 in stack pointer top of the first 32kbytes of mem
        xor sp, sp          ;The minimum of 64k of ram are OK.
        xor ax, ax              ; Put flags in known state
        PUSH AX
        POPF
        MOV SP,AX    

   
;******************************************************
; END INITIALIZATION
;======================================================
;PUT MAIN CODE HERE
		call configure_uart

		call scr_clear
		mov  bx, welcome
		call print2
		mov  bx, testMem
		call print2
		mov  bx, bloco01
		call print2
		mov  ax, 0x1000
		mov  ds, ax
		mov  es, ax
		call    test64kb
		mov ax, 0xF000
		mov ds, ax
		mov  bx, qtdMem1
		call print2
		jmp ledblinkOk

%include "DRV16C550_8088.asm"
%include "screen.asm"
%include "errorLed.asm"
%include "testSram.asm"

        setloc	0FFF0h			; Power-On Entry Point, macro fills space from last line with FF
start:
        jmp     0F000h:reset
        setloc	0FFFFh			; Pad remainder of ROM
	      db	0ffh            