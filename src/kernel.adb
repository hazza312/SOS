with Interfaces, System.Machine_Code;
use Interfaces, System.Machine_Code;

with Console, Common;
use Console, Common;
with Arch, MMap; 
with Error;

with X86.VM;
with X86.VM2; use X86.VM2;

with KernelInteract, Syscall;

procedure Kernel is
   -- base and size of biggest memory hole
   Biggest_Base: Address := NULL_ADDRESS;
   Biggest_Size: Unsigned_64 := 0;

   -- test the memory allocator
   Y: Boolean;

begin
   Banner   ("SOS#toast", FG=>White, BG=>Cyan);
   Put_Line ("-> entered 64-bit long mode" );

   -- find base and size of largest memory hole.
   Arch.Scout_Memory(Biggest_Base, Biggest_Size, False);  
   if Biggest_Size = 0 then Error.Panic("No Free Memory?"); end if;

   Put("-> Using largest hole ("); Put_Size(Biggest_Size); Put(") RAM @"); 
      Put_Hex(Biggest_Base); Put(LF);
   Put_Line("-> Initialising kernel page mapper");

   -- set up the kernel page mapper
   MMap.Initialise(Biggest_Base + 16#8000#, Biggest_Size- 16#8000#, Common.PAGE_SIZE);
   -- MMap.Exclude(X86.KERNEL_PHYS_BASE, X86.KERNEL_SIZE); -- exclude the kernel
   -- MMap.Exclude(X86.PD_POOL_BASE, X86.PD_POOL_SIZE); -- exclude the our PD dirs
     

   -- initialise architecture-specific interrupts
   Put_Line("-> (re)enabling interrupts");
   Arch.Initialise_Interrupts;

   Put_Line("-> mapping physical memory");
   -- for I in 0 .. (Biggest_Size / 16#1000#) -1 loop 
   --    Y :=X86.VM.Map_Page(Arch.CR3_Address, 16#1000_0000_0000# + Virtual_Address(I) * 16#1000#, Physical_Address(Biggest_Base + Address(I) * 16#1000#), X86.VM.Page_4K);
   -- end loop;



   X86.VM2.Initialise;
   X86.VM2.Create_Mapping(X86.PD_POOL_BASE, 16#0#, 16#0#, X86.VM2.IS_PAGE or X86.VM2.PRESENT or X86.VM2.WRITEABLE, X86.VM2.Page_2M, Y);
   Asm(  "movq $0x200000, %%rax" & LF &
         "movq %%rax, %%cr3",
         Clobber => ("rax"),
         Volatile => True
   );


   Put(LF);

   -- Asm("movq $0, %%rdi", Clobber => ("rdi"), Volatile => True);
   --Asm("syscall", Volatile => True);
   -- enter the kernel interaction console
   KernelInteract;    

end Kernel;