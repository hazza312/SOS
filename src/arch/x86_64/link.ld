
ENTRY(_entry)
OUTPUT_FORMAT(elf64-x86-64)

SECTIONS {

	. = 1M;
  .boot ALIGN(0x1000) : { *(.multiboot_header) }
  
  .text : { *(.text) }
}