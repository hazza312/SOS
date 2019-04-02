		# init.s
		# initial entry point for x86_64 architecture.
		# GRUB has already setup 32-bit protected mode for us.

/****** Multiboot header ******************************************************/
		.section .multiboot_header
		.align 	64								# spec requires 64-bit alignment
												# and whole header in first 64k 
		.long  	0xE85250D6 						# magic number for multiboot2
		.long  	0 								# i386, 32 bit protected mode
		.long  	0x10							# header length
		.long  	-(0xe85250d6+0x10) & 0xffffffff	# checksum

		# final end tag: no more header
		.short 	0  								# tag type
   		.short 	0  								# flags
   		.long 	8  								# size


/****** .bss section: initial page tables *************************************/
		.section .bss
		.align 	0x1000 							# align on a 4K boundary
pml4t: 	.space  0x1000 							# Page Map Level 4 Table
pdpt: 	.space  0x1000 							# page-directory pointer table
pdt:	.space 	0x1000
stack:	.space	0x1000
stack_end:

		
/****** .data section: GDT entries ********************************************/
		.section .data							# see AMD64 P88
		.align 0x1000							# align on a page boundary 
GDT:
0:		.space 8								# Null descriptor
1:		.space 8								# match our CS/DS with GRUB
		
2:		# Code Entry (0x10)
		.short 	0								# segment limit[15:0]
		.short 	0								# base address[15:0]
		.byte 	0								# base address[23:16]
		.byte 	0b10011010						# long mode & (??)
		.byte	0b10101111						# segment limit[19:16] & flags
		.byte 	0 								# base address[31:24]

3:		# Data entry (0x18)
		.short 	0								# segment limit[15:0]
		.short 	0								# base address[15:0]
		.byte 	0								# base address[23:16]
		.byte 	0b10010010						# long mode & (??)
		.byte	0								# segment limit[19:16] & flags
		.byte 	0 								# base address[31:24]
.end:
gdtinfo:.short 	.end -GDT -1					# GDT Table limit
		.quad 	GDT	 							# Base Address of GDT Table


/****** Kernel Entry Point ****************************************************/
		.section .entry
		.global	_entry
		.extern _ada_kernel			# continue Ada kernel when we are ready
		.code32						# 32-bit code for now, please

		# TODO: disable blinky cursor
		movb 	$0xA, %al
		movw 	$0x3D4, %dx
		out	 	%al,%dx

		movb 	$0x20, %al
		movw 	$0x3D5, %dx
		out	 	%al,%dx


_entry:	
		movl 	$stack_end, %esp

		movl 	%cr0, %eax 
		andl 	$~(1<<31), %eax 
		movl 	%eax, %cr0
									# see P135 in AMD64SP
		movl 	$pdpt, (pml4t)		# set PDPT entry in PML4T
		orl		$3, (pml4t)			# Set R/W + P bits
		movl 	$pdt, (pdpt)		# set PDT entry in PDPT
		orl 	$3, (pdpt)			# Set R/W + P bits (also .PS is already 0ed)
		orl 	$((1<<7) |3), (pdt)		# set PDE.PS bit 7 = 2M page translation, RW+P
									# see P439 on enabling long mode.

		movl	$pml4t, %eax		# load base of PML4 in CR3
		movl	%eax, %cr3	

		movl	%cr4, %eax 
		orl 	$(1<<5), %eax		# enable the PAE bit
		movl 	%eax, %cr4 

		movl 	$0xC0000080, %ecx	# we need to set the EFER.LME
		rdmsr						# (Extended Feature Enable Register)
		orl 	$(1<<8), %eax 		# toggle the Long Mode Enable Bit
		wrmsr						# write back

		movl 	%cr0, %eax 			
		orl 	$(1<<31), %eax		# enable PG bit	
		movl 	%eax, %cr0

		lgdt	gdt_info			# load the GDT

		call	$0x10, $_ada_kernel	# hope and pray for no PF!

never:	jmp 	never			
