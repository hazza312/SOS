with System;
with Interfaces; use Interfaces;
with Interrupts; use Interrupts;

package Error is 

    -- procedure lastchance(Msg : String; Line: Integer)
    -- with 
    --     Export => True, 
    --     Convention => C, 
    --     External_Name => "__gnat_last_chance_handler";

    procedure Exception_Handler
    with 
        Export => True, 
        Convention => C, 
        External_Name => "_ada_cpu_exception";

    procedure Panic(S: String);
 
end Error;