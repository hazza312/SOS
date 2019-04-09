with System.Machine_Code; use System.Machine_Code;
with Arch; use Arch;
with Common; use Common;
with Console; use Console;
with Error; use Error;
with System.Storage_Elements; use System.Storage_Elements;

package body X86.VM is 

   -- offsets into the VMA
   Shifts : constant array(Level) of Natural := (12, 21, 30, 39);

   -- used for pretty printing
   Columns : constant array(Level) of Natural := (48, 36, 24, 12);

----PAGE MANAGEMENT PROCEDURES ------------------------------------------------- 

   function Map_Page(PML4, Base: Address; Size: Page_Size) return Virtual_Address is
      Destination_Level: Level := (if Size = Page_4K then 1 else 2); 
      X : Boolean;
   begin
      X := Insert_Page(PML4, Base, Natural(4-Destination_Level));
      return Virtual_Address(0);
   end;


   function Insert_Directory(PMLX: in out Page_Table) return Boolean is 
   begin
      -- allocate a 4K page from the kernel page allocator
      -- directory page will need to be mapped as a P in VM:(
      -- insert this as an entry into PMLX.
      null;
      return True;
   end Insert_Directory;



   function Insert_Page(Table_Base, Base_Address: Address; Remaining: Natural) return Boolean is 
      PMLX: Page_Table with Address => System'To_Address(Table_Base);
      Next_Table_Base : Address;
      I : Entry_Index := 0;
   begin
      if Remaining = 0 then
         while PMLX(I).Present loop
            I := I + 1;
         end loop;

         PMLX(I) := (
            Reference => Address_4K_Truncate(Shift_Right(Base_Address, 12)),
            Page_Size => True, Present => True, others => <>);

         return True;

      else
         -- can we add to an existing subdirectory?
         for J in PMLX'Range loop
         -- assume P marks PT as valid entry. 
            if not PMLX(J).Page_Size 
            and then PMLX(J).Present 
            and then PMLX(J).Used_Entries < 511 then
               Next_Table_Base :=  Address(Shift_Left(Unsigned_64(PMLX(J).Reference), 12));
               if Insert_Page(Next_Table_Base, Base_Address, Remaining-1) then
                  PMLX(J).Used_Entries := @ + 1;
                  return True;
               end if; 
            end if;
         end loop;

         -- if not, maybe we need to make a new directory before attempting to insert again
         if (Insert_Directory(PMLX)) then

            null;
         end if;

         -- if that failed, nothing more we can do. Go up a dir and try from there
         Panic("More complicated scenario");
         return False;
      end if;
   end Insert_Page;








----DEBUG & PRINTING PROCEDURES ------------------------------------------------

   procedure Print_Page(
      Virtual_Address     : Address;
      Physical_Address    : Address;
      Entry_Level         : Level)
   is
      Current_Offset : Entry_Index;
   begin
      Put(Console.LF);
      At_X(0);    Put_Hex(Virtual_Address);

      -- get the table offsets back from the virtual address.
      for I in Entry_Level..4 loop
         Current_Offset := Entry_Index(Shift_Right(Virtual_Address, Shifts(I)) and (2**9 -1));
         At_X(Columns(I)); Put_Hex(Unsigned_64(Current_Offset));
      end loop;
 
      At_X(60); Put_Size(2 ** Shifts(Entry_Level));
      At_X(64); Put_Hex(Physical_Address);  
          
    end Print_Page;

    procedure Dump_Rec(Table_Base, Virtual_Address: Address; L: Level)
    is
      PMLX: Page_Table with Address => System'To_Address(Table_Base);
      Page_Entry: Page_Table_Entry;
      Next_Base, Physical_Address, Next_Virtual_Address: Address;
   begin
      Set_Colour(FG=>Cyan);
      -- since console doesnt pad, cheat to make sure completely overwritten
      At_X(Columns(L)); Put("            ");
      At_X(Columns(L)); Put_Hex(Table_Base);
      Set_Colour;

      -- for every index in this page table
      for I in PMLX'Range loop
         -- Page_Entry refers to the entry at index I
         Page_Entry := PMLX(I);

         -- if there is an entry present
         if Page_Entry.Present then
            Next_Base := Address(Page_Entry.Reference * 2**12);
            Next_Virtual_Address := Virtual_Address or Shift_Left(Address(I), Shifts(L));

            -- and it's a reference to a physical page, print page          
            if Page_Entry.Page_Size then
               Physical_Address := 
                  Address(Shift_Left(Address(Page_Entry.Reference), 12));
               Print_Page(Next_Virtual_Address, Physical_Address, L);

            -- otherwise, it is a reference to a PT another layer down, recurse.
            else              
               Dump_Rec(Next_Base, Next_Virtual_Address, L-1);              
            end if;                
         end if;
        end loop;    
    end Dump_Rec;

 
   procedure Dump_Pages is 
      PML4_Base : Address := Null_Address;
      use ASCII;
   begin 
      Asm("movq    %%cr3, %%rax" & ASCII.LF &
         "movq    %%rax, %0", 
         Outputs => Address'Asm_Output("=g", PML4_Base), 
         Clobber => "rax",
         Volatile => True);
  

      Set_Colour(FG=>Grey);
    
      At_X(0);            Put("Virtual");
      At_X(Columns(1));   Put("PTE");
      At_X(Columns(2));   Put("PDE");
      At_X(Columns(3));   Put("PDPE");
      At_X(Columns(4));   Put("PML4");
      At_X(60);           Put("S");
      At_X(64);           Put("Physical");
      Put(Console.LF);
        
      Dump_Rec(PML4_Base, 0, 4);
      Put(Console.LF);  
   end Dump_Pages;






end X86.VM;