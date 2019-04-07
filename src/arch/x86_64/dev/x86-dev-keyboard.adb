with Interfaces; use Interfaces;
with Arch; use Arch;

package body X86.Dev.Keyboard is 

    Last : Character;
    Ticks : Unsigned_64 with Export, External_Name => "x86_dev_keyboard_ticks";

    procedure Handler is
    begin 
        Ticks := Ticks + 1;
        Last := Character'Val(IO_Inb(16#60#));
    end Handler;

    function Get_Key return Character is 
    begin
        return Last;
    end Get_Key;

    procedure Reset is 
    begin
        Ticks := 0;
    end Reset;

    function Get_Ticks return Unsigned_64 is (Ticks);


end X86.Dev.Keyboard;