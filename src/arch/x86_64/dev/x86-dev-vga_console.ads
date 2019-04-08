with System;
with Interfaces; use Interfaces;
with Console; use Console;
package X86.Dev.VGA_Console is



   Width : constant Integer := 80;
   Height : constant Integer := 25;

   type cell is record
      c : Character;
      fg : Colour;
      bg : BG_Colour;
   end record;

   for cell use record
      c at 0 range 0..7;
      fg at 1 range 0..3;
      bg at 1 range 4..7;
   end record;

    procedure At_X(New_X : Natural);
    procedure Put(c : Character; fg: Colour := White; bg : BG_Colour := Black);
    procedure Clear;


private
   procedure  Shift_Lines(num : Positive := 1);

end X86.Dev.VGA_Console;