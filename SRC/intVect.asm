        CPU 8086
        BITS 16

;--------------------------------------
; System definitions
;--------------------------------------
SYSTEM_STACK_SEG    EQU     0x0000
SYSTEM_BOOT_SEG     EQU     0xf000

init_int_vectors:

        mov word es:[0h*4], default_handler
        mov word es:[0h*4+2], 0F000h

        mov word es:[1h*4], default_handler
        mov word es:[1h*4+2], 0F000h

        mov word es:[2h*4], default_handler
        mov word es:[2h*4+2], 0F000h

        mov word es:[3h*4], default_handler
        mov word es:[3h*4+2], 0F000h

        mov word es:[4h*4], default_handler
        mov word es:[4h*4+2], 0F000h

        mov word es:[5h*4], default_handler
        mov word es:[5h*4+2], 0F000h

        ret
    
;--------------------------------------
; void set_int_vector(uint8_t intNo, void* ptr)
;--------------------------------------
set_int_vector:
        MOV bx, INT_VECT 
        call    print2

        push es
        xor ax, ax
        mov es, ax

        cli

        mov word es:[8h*4], counter0_int_handler
        mov word es:[8h*4+2], 0F000h

        pop es
        ret

default_handler:
        iret


; divide by 0
        DW default_handler
; single step
        DW default_handler
; NMI
        DW default_handler
; breakpoint
        DW default_handler
; overflow
        DW default_handler


; test interrupt handler
;ir0_int_handler:
;        nop
;        push ax
;
;
;        pop ax
;        iret

;ir0_int_handler:
;        nop
;        cli
;        push ax
;        push es
;        xor ax, ax
;        mov es, ax
;
;        mov al, byte es:[mem_led_reg]
;        inc al
;        mov byte es:[mem_led_reg],al
;        out 0x80, al
;        ;mov al, 0b00100000
;        ;out PIC_REG_0, al
;
;        pop es
;        pop ax
;        sti
;        iret        