with Console; use Console;
with Interfaces; use Interfaces;
with System.Machine_Code; use System.Machine_Code;
with X86.Interrupts; use X86.Interrupts;
with X86.Dev.Keyboard;

package body Error is 

procedure Panic_If(Condition: Boolean; S: String) is
begin   
    if Condition then 
        Panic(S);
    end if;
end Panic_If;

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
    Asm("cli", Volatile=>True);
    Put(LF);

    if not V'Valid then 
        Banner("???", bg=>Console.Red);
        Put("Some impossible event occured (unknown interrupt/exception): ");

    elsif V in CPU_Exception then 
        Banner("CPU EXCEPTION", bg=>Console.Red);
        Put("Some uncaught exception occured: ");
        Put(Interrupt_Name(V).all);

    else 
        Banner("UNHANDLED INTERRUPT", bg=>Console.Red);
        Put("Some unhandled (external) interrupt occured: ");
        Put(Interrupt_Name(V).all);
    end if;
    Put(" -> ");    Put_Hex(Unsigned_64(Interrupt'Enum_Rep(V)));
    Put(LF);

    
    Put_Line("Halted.");
    Asm("hlt", Volatile => True);
    
    -- Asm("sti");
    -- Put_Line("Press any key to restart..");
    -- X86.Dev.Keyboard.Flush;
    -- while not X86.Dev.Keyboard.Has_Input loop null; end loop;
    -- Put_Line("ok");

    -- Asm("movq $0xdeadbeef, %%rax" & ASCII.LF &
    --     "movq %%rax, %%cr3", Volatile=>True);
end Exception_Handler;

procedure lastchance(Msg : String; Line: Integer) is
begin
    Put(Console.LF);
    Banner("KERNEL PANIC", bg=>Console.Red);
    Put_Line("Some unknown error occured in");
    Put("==> ");    Put(Msg);    Put(", line: ");    Put(Line);

    Asm("cli", Volatile=>True);
    Asm("hlt", Volatile=>True);
end lastchance;

end Error;