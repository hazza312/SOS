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
pdt:    .space  0x1000                             # Page-Directory Table
pt:     .space  0x1000                             # Page table
stack:  .space  0x1000
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

        .macro TSS_Entry base limit type DPL P     # AMD P91
            .short  \limit & 0xffff
            .short  \base & 0xffff
            .byte   (\base >> 16) & 0xff
            .byte   (\type<<0)|(\DPL<<5)|(\P<<7) 
            .byte   ((\limit>>16) & 0xf)
            .byte   (\base >> 24) & 0xff
            .word   (\base >> 32) & 0xffffffff
            .word   0
        .endm

        .section .data                               # see AMD64 P88
        .globl     bootinfo
        .align     0x1000                            # align on a page boundary 

GDT:    /**********  base limit    code A RW EC DPL P AVL L DB G */    
.0x00$: GDT_Entry    0    0xffffff  0    0 0  0  0   0 0   1 0  0        # null
.0x08$: GDT_Entry    0    0xffffff  0    0 0  0  0   0 0   1 0  0        # null
.0x10$: GDT_Entry    0    0xffffff  1    0 1  0  0   1 0   1 0  1        # CPL0
.0x18$: GDT_Entry    0    0xffffff  0    0 1  0  0   1 0   1 0  1        # CPL0
.0x20$: GDT_Entry    0    0xffffff  1    0 1  0  3   1 0   1 0  1        # CPL3
.0x28$: GDT_Entry    0    0xffffff  0    0 1  0  3   1 0   1 0  1        # CPL3

        .equ    tss_base, 0x12b080 

        /**********  base      limit    type         DPL P ************/
.0x30$: TSS_Entry    tss_base  100      0b1001       0   1
.end$:

gdtinfo:.short  100                      # GDT Table limit
        .quad   GDT                                # Base Address of GDT 


/****** .data section: TSS entry **********************************************/

# this is required only for multitasking, which we will setup later.
# However, it is easiest to set up the requisite structure here first.
# see P4375(!) INTEL 
        
        .section        .data
        .align          64
tss:    .space          25 * 8


bootinfo:
        .quad     0                                # save the info here for later


/****** Kernel Entry Point ****************************************************/
        .equ    PTE_PS,     (1<<7)
        .equ    PTE_W,      (1<<1)
        .equ    PTE_P,      (1<<0)
        .equ    CR4_PAE,    (1<<5)

        .equ    MSR_EFER,   0xC0000080
        .equ    EEFR_LME,   (1<<8)
        .equ    EEFT_SCE,   (1<<0)

        .equ    MSR_STAR,   0xC0000081  # p153
        .equ    MSR_LSTAR,  0xC0000082
        .equ    MSR_CSTAR,  0xC0000083
        .equ    MSR_SFMASK, 0xC0000084

        .equ    CR0_PG,     (1<<31)

        .section .entry
        .global    _entry
        .extern _ada_kernel                     # continue Ada kernel when ready
        .code32                                 # 32-bit code for now, please

        
_entry:
        movl     $stack_end, %esp               # ensure SP in paged region
        movl     %ebx, (bootinfo)

                                                
.init_page_tables:
                                             # see P135 in AMD64SP
        movl    $pml4t, %eax            
        movl    $pdpt,                  (pml4t) # pdpt is 0th entry of pml4t
        orl     $(PTE_W|PTE_P),         (pml4t) # table is present, W

        movl    $pdt,                  (pdpt)  # pdt is 0th entry of pdt
        orl     $(PTE_W|PTE_P),        (pdpt)  # table is present, W
        orl     $(PTE_W|PTE_P|PTE_PS), (pdt)   # (physical base is 0). 2M page.
                                               # see P439 on enabling long mode.

        movl    $pdt, %eax
        movl    $(0x200000 |PTE_W|PTE_P|PTE_PS) , 1*8(%eax)

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
        orl     $(EEFR_LME | EEFT_SCE), %eax      # might as well enable   
        wrmsr                                     # syscall while we're here (P56/152)

.enable_paging$:
        movl    %cr0, %eax
        orl     $CR0_PG, %eax        
        movl    %eax, %cr0

.leap_of_faith$:
        lgdt    gdtinfo
        jmp     $0x10, $next                # pray for no page faults

        .code64        
next:   lidt    idtinfo
                                        # setup syscall/sysret before kerneling
        # load STAR
        movq    $MSR_STAR, %rcx        
        .equ    SYSRET_CS,      ((0x20 << 3) | 3)
        .equ    SYSCALL_CS,     (0x10 << 3)
        rdmsr
        movq   $0xffffffffffffffff, %rdi # todo change
        orq    %rdi, %rax
        wrmsr  

        # load TR with out TSS segment above 
        movw   $0x30, %ax
        ltr     %ax

        # load LSTAR
        .globl  syscall_entry
        movq    $MSR_LSTAR, %rcx
        movq    $syscall_entry, %rax
        wrmsr

        call     _ada_kernel
        
never:  jmp     never            
