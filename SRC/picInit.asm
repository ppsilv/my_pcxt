        CPU 8086
        BITS 16


init_system_intr:

        call init_int_vectors

        call pic_init
 
        call pit_init

; set the address of the test handler in the interrupt vector table
        ;call set_int_vector     ; => set_int_vector(8, &ir0_int_handler);

; enable pin IR0 in the PIC
        ;call pic_enable_ir      ; => pic_enable_ir(0);

        sti
        ret




