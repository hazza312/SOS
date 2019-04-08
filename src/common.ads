with Interfaces; use Interfaces;

package Common is

   type  Address is new Unsigned_64;
   type  Physical_Address is new Address;
   type  Virtual_Address is new Address;
   
   NULL_ADDRESS : constant Address := 0;
   PAGE_SIZE : constant := 4_096;

end Common;