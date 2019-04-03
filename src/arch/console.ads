with System;
with Interfaces; use Interfaces;

package Console is

   Width : constant Integer := 80;
   Height : constant Integer := 25;

   LF : constant Character := Character'Val(16#0A#);

   type Colour is (
      Black, Blue, Green, Cyan,
      Red, Magenta, Brown, Grey,
      Dark_Grey, Light_Blue, Light_Green, Light_Cyan,
      Light_Red, Light_Magenta, Yellow, White
   );

   subtype BG_Colour is Colour range Black..Grey;

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

   procedure At_X(x : Natural);
   procedure Put(c : Character; fg: Colour := White; bg : BG_Colour := Black);
   procedure Put(s: String; fg: Colour :=  White; bg : BG_Colour := Black);
   procedure Put_Size(Size: Natural);
   procedure Put_Line(s: String; fg: Colour :=  White; bg : BG_Colour := Black);
   procedure Put_Unsigned(num : Positive; Base : Natural := 10; fg : Colour :=  White; bg : BG_Colour := Black);
   procedure Put_Int(num : Integer; Base : Natural := 10; fg : Colour :=  White; bg : BG_Colour := Black);
   procedure Put_Hex(n: Positive; fg : Colour :=  White; bg : BG_Colour := Black);

   procedure Banner(s : String; fg: Colour := White; bg: BG_Colour := Black);

   procedure Clear;

private
   procedure  Shift_Lines(num : Positive := 1);

end Console;