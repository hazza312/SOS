with System;
with Interfaces; use Interfaces;

package Error is 

    type CPU_Exception is (
        DE,     DB,     NMI,    BP,     OFE,    BR,     UD,     NM,
        DF,     Reserved0,TS,   NP,     SS,     GP,     PF,     Reserved1,
        MF,     AC,     MC,     XF,     VC,
        SX
    );


    procedure lastchance(Msg : String; Line: Integer)
    with 
        Export => True, 
        Convention => C, 
        External_Name => "__gnat_last_chance_handler";

    procedure Exception_Handler
    with 
        Export => True, 
        Convention => C, 
        External_Name => "_ada_cpu_exception";

    procedure Panic(S: String);
 
end Error;