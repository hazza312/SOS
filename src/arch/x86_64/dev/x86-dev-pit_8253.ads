with Interfaces; use Interfaces;


package X86.Dev.PIT_8253 is

    procedure Handler;

    function Get_Ticks return Unsigned_64  ;

    procedure Reset;

end X86.Dev.PIT_8253;