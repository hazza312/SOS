with Interfaces; use Interfaces;
with Common; use Common;
with System;
with System.Storage_Elements; use System.Storage_Elements;
with Console; use Console;
use System;


package body X86.Interrupts is 

   Handler_Table : array(0..63) of System.Address
      with Import, Convention => Assembler, External_Name => "handler_table";
   for Handler_Table'Size use 8*8*64;


   procedure Slow_Handler(IRQ: Interrupt; Handler: System.Address) is 
      H : Unsigned_64 := Unsigned_64(To_Integer(Handler));
   begin 
      Handler_Table(Interrupt'Enum_Rep(IRQ)) := Handler;
   end Slow_Handler;


   procedure Register_Handler(IRQ: Interrupt; Handler: System.Address) is 
      H : Unsigned_64 := Unsigned_64(To_Integer(Handler));
      A : Unsigned_16 := Unsigned_16(H and 16#ffff#);
      B: Unsigned_16 := Unsigned_16(Shift_Right(H, 16) and 16#ffff#);
      C: Unsigned_32 := Unsigned_32(Shift_Right(H, 32) and 16#ffff_ffff#);
   begin
      Table(Interrupt'Enum_Rep(IRQ)) := (
         Offset_0_15  => A,
         Offset_16_31 => B,
         Offset_32_63 => C,
         others => <>         
         );
   end Register_Handler;


   function Get_Fast_Handler(IRQ: Interrupt) return Common.Address is 
      E: IDT_Entry := Table(Interrupt'Enum_Rep(IRQ));
   begin 
      -- Put_Hex(Unsigned_64(E.Offset_0_15)); Put(LF);
      -- Put_Hex(Unsigned_64(E.Offset_16_31)); Put(LF);
      -- Put_Hex(Unsigned_64(E.Offset_32_63)); Put(LF);
      return Common.Address(
               Unsigned_64(E.Offset_0_15) 
            or Shift_Left(Unsigned_64(E.Offset_16_31), 16)
            or Shift_Left(Unsigned_64(E.Offset_32_63), 32));
   end Get_Fast_Handler;


   function Get_Default_Stub(IRQ: Interrupt) return Common.Address is
      Stubs : array(0..63) of Unsigned_64 with Import, External_Name => "stubs", Convention => Assembler;
   begin 
      return Common.Address(To_Integer( Stubs(Interrupt'Enum_Rep(IRQ))'Address)   );
   end Get_Default_Stub;


   procedure Dump_Mapping is
      Slow_Handler_Address : Common.Address;
      Fast_Handler_Address : Common.Address;
      Default_Stub_Address : Common.Address;

      Cols : constant array(0..3) of Integer := (0, 5, 30, 50);

   begin 
      Set_Colour(FG => Grey);
      At_X(Cols(0)); Put("IRQ");
      At_X(Cols(1)); Put("Interrupt");
      At_X(Cols(2)); Put("Handler Type");
      At_X(Cols(3)); Put("@");
      Set_Colour;
      Put(LF);

      for I in Interrupt'Range loop
         Slow_Handler_Address := Common.Address(To_Integer(Handler_Table(Interrupt'Enum_Rep(I))));
         Fast_Handler_Address := Get_Fast_Handler(I);
         Default_Stub_Address := Get_Default_Stub(I);


         if Slow_Handler_Address /= 0 then
            At_X(Cols(0)); Put_Hex(Unsigned_64(Interrupt'Enum_Rep(I))); 
            At_X(Cols(1)); Put(Interrupt_Name(Interrupt(I)).all);
            At_X(Cols(2)); Put("Slow");
            At_X(Cols(3)); Put_Hex(Slow_Handler_Address);
            Put(LF);

         elsif Fast_Handler_Address /= Default_Stub_Address then 
            At_X(Cols(0)); Put_Hex(Unsigned_64(Interrupt'Enum_Rep(I))); 
            At_X(Cols(1)); Put(Interrupt_Name(Interrupt(I)).all);
            At_X(Cols(2)); Put("Fast");
            At_X(Cols(3)); Put_Hex(Fast_Handler_Address);
            Put(LF);
         end if;         

      end loop;
      Put_Line("All others served by the default 'stub' exception handler.");
   end Dump_Mapping;


end X86.Interrupts;