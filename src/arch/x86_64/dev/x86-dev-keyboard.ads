with Interfaces; use Interfaces;
with Common; use Common;
with Arch; use Arch;

package X86.Dev.Keyboard is

    Null_Character : constant Character := Character'Val(0);
    Backspace: constant Character := Character'Val(8);
    Tab: constant Character := Character'Val(9);
    LF : constant Character := Character'Val(10);

    Num_Row : constant String := "1234567890-=";
    First_Row : constant String := "qwertyuiop[]";
    Second_Row : constant String := "asdfghjkl;'`";
    Third_Row : constant String := "\zxcvbnm,./";  


    procedure Handler;
   -- function Get_Key return Character;
    function Get_Character return Character;
    function Get_Ticks return Unsigned_64;
    function Has_Line return Boolean;
    function Has_Input return Boolean;
    procedure Flush;

private
    Command_Port : constant IO_Port := 16#64#;
    Data_Port : constant IO_Port := 16#60#;


end X86.Dev.Keyboard;