with Console; use Console;
with Interfaces; use Interfaces;
with System.Machine_Code; use System.Machine_Code;

package body Error is 

procedure Panic(S: String) is 
begin 
    Put(LF);
    Banner("KERNEL PANIC", bg=>Red, fg=>White);
    Put_Line(S);
    loop
        null;
    end loop;
end Panic;

procedure Exception_Handler is
    V : Unsigned_64;
begin 
    Asm("movq %%rdi, %0", Outputs => Unsigned_64'Asm_Output("=g", V));
    Asm("cli");
    Console.Put(LF);
    Console.Banner("CPU EXCEPTION", bg=>Console.Red);
    Console.Put("Some uncaught exception occured: ");
    Console.Put_Hex(Integer(V));
    Console.Put(" -> ");

    case CPU_Exception'Val(V) is
        when DE      => Put_Line("Divide by Zero (#DE)");
        when DB      => Put_Line("Debug (#DB)");
        when NMI     => Put_Line("NMI");
        when BP      => Put_Line("Breakpoint (#BP)");
        when OFE     => Put_Line("Overflow (#OF)");
        when BR      => Put_Line("Bound_Range (#BR)");
        when UD      => Put_Line("Invalid Opcode (#UD)");
        when NM      => Put_Line("Device Not Available (#NM)");
        when DF      => Put_Line("Double Fault (#DF)");
        when TS      => Put_Line("Invalid TSS (#TS)");
        when NP      => Put_Line("Segment Not Present (#NP)");
        when SS      => Put_Line("Stack Exception (#SS)");
        when GP      => Put_Line("General Protection Fault (#GP)");
        when PF      => Put_Line("Page Fault (#PF)");
        when MF      => Put_Line("X87 FP Exception (#MF)");
        when AC      => Put_Line("Alignment Check Exception (#AC)");
        when MC      => Put_Line("Machine Check Exception (#MC)");
        when XF      => Put_Line("SIMD FP Exception (#XF)");
        when VC      => Put_Line("VMM Communication Exception (#VC)");
        when SX      => Put_Line("Security Exception (#SX)");
        when others  => Put_Line("external/software interrupt(?)");
    end case;
    
    Asm("hlt");

end Exception_Handler;

procedure lastchance(Msg : String; Line: Integer) is
begin
    Console.Put(Console.LF);
    Console.Banner("KERNEL PANIC", bg=>Console.Red);
    Console.Put_Line("Some unknown error occured in");
    Console.Put("==> ");

    Console.Put(Msg);

    Console.Put(", line: ");
    Console.Put_Int(Line);

    loop null; end loop;
end lastchance;

end Error;