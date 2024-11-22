cpu	8086

%include "macro.inc"

%define	START		0x000		

org	START		


setloc	0E000h

reset:
            
    		cli     ; Clear Interrupts until vectors defined
            cld
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


            hlt     ;stops cpu    



        setloc	0FFF0h			; Power-On Entry Point, macro fills space from last line with FF
start:
        jmp     0F000h:reset
        setloc	0FFFFh			; Pad remainder of ROM
	      db	0ffh            