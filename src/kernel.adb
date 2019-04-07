with System.Storage_Elements;    use System.Storage_Elements;
with Interfaces;                 use Interfaces;
with System; use System;
with System.Machine_Code; use System.Machine_Code;

with Console;                    use Console;
with Arch; 
with MMap;
with Error; use Error;
with Consoleb;

package body Kernel is

procedure Kernel is
begin
   Banner   ("SOS#toast", bg=>Cyan, fg=>White  );
   Put_Line ("-> entered 64-bit long mode" );
   Put(LF);
   Banner   ("System Map", bg=>White, fg=>Black );

   -- fill holes with free holes, ordered largest to smallest
   Arch.Scout_Memory(Holes);  
   if Holes(0).Length = 0 then Panic("No Free Memory?"); end if;

   Put("-> Using largest hole ("); 
      Put_Size(Holes(0).Length); 
      Put(") RAM @"); 
      Put_Hex(Positive( To_Integer(Holes(0).Base)) );
      Put(LF);
   Put_Line("-> Initialising kernel page mapper");
   Put(LF);
    
   declare 
      package Page_Mapper is new MMap(
         Min_Allocation  => PAGE_SIZE,
         Base_Address    => Holes(0).Base,
         Max_Length      => Holes(0).Length,
         Num_Elements    => 15
      );

      Allocs : array(0..3) of System.Address;

   begin

      Banner   ("Kernel Map", bg=>White, fg=>Black);
      Allocs(0) := Page_Mapper.Allocate(PAGE_SIZE);
      Allocs(1) := Page_Mapper.Allocate(PAGE_SIZE);
      Allocs(2) := Page_Mapper.Allocate(PAGE_SIZE);
      Page_Mapper.Free(Allocs(0), PAGE_SIZE);      
      Page_Mapper.Print;
   end;

    Put_Line("-> (re)enabling interrupts");
    Arch.Initialise_Interrupts;

end Kernel;
end Kernel;