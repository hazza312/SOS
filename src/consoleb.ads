with System;
with Interfaces; use Interfaces;

package Consoleb is

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

   generic
        with procedure At_X(x : Natural);
        with procedure Put(c : Character; fg: Colour := White; bg : BG_Colour := Black);
        with procedure Clear;
    package Printer is 
        procedure Put(s: String; fg: Colour :=  White; bg : BG_Colour := Black);
        procedure Put_Size(Size: Natural);
        procedure Put_Line(s: String; fg: Colour :=  White; bg : BG_Colour := Black);
        procedure Put_Unsigned(num : Natural; Base : Natural := 10; fg : Colour :=  White; bg : BG_Colour := Black);
        procedure Put_Int(num : Integer; Base : Natural := 10; fg : Colour :=  White; bg : BG_Colour := Black);
        procedure Put_Hex(n: Positive; fg : Colour :=  White; bg : BG_Colour := Black);
        procedure Banner(s : String; fg: Colour := White; bg: BG_Colour := Black);
    end Printer;
    

end Consoleb;