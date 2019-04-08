with System;
with Interfaces; use Interfaces;
with Common; use Common;

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
      bg at 1 range 4..6;
   end record;

    -- new procedures
    procedure At_X(X : Natural);
    procedure Put(C : Character);
    procedure Put(S: String);
    procedure Put(N : Unsigned_64; Base : Unsigned_64 := 10);
    procedure Put(N : Integer);
    procedure Put_Hex(N: Unsigned_64);
    procedure Put_Hex(N: Address);
    procedure Put_Size(N: Unsigned_64);
    procedure Put_Line(S: String);    
    procedure Banner(S : String; FG: Colour := White; BG: BG_Colour :=Black);
    procedure Set_Colour(FG: Colour := White; BG: BG_Colour := Black);
    procedure Clear;

private
   procedure  Shift_Lines(num : Positive := 1);

end Console;