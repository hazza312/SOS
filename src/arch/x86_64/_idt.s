        # IDT.s
        # initial IDT 

        # sadly, when an exception occurs, we don't necessarily know which 
        # exception was called if we use the same handler for each exception.
        # And having multiple default handlers for every exception is a bit OTT.
        # So, we can use a small stub that loads %rdi with the interrupt 
        # number, before jumping to the real Ada routine, who can take 
        # appropriate action.        

        .equ    STUB_WIDTH, 0x08
        .equ    STUB_BASE,  0x100018

        .globl  idtinfo
        .globl  IDT

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
            IDT 0x10, addr, 0, 0xE, 0, 1            
            .if \i_no - \last 
                Make_Table \i_no+1, \last
            .endif
        .endm 

        .section .data
        .align  64

IDT:    Make_Table 0, 63

.end$:  

idtinfo:.short 	.end$ -IDT -1	# LDT Table limit
		.quad 	IDT	# Base Address of LDT Table

/****** Registered Handlers ***************************************************/
        .section .bss 
        .globl handler_table
        .align 8
handler_table:
        .space 63 * 16


/****** Stubs *****************************************************************/
        .macro Make_Stubs i_no last 
            .align STUB_WIDTH

            # hand assemble, so each entry is only ~5 bytes
             .byte   0x50      # push rax
             .byte   0xb0      # mov imm8, al
             .byte   \i_no     # exception number
             jmp     handler

            .if \i_no - \last 
                Make_Stubs \i_no+1, \last
            .endif
        .endm 

        .section .stubs
        .align STUB_WIDTH
        .code64
stubs:  Make_Stubs 0 63
        # Stubs expands here..


handler:
        andq    $0xff, %rax
        push    %rdi
        movq    handler_table(,%rax,8), %rdi
        test    %rdi, %rdi
        jz      _ada_cpu_exception

        push    %rdx
        push    %rsi 
        push    %rcx 
        push    %r8 
        push    %r9 
        push    %r10 
        push    %r11 

        call    *%rdi

        pop     %r11 
        pop     %r10 
        pop     %r9 
        pop     %r8 
        pop     %rcx 
        pop     %rsi 
        pop     %rdx
        pop     %rdi 
        pop     %rax

.done$:
        iretq



