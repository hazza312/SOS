        # init.s
        # initial entry point for x86_64 architecture.
        # GRUB has already setup 32-bit protected mode for us.

/****** Multiboot header ******************************************************/
        .equ    MBH_MAGIC,      0xE85250D6
        .equ    MBH_ARCH,       0                    # i386, 32-bit protected 
        .equ    MBH_LENGTH,     end$ - MBH
        .equ    MBH_CHKSUM,     -(MBH_MAGIC+MBH_ARCH+MBH_LENGTH) & 0xffffffff

        .section .multiboot_header
        .align     64                           # spec requires 64-bit alignment
                                                # and whole header in first 64k 
MBH:    .long      MBH_MAGIC
        .long      MBH_ARCH
        .long      MBH_LENGTH
        .long      MBH_CHKSUM

        # final end tag: no more header
           .short     0                                  # tag type
           .short     0                                  # flags
           .long      8                                  # size
end$:

/****** .bss section: initial page tables *************************************/
        .section .bss
        .align  0x1000                             # align on a 4K boundary
pml4t:  .space  0x1000                             # Page Map Level 4 Table
pdpt:   .space  0x1000                             # Page-Directory Pointer table
pdt:    .space  0x1000                            # Page-Directory Table
stack:  .space  0x8000
stack_end:

        
/****** .data section: GDT entries ********************************************/
        .macro GDT_Entry base limit code A W E DPL P AVL L DBD G
            .short  \limit & 0xffff
            .short  \base & 0xffff
            .byte   (\base >> 16) & 0xff
            .byte   (\A<<0)|(\W<<1)|(\E<<2)|(\code<<3)|(1<<4)|(\DPL<<5)|(\P<<7) 
            .byte   ((\limit>>16) & 0xf)|(\L<<5)|(\AVL<<4)|(\DBD<<6)|(\G<<7)
            .byte   (\base >> 24) & 0xff
        .endm

        .section .data                               # see AMD64 P88
        .globl     bootinfo
        .align     0x1000                            # align on a page boundary 

GDT:    /**********  base limit    code A RW EC DPL P AVL L DB G */    
.0x00$: GDT_Entry    0    0        0    0 0  0  0   0 0   0 0  0
.0x08$: GDT_Entry    0    0        0    0 0  0  0   0 0   0 0  0
.0x10$: GDT_Entry    0    0xf0000  1    0 1  0  0   1 0   1 0  1
.0x18$: GDT_Entry    0    0        0    0 1  0  0   1 0   0 0  1
.end$:

gdtinfo:.short  .end$ -GDT -1                      # GDT Table limit
        .quad   GDT                                # Base Address of GDT Table

bootinfo:
        .quad     0                                # save the info here for later


/****** Kernel Entry Point ****************************************************/
        .equ    PTE_PS,     (1<<7)
        .equ    PTE_W,      (1<<1)
        .equ    PTE_P,      (1<<0)
        .equ    CR4_PAE,    (1<<5)
        .equ    MSR_EFER,   0xC0000080
        .equ    EEFR_LME,   (1<<8)
        .equ    CR0_PG,     (1<<31)

        .section .entry
        .global    _entry
        .extern _ada_kernel                     # continue Ada kernel when ready
        .code32                                 # 32-bit code for now, please

        
_entry:
        movl     $stack_end, %esp               # ensure SP in paged region
        movl     %ebx, (bootinfo)

.disable_blinky_cursor:                         # just as important as paging
        movb     $0xA, %al                      # TODO: move elsewhere
        movw     $0x3D4, %dx
        out      %al, %dx

        movb     $0x20, %al
        movw     $0x3D5, %dx
        out      %al, %dx
                                                
.init_page_tables:                             # see P135 in AMD64SP            
        movl    $pdpt,                 (pml4t) # pdpt is 0th entry of pml4t
        orl     $(PTE_W|PTE_P),        (pml4t) # table is present, W
        movl    $pdt,                  (pdpt)  # pdt is 0th entry of pdt
        orl     $(PTE_W|PTE_P),        (pdpt)  # table is present, W
        orl     $(PTE_W|PTE_P|PTE_PS), (pdt)   # (physical base is 0). 2M page.
                                               # see P439 on enabling long mode.
.load_cr3$:
        movl    $pml4t, %eax
        movl    %eax, %cr3    

.enable_pae$:        
        movl    %cr4, %eax
        orl     $CR4_PAE, %eax
        movl    %eax, %cr4 

.enable_lm$:
        movl    $MSR_EFER, %ecx
        rdmsr                        
        orl     $EEFR_LME, %eax         
        wrmsr                    

.enable_paging$:
        movl    %cr0, %eax
        orl     $CR0_PG, %eax        
        movl    %eax, %cr0

.leap_of_faith$:
        lgdt    gdtinfo
        jmp     $0x10, $next                # pray for no page faults

        .code64        
next:   lidt    idtinfo
        call     _ada_kernel
        
never:  jmp     never            
