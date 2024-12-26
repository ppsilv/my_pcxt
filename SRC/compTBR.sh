#!/bin/bash

nasm  -O9 -f bin -o testBootRecord.bin -l testBootRecord.lst testBootRecord.asm
