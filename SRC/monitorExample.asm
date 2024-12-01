; boot.asm
; bootstrap code for 80C186EB
;
; The reset vector is 0FFFF0h!
;
; Copyright (c) 2004 WICHIT SIRICHOTE email: kswichit@kmitl.ac.th
; 
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
;
; After setup segment registers, UCS# and LCS#, the binary image named
; "186bug.img" will be read and write to SRAM start at location 100h.
; The size of image can change for your application.
; when finish, it will jump to location 00100h in SRAM!
; Now I testd with 32kBx2 or 64kB, the high location from FFF00-FFFFF stores
; the bootstarp code. So it will leave space approx. 64kB for applications image!
; Since the SRAM is 256kB, for bigger image, you may try with bigger FLASH or
; develop another channel to provide image loading, say through expansion bus!
;
; d:\c32\c32 boot.asm -h boot.bin -l boot.lst
; d:\c32\split2 boot.bin             ; split BIN file into EVN and ODD files


           CPU     "8086.TBL"      ; CPU TABLE
           HOF     "INT8"         ; HEX OUTPUT FORMAT
	   INCL "ecpcb.inc"
	
extra_segment equ 0F000h        ; extra segment was used for image reading
                                ; test with 32kB x2
                                ; need change for bigger FLASH
                                ; see the UCS# map


stack_segment equ 7000h         ; may need to change for your RAM
top_of_stack  equ 0f000h       ; top of stack is 7F000H!
                               ; 512kB SRAM locates at 0x00000-0x7FFFF!

system_ram    equ 0f000h       ; 0f000h page 0!
gpio1         equ 3000h        ; location of gpio1 for boot running



        ; data segment

         org system_ram

inline_buffer dfs 128   ; inline buffer 128 bytes

sram_pointer dfs 2      ; 16-bit pointer
bcs        dfs 1        ; byte check sum
bcs_error  dfs 1        ; byte check sum = 1 error
user_flags  dfs 2
USER_IP     dfs 2
USER_CS     dfs 2
user_ds     dfs 2
user_es     dfs 2
user_ss     dfs 2
user_sp     dfs 2


user_ax     dfs 2
user_bx     dfs 2
user_cx     dfs 2
user_dx     dfs 2
user_bp     dfs 2
user_si     dfs 2
user_di     dfs 2

long_i     dfs 4        ; general 32-bit counter
long_j     dfs 4
long_k     dfs 4



           org 0e000h

start:  mov cx,40000
        loop $

        CLI                             ; DISABLE INTERRUPTS
	XOR     AX, AX                  ; CLEAR AX
	MOV     SI, AX                  ; CLEAR SI
	MOV     DI, AX                  ; CLEAR DI

; SET UP SEGMENT REGISTERS.  STACK AND DATA SEGMENTS ARE THE SAME FOR RISM.

	MOV     AX, 0000h		; data segment 
	MOV     DS, AX                  ; LOAD DATA SEGMENT

        MOV     ES, AX

        MOV     AX, stack_segment
        MOV     SS, AX                  ; LOAD STACK SEGMENT


;  SET UP CHIP SELECTS
;
;  UCS#  - EPROM ACCESS
;  LCS#  - SRAM  ACEESS


	MOV     DX, UCSSP               ; FINISH SETTING UP UCS#
	MOV     AX, 000eh		; set ISTOP for 0FFFFF ending loaction
	OUT     DX, AL                  ; REMEMBER, BYTE WRITE WORK OK


        MOV     DX, LCSST               ; SET UP LCS START REGISTER
	MOV     AX, 0000H               ; LCS STARTS AT 0H, ZERO WAIT STATES!
	OUT     DX, AL                  ; REMEMBER, BYTE WRITES WORK OK
        
; THE STOP VALUE MUST BE DETERMINED. IT IS POSSIBLE THAT 128K
; HAS BEEN INSTALLED IN THE SRAM SCOKETS...
        
        
        MOV     DX, LCSSP               ; SET UP LCS STOP REGISTER
        MOV     AX, 800AH               ; 512kB Installed (628512)
	OUT     DX, AL                  ; REMEMBER, BYTE WRITES WORK OK

; ENABLE CHIP SELECT FOR ONBOARD I/O USING GCS6#
; START 0X3000 TO 0X3FFF I/O CYCLE

        MOV     DX, GCS6ST
        MOV     AX, 300AH               ; INSERT 10 WAIT STATES
        OUT     DX, AX                  ; for low speed i/o

        MOV     DX,GCS6SP
        MOV     AX, 4009H               ; 0x3000-x3FFFF for GCS6
        OUT     DX, AX


; SET P1.7 TO BE ONE BIT OUTPUT PORT 
; THE REST ARE GPCS

main:	MOV DX,P1CON
	MOV AL,01111111B	; P1.7 is for debug LED, clear to make it on.
	OUT DX,AL
        mov al,0
        mov dx,p1ltch
        out dx,al              ; light led to indicate booting...

           cli
           xor ax,ax
           mov si,ax
           mov di,ax

           mov ax,top_of_stack    ; set top of stack
           mov sp,ax

; FILL INTERRUPT VECTORS TO POINT TO UNWANTED INTERRUPT SO THAT STRAY
; INTERRUPTS DO NOT CAUSE THE BOARD HANG


	MOV     DI, 0                   ; START AT 0 (ASSUMES DS IS SET UP)
	MOV     CX, 256                 ; DO 256 TIMES
FILL_A:
        MOV     word ptr [DI], UNWANTED_INT
	ADD     DI, 4                   ; FILL OFFSETS
	LOOP    FILL_A

	MOV     DI, 2                   ; START AT 2
	MOV     CX, 256                 ; DO 256 TIMES
FILL_B:
        MOV     word ptr [DI], 0000h
	ADD     DI, 4                   ; FILL SEGMENTS
	LOOP    FILL_B



; write interrupt vector for INT 21H service

           mov di,4*21h
           mov si, int21_service
           mov [di], si
           mov ax,cs
           mov [di+2], ax

           call clr_sram
           call serial_init     ; init serial port 9600 8n1 8-data bit

           mov dx,s0sts
           mov al,8
           out dx,al


           mov al, 0ffh        ; turn debug led off
           mov dx,p1ltch
           out dx,al

; if user press key4 then skip checking location 400h
; if not check location 400, if there is EA byte then jump to application
; program at 400h

           mov dx,gpio1
           in al,dx
           and al,80h
           jz  skip_checkEA

           mov al,[400h]
           cmp al,0EAh
           jnz main0

           mov si,boot
           call pstr

           JMP  FAR PTR 400h,0000h ; jump to start



skip_checkEA: mov [400h],al  ; clear byte EA to prevent auto run

main0:     mov si,title
           call pstr


main1:     call send_prompt
           call cins
           call cout              ; echo to screen

           cmp al,cr
           jne check1
           call key_enter

check1:    cmp al,"d"
           jne check2
           call dump

check2:    cmp al,"v"
           jne check3
           call ver

check3:    cmp al,"l"
           jne check4
           call load

check4:    cmp al,"s"
           jne check5
           call string

check5:    cmp al,"?"
           jne check6
           call help

check6:    cmp al,"f"
           jne check7
           call fill

check7:    cmp al,"j"
           jne check8
           call jump

check8:    cmp al,"r"
           jne check9
           call user_registers

check9:    cmp al,"c"
           jne check10
           mov si,restart
           call pstr
           jmp main

check10:   cmp al,"u"
           jne check11
           call upload_image

check11:   cmp al,"e"
           jne check12
           call edit_memory


check12:   cmp al,"w"
           jne check13
           call write_peripherals

check13:   cmp al,"p"
           jne check14
           call print_peripheral

check14:   cmp al,"o"
           jne check15
           call outbyte

check15:   cmp al,"i"
           jne check16
           call inbyte

check16:

           jmp main1


;*************************************************************************

key_enter: mov si,title
           call pstr
           ret

ver:       mov si,version
           call pstr
           ret

dump:      call dump_memory
           ret

;************************************************************************
; init built-in serial port for console interfacing
; use cpu clock and compare register to produce baud clock
; format: 10-bit asynchronous 9600 8n1 serial port 0
;

serial_init: 
	    
        mov ax,8067h    ; 9600 @16MHz
;       mov ax,8019h    ; 38400 @16MHz
	mov dx,B0CMP
	out dx,ax 
	mov ax,0021H     ; mode 1 asynchronous 10-bit
	mov dx,S0CON
	out dx,ax
	ret

; send 8-bit character in al to terminal
; entry: al

cout:	push ax
	mov dx,S0STS
	
cout1:	in  al,dx
	test al,8	; test TXE
	jz cout1	; wait until TXE = 1
	
	pop ax
    mov dx,S0TBUF
	out dx,al
	ret

; receive character from terminal
; exit: al = data received
;       al = -1 no data received

cin:
        mov     dx, S0STS
	    in      al, dx
	    test    al, 40h
	    jnz     cin1
	    mov     al,-1
	    ret
cin1:   
        mov     dx, S0RBUF
	    in      al, dx
	    ret

; cins wait until get character

cins:	call cin
	cmp al,-1
	je  cins
	ret

; cins1 wait until get character and echo to screen

cins1:   call cin
	cmp al,-1
        je  cins1
        call cout
	ret


; send string to terminal
; entry: si

eos	equ 0
cr	equ 13
lf	equ 10

pstr:    seg cs          ; override data segment for SI
         mov al,[si]
	 cmp al,eos
         jnz pstr1
	 ret

pstr1:
	 call cout
	 inc si
         jmp pstr

send_prompt: mov si,prompt
         call pstr
         ret

; print hex
; entry: al

out1x:       push ax
	     and al,0fh
	     add al,"0"
	     cmp al,"9"
             jle out1x1     ; if al less than or equal 39h then print it
             add al,7       ; else add with 7

out1x1:	     call cout
	     pop ax
	     ret
	     
out2x:       push cx
             mov cl,4
             ror al,cl     ; rotate right four bits
	     call out1x
             rol al,cl     ; rotate left four bits
	     call out1x
             pop cx
	     ret

out4x:       push ax
             xchg ah,al
             call out2x
             pop ax
             call out2x
             ret


            
space:       mov al," "
	     call cout
	     ret

newline:    mov al,cr
	    call cout
	    mov al,lf
	    call cout
	    ret


; convert ASCII letter to one nibble 0-F
; 0-9 -> al-30
; A-F -> al-7
; entry: al
; exit: al

to_hex:  sub al,"0"
         cmp al,10
	 jl zero_nine
         and al,11011111b
	 sub al,7
zero_nine: ret
	
; read two ASCII bytes and convert them to one bye 8-bit data
; exit: al

get_hex: call cins
	 call to_hex
	 rol al,1
	 rol al,1
	 rol al,1
	 rol al,1
	 mov ah,al
	 call cins
	 call to_hex
	 add al,ah
	 ret

; read two ASCII bytes and convert them to one bye 8-bit data
; exit: al

get_hex1: call cins1
	 call to_hex
	 rol al,1
	 rol al,1
	 rol al,1
	 rol al,1
	 mov ah,al
         call cins1
	 call to_hex
	 add al,ah
	 ret

; get record and write to SRAM
;

esc     equ 1bh

get_record: call cins
            cmp al,esc
            jne is_colon?
            ret

is_colon?:  cmp al,":"
	    jne get_record	; wait until found begin of record

            xor al,al
            mov [bcs],al         ; clear byte check sum

	    mov cx,0		; clear counter 
	    call get_hex	; get number of byte
	    mov cl,al		; put to cl

            add [bcs],al

	    call get_hex	; get destination address, put to bx register
            mov bh,al           ; save high byte

            add [bcs],al


            call get_hex
            mov bl,al           ; and low byte

            add [bcs],al

	    call get_hex
            add [bcs],al

            cmp  al,1           ; end of record type is 01 ?
            jne  data_record    ; jump if not 01

wait_lf:    call cin
            cmp al,lf
            jne wait_lf     ; until end of record sending! with lf detection


            mov  al,0ffh        ; finish loading turn debug led off
            mov  dx,p1ltch
            out  dx,al

            mov al,[bcs_error]
            cmp al,1
            jne no_error

            mov si,check_sum_error
            call pstr
            ret

no_error:   mov si,check_sum_ok
            call pstr
            ret

data_record: call get_hex       ; get data byte
            mov [bx],al         ; save to SRAM at ds:[bx]

            add [bcs],al

            inc bx              ; next location

            mov dx,p1ltch       ; light debug led indicates loading is running
	    out dx,al

	    loop data_record    ; until cx = 0

            mov al,[bcs]
            neg al
            mov [bcs],al
            call get_hex        ; get check sum

            cmp al,[bcs]

            je  record_correct

            mov al,1
            mov [bcs_error],al    ; set byte check sum error flag

record_correct:

            jmp get_record	; back to next record


; load intel hex file

load:     mov si,load_hex
          call pstr

          mov al,0
          mov [bcs_error],al

          call get_record
          ret

; dump memory with es extra segment user register!

dump_memory: call getstr
             jnc  dump8                 ; jump if no carry
             mov bx,[sram_pointer]      ; carry = 1, restore last pointer

             jmp dump9

dump8:       call atohex
             mov bh,ah
             mov bl,al

dump9:       call newline

             mov cx,8

dump2:	     push cx
	     call newline

             mov ax,[user_es]       ; get user data segment register

             mov es,ax

             mov dx,ax              ; display data segment
             mov al,dh

             push dx
             call out2x
             pop dx

             mov al,dl
             call out2x

             mov al,":"
             call cout

             mov ax,bx
             call out4x

           ;  mov al,bh
           ;  call out2x
           ;  mov al,bl
           ;  call out2x

             call space
             call space

             mov cx,16

dump1:       seg es
             mov al,[bx]
	     call out2x

             mov al,cl
             cmp al,16-7    ; backward couting!
             jne dump6
             mov al,"-"
             call cout
             jmp dump7

dump6:       call space

dump7:       inc bx
	     loop dump1

; print ASCII representation

             call space
             mov ax,bx
             sbb ax,16
             mov bx,ax
             mov cx,16

dump5:       seg es        ; relative with ES register!
             mov al,[bx]
             cmp al,20h
             jb  dump3
             cmp al,80h
             jae dump3
             call cout
             jmp dump4
dump3:       mov al,"."
             call cout
dump4:       inc bx
             loop dump5

	     pop cx
	     loop dump2

             mov [sram_pointer],bx      ; save last location
	     ret

clr_sram:  mov cx,512
           mov di,inline_buffer   ; start of sram
           xor ax,ax
clr_sram1: mov [di],ax
           inc di
           inc di
           loop clr_sram1
           ret

; clear inline buffer

clr_buffer: mov cx,64           ; clear 64 word
            mov di,inline_buffer
            xor ax,ax

clr1:       mov [di],ax
            inc di
            inc di
            loop clr1
            ret
; getstr

bs         equ 8

getstr:     clc                 ; clear carry flag
            mov di,inline_buffer

getstr1:    call cins1
            cmp al,cr
            je  end_of_string
            cmp al,bs
            je  dec_pointer
            mov [di],al
            inc di
            jmp getstr1

dec_pointer: dec di
            jmp getstr1

end_of_string: mov al,0
               mov [di],al   ; put terminator
               cmp di,inline_buffer
               ja skip1

               stc          ; carry = 1, no key entered
skip1:         ret


; cins1 wait until get character and echo to screen

cins1_hex:   call cin
	cmp al,-1
        je  cins1_hex

        cmp al,cr
        je print_digit
        cmp al,bs
        je print_digit


        cmp al,"0"
        jae check_9
        jmp cins1_hex

check_9: cmp al,"9"
         ja check_a
         jmp print_digit

check_a: cmp al,"a"
         jae check_f
         jmp cins1_hex

check_f: cmp al,"f"
         ja cins1_hex

print_digit:

        call cout
	ret


; getstr_hex accepts only hex digit

getstr_hex: clc                 ; clear carry flag
            mov di,inline_buffer

getstr1_hex:    call cins1_hex
            cmp al,cr
            je  end_of_string_hex
            cmp al,bs
            je  dec_pointer_hex

            mov [di],al
            inc di
            jmp getstr1_hex

dec_pointer_hex: dec di
            jmp getstr1_hex

end_of_string_hex: mov al,0
               mov [di],al   ; put terminator
               cmp di,inline_buffer
               ja skip1_hex

               stc          ; carry = 1, no key entered
skip1_hex:     ret

; convert ASCII to 16-bit hex number
; entry: string in inline buffer
; exit: ax

atohex:     mov di,inline_buffer
            mov dx,0

atohex2:    mov al,[di]
            cmp al,eos
            jne atohex1
            mov ax,dx

            ret

atohex1:    call to_hex
            mov  cl,4
            rol  dx,cl
            or   dl,al
            inc  di
            jmp  atohex2
            

string:     call clr_buffer
            call getstr
            call newline
            mov si,inline_buffer
            call pstr
            ret

; help menu

help:       mov si,menu
            call pstr
            ret

; fill memory with constant

fill:       mov si,fill_text
            call pstr
            call getstr_hex
            jc   exit_fill
            call atohex
            mov  si,ax

            push si

            mov si,stop_text
            call pstr
            call getstr_hex
            call atohex
            mov di,ax

            mov ax,[user_es]
            mov es,ax


            push di

            mov si,data_text
            call pstr
            call getstr_hex
            call atohex

            pop di
            pop si

            sub di,si           ; get number of byte
            mov cx,di
            shr cx,1            ; devide by two for word fill!

fill2:      seg es
            mov [si],ax
            inc si
            inc si
            loop fill2

exit_fill:
            ret

; jump to user program

jump:     mov si, jump_text
          call pstr           ; show current CS:IP
          mov ax,[user_cs]
          call out4x
          mov al,":"
          call cout
          mov ax,[user_ip]
          call out4x

          mov al,">"
          call cout

          mov ax,[user_cs]
          call out4x
          mov al,":"
          call cout


          call getstr
          jnc  jump1
          jmp jump2

jump1:
          call atohex     ; ax = where to jump
          mov [user_ip],ax

jump2:
        MOV     BX, SP                ; GET CURRENT STACK POINTER
        MOV     AX,[USER_IP]          ; GET USER CODE STARTING IP
        seg ss
        MOV    [BX+14h], AX           ; REPLACE OLD IP WITH USER IP
        MOV     AX, [user_cs]
        seg ss                        ; GET USER CODE STARTING CS
        MOV    [BX+16h], AX           ; REPLACE OLD CS WITH USER CS
        mov     ax, [user_flags]      ; get saved user flags value
        seg ss
        mov    [bx+18h], ax           ; replace idle rism flags
        POP     bx 
        POP     bx                    ; dummy pop
        POPA                          ; CLEAN UP STACK
        IRET                          ; RETURN TO USER CODE



; out_tab

out_tab:  mov si,tab
          call pstr
          ret

; user registers display

user_registers:

         call getstr
         jnc find_what_register

         call print_all
         ret


find_what_register:
         mov si,inline_buffer
         mov ax,[si]            ; get text, AX, IP, CS...
         xchg al,ah
         cmp ax,"ip"
         jne register1

         call newline
         mov si,ip_text
         call pstr
         mov ax,[user_ip]
         call out4x
         call newline
         mov al,"-"
         call cout
         call getstr
         jnc write_ip
         ret

write_ip: call atohex
          mov [user_ip],ax
          ret

register1:

         cmp ax,"es"
         jne register2

         call newline
         mov si,es_text
         call pstr
         mov ax,[user_es]
         call out4x
         call newline
         mov al,"-"
         call cout
         call getstr
         jnc write_es
         ret

write_es: call atohex
          mov [user_es],ax
          ret

register2:
         cmp ax,"cs"
         jne register3

         call newline
         mov si,cs_text1
         call pstr
         mov ax,[user_cs]
         call out4x
         call newline
         mov al,"-"
         call cout
         call getstr
         jnc write_cs
         ret

write_cs: call atohex
          mov [user_cs],ax
          ret

register3: ret



print_all:
         call newline
         call newline
         mov si,cs_text
         call pstr
         mov ax,[user_cs]
         call out4x
         mov al,":"
         call cout
         mov ax,[user_ip]
         call out4x

         call out_tab

         mov si,ss_text
         call pstr
         mov ax,[user_ss]
         call out4x
         mov al,":"
         call cout
         mov ax,[user_sp]
         call out4x

         call out_tab
         mov si,ax_text
         call pstr
         mov ax,[user_ax]
         call out4x

         call out_tab
         mov si,bx_text
         call pstr
         mov ax,[user_bx]
         call out4x

         call out_tab
         mov si,cx_text
         call pstr
         mov ax,[user_cx]
         call out4x

         call out_tab
         mov si,dx_text
         call pstr
         mov ax,[user_dx]
         call out4x

         call newline
         mov si,ds_text
         call pstr
         mov ax,[user_ds]
         call out4x

         call out_tab
         mov si,es_text
         call pstr
         mov ax,[user_es]
         call out4x

         call out_tab
         mov si,si_text
         call pstr
         mov ax,[user_si]
         call out4x

         call out_tab
         mov si,di_text
         call pstr
         mov ax,[user_di]
         call out4x

         call out_tab
         mov si,bp_text
         call pstr
         mov ax,[user_bp]
         call out4x


         ret


; upload binary image to terminal, save it as dwl for c32 cross assembler

upload_image:
          mov si,start_upload
          call pstr
          call getstr
          call atohex
          mov si,ax

          push si

          mov si,stop_upload
          call pstr
          call getstr

          mov si,capture_text
          call pstr

          call cins

          call atohex   ; convert stop address

          pop si

          sub ax,si           ; get number of byte
          mov cx,16
          mov dx,0           ; clear dx
          div cx              ; devide by two for word counting
          mov cx,ax

upload1:  push cx

          mov cx,8

          push si

          mov  si,dwl_text
          call pstr

          pop si

upload2:  mov al,"0"
          call cout

          mov ax,[si]
          call out4x

          mov al,"h"
          call cout
          mov al,","
          call cout

          inc si
          inc si
          loop upload2

          pop cx

          loop upload1

          call cins   ; wait unitil catured text was saved

          ret



; edit memory

edit_memory: call getstr_hex
             jnc  edit1
             ret               ; return prompt if carry set!

edit1:       call atohex
             mov bh,ah
             mov bl,al

edit3:       call newline

             mov ax,[user_es]
             mov dx,ax
             mov al,dh

             push dx
             call out2x
             pop dx

             mov al,dl
             call out2x

             mov al,":"
             call cout

             mov ax,bx
             call out4x

             call space
             call space

             mov al,"["
             call cout
             seg es
             mov al,[bx]
	     call out2x
             mov al,"]"
             call cout

             call space

             call getstr_hex
             jc   edit2
             call atohex
             seg es
             mov [bx],al
             mov ah,al
             seg es
             mov al,[bx]    ; read back
             cmp ah,al
             je  next_byte

             dec bx

next_byte:   inc bx
             jmp edit3

edit2:       ret


; write peripheral

write_peripherals:  mov si,write_text
            call pstr
            call getstr_hex
            call atohex
            push ax
            mov  si,word_text
            call pstr
            call getstr_hex
            call atohex

            mov bx,ax
            pop ax
            or  ax,0ff00h   ; PCB was set to FF
            mov dx,ax
            mov ax,bx
            out dx,ax
            ret

outbyte:    mov si,outbyte_text
            call pstr
            call getstr_hex
            call atohex
            push ax
            mov  si,word_text
            call pstr
            call getstr_hex
            call atohex

            mov bx,ax
            pop ax
            mov dx,ax
            mov ax,bx
            out dx,al
            ret

inbyte:  mov si,inbyte_text
            call pstr
            call getstr_hex
            call atohex
            mov dx,ax
            in ax,dx

            push ax
            call newline
            pop ax
            call out4x
            ret

; print peripheral registers

print_peripheral:
            mov si,per_text
            call pstr
            call newline

            mov bx,0ff00h
            mov cx,16

print1:     call newline
            mov ax,bx

            push cx
            call out4x
            call space  ; one more space

            mov cx,8

print2:     push cx
            call space

            mov dx,bx
            in ax,dx
            call out4x

            inc bx
            inc bx
            pop cx
            loop print2


            pop cx

            loop print1
            ret



; service int 21h emulates some dos function call

int21_service:
         ; mov dx,p1ltch
         ; mov al,0
         ; out dx,al
          mov al,dl
          call cout
          nop
          iret


UNWANTED_INT:

         iret           ; test with int 34-3E borland floating point emulation

	MOV     DX, P1LTCH
        MOV     Al, 0H
	OUT     DX, AL                          ; INDICATE A MAJOR SCREW UP

testa4:
	HLT                                     ; THIS IS NOT GOOD
	jmp     testa4



	; string constant
boot:    dfb cr,lf,lf,"Boot Loader Auto Run...",eos
title:   dfb cr,lf,lf,"x86Bug(RAM) V1.1 Boot LOADER for 80C188/186 Single Board Computer",eos
prompt:  dfb cr,lf,lf,">",eos
version: dfb cr,lf,lf,"x86Bug V1.1 Copyright(C) OCT.2004 Wichit Sirichote kswichit@kmitl.ac.th",eos
load_hex: dfb "oad Intel hex file...",cr,lf,eos
fill_text: dfb "ill memory with 16-bit data",cr,lf,"start=",eos
stop_text: dfb cr,lf,"stop=",eos
data_text: dfb cr,lf,"16-bit data=",eos

check_sum_error: dfb cr,lf,"checksum errors!",eos
check_sum_ok:   dfb cr,lf,"ok",eos
jump_text:      dfb "ump to address CS:IP=",eos

register_text: dfb cr,lf," CS   IP   SS   SP   AX   BX   CX   DX   DS   ES   BP   SI   DI",eos
restart:   dfb "old boot...",eos
start_upload: dfb cr,lf,"start=",eos
stop_upload: dfb cr,lf,"stop =",eos
dwl_text:    dfb cr,lf," dwl ",eos
capture_text: dfb cr,lf,"enable capture text..press any key when ready",eos

write_text:    dfb "rite peripherals with 16-bit data"
               dfb cr,lf,"offset address FF:OFFSET=",eos
word_text:     dfb cr,lf,"16-bit data=",eos
per_text:      dfb "rint peripheral registers PCB=FF",eos

outbyte_text:  dfb "utput 16-bit data to output port"
               dfb cr,lf,"port address=",eos

inbyte_text: dfb "nput 16-bit data from input port"
             dfb cr,lf,"port address=",eos

ax_text:  dfb "AX=",eos
bx_text:  dfb "BX=",eos
cx_text:  dfb "CX=",eos
dx_text:  dfb "DX=",eos
si_text:  dfb "SI=",eos
di_text:  dfb "DI=",eos
bp_text:  dfb "BP=",eos
cs_text:  dfb "CS:IP=",eos
cs_text1: dfb "CS=",eos
ip_text:  dfb "IP=",eos
ds_text:  dfb "DS=",eos
ss_text:  dfb "SS:SP=",eos
es_text:  dfb "ES=",eos

tab:      dfb "  ",eos

menu:    dfb cr,lf,"d  dump memory d100< (using extra segment)"
         dfb cr,lf,"r  user registers display/modify"
         dfb cr,lf,"e  edit memory e120<"
         dfb cr,lf,"l  load intel hex file"
         dfb cr,lf,"u  upload binary image"
         dfb cr,lf,"f  fill memory with word"
         dfb cr,lf,"j  jump to address"
         dfb cr,lf,"w  write 16-bit data to onchip peripherals"
         dfb cr,lf,"o  output byte to output port"
         dfb cr,lf,"i  input byte from input port"
         dfb cr,lf,"p  print peripheral registers"
         dfb cr,lf,"v  version"
         dfb cr,lf,"?  help menu",eos


;***************************reset vector FFFF0 *******************************
           org 0FFF0h
           MOV     DX, UCSST       ; POINT TO UMCS REGISTER
           MOV     AX, 8000h       ; enable upper 512kB
           OUT     DX, AL          ; I used AT29C010A, access time is 70ns!
           JMP  FAR PTR start,0F000H ; jump to start

	   end
