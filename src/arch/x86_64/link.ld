
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
   .bss 0x102000 : { 
      init.o(.bss)
      *(.bss)
   }
   .data 0x10A000 : {
      init.o(.data)
      *(.data)
   }


}