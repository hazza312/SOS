
ENTRY(_entry)
STARTUP(init.o)
OUTPUT_FORMAT(elf64-x86-64)

SECTIONS {

   . = 1M ;
   .boot : { 
    *(.multiboot_header)  
      }
   .text : { 
      init.o(.entry)
      *(.text)
   }
   .bss : { *(.bss) }


}