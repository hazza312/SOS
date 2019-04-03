with Interfaces; use Interfaces;
with System;

-- @summary
-- Common interface for subprograms across different architectures.

-- @description
-- These subprograms are architecture-specific and should be implemented in the
-- code base for the relevant architecture. 
package Arch is

    PAGE_SIZE : constant := 4_096;

    type Free_Hole is record 
        Base: System.Address;
        Length: Integer;
    end record;
    type Holes_List is array(0..7) of Free_Hole;


    procedure Scout_Memory(Holes: in out Holes_List);    

end Arch;