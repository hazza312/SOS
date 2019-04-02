with Console; use Console;
with VM;
with IDT;
with System;

procedure Kernel is
   Boot_Info: System.Address;
   pragma Import(C, Boot_Info, "bootinfo");
   

begin
   Banner("Hello World!", bg=>Cyan, fg=>White);
   Put_Line("-> Entered 64-bit kernel");
   Put_Line("-> Setting up IDTs");
   Put("-> Setting up GDTs");
   Put_Line(".. done");

   Put("MultiBoot2 Info at");
      Put(Boot_Info);
      Put(LF);


   -- infinite loop
   loop
      null;
   end loop;
end Kernel;
