with Console; use Console;

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

procedure lastchance(Msg : System.Address; Line: Integer) is
    type c_array is array(Positive range <>) of Character;
    chars : c_array(1..100) with Address => Msg;
begin
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