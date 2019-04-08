-- with Consoleb; 

package X86 is

    IDT_BASE        : constant := 16#10a080#;
    IDT_ENTRIES     : constant := 64;
    CODE_SELECTOR   : constant := 16#10#;

end X86;