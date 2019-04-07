with Interfaces; use Interfaces;
with Kernel; use Kernel;
with System;
with System.Storage_Elements; use System.Storage_Elements;
with Console; use Console;
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



end X86.Interrupts;