with Console; use Console;
with System.Machine_Code; use System.Machine_Code;
with Interfaces; Use Interfaces;

package body X86.Dev.PIT_8253 is

    Tick_Count : Unsigned_64 := 0 with Volatile;

    procedure Handler is 
    begin 
        Tick_Count := @ + 1;
    end;

    function Get_Ticks return Unsigned_64 is (Tick_Count);

    procedure Reset is 
    begin 
        Tick_Count := 0;
    end Reset;

end X86.Dev.PIT_8253;