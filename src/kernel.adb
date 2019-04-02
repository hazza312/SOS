with Console;
with VM;
with IDT;

procedure Kernel is
begin
   Console.Banner("Hello World!", bg=>Console.Cyan, fg=>Console.White);
   Console.Put_Line("-> Entered 64-bit kernel");
   Console.Put("-> Setting up IDTs");
   Console.Put("-> Setting up GDTs");
   Console.Put_Line(".. done");


   -- infinite loop
   loop
      null;
   end loop;
end Kernel;
