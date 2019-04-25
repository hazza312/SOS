with System;
with Interfaces; use Interfaces;
with Common; use Common;

-- @summary
-- A general purpose, first-fit allocator.

package MMap is

   MAX_ALLOCATIONS : constant Integer := 4_000;

   type Node is private;
   type Node_List is private;

   function Allocate(Size: Unsigned_64) return Address;
   procedure Free(Base: Address; Length: Unsigned_64);
   procedure Initialise(
      Base: Address;
      Length : Unsigned_64;
      Unit: Unsigned_64  
   );
   procedure Print;

   function Get_Base return Address;
   function Get_Length return Unsigned_64;

    
private

   subtype Node_Index is Integer range 0..MAX_ALLOCATIONS;

   type Node is record 
      Next    : Node_Index;
      Base    : Address;
      Length  : Unsigned_64; 
   end record;

   type Node_List is array(Node_Index) of Node;

end MMap;