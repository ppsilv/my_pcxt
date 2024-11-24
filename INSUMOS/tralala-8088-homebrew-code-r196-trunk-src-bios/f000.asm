;    This file is part of the BIOS of the Tralala 8088 Homebrew Computer.
;
;    The BIOS of the Tralala 8088 Homebrew Computer is free software: you
;    can redistribute it and/or modify it under the terms of the GNU General
;    Public License as published by the Free Software Foundation, either
;    version 3 of the License, or (at your option) any later version.
;
;    The BIOS of the Tralala 8088 Homebrew Computer is distributed in the hope
;    that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
;    warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with the BIOS.  If not, see <http://www.gnu.org/licenses/>.


                            cpu 8086
                            bits 16

                            ;%define TRACE_INT10_UNSUPPORTED
                            ;%define TRACE_INT11
                            ;%define TRACE_INT12
                            ;%define TRACE_INT13
                            ;%define TRACE_INT15
                            ;%define TRACE_INT16
                            ;%define TRACE_INT1A

                            %include "ich_cmds.asm"

%ifdef __8086__
PPI_Port_A                  equ 0E0h
PPI_Port_B                  equ 0E2h
PPI_Port_C                  equ 0E4h
PPI_Control_Register        equ 0E6h

PIC_8259A_Port0             equ 020h
PIC_8259A_Port1             equ 022h
%else
PPI_Port_A                  equ 0E0h
PPI_Port_B                  equ 0E1h
PPI_Port_C                  equ 0E2h
PPI_Control_Register        equ 0E3h

PIC_8259A_Port0             equ 020h
PIC_8259A_Port1             equ 021h
%endif

                            org 0
boot_msg:
                            db 0FFh, ICH_COMMAND_CLEAR_CONSOLE  ; clear screen
%ifdef __8086__
                            db 'Tralala 8086 Homebrew PC', 13, 10
                            db 'Copyright (c) 2016, 2017, 2022 Nikolay Nikolov <nickysn@users.sourceforge.net>', 13, 10, 13, 10
                            db 'Powered by a red printed circuit board and ', 0
boot_8088:                    db 'an 8086', 0
boot_nec_v20:               db 'a NEC V30', 0
%else
                            db 'Tralala 8088 Homebrew PC', 13, 10
                            db 'Copyright (c) 2016, 2017, 2022 Nikolay Nikolov <nickysn@users.sourceforge.net>', 13, 10, 13, 10
                            db 'Powered by a twisted maze of wires and ', 0
boot_8088:                    db 'an 8088', 0
boot_nec_v20:               db 'a NEC V20', 0
%endif
boot_msg_part_2:            db ' CPU', 13, 10, 13, 10
                            db 'Enjoy your DOS session!', 13, 10, 13, 10, 0

LED_ADDR                    equ 0412h
LAST_ATTR                   equ 04B4h
VIDEO_SEG                   equ 07F00h
VIDEO_COLS                  equ 80
VIDEO_ROWS                  equ 25

handle_reset:
                            ; setup stack
                            xor ax, ax
                            mov ss, ax
                            mov sp, 03FEh

                            ; clear the direction flag
                            cld

                            ; setup data segment
                            mov ds, ax

                            ; setup LED mask
                            mov byte [LED_ADDR], 1  ; green LED on

                            ; setup 8255 group A for mode 2 operation and port C(lower) as output
                            mov al, 11000010b
                            out PPI_Control_Register, al

                            call light_leds

                            ; install int handlers
                            mov word [10h*4], int_10h_handler
                            mov word [10h*4+2], 0F000h
                            mov word [11h*4], int_11h_handler
                            mov word [11h*4+2], 0F000h
                            mov word [12h*4], int_12h_handler
                            mov word [12h*4+2], 0F000h
                            mov word [13h*4], int_13h_handler
                            mov word [13h*4+2], 0F000h
                            mov word [14h*4], int_14h_handler
                            mov word [14h*4+2], 0F000h
                            mov word [15h*4], int_15h_handler
                            mov word [15h*4+2], 0F000h
                            mov word [16h*4], int_16h_handler
                            mov word [16h*4+2], 0F000h
                            mov word [17h*4], int_17h_handler
                            mov word [17h*4+2], 0F000h
                            mov word [18h*4], int_18h_handler
                            mov word [18h*4+2], 0F000h
                            mov word [19h*4], int_19h_handler
                            mov word [19h*4+2], 0F000h
                            mov word [1Ah*4], int_1Ah_handler
                            mov word [1Ah*4+2], 0F000h
                            mov word [1Bh*4], int_1Bh_handler
                            mov word [1Bh*4+2], 0F000h
                            mov word [1Ch*4], int_1Ch_handler
                            mov word [1Ch*4+2], 0F000h
                            mov word [1Dh*4], int_1Dh_handler
                            mov word [1Dh*4+2], 0F000h
                            mov word [1Eh*4], int_1Eh_handler
                            mov word [1Eh*4+2], 0F000h

                            mov word [78h*4], irq0_handler
                            mov word [78h*4+2], 0F000h
                            mov word [79h*4], irq1_handler
                            mov word [79h*4+2], 0F000h
                            mov word [7Ah*4], irq2_handler
                            mov word [7Ah*4+2], 0F000h
                            mov word [7Bh*4], irq3_handler
                            mov word [7Bh*4+2], 0F000h
                            mov word [7Ch*4], irq4_handler
                            mov word [7Ch*4+2], 0F000h
                            mov word [7Dh*4], irq5_handler
                            mov word [7Dh*4+2], 0F000h
                            mov word [7Eh*4], irq6_handler
                            mov word [7Eh*4+2], 0F000h
                            mov word [7Fh*4], irq7_handler
                            mov word [7Fh*4+2], 0F000h

                            ; init the 8259A Programmable Interrupt Controller
                            ; ICW1
                            mov al, 00010011b
                            out PIC_8259A_Port0, al
                            jmp short $+2
                            ; ICW2
                            mov al, 78h
                            out PIC_8259A_Port1, al
                            jmp short $+2
                            ; ICW4
                            mov al, 00001101b
                            out PIC_8259A_Port1, al
                            jmp short $+2
                            ; OCW1
                            mov al, 0FFh  ; mask (disable) all interrupts
                            out PIC_8259A_Port1, al

                            ; init memory size
                            mov word [0413h], 512-4  ; memory size in kilobytes (reserve 4KB for video memory)

                            ; init keyboard buffer
                            mov word [0480h], 1eh  ; keyboard buffer start
                            mov word [0482h], 3eh  ; keyboard buffer end
                            mov word [041ah], 1eh  ; keyboard buffer head
                            mov word [041ch], 1eh  ; keyboard buffer tail

                            ; clear keyboard flags
                            mov word [0417h], 0
                            mov word [0496h], 0

                            ; init system timer
                            mov word [046ch], 0
                            mov word [046eh], 0
                            mov byte [0470h], 0  ; the daily rollover flag

                            ; init display vars
                            mov byte [0449h], 3  ; current video mode
                            mov word [044ah], 80 ; number of columns
                            mov word [044ch], 1000h  ; ???
                            mov word [044eh], 0  ; ???
                            mov word [0450h], 0  ; cursor position for page 0
                            mov word [0452h], 0  ; cursor position for page 1
                            mov word [0454h], 0  ; cursor position for page 2
                            mov word [0456h], 0  ; cursor position for page 3
                            mov word [0458h], 0  ; cursor position for page 4
                            mov word [045ah], 0  ; cursor position for page 5
                            mov word [045ch], 0  ; cursor position for page 6
                            mov word [045eh], 0  ; cursor position for page 7
                            mov word [0460h], 0d0eh  ; cursor shape start and end line
                            mov byte [0462h], 0  ; current video page
                            mov byte [0484h], 24 ; number of rows - 1

                            mov byte [LAST_ATTR], 07h

                            ; clear the video buffer
                            mov di, VIDEO_SEG
                            mov es, di
                            xor di, di
                            mov cx, 2048
                            mov ax, 0720h
                            rep stosw

lets_boot:                  call print_msg
                            dw boot_msg
                            mov ax, 100h
                            aad 9
                            cmp ax, 10
                            je .nec
                            call print_msg
                            dw boot_8088
                            jmp .cpu_msg_done
.nec:                       call print_msg
                            dw boot_nec_v20
.cpu_msg_done:                call print_msg
                            dw boot_msg_part_2

                            mov al, 0FFh
                            call ppi_send
                            mov al, ICH_COMMAND_GET_STATUS
                            call ppi_send
                            call wait_for_command_response
                            test al, 1
                            jz .no_sd
                            call print_msg
                            dw sd_msg
                            jmp .goon_sd
.no_sd:                     call print_msg
                            dw no_sd_msg
.goon_sd:
                            int 19h

no_sd_msg:                  db 'MicroSD card not found!', 13, 10, 13, 10, 0
sd_msg:                     db 'MicroSD card found!', 13, 10, 13, 10, 0

;blink_loop:
;;                            call blink_short
;;                            call blink_short
;;                            call blink_short
;;                            call blink_long
;;                            call blink_long
;;                            call blink_long
;                            call light_leds
;                            mov cx, 50000
;                            call delay_loop
;                            mov cx, 50000
;                            call delay_loop
;                            mov cx, 50000
;                            call delay_loop
;                            inc byte [LED_ADDR]  ; increment LED mask
;
;                            mov al, byte [LED_ADDR]
;                            and al, 7
;                            cmp al, 0
;                            je lets_boot
;                            add al, '0'
;                            mov ah, 0Eh
;                            int 10h
;
;                            jmp blink_loop

blink_long:                 push ax
                            push bx
                            mov ax, 50000
                            mov bx, 50000
                            call blink_routine
                            pop bx
                            pop ax
                            ret

blink_short:                push ax
                            push bx
                            mov ax, 15000
                            mov bx, 30000
                            call blink_routine
                            pop bx
                            pop ax
                            ret

light_leds:                 push ax
                            mov al, [LED_ADDR]
                            out PPI_Port_C, al
                            pop ax
                            ret

blink_routine:              ; in: ax = on time
                            ;     bx = off time
                            push cx

                            ; turn LED on
                            mov al, [LED_ADDR]
                            out PPI_Port_C, al

                            mov cx, ax
                            call delay_loop

                            ; turn LED off
                            mov al, 0
                            out PPI_Port_C, al

                            mov cx, bx
                            call delay_loop

                            pop cx
                            ret

delay_loop:                    ; in: cx = time
                            push cx
.loop_start:                nop
                            nop
                            nop
                            nop
                            dec cx
                            jnz .loop_start
                            pop cx
                            ret

int_10h_handler:            cld
                            cmp ah, 0Eh
                            je int_10h_0Eh
                            cmp ah, 0Bh
                            je int_10h_0Bh
                            cmp ah, 0Fh
                            je int_10h_0Fh
                            cmp ah, 02h
                            je int_10h_02h
                            cmp ah, 03h
                            je int_10h_03h
                            cmp ah, 01h
                            je int_10h_01h
                            cmp ah, 06h
                            je int_10h_06h
                            cmp ah, 09h
                            je int_10h_09h
                            cmp ah, 08h
                            je int_10h_08h
                            cmp ah, 05h
                            je int_10h_05h
                            cmp ah, 07h
                            je int_10h_07h
                            test ah, ah
                            jz int_10h_00h

int_10h_unsupported:
                            %ifdef TRACE_INT10_UNSUPPORTED
                            call print_msg
                            dw int_10h_unsupported_msg
                            call print_regs
                            call print_msg
                            dw crlf_msg
                            %endif

                            iret

int_10h_0Eh:                cmp al, 0FFh
                            je int_10h_0Eh_print0FFh
                            push ax
.obf_loop:                    in al, PPI_Port_C
                            test al, 10000000b
                            jz .obf_loop
                            pop ax
                            out PPI_Port_A, al
                            iret
int_10h_0Eh_print0FFh:      push ax
.obf_loop1:                    in al, PPI_Port_C
                            test al, 10000000b
                            jz .obf_loop1
                            mov al, 0FFh
                            out PPI_Port_A, al
.obf_loop2:                    in al, PPI_Port_C
                            test al, 10000000b
                            jz .obf_loop2
                            mov al, ICH_COMMAND_SEND_FF_TO_CONSOLE
                            out PPI_Port_A, al
                            pop ax
                            iret

int_10h_0Bh:                iret  ; "set background/border color"; called by "cls" in DOS 2.0+

int_10h_0Fh:                ; get current video mode; called by "cls" in DOS 2.0+
                            push ds
                            xor ax, ax
                            mov ds, ax
                            mov ah, [044ah]  ; number of columns
                            mov al, [0449h]  ; current mode
                            mov bl, [0462h]   ; current video page
                            pop ds
                            iret

int_10h_02h:                ; "set cursor position"; called by "cls" in DOS 2.0+
                            push ax
                            mov al, 0FFh
                            call ppi_send
                            mov al, ICH_COMMAND_SET_CURSOR_POSITION
                            call ppi_send
                            mov al, dl
                            call ppi_send
                            mov al, dh
                            call ppi_send

                            push ds
                            push bx

                            xor ax, ax
                            mov ds, ax
                            mov bl, bh
                            shl bl, 1
                            xor bh, bh
                            mov [bx + 0450h], dx

                            pop bx
                            pop ds

                            pop ax
                            iret

int_10h_03h:                ; "get cursor position and size"
                            push ds
                            push bx
                            xor dx, dx
                            mov ds, dx
                            mov bl, bh
                            shl bl, 1
                            xor bh, bh
                            mov dx, [bx + 0450h]
                            mov cx, [0460h]
                            pop bx
                            pop ds
                            iret

int_10h_01h:                ; set cursor shape
                            ; TODO: implement
                            iret

int_10h_05h:                ; "select active display page"
                            test al, al
                            jz .done

                            %ifdef TRACE_INT10_UNSUPPORTED
                            call print_msg
                            dw int_10h_unsupported_msg
                            call print_regs
                            call print_msg
                            dw crlf_msg
                            %endif

.done:                        iret

int_10h_00h:                ; set video mode
                            cmp al, 3
                            je int_10h_set_mode_3
                            cmp al, 2
                            je int_10h_set_mode_2

                            %ifdef TRACE_INT10_UNSUPPORTED
                            call print_msg
                            dw int_10h_unsupported_msg
                            call print_regs
                            call print_msg
                            dw crlf_msg
                            %endif
                            iret

int_10h_set_mode_2:
int_10h_set_mode_3:
                            push ds
                            push ax
                            push bx
                            push cx
                            push dx

                            xor bx, bx
                            mov ds, bx
                            mov [0449h], al  ; set the current video mode var
                            mov ah, 2  ; move cursor to upper left corner
                            xor bh, bh
                            xor dx, dx
                            int 10h
                            mov ah, 1  ; set cursor shape
                            mov cx, 0607h
                            int 10h
                            mov ah, 0Fh  ; get current mode (for the number of columns)
                            int 10h
                            mov dl, ah
                            dec dl
                            mov dh, [0484h]  ; number of rows - 1
                            mov ax, 0600h  ; scroll up window (clear screen)
                            mov bh, 07h
                            xor cx, cx
                            int 10h

                            pop dx
                            pop cx
                            pop bx
                            pop ax
                            pop ds
                            iret

int_10h_06h:                ; "scroll up window", also "fill window"; called by "cls" in DOS 2.0+
                            push ds
                            push es
                            push di
                            push ax
                            push bx

                            xor di, di
                            mov ds, di
                            mov di, VIDEO_SEG
                            mov es, di
                            test cx, cx
                            jnz .not_entire_screen_fill
                            test al, al
                            jnz .not_entire_screen_fill
                            mov ah, [044ah]
                            dec ah
                            cmp dl, ah
                            jne .not_entire_screen_fill
                            cmp dh, [0484h]
                            jne .not_entire_screen_fill
                            jmp .entire_screen_fill

.not_entire_screen_fill:    test al, al
                            jnz .not_screen_fill

                            ; partial screen fill
                            mov ah, bh
                            call maybe_change_text_attr

                            mov al, 0FFh
                            call ppi_send
                            mov al, ICH_COMMAND_CONSOLE_ERASE_RECT
                            call ppi_send
                            mov al, cl
                            call ppi_send
                            mov al, ch
                            call ppi_send
                            mov al, dl
                            call ppi_send
                            mov al, dh
                            call ppi_send

                            mov al, ch  ; al = start row
                            mul byte [044ah]  ; ax = row * number_of_columns
                            mov bl, cl  ; bl = start column
                            xor bh, bh
                            add ax, bx
                            shl ax, 1
                            mov di, ax

                            ; row count: bx := dh - ch + 1
                            mov bl, dh
                            sub bl, ch
                            inc bl
                            xor bh, bh

                            ; column count cx := dl - cl + 1
                            neg cl
                            add cl, dl
                            inc cl
                            xor ch, ch

                            mov al, 20h  ; fill with spaces

.fill_next_row:
                            xchg bx, cx

                            push di
                            rep stosw
                            pop di
                            add di, VIDEO_COLS*2

                            xchg bx, cx
                            loop .fill_next_row

                            jmp .done

.not_screen_fill:
                            test cl, cl
                            jnz .not_wide_scroll
                            mov ah, [044ah]
                            dec ah
                            cmp dl, ah
                            jne .not_wide_scroll

                            ; wide screen scroll
                            mov ah, bh
                            call maybe_change_text_attr

                            mov bl, al  ; bl = scroll line count

                            mov al, 0FFh
                            call ppi_send
                            mov al, ICH_COMMAND_CONSOLE_SCROLL_UP
                            call ppi_send
                            mov al, bl
                            call ppi_send
                            mov al, ch
                            call ppi_send
                            mov al, dh
                            call ppi_send

                            push bx
                            mov al, ch  ; al = start row
                            mul byte [044ah]  ; ax = row * number_of_columns
                            mov bl, cl  ; bl = start column
                            xor bh, bh
                            add ax, bx
                            shl ax, 1
                            mov di, ax
                            pop bx  ; bl = scroll line count, bh = new line fill attr

                            ; si := di + scroll_row_count * number_of_columns * 2
                            mov al, bl
                            mul byte [044ah]
                            shl ax, 1
                            mov si, ax
                            add si, di

                            push bx  ; save bh = new line fill attr
                            ; row count: bx := dh - ch + 1 - scroll rows
                            neg bl
                            add bl, dh
                            sub bl, ch
                            inc bl
                            xor bh, bh

                            ; column count cx := dl - cl + 1
                            neg cl
                            add cl, dl
                            inc cl
                            xor ch, ch

                            push es
                            pop ds
.scroll_next_row:
                            xchg bx, cx

                            push di
                            push si
                            rep movsw
                            pop si
                            pop di
                            add si, VIDEO_COLS*2
                            add di, VIDEO_COLS*2

                            xchg bx, cx
                            loop .scroll_next_row

                            ; ok, now it's time to fill the remaining area

                            pop ax  ; from stack, was: bh = new line fill attr
                            mov al, 20h

                            xchg si, di
.scroll_wide__fill_loop:
                            push di
                            rep stosw
                            pop di
                            add di, VIDEO_COLS*2

                            cmp si, di
                            jne .scroll_wide__fill_loop

                            jmp .done

.not_wide_scroll:
                            ; TODO: implement properly

                            %ifdef TRACE_INT10_UNSUPPORTED
                            call print_msg
                            dw int_10h_unsupported_msg
                            call print_regs
                            call print_msg
                            dw crlf_msg
                            %endif

                            jmp .done

.entire_screen_fill:
                            mov ah, bh
                            call maybe_change_text_attr

                            mov al, 20h
                            xor di, di
                            mov cx, VIDEO_COLS*VIDEO_ROWS
                            rep stosw

                            mov al, 0FFh
                            call ppi_send
                            mov al, ICH_COMMAND_CONSOLE_ERASE_WHOLE_DISPLAY
                            call ppi_send
.done:
                            pop bx
                            pop ax
                            pop di
                            pop es
                            pop ds
                            iret

int_10h_07h:                ; "scroll down window", also "fill window"; called by Turbo Pascal 1, 2 and 3 when inserting a line in the editor
                            push ds
                            push es
                            push di
                            push ax
                            push bx

                            xor di, di
                            mov ds, di
                            mov di, VIDEO_SEG
                            mov es, di
                            test cx, cx
                            jnz .not_entire_screen_fill
                            test al, al
                            jnz .not_entire_screen_fill
                            mov ah, [044ah]
                            dec ah
                            cmp dl, ah
                            jne .not_entire_screen_fill
                            cmp dh, [0484h]
                            jne .not_entire_screen_fill
                            jmp .entire_screen_fill

.not_entire_screen_fill:    test al, al
                            jnz .not_screen_fill

                            ; partial screen fill
                            mov ah, bh
                            call maybe_change_text_attr

                            mov al, 0FFh
                            call ppi_send
                            mov al, ICH_COMMAND_CONSOLE_ERASE_RECT
                            call ppi_send
                            mov al, cl
                            call ppi_send
                            mov al, ch
                            call ppi_send
                            mov al, dl
                            call ppi_send
                            mov al, dh
                            call ppi_send

                            mov al, ch  ; al = start row
                            mul byte [044ah]  ; ax = row * number_of_columns
                            mov bl, cl  ; bl = start column
                            xor bh, bh
                            add ax, bx
                            shl ax, 1
                            mov di, ax

                            ; row count: bx := dh - ch + 1
                            mov bl, dh
                            sub bl, ch
                            inc bl
                            xor bh, bh

                            ; column count cx := dl - cl + 1
                            neg cl
                            add cl, dl
                            inc cl
                            xor ch, ch

                            mov al, 20h  ; fill with spaces

.fill_next_row:
                            xchg bx, cx

                            push di
                            rep stosw
                            pop di
                            add di, VIDEO_COLS*2

                            xchg bx, cx
                            loop .fill_next_row

                            jmp .done

.not_screen_fill:
                            test cl, cl
                            jnz .not_wide_scroll
                            mov ah, [044ah]
                            dec ah
                            cmp dl, ah
                            jne .not_wide_scroll

                            ; wide screen scroll
                            mov ah, bh
                            call maybe_change_text_attr

                            mov bl, al  ; bl = scroll line count

                            mov al, 0FFh
                            call ppi_send
                            mov al, ICH_COMMAND_CONSOLE_SCROLL_DOWN
                            call ppi_send
                            mov al, bl
                            call ppi_send
                            mov al, ch
                            call ppi_send
                            mov al, dh
                            call ppi_send

                            push bx
                            mov al, dh  ; al = end row
                            mul byte [044ah]  ; ax = row * number_of_columns
                            mov bl, cl  ; bl = start column
                            xor bh, bh
                            add ax, bx
                            shl ax, 1
                            mov di, ax
                            pop bx  ; bl = scroll line count, bh = new line fill attr

                            ; si := di - scroll_row_count * number_of_columns * 2
                            mov al, bl
                            mul byte [044ah]
                            shl ax, 1
                            mov si, ax
                            sub si, di
                            neg si

                            push bx  ; save bh = new line fill attr
                            ; row count: bx := dh - ch + 1 - scroll rows
                            neg bl
                            add bl, dh
                            sub bl, ch
                            inc bl
                            xor bh, bh

                            ; column count cx := dl - cl + 1
                            neg cl
                            add cl, dl
                            inc cl
                            xor ch, ch

                            push es
                            pop ds
.scroll_next_row:
                            xchg bx, cx

                            push di
                            push si
                            rep movsw
                            pop si
                            pop di
                            sub si, VIDEO_COLS*2
                            sub di, VIDEO_COLS*2

                            xchg bx, cx
                            loop .scroll_next_row

                            ; ok, now it's time to fill the remaining area

                            pop ax  ; from stack, was: bh = new line fill attr
                            mov al, 20h

                            xchg si, di
.scroll_wide__fill_loop:
                            push di
                            rep stosw
                            pop di
                            sub di, VIDEO_COLS*2

                            cmp si, di
                            jne .scroll_wide__fill_loop

                            jmp .done

.not_wide_scroll:
                            ; TODO: implement properly

                            %ifdef TRACE_INT10_UNSUPPORTED
                            call print_msg
                            dw int_10h_unsupported_msg
                            call print_regs
                            call print_msg
                            dw crlf_msg
                            %endif

                            jmp .done

.entire_screen_fill:
                            mov ah, bh
                            call maybe_change_text_attr

                            mov al, 20h
                            xor di, di
                            mov cx, VIDEO_COLS*VIDEO_ROWS
                            rep stosw

                            mov al, 0FFh
                            call ppi_send
                            mov al, ICH_COMMAND_CONSOLE_ERASE_WHOLE_DISPLAY
                            call ppi_send
.done:
                            pop bx
                            pop ax
                            pop di
                            pop es
                            pop ds
                            iret

int_10h_09h:                ; "write character and attribute at cursor position"
                            push ds
                            push es
                            push ax
                            push bx
                            push cx
                            push dx
                            push di

                            xchg ax, dx  ; 1 byte shorter than a mov
                            mov dh, bl

                            xor ax, ax
                            mov ds, ax
                            mov ax, VIDEO_SEG
                            mov es, ax

                            mov al, [0451h]  ; al = cursor row
                            mul byte [044ah]  ; ax = row * number_of_columns
                            mov bl, [0450h]  ; bl = cursor column
                            xor bh, bh
                            add ax, bx
                            shl ax, 1
                            mov di, ax
                            xchg ax, dx
                            push cx
                            rep stosw
                            pop cx

                            call maybe_change_text_attr

                            cmp al, 0FFh
                            je int_10h_09h_print0FFh
.print_loop:
                            push ax
.obf_loop:                    in al, PPI_Port_C
                            test al, 10000000b
                            jz .obf_loop
                            pop ax
                            out PPI_Port_A, al
                            loop .print_loop
                            jmp int_10h_09h_continue
int_10h_09h_print0FFh:
.obf_loop1:                    in al, PPI_Port_C
                            test al, 10000000b
                            jz .obf_loop1
                            mov al, 0FFh
                            out PPI_Port_A, al
.obf_loop2:                    in al, PPI_Port_C
                            test al, 10000000b
                            jz .obf_loop2
                            mov al, ICH_COMMAND_SEND_FF_TO_CONSOLE
                            out PPI_Port_A, al
                            loop .obf_loop1

int_10h_09h_continue:       ; now return the cursor to its original position
                            mov dx, [0450h]
                            xor bh, bh
                            mov ah, 2
                            int 10h

                            pop di
                            pop dx
                            pop cx
                            pop bx
                            pop ax
                            pop es
                            pop ds
                            iret

maybe_change_text_attr:     ; in: ah = new text attr
                            push ds
                            push ax
                            push ax
                            xor ax, ax
                            mov ds, ax
                            pop ax
                            cmp ah, [LAST_ATTR]
                            je .no_change

                            mov [LAST_ATTR], ah
                            mov al, 0FFh
                            call ppi_send
                            mov al, ICH_COMMAND_SET_TEXT_ATTR
                            call ppi_send
                            mov al, ah
                            call ppi_send
.no_change:
                            pop ax
                            pop ds
                            ret

int_10h_08h:                push ds
                            push es
                            push bx
                            push si

                            xor ax, ax
                            mov ds, ax
                            mov ax, VIDEO_SEG
                            mov es, ax

                            mov al, [0451h]  ; al = cursor row
                            mul byte [044ah]  ; ax = row * number_of_columns
                            mov bl, [0450h]  ; bl = cursor column
                            xor bh, bh
                            add ax, bx
                            shl ax, 1
                            mov si, ax

                            es lodsw

                            pop si
                            pop bx
                            pop es
                            pop ds
                            iret

int_11h_msg:                db 'INT 11h', 13, 10, 0

int_11h_handler:
                            %ifdef TRACE_INT11
                            call print_msg
                            dw int_11h_msg
                            %endif
                            mov ax, 0000000000001101b
                            iret

int_12h_msg:                db 'INT 12h', 13, 10, 0
int_12h_handler:
                            %ifdef TRACE_INT12
                            call print_msg
                            dw int_12h_msg
                            %endif

                            push ds
                            xor ax, ax
                            mov ds, ax
                            mov ax, [0413h]
                            pop ds
                            iret

int_13h_msg:                db ' Int 13h,', 0
int_16h_unsupported_msg:    db ' Int 16h unsupported function,', 0
int_13h_unsupported_msg:    db ' Int 13h unsupported function,', 0
int_10h_unsupported_msg:    db ' Int 10h unsupported function,', 0
crlf_msg:                   db 13, 10, 0

int_13h_handler:
                            %ifdef TRACE_INT13
                            call print_msg
                            dw int_13h_msg
                            call print_regs
                            call print_msg
                            dw crlf_msg
                            %endif

                            cld
                            push bp
                            mov bp, sp
                            cmp ah, 0
                            je int_13h_00h
                            cmp ah, 1
                            je int_13h_01h
                            cmp ah, 2
                            je int_13h_02h
                            cmp ah, 3
                            je int_13h_03h
                            cmp ah, 4
                            je int_13h_04h
                            cmp ah, 5
                            je int_13h_05h
                            cmp ah, 8
                            je int_13h_08h
                            cmp ah, 15h
                            je int_13h_15h

                            call print_msg
                            dw int_13h_unsupported_msg
                            call print_regs
                            call print_msg
                            dw crlf_msg

                            or byte [bp+6], 1
                            mov ah, 1
                            pop bp
                            iret

int_13h_00h:                   and byte [bp+6], 0FEh
                            xor ah, ah
                            pop bp
                            iret

int_13h_01h:                   and byte [bp+6], 0FEh
                            xor ah, ah
                            pop bp
                            iret

int_13h_04h:                   and byte [bp+6], 0FEh
                            xor ah, ah
                            pop bp
                            iret

int_13h_03h:                   test dl, 80h
                            jnz .int_13h_03h_hdd
                            or byte [bp+6], 1
                            mov ah, 3
                            pop bp
                            iret

.int_13h_03h_hdd:           cmp dl, 80h
                            je .int_13h_03h_hdd0
                            or byte [bp+6], 1
                            mov ah, 7
                            pop bp
                            iret

.int_13h_03h_hdd0:
                            push ds
                            push ax
                            push bx
                            push cx
                            push dx
                            push si
                            push di

                            call led_red_on
                            call led_yellow_on
                            xchg dh, dl
                            xor dh, dh  ; dx = head number
                            mov di, dx  ; di = head number
                            xor ah, ah
                            push ax  ; push number of sectors to write
                            mov ax, cx
                            xchg ah, al
                            rol ah, 1
                            rol ah, 1
                            and ah, 3  ; ax = cylinder number
                            mov si, 255 ; heads per cylinder
                            mul si  ; ax:dx = cylinder * heads_per_cylinder
                            add ax, di
                            adc dx, 0  ; ax:dx = cylinder * heads_per_cylinder + head
                            mov si, ax
                            mov di, dx  ; si:di = ax:dx

                            shl ax, 1
                            rcl dx, 1
                            shl ax, 1
                            rcl dx, 1
                            shl ax, 1
                            rcl dx, 1
                            shl ax, 1
                            rcl dx, 1
                            shl ax, 1
                            rcl dx, 1
                            shl ax, 1
                            rcl dx, 1
                            ;ax:dx = 64*(ax:dx)

                            sub ax, si
                            sbb dx, di  ; ax:dx = ax:dx - si:di = 63 * (cylinder * heads_per_cylinder + head)

                            xor ch, ch
                            and cl, 03Fh

                            dec cx
                            add ax, cx
                            adc dx, 0  ; ax:dx = 63 * (cylinder * heads_per_cylinder + head) + (Sector - 1)
                            ; ax:dx = LBA of first sector to write

                            pop cx  ; cx = number of sectors to write

.hdd_write_sector_loop:        call write_sd_lba
                            jc .write_error
                            add ax, 1
                            adc dx, 0
                            loop .hdd_write_sector_loop

                            call led_red_off
                            call led_yellow_off
                            pop di
                            pop si
                            pop dx
                            pop cx
                            pop bx
                            pop ax
                            pop ds

                            and byte [bp+6], 0FEh
                            xor ah, ah
                            pop bp
                            iret
.write_error:
                            call led_red_off
                            call led_yellow_off

                            mov ah, dl
                            xor al, al  ; yes, we destroy al, tsk tsk

                            pop di
                            pop si
                            pop dx
                            pop cx
                            pop bx
                            ;pop ax
                            add sp, 2
                            pop ds

                            or byte [bp+6], 1
                            pop bp
                            iret

write_sd_lba:               push dx
                            push ax
                            push ax
                            mov al, 0FFh
                            call ppi_send
                            mov al, ICH_COMMAND_SD_WRITE_SECTOR
                            call ppi_send
                            pop ax
                            call ppi_send
                            xchg ah, al
                            call ppi_send
                            xchg ax, dx
                            call ppi_send
                            xchg ah, al
                            call ppi_send
                            call wait_for_command_response
                            test al, al
                            jnz .write_sd_error

                            push cx
                            mov cx, 512

                            xchg bx, si

.write_sd_sector_bytes_loop:
                            es lodsb
                            call ppi_send
                            loop .write_sd_sector_bytes_loop

                            xchg bx, si

                            pop cx

                            call wait_for_command_response
                            test al, al
                            jnz .write_sd_error

                            pop ax
                            pop dx
                            clc
                            ret

.write_sd_error:
                            mov dl, al
                            pop ax
                            pop dx
                            stc
                            ret

int_13h_05h:                   or byte [bp+6], 1
                            mov ah, 3
                            pop bp
                            iret

                            ; called by dos 2.0+ with dl=80h to detect hard disks; fail for now
int_13h_08h:                test dl, 80h
                            jnz .int_13h_08h_hdd
                            or byte [bp+6], 1
                            mov ah, 1
                            pop bp
                            iret
.int_13h_08h_hdd:           cmp dl, 80h
                            je .int_13h_08h_hdd0
                            or byte [bp+6], 1
                            mov ah, 7
                            pop bp
                            iret
.int_13h_08h_hdd0:          ; TODO: check if MicroSD card is present
                            and byte [bp+6], 0FEh
                            mov cx, 0FFFFh
                            mov dx, 0FE01h
                            xor ah, ah
                            pop bp
                            iret


int_13h_15h:                ; TODO: implement?
                            or byte [bp+6], 1
                            mov ah, 1
                            pop bp
                            iret

int_13h_02h:                test dl, 80h
                            jnz int_13h_02h_hdd
                            push ds
                            push ax
                            push bx
                            push cx
                            push dx
                            push si
                            push di

                            call led_yellow_on
                            dec cl
                            xchg cl, ch
                            mov si, cx
                            and si, 0FFh
                            ;ifdef 9
                            mov di, si
                            ;endif 9
                            shl si, 1
                            shl si, 1
                            shl si, 1
                            ;ifdef 9
                            add si, di
                            ;endif 9
                            mov cl, ch
                            xor ch, ch
                            add si, cx
                            mov cl, 5
                            shl si, cl
                            add si, 0C000h
                            mov ds, si
                            xor si, si
                            mov di, bx
                            mov ch, al
                            xor cl, cl
                            rep movsw
                            call led_yellow_off

                            pop di
                            pop si
                            pop dx
                            pop cx
                            pop bx
                            pop ax
                            pop ds

                            and byte [bp+6], 0FEh
                            xor ah, ah
                            pop bp
                            iret

int_13h_02h_hdd:            cmp dl, 80h
                            je int_13h_02h_hdd0
                            or byte [bp+6], 1
                            mov ah, 7
                            pop bp
                            iret

int_13h_02h_hdd0:
                            push ds
                            push ax
                            push bx
                            push cx
                            push dx
                            push si
                            push di

                            call led_yellow_on
                            xchg dh, dl
                            xor dh, dh  ; dx = head number
                            mov di, dx  ; di = head number
                            xor ah, ah
                            push ax  ; push number of sectors to read
                            mov ax, cx
                            xchg ah, al
                            rol ah, 1
                            rol ah, 1
                            and ah, 3  ; ax = cylinder number
                            mov si, 255 ; heads per cylinder
                            mul si  ; ax:dx = cylinder * heads_per_cylinder
                            add ax, di
                            adc dx, 0  ; ax:dx = cylinder * heads_per_cylinder + head
                            mov si, ax
                            mov di, dx  ; si:di = ax:dx

                            shl ax, 1
                            rcl dx, 1
                            shl ax, 1
                            rcl dx, 1
                            shl ax, 1
                            rcl dx, 1
                            shl ax, 1
                            rcl dx, 1
                            shl ax, 1
                            rcl dx, 1
                            shl ax, 1
                            rcl dx, 1
                            ;ax:dx = 64*(ax:dx)

                            sub ax, si
                            sbb dx, di  ; ax:dx = ax:dx - si:di = 63 * (cylinder * heads_per_cylinder + head)

                            xor ch, ch
                            and cl, 03Fh

                            dec cx
                            add ax, cx
                            adc dx, 0  ; ax:dx = 63 * (cylinder * heads_per_cylinder + head) + (Sector - 1)
                            ; ax:dx = LBA of first sector to read

                            pop cx  ; cx = number of sectors to read

.hdd_read_sector_loop:        call read_sd_lba
                            jc .read_error
                            add ax, 1
                            adc dx, 0
                            loop .hdd_read_sector_loop

                            call led_yellow_off

                            pop di
                            pop si
                            pop dx
                            pop cx
                            pop bx
                            pop ax
                            pop ds

                            and byte [bp+6], 0FEh
                            xor ah, ah
                            pop bp
                            iret
.read_error:
                            call led_yellow_off

                            mov ah, dl
                            xor al, al  ; yes, we destroy al, tsk tsk

                            pop di
                            pop si
                            pop dx
                            pop cx
                            pop bx
                            ;pop ax
                            add sp, 2
                            pop ds

                            or byte [bp+6], 1
                            pop bp
                            iret

read_sd_lba:                push dx
                            push ax
                            push ax
                            mov al, 0FFh
                            call ppi_send
                            mov al, ICH_COMMAND_SD_READ_SECTOR
                            call ppi_send
                            pop ax
                            call ppi_send
                            xchg ah, al
                            call ppi_send
                            xchg ax, dx
                            call ppi_send
                            xchg ah, al
                            call ppi_send
                            call wait_for_command_response
                            test al, al
                            jnz .read_sd_error

                            push cx
                            mov cx, 512

                            xchg bx, di

.read_sd_sector_bytes_loop:    in al, PPI_Port_C
                            test al, 00100000b  ; Input Buffer Full?
                            jz .read_sd_sector_bytes_loop
                            in al, PPI_Port_A
                            stosb
                            loop .read_sd_sector_bytes_loop

                            xchg bx, di

                            pop cx

                            pop ax
                            pop dx
                            clc
                            ret

.read_sd_error:
                            mov dl, al
                            pop ax
                            pop dx
                            stc
                            ret

int_14h_handler:            iret
int_15h_msg:                db 'INT 15h', 0
int_15h_handler:
                            %ifdef TRACE_INT15
                            call print_msg
                            dw int_15h_msg
                            call print_regs
                            %endif

                            mov ah, 86h
                            stc
                            retf 2

int_16h_msg:                db 'INT 16h', 0
int_16h_handler:
                            %ifdef TRACE_INT16
                            call print_msg
                            dw int_16h_msg
                            call print_regs
                            %endif

                            cmp ah, 0
                            je .wait_for_keystroke
                            cmp ah, 1
                            je .check_for_keystroke
                            cmp ah, 2
                            je .get_shift_flags

                            call print_msg
                            dw int_16h_unsupported_msg
                            call print_regs
                            call print_msg
                            dw crlf_msg
                            iret

.get_shift_flags:           push ds
                            push ax
                            xor ax, ax
                            mov ds, ax
                            pop ax
                            mov al, [0417h]
                            pop ds
                            iret

.wait_for_keystroke:        push ds
                            push bx
                            push si

.wait_for_keystroke_loop:    call read_keystrokes_from_8255
                            mov ax, 40h
                            mov ds, ax
                            mov bx, [1ah]
                            cmp bx, [1ch]
                            je .wait_for_keystroke_loop
                            mov ax, [bx]  ; read keystroke
                            lea si, [bx+2]
                            cmp si, [82h]
                            jb .no_wraparound
                            mov si, [80h]
.no_wraparound:                mov [1ah], si  ; update kbd head
                            pop si
                            pop bx
                            pop ds
                            iret

.check_for_keystroke:       push bp
                            mov bp, sp
                            push ds
                            push bx
                            push ax

                            call read_keystrokes_from_8255
                            mov ax, 40h
                            mov ds, ax
                            mov bx, [1ah]
                            cmp bx, [1ch]
                            je .no_keystroke
                            mov ax, [bx]  ; read keystroke
                            pop bx  ; discard saved bx (we need to return our ax)
                            and byte [bp+6], 0BFh  ; ZF clear = keystroke available
                            jmp .done

.no_keystroke:              or byte [bp+6], 40h  ; ZF set = no keystroke
                            pop ax
.done:
                            pop bx
                            pop ds
                            pop bp
                            iret


wait_for_command_response:  in al, PPI_Port_C
                            test al, 00100000b  ; Input Buffer Full?
                            jz wait_for_command_response
                            in al, PPI_Port_A
                            cmp al, 0FFh
                            je .got_ff
                            call add_keystroke_to_kbdbuffer
                            jmp wait_for_command_response
.got_ff:                    in al, PPI_Port_C
                            test al, 00100000b  ; Input Buffer Full?
                            jz .got_ff
                            in al, PPI_Port_A
                            ret

read_keystrokes_from_8255:
                            push ds
                            push ax
                            push bx
                            push cx
                            mov bx, 40h
                            mov ds, bx

                            mov bx, [1ch]  ; kbd buf tail
                            lea bx, [bx + 2]  ; si = kbd buf tail advance
                            cmp bx, [82h]
                            jb .no_wraparound
                            mov bx, [80h]
.no_wraparound:             cmp bx, [1ah]  ; kbd buf full?
                            je .kbd_buf_full

                            in al, PPI_Port_C
                            test al, 00100000b  ; Input Buffer Full?
                            jz .no_new_data
                            in al, PPI_Port_A
                            mov ah, al
                            mov cx, 65535  ; timeout for the loop
.wait_for_second_key_byte:  dec cx
                            jcxz .no_new_data
                            in al, PPI_Port_C
                            test al, 00100000b  ; Input Buffer Full?
                            nop
                            nop
                            nop
                            nop
                            nop
                            nop
                            jz .wait_for_second_key_byte
                            in al, PPI_Port_A
                            call add_keystroke_to_kbdbuffer
.kbd_buf_full:
.no_new_data:               pop cx
                            pop bx
                            pop ax
                            pop ds
                            ret

add_keystroke_to_kbdbuffer:    push ds
                            push bx
                            push si

                            mov bx, 40h
                            mov ds, bx
                            mov bx, [1ch]  ; kbd buf tail
                            lea si, [bx + 2]  ; si = kbd buf tail advance
                            cmp si, [82h]
                            jb .no_wraparound
                            mov si, [80h]
.no_wraparound:             cmp si, [1ah]  ; kbd buf full?
                            je .kbd_buf_full

                            mov [bx], ax   ; save key to buf
                            mov [1ch], si  ; update kbf buf tail
.kbd_buf_full:

                            pop si
                            pop bx
                            pop ds
                            ret


int_17h_handler:            iret

int_18h_msg:                db 'INT 18h', 13, 10, 0
int_18h_handler:            call print_msg
                            dw int_18h_msg
.endless:                   jmp .endless

int_19h_handler:            call .try_hdd_boot
                            mov ax, 0201h
                            mov cx, 1
                            xor dx, dx
                            push dx
                            pop es
                            mov bx, 7C00h
                            int 13h
                            xor dx, dx
                            cld
                            jmp 0000h:7C00h

.try_hdd_boot:
                            mov ax, 0201h
                            mov cx, 1
                            xor dx, dx
                            push dx
                            pop es
                            mov dx, 80h
                            mov bx, 7C00h
                            int 13h
                            jc .hdd_boot_failed
                            mov dx, 80h
                            cld
                            jmp 0000h:7C00h
.hdd_boot_failed:           ret

int_1Ah_msg:                db 'INT 1A', 0

int_1Ah_handler:
                            %ifdef TRACE_INT1A
                            call print_msg
                            dw int_1Ah_msg
                            call print_regs
                            %endif
                            cmp ah, 0
                            je int_1Ah_get_system_time
                            cmp ah, 1
                            je int_1Ah_set_system_time
                            iret

int_1Ah_get_system_time:    push ds
                            xor dx, dx
                            mov ds, dx
                            mov dx, [046Ch]
                            mov cx, [046Eh]
                            mov al, [0470h]
                            mov byte [0470h], 0
                            pop ds
                            iret

int_1Ah_set_system_time:    push ds
                            push dx
                            xor dx, dx
                            mov ds, dx
                            pop dx
                            mov [046Ch], dx
                            mov [046Eh], cx
                            mov byte [0470h], 0
                            pop ds
                            iret

int_1Bh_handler:            iret
int_1Ch_handler:            iret

irq0_handler:
                            push ax
                            push bx
                            push cx
                            push dx
                            push si
                            push di
                            push bp
                            push es
                            push ds

                            mov al, 20h
                            out PIC_8259A_Port0, al

                            call print_msg
                            dw irq0_msg

                            pop ds
                            pop es
                            pop bp
                            pop di
                            pop si
                            pop dx
                            pop cx
                            pop bx
                            pop ax
                            iret
irq1_handler:
                            push ax
                            push bx
                            push cx
                            push dx
                            push si
                            push di
                            push bp
                            push es
                            push ds

                            mov al, 20h
                            out PIC_8259A_Port0, al

                            call print_msg
                            dw irq1_msg

                            pop ds
                            pop es
                            pop bp
                            pop di
                            pop si
                            pop dx
                            pop cx
                            pop bx
                            pop ax
                            iret
irq2_handler:
                            push ax
                            push bx
                            push cx
                            push dx
                            push si
                            push di
                            push bp
                            push es
                            push ds

                            mov al, 20h
                            out PIC_8259A_Port0, al

                            call print_msg
                            dw irq2_msg

                            pop ds
                            pop es
                            pop bp
                            pop di
                            pop si
                            pop dx
                            pop cx
                            pop bx
                            pop ax
                            iret
irq3_handler:
                            push ax
                            push bx
                            push cx
                            push dx
                            push si
                            push di
                            push bp
                            push es
                            push ds

                            mov al, 20h
                            out PIC_8259A_Port0, al

                            call print_msg
                            dw irq3_msg

                            pop ds
                            pop es
                            pop bp
                            pop di
                            pop si
                            pop dx
                            pop cx
                            pop bx
                            pop ax
                            iret
irq4_handler:
                            push ax
                            push bx
                            push cx
                            push dx
                            push si
                            push di
                            push bp
                            push es
                            push ds

                            mov al, 20h
                            out PIC_8259A_Port0, al

                            call print_msg
                            dw irq4_msg

                            pop ds
                            pop es
                            pop bp
                            pop di
                            pop si
                            pop dx
                            pop cx
                            pop bx
                            pop ax
                            iret
irq5_handler:
                            push ax
                            push bx
                            push cx
                            push dx
                            push si
                            push di
                            push bp
                            push es
                            push ds

                            mov al, 20h
                            out PIC_8259A_Port0, al

                            call print_msg
                            dw irq5_msg

                            pop ds
                            pop es
                            pop bp
                            pop di
                            pop si
                            pop dx
                            pop cx
                            pop bx
                            pop ax
                            iret
irq6_handler:
                            push ax
                            push bx
                            push cx
                            push dx
                            push si
                            push di
                            push bp
                            push es
                            push ds

                            mov al, 20h
                            out PIC_8259A_Port0, al

                            call print_msg
                            dw irq6_msg

                            pop ds
                            pop es
                            pop bp
                            pop di
                            pop si
                            pop dx
                            pop cx
                            pop bx
                            pop ax
                            iret
irq7_handler:
                            push ax
                            push bx
                            push cx
                            push dx
                            push si
                            push di
                            push bp
                            push es
                            push ds

                            mov al, 20h
                            out PIC_8259A_Port0, al

                            call print_msg
                            dw irq7_msg

                            pop ds
                            pop es
                            pop bp
                            pop di
                            pop si
                            pop dx
                            pop cx
                            pop bx
                            pop ax
                            iret

irq0_msg:                    db 'Got an IRQ 0!', 13, 10, 0
irq1_msg:                    db 'Got an IRQ 1!', 13, 10, 0
irq2_msg:                    db 'Got an IRQ 2!', 13, 10, 0
irq3_msg:                    db 'Got an IRQ 3!', 13, 10, 0
irq4_msg:                    db 'Got an IRQ 4!', 13, 10, 0
irq5_msg:                    db 'Got an IRQ 5!', 13, 10, 0
irq6_msg:                    db 'Got an IRQ 6!', 13, 10, 0
irq7_msg:                    db 'Got an IRQ 7!', 13, 10, 0

print_msg:                  push bp
                            mov bp, sp
                            push ds
                            push si
                            push ax
                            pushf
                            cld
                            mov si, 0F000h
                            mov ds, si
                            mov si, [bp+2]
                            add word [bp+2], 2
                            mov si, [cs:si]

.print_loop:                lodsb
                            test al, al
                            jz .done
                            call ppi_send
                            jmp .print_loop
.done:
                            popf
                            pop ax
                            pop si
                            pop ds
                            pop bp
                            ret

int19_msg:                  db 'INT 19h boot!', 13, 10, 0

ppi_send:                   ; in: AL = byte to send
                            push ax
.obf_loop:                    in al, PPI_Port_C
                            test al, 10000000b
                            jz .obf_loop
                            pop ax
                            out PPI_Port_A, al
                            ret

print_al_nibble:            push ax
                            and al, 0Fh
                            cmp al, 10
                            jb .al_nibble_09
                            add al, 'A'-'0'-10
.al_nibble_09:              add al, '0'
                            mov ah, 0Eh
                            int 10h
                            pop ax
                            ret

print_al:                   push ax
                            shr al, 1
                            shr al, 1
                            shr al, 1
                            shr al, 1
                            call print_al_nibble
                            pop ax
                            call print_al_nibble
                            ret

print_ax:                   xchg ah, al
                            call print_al
                            xchg ah, al
                            call print_al
                            ret

print_bx:                   xchg ax, bx
                            call print_ax
                            xchg ax, bx
                            ret

print_cx:                   xchg ax, cx
                            call print_ax
                            xchg ax, cx
                            ret

print_dx:                   xchg ax, dx
                            call print_ax
                            xchg ax, dx
                            ret

print_si:                   xchg ax, si
                            call print_ax
                            xchg ax, si
                            ret

print_di:                   xchg ax, di
                            call print_ax
                            xchg ax, di
                            ret

print_bp:                   xchg ax, bp
                            call print_ax
                            xchg ax, bp
                            ret

print_ds:                   push ax
                            push ds
                            pop ax
                            call print_ax
                            pop ax
                            ret

print_es:                   push ax
                            push es
                            pop ax
                            call print_ax
                            pop ax
                            ret

print_ss:                   push ax
                            push ss
                            pop ax
                            call print_ax
                            pop ax
                            ret

print_regs:                 call print_msg
                            dw ax_msg
                            call print_ax
                            call print_msg
                            dw bx_msg
                            call print_bx
                            call print_msg
                            dw cx_msg
                            call print_cx
                            call print_msg
                            dw dx_msg
                            call print_dx
                            call print_msg
                            dw si_msg
                            call print_si
                            call print_msg
                            dw di_msg
                            call print_di
                            call print_msg
                            dw bp_msg
                            call print_bp
                            call print_msg
                            dw ds_msg
                            call print_ds
                            call print_msg
                            dw es_msg
                            call print_es
                            call print_msg
                            dw ss_msg
                            call print_ss

                            ret
ax_msg:                     dw ' AX=', 0
bx_msg:                     dw ' BX=', 0
cx_msg:                     dw ' CX=', 0
dx_msg:                     dw ' DX=', 0
si_msg:                     dw ' SI=', 0
di_msg:                     dw ' DI=', 0
bp_msg:                     dw ' BP=', 0
ds_msg:                     dw ' DS=', 0
es_msg:                     dw ' ES=', 0
ss_msg:                     dw ' SS=', 0

led_green_on:               push ds
                            push ax
                            xor ax, ax
                            mov ds, ax
                            or byte [LED_ADDR], 1
                            pop ax
                            call light_leds
                            pop ds
                            ret

led_green_off:              push ds
                            push ax
                            xor ax, ax
                            mov ds, ax
                            and byte [LED_ADDR], 6
                            pop ax
                            call light_leds
                            pop ds
                            ret

led_yellow_on:              push ds
                            push ax
                            xor ax, ax
                            mov ds, ax
                            or byte [LED_ADDR], 2
                            pop ax
                            call light_leds
                            pop ds
                            ret

led_yellow_off:             push ds
                            push ax
                            xor ax, ax
                            mov ds, ax
                            and byte [LED_ADDR], 5
                            pop ax
                            call light_leds
                            pop ds
                            ret

led_red_on:                 push ds
                            push ax
                            xor ax, ax
                            mov ds, ax
                            or byte [LED_ADDR], 4
                            pop ax
                            call light_leds
                            pop ds
                            ret

led_red_off:                push ds
                            push ax
                            xor ax, ax
                            mov ds, ax
                            and byte [LED_ADDR], 3
                            pop ax
                            call light_leds
                            pop ds
                            ret

                            ; As an easter egg, let's add some greetings to the other PC makers, just for fun ;-)
                            ; And, btw, this is the ROM BASIC address in the original PC :)
                            times 06000h-($-$$) db 0
                            db 'KUR ZA APPLE! KUR ZA DELL! KUR ZA ACER! KUR ZA LENOVO! KUR ZA ASUS! KUR ZA HP!', 0

                            times 0EFC7h-($-$$) db 0
int_1Eh_handler:            ; diskette parameter table
                            db 0CFh  ;
                            db 2
                            db 025h  ; delay (in ticks) until motor turned off
                            db 2     ; bytes per sector (0=128; 1=256; 2=512; 3=1024)
                            db 8     ; sectors per track
                            db 02Ah  ; length of gap between sectors (2Ah for 5.25"; 1Bh for 3.5")
                            db 0FFh  ; data length (ignored if bytes-per-sector field nonzero)
                            db 050h  ; gap length when formatting (50h for 5.25"; 6Ch for 3.5")
                            db 0F6h  ; format filler byte (default: 0F6h)
                            db 019h  ; head settle time in milliseconds
                            db 4     ; motor start time in 1/8 seconds

                            times 0F0A4h-($-$$) db 0
int_1Dh_handler:            ; video parameter tables
                            ; TODO: fill something here

                            times 0FFF0h-($-$$) db 0
                            ; reset conditions:
                            ; CS:IP = 0FFFFh:0000h
                            ; flags = f002
                            ; ss*16+sp = FFF5h  (sp = uninitialized?)
                            ; ss = 0000h
reset_vector:               jmp 0F000h:handle_reset

                            times 0FFF5h-($-$$) db 0
bios_date:                  db '02/14/17'

                            times 0FFFEh-($-$$) db 0
machine_type_code:          db 0FFh

                            times 010000h-($-$$) db 0
