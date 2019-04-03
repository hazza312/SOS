with Interfaces; use Interfaces;

package Multiboot is

    Boot_Info: Unsigned_32;
    pragma Import(C, Boot_Info, "bootinfo");

    type Memory_Type is (Free_Ram, ACPI, Hibernation, Defective_Ram);
    for Memory_Type use (Free_Ram => 1, ACPI => 3, Hibernation => 4, Defective_Ram => 5);
    for Memory_Type'Size use 32;

    type Memory_Entry is record 
      Base_Address: Unsigned_64;
      Length:       Unsigned_64;
      Availability: Memory_Type;
      Reserved:     Unsigned_32;
   end record; 
   for Memory_Entry'Size use 24*8;
    
    type Memory_Entries is array(Natural range <>) of Memory_Entry;


   type Base_Tag is record
      Tag_Type:     Unsigned_32;
      Tag_Size:     Unsigned_32;
   end record;
   for Base_Tag'Size use 64;

end Multiboot;