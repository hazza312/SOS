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

procedure CPU_Exception(V: Unsigned_64) is
begin 
    Asm("cli");
    Console.Banner("KERNEL PANIC (EXCEPTION)", bg=>Console.Red);
    Console.Put_Line("Some uncaught exception occured: ");
    Console.Put_Int(Integer(V));
    Asm("hlt");

end CPU_Exception;

procedure lastchance(Msg : System.Address; Line: Integer) is
    type c_array is array(Positive range <>) of Character;
    chars : c_array(1..100) with Address => Msg;
begin
    Console.Put(Console.LF);
    Console.Banner("KERNEL PANIC", bg=>Console.Red);
    Console.Put_Line("Some unknown error occured in");
    Console.Put("==> ");

    for c of chars loop
        exit when c = Character'Val(0);
        Console.Put(c);
    end loop;

    Console.Put(", line: ");
    Console.Put_Int(Line);

    loop null; end loop;
end lastchance;

end Error;