
ENTRY(_entry)
STARTUP(init.o)
OUTPUT_FORMAT(elf64-x86-64)

SECTIONS {
   . = 0x100000;
   .boot ALIGN(64) : { *(.multiboot_header) }

   . = 0x100010;
   .text : { 
      init.o(.entry)
      *(.text)
   }
   .bss 0x103000 : { 
      init.o(.bss)
      *(.bss)
   }
   .data 0x10F000 : {
      init.o(.data)
      *(.data)
   }


}