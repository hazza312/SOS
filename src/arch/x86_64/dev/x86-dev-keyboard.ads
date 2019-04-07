with Interfaces; use Interfaces;
with Kernel; use Kernel;

package X86.Dev.Keyboard is

    X : constant Character := Character'Val(0);
    Tab: constant Character := Character'Val(9);
    Enter : constant Character := Character'Val(10);

    -- 0x12 = LS, 0x59=RS, 0x58=caps
    --0x5a=enter
    --0x66=bs
    Buffer : Character 
        with Export, External_Name => "x86_dev_keyboard_buffer",Volatile ;

    -- assume scan code 2? Ignore non alphanum keys for now.
    Scan_Code_LUT : constant array(Unsigned_8) of Character := (
        X,X,X,X,X,X,X,X,X,X,X,X,X,Tab,'`',X,
        X,X,X,X,X,'Q','1',X,X,X,'Z','S','A','W','2',X,
        X,'C','X','D','E','4','3',X,X,' ','V','F','T','R','5',X,
        X,'N','B','H','G','Y','6',X,X,X,'M','J','U','7','8',X,
        X,',','K','I','O','0','9',X,X,'.','/','L',';','P','-',X,
        X,X,''',X,'[','=',X,X,X,X,Enter,']',X,'\',X,X
    )
    with Export, External_Name => "x86_dev_keyboard_scancode_lut" ;
    


    procedure Handler;
    function Get_Key return Character;
    function Get_Ticks return Unsigned_64;
    procedure Reset;

private
    type Port_Type is (Command, Data);
    for Port_Type use (Command => 16#60#, Data => 16#64#);


end X86.Dev.Keyboard;