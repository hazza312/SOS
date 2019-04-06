with Interfaces; use Interfaces;
with Arch; use Arch;

package Kernel is
   
   type  Address is new Unsigned_64;
   type  Physical_Address is new Address;
   type  Virtual_Address is new Address;
   
   PAGE_SIZE : constant := 4_096;
   Holes:      Arch.Holes_List;

   procedure Kernel;

end Kernel;
