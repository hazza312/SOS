with System;
with Interfaces; use Interfaces;

-- @summary
-- A general purpose, first-fit allocator.
generic
    Min_Allocation:    Positive;
    Base_Address:      System.Address;
    Max_Length:        Natural;
    Num_Elements:      Positive;

package MMap is 
    type Node is private;
    type Node_List is private;

    function Allocate(Size: Positive) return System.Address;
    procedure Free(Base: System.Address; Length: Positive);
    procedure Print;

    
private

    subtype Node_Index is Integer range 0..Num_Elements;

    type Node is record 
        Next    : Node_Index;
        Base    : System.Address;
        Length  : Natural; 
    end record;

    type Node_List is array(Node_Index) of Node;

end MMap;