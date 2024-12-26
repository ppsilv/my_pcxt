;==================================================================================
; iLoad - Intel-Hex Loader - S200220
; HW ref: A250220 (V20-MBC)
;
; REQUIRED: IOS S260320 (or following revisions until otherwise stated)
;
; Assemble with "nasm -f bin  filename.asm -o filename.bin"
;
; Loads an 8088 executable in Intel-Hex format and executes it. 
; The executable must be a "flat file" inside a single segment, so the maximum 
; executable size is 64KB (that is also the maximum address space allowed with 
; the used Intel-Hex format.
;
; The executable file is loaded and executed into the segment at 0x0000.
;
; The starting address of the loaded executable is 0x0000:STRADDR, where STRADDR is the
; first address (16 bit) of the Intel-Hex stream (the first executed instruction starts 
; at the address of the first byte of the Intel-Hex stream).
;
; iLoad checks for errors in the Intel-Hex stream, and if the Intel-Hex streams attempts 
; to overwrite it.
;
;==================================================================================
;
;  Physical memory layout (not in scale):
;
;  +---------------+
;  ! 0x0000:0x0000 !    Free area available for the user 8088 executable 
;  !  -----------  !
;  ! 0x0000:0xFCEF !
;  +---------------+
;  ! 0x0000:0xFCF0 !    iLoad (local data area + program + reserved area)
;  !  -----------  !    
;  ! 0x0000:0xFFFF !
;  +---------------+
;  ! 0x1000:0x0000 !    Not used
;  !  -----------  !    
;  ! 0x1000:0xFFFF !
;  +---------------+
;  ! 0x2000:0x0000 !    Not used (can be not fitted with RAM)
;  !  -----------  !    
;  ! 0xF000:0xFFFF !
;  +---------------+
; 
; The available Physical  memory area for user program is from address 0x0000:0000 to 
; 0x0000:0xFCEF (64.752 bytes).
;
; iLoad can work with the A250220 minimum RAM configuration (128KB).
;
; Multi-segment executables are not supportd by iLoad.
; 
;==================================================================================
;
; NOTE: I've ported to the 8086/8088 assembler the original iLoad (SW ref. S200718)
;       for the Z80-MBC2, translating the source line by line.
;       In the following the "convention" that I've (mainly) used for the registers.
;
;       16 bit registes (Z80 -> 8086):
;               AF -> AX
;               BC -> CX
;               DE -> DX
;               HL -> BX
;
;       8 bit registes (Z80 -> 8086):
;                A -> AL
;                B -> CH
;                C -> CL
;                D -> DH
;                E -> DL
;                H -> BH
;                L -> BL
;
;==================================================================================


;
; NASM setting
;
    CPU     8086        ; Set 8086/8088 opcodes only
    BITS    16          ; Set default 16 bit

;******************************************************************************
;***
;*** Main program
;***
;******************************************************************************


;
; Costants definitions
;
loader_ram      equ    0xfcf0           ; First RAM location used
eos             equ    0x00             ; End of string
cr              equ    0x0d             ; Carriage return
lf              equ    0x0a             ; Line feed
space           equ    0x20             ; Space
rx_port         equ    0x01             ; IOS serial Rx read port
opcode_port     equ    0x01             ; IOS opcode write port
exec_wport      equ    0x00             ; IOS execute opcode write port
tx_opcode       equ    0x01             ; IOS serial Tx operation opcode
;
; iLoad memory starting area
;
                org    loader_ram
;
; Stack pointer local area
;
start:
    jmp     starting_addr           ; Inside the stack area, can be overwritten
    times   32-$+start  db      0   ; Local stack area
local_stack:
;
; Init
;
starting_addr:
    mov     sp, local_stack ; Set the stack
    mov     ax, cs          ; DS = SS = CS
    mov     ds, ax
    mov     ss, ax
;
; Print a welcome message
;
    mov     bx, hello_msg
    call    puts
    call    crlf
;
; Load an INTEL-Hex file into memory
;
    call    ih_load         ; Load Intel-Hex file
    mov     al, 0xff        ; Test for errors
    cmp     al, bh          ; (A = H ?)
    jnz     short print_addr; Jump if BH (H) <> $FF (no errors)
    cmp     al, bl          ; (A = L ?)
    jnz     short print_addr; Jump if BL (L) <> $FF (no errors)
;
; Print an error message and halt cpu
;               
    mov     bx, ih_load_msg_4
    call    puts
    mov     bx, load_msg_2
    call    puts
    hlt
;
; Print starting address
;
print_addr:
    push    bx              ; Save starting addresss BX (HL)
    mov     bx, ih_load_msg_4
    call    puts
    mov     bx, load_msg_1
    call    puts
    
    mov     bx, cs          ; Print the CS segment
    call    print_word
    mov     al, ':'
    call    putc
    
    pop     bx              ; Print the starting addresss of the loaded program
    call    print_word
    call    crlf
    call    crlf
;
; Flush remaining input data (if any) and jump to the loaded program
;               
flush_rx:
    in      al, rx_port     ; Read a char from serial port
    cmp     al, 0xff        ; Is <> $FF?
    jnz     short flush_rx  ; Yes, read an other one
    jmp     bx              ; IP = BX
;
; Message definitions
;
hello_msg       db   "iLoad - Intel-Hex Loader - S200220", eos
load_msg_1      db   "Starting Address: ", eos
load_msg_2      db   "Load error - System halted", eos
ih_load_msg_1   db   "Waiting input stream...", eos
ih_load_msg_2   db   "Syntax error!", eos
ih_load_msg_3   db   "Checksum error!", eos 
ih_load_msg_4   db   "iLoad: ", eos
ih_load_msg_5   db   "Address violation!", eos

;******************************************************************************
;***
;*** Subroutines
;***
;******************************************************************************


;
; Load an INTEL-Hex file (a ROM image) into memory. This routine has been 
; more or less stolen from a boot program written by Andrew Lynch and adapted
; to this simple Z80 based machine.
;
; The first address in the INTEL-Hex file is considerd as the Program Starting Address
; and is stored into HL.
;
; If an error is found HL=$FFFF on return.
;
; The INTEL-Hex format looks a bit awkward - a single line contains these 
; parts:
; ':', Record length (2 hex characters), load address field (4 hex characters),
; record type field (2 characters), data field (2 * n hex characters),
; checksum field. Valid record types are 0 (data) and 1 (end of file).
;
; Please note that this routine will not echo what it read from stdin but
; what it "understood". :-)
; 
ih_load:
    push    ax              ; (AF)
    push    dx              ; (DE)
    push    cx              ; (BC)
    mov     cx, 0xffff      ; (Init BC = $FFFF)
    mov     bx, ih_load_msg_1
    call    puts
    call    crlf
ih_load_loop:
    call    getc            ; Get a single character
    cmp     al, cr          ; Don't care about CR
    jz      short ih_load_loop
    cmp     al, lf          ; ...or LF
    jz      short ih_load_loop
    cmp     al, space       ; ...or a space
    jz      short ih_load_loop
    call    to_upper        ; Convert to upper case
    call    putc            ; Echo character
    cmp     al, ':'         ; Is it a colon? 
    jnz     short ih_load_err   ; No - print an error message
    call    get_byte        ; Get record length into A
    mov     dh, al          ; Length is now in D (D = A)
    mov     dl, 0           ; Clear checksum
    call    ih_load_chk     ; Compute checksum
    call    get_word        ; Get load address into BX (HL)
    mov     al, 0xff        ; Save first address as the starting addr
    cmp     al, ch          ; (A = B ?)
    jnz     short update_chk    ; Jump if B<>$FF
    cmp     al, cl          ; (A = C ?)
    jnz     short update_chk; (Jump if C<>$FF)
    mov     cx, bx          ; Save starting address in CX (BC = HL)
update_chk:
    mov     al, bh          ; Update checksum by this address (A = H)
    call    ih_load_chk
    mov     al, bl          ; (A = L)
    call    ih_load_chk
    call    get_byte        ; Get the record type
    call    ih_load_chk     ; Update checksum
    cmp     al, 1           ; Have we reached the EOF marker?
    jnz     short ih_load_data  ; No - get some data
    call    get_byte        ; Yes - EOF, read checksum data
    call    ih_load_chk     ; Update our own checksum
    mov     al, dl          ; (A = E)
    and     al, al          ; Is our checksum zero (as expected)?
    jz      short ih_load_exit  ; Yes - exit this routine
ih_load_chk_err:
    call    crlf            ; No - print an error message
    mov     bx, ih_load_msg_4
    call    puts
    mov     bx, ih_load_msg_3
    call    puts
    mov     cx, 0xffff      ; (BC = 0xffff)
    jmp     ih_load_exit    ; ...and exit
ih_load_err:
    call    crlf
    mov     bx, ih_load_msg_4
    call    puts            ; Print error message
    mov     bx, ih_load_msg_2
    call    puts
    mov     cx, 0xffff      ; (BC = 0xffff)
ih_load_data:
    mov     al, dh          ; Record length is now in AL
    and     al, al          ; Did we process all bytes?
    jz      short ih_load_eol   ; Yes - process end of line
    call    get_byte        ; Read two hex digits into A
    call    ih_load_chk     ; Update checksum
    push    bx              ; Check if BX (HL) < iLoad used space
    push    cx              ; (BC)
    and     al, al          ; Reset flag C
    mov     cx, loader_ram  ; CX (BC) = iLoad starting area
    sub     bx, cx          ; BX = BX - iLoad starting area (HL = HL - iLoad starting area)
    pop     cx
    pop     bx
    jc      store_byte      ; Jump if BX (HL) < iLoad starting area
    call    crlf            ; Print an error message
    mov     bx, ih_load_msg_4
    call    puts
    mov     bx, ih_load_msg_5
    call    puts
    mov     cx, 0xffff      ; Set error flag (BC = 0xffff)
    jmp     ih_load_exit    ; ...and exit
store_byte:
    mov     [bx], al        ; Store byte into memory
    inc     bx              ; Increment pointer
    dec     dh              ; Decrement remaining record length
    jmp     ih_load_data    ; Get next byte
ih_load_eol:
    call    get_byte        ; Read the last byte in the line
    call    ih_load_chk     ; Update checksum
    mov     al, dl
    and     al, al          ; Is the checksum zero (as expected)?
    jnz     short ih_load_chk_err
    call    crlf
    jmp     ih_load_loop    ; Yes - read next line
ih_load_exit:
    call    crlf
    mov     bx, cx          ; BX = CX (HL = BC)
    pop     cx              ; Restore registers (BC)
    pop     dx              ; (DE)
    pop     ax              ; (AF)
    ret
;
; Compute DL = DL - AL (E = E - A)
;
ih_load_chk:
    sub     dl, al          ; DL = DL - AL
    ret

;------------------------------------------------------------------------------
;---
;--- String subroutines
;---
;------------------------------------------------------------------------------

;
; Get a word (16 bit) in hexadecimal notation. The result is returned in BX.
; Since the routines get_byte and therefore get_nibble are called, only valid
; characters (0-9a-f) are accepted.
;
get_word:
    push    ax
    call    get_byte        ; Get the upper byte
    mov     bh, al
    call    get_byte        ; Get the lower byte
    mov     bl, al
    pop     ax
    ret

;
; Get a byte in hexadecimal notation. The result is returned in AL. Since
; the routine get_nibble is used only valid characters are accepted - the 
; input routine only accepts characters 0-9, a-f.
;
get_byte:
    push    cx              ; Save CX
    call    get_nibble      ; Get upper nibble
    mov     cl, 4
    rol     al, cl
    mov     ah, al          ; Save upper four bits
    call    get_nibble      ; Get lower nibble
    or      al, ah          ; Combine both nibbles
    pop     cx              ; Restore CX
    ret

;
; Get a hexadecimal digit from the serial line. This routine blocks until
; a valid character (0-9a-f) has been entered. A valid digit will be echoed
; to the serial line interface. The lower 4 bits of AL contain the value of 
; that particular digit.
;
get_nibble:
    call    getc            ; Read a character in AL
    call    to_upper        ; Convert to upper case
    call    is_hex          ; Was it a hex digit?
    jnc     get_nibble      ; No, get another character
    call    nibble2val      ; Convert nibble to value
    call    print_nibble
    ret

;
; is_hex checks a character stored in AL for being a valid hexadecimal digit.
; A valid hexadecimal digit is denoted by a set C flag.
;
is_hex:
    cmp     al, 'F' + 1     ; Greater than 'F'?
    jc      is_hex_0        ; ret nc ; Yes return
    ret
is_hex_0:
    cmp     al, '0'         ; Less than '0'?
    jnc     is_hex_1        ; No, continue
    clc                     ; Clear carry
    ret
is_hex_1:
    cmp     al, '9' + 1     ; Less or equal '9*?
    jnc     is_hex_1b       ; ret c ; Yes
    ret
is_hex_1b:
    cmp     al, 'A'         ; Less than 'A'?
    jnc     is_hex_2        ; No, continue
    clc                     ; Yes - clear carry and return
    ret
is_hex_2:        
    stc                     ; Set carry
    ret

;
; Convert a single character contained in AL to upper case:
;
to_upper:
    cmp     al, 'a'             ; Nothing to do if not lower case
    jnc     to_upper1           ; ret     c
    ret
to_upper1:
    cmp     al, 'z' + 1         ; > 'z'?
    jc      to_upper2           ; ret nc ; Nothing to do, either
    ret
to_upper2:
    and     al, 0x5f             ; Convert to upper case
    ret

;
; Expects a hexadecimal digit (upper case!) in AL and returns the
; corresponding value in AL.
;
nibble2val:
    cmp     al, '9' + 1         ; Is it a digit (less or equal '9')?
    jc      nibble2val_1        ; Yes
    sub     al, 7               ; Adjust for A-F
nibble2val_1:
    sub     al, '0'             ; Fold back to 0..15
    and     al, 0xf             ; Only return lower 4 bits
    ret

;
; Send a string to the serial line, BX contains the pointer to the string:
;
puts:
    push    ax
    push    bx
puts_loop:
    mov     al, [bx]
    cmp     al, eos         ; End of string reached?
    jz short      puts_end      ; Yes
    call    putc
    inc     bx              ; Increment character pointer
    jmp     puts_loop       ; Transmit next character
puts_end:
    pop     bx
    pop     ax
    ret

;
; Print_word prints the four hex digits of a word to the serial line. The 
; word is expected to be in BX.
;
print_word:
    push    bx
    push    ax
    mov     al, bh          ; Print high digits
    call    print_byte
    mov     al, bl          ; Print low digits
    call    print_byte
    pop     ax
    pop     bx
    ret

;
; Print_byte prints a single byte in hexadecimal notation to the serial line.
; The byte to be printed is expected to be in AL.
;
print_byte:
    push    ax              ; Save the contents of the registers
    push    cx
    mov     ah, al
    mov     cl, 4
    ror     al, cl
    call    print_nibble    ; Print high nibble
    mov     al, ah
    call    print_nibble    ; Print low nibble
    pop     cx              ; Restore original register contents
    pop     ax
    ret

;
; Print_nibble prints a single hex nibble which is contained in the lower 
; four bits of AL:
;
print_nibble:    
    push    ax              ; We won't destroy the contents of A
    and     al, 0xf         ; Just in case...
    add     al, '0'         ; If we have a digit we are done here.
    cmp     al, '9' + 1     ; Is the result > 9?
    jc      print_nibble_1
    add     al, 'A' - '0' - 0xa  ; Take care of A-F
print_nibble_1:  
    call    putc            ; Print the nibble and
    pop     ax              ; restore the original value of A
    ret

;
; Send a CR/LF pair:
;
crlf:           
    push    ax
    mov     al, cr
    call    putc
    mov     al, lf
    call    putc
    pop     ax
    ret

;------------------------------------------------------------------------------
;---
;--- I/O suroutines
;---
;------------------------------------------------------------------------------

;
; Send a single character to the serial line (AL contains the character):
;
putc:
    mov     ah, al          ; Save the chat into AH
    mov     al, tx_opcode   ; AL = IOS Serial Tx operation opcode
    out     opcode_port, al ; Send to IOS the Tx operation opcode
    mov     al, ah          ; Output char into AL
    out     exec_wport, al  ; Write AL to the serial
    ret
    
;
; Wait for a single incoming character on the serial line
; and read it, result is in AL:
;
getc:           
    in      al, rx_port     ; Read a char from serial
    cmp     al, 0xff        ; It is = $FF?
    jz      short getc      ; If yes jump until a valid char is received
    ret
    