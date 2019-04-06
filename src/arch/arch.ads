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
    type IO_Port is new Unsigned_16;

    procedure Scout_Memory(Holes: in out Holes_List);  
    procedure Initialise_Interrupts;  

    function IO_Inb(Port: IO_Port) return Unsigned_8 with Inline;
    procedure IO_Outb(Port: IO_Port; Data: Unsigned_8) with Inline;


end Arch;