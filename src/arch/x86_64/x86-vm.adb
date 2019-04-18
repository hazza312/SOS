with System.Machine_Code; use System.Machine_Code;
with Arch; use Arch;
with Common; use Common;
with Console; use Console;
with Error; use Error;
with System.Storage_Elements; use System.Storage_Elements;
with MMap; use MMap;
with X86.Dev.Keyboard;

package body X86.VM is

   type Page_Bit_Array is array(0..PD_POOL_SIZE / TABLE_SIZE) of Boolean with Pack;
   Dir_Pages : Page_Bit_Array;

   -- offsets into the VMA
   Shifts : constant array(Level) of Natural := (12, 21, 30, 39);

   -- used for prettying
   Columns : constant array(Level) of Natural := (61, 42, 19, 0);


----HELPERS --------------------------------------------------------------------

   function Get_Free_Dir_Page return Virtual_Address is 
   begin 
      for I in Dir_Pages'Range loop
         if Dir_Pages(I) = False then 
            Dir_Pages(I) := True;
            return Virtual_Address(PD_POOL_BASE + I * TABLE_SIZE);
         end if;
      end loop;
      return Virtual_Address(0);
   end;


   procedure Free_Dir_Page(VMA: Virtual_Address) is 
   begin
      Dir_Pages(Integer((VMA - PD_POOL_BASE) / TABLE_SIZE)) := False;
   end;


   function Offsets_To_VMA(T: Table_Offsets) return Virtual_Address is
      Result: Unsigned_64 := 0; 
   begin
      for Table_Level in Table_Offsets'Range loop 
         Result := @ or Shift_Left(Unsigned_64(T(Table_Level)) and 511, Shifts(Table_Level));
      end loop;

      -- TODO: sign extension
      return Virtual_Address(Result);
   end Offsets_To_VMA;

   function VMA_To_Offsets(VMA: Virtual_Address) return Table_Offsets is 
      T : Table_Offsets := (0,0,0,0);
   begin 
      for L in Level loop
         T(L) := Entry_Index(Shift_Right(VMA, Shifts(L)) and 511);
      end loop;
      return T;
   end VMA_To_Offsets;

   procedure Flush_TLB is 
      use ASCII;
   begin 
      -- TODO: use invlpg command
      Asm(  "movq %%cr3, %%rax" & ASCII.LF &
            "movq %%rax, %%cr3",
            Clobber => "rax",
            Volatile => True
         );
   end Flush_TLB;




----PAGE MANAGEMENT PROCEDURES ------------------------------------------------- 

   function Map_Page(   PML4:    Physical_Address; 
                        VMA:     Virtual_Address; 
                        PA:      Physical_Address;
                        Size:    Page_Size)  
   return Boolean 
   is
      Offsets: Table_Offsets;
      Parent_Level: Level := (if Size = Page_4K then 1 else 2);
   begin
      Offsets := VMA_To_Offsets(VMA);
      return Create_Mapping(Address(PML4), Offsets, PA, Parent_Level, 4);     
   end;


   function Create_Mapping(   Base:          Address; 
                              Offsets:       Table_Offsets; 
                              PA:            Physical_Address;
                              Parent_Level:  Level;
                              L:             Level) 
   return Boolean 
   is 
      PMLX : Page_Table with Address => System'To_Address(Base);
      Next_Base : Address;
   begin
      -- at lowest PML and page already has a mapping 
      if L = Parent_Level and then PMLX(Offsets(L)).Present then 
         return False;

      -- at lowest PML and page may be mapped
      elsif L = Parent_Level then
         PMLX(Offsets(L)) := (
            Reference => Address_4K_Truncate(Shift_Right(PA, 12)),
            Page_Size => True, Present => True, Writeable => True, 
            others => <>);
         return True;      
      end if;

      -- next lowest PML needs a directory page
      if not PMLX(Offsets(L)).Present then 
         Next_Base := Address(Get_Free_Dir_Page);
         PMLX(Offsets(L)) := (   
            Reference => Address_4K_Truncate(Shift_Right(Address(Next_Base), 12)),
            Page_Size => False, Present => True, Writeable => True, others => <>); 
      end if;

      -- recurse to PML next layer below.
      Next_Base := Address(Shift_Left(Address(PMLX(Offsets(L)).Reference), 12));
      return Create_Mapping(Next_Base, Offsets, PA, Parent_Level, L-1);
   end Create_Mapping;


  
----DEBUG & PRINTING PROCEDURES ------------------------------------------------

   procedure Print_Page(
      Table_Addresses     : Tables;
      Offsets             : Table_Offsets;
      Physical_Address    : Address;
      PTE                 : Page_Table_Entry;
      L                   : Level)
   is
   begin
      -- Set_Colour(FG=>Grey);
      -- Put("V/P");

      Set_Colour(FG=>Light_Red);
      -- At_X(9); 
      Put_Hex(Address(Offsets_To_VMA(Offsets)));
      Put(" -> ");
      Put_Hex(Physical_Address);

      Set_Colour(FG=>Grey);
      At_X(42); Put("BITS");

      Set_Colour;
      At_X(53);      Put_Size(2**Shifts(L));
      if PTE.Dirty          then Put(" D");                   end if;
      if PTE.Accessed       then Put(" A") ;                  end if;
      if PTE.Cache_Disable  then Put(" CD");                  end if;
      if PTE.Writethrough   then Put(" WT");                  end if;
      if PTE.User_Access    then Put(" U");   else Put(" S"); end if;
      if PTE.Writeable      then Put(" W");                   end if;
      if PTE.Present        then Put(" P");                   end if;
      Put(LF);

      Set_Colour(FG=>Grey);
      Put("PML4                        [     ]       ");
      Put("PDP                           [     ]");

      Set_Colour(FG=>White);
      At_X(9);   Put_Hex(Table_Addresses(4));
      At_X(53);  Put_Hex(Table_Addresses(3));
      

      Set_Colour(FG=>Cyan);
      At_X(29);   Put_Hex(Unsigned_64(Offsets(4)));
      At_X(73);   Put_Hex(Unsigned_64(Offsets(3)));
      Put(LF);
      Set_Colour(FG=>Grey);
      Put("PD                          [     ]       PT                            [     ]");

      Set_Colour(FG=>White);
      if L <= 2 then At_X(9);    Put_Hex(Table_Addresses(2)); end if;
      if L <= 1 then At_X(53);   Put_Hex(Table_Addresses(1)); end if;

      Set_Colour(FG=>Cyan);
      if L <= 2 then At_X(9);    At_X(29);   Put_Hex(Unsigned_64(Offsets(2))); end if;
      if L <= 1 then At_X(53);   At_X(73);   Put_Hex(Unsigned_64(Offsets(1))); end if;
      Put(LF);
      Put(LF);
          
    end Print_Page;

    procedure Dump_Rec( Table_Addresses:  in out Tables;
                        Offsets:          in out Table_Offsets;
                        L:                Level)
    is
      PMLX: Page_Table with Address => System'To_Address(Table_Addresses(L));
      Page_Entry: Page_Table_Entry;
      Entry_Ref : Address;
   begin
      -- for every index in this page table
      for I in PMLX'Range loop
         exit when X86.Dev.Keyboard.Has_Input;

         -- Page_Entry refers to the entry at index I
         Page_Entry := PMLX(I);

         -- if there is an entry present
         if Page_Entry.Present then
            Offsets(L) := I;
            Entry_Ref := Address(Page_Entry.Reference * 2**12);

            -- and it's a reference to a physical page, print page          
            if Page_Entry.Page_Size then
               Print_Page(Table_Addresses, Offsets, Entry_Ref, Page_Entry, L);

            -- otherwise, it is a reference to a PT another layer down, recurse.
            else            
               Table_Addresses(L-1) := Entry_Ref;  
               Dump_Rec(Table_Addresses, Offsets, L-1); 
                             
            end if;                
         end if;
      end loop;

      Offsets(L) := 0;           
    end Dump_Rec;

 
   procedure Dump_Pages is 
      PML4_Base : Address := Null_Address;
      Table_Addresses: Tables;
      Offsets: Table_Offsets := (0,0,0,0);
      use ASCII;
   begin 
      Asm(  "movq    %%cr3, %%rax" & ASCII.LF &
            "movq    %%rax, %0", 
            Outputs     => Address'Asm_Output("=g", PML4_Base), 
            Clobber     => "rax",
            Volatile    => True);

      Table_Addresses := (0,0,0,PML4_Base);         
      Dump_Rec(Table_Addresses, Offsets, 4);
      Put(Console.LF);  
   end Dump_Pages;






end X86.VM;