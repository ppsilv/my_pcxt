        CPU 8086
        BITS 16


init_system:

        call pic_init
 
        call pit_init

        sti
        ret




