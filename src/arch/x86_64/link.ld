
ENTRY(_entry)
STARTUP(init.o)
OUTPUT_FORMAT(elf64-x86-64)

SECTIONS {
    . = 0x100000;
   .text : { 
       *(.multiboot_header)
      init.o(.entry)
      *(.text)
   }

   .bss  : { 
      *(.bss)
   }
   
   .data : {
      *(.data)
   }


}