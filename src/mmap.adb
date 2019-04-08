with Console; use Console;
with System.Storage_Elements; use System.Storage_Elements;
with Common; use Common;

package body MMap is 

Head: Node_Index := 0;
Tail: Node_Index := Num_Elements;

Free_Nodes: Node_List := (
    0            =>   (1,     Null_Address,    0           ),
    1            =>   (Tail,  Base_Address,    Max_Length  ),
    others       =>   (0,     Null_Address,    0           )
);

function Get_Free_Node return Node_Index is 
begin 
    for I in 1..Num_Elements-1 loop 
        if Free_Nodes(I).Length = 0 then 
            return I;
        end if;
    end loop;
    return 0;
end Get_Free_Node;


function Allocate(Size: Unsigned_64) return Address is 
    Prev:   Node_Index := Head;
    Match:  Node_Index := Free_Nodes(Head).Next;
    Addr:   Address := NULL_ADDRESS;
begin 
    while Match /= Tail and then Free_Nodes(Match).Length < Size loop 
        Prev := Match;
        Match := Free_Nodes(Match).Next;
    end loop;

    if Match = Tail then 
        null;

    elsif Free_Nodes(Match).Length = Size then 
        Free_Nodes(Prev).Next := Free_Nodes(Match).Next;
        Free_Nodes(Match).Length := 0;     
        Addr := Free_Nodes(Match).Base;
    
    elsif Free_Nodes(Match).Length > Size then
        Addr := Free_Nodes(Match).Base;
        Free_Nodes(Match).Base    := Free_Nodes(Match).Base + Address(Size);
        Free_Nodes(Match).Length  := Free_Nodes(Match).Length - Size;      
    end if;

    return Addr;
end Allocate;



procedure Free(Base: Address; Length: Unsigned_64) is 
    Prev:  Node_Index := Head;
    Curr:  Node_Index := Head;
    Free:  Node_Index := 0;

begin
    while Curr /= Tail and then Base >= Free_Nodes(Curr).Base loop      
        Prev := Curr;
        Curr := Free_Nodes(Curr).Next;
    end loop;

    if Free_Nodes(Prev).Base + Address(Free_Nodes(Prev).Length) = Base then 
        Free_Nodes(Prev).Length := @ + Length;
    elsif Base + Address(Length) = Free_Nodes(Curr).Base then 
        Free_Nodes(Curr).Length := @ + Length;
        Free_Nodes(Curr).Base   := Free_Nodes(Curr).Base - Address(Length);
    else 
        Free := Get_Free_Node; 
        Free_Nodes(Prev).Next   := Free;
        Free_Nodes(Free)        := (Curr, Base, Length);
    end if;

    while Curr /= Tail 
    and then Free_Nodes(Prev).Base + Address(Free_Nodes(Prev).Length) 
             = Free_Nodes(Curr).Base 
    loop 
        Free_Nodes(Prev).Length := @ + Free_Nodes(Curr).Length;
        Free_Nodes(Prev).Next := Free_Nodes(Curr).Next;
        Free_Nodes(Curr).Length := 0; -- free the node
        Curr := Free_Nodes(Curr).Next;
    end loop;  
    
end Free;


procedure Print is 
    I : Node_Index := Free_Nodes(Head).Next;
begin 
    Set_Colour(fg=>Grey);
    At_X(0);   Put("Address Base");
    At_X(20);  Put("Size");
    At_X(40);  Put("Size");
    At_X(60);  Put("Node");
    At_X(70);  Put("Next Node");
    Put(LF);

    Set_Colour;
    while I /= Tail loop       
        At_X(0);   Put_Hex(Free_Nodes(I).Base);
        At_X(20);  Put_Size(Free_Nodes(I).Length);
        At_X(40);  Put_Hex(Free_Nodes(I).Length);
        At_X(60);  Put(I);
        I := Free_Nodes(I).Next;
        At_X(70);  if I = Tail then Put("END"); else Put(I); end if;
        Put(LF);
    end loop;
    Put(LF);
end;

end MMap;