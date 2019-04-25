with Interfaces; use Interfaces;
with Common;
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

    procedure Slow_Handler(IRQ: Interrupt; Handler: System.Address);
    procedure Register_Handler(IRQ: Interrupt; Handler: System.Address);
    procedure Dump_Mapping;







   -- create a constant ragged array, so we can pretty print the interrupt names
   DE_Str      : aliased constant String := "Divide by Zero (#DE)";
   DB_Str      : aliased constant String := "Debug (#DB)";
   NMI_Str     : aliased constant String := "NMI";
   BP_Str      : aliased constant String := "Breakpoint (#BP)";
   OFE_Str     : aliased constant String := "Overflow (#OF)";
   BR_Str      : aliased constant String := "Bound_Range (#BR)";
   UD_Str      : aliased constant String := "Invalid Opcode (#UD)";
   NM_Str      : aliased constant String := "Device Not Available (#NM)";
   DF_Str      : aliased constant String := "Double Fault (#DF)";
   TS_Str      : aliased constant String := "Invalid TSS (#TS)";
   NP_Str      : aliased constant String := "Segment Not Present (#NP)";
   SS_Str      : aliased constant String := "Stack Exception (#SS)";
   GP_Str      : aliased constant String := "General Protection Fault (#GP)";
   PF_Str      : aliased constant String := "Page Fault (#PF)";
   MF_Str      : aliased constant String := "X87 FP Exception (#MF)";
   AC_Str      : aliased constant String := "Alignment Check Exception (#AC)";
   MC_Str      : aliased constant String := "Machine Check Exception (#MC)";
   XF_Str      : aliased constant String := "SIMD FP Exception (#XF)";
   VC_Str      : aliased constant String := "VMM Communication Exception (#VC)";
   SX_Str      : aliased constant String := "Security Exception (#SX)";

   PIT_Str     : aliased constant String := "PIT";
   KEY_Str     : aliased constant String := "Keyboard";
   PICS_Str    : aliased constant String := "PIC Slave";
   COM2_4_Str  : aliased constant String := "Serial COM2/4";
   COM1_3_Str  : aliased constant String := "Serial COM1/3";
   LPT2_Str    : aliased constant String := "LPT2";
   Floppy_Str  : aliased constant String := "Floppy";
   LPT1_Str    : aliased constant String := "LPT1";
   RTC_Str     : aliased constant String := "RTC";
   Mouse_Str   : aliased constant String := "Mouse";
   Math_Str    : aliased constant String := "Math Coprocessor";
   HD1_Str     : aliased constant String := "Hard Disk Controller 1";
   HD2_Str     : aliased constant String := "Hard Disk Controller 2";
   Other_Str   : aliased constant String := "Unknown";

   -- type Name_Handle is access constant String;
   Interrupt_Name : array(Interrupt) of access constant String := (
       DE=>DE_Str'Access,  DB=>DB_Str'Access,  NMI=>NMI_Str'Access,
       BP=>BP_Str'Access,  OFE=>OFE_Str'Access,BR=>BR_Str'Access,
       UD=>UD_Str'Access,  NM=>NM_Str'Access,  DF=>DF_Str'Access,
       TS=>TS_Str'Access,  NP=>NP_Str'Access,  SS=>SS_Str'Access,
       GP=>GP_Str'Access,  PF=>PF_Str'Access,  MF=>MF_Str'Access,
       AC=>AC_Str'Access,  MC=>MC_Str'Access,  XF=>XF_Str'Access,
       VC=>VC_Str'Access,  SX=>SX_Str'Access,  PIT=>PIT_Str'Access,
       Keyboard=>Key_Str'Access,  PIC_Slave=>PICS_Str'Access,
       COM2_4=>COM2_4_Str'Access, COM1_3=>COM1_3_Str'Access,
       LPT2=>LPT2_Str'Access,     Floppy=>Floppy_Str'Access,
       LPT1=>LPT1_Str'Access,     RTC=>RTC_Str'Access,
       Mouse=>Mouse_Str'Access,   Math_Coprocessor=>Math_Str'Access,
       HD1=>HD1_Str'Access,       HD2=>HD2_Str'Access 
   );



private


    type IDT_Entry is record
        Offset_0_15:    Unsigned_16;
        Selector:       Unsigned_16             := X86.CODE_SELECTOR;
        IST:            Unsigned_8 range 0..7   := 0;
        Descriptor_Type:Unsigned_8 range 0..15  := 16#E#;
        DPL:            Unsigned_8 range 0..3   := 0;
        P:              Boolean                 := True;
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
    for IDT_Entry'Size use 16*8;


    Table : array(0..63) of IDT_Entry 
        with Import, Convention => Assembler, External_Name => "IDT";
    for Table'Size use 64*16*8;


end X86.Interrupts;