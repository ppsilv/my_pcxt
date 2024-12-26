cpu	8086

%include "macros.inc"
%include "vars.inc"

%define	START		0x0000		
%define DATE		'22/11/24'
%define MODEL_BYTE	0FEh		; IBM PC/XT
%define VERSION		'1.0.00'	; BIOS version

org	START		


welcome		db	cr,lf,"XT 8088 BIOS, Version ",VERSION
			db	cr,lf,"Paulo Silva(pgordao) - Copyright (C) 2024"
			db	cr,lf,"CPU 8088-2   board: 8088BOAD2447-RA  "
			db	cr,lf,"8088 MonitorV0 V ",VERSION ," 2447A 512 Sram Rom at29C512"
			db  cr,lf,"A total of 64k minimum are ok..", eos
biosloaded	db  cr,lf,"Bios loaded...", eos
help_msg	db cr,lf,"=========================="
			db cr,lf,"cmd   description"
			db cr,lf," b    read boot loader"
			db cr,lf," d    dump memory using ES"
			db cr,lf," e    edit memory "
			db cr,lf," f    fill memory "
			db cr,lf," l    load intel hex file"
			db cr,lf," p    write 16-bit data to onchip peripherals"
			db cr,lf," o    output byte to output port"
			db cr,lf," i    input byte from input port"
			db cr,lf," s    read sector 1"
			db cr,lf," W    write sector "
			db cr,lf," w    write sector 1"
			db cr,lf," t    show systick"
			db cr,lf," h    for this help", cr, lf, eos

setloc	0D000h
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
		mov	al, 0x0
		mov byte es:[mem_led_reg],al
   
;******************************************************
; END INITIALIZATION
;======================================================
;PUT MAIN CODE HERE
		call configure_uart

		call scr_clear
		mov  si, welcome
		call pstr

		call memoryTest

		call init_system
        mov al,0x0
        mov byte es:[mem_led_reg],al
		;Checking cpu type
		call cpu_check
		;Loading bios 
		call BiosLoad
		mov	 BX, biosloaded
		mov	 Ah, 0x10
		INT	 0x10
Mainloop:
		call	printPrompt
		call	cin_blct
		call	cout
		cmp		al, 'b'
		je 		bootRecord
		cmp		al, 'd'
		je 		show_dump
		cmp		al, 'e'
		je		editmemory
		cmp		al, 'f'
		je		fillMemory
		cmp		al, 'l'
		je		ldIntelHex
		cmp		al, 'h'
		je 		show_help_msg
		cmp		al, 'j'
		je 		jump
		cmp		al, 's'
		je 		readSector1
		cmp		al, 'W'
		je 		writeSector
		cmp		al, 'w'
		je 		writeSector1
		cmp		al, 't'
		je 		show_systic
		cmp		al, 'r'
		je 		show_reg
		cmp		al, 'q'
		je 		writePeripherals
		cmp		al, 'o'
		je 		outByte
		cmp		al, 'i'
		je 		inByte


		;CALL	newLine
		jmp 	Mainloop	
jump:
	jmp	jump01	
	jmp 	Mainloop	
bootRecord:
		call 	BOOT_DRIVE		
		call	newLine
		jmp 	Mainloop	
readSector1:		
	MOV AX, 0X07C0 	;0X07C0:0X0000
	MOV ES, AX		;ES:BX = ADDRESS BUFFER
	MOV AX, 0X0201	;READ ONE SECTOR
	MOV BX, 0X0000	;ES:BX = ADDRESS BUFFER
	MOV CX, 0X0001	;1 SECTOR
	MOV DX, 0X0081	;DRIVE TO BOOT UP 0=A, 80=C

		call	printPrompt
		call	cin_blct
		call	cout
		call 	to_hex
		mov		cl, al
	MOV AX, 0X07C0 	;0X07C0:0X0000
	MOV ES, AX		;ES:BX = ADDRESS BUFFER
	MOV AX, 0X0201	;READ ONE SECTOR
	MOV BX, 0X0000	;ES:BX = ADDRESS BUFFER
	MOV CH, 0X00	;
	MOV DX, 0X0081	;DRIVE TO BOOT UP 0=A, 80=C
	INT 0X13		;INT 13
		call	newLine
		jmp 	Mainloop	
;AH = 03h
;AL = number of sectors to read (must be nonzero)
;CH = low eight bits of cylinder number
;CL = sector number 1-63 (bits 0-5)
;high two bits of cylinder (bits 6-7, hard disk only)
;DH = head number
;DL = drive number (bit 7 set for hard disk)
;ES:BX -> data buffer		
writeSector:		
		MOV AX, 0X07C0 	;0X07C0:0X0000
		MOV ES, AX		;ES:BX = ADDRESS BUFFER
		MOV AX, 0X0301	;WRITE ONE SECTOR
		MOV BX, 0x0 	;ES:BX = ADDRESS BUFFER
		MOV CX, 0X0001	;1 SECTOR
		MOV DX, 0X0081	;DRIVE TO BOOT UP 0=A, 80=C
		INT 0X13		;INT 13
		call	newLine
		jmp 	Mainloop	
writeSector1:		
		MOV AX, 0XF000 	;0X07C0:0X0000
		MOV ES, AX		;ES:BX = ADDRESS BUFFER
		MOV AX, 0X0301	;READ ONE SECTOR
		MOV BX, sector1	;ES:BX = ADDRESS BUFFER
		MOV CX, 0X0001	;1 SECTOR
		MOV DX, 0X0081	;DRIVE TO BOOT UP 0=A, 80=C
		INT 0X13		;INT 13
		call	newLine
		jmp 	Mainloop	
fillMemory:		
		call 	fill_memory
		call	newLine
		jmp 	Mainloop	
ldIntelHex:		
		call 	load_intel_hex
		call	newLine
		jmp 	Mainloop	
writePeripherals:
		call 	write_peripherals
		call	newLine
		jmp 	Mainloop	
outByte:
		call 	outbyte
		call	newLine
		jmp 	Mainloop	
inByte:		
		call	inbyte
		call	newLine
		jmp 	Mainloop	
show_reg:
		mov	AX, 0x1234
		call	print_hex
		call	newLine
		jmp 	Mainloop		
show_dump:
		call	dump
		call	newLine
		jmp 	Mainloop	
editmemory:			
		call	edit_memory
		call	newLine
		jmp 	Mainloop	
show_systic:
		call    get_sys_ticks
		push	AX
		mov		AX, DX
		call	print_hex
		pop		AX
		call	print_hex
		call	newLine
		jmp 	Mainloop		
show_help_msg:
		mov		si, help_msg
		call 	pstr
		jmp 	Mainloop


%include "DRV16C550.asm"
%include "DRVCH376S.asm"
;%include "DRVch376s2.asm"

%include "screen.asm"
%include "errorLed.asm"
%include "testSram.asm"
%include "mprintRegs.asm"
%include "mHardwareInit.asm"
%include "mpic8259A.asm"
%include "mpit8254.asm"
%include "mmath.asm"
%include "mmemoryDump.asm"
%include "meditMemory.asm"
%include "minputs.asm"
;===========================
%include "code/bios.asm"

        setloc	0FFF0h			; Power-On Entry Point, macro fills space from last line with FF
start:
        jmp     0F000h:reset
        setloc	0FFFFh			; Pad remainder of ROM
	      db	086h            
