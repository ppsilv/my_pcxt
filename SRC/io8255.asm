        ; Paralela 8255     0x060
        ;PPI 99 PortA = input PortB = output PortC = input
        mov AL, 0x99
        out 0x63, AL