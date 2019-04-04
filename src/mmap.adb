with Console; use Console;
with System.Storage_Elements; use System.Storage_Elements;

package body MMap is 

Head: Node_Index := 0;
Tail: Node_Index := Num_Elements;

Free_Nodes: Node_List := (
    0            =>   (1,     System.Null_Address,    0           ),
    1            =>   (Tail,  Base_Address,           Max_Length  ),
    others =>   (0,     System.Null_Address,    0           )
);

function Get_Free_Node return Natural is 
begin 
    for I in 1..Num_Elements-1 loop 
        if Free_Nodes(I).Length = 0 then 
            return I;
        end if;
    end loop;
    return 0;
end Get_Free_Node;


function Allocate(Size: Positive) return System.Address is 
    Prev:   Node_Index := Head;
    Match:  Node_Index := Free_Nodes(Head).Next;
    Addr:   System.Address := System.Null_Address;
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
        Free_Nodes(Match).Base    := Free_Nodes(Match).Base + Storage_Offset(Size);
        Free_Nodes(Match).Length  := Free_Nodes(Match).Length - Size;      
    end if;

    return Addr;
end Allocate;



procedure Free(Base: System.Address; Length: Positive) is 
    Prev:       Node_Index := Head;
    Curr:       Node_Index := Head;
    Free:       Node_Index := 0;
    -- Limit: System.Address := 
begin
    while Curr /= Tail and then  To_Integer(Base) >= To_Integer(Free_Nodes(Curr).Base) loop      
        Prev := Curr;
        Curr := Free_Nodes(Curr).Next;
    end loop;

    if Unsigned_64(To_Integer(Free_Nodes(Prev).Base)) + Unsigned_64(Free_Nodes(Prev).Length) = Unsigned_64(To_Integer(Base)) then 
        Free_Nodes(Prev).Length := @ + Length;
    elsif Unsigned_64(To_Integer(Base)) + Unsigned_64(Length) = Unsigned_64(To_Integer(Free_Nodes(Curr).Base)) then 
        Free_Nodes(Curr).Length := @ + Length;
        Free_Nodes(Curr).Base   := Free_Nodes(Curr).Base - Storage_Offset(Length);
    else 
        Free := Get_Free_Node; 
        Free_Nodes(Prev).Next   := Free;
        Free_Nodes(Free)        := (Curr, Base, Length);
    end if;

    while Curr /= Tail and then Unsigned_64(To_Integer(Free_Nodes(Prev).Base)) + Unsigned_64(Free_Nodes(Prev).Length) = Unsigned_64(To_Integer(Free_Nodes(Curr).Base)) loop 
        Free_Nodes(Prev).Length := @ + Free_Nodes(Curr).Length;
        Free_Nodes(Prev).Next := Free_Nodes(Curr).Next;
        Free_Nodes(Curr).Length := 0; -- free the node
        Curr := Free_Nodes(Curr).Next;
    end loop;



    


    
    
    
end Free;


procedure Print is 
    I : Node_Index := Free_Nodes(Head).Next;
begin 
    At_X(0);   Put("Address Base", fg=>Grey);
    At_X(20);  Put("Size", fg=>Grey);
    At_X(40);  Put("Size", fg=>Grey);
    At_X(60);  Put("Node", fg=>Grey);
    At_X(70);  Put("Next Node", fg=>Grey);
    Put(LF);
    while I /= Tail loop       
        At_X(0);   Put_Hex(Positive(To_Integer(Free_Nodes(I).Base)));
        At_X(20);  Put_Size(Free_Nodes(I).Length);
        At_X(40);  Put_Hex(Free_Nodes(I).Length);
        At_X(60);  Put_Int(I);
        I := Free_Nodes(I).Next;
        At_X(70);  if I = Tail then Put("END"); else Put_Int(I); end if;
        Put(LF);
    end loop;
    Put(LF);
end;

end MMap;