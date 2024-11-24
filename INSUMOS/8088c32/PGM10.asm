           CPU     "8086.TBL"      ; CPU TABLE
           HOF     "INT8"         ; HEX OUTPUT FORMAT

byte2led_far equ 0d010h  

           org 3fch
	
	   dfb service_timer&0ffh
	   dfb  service_timer>>8
	  
	   dfb 0
	   dfb 0

	   org 400h

	   sti
main
	   mov si,0ff2ch
	   CALL  FAR PTR 0d000h,0f000h 
	   jmp main

	   org 500h

service_timer

	   push ax
	   
	   mov al,[0]
	   inc al
	   mov [0],al
	   cmp al,10  ; 10 ticks
	   jnz skip
	   
	   mov al,0
	   mov [0],al
	   mov al,[1]
	   add al,1
	   daa
	   mov [1],al
	   
	   out 0,al
	   
	   push si
	   call far ptr byte2led_far,0f000h
	   pop si
	   
skip	   pop ax

           iret

	   end
