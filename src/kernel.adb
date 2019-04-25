with Interfaces, System.Machine_Code;
use Interfaces, System.Machine_Code;

with Console, Common;
use Console, Common;
with Arch, MMap; 
with Error; use Error;

with X86.VM; use X86.VM;

with KernelInteract, Syscall;

with System; 
with System.Storage_Elements; use System.Storage_Elements;

procedure Kernel is

   KERNEL_PAGE : constant X86.VM.Flags_Type 
                     := X86.VM.IS_PAGE or X86.VM.PRESENT or X86.VM.WRITEABLE or X86.VM.USER;

   USER_PAGE : constant X86.VM.Flags_Type := KERNEL_PAGE or X86.VM.USER;

   -- base and size of biggest memory hole
   Biggest_Base: Address := NULL_ADDRESS;
   Biggest_Size: Unsigned_64 := 0;

   MMap_Base:    Address := NULL_ADDRESS;
   MMap_Size:    Unsigned_64 := 0;

   Success:    Boolean;

   Userland_Entry : access procedure with Import => True, External_Name => "userland";
   Userland_PA    : Physical_Address := Physical_Address(To_Integer(Userland_Entry'Address));
   Userland_VMA   : Virtual_Address := 16#800_000#;

begin
   Banner   ("SOS#toast", FG=>White, BG=>Cyan);
   Put_Line ("-> entered 64-bit long mode" );

   -- find base and size of largest memory hole.
   Arch.Scout_Memory(Biggest_Base, Biggest_Size, False);
   Panic_If(Biggest_Size = 0, "No Free Memory?");

   Put("-> Using largest hole ("); Put_Size(Biggest_Size); Put(") RAM @"); 
      Put_Hex(Biggest_Base); Put(LF);


   -- set up the kernel page mapper, excluding any already reserved memory
   Put_Line("-> Initialising kernel page mapper");
   MMap_Base := Address'Max(X86.UNRESERVED_BASE, Biggest_Base);
   MMap_Size := Biggest_Size - Unsigned_64(MMap_Base - Biggest_Base);
   MMap.Initialise(MMap_Base, MMap_Size, Common.PAGE_SIZE);
     

   -- initialise architecture-specific interrupts
   Put_Line("-> (re)enabling interrupts");
   Arch.Initialise_Interrupts;


   -- Setup Virutal Memory 
   X86.VM.Initialise;
   X86.VM.Create_Mapping(  X86.KERNEL_PHYS_BASE,   -- Virtual Address
                           X86.KERNEL_PHYS_BASE,   -- Physical address
                           KERNEL_PAGE,            -- Flags
                           X86.VM.Page_2M,         -- Page Size
                           Success);               -- Success / Failure
   Panic_If(not Success, "Could not map kernel page");
   Arch.Reload_CR3(X86.PD_POOL_BASE);


   -- identity map the rest of physical memory
   -- Put_Line("-> identity mapping remainder of physical memory in 2M pages");
   -- Page_Base := MMap_Base;
   -- while Unsigned_64(Page_Base) + 16#200_000# < Unsigned_64(MMap_Base) + MMap_Size loop
   --    X86.VM.Create_Mapping(  Virtual_Address(Page_Base),
   --                            Physical_Address(Page_Base),
   --                            KERNEL_PAGE,
   --                            X86.VM.Page_2M,
   --                            Success); 

   --    Panic_If(not Success, "Could not map page");
   --    Page_Base := Page_Base + 16#200_000#;
   -- end loop;

   Put_Line("-> preparing to enter userland");
   X86.VM.Create_Mapping(  Userland_VMA,
                           Userland_PA,
                           USER_PAGE,
                           X86.VM.Page_4K,
                           Success); 
   
   -- enter the kernel interaction console
   KernelInteract;    

end Kernel;