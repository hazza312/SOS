with System;
with Interfaces; use Interfaces;
with Common; use Common;

-- @summary
-- A general purpose, first-fit allocator.
generic
    Min_Allocation:    Unsigned_64;
    Base_Address:      Address;
    Max_Length:        Unsigned_64;
    Num_Elements:      Unsigned_64;

package MMap is 
    type Node is private;
    type Node_List is private;

    function Allocate(Size: Unsigned_64) return Address;
    procedure Free(Base: Address; Length: Unsigned_64);
    procedure Print;

    
private

    subtype Node_Index is Unsigned_64 range 0..Num_Elements;

    type Node is record 
        Next    : Node_Index;
        Base    : Address;
        Length  : Unsigned_64; 
    end record;

    type Node_List is array(Node_Index) of Node;

end MMap;