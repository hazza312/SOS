        # IDT.s
        # initial IDT 

        # sadly, when an exception occurs, we don't necessarily know which 
        # exception was called if we use the same handler for each exception.
        # And having multiple default handlers for every exception is a bit OTT.
        # So, we can use a small stub that loads %rdi with the interrupt 
        # number, before jumping to the real Ada routine, who can take 
        # appropriate action.        

        .equ    STUB_WIDTH, 0x10
        .equ    STUB_BASE,  0x100020

        .globl  STUB_BASE
        .globl  ldtinfo


/****** IDT Table *************************************************************/
        .macro IDT selector offset ist type dpl p
            .align 16
            .short  \offset & 0xffff
            .short  \selector
            .byte   \ist & 0b111
            .byte   (\type & 0xf) | (\dpl<<5) | (\p<<7)
            .short  \offset>>16
            .quad   \offset>>32
            .quad   0
        .endm

        .macro Make_Table i_no last 
            IDT 0x10, (STUB_BASE + (\i_no * STUB_WIDTH)), 0, 0xF, 0, 1            
            .if \i_no - \last 
                Make_Table \i_no+1, \last
            .endif
        .endm 

        .section .data
        .align  64

LDT:    Make_Table 0    63
.end$:  # interrupt table generated here

ldtinfo:.short 	.end$ -LDT -1					# LDT Table limit
		.quad 	LDT	 							# Base Address of LDT Table


/****** Stubs *****************************************************************/
        .macro Make_Stubs i_no last 
            .align STUB_WIDTH
            movq    \i_no, %rdi 
            jmp     except
            # hand assemble these instructions to ensure they are "packed"
            # .byte   0xb0                 # mov imm8, al
            # .byte   \i_no                # exception number
            # jmp     except

            .if \i_no - \last 
                Make_Stubs \i_no+1, \last
            .endif
        .endm 

        .section .stubs
        .align 16
stubs:  Make_Stubs 0    63
        # Stubs generated here..

except: cli
        jmp _ada_cpu_exception
