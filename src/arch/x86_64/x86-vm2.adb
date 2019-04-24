with System.Machine_Code; use System.Machine_Code;
with Arch; use Arch;
with Common; use Common;
with Console; use Console;
with Error; use Error;
with System.Storage_Elements; use System.Storage_Elements;
with MMap; use MMap;
with X86.Dev.Keyboard;

package body X86.VM2 is

   Directories : array(Directory_Ref) of Table 
      with Address => System'To_Address(X86.PD_POOL_BASE);

   -- offsets into the VMA
   Shifts : constant array(Table_Level) of Natural := (12, 21, 30, 39);


----INLINE HELPERS -------------------------------------------------------------

   function Make_Directory_Entry(A: Virtual_Address; F: Flags_Type) 
   return Table_Entry 
   is (Table_Entry(Unsigned_64(A) or Unsigned_64(F)));


   function Make_Frame_Entry(PA: Physical_Address; F: Flags_Type) 
   return Table_Entry 
   is (Table_Entry(Unsigned_64(PA) or Unsigned_64(F)));


   function Get_Directory_Address(T: in Table_Entry) return Table_Address
   is (Table_Address(T and REFERENCE));


   function Get_Frame_Address(T: in Table_Entry) return Physical_Address
   is (Physical_Address(T and REFERENCE));


---PAGE DIRECTORY MANAGEMENT----------------------------------------------------

   procedure Get_Free_Dir_Page(Page: out Virtual_Address)  
      with SPARK_MODE
   is
   begin
      for I in 0..Dir_Pages'Last loop
         if Dir_Pages(I) = False then 
            Dir_Pages(I) := True;
            Page := Virtual_Address(PD_POOL_BASE + (I * TABLE_SIZE));
            return;
         end if;
         pragma Loop_Invariant (for all J in 0..I => Dir_Pages(J));

      end loop;
      Page := 0;
   end;


   function Get_Directory_Ref(T: in Table_Entry) return Directory_Ref
   is (Directory_Ref(((T and REFERENCE) - X86.PD_POOL_BASE) / TABLE_SIZE));
   

   function Has_Free_Dir_Page return Boolean
   is (for some Page of Dir_Pages => (not Page)) with SPARK_Mode ;


   procedure Free_Dir_Page(VMA: Virtual_Address) is 
   begin
      Dir_Pages(Integer((VMA - PD_POOL_BASE) / Table'Size)) := False;
   end;

---CONVERSIONS TO AND FROM OFFSETS & VMAs---------------------------------------
   function Offsets_To_VMA(T: Table_Offsets) return Virtual_Address is
      Result: Unsigned_64 := 0; 
   begin
      for L in Table_Offsets'Range loop 
         Result := @ or Shift_Left(Unsigned_64(T(L)) and 511, Shifts(L));
      end loop;

      -- TODO: sign extension
      return Virtual_Address(Result);
   end Offsets_To_VMA;

   function VMA_To_Offsets(VMA: Virtual_Address) return Table_Offsets is 
      T : Table_Offsets := (0,0,0,0);
   begin 
      for L in Table_Level loop
         T(L) := Table_Index(Shift_Right(VMA, Shifts(L)) and 511);
      end loop;
      return T;
   end VMA_To_Offsets;


   -- TODO: move into arch.
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

   procedure Create_Mapping(  PML4:          Physical_Address;
                              VMA:           Virtual_Address;
                              PA:            Physical_Address;
                              Flags:         Flags_Type;
                              Size:          Page_Size;
                              Success:       out Boolean) 
   with 
      SPARK_Mode
   is
      Current_Table  : Directory_Ref    := 0;
      Offsets        : Table_Offsets    := VMA_To_Offsets(VMA);
      Dir_Page       : Virtual_Address;
      PTE            : Table_Entry;
      Target_Level   : Table_Level      := (if Size = Page_4K then 1 else 2);
   begin
      for L in reverse Table_Level'First..Target_Level loop
         PTE := Directories(Current_Table)(Offsets(L));
         if (PTE and IS_PAGE) /= 0 then 
            Success := False; return;

         elsif (PTE and PRESENT) = 0 then
            if Has_Free_Dir_Page then
               Get_Free_Dir_Page(Dir_Page);
               Directories(Current_Table)(Offsets(L)) 
                  := Make_Directory_Entry(Dir_Page, PRESENT or WRITEABLE);
            else 
               Success := False; return;
            end if;
 
         end if;
            Current_Table 
               := Get_Directory_Ref(Directories(Current_Table)(Offsets(L)));
      end loop;
      
      PTE := Directories(Current_Table)(Offsets(Target_Level));
      if (PTE and PRESENT) = 0 then
         Directories(Current_Table)(Offsets(Target_Level)) 
            := Make_Frame_Entry(PA, Flags);
         Success := True;
      else 
         Success := False;
      end if;
   end;


   procedure Initialise is
      Offsets: Table_Offsets := VMA_To_Offsets(PD_POOL_BASE); 
   begin 
      Directories(0)(Offsets(4)) := 
         Make_Directory_Entry(PD_POOL_BASE + TABLE_SIZE, PRESENT);

      Directories(1)(Offsets(3)) := 
         Make_Directory_Entry(PD_POOL_BASE + 2*TABLE_SIZE, PRESENT);

      Directories(2)(Offsets(2)) := 
         Make_Frame_Entry(PD_POOL_BASE, IS_PAGE or PRESENT or WRITEABLE);

      Dir_Pages(0) := True;
      Dir_Pages(1) := True;
      Dir_Pages(2) := True;   
   end Initialise;


----DEBUG & PRINTING PROCEDURES ------------------------------------------------
   -- TODO: move to different package?
   procedure Print_Page(
      Table_Addresses     : Tables;
      Offsets             : Table_Offsets;
      Physical_Address    : Address;
      PTE                 : Table_Entry;
      L                   : Table_Level)
   is
      Cols : constant array(1..6) of Integer := (0,6,32,40,46,72);
      Names: constant array(Table_Level) of String(1..4) 
         := ("PT  ", "PD  ", "PDP ", "PML4");
      Col_Shift : Integer := 0;
   begin
      -- Row1: Virtual -> Physical Mapping
      Set_Colour(BG => Magenta);
      Put_Hex(Address(Offsets_To_VMA(Offsets)));
         Put(" -> ");   Put_Hex(Physical_Address);

      -- Row1: Size and Bits
      Set_Colour(FG=>Grey);
      At_X(Cols(4)); Put("BITS");

      Set_Colour;
      At_X(Cols(5));      Put_Size(2**Shifts(L));
      if (PTE and DIRTY)         /= 0 then Put(" D");                   end if;
      if (PTE and ACCESSED)      /= 0 then Put(" A") ;                  end if;
      if (PTE and CACHE_DISABLE) /= 0 then Put(" CD");                  end if;
      if (PTE and WRITETHROUGH)  /= 0 then Put(" WT");                  end if;
      if (PTE and USER)          /= 0 then Put(" U");   else Put(" S"); end if;
      if (PTE and WRITEABLE)     /= 0 then Put(" W");                   end if;
      if (PTE and PRESENT)       /= 0 then Put(" P");                   end if;
      Put(LF);

      -- Rows 2&3: Table bases and offsets
      Set_Colour(FG=>Grey);

      for I in reverse Table_Level'Range loop
         Col_Shift := (Integer(I) mod 2) * 3;

         if L <= I then
            Set_Colour(FG=>Grey);
            At_X(Cols(1 + Col_Shift));     Put(Names(I));
            At_X(Cols(3 + Col_Shift));     Put("[     ]");

            Set_Colour(FG=>White);
            At_X(Cols(2 + Col_Shift));     Put_Hex(Table_Addresses(I));

            Set_Colour(FG=>Cyan);
            At_X(Cols(3 + Col_Shift) + 1); Put_Hex(Unsigned_64(Offsets(I)));
         end if;

         if Col_Shift /= 0 then Put(LF); end if;
      end loop;

      Put(LF);          
    end Print_Page;

    procedure Dump_Rec( Table_Addresses:  in out Tables;
                        Offsets:          in out Table_Offsets;
                        L:                Table_Level)
    is
      PMLX: Table with Address => System'To_Address(Table_Addresses(L));
      Page_Entry: Table_Entry;
      Entry_Ref : Address;
   begin
      -- for every index in this page table
      for I in PMLX'Range loop
         exit when X86.Dev.Keyboard.Has_Input;

         -- Page_Entry refers to the entry at index I
         Page_Entry := PMLX(I);

         -- if there is an entry present
         if (Page_Entry and PRESENT) /= 0 then
            Offsets(L) := I;
            Entry_Ref := Address(Get_Frame_Address(Page_Entry));

            -- and it's a reference to a physical page, print page          
            if (Page_Entry and IS_PAGE) /= 0 then
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

 
   procedure Dump_Pages(PML4: Physical_Address) is 
      Table_Addresses: Tables;
      Offsets: Table_Offsets := (0,0,0,0);
      use ASCII;
   begin 
      Table_Addresses := (0,0,0, Address(PML4));         
      Dump_Rec(Table_Addresses, Offsets, 4);
      Put(Console.LF);  
   end Dump_Pages;



   -- procedure Dump_Pages_New_And_Improved(PML4: Physical_Address)
   -- is 
   --    L           : Table_Level                          := 4;
   --    Offsets     : Table_Offsets                        := (0,0,0,0);
   --    Dirs        : array(Table_Level) of Directory_Ref  := (0,0,0,0);  
   -- begin 
   --    loop 


   --       if L - 1 then

   --       end if;
   --    end loop;
   -- end Dump_Pages_New_And_Improved;


begin 

   Initialise;

end X86.VM2;