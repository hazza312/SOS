        # welcome to userland

        # KERNEL will:
        # -> map this to a 4K USER page
        # -> enter this userland in PL3

        # USERLAND will then:
        # -> syscall into the kernel

        # KERNEL will then:
        # -> acknowledge syscall request
        # -> print / do something
        # -> sysret back to userland

        # USERLAND will then:
        # -> loop doing nothing forever.



        .section .text

        .align  4096
        .globl  userland 

userland:
        movq    $0, %rdi
        syscall
        # jmp     userland
        
        movq    $1, %rdi
        syscall
        
        movq    $2, %rdi
        movq    $msg, %r15 
        syscall

        # movq    $3, %rdi
        # syscall
        
        
        jmp     .
msg:    .asciz "Hello world from userland!!"
