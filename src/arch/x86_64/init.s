		# init.s
		# initial entry point for x86_64 architecture.
		# in GAS. Ew.
		# GRUB has already setup protected mode for us.

		/* Multiboot header */
		.section .multiboot_header
		.align 	64					# spec requires 64-bit alignment
									# and whole header in first 64k 
		.long  	0xE85250D6 			# magic number for multiboot2
		.long  	0 					# i386, 32 bit protected mode
		.long  	0x10				# header length
		.long  	-(0xe85250d6+0x10)	# checksum

		# final end tag: no more header
		.short 	0  					# tag type
   		.short 	0  					# flags
   		.long 	8  					# size


		/* .bss section: memory mapped pages */
		.section .bss
		.align 	0x1000 				# align on a 4K boundary
pml4t: 	.space  0x1000 				# Page Map Level 4 Table
pdpt: 	.space  0x1000 				# page-directory pointer table
pdt:	.space 	0x1000

		
		/* .data section: GDT entries */
	 	/* see AMD64 P88 */
		.section .data
		.align 0x1000
GDT:
0:		# Null descriptor, values don't really matter(?)
		#.space 	32
		.long 0xFFFF                    # Limit (low).
		.long 0                         # Base (low).
		.byte 0                         # Base (middle)
		.byte 0                         # Access.
		.byte 1                         # Granularity.
		.byte 0                         # Base (high).					
		
1:		# Code entry
		.long 	0					# segment limit[15:0]
		.long 	0					# base address[15:0]
		.byte 	0					# base address[23:16]
		.byte 	0b10011010			# long mode & (??)
		.byte	0b10101111			# segment limit[19:16] & flags
		.byte 	0 					# base address[31:24]

2:		# Data entry
		.long 	0					# segment limit[15:0]
		.long 	0					# base address[15:0]
		.byte 	0					# base address[23:16]
		.byte 	0b10010010			# long mode & (??)
		.byte	0					# segment limit[19:16] & flags
		.byte 	0 					# base address[31:24]
.end:


gdt_info:
		.short 	8*3					# GDT Table limit
		.long 	GDT	 				# Base Address of GDT Table
									# TODO: local sublabelsm like in NASM?


		/* 	Kernel Entry Point */
		.section .entry
		.globl 	_entry
		.extern _ada_kernel			# continue Ada kernel when we are ready
		.code32						# 32-bit code for now, please

_entry:	
.pt_magic:							# see P135 in AMD64SP
		movl 	$pdpt, (pml4t)		# set PDPT entry in PML4T
		orl		$3, (pml4t)			# Set R/W + P bits
		movl 	$pdt, (pdpt)		# set PDT entry in PDPT
		orl 	$3, (pdpt)			# Set R/W + P bits (also .PS is already 0ed)
		orl 	$(1<<7), (pdt)		# set PDE.PS bit 7 = 2M page translation

									# see P439 on enabling long mode.

		movl	%cr4, %eax 
		orl 	$(1<<31), %eax		# enable the PAE bit
		movl 	%eax, %cr4 

		movl	$pml4t, %eax		# load base of PML4 in CR3
		movl	%eax, %cr3	


		movl 	$0xC0000080, %ecx	# we need to set the EFER.LME
		rdmsr						# (Extended Feature Enable Register)
		orl 	$(1<<8), %eax 		# toggle the Long Mode Enable Bit
		wrmsr						# write back


		movl 	%cr0, %eax 			
		orl 	$(1<<31), %eax		# enable PG bit	
		movl 	%eax, %cr0

		cli
		lgdt	(gdt_info)			# load the GDT

		jmp		$0x08, $_ada_kernel	# hope and pray for no PF!

never:	jmp 	never			
