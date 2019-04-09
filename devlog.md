# Development Log

![](http://harryking.nl/SOS/img/img1.png)

Here is a log of the changes & development..

## Week 2
### Monday 8/4
(to be completed... keyboard scancodes, console, basic input etc)

## Week 1

### Sunday 7/4
Still having some weird bugs where an interrupt would be handled, and then the continuing program's execution would mess up / start printing to the screen in weird places. Realised (after a long time) that not necessary registers were being pushed, so the handler was still trashing the contents in some cases. I had a look at the linux x86_64 interrupt.s (LINK) source to look at which registers need to be saved / restored. I guess it is just the scratch registers (see the System-V ABI), since any handling routine will preserve the others.

Starting to look at external interrupts now and programming the PIC. By default, it annoyingly overlaps the IRQs from with system exceptions, this is something that is commonly changed such that external interrupts are mapped to `32` upwards. Reprogramming to use the different vectors isn't too hard, and since the device is so old, the datasheets are avilable and there are guides on how to do this. For this and other devices, I've made separate packages with the register descriptions in Ada, so it will be easy to reprogram them later.

I chose to use the "Auto_EOI", so that it isn't necessary to ack the PIC after every interrupt. Not really sure at the moment what the implications of this will be.

But this seems to be working now, nice. Time to write some handlers for the keyboard, PIT timer and RTC.

I quite like the default "error message" handlers for all interrupts. So I've made it possible to keep these when registering/deregistering a new interrupt for a device. I've made the possibility for two types of handler:
- 'fast handlers': these directly change the value in the IDT, bypassing the stub. The routine (usually assembly) will be responsible for preserving whatever registers it needs to. (in all honesty, the speed isn't essential, just interesting to experiment with another way of solving the interrupt problem).

Currently, my PIT Timer handler is simple enough to be handled in this way (it doesn't even need any registers):


    # X86.Dev.PIT_8253
        .global    x86_dev_pit_8253_ticks
        .global    x86_dev_pit_8253_handler
    x86_dev_pit_8253_handler:
        incq        x86_dev_pit_8253_ticks
        iretq

- the normal handler now adds (another) layer of indirection. The kernel places the address of a handler in a table. When the common stub handler looks at the interrupt number, it looks into the table at this index. If it is null, then we call our error message routine, as before. Otherwise, we call this function.

So this makes registering/deregistering a handler as simple as putting the address into this table, instead of messing around with IDT entries. Nice. I've kept option for adding the two types of interrupt handler in the `X86.Interrupts` package. 

I saw somewhere that Linux used to have fast/normal handlers -- I use the terminology here, but I haven't looked in detail at those handlers to see what makes them 'fast'. I adopt the terminology here anyway.

#### References
- http://www.cpcwiki.eu/imgs/e/e3/8253.pdf
- [PIC8259 datasheet](https://pdos.csail.mit.edu/6.828/2009/readings/hardware/8259A.pdf)
- [Wikipedia: Calling conventions](https://en.wikipedia.org/wiki/X86_calling_conventions)
- [Wikipedia: PIC8259 Interrupt Controller](https://en.wikipedia.org/wiki/Intel_8259)
- [Wikipedia: PIT8253 Timer](https://en.wikipedia.org/wiki/Intel_8253)
- [OSDev: PIC8259](https://wiki.osdev.org/8259_PIC)

### Satuday 6/4
So. Interrupts. I came up with an ingenious plan, and discovered the joy of macros. What would be handy is if we could have one ISR that could act as a default routine, if no handler is loaded. The only problem is, if all gates lead to the same ISR, we won't know why/which interupt/exception just occured, since no registers are loaded/code is pushed to inform of the interrupt. So, we can instead make each IDT entry point to a stub. This stub loads a register with the specific interrupt number, before jumping to the common handler, which can differentiate between the interrupts based ont he contents of this register.

Initially, I tried to make the "stub table" as compact as possible: using only 4 bytes I could do:

    movb ID, %al    # 2 bytes
    jmp except      # 2 bytes if relative offset in [-128, 127]

Of course, there are two problems here. First, %al is trashed. Second, this doesn't work for a table larger than 31 entries, as we can't do this relative jump with a 1 byte offset. I was getting creative and making the further away entries "bunnyhop" towards except, but gave up on this in the end after I realised I needed to push %rax anyway. With all this together, each stub fits within 8 bytes.

With many thanks to the GNU GAS macros, though I wasted a lot of time getting the size neumonics wrong.. This meant my IDT entries were taking up too much space / weren't working correctly.

Though it is cool now that we have all the CPU Exceptions as well as Interrupts caught by our system. This might be pretty handy for debugging.


#### References
[Muen Separation Kernel: IO routines](https://github.com/jcdubois/muen/blob/master/common/src/sk-io.adb)

[GNU GAS Directives](https://ftp.gnu.org/old-gnu/Manuals/gas-2.9.1/html_chapter/as_7.html)

### Friday 5/4
Making a start on interrupts. Immediately turning them on with `sti` causes crashes, as there is no lidt loaded and nothing to handle them. I think the interrupt that comes through almost immediately is the PIT timer.

 Getting my head around these structures gives me a bit of a headache... My plan initially was to do this all from Ada: set up a means of programatically overwrite/read an IDT entry with the address of some assembly / Ada routine. 
 
 Though after thinking about it, this doesn't make so much sense -- we can't just put the address of one of these routines here. These compiled routines will totally trash any registers. And they would end like a normal subroutine, ending with a `ret` when we need to `iret`. This has me thinking of an extra layer of indirection/ some other 'stub' structure that would set things up and push/pop what is required before and after calling the routine. In any case, for now I just want to be able to handle any interrupt with a meaningless handler without it crashing...

 #### References
P93 AMD64SP 

[Interrupts Tutorial](https://wiki.osdev.org/Interrupts_tutorial) (though the copy pasting of stuff there is a little messy).

### Thursday 4/4
Although not really needed yet, a small memory map was written to keep track of free kernel memory. Currently, this is implemented as an experimentation with generic Ada packages (with the hope that it can be reused for managing different sized memory blocks). This might need to be refactored.

Currently implements a first-fit algorithm (inspired by the algorithm in the Unix6 book). Though perhaps the structure to maintain this would take up too much memory (i.e. the "free nodes" in the linked list?). Freed memory is automatically joined back with contiguous regions before and after that memory spot. 

In the worst case, every other alloc unit (e.g. page) would be allocated. So, this would require (REGION_SIZE / ALLOC_UNIT) /2 nodes. And every node requires the fields for 

    64 bit base address
    64 bit size
    xx bit pointer
        xx bits for (2**x) * 2 allocations (see above)

Ok realistically, this could be optimised. If this is for kernel only use, we could assume the minimum allocation size of a page=4096 bytes. If the base address becomes the page number, a 32-bit integer would likely be large enough to cover all physical memory. We could limit the size of a single allocation to 2^16 pages. And perhaps 2^16 concurrent allocations would be enough? Something to play with later.

### Wednesday 3/4
Code has been refactored somewhat to separate 
- architecture specific code
- kernel code common across different architectures
- lengthy code for printing debug tables etc goes in its own (for now, architecture-specific) package. 

Each architecture will provide a means of filling the `Holes_List` (perhaps on some platforms, this information might be static and not require much processing). This is populated such that the list is ordered with the biggest holes listed first. The kernel panics if there is no memory.

On the x86_64 platform, we make use of the multiboot2 `boot_info` saved earlier and use it to work out where we have free "holes" in memory. 

My current plan is to separate the allocation of physical memory, and the paging of this memory. Since memory allocators are probably going to reappear elsewhere, I am making a generic Ada package for this.

I have just discovered GNATdoc, can make some pretty [nice documentation from Ada specification files](doc/index.html) -- so I have started setting that up.

### Tuesday 2/4
Managed to (finally) get myself into Long Mode. Discovered how useful Bochs is for kernel debugging in addition to the QEMU+GDB combo.

[OSDev's Setting Up Long Mode](https://wiki.osdev.org/Setting_Up_Long_Mode) is a really useful resource. I deviate slightly from the guide:
- take it for granted that the machine can enter long mode (part of rubric), so omit the checks.
- using a single 2M page to identity map the already loaded kernel (instead of an extra level and using 512 4K pages to map 2M).
- putting the page tables in the .bss section -- taking advantage of the fact the multiboot specification will zero this out for us (so we don't have to zero out any memory ourselves).
- Memory layout is different, kernel text & page objects we keep all above 0x100000 (1M). The location of the pages are defined in the linker script, rather than in the source (perhaps this would make it easier to port/move in the future?)
- using GNU GAS assembler instead of NASM/Intel syntax.
- inserted an extra null entry to the GDT such that the CS and DS in 64-bit mode match that loaded by GRUB (0x10, 0x18). (This also saves having to modify a 32-bit GDT?)
- jump straight to our Ada entry routine, rather than hanging around and doing more stuff in Assembly. IDT is still not setup, hopefully can do that there.

Current memory map is

    0x100000: Multiboot header
              .text
    0x100010: _entry (assembly bootstrap)
              rest of kernel .text (Ada)
              .bss
    0x101000: PML4T
    0x102000: PDPT
    0x103000: PDT
    0x104000: (4096 bytes stack space)
    0x106000: .data

This works for now (everything is contained within the first 2MB, the identity mapped page). Perhaps it would be better to add more separation for .text and .bss/.data sections? (possibility for page protection later, making the .text read/execute only, and .data not executable?)

The third issue above kept me busy for a long time (triple faults are sad). Bochs helped to debug the issue (easy to probe memory to ensure the maps and tables were correct, and state of the segment registers on transfer from GRUB -> kernel).

#### References
- https://wiki.osdev.org/Setting_Up_Long_Mode
- [AMD64 Architecture Programmer’s Manual Volume 2: System Programming](https://www.amd.com/system/files/TechDocs/24593.pdf) : particularly:
    - System Control Registers CR0/3/4 (P. 41)
    - Long Mode Segment Descriptors (P.88)
    - Long Mode Page Translation (P. 130)
    - Activating Long Mode (P. 439)
- [Multiboot2 Spec](https://www.gnu.org/software/grub/manual/multiboot2/multiboot.html#Boot-information-format)


### Friday 29/3 - Monday 1/4
I had worked on a (small) 32-bit Ada kernel, using [Ada Bare Bones OSDev Tutorial](https://wiki.osdev.org/Ada_Bare_bones) as a starting point. This was relatively straight forward, considering from entry after GRUB, there was very little bootstrap code needed to enter Ada code immediately. I got a few words printing on the screen, but hadn't touched and GDTs/IDTs/paging etc.

Later version of the GNAT compiler include a (native) Zero Footprint Runtime, so it isn't necessary to perform the changes made here.

I was struggling for a long time deciding whether to drive the build by some Makefile or through GNAT project files (here both are used, where the GPR drives gnatmake for the Ada sources, however the assembly startup file is built and linked in the Makeflie).

The GNAT project file is pretty nifty for handling sources in different languages, and does a good job of handling the compile/bind/link Ada chain. I'm going to try and define as much as possible in this (compiling the sources and linking the final executable) and use the Makefile for building .iso's, running the debugger and other extra tasks.

At this point, I'm using QEMU+GDB to debug. I've started to attempt getting into Long Mode, using [Setting up Long Mode](https://wiki.osdev.org/Setting_Up_Long_Mode) as a guide but something isn't quite working out (triple faulting?)..

It took a while to get just the multiboot header correct.. read somewhere (where?) about a useful way to check whether an executable was multiboot compliant or not without booting up an emulator:

    grub-file -is-x86-multiboot2 [executable]

Which exits with 0 if multiboot2able, else 1.

#### References
- [Gnat Project Manager](https://docs.adacore.com/gprbuild-docs/html/gprbuild_ug/gnat_project_manager.html)
- [Ada Bare Bones OSDev Tutorial](https://wiki.osdev.org/Ada_Bare_bones)

### Preliminary
