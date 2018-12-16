TGT := riscv32imac-unknown-none-elf
LIBATOMOS := target/$(TGT)/debug/libatomos.a
SRCDIR := src
CELLAR_DIR := tools/cellar
TL_BIN_DIR := tools/bin

build: $(LIBATOMOS)

$(LIBATOMOS): $(SRCDIR)/*
	cargo build --target $(TGT)

clean:
	cargo clean

install-qemu: $(TL_BIN_DIR)/qemu

$(TL_BIN_DIR)/qemu:
	wget https://download.qemu.org/qemu-3.0.0.tar.xz -P $(CELLAR_DIR)
	tar xf $(CELLAR_DIR)/qemu-3.0.0.tar.xz -C $(CELLAR_DIR)
	rm -f $(CELLAR_DIR)/qemu-3.0.0.tar.xz
	cd $(CELLAR_DIR)/qemu-3.0.0 && mkdir build
	cd $(CELLAR_DIR)/qemu-3.0.0/build && ../configure --target-list=riscv32-softmmu
	cd $(CELLAR_DIR)/qemu-3.0.0/build && make
	ln -s ../cellar/qemu-3.0.0/build/riscv32-softmmu/qemu-system-riscv32 $(TL_BIN_DIR)/qemu
