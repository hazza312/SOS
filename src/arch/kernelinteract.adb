with Console; use Console;
with System.Machine_Code; use System.Machine_Code;
with Interfaces; use Interfaces;
with Input;
with X86.VM;
with X86;
with MMap;
with Arch;
with Common; use common;
with X86.Dev.Pit_8253, X86.Dev.Keyboard, X86.Dev.RTC;
with X86.Interrupts;
with Interfaces.C; use Interfaces.C;

procedure KernelInteract is 

   procedure Debug is begin null; end Debug;

   procedure C_VM_Test_Init(sz: Interfaces.C.size_t) 
   with  Import, 
         Convention => C,
         External_Name => "init_mem";

   procedure C_VM_Test_All  
   with  Import, 
         Convention => C,
         External_Name => "test_all";



   function Equals(S1,S2: String; Length: Positive) return Boolean is 
      S1_I : Positive := S1'First;
      S2_I : Positive := S2'First;
   begin 
      while S1_I <= Length and then S2_I <= S2'Last loop 
         if S1(S1_I) /= S2(S2_I) then 
            return False;
         end if;

         S1_I := S1_I + 1;
         S2_I := S2_I + 1;
      end loop;
      return (S1_I = (Length+1)) and (S2_I = (S2'Last+1));
   end Equals;

   Exception_Number : Unsigned_8;
   IDT_Entry : Address := 16#100018#;
   Command : String(1..73);
   Command_Length : Positive; 

   -- throwaway variables, multiboot mapper will store what it finds here.
   Base : Address := 0;
   Base_Length : Unsigned_64 := 0;

begin
   -- Asm("sti");
   Put_Line("Entered Week 2 Console, type [help] for commands");

   loop 
      Set_Colour;
      Put("# ");
      Command_Length := Input.Get_Line(Command);

      if Equals(Command, "hey", Command_Length) then 
      Put_Line("sup");

      elsif Equals(Command, "help", Command_Length) then 
         Put_Line("commands:");
         Put_Line("  multiboot     : show multiboot memory info");
         Put_Line("  kmap          : show kernel free list");
         Put_Line("  mmap          : show virtual memory mappings");
         Put_Line("  uptime        : display system uptime");
         Put_Line("  interrupts    : show interrupt mapping");
         Put_Line("  ticks         : show interrupt ticks");
         Set_Colour(FG=>Light_Green);
         Put_Line("  userland      : down the rabbit hole to #userland");
         Set_Colour;
         Put_Line("  vmtest        : run VM OS test cases");
         Put_Line("  crash         : deliberately crash the kernel");

      elsif Equals(Command, "vmtest", Command_Length) then 
         Banner("Virtual Memory Test Cases", bg=>White, fg=>Black);
         Put_Line("Any CPU Exceptions thrown suggest an error...");
         C_VM_Test_Init(Interfaces.C.size_t(MMap.Get_Length));
         C_VM_Test_All;


      elsif Equals(Command, "mmap", Command_Length) then 
         Banner("Virtual Memory Map", bg=>White, fg=>Black);
         X86.Vm.Dump_Pages(X86.PD_POOL_BASE); 

      elsif Equals(Command, "kmap", Command_Length) then 
         Banner("Kernel Free Map", bg=>White, fg=>Black);
         Mmap.Print; 

      elsif Equals(Command, "multiboot", Command_Length) then 
         Banner("Multiboot Map", bg=>White, fg=>Black);
         Arch.Scout_Memory(Base, Base_Length, True);   

      elsif Equals(Command, "interrupts", Command_Length) then 
         Banner("Registered Interrupts", bg=>White, fg=>Black);
         X86.Interrupts.Dump_Mapping; 

      elsif Equals(Command, "ticks", Command_Length) then 
         At_X(0);    Put("-> PIT ticks:");
         At_X(29);   Put("Keyboard ticks:");
         At_X(55);   Put("RTC Ticks:");

         while not X86.Dev.Keyboard.Has_Input loop 
            Set_Colour(bg => Light_Magenta, fg=>White);
            At_X(14); Put(X86.Dev.Pit_8253.Get_Ticks);
            At_X(45); Put(X86.Dev.Keyboard.Get_Ticks);
            At_X(66); Put(X86.Dev.RTC.Get_Ticks);
         end loop;
      Put(LF);

      elsif Equals(Command, "uptime", Command_Length) then 
         Put("-> Uptime ");
         Set_Colour(BG=>Light_Green);
         while not X86.Dev.Keyboard.Has_Input loop 
            At_X(12); Put(X86.Dev.RTC.Get_Ticks/2); Put(" seconds");
         end loop;
      Put(LF);

      elsif Equals(Command, "crash", Command_Length) then
         Put("Enter a key: ");
         Exception_Number := Unsigned_8(Character'Pos(Input.Get_Char));
         IDT_Entry := @ + Address((Exception_Number and 31) * 8);
         Asm("call *%0", 
            Inputs => Address'Asm_Input("d", IDT_Entry), 
            Volatile => True);

      elsif Equals(Command, "userland", Command_Length) then
         Put_Line("here");
         Debug;
         Asm(  "cli"                       & LF &
               "movw    $(0x28 | 3), %%ax" & LF &
               "movw    %%ax, %%ds"        & LF &
               "movw    %%ax, %%es"        & LF &
               "movw    %%ax, %%fs"        & LF &
               "movw    %%ax, %%gs"        & LF &     
            
               "push    $(0x28 | 3)"       & LF &   -- Stack selector
               "push    $0x800600"         & LF &   -- RSP
               "pushf    "                 & LF &   -- RFLAGS
               "push    $0x23"             & LF &   -- CPL3 CS
               "push    $0x800000"         & LF &   -- RIP
               "iretq",
               Volatile => True
         ); 

      elsif Command_Length = 0 then 
         null;

      else 
         Set_Colour(bg=>Red);
         Put(Command); Put_Line("..?");
      end if;

   end loop;
end KernelInteract;