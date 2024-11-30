        CPU 8086
        BITS 16


SYSTEM_CPU_CLK      EQU     4771000    ; this is the CPU clk (1/3 of the used crystal)
SYSTEM_PCLK         EQU     (SYSTEM_CPU_CLK / 2) ; PCLK from 8284 is half the rate of the CPU clk
;--------------------------------------
; PIT (8254)
;--------------------------------------
PIT_COUNTER_0       EQU     0x40
PIT_COUNTER_1       EQU     0x41
PIT_COUNTER_2       EQU     0x42
PIT_CTRL_REG        EQU     0x43

PIT_COUNTER0_INT    EQU     (PIC_INT_VEC + 0)
SYSTEM_TICKS_SEC    EQU     100         ; 100 ticks per second = 100Hz

;--------------------------------------
; void pit_init(void)
;--------------------------------------
pit_init:
        pushf
        cli
        mov al, 0b00110110      ; Counter 0, binary, mode 3, write both bytes
        out PIT_CTRL_REG, al

        mov ax, ((SYSTEM_PCLK + (SYSTEM_TICKS_SEC / 2)) / SYSTEM_TICKS_SEC) ; set system tick counter
        out PIT_COUNTER_0, al
        xchg ah, al
        out PIT_COUNTER_0, al

        ;mov ax, counter0_int_handler
        ;push ax
        ;mov al, PIT_COUNTER0_INT
        ;push ax
        call set_int_vector     ; => set_int_vector(PIT_COUNTER0_INT, &counter0_int_handler);
        ;add sp, 4

; enable pin IR0 in the PIC
        xor ax, ax
        push ax
        call pic_enable_ir      ; => pic_enable_ir(0);
        add sp, 2

        popf
        ret

;--------------------------------------
; uint32_t get_sys_ticks(void)
;--------------------------------------
get_sys_ticks:
        pushf
        cli
        mov ax, word es:[sys_tick_count]
        mov dx, word es:[sys_tick_count + 2]
        popf
        ret

;--------------------------------------
counter0_int_handler:
        push ES
        push AX
        xor AX, AX
        mov ES, AX
        inc word es:[sys_tick_count]
        jnz .1
        inc word es:[sys_tick_count + 2]
.1:
        pic_eoi_cmd
        pop AX
        pop ES
        iret

;--------------------------------------


