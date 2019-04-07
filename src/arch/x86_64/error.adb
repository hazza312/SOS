with Console; use Console;
with Interfaces; use Interfaces;
with System.Machine_Code; use System.Machine_Code;
with X86.Interrupts; use X86.Interrupts;

package body Error is 

procedure Panic(S: String) is 
begin 
    Put(LF);
    Banner("KERNEL PANIC", bg=>Red, fg=>White);
    Put_Line(S);
    Asm("cli", Volatile=>True);
    Asm("hlt", Volatile=>True);
end Panic;

procedure Exception_Handler is
    V : Interrupt;
begin 
    Asm("movb %%al, %0", Outputs => Interrupt'Asm_Output("=g", V), Volatile=>True);
    Put(LF);

    if V in CPU_Exception then 
        Banner("CPU EXCEPTION", bg=>Console.Red);
        Put("Some uncaught exception occured: ");
    else 
        Banner("Uncaught Interrupt", bg=>Console.Red);
        Put("Some unhandled (external) interrupt occured: ");
    end if;
    
    Put_Hex(Interrupt'Enum_Rep(V));
    Put(" -> ");

    case V is
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

        when PIT                => Put_Line("PIT");
        when Keyboard           => Put_Line("Keyboard");
        when PIC_Slave          => Put_Line("PIC Slave");
        when COM2_4             => Put_Line("Serial COM2/4");
        when COM1_3             => Put_Line("Serial COM1/3");
        when LPT2               => Put_Line("LPT2");
        when Floppy             => Put_Line("Floppy");
        when LPT1               => Put_Line("LPT1");
        when RTC                => Put_Line("Real Time Clock");
        when Mouse              => Put_Line("Mouse");
        when Math_Coprocessor   => Put_Line("Math Coprocessor");
        when HD1                => Put_Line("Hard Disk Controller 1");
        when HD2                => Put_Line("Hard Disk Controller 2");
        when others             => Put_Line("unknown");
    end case;

    Asm("cli", Volatile=>True);
    Asm("hlt", Volatile=>True);

end Exception_Handler;

procedure lastchance(Msg : String; Line: Integer) is
begin
    Put(Console.LF);
    Banner("KERNEL PANIC", bg=>Console.Red);
    Put_Line("Some unknown error occured in");
    Put("==> ");    Put(Msg);    Put(", line: ");    Put_Int(Line);

    Asm("cli");
    Asm("hlt");
end lastchance;

end Error;