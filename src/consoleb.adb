with System; use System;
with System.Storage_Elements; use System.Storage_Elements;
with Ada.Unchecked_Conversion; 
with Interfaces; use Interfaces;

package body consoleb is

    package body Printer is

    procedure Put(s: String; fg: Colour :=  White; bg : BG_Colour := Black) is
    begin
        for c of s loop
            Put(c, fg => fg, bg => bg);
        end loop;
    end Put;


    procedure Put_Line(s: String; fg: Colour :=  White; bg : BG_Colour := Black) is
    begin
        Put(s, fg => fg, bg => bg);
        Put(LF);
    end Put_Line;

    procedure Put_Hex(n: Positive; fg : Colour :=  White; bg : BG_Colour := Black) is
    begin 
        Put("0x");
        Put_Unsigned(n, Base=>16, fg=>fg, bg=>bg);
    end Put_Hex;

    procedure Put_Int(num : Integer; Base : Natural := 10; fg : Colour :=  White; bg : BG_Colour := Black) is 
    begin 
        if num < 0 then
            Put('-', fg=>fg, bg=>bg);
        end if;
        Put_Unsigned(abs num, Base=>Base, fg=>fg, bg=>bg);

    end Put_Int;


    procedure Put_Unsigned(num : Natural; Base : Natural := 10; fg : Colour :=  White; bg : BG_Colour := Black) is
        Chars : array(0..15) of Character := "0123456789ABCDEF";
        Digit : array(0 .. 63) of Character;
        n : Natural := num;
        i : Natural := 0;
    begin
        loop
            Digit(i) := Chars(n mod Base);
            n := n / Base;
            exit when n = 0;
            i := i + 1;
        end loop;

        for x in reverse 0..i loop
            Put(Digit(x), fg=>fg, bg=>bg);
        end loop;
    end Put_Unsigned;



    procedure Banner(s : String; fg: Colour := White; bg: BG_Colour := Black) is
        L_Pad : Positive := (width - s'Length) / 2;
        R_Pad : Positive := width - L_Pad - s'Length;
    begin
        for i in 1..L_Pad loop
            Put(' ', fg=>fg, bg=>bg);
        end loop;

        Put(s, fg=>fg, bg=>bg);

        for i in 1..R_Pad loop
            Put(' ', fg=>fg, bg=>bg);
        end loop;
    end;

    
    procedure Put_Size(Size: Natural) is
    begin 
        case Size is 
        when 0      ..1024**1 -1   => Put_Int(Size);           Put("B");
        when 1024**1..1024**2 -1   => Put_Int(Size / 1024**1); Put("kB");
        when 1024**2..1024**3 -1   => Put_Int(Size / 1024**2); Put("MB");
        when others                => Put_Int(Size / 1024**3); Put("GB");
        end case;
    end;
    end Printer;

end consoleb;