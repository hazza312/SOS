with Interfaces; use Interfaces;
with Kernel; use Kernel;

package X86.Dev.Keyboard is 
    procedure Handler;
    function Get_Key return Character;
    function Get_Ticks return Unsigned_64;

private
    type Port_Type is (Command, Data);
    for Port_Type use (Command => 16#60#, Data => 16#64#);


end X86.Dev.Keyboard;