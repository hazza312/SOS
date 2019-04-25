        # _syscall.s
        # initial syscall entry point for x86_64 architecture.

/****** Entry Point ***********************************************************/
        .section    .text
        .code64
        .globl      syscall_entry
        .globl      syscall__handle

syscall_entry:
        cli
        # r11 contains old rflags
        # rcx contains rip
        pushf
        push       %rcx
        # andq       16, %rsp
        # sti
        call       syscall__handle
.done$: # jmp        .done$
        # do some stuff here to setup for returning.
        pop        %rcx
        pop        %r11
        sysretq
