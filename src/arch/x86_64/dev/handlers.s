        .globl    pit_8253_tick_count
        .globl    pit_8253_handler
        
        .section .text
        .code64


/****** X86.Dev.PIT_8253 ******************************************************/
        .global    pit_8253_tick_count
        .global    pit_8253_handler
        .align     16
pit_8253_handler:
        incq        pit_8253_tick_count
        iretq


/****** X86.Dev.Keyboard ******************************************************/
        .global    x86_dev_keyboard_ticks
        .global    x86_dev_keyboard_handler
        .align     16
x86_dev_keyboard_handler:
        incq        x86_dev_keyboard_ticks
        push        %rax
        inb         $0x60, %al        
        pop         %rax
        iretq


