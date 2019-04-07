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


/****** X86.Dev.Keyboard ******************************************************/
        .global    x86_dev_keyboard_ticks
        .global    x86_dev_keyboard_scancode_lut
        .global    x86_dev_keyboard_handler
        .global    x86_dev_keyboard_buffer
x86_dev_keyboard_handler:
        incq        x86_dev_keyboard_ticks
        push        %rax
        push        %rbx
        xor         %rax, %rax
        inb         $0x60, %al
        cmp         $0x80, %rax
        jl          .save
        mov         %rax, %rbx
        inb         $0x60, %al
        cmp         $0xf0, %rbx
        je         .done
        inb         $0x60, %al
        jmp         .done

.save:
       # addb        $0x0, %al
        movb        x86_dev_keyboard_scancode_lut(,%rax,1), %al
        movb        %al, x86_dev_keyboard_buffer

.done:
        pop         %rbx
        pop         %rax
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
