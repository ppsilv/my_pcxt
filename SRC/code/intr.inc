

%define DIVIDE0VECTOR 0x0000 ; IP and CS for divide by 0
%define SINGLESTEPVECTOR 0x0004 ; IP and CS for Single Step
%define NMIVECTOR 0x0008  ; IP and CS for Non Maskable Interrupt
%define INT3VECTOR 0x000c ; IP and CS for INT 3 Software Interrupt
%define OVERFLOWVECTOR 0x0010 ; IP and CS for Overflow
%define MONCODESEG 0xF000 ; Monitor Code Segment

UNWANTED_INT:
        iret
dummy:
   ; Put rest of registers on the stack (now has Flags and dummy IP and CS if after reset)
   ; After INT 3 or NMI then Flags, CS and IP are on stack already
   ; pusha does not exist on 8088/8086!
   push sp  
   push ax
   push cx
   push dx
   push bx
   push bp
   push si
   push di
   ; Save User Program Stack pointer current value, is restored on Continue or set on GO   default FDFE
;   mov [ds:STACKSTART], sp; NMISR               sts      STACKSTART         ; Save current stack pointer at STACKSTART $13F8 (after NMI or RESET)
;;; PUT YOUR CODE HERE
;   mov sp, [ds:STACKSTART] ; Restore sp from end of push on NMI/INT 3   
   pop di
   pop si
   pop bp
   pop bx
   pop dx
   pop cx
   pop ax
   pop sp ; This should result in the same sp value before iret as is in STACKSTART
   iret            ;                  rti                        ; Return from interupt, which will load program counter from X value returned from BADDR

