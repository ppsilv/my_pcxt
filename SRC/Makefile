# Makefile - GNU Makefile
# 
# Copyright (C) 2010 - 2023 Sergey Kiselev.
# Provided for hobbyist use on the Xi 8088 and Micro 8088 boards.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Flash ROM IC type (as supported by minipro programmer)
FLASH_ROM=AT29C512
#FLASH_ROM=AT28C256
#FLASH_ROM=AT28C64

#SOURCES=bios.asm macro.inc at_kbc.inc config.inc errno.inc flash.inc floppy1.inc floppy2.inc keyboard.inc misc.inc printer1.inc printer2.inc ps2aux.inc scancode.inc serial1.inc serial2.inc setup.inc sound.inc time1.inc time2.inc video.inc cpu.inc messages.inc inttrace.inc rtc.inc fnt00-7F.inc fnt80-FF.inc
SOURCES=mybios.asm

#IMAGES=bios-micro8088-noide.rom bios-micro8088-xtide.rom bios-sergey-xt-noide.rom bios-sergey-xt-xtide.rom bios-xi8088-noide.rom bios-xi8088-xtide.rom bios-book8088-xtide.rom bios-book8088-xtide-v20.rom bios-xt.bin bios-homebrew8088.bin
IMAGES=mybios.rom
FLASH_IMAGE=mybios.rom

all: Makefile $(SOURCES) $(IMAGES)

mybios.bin: $(SOURCES)
	nasm -DMACHINE_FE2010A -O9 -f bin -o mybios.bin -l mybios.lst mybios.asm


mybios.rom: mybios.bin
	dd if=/dev/zero ibs=1k count=40 | LANG=C tr "\000" "\377" > mybios.rom
	cat mybios.bin >> mybios.rom
	dd if=/dev/zero ibs=1k count=64 | LANG=C tr "\000" "\377" >> mybios.rom

clean:
	rm -f mybios.lst mybios.lst mybios.bin $(IMAGES)

flash:
	minipro -p $(FLASH_ROM) -w mybios.bin
