with System.Storage_Elements;    use System.Storage_Elements;
with Interfaces;                 use Interfaces;
with System; 
with System.Machine_Code; use System.Machine_Code;

with Console;                    use Console;
with Arch; 
with MMap;
with Error; use Error;

with Common; use Common;
with Input;

with X86.Debug;
with X86.Dev.PIT_8253;
with X86.Dev.Keyboard;
with X86.Dev.RTC;
with X86.VM;

with KernelInteract;

procedure Kernel is

   -- base and size of biggest memory hole
   Biggest_Base: Address := NULL_ADDRESS;
   Biggest_Size: Unsigned_64 := 0;

   -- test the memory allocator
   Allocs : array(0..5) of Address;
   X : Virtual_Address;
   Y: Boolean;

begin
   Banner   ("SOS#toast", FG=>White, BG=>Cyan);
   Put_Line ("-> entered 64-bit long mode" );

   -- find base and size of largest memory hole.
   Arch.Scout_Memory(Biggest_Base, Biggest_Size, False);  
   if Biggest_Size = 0 then Panic("No Free Memory?"); end if;

   Put("-> Using largest hole ("); Put_Size(Biggest_Size); Put(") RAM @"); 
      Put_Hex(Biggest_Base); Put(LF);
   Put_Line("-> Initialising kernel page mapper");

   -- X86.Debug.Print_Multiboot_Map

   -- set up the kernel page mapper
   MMap.Initialise(Biggest_Base + 16#8000#, Biggest_Size- 16#8000#, PAGE_SIZE);
     

   -- initialise architecture-specific interrupts
   Put_Line("-> (re)enabling interrupts");
   Arch.Initialise_Interrupts;
      -- KernelInteract;
   --X86.Vm.Dump_Pages; 
   -- inserting a page directory
   --Y :=X86.VM.Insert_Directory(Address(16#107000#), 2);
--   X := X86.VM.Map_Page(Address(16#107000#), Address(16#250000#), X86.VM.PAGE_4K_LEVEL);

   --X := X86.VM.Map_Page(Address(16#107000#), Address(16#251000#), X86.VM.PAGE_4K_LEVEL);

   -- X86.Vm.Dump_Pages;
   --map some memory into the VM space
   -- Put_Line("-> mapping 25 2M pages of memory..");
   -- for I in 1..522 loop
   --    --X := X86.VM.Map_Page(Address(16#107000#), Address(16#200000# * I), X86.VM.PAGE_4K_LEVEL);
   --    Put(I); Put(" given "); Put_Hex(Address(X)); Put(LF);
   -- end loop;
   --KernelInteract;    
   -- X86.Vm.Get_Table_VMAS(2**64 - 16#2000#, Tables);
   Y := X86.Vm.Map_Page(16#106000#, 16#eeee_eeee_eeee_0000#, 16#2000_0000#, X86.Vm.Page_2M);

   Put(LF);

   -- enter the kernel interaction console
   KernelInteract;    

end Kernel;