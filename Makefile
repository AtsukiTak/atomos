run: boot.bin
	qemu-system-i386 -drive format=raw,file=boot.bin

boot.bin: boot.asm
	nasm boot.asm -f bin -o boot.bin
