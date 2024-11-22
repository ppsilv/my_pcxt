
cls     db 0x1B,"[2J",0
curpos  db 0x1B,"[!;!H",0

;=====================
; ESC [ 2 J
;
scr_clear:
        mov	bx, cls
        call print2	
        ret
;=====================
; ESC [ Pl ; Pc H
; input:
;	dh = y position
; 	dl = x position
; MARK: scr_goto
scr_goto:
        push DS
        mov AX, 0x0
        mov DS, AX
        mov bx, AX
        mov byte ds:[bx],0x1B
        inc bx
        mov byte ds:[bx],'['
        inc bx
        mov byte ds:[bx],10
        inc bx
        mov byte ds:[bx],';'
        inc bx
        mov byte ds:[bx],10
        inc bx
        mov byte ds:[bx],'H'  
        inc bx
        mov byte ds:[bx],0x0


        mov AX, 0x0
        mov bx, AX
        call print2
        POP DS
		ret

s123 db "fn00",0dh,0
s124 db "fn01",0dh,0
s125 db "fn02",0dh,0
s126 db "fn03",0dh,0
s127 db "fn04",0dh,0
s128 db "fn05",0dh,0

TESTE:
        call printch

        cmp   al, '0'
        jz    .fn00
        cmp   al, '1'
        jz    .fn01
        cmp   al, '2'
        jz    .fn02
        cmp   al, '3'
        jz    .fn03
        cmp   al, '4'
        jz    .fn04
        cmp   al, '5'
        jz    .fn05
        ret        

.fn00: 
        mov  bx, s123
        call print2
        ret
.fn01: 
        mov  bx, s124
        call print2
        ret        
.fn02: 
        mov  bx, s125
        call print2
        ret
.fn03: 
        mov  bx, s126
        call print2
        ret
.fn04:   
        mov  bx, s127
        call print2
        ret
.fn05: 
        mov  bx, s128
        call print2
        ret

        


