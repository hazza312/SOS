with System.Machine_Code; use System.Machine_Code;
with Arch; use Arch;
with Common; use Common;
with Console; use Console;

package body X86.VM is 

    -- offsets into the VMA
    Shifts : constant array(Level) of Natural := (12, 21, 30, 39);

    -- used for pretty printing
    Columns : constant array(Level) of Natural := (48, 36, 24, 12);

----PAGE MANAGEMENT PROCEDURES ------------------------------------------------- 










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
        for I in reverse Entry_Level..4 loop
            Current_Offset := Entry_Index(Shift_Right(Virtual_Address, Shifts(I))) and Entry_Index(2**9 -1);
            At_X(Columns(I)); Put_Hex(Unsigned_64(Current_Offset));
        end loop;
 
        At_X(60); Put_Size(2 ** Shifts(Entry_Level));
        At_X(64); Put_Hex(Physical_Address);  
        Put(LF);    
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

                -- and it's a reference to a physical page, print page          
                if Page_Entry.Page_Size then
                    Physical_Address := 
                        Address(Address(Page_Entry.Reference) * Address(Shifts(L)));
                    Print_Page(Virtual_Address, Physical_Address, L);

                -- otherwise, it is a reference to a PT another layer down, recurse.
                else
                    Next_Base := Address(Page_Entry.Reference * 2**12);
                    Next_Virtual_Address := Virtual_Address or Shift_Left(Address(I), Shifts(L));
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
            Clobber => "rax");
  

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
    end Dump_Pages;






end X86.VM;