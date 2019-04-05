with System;
with Interfaces; use Interfaces;

package Error is 
    procedure lastchance(Msg : System.Address; Line: Integer)
    with 
        Export => True, 
        Convention => C, 
        External_Name => "__gnat_last_chance_handler";

    procedure CPU_Exception(V: Unsigned_64)
    with 
        Export => True, 
        Convention => C, 
        External_Name => "_ada_cpu_exception";

    procedure Panic(S: String);
 
end Error;