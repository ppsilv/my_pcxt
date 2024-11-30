
ledblinkOk:
.loop0:
          
                mov     al, 0x01
                out     0x80, al
                mov     cx, 0x3fff
.label01:
                dec     cx
                jnz     .label01
                mov     al, 0x00
                out     0x80, al
                mov     cx, 0x7fff
.label02:
                dec     cx
                jnz     .label02
                ret      

led2blinks:
.loop0:
                mov     bx, 3
.loop:            
                mov     al, 0x01
                out     0x80, al
                mov     cx, 0xffff
.label01:
                dec     cx
                jnz     .label01
                mov     al, 0x00
                out     0x80, al
                mov     cx, 0xffff
.label02:
                dec     cx
                jnz     .label02

                dec     bx
                jnz     .loop
;                mov     al, 0x01
;                out     0x80, al
                
                mov     bx, 5
.longDelay:                
                mov     cx, 0xffff
.labelLD:
                dec     cx
                jnz     .labelLD
                dec     bx
                jnz     .longDelay
                ;mov     bx, 3 
                jmp     .loop0         

led3blinks:
.loop0:
                mov     bx, 3
.loop:            
                mov     al, 0x01
                out     0x80, al
                mov     cx, 0xffff
.label01:
                dec     cx
                jnz     .label01
                mov     al, 0x00
                out     0x80, al
                mov     cx, 0xffff
.label02:
                dec     cx
                jnz     .label02

                dec     bx
                jnz     .loop
;                mov     al, 0x01
;                out     0x80, al
                
                mov     bx, 5
.longDelay:                
                mov     cx, 0xffff
.labelLD:
                dec     cx
                jnz     .labelLD
                dec     bx
                jnz     .longDelay
                ;mov     bx, 3 
                jmp     .loop0         

led4blinks:
.loop0:
                mov     bx, 4
.loop:            
                mov     al, 0x01
                out     0x80, al
                mov     cx, 0xffff
.label01:
                dec     cx
                jnz     .label01
                mov     al, 0x00
                out     0x80, al
                mov     cx, 0xffff
.label02:
                dec     cx
                jnz     .label02

                dec     bx
                jnz     .loop
;                mov     al, 0x01
;                out     0x80, al
                
                mov     bx, 5
.longDelay:                
                mov     cx, 0xffff
.labelLD:
                dec     cx
                jnz     .labelLD
                dec     bx
                jnz     .longDelay
                ;mov     bx, 3 
                jmp     .loop0         
