OUTPUT_FORMAT(binary)
TARGET(elf32-i386)
ENTRY(main)

SECTIONS {
  . = 0x1000;
  .text . :
  {
    *(.text)
  }
}
