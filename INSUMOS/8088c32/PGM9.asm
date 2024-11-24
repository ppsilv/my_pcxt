           CPU     "8086.TBL"      ; CPU TABLE
           HOF     "INT8"         ; HEX OUTPUT FORMAT

           org 3fch
	
	   dfb service_timer&0ffh
	   dfb  service_timer>>8
	  
	   dfb 0
	   dfb 0

	   org 400h

	   sti
	   jmp $

	   org 500h

service_timer
	   mov ah,[0]
	   cmp ah,100
	   jnz skip
	   mov ah,0
	   mov [0],ah
	   mov al,[1]
	   inc al
	   mov [1],al
	   out 0,al
	   
skip	   iret

	   end
