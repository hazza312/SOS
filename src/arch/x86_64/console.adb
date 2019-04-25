with Interfaces; use Interfaces;
with Common; use Common;
with Arch; use Arch;

package body console is

   VMem : array(0..Height-1, 0..Width-1) of cell;
   for VMem'Address use System'To_Address(16#B8000#);

   X: Natural := 0;
   Y: Natural := 0;

   Current_FG : Colour := White;
   Current_BG : BG_Colour := Black;

   procedure At_X(X : Natural) is 
   begin 
      Console.X := X;
   end At_X;

   procedure Set_Colour(FG: Colour := White; BG: BG_Colour := Black) is 
   begin
      Current_BG := BG;
      Current_FG := FG;
   end Set_Colour;
        

   procedure Clear is
   begin
      Shift_Lines(Height);
   end Clear;

   procedure Put(C: Character) is
      P : Unsigned_16;
   begin
      if c /= LF then
         VMem(Y,X) := (fg => Current_FG, bg =>Current_BG, c => c);
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

      P := Unsigned_16(Y) * Unsigned_16(WIDTH) + Unsigned_16(X);

      IO_Outb(16#3D4#, 16#F#);
      IO_Outb(16#3D5#, Unsigned_8(P and 16#ff#));

      IO_Outb(16#3D4#, 16#E#);
      IO_Outb(16#3D5#, Unsigned_8( Shift_Right(P, 8) and 16#ff#));

   end Put;


   procedure Put(S: String) is
   begin
      for c of s loop
         exit when c = Character'Val(0); 
         Put(c);
      end loop;
   end Put;

   procedure Put_C(S: String) is
   begin
      Put(S);
   end Put_C;


   procedure Put_Line(S: String) is
   begin
      Put(S);
      Put(LF);
   end Put_Line;


   procedure Put_Hex(N: Address) is begin Put_Hex(Unsigned_64(N)); end Put_Hex;

   procedure Put_Hex(N: Unsigned_64) is
   begin 
      Put("0x");
      Put(N, Base=>16);
   end Put_Hex;


   procedure Put(N : Integer) is 
   begin
      if N < 0 then
         Put('-');
      end if;
      Put(Unsigned_64(abs N));
   end;


   procedure Put(N : Unsigned_64; Base : Unsigned_64 := 10) is
      Chars : array(Unsigned_64 range 0..15) of Character := "0123456789ABCDEF";
      Digit : array(0..63) of Character;
      X : Unsigned_64 := N;
      i : Natural := 0;
   begin
      loop
         Digit(i) := Chars(X mod Base);
         X := X / Base;
         exit when X = 0;
         i := i + 1;
      end loop;

      for J in reverse 0..i loop
         Put(Digit(J));
      end loop;
   end Put;



   procedure Banner(S : String; FG : Colour := White; BG: BG_Colour :=Black) is
      L_Pad : Positive := (width - s'Length) / 2;
      R_Pad : Positive := width - L_Pad - s'Length;
      Old_FG : Colour := Current_FG;
      Old_BG : BG_Colour := Current_BG;
   begin
      Current_BG := BG;
      Current_FG := FG;

      for i in 1..L_Pad loop  Put(' ');   end loop;
      Put(s);
      for i in 1..R_Pad loop  Put(' ');    end loop;

      Current_BG := Old_BG;
      Current_FG := Old_FG;
   end;

   
   procedure Put_Size(N: Unsigned_64) is
   begin 
      case N is 
      when 0      ..1024**1 -1   => Put(N);           Put("B");
      when 1024**1..1024**2 -1   => Put(N / 1024**1); Put("kB");
      when 1024**2..1024**3 -1   => Put(N / 1024**2); Put("MB");
      when others                => Put(N / 1024**3); Put("GB");
      end case;
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