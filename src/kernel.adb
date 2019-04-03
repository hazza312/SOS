with System.Storage_Elements;    use System.Storage_Elements;
with Interfaces;                 use Interfaces;
with System;

with Console;                    use Console;
with Arch; 
with MMap;


procedure Kernel is
   Holes:      Arch.Holes_List;
   Max_Hole:   Arch.Free_Hole;

   procedure Panic(S: String) is 
   begin 
      Banner("KERNEL PANIC", bg=>Red, fg=>White);
      Put_Line(S);
      loop
         null;
      end loop;
   end Panic;

begin
   Banner   ("SOS Booting",                  bg=>Cyan, fg=>White  );
   Put_Line ("-> entered 64-bit long mode"                        );
   Banner   ("Memory Map",                   bg=>White, fg=>Black );

   -- fill holes with free holes, ordered largest to smallest
   Arch.Scout_Memory(Holes);  

   if Holes(0).Length = 0 then Panic("No Free Memory?"); end if;

   declare 
      package Page_Mapper is new MMap(
         Allocation_Unit => Holes(0).Length,
                  
      );
   begin
      Page_Mapper.Hey;
   end;

   
   Panic("Nothing left to do");
end Kernel;
