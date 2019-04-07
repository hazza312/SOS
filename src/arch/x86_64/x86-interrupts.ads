with Interfaces; use Interfaces;
with Kernel;
with System;

package X86.Interrupts is 
    type Interrupt is (
        DE,     DB,     NMI,    BP,     OFE,    BR,     UD,     NM,
        DF,     TS,     NP,     SS,     GP,     PF,     MF,     AC,     
        MC,     XF,     VC,     SX,

        PIT, Keyboard, PIC_Slave, COM2_4, COM1_3, LPT2, Floppy, LPT1,
        RTC, Mouse, Math_Coprocessor, HD1, HD2
    );

    for Interrupt use (
        DE=>0,  DB=>1,  NMI=>2, BP=>3,  OFE=>4, BR=>5, UD=>6, NM=>7, 
        DF=>8,  TS=>10, NP=>11, SS=>12, GP=>13, PF=> 14, 
        MF=>16, AC=>17, MC=>18, XF=>19, VC=>20, SX=>21,

        PIT=>32, Keyboard=>33, PIC_Slave=>34, COM2_4=>35, 
        COM1_3=>36, LPT2=>37,Floppy=>38, LPT1=>39, 
        RTC=>40, Mouse=>44, Math_Coprocessor=>45, HD1=>46,
        HD2=>47
    );

    subtype CPU_Exception is Interrupt range DE .. SX;
    subtype External_Interrupt is Interrupt range PIT .. HD2;

    procedure Register_Handler(IRQ: Interrupt; Handler: System.Address);

    -- .macro IDT selector offset ist type dpl p
    --         .align 16
    --         .short  \offset & 0xffff
    --         .short  \selector
    --         .byte   \ist & 0b111
    --         .byte   (\type & 0xf) | (\dpl<<5) | (\p<<7)
    --         .short  \offset>>16
    --         .long   \offset>>32
    --         .long   0
    --     .endm

private


    type IDT_Entry is record
        Offset_0_15:    Unsigned_16;
        Selector:       Unsigned_16             := X86.CODE_SELECTOR;
        IST:            Unsigned_8 range 0..7   := 0;
        Descriptor_Type:Unsigned_8 range 0..15  := 16#f#;
        DPL:            Unsigned_8 range 0..3   := 0;
        P:              Boolean;
        Offset_16_31:   Unsigned_16;
        Offset_32_63:   Unsigned_32;
        Pad:            Unsigned_32             := 0;
    end record;

    for IDT_Entry use record
        Offset_0_15     at 0 range 0..15;
        Selector        at 2 range 0..15;
        IST             at 4 range 0..7;
        Descriptor_Type at 5 range 0..4;
        DPL             at 5 range 5..6;
        P               at 5 range 7..7;
        Offset_16_31    at 6 range 0..15;
        Offset_32_63    at 8 range 0..31;
        Pad             at 12 range 0..31;
    end record;
    for IDT_Entry'Size use 128;

    -- type IDT_Table is array(Interrupt range <>) of IDT_Entry;
    Table : array(Integer range 0..63) of IDT_Entry with Address => System'To_Address(X86.IDT_BASE), Import;
    for Table'Size use 64*128;




end X86.Interrupts;