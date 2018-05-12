CC = clang
LD = ld
AS = nasm
TARGET = i386-unknown-none-elf

C_SOURCE = $(wildcard kernel/*.c drivers/*.c)
OBJ = ${C_SOURCE:.c=.o}

all: atomos.iso

run: atomos.iso
	qemu-system-i386 -drive format=raw,index=0,if=floppy,file=$^

atomos.iso: bootloader/boot.bin kernel/kernel.bin
	cat $^ > $@

bootloader/boot.bin: bootloader/boot.asm
	${AS} $< -f bin -o $@

kernel/kernel.bin: ${OBJ} kernel/linker.ld
	${LD} -m i386linux -o $@ -T kernel/linker.ld ${OBJ}

%.o : %.c
	${CC} -o $@ --target=${TARGET} -ffreestanding -c $<

%.o : %.asm
	${AS} $< -f elf -o $@

clean:
	rm -rf atomos.iso
	rm -rf kernel/*.o bootloader/*.bin drivers/*.o
