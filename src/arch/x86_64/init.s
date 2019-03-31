# init.s
# initial entry point for x86_64 architecture.
# GRUB has already setup protected mode for us.

.code32
.global .multiboot_header
.section .multiboot_header
.align 4
	.long		0xE85250D6 		# magic number
	.long		0 				# 32 bit protected mode
	.long 		0x10
	.long 		-(0xe85250d6+0x10)		# checksum

	.long 0    # type
    .long 0    # flags
    .long 8    # size


# see P183, AMD64 APMV2SP
# -- CR3 layout --
# 	      63:52 	# reserved
#		  51:12 	# PML4 Table Base Address
#		  11:05 	# reserved
.equ CR3PCD, 04     # page cache-disable
.equ CR3PWT, 03     # page write-through
#		  02:00		# reserved

# --


.section bss
.align 4096

# identity map the first 2M in a 2M page

.lcomm pml4t	4096 #
.lcomm pdpt 	4096 # page-directory pointer table
.lcomm pdt		4096 # page directory
.lcomm pt1 		4096

gdt_info:
.word 0 #limit
.quad 0 #base

.section text
.global _entry
.extern _ada_kernel

# -- setup up page tables --
_entry:
	movl	$pml4t, %eax
	movl	%eax, %cr3

	movl	$pml4t, %edi 	# dest
	movl	$pdpt, %esi 	# src
	addl	3, %esi

ploop:
	movl	%esi, (%edi)
	addl	4096, %edi
	addl	4096, %esi
	cmp		$pt1, %esi
	jl		ploop


	lgdt	(gdt_info)


	nop
	call _ada_kernel
