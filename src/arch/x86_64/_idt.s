        # IDT.s
        # initial IDT 

        # sadly, when an exception occurs, we don't necessarily know which 
        # exception was called if we use the same handler for each exception.
        # And having multiple default handlers for every exception is a bit OTT.
        # So, we can use a small stub that loads %rdi with the interrupt 
        # number, before jumping to the real Ada routine, who can take 
        # appropriate action.        

        .equ    STUB_WIDTH, 0x04
        .equ    STUB_BASE,  0x100018

        .globl  idtinfo

/****** IDT Table *************************************************************/
        .macro IDT selector offset ist type dpl p
            .align 16
            .short  \offset & 0xffff
            .short  \selector
            .byte   \ist & 0b111
            .byte   (\type & 0xf) | (\dpl<<5) | (\p<<7)
            .short  \offset>>16
            .long   \offset>>32
            .long   0
        .endm

        .macro Make_Table i_no last 
            .equ addr, STUB_BASE + ((\i_no) * STUB_WIDTH)
            IDT 0x10, addr, 0, 0xF, 0, 1            
            .if \i_no - \last 
                Make_Table \i_no+1, \last
            .endif
        .endm 

        .section .data
        .align  64

IDT:    Make_Table 0, 63
        # IDT expands here
.end$:  

idtinfo:.short 	.end$ -IDT -1	# LDT Table limit
		.quad 	IDT	# Base Address of LDT Table

/****** Registered Handlers ***************************************************/
        .section .bss 
        .globl handler_table
        .align 8
handler_table:
        .space 63 * 8


/****** Stubs *****************************************************************/
        .macro Make_Stubs i_no last 
            .align STUB_WIDTH

            # hand assemble, so each entry is only 4 bytes
             .byte   0xb0      # mov imm8, al
             .byte   \i_no     # exception number
             .byte   0xeb      # jmp rel8 
             .if (((\last) - (\i_no)) * STUB_WIDTH) > 0x7f
                .byte   0x7e   # bunnyhop
             .else 
                .byte   ((\last) - (\i_no)) * STUB_WIDTH
             .endif

             # we can directly jump with a relative offset of up to +127 to
             # <except> when the table is small enough. I might want to use this
             # for debugging higher (external) interrupts later, so will need a
             # bigger table. So bunnyhop to <except> if we are too far away,
             # , else jump there directly.  

            .if \i_no - \last 
                Make_Stubs \i_no+1, \last
            .endif
        .endm 

        .section .stubs
        .align STUB_WIDTH
stubs:  Make_Stubs 0 63
        # Stubs expands here..


handler:
        andq    $0xff, %rax
        push    %rax
        movq    handler_table(,%rax,8), %rdi
        test    %rdi, %rdi 
        jz      _ada_cpu_exception
        call    *%rdi


        pop     %rax 
        cmp     $0x28, %rax 
        jge     .master$
         movb    $0x20, %al
         outb    %al, $0x20
.master$:
         movb    $0x20, %al
         outb    %al, $0x20
        iretq
