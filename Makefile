build: target/riscv32imac-unknown-none-elf/debug/atomos

target/riscv32imac-unknown-none-elf/debug/atomos:
	cargo build --target riscv32imac-unknown-none-elf

clean:
	cargo clean
