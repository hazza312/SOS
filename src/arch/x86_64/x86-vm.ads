with Interfaces; use Interfaces;
with Arch; use Arch;
with Common; use Common;
with Interfaces.C;

package X86.Vm 
   with SPARK_Mode, Elaborate_Body
is 
   TABLE_SIZE     : constant := 4_096;

---PAGE TABLE ENTRY MASKS------------------------------------------------------- 

   PRESENT        : constant := 2#1#;
   WRITEABLE      : constant := 2#10#;
   USER           : constant := 2#100#;
   WRITETHROUGH   : constant := 2#1000#;
   CACHE_DISABLE  : constant := 2#1_0000#;
   ACCESSED       : constant := 2#10_0000#;
   DIRTY          : constant := 2#100_0000#;
   IS_PAGE        : constant := 2#1000_0000#;
   GLOBAL         : constant := 2#1_0000_0000#;

   ENTRY_COUNT    : constant := (2**63 -1) - (2**52 -1);
   REFERENCE      : constant := (2**52 -1) - (2**12 -1);

---PUBLIC TYPES-----------------------------------------------------------------

   type Page_Size is (Page_4K, Page_2M);
   type Table_Level is range 1..4;
   type Flags_Type is new Unsigned_64
      with Predicate => (Flags_Type and REFERENCE) = 0;
   type Directory_Ref is range 0..(X86.PD_POOL_SIZE / TABLE_SIZE) -1;


---PUBLIC SUBPROGRAMS-----------------------------------------------------------

   -- while it would be handy for this subprogram to return a boolean, this
   -- would not be possible in SPARK, as functions must be pure, but this 
   -- might modify mutable state (i.e. we might have to request a new page dir).
   procedure Create_Mapping(  VMA:           Virtual_Address;
                              PA:            Physical_Address;
                              Flags:         Flags_Type;
                              Size:          Page_Size;
                              Success:       out Boolean)
   with 
      SPARK_Mode,
      Pre =>   ((PA and not REFERENCE) = 0) and then
               ((Flags and IS_PAGE) /= 0);

   procedure Free_Mapping( VMA:      Virtual_Address;
                           Size:     Page_Size;
                           PA:       out Physical_Address;
                           Success:  out Boolean);
   
   procedure Dump_Pages(PML4: Physical_Address);

   procedure Initialise;


---C Compatability Layer (for test cases)---------------------------------------
   
   -- This combines allocation and Virtual Mapping, which is not something we 
   -- neccessarily always want to do. This function does both for the purposes
   -- of the test cases (but in reality, shouldn't be used as it might go 
   -- against some of the other conventions in the kernel).
   function page_alloc(Num_Pages : Interfaces.C.size_t) return Address 
      with Export, Convention => C, External_Name => "page_alloc";

   procedure page_free(VMA: Virtual_Address)
      with Export, Convention => C, External_Name => "page_free";
  


private

---related types----------------------------------------------------------------
   type Table_Entry is new Unsigned_64;
   type Table_Index is range 0..511; 
   type Table is array(Table_Index) of Table_Entry;

   type Table_Address is new Virtual_Address range 
      X86.PD_POOL_Base..(X86.PD_POOL_Base + X86.PD_POOL_SIZE * Table'Size) -1; 

   type Table_Offsets is array(Table_Level) of Table_Index;
   type Tables is array(Table_Level) of Address;


---globals----------------------------------------------------------------------
   type Page_Bit_Array is array(0..(PD_POOL_SIZE / TABLE_SIZE)-1) of Boolean 
   with Pack;

   Dir_Pages : Page_Bit_Array;

---helpers----------------------------------------------------------------------

   -- return true if Table empty.
   --function Decrement_Entry_Count(T: in out Table; I: Table_Index) return Boolean with Inline;

   -- return True if Table full
  --function Increment_Entry_Count(T: in out Table; I: Table_Index) return Boolean with Inline;

   function Has_Free_Dir_Page return Boolean
   with SPARK_Mode,
   Global => (Input => Dir_Pages),
   Post  => Has_Free_Dir_Page'Result = (for some I of Dir_Pages => I = False);


   procedure Get_Free_Dir_Page(Page: out Virtual_Address) 
   with SPARK_Mode,
   Global   => (In_Out => Dir_Pages),
   Pre      => Has_Free_Dir_Page,

   Contract_Cases => (
      Has_Free_Dir_Page =>  ((Page mod 4096) = 0),
      others            =>  Page = 0
   );

   function Make_Directory_Entry(A: Virtual_Address; F: Flags_Type) 
   return Table_Entry 
   with  
      Inline,
      Pre   => ((A and (not REFERENCE)) = 0) and then
               ((F and IS_PAGE) = 0),
      Post  => (Make_Directory_Entry'Result = Table_Entry(A));


   function Make_Frame_Entry(PA: Physical_Address; F: Flags_Type) 
   return Table_Entry
   with  
      Inline,
      Pre   => ((PA and not REFERENCE) = 0) and then
               ((F and IS_PAGE) /= 0);  


   function Get_Directory_Address(T: in Table_Entry) return Table_Address
   with  
      Inline,
      Pre   => (T and IS_PAGE) = 0;

   function Get_Directory_Ref(T: in Table_Entry) return Directory_Ref
   with  
      Inline,
      Pre   => (T and IS_PAGE) = 0;

   function Get_Frame_Address(T: in Table_Entry) return Physical_Address
   with  
      Inline,
      Pre   => (T and IS_PAGE) /= 0;

end X86.Vm;