# 32-bit mode code

.global _entry
.global Make_Page_Table

_entry:
	nop
	call Make_Page_Table

	movl 0x2000, %edi    # Set the destination index to 0x1000.
    movl %edi, %cr3       # Set control register 3 to the destination index.
    xorl %eax, %eax       # Nullify the A-register.
    movl 4096, %ecx      # Set the C-register to 4096.
    rep stosl          # Clear the memory.
    movl %cr3, %edi       # Set the destination index to control register 3.

    movl $0x3003, (%edi)      # Set the uint32_t at the destination index to 0x2003.
    addl $0x1000, %edi              # Add 0x1000 to the destination index.
    movl $0x4003, (%edi)      # Set the uint32_t at the destination index to 0x3003.
    addl $0x1000, (%edi)              # Add 0x1000 to the destination index.
    movl $0x5003, (%edi)      # Set the uint32_t at the destination index to 0x4003.
    addl $0x1000, (%edi)              # Add 0x1000 to the destination index.

    movl 0x00001003, %ebx          # Set the B-register to 0x00000003.
    movl 512, %ecx                 # Set the C-register to 512.

.SetEntry:
    movl %ebx, (%edi)         # Set the uint32_t at the destination index to the B-register.
    addl 0x1000, %ebx # 0x1000 to the B-register.
    addl 8, %edi                   # Add eight to the destination index.
    loop .SetEntry               # Set the next entry.
