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
--    Put(LF);
--    Banner   ("System Map", bg=>White, fg=>Black );

   -- fill holes with free holes, ordered largest to smallest
   Arch.Scout_Memory(Biggest_Base, Biggest_Size, False);  
   if Biggest_Size = 0 then Panic("No Free Memory?"); end if;

   Put("-> Using largest hole ("); 
      Put_Size(Biggest_Size); 
      Put(") RAM @"); 
      Put_Hex(Biggest_Base);
      Put(LF);
   Put_Line("-> Initialising kernel page mapper");
--    Put(LF);
    
   declare 
      package Page_Mapper is new MMap(
         Min_Allocation  => PAGE_SIZE,
         Base_Address    => Biggest_Base,
         Max_Length      => Biggest_Size,
         Num_Elements    => 15
      );

      Allocs : array(0..3) of Address;

   begin
    --   Banner   ("Kernel Map", bg=>White, fg=>Black);
      Allocs(0) := Page_Mapper.Allocate(PAGE_SIZE);
      Allocs(1) := Page_Mapper.Allocate(PAGE_SIZE);
      Allocs(2) := Page_Mapper.Allocate(PAGE_SIZE);
      Page_Mapper.Free(Allocs(0), PAGE_SIZE);      
    --   Page_Mapper.Print;


      Put_Line("-> (re)enabling interrupts");
      Arch.Initialise_Interrupts;
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
                Put_Line("[mem multiboot] show multiboot memory info");
                Put_Line("[mem kmap]      show kernel free list");
                Put_Line("[uptime]        display system uptime");
                Put_Line("[interrupts]    show interrupt mapping");
                Put_Line("[ticks]         show interrupt ticks");
                Put_Line("[crash]         deliberately crash the kernel");

            elsif Equals(Command, "mem kmap", Length) then 
                Banner("Kernel Map", bg=>White, fg=>Black);
                Page_Mapper.Print; 

            elsif Equals(Command, "mem multiboot", Length) then 
                Banner("Multiboot Map", bg=>White, fg=>Black);
                Arch.Scout_Memory(Biggest_Base, Biggest_Size, True);   

            elsif Equals(Command, "ticks", Length) then 
                Banner("Interrupt Ticks", bg=>White, fg=>Black);
                Put("PIT 8253 "); At_X(20); Put(X86.Dev.PIT_8253.Get_Ticks); Put(LF);
                Put("Keyboard "); At_X(20); Put(X86.Dev.Keyboard.Get_Ticks); Put(LF);
                Put("RTC      "); At_X(20); Put(X86.Dev.RTC.Get_Ticks); Put(LF);

            elsif Equals(Command, "uptime", Length) then 
                Put("Uptime = ");
                Set_Colour(BG=>Light_Magenta);
                Put(X86.Dev.RTC.Get_Ticks/2); Put_Line(" seconds");

            elsif Equals(Command, "crash", Length) then
                Put("Enter a key: ");
                Int_No := Unsigned_8(Character'Pos(Input.Get_Char));
                Loc := Loc + Unsigned_64((Int_No and 63) * 8);
                Asm("call %0", Inputs => Unsigned_64'Asm_Input("d", Loc));

                Banner("Interrupt Ticks", bg=>White, fg=>Black);
                Put("PIT 8253 "); At_X(20); Put(X86.Dev.PIT_8253.Get_Ticks); Put(LF);
                Put("Keyboard "); At_X(20); Put(X86.Dev.Keyboard.Get_Ticks); Put(LF);
                Put("RTC      "); At_X(20); Put(X86.Dev.RTC.Get_Ticks); Put(LF);
                Put(LF);

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