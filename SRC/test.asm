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
		db	"8088 MonitorV0 V ",VERSION ," 2447A 512 Sram Rom at29C512", 0Dh, 0

setloc	0E000h
reset:
            
        mov ax, 0x0000
        mov es, ax
        mov ax, 0x0000                  ; Segmento Stack
        mov ss, ax
        mov ax, 0xF000
        mov ds, ax
		mov cs, ax
        ;Put 0x0000 in stack pointer
        xor sp, sp
    
        ; Add Flags, IP and CS to stack after reset as DisplayRegisters may get confused before INT3 or NMI?
        xor ax, ax  ; Put flags in known state
        PUSH AX
        POPF
        MOV SP,AX    

        ;STI
;******************************************************
; END INITIALIZATION
;======================================================
;PUT MAIN CODE HERE

	call configure_uart
        
        call scr_clear
        mov  bx, welcome
        call print2

.loop:            
            mov     al, 0x00
            out     0x80, al
            out     0x80, al

            mov     cx, 0x7fff
.label01:
            dec     cx
            jnz     .label01

            mov     al, 0x01
            out     0x80, al
            out     0x80, al

            mov     cx, 0x7fff
.label02:
            dec     cx
            jnz     .label02

            jmp     .loop            
   

%include "DRV16C550_8088.asm"
%include "screen.asm"


        setloc	0FFF0h			; Power-On Entry Point, macro fills space from last line with FF
start:
        jmp     0F000h:reset
        setloc	0FFFFh			; Pad remainder of ROM
	      db	0ffh            