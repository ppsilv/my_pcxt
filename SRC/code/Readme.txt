00000 - 0FFFF ------> 64k
		0000:0000
		0000:FFFF 
10000 - 1FFFF ------>128k
		1000:0000
		1000:FFFF 
20000 - 2FFFF ------>192k
		2000:0000
		2000:FFFF 
30000 - 3FFFF ------>256k
		3000:0000
		3000:FFFF 
40000 - 4FFFF ------>320k
		4000:0000
		4000:FFFF 
50000 - 5FFFF ------>384k
		5000:0000
		5000:FFFF 
60000 - 6FFFF ------>445k
		6000:0000
		6000:FFFF 
70000 - 7FFFF ------>512
		7000:0000
		7000:FFFF 

80000 - 8FFFF ------>576k
		8000:0000
		8000:FFFF 
90000 - 9FFFF ------>640k
		9000:0000
		9000:FFFF 
A0000 - AFFFF ------>704k
		A000:0000
		A000:FFFF 
B0000 - BFFFF ------>768k
		B000:0000
		B000:FFFF 
C0000 - CFFFF ------>832k
		C000:0000
		C000:FFFF 
D0000 - DFFFF ------>896k
		D000:0000
		D000:FFFF 
E0000 - EFFFF ------>960k
		E000:0000
		E000:FFFF 
F0000 - FFFFF ------>1024k
		F000:0000
		F000:FFFF 


and so on:

PIC 8259
The PC/XT ISA system has one 8259 controller, and the port numbers for 
configuring it are:
    Port 0x20: The master PIC's port A
    Port 0x21: The master PIC's port B

The IBM PC XT uses a single 8259 Programmable Interrupt Controller (PIC) 
chip that interfaces with the system through the following I/O locations:
Ports 20h/0A0h: The command register, which is write only, and the status 
register, which is read only
Ports 21h/0A1h: Corresponds to the slave PIC 
8259 – The eCS Dump
The BIOS traditionally maps the 8259 PIC's eight interrupt requests (IRQs) 
to interrupts 8 to 15 (0x08 to 0x0F). 
The PIC manages hardware interrupt requests in an interrupt driven system 
environment. When an I/O device requires service, it signals the PIC via 
one of the PIC's seven interrupt request (IR) input lines. The PIC then 
activates the INT line, which is connected to the CPU INTR line. 


TIMER 8253
On PCs the address for timer0 (chip) is at port 40h..43h and the second 
timer1 (chip) is at 50h..53h.
    Port 40h
    Port 41h
    Port 42h
    Port 43h

On x86 PCs, many video card BIOS and system BIOS will reprogram the second 
counter for their own use. Reprogramming typically happens during video mode 
changes, when the video BIOS may be executed, and during system management 
mode and power saving state changes, when the system BIOS may be executed. 
This prevents any serious alternative uses of the timer's second counter on 
many x86 systems.

As stated above, Channel 0 is implemented as a counter. Typically, the 
initial value of the counter is set by sending bytes to the Control, then 
Data I/O Port registers (the value 36h sent to port 43h, then the low byte 
to port 40h, and port 40h again for the high byte). The counter counts down 
to zero, then sends a hardware interrupt (IRQ 0, INT 8) to the CPU. The 
counter then resets to its initial value and begins to count down again. 
The fastest possible interrupt frequency is a little over a half of a 
megahertz. The slowest possible frequency, which is also the one normally 
used by computers running MS-DOS or compatible operating systems, is about 
18.2 Hz. Under these real mode operating systems, the BIOS accumulates the 
number of INT 8 calls that it receives in real mode address 0040:006c, which 
can be read by a program.

Parallel Port
    LPT1: 0x378 (or occasionally 0x3BC) (IRQ 7)
    LPT2: 0x278 (IRQ 6). 

IBM defined three standard port base addresses for the parallel printer port 
in the IBM PC:
Port R/W IOAddr Bits Function: Data Out W Base+0 D0-D7 8 LS TTL outputs
Status In R Base+1 S3-S7 5 LS TTL inputs
Control Out W Base+2 C0-C3 4 TTL Open Collector outputs 
Common base addresses for parallel ports include: 
    LPT1: 0x378 (or occasionally 0x3BC) (IRQ 7)
    LPT2: 0x278 (IRQ 6). 
A parallel port is a type of interface that allows computers to connect to 
various peripherals. The most common configuration for a standard parallel 
port is the Centronics port, which has 25 pins.


PORTS Common I/O Port Addresses

	Port addresses are not always constant across PC, AT and PS/2
	Unless marked, port addresses are relative to PC and XT only

	000-00F  8237 DMA controller
	000 Channel 0 address register
	001 Channel 0 word count
	002 Channel 1 address register
	003 Channel 1 word count
	004 Channel 2 address register
	005 Channel 2 word count
	006 Channel 3 address register
	007 Channel 3 word count
	008 Status/command register
	009 Request register
	00A Mask register
	00B Mode register
	00C Clear MSB/LSB flip flop
	00D Master clear temp register
	00E Clear mask register
	00F Multiple mask register

	010-01F  8237 DMA Controller (PS/2 model 60 & 80), reserved (AT)

	020-02F  8259A Master Programmable Interrupt Controller
	020 8259 Command port  (see 8259)
	021 8259 Interrupt mask register  (see 8259)

	030-03F  8259A Slave Programmable Interrupt Controller (AT,PS/2)

	040-05F  8253 or 8254 Programmable Interval Timer (PIT, see ~8253~)
	040 8253 channel 0, counter divisor
	041 8253 channel 1, RAM refresh counter
	042 8253 channel 2, Cassette and speaker functions
	043 8253 mode control  (see 8253)
	044 8254 PS/2 extended timer
	047 8254 Channel 3 control byte

	060-067  8255 Programmable Peripheral Interface  (PC,XT, PCjr)
	060 8255 Port A keyboard input/output buffer (output PCjr)
	061 8255 Port B output
	062 8255 Port C input
	063 8255 Command/Mode control register

	060-06F  8042 Keyboard Controller  (AT,PS/2)
	060 8042 Keyboard input/output buffer register
	061 8042 system control port (for compatability with 8255)
	064 8042 Keyboard command/status register

	070 CMOS RAM/RTC, also NMI enable/disable (AT,PS/2, see RTC)
	071 CMOS RAM data  (AT,PS/2)

	080 Manufacturer systems checkpoint port (used during POST)
	080-090  DMA Page Registers
	081 High order 4 bits of DMA channel 2 address
	082 High order 4 bits of DMA channel 3 address
	083 High order 4 bits of DMA channel 1 address

	090-097  POS/Programmable Option Select  (PS/2)
	090 Central arbitration control Port
	091 Card selection feedback
	092 System control and status register
	094 System board enable/setup register
	095 Reserved
	096 Adapter enable/setup register
	097 Reserved

	0A0 NMI Mask Register (PC,XT) (write 80h to enable NMI, 00h disable)
	0A0-0BF  Second 8259 Programmable Interrupt Controller (AT, PS/2)
	0A0 Second 8259 Command port  (see 8259)
	0A1 Second 8259 Interrupt mask register  (see 8259)

	0C0 TI SN76496 Programmable Tone/Noise Generator (PCjr)
	0C0-0DF  8237 DMA controller 2 (AT)
	0C2 DMA channel 3 selector  (see ports 6 & 82)

	0E0-0EF  Reserved

	0F0-0FF  Math coprocessor (AT, PS/2)
	0F0-0F5  PCjr Disk Controller
	0F0 Disk Controller
	0F2 Disk Controller control port
	0F4 Disk Controller status register
	0F5 Disk Controller data port

	0F8-0FF  Reserved for future microprocessor extensions

	100-10F  POS Programmable Option Select (PS/2)
	100 POS Register 0, Adapter ID byte (LSB)
	101 POS Register 1, Adapter ID byte (MSB)
	102 POS Register 2, Option select data byte 1
	    Bit 0 is card enable (CDEN)
	103 POS Register 3, Option select data byte 2
	104 POS Register 4, Option select data byte 3
	105 POS Register 5, Option select data byte 4
	    Bit 7 is (-CHCK)
	    Bit 6 is reserved
	106 POS Register 6, subaddress extension (LSB)
	107 POS Register 7, subaddress extension (MSB)

	110-1EF  System I/O channel

	170-17F  Fixed disk 1 (AT)
	170 disk 1 data
	171 disk 1 error
	172 disk 1 sector count
	173 disk 1 sector number
	174 disk 1 cylinder low
	175 disk 1 cylinder high
	176 disk 1 drive/head
	177 disk 1 status

	1F0-1FF  Fixed disk 0 (AT)
	1F0 disk 0 data
	1F1 disk 0 error
	1F2 disk 0 sector count
	1F3 disk 0 sector number
	1F4 disk 0 cylinder low
	1F5 disk 0 cylinder high
	1F6 disk 0 drive/head
	1F7 disk 0 status

	200-20F  Game Adapter (see GAME PORT or ~JOYSTICK~)

	210-217  Expansion Card Ports (XT)
	210 Write: latch expansion bus data
	    read:  verify expansion bus data
	211 Write: clear wait,test latch
	    Read:  MSB of data address
	212 Read:  LSB of data address
	213 Write: 0=enable, 1=/disable expansion unit
	214-215  Receiver Card Ports
	214 write: latch data, read: data
	215 read:  MSB of address, next read: LSB of address

	21F Reserved

	220-26F  Reserved for I/O channel

	270-27F  Third parallel port (see ~PARALLEL PORT~)
	278 data port
	279 status port
	27A control port

	280-2AF  Reserved for I/O channel

	2A2-2A3  MSM58321RS clock

	2B0-2DF  Alternate EGA, or 3270 PC video (XT, AT)

	2E0 Alternate EGA/VGA
	2E1 GPIB Adapter  (AT)

	2E2-2E3  Data acquisition adapter (AT)

	2E8-2EF  COM4 non PS/2 UART (Reserved by IBM) (see ~UART~)

	2F0-2F7  Reserved

	2F8-2FF  COM2 Second Asynchronous Adapter (see UART)
		 Primary Asynchronous Adapter for PCjr

	300-31F  Prototype Experimentation Card (except PCjr)
		 Periscope hardware debugger
	320-32F  Hard Disk Controller  (XT)
	320 Read from/Write to controller
	321 Read: Controller Status, Write: controller reset
	322 Write: generate controller select pulse
	323 Write: Pattern to DMA and interrupt mask register
	    (see ports 0F,21,C2)
	324 disk attention/status

	330-33F  Reserved for XT/370

	340-35F  Reserved for I/O channel

	360-36F  PC Network

	370-377  Floppy disk controller (except PCjr)
	372 Diskette digital output
	374 Diskette controller status
	375 Diskette controller data
	376 Diskette controller data
	377 Diskette digital input

	378-37F  Second Parallel Printer (see ~PARALLEL PORT~)
		 First Parallel Printer (see PARALLEL PORT)
	378 data port
	379 status port
	37A control port

	380-38F  Secondary Binary Synchronous Data Link Control (SDLC) adapter
	380 On board 8255 port A, internal/external sense
	381 On board 8255 port B, external modem interface
	382 On board 8255 port C, internal control and gating
	383 On board 8255 mode register
	384 On board 8253 channel square wave generator
	385 On board 8253 channel 1 inactivity time-out
	386 On board 8253 channel 2 inactivity time-out
	387 On board 8253 mode register
	388 On board 8273 read: status; Write: Command
	389 On board 8273 write: parameter; read: response
	38A On board 8273 transmit interrupt status
	38B On board 8273 receiver interrupt status
	38C On board 8273 data

	390-39F  Cluster Adapter

	3A0-3AF  Primary Binary Synchronous Data Link Control (SDLC) adapter
	3A0 On board 8255 port A, internal/external sense
	3A1 On board 8255 port B, external modem interface
	3A2 On board 8255 port C, internal control and gating
	3A3 On board 8255 mode register
	3A4 On board 8253 counter 0 unused
	3A5 On board 8253 counter 1 inactivity time-outs
	3A6 On board 8253 counter 2 inactivity time-outs
	3A7 On board 8253 mode register
	3A8 On board 8251 data
	3A9 On board 8251 command/mode/status register

	3B0-3BF Monochrome Display Adapter (write only, see ~6845~)
	3B0 port address decodes to 3B4
	3B1 port address decodes to 3B5
	3B2 port address decodes to 3B4
	3B3 port address decodes to 3B5
	3B4 6845 index register, selects which register [0-11h]
	    is to be accessed through port 3B5
	3B5 6845 data register [0-11h] selected by port 3B4,
	    registers 0C-0F may be read.  If a read occurs without
	    the adapter installed, FFh is returned.  (see 6845)
	3B6 port address decodes to 3B4
	3B7 port address decodes to 3B5
	3B8 6845 Mode control register
	3B9 reserved for color select register on color adapter
	3BA status register (read only)
	3BB reserved for light pen strobe reset

	3BC-3BF  Primary Parallel Printer Adapter (see ~PARALLEL PORT~)
	3BC parallel 1, data port
	3BD parallel 1, status port
	3BE parallel 1, control port

	3C0-3CF  EGA/VGA
	3C0 VGA attribute and sequencer register
	3C1 Other video attributes
	3C2 EGA, VGA, CGA input status 0
	3C3 Video subsystem enable
	3C4 CGA, EGA, VGA sequencer index
	3C5 CGA, EGA, VGA sequencer
	3C6 VGA video DAC PEL mask
	3C7 VGA video DAC state
	3C8 VGA video DAC PEL address
	3C9 VGA video DAC
	3CA VGA graphics 2 position
	3CC VGA graphics 1 position
	3CD VGA feature control
	3CE VGA graphics index
	3CF Other VGA graphics

	3D0-3DF Color Graphics Monitor Adapter (ports 3D0-3DB are
		write only, see 6845)
	3D0 port address decodes to 3D4
	3D1 port address decodes to 3D5
	3D2 port address decodes to 3D4
	3D3 port address decodes to 3D5
	3D4 6845 index register, selects which register [0-11h]
	    is to be accessed through port 3D5
	3D5 6845 data register [0-11h] selected by port 3D4,
	    registers 0C-0F may be read.  If a read occurs without
	    the adapter installed, FFh is returned.  (see 6845)
	3D6 port address decodes to 3D4
	3D7 port address decodes to 3D5
	3D8 6845 Mode control register (CGA, EGA, VGA, except PCjr)
	3D9 color select palette register (CGA, EGA, VGA, see 6845)
	3DA status register (read only, see 6845, PCjr VGA access)
	3DB Clear light pen latch (any write)
	3DC Preset Light pen latch
	3DF CRT/CPU page register (PCjr only)

	3E8-3EF  COM3 non PS/2 UART (Reserved by IBM) (see ~UART~)

	3F0-3F7  Floppy disk controller (except PCjr)
	3F0 Diskette controller status A
	3F1 Diskette controller status B
	3F2 controller control port
	3F4 controller status register
	3F5 data register (write 1-9 byte command, see INT 13)
	3F6 Diskette controller data
	3F7 Diskette digital input

	3F8-3FF  COM1 Primary Asynchronous Adapter  (see ~UART~)

	3220-3227  PS/2 COM3 (see UART)
	3228-322F  PS/2 COM4 (see UART)
	4220-4227  PS/2 COM5 (see UART)
	4228-422F  PS/2 COM6 (see UART)
	5220-5227  PS/2 COM7 (see UART)
	5228-522F  PS/2 COM8 (see UART)

	- many cards designed for the ISA BUS only uses the lower 10 bits
	  of the port address but some ISA adapters use addresses beyond
	  3FF.  Any address that matches in the lower 10 bits will decode
	  to the same card.   It is up to the adapters to resolve or ignore
	  the high bits of the port addresses.   An example would be the
	  Cluster adapter that has a port address of 390h.  The second
	  cluster adapter has a port address of 790h which resolves to
	  the same port address with the cards determining which one
	  actually gets the data.