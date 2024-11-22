cpu	8086

%include "macro.inc"

%define	START		0x000		

org	START		


setloc	0E000h

reset:
            
    		cli     ; Clear Interrupts until vectors defined
            cld

        mov ax, 0x0000
        mov es, ax
        mov ss, ax
        mov ax, 0xF000
        mov ds, ax
		mov cs, ax
        ;Put 0x0000 in stack pointer
        xor sp, sp

        mov ax, 0xAA55
        mov word es:[0x0], ax

        xor ax,ax

        mov ax,word es:[0x0] 
        cmp ax, 0xAA55
        jnz  .loop1   

.loop:            
            mov     al, 0x00
            out     0x80, al
            out     0x80, al

            mov     cx, 0xffff
.label01:
            dec     cx
            jnz     .label01
            mov     cx, 0xffff
.label012:
            dec     cx
            jnz     .label012

            mov     al, 0x01
            out     0x80, al
            out     0x80, al

            mov     cx, 0xffff
.label02:
            dec     cx
            jnz     .label02
            mov     cx, 0xffff
.label022:
            dec     cx
            jnz     .label022

            jmp     .loop    


.loop1:            
            mov     al, 0x00
            out     0x80, al
            out     0x80, al

            mov     cx, 0x3fff
.label011:
            dec     cx
            jnz     .label011

            mov     al, 0x01
            out     0x80, al
            out     0x80, al

            mov     cx, 0x3fff
.label021:
            dec     cx
            jnz     .label021

            jmp     .loop1    





            hlt     ;stops cpu    



        setloc	0FFF0h			; Power-On Entry Point, macro fills space from last line with FF
start:
        jmp     0F000h:reset
        setloc	0FFFFh			; Pad remainder of ROM
	      db	0ffh            