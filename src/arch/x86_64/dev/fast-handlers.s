        .globl    pit_8253_tick_count
        .globl    pit_8253_handler
        
        .section .text
        .code64


/****** X86.Dev.PIT_8253 ******************************************************/
        .global    x86_dev_pit_8253_ticks
        .global    x86_dev_pit_8253_handler
x86_dev_pit_8253_handler:
        incq        x86_dev_pit_8253_ticks
        iretq


/****** X86.Dev.RTC ***********************************************************/
        .global    x86_dev_rtc_ticks
        .global    x86_dev_rtc_handler
x86_dev_rtc_handler:
        incq        x86_dev_rtc_ticks
        push        %rax
        movb        $0x0c, %al 
        outb        %al, $0x70
        inb         $0x71, %al        
        pop         %rax
        iretq
