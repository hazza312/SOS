with System;

package Error is 
    procedure lastchance(Msg : System.Address; Line: Integer)
    with 
        Export => True, 
        Convention => C, 
        External_Name => "__gnat_last_chance_handler";


    procedure Panic(S: String);
 
end Error;