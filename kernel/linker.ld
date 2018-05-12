OUTPUT_FORMAT(binary)
TARGET(elf32-i386)
ENTRY(main)

SECTIONS {
  . = 0x10000;
  .text . :
  {
    *(.text)
  }
}
