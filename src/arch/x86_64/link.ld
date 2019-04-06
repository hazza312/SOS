
ENTRY(_entry)
STARTUP(init.o)
OUTPUT_FORMAT(elf64-x86-64)

SECTIONS {
    . = 0x100000;
   .text : { 
       *(.multiboot_header)
       *(.stubs)
      init.o(.entry)
      *(.text)      
   }

      /DISCARD/ : {
       *(.eh_frame)
       *(.debug_info)
       *(.debug_abbrev)
       *(.debug_aranges)
       *(.debug_line)
       *(.debug_str)

   }

   .bss  : { 
      *(.bss)
   }
   
   .data : {
      *(.data)
   }


}