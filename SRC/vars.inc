flagMemOk		    equ		0401h ;This location has 0 if memory block ok other wise has 1

mem_led_reg         equ     0x0501  ;Led status register
mem_timeout01       equ     0x0502  ;Timer timeout value Ex.: 5 seconds
mem_timer01         equ     0x0503  ;dw Timer atual value plus timeout Ex 1000 + 5 seconds 

inline_buffer       equ     0x050F  ;buffer 128 bytes
buff_read           equ     0x050F  ;buffer 128 bytes
buff_write          equ     0x058F  ;buffer 128 bytes
abc                 equ     0x060F  ;dd 9ABCDEF0h
def                 equ     0x0614  ;dd 12345678h
ghi                 equ     0x0618  ;dw ?
sys_tick_count      equ     0x006C  ;dw system tick
bcs                 equ     0x061E  ;db byte check sum
bcs_error           equ     0x061F    ; byte check sum = 1 error
user_ds     dw 2
user_es     dw 2
user_ss     dw 2
user_sp     dw 2

bs                  equ     8
