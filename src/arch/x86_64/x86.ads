-- with Consoleb; 

package X86 is

    CODE_SELECTOR       : constant := 16#10#;

    IDT_BASE            : constant := 16#10a_080#;
    IDT_ENTRIES         : constant := 64;

    KERNEL_PHYS_BASE    : constant := 16#0#;
    KERNEL_SIZE         : constant := 16#200_000#;

    PD_POOL_BASE        : constant := 16#200_000#;
    PD_POOL_SIZE        : constant := 16#200_000#;

    UNRESERVED_BASE     : constant := PD_POOL_BASE + PD_POOL_SIZE;

private 


end X86;