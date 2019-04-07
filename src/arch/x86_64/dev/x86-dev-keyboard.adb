with Interfaces; use Interfaces;
with Arch; use Arch;

package body X86.Dev.Keyboard is 

    Last : Character;
    Ticks : Unsigned_64 with Volatile;

    procedure Handler is
        V : Unsigned_8;
    begin 
        Ticks := Ticks + 1;
        V := IO_Inb(16#60#);
    end Handler;

    function Get_Key return Character is 
    begin
        return Character'Val(Ticks mod 128);
    end Get_Key;

    function Get_Ticks return Unsigned_64 is (Ticks);


end X86.Dev.Keyboard;