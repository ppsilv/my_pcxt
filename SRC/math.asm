

 
subtract:
        mov dl, 00h
        mov ax, word es:[abc]
        mov bx, word es:[def]
        sub ax, bx
        mov word es:[ghi], ax
        mov ax, word es:[abc+2]
        mov bx, word es:[def+2]
        sbb ax, bx
        mov word es:[ghi+2],ax
        jnc move
        inc dl
move: 
        mov byte es:[ghi+4], dl
        int 3
