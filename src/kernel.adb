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

procedure Kernel is

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


   Biggest_Size: Unsigned_64 := 0;
   Biggest_Base: Address := NULL_ADDRESS;
   S : String(1..80);
   T: Integer;
begin
   Banner   ("SOS#toast", FG=>White, BG=>Cyan);
   Put_Line ("-> entered 64-bit long mode" );

   -- find base and size of largest memory hole.
   Arch.Scout_Memory(Biggest_Base, Biggest_Size, False);  
   if Biggest_Size = 0 then Panic("No Free Memory?"); end if;

   Put("-> Using largest hole ("); Put_Size(Biggest_Size); Put(") RAM @"); 
      Put_Hex(Biggest_Base); Put(LF);
   Put_Line("-> Initialising kernel page mapper");
    
   declare 
      package Page_Mapper is new MMap(
         Min_Allocation  => PAGE_SIZE,
         Base_Address    => Biggest_Base,
         Max_Length      => Biggest_Size,
         Num_Elements    => 15
      );

      Allocs : array(0..5) of Address;
      X : Virtual_Address;

   begin
      -- just test out a couple of allocations and frees
      Allocs(0) := Page_Mapper.Allocate(PAGE_SIZE);
      Allocs(1) := Page_Mapper.Allocate(PAGE_SIZE);
      Allocs(2) := Page_Mapper.Allocate(PAGE_SIZE);
      Allocs(3) := Page_Mapper.Allocate(PAGE_SIZE);
      Allocs(4) := Page_Mapper.Allocate(PAGE_SIZE);
      Page_Mapper.Free(Allocs(3), PAGE_SIZE);   
      Page_Mapper.Free(Allocs(1), PAGE_SIZE);   

      Put_Line("-> (re)enabling interrupts");
      Arch.Initialise_Interrupts;

      Put_Line("-> mapping 25 2M pages of memory..");
      for I in reverse 1..5 loop
         X := X86.VM.Map_Page(Address(16#107000#), Address(16#200000# * I), X86.VM.Page_2M);
   end loop;
   --Put_Hex(Unsigned_64(X));
   Put(LF);


   declare
      Command : String(1..73);
      Length : Positive; 
      Int_No : Unsigned_8;
      Loc : Unsigned_64 :=  16#100018#;
   begin 
      Put_Line("Entered Week 2 Console, type [help] for commands");

      loop 
         Set_Colour;
         Put("# ");
         Length := Input.Get_Line(Command);

         if Equals(Command, "hey", Length) then 
            Put_Line("sup");

         elsif Equals(Command, "help", Length) then 
               Put_Line("commands:");
               Put_Line("  multiboot     : show multiboot memory info");
               Put_Line("  kmap          : show kernel free list");
               Put_Line("  mmap          : show virtual memory mappings");
               Put_Line("  uptime        : display system uptime");
               Put_Line("  interrupts    : show interrupt mapping");
               Put_Line("  ticks         : show interrupt ticks");
               Put_Line("  crash         : deliberately crash the kernel");

         elsif Equals(Command, "mmap", Length) then 
               Banner("Virtual Memory Map", bg=>White, fg=>Black);
               X86.Vm.Dump_Pages; 

         elsif Equals(Command, "kmap", Length) then 
               Banner("Kernel Free Map", bg=>White, fg=>Black);
               Page_Mapper.Print; 

         elsif Equals(Command, "multiboot", Length) then 
               Banner("Multiboot Map", bg=>White, fg=>Black);
               Arch.Scout_Memory(Biggest_Base, Biggest_Size, True);   

         elsif Equals(Command, "ticks", Length) then 
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

         elsif Equals(Command, "uptime", Length) then 
            Put("-> Uptime ");
            Set_Colour(BG=>Light_Green);
            while not X86.Dev.Keyboard.Has_Input loop 
               At_X(12); Put(X86.Dev.RTC.Get_Ticks/2); Put(" seconds");
            end loop;
            Put(LF);

         elsif Equals(Command, "crash", Length) then
            Put("Enter a key: ");
            Int_No := Unsigned_8(Character'Pos(Input.Get_Char));
            Loc := Loc + Unsigned_64((Int_No and 31) * 8);
            Asm("call *%0", Inputs => Unsigned_64'Asm_Input("d", Loc));

         elsif Length = 0 then 
            null;

         else 
            Set_Colour(bg=>Red);
            Put(Command); Put_Line("..?");
         end if;

      end loop;
   end;
   end;

    

end Kernel;