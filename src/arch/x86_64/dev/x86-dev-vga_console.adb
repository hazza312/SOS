with System;
with Interfaces; use Interfaces;

package body X86.Dev.VGA_Console is

   VMem : array(0..Height-1, 0..Width-1) of cell;
   for VMem'Address use System'To_Address(16#B8000#);

   X: Natural := 0;
   Y: Natural := 0;

   procedure At_X(New_X : Natural) is 
   begin 
      X := New_X;
   end At_X;

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

    procedure Clear is 
    begin 
        Shift_Lines(Height);
    end Clear;


end X86.Dev.VGA_Console;