with Interfaces; use Interfaces;
with Arch; use Arch;
with Console; use Console;
with Common; use Common;


package body X86.Dev.Keyboard is 

    type Buffer_Index is mod 2 ** 6;
    type Key_Buffer is array(Buffer_Index) of Character;

    Buffer: Key_Buffer;

    Write_Head: Buffer_Index;
    Read_Tail: Buffer_Index;

    Ticks: Unsigned_64 := 0;
    Caps_Lock : Boolean := False;
    Shifts: Integer := 0;

    Has_Line_Flag: Boolean;

    procedure Handler is
        Code: Integer;
        Converted : Character;
    begin 
        Ticks := Ticks + 1;
        Code := Integer(IO_Inb(Data_Port));

        case Integer(Code) is 
        when 16#02#..16#0d#    => Converted := Num_Row(Code - 16#02# +1);
        when 16#0e#            => Converted := Backspace; -- backspace
        when 16#0f#            => Converted := Tab; -- tab
        when 16#10#..16#1b#    => Converted := First_Row(Code - 16#10# +1);
        when 16#1c#            => Converted := LF; -- lf
        when 16#1e#..16#29#    => Converted := Second_Row(Code - 16#1e# +1);
        when 16#2a# | 16#36#   => Shifts := Shifts + 1;
        when 16#2b#..16#35#    => Converted := Third_Row(Code - 16#2b# +1);
        when 16#3a#            => Caps_Lock := Caps_Lock xor True;
        when 16#39#            => Converted := ' ';
        when 16#b6#|16#aa#     => Shifts := Shifts - 1;
        when others            => Converted := Null_Character;
        end case;

        if Converted = Null_Character then 
            return;
        end if;

        if Shifts > 0 or Caps_Lock then 
            case Converted is 
            when 'a'..'z' => Converted := Character'Val(Character'Pos(Converted) - 16#20#);
            when '1'..'9' => Converted := Character'Val(Character'Pos(Converted) - 16#10#);
            when others => null;
            end case;
        end if;

        Buffer(Write_Head) := Converted;
        Write_Head := @ + 1;
        if Converted = LF then 
            Has_Line_Flag := True;
        end if;

    end Handler;

    procedure Flush is 
    begin 
        Read_Tail := Write_Head;
        Has_Line_Flag := False;
    end Flush;

    procedure Get_Line(Out_Buffer: in out Key_Buffer) is 
        Write_Index: Buffer_Index := 0;
    begin 
        while Buffer(Read_Tail) /= LF and then Read_Tail /= Write_Head loop 
            Out_Buffer(Write_Index) := Buffer(Read_Tail);
            Read_Tail := @ + 1;
            Write_Index := @ + 1;
        end loop;
    end Get_Line;

    function Has_Input return Boolean is (Read_Tail /= Write_Head);

    function Get_Character return Character is 
        C: Character;
    begin 
        if Read_Tail /= Write_Head then 
            C := Buffer(Read_Tail);
            Read_Tail := @ + 1;
        else
            C := Null_Character;
        end if;
        return C;
    end Get_Character;


    function Has_Line return Boolean is (Has_Line_Flag);
    function Get_Ticks return Unsigned_64 is (Ticks);


end X86.Dev.Keyboard;