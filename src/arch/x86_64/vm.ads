with Interfaces; use Interfaces;

package Vm is 

    procedure b;

private
    type Table_Ref is new Unsigned_64;

    type PML4_Entry is record
        No_Execute: Boolean;
        PDP_Base: Table_Ref;
        Page_Attribute_Table: Boolean;
        Available: Integer;
        Global: Boolean;
        Page_Size: Boolean;
        Dirty: Boolean;
        Accessed: Boolean;
        Cache_Disable: Boolean;
        Writethrough: Boolean;
        User_Access: Boolean;
        Writeable: Boolean;
        Present: Boolean;
    end record
        with Dynamic_Predicate => 
            not (
                -- the following combinations of bits are invalid.
                (Dirty xor Page_Size) or 
                (Global xor Page_Size) or 
                (Page_Attribute_Table xor Page_Attribute_Table)
            );

    



    -- for PML4_Entry use record 

    -- end record;

    
end Vm;