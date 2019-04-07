with Interfaces; use Interfaces;
with Kernel; use Kernel;
with System;
with System.Storage_Elements; use System.Storage_Elements;

package body X86.Interrupts is 

    Handler_Table : array(0..63) of System.Address
        with Import, Convention => Assembler, External_Name => "handler_table";


    procedure Register_Handler(IRQ: Interrupt; Handler: System.Address) is 
        H : Unsigned_64 := Unsigned_64(To_Integer(Handler));
    begin
        -- Table(Interrupt'Enum_Rep(IRQ)) := (
        --     Offset_0_15  => Unsigned_16(H and 16#ffff#),
        --     Offset_16_31 => Unsigned_16(Shift_Right(H, 16) and 16#ffff#),
        --     Offset_32_63 => Unsigned_32(Shift_Right(H, 32) and 16#ffffffff#),
        --     P            => True,
        --     others       => <>);
        Handler_Table(Interrupt'Enum_Rep(IRQ)) := Handler;
    end Register_Handler;


end X86.Interrupts;