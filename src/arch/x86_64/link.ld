
ENTRY(_entry)
STARTUP(init.o)
OUTPUT_FORMAT(elf64-x86-64)

SECTIONS {
   . = 0x10000;
   .boot ALIGN(64) : { *(.multiboot_header) }

   . = 0x10010;
   .text : { 
      init.o(.entry)
      *(.text)
   }
   .bss 0x11000 : { 
      init.o(.bss)
      *(.bss)
   }
   .data 0x15000 : {
      init.o(.data)
      *(.data)
   }


}