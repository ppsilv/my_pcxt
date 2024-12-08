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

        call init8253

        call set_int_vector     ; => set_int_vector(PIT_COUNTER0_INT, &counter0_int_handler);

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
        mov AX, 0x0040
        mov ES, AX
        MOV BX, 0x006C			;SET BX TO TICK COUNTER
        mov ax, word es:[BX]
        mov dx, word es:[BX + 2]
        sti
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
; void set_int_vector(uint8_t intNo, void* ptr)
;--------------------------------------
set_int_vector:
        ;MOV si, INT_VECT 
        ;call    pstr

        push es
        xor ax, ax
        mov es, ax

        cli

        mov word es:[8h*4], INT08
        mov word es:[8h*4+2], 0F000h

        pop es
        ret
myInit8253:
        mov al, 0b00110110      ; Counter 0, binary, mode 3, write both bytes
        out PIT_CTRL_REG, al

        mov ax, ((SYSTEM_PCLK + (SYSTEM_TICKS_SEC / 2)) / SYSTEM_TICKS_SEC) ; set system tick counter
        out PIT_COUNTER_0, al
        xchg ah, al
        out PIT_COUNTER_0, al
        ret

init8253:

	PUSH AX
	PUSH CX

	MOV AL, 0X36 		;00110110b  
			        ;CHANNEL 0
			        ;WRITE LOW BYTE THEN HIGH BYTE
			        ;MODE 3 
			        ;16 BIT COUNTER 
			
	OUT 0X43, AL		;CONTROL REG

	MOV CX, 0XFFFF		;COUNT 

	MOV AL, CL		;WRITE LOW BYTE OF COUNT
	OUT 0X40, AL		;PORT 0X40 ;INTERNAL FLIP-FLOP INC
			
	MOV AL, CH		;WRITE HIGH BYTE OF COUNT 
	OUT 0X40, AL		;PORT 040

	;;;;;;;;;;;
	;TEST TONE
	;;;;;;;;;;;
	MOV AL, 0X03		;ENABLE SPK AND TIMMER 2 'GO'
	OUT 0X61, AL		;PORT 0X61 CONTROL PORT
	MOV AL, 0XB6
	OUT 0X43, AL
	MOV AL, 0X00
	OUT 0X42, AL
	MOV AL, 0X05
	OUT 0X42, AL

	POP CX
	POP AX

	RET