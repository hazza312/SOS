# Development Log

Here is a log of the changes & development..

## Week 1

### Sunday 7/4
http://www.cpcwiki.eu/imgs/e/e3/8253.pdf

### Satuday 6/4
Interrupts continued. Wonderful macros.
GNU GAS sizes.
New memory map.
PIC 8259 routines.
Trimming debug carp from executable.
Debugging.



#### References
[Muen Separation Kernel: IO routines](https://github.com/jcdubois/muen/blob/master/common/src/sk-io.adb)

### Friday 5/4
Interrupts

### Thursday 4/4
Memory map

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
