with Interfaces; use Interfaces;
with System;

package Arch is

    PAGE_SIZE : constant := 4_096;

    type Free_Hole is record 
        Base: System.Address;
        Length: Integer;
    end record;
    type Holes_List is array(0..7) of Free_Hole;


    procedure Scout_Memory(Holes: in out Holes_List);    

end Arch;