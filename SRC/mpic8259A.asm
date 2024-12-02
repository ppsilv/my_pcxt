        CPU 8086
        BITS 16

        
;--------------------------------------
; PIC (8259)
;--------------------------------------
PIC_REG_0           EQU     0x20
PIC_REG_1           EQU     0x21
PIC_ISR             EQU     0x20
PIC_IRR             EQU     0x20
PIC_IMR             EQU     0x21
PIC_INT_VEC         EQU     0x08

;PIC_INIT        db 0Dh,0Ah,"pc_init: init",0Dh, 0
;INIT_IRQ        db 0Dh,0Ah,"pic_enable_ir: init",0Dh, 0
;INT_VECT        db 0Dh,0Ah,"set_int_vector: init",0Dh, 0

;--------------------------------------
; void pic_init(void)
;--------------------------------------
pic_init:
        ;mov     si, PIC_INIT 
        ;call    pstr
        pushf
        cli
        mov al, 0b00010111      ; ICW1
        out PIC_REG_0, al
        mov al, (PIC_INT_VEC & 0b11111000)  ; ICW2
        out PIC_REG_1, al
        ;Precisa de codigo para informar ao 8259 o termino da interrupção
        ;mov al, 0b00000001      ; ICW4
        ;Não precisa de codigo para informar ao 8259 o termino da interrupção
        mov al, 0b00000011      ; ICW4
        out PIC_REG_1, al

        mov al, 0b11111111      ; mask all interrupts
        out PIC_IMR, al

        mov al, 0b00001000
        out PIC_REG_0, al

        popf
        ret

;--------------------------------------
; void pic_disable_ir(uint8_t irNo)
;--------------------------------------
pic_disable_ir:
        pushf
        cli

        mov bx, sp
        mov cl, 8 ;[bx + 2]
        and cl, 0b00000111
        mov ah, 1
        shl ah, cl
        in al, PIC_IMR
        or al, ah
        out PIC_IMR, al

        popf
        ret

;--------------------------------------
; void pic_enable_ir(uint8_t irNo)
;--------------------------------------
pic_enable_ir:
        ;mov     si, INIT_IRQ 
        ;call    pstr

        pushf
        cli
        mov al, 0FEh
        out PIC_IMR, al
        in al, PIC_IMR
        ;call print_hex

        popf
        ret

%include "intVect.asm"
%include "picInit.asm"

;#1 tentar testar sem ter terminado wireup de I/0 RD WR e dados no barramento
;#2 negligenciar o pino de CS na hora de ligá-lo ao 74138 pois fiz uma gambeta
;   para que o mesmo 74138 pudesse atuar com endereços 0x20 e 0x40
;#3 negligenciar a forma de habilitar a interrupção na função pic_enable_ir
;#4 A chave conectada ao pino da interrupção com certeza dava problemas pois
;   foi tirar a chave e colocar o 8253 fazendo a interrupção que todos os
;   probremas de reset acabaram.