;=================================
; Edit memory
; Segment address: ES
; Memory  address: bx
;  

p1ltch      equ     0x80
check_sum_error db cr,lf,"checksum errors!",eos
check_sum_ok    db cr,lf,"ok",eos


edit_memory: 
            call    readAddress
            mov     di, bx
edit:            
            call    newLine
            mov     AX, ES
            call    print_hex
            mov     al, ':'
            call    cout
            mov     AX, DI
            call    printw_hex
            call    space
            mov     al, '['
            call    cout
            mov     al, byte es:[di]
            call    printb_hex
            mov     al, ']'
            call    cout
            call    space
            call    readByteHexX
            jnc     edit_memoryEnd
            mov     byte es:[di], al 
            inc     di
            jmp     edit        
edit_memoryEnd:
            mov     AX, CX
            call    printw_hex
            ret


;LOAD FILE 

load_hex db cr, lf, "Load Intel hex file...",eos

load:     mov si, load_hex
          call pstr

          mov al,0
          mov [bcs_error],al

          call get_record
          ret
            
; get record and write to SRAM
;
esc     equ 1bh

get_record: call cin
            cmp al,esc
            jne is_colon?
            ret

is_colon?:  cmp al, ":"
            jne get_record	    ; wait until found begin of record
            xor al, al           
            mov byte es:[bcs],al        ; clear byte check sum
            mov cx, 0		    ; clear counter 
            call get_hex	    ; get number of byte
            mov cl, al		    ; put to cl
            add byte es:[bcs],al        
            call get_hex	    ; get destination address, put to bx register
            mov bh, al           ; save high byte
            add byte es:[bcs],al        
            call get_hex        
            mov bl, al           ; and low byte
            add byte es:[bcs],al        
            call get_hex        
            add byte es:[bcs],al        
            cmp  al,  1           ; end of record type is 01 ?
            jne  data_record    ; jump if not 01

wait_lf:    
            call    cin
            cmp     al,lf
            jne     wait_lf         ; until end of record sending! with lf detection
            mov     al, 0ffh        ; finish loading turn debug led off
            mov     dx, p1ltch
            out     dx, al
            mov     al,byte es:[bcs_error]
            cmp     al,1
            jne     no_error
            mov     si, check_sum_error
            call    pstr
            ret
no_error:   
            mov     si, check_sum_ok
            call    pstr
            ret
data_record: 
            call    get_hex                ; get data byte
            mov     byte es:[bx],al        ; save to SRAM at es:[bx]
            add     byte es:[bcs],al
            inc     bx                     ; next location
            mov     dx, p1ltch             ; light debug led indicates loading is running
            out     dx, al
            loop    data_record            ; until cx = 0
            mov     al, byte es:[bcs]
            neg     al
            mov     byte es:[bcs],al
            call    get_hex                ; get check sum
            cmp     al, byte es:[bcs]
            je      record_correct
            mov     al,1
            mov     byte es:[bcs_error],al ; set byte check sum error flag
record_correct:
            jmp     get_record	; back to next record
