.PHONY: all
all: bios_8088_256k.bin bios_8086_256k.bin bios_8086_256k_lo.bin bios_8086_256k_hi.bin

.PHONY: clean
clean:
	rm -rf f000_8088.bin f000_8086.bin bios_8088_256k.bin bios_8086_256k.bin bios_8086_512k.bin bios_8086_256k_lo.bin bios_8086_256k_hi.bin 160kfloppyfill.bin 180kfloppyfill.bin

bios_8088_256k.bin: freedos12_180k.img 180kfloppyfill.bin f000_8088.bin
ifeq ($(OS),Windows_NT)
	copy /b freedos12_180k.img+180kfloppyfill.bin+f000_8088.bin bios_8088_256k.bin
else
	cat freedos12_180k.img 180kfloppyfill.bin f000_8088.bin > bios_8088_256k.bin
endif

bios_8086_256k.bin: freedos12_180k.img 180kfloppyfill.bin f000_8086.bin
ifeq ($(OS),Windows_NT)
	copy /b freedos12_180k.img+180kfloppyfill.bin+f000_8086.bin bios_8086_256k.bin
else
	cat freedos12_180k.img 180kfloppyfill.bin f000_8086.bin > bios_8086_256k.bin
endif

# TODO: We can support a 360 KB floppy image in the 512 KB BIOS image. But for
# now we haven't implemented it yet, so we just repeat the 256KB BIOS image twice.
bios_8086_512k.bin: bios_8086_256k.bin
ifeq ($(OS),Windows_NT)
	copy /b bios_8086_256k.bin+bios_8086_256k.bin bios_8086_512k.bin
else
	cat bios_8086_256k.bin bios_8086_256k.bin > bios_8086_512k.bin
endif

bios_8086_256k_lo.bin: bios_8086_512k.bin
	split_odd_even bios_8086_512k.bin bios_8086_256k_lo.bin bios_8086_256k_hi.bin

bios_8086_256k_hi.bin: bios_8086_256k_lo.bin

160kfloppyfill.bin: 160kfloppyfill.asm
	nasm -o 160kfloppyfill.bin 160kfloppyfill.asm

180kfloppyfill.bin: 180kfloppyfill.asm
	nasm -o 180kfloppyfill.bin 180kfloppyfill.asm

f000_8088.bin: f000.asm ich_cmds.asm
	nasm -o f000_8088.bin f000.asm

f000_8086.bin: f000.asm ich_cmds.asm
	nasm -o f000_8086.bin -D__8086__ f000.asm
