with Interfaces; use Interfaces;
with System;
with Consoleb;
with Common; use Common;

-- @summary
-- Common interface for subprograms across different architectures.

-- @description
-- These subprograms are architecture-specific and should be implemented in the
-- code base for the relevant architecture. 
package Arch is

    MAX_ADDRESS_BITS : constant := 48;
    PAGE_SIZE : constant := 4_096;
    type IO_Port is new Unsigned_16;

    procedure Scout_Memory(Base: in out Address; Size: in out Unsigned_64; Debug: Boolean);  
    procedure Initialise_Interrupts;  

    function IO_Inb(Port: IO_Port) return Unsigned_8 with Inline_Always;
    procedure IO_Outb(Port: IO_Port; Data: Unsigned_8) with Inline_Always;
    function CR3_Address return Physical_Address with Inline_Always;

    procedure Reload_CR3(Address: Physical_Address);

   -- package Console is
        -- procedure X(C : Natural);
        -- procedure Put(C : Character);
        -- procedure Put(S: String);
        -- procedure Put(N : Unsigned_64);
        -- procedure Put_Int(N : Integer);
        -- procedure Put_Hex(N: Positive);
        -- procedure Put_Size(s: Unsigned_64);
        -- procedure Put_Line(S: String);    
        -- procedure Banner(S : String); 
   -- end Console;



end Arch;