package Interrupts is 
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


end Interrupts;