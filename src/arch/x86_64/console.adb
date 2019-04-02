with System; use System;
with System.Storage_Elements; use System.Storage_Elements;
with Ada.Unchecked_Conversion; 

package body console is

   function A_To_Int is new Ada.Unchecked_Conversion(System.Address, Integer);

   VMem : array(0..Height-1, 0..Width-1) of cell;
   for VMem'Address use System'To_Address(16#B8000#);

   X: Natural := 0;
   Y: Natural := 0;

   procedure Clear is
   begin
      Shift_Lines(Height);
   end Clear;

   procedure Put(c: Character; fg: Colour := White; bg: BG_Colour := Black) is
   begin
      if c /= LF then
         VMem(Y,X) := (fg => fg, bg => bg, c => c);
         X := (if X = Width-1 then 0 else X+1);
      else
         X := 0;
      end if;

      if X = 0 then
         if Y < Height-1 then
            Y := Y + 1;
         else
            Y := Height-1;
            Shift_Lines;
         end if;
      end if;

   end Put;


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


   procedure Put(num : Integer; Base : Natural := 10; fg : Colour :=  White; bg : BG_Colour := Black) is
      Digit : array(0 .. 32) of Character;
      n : Integer := num;
      i : Natural := 0;
   begin
      if num < 0 then
         Put('-', fg=>fg, bg=>bg);
         n := abs num;
      end if;

      loop
         Digit(i) := Character'Val((n mod Base) + Character'Pos('0'));
         n := n / Base;
         exit when n = 0;
         i := i + 1;
      end loop;

      for x in reverse 0..i loop
         Put(Digit(x), fg=>fg, bg=>bg);
      end loop;

   end Put;

   procedure Put(a : System.Address; fg : Colour :=  White; bg : BG_Colour := Black) is 
   begin 
      Put("0x");
      Put(A_To_Int(a), Base=>16);
   end;

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



   procedure Shift_Lines(num : Positive := 1) is
   begin
      for j in 0..Height-1-num loop
         for i in 0..Width-1 loop
            VMem(j, i) := VMem(j+num, i);
         end loop;
      end loop;

      for j in Height-num..Height-1 loop
         for i in 0..Width-1 loop
            VMem(j,i) := (fg=>White, bg=>Black, c=>' ');
         end loop;
      end loop;
   end;

end console;