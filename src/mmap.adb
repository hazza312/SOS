with Console; use Console;
with System.Storage_Elements; use System.Storage_Elements;
with Common; use Common;

package body MMap is 

Address_Base : Address := Null_Address;
Allocation_Unit : Unsigned_64 := 0;
Max_Length : Unsigned_64 := 0;
Free_Space: Unsigned_64;

Head: Node_Index := 0;
Tail: Node_Index := MAX_ALLOCATIONS;

Nodes: Node_List := (
    others       =>   (0,     Null_Address,    0           )
);

function Get_Free_Space return Unsigned_64 is (Free_Space);

procedure Initialise(Base: Address; Length: Unsigned_64; Unit: Unsigned_64) is 
begin 
   Allocation_Unit := Unit;
   Address_Base := Base;
   Max_Length := Length;
   Free_Space := Length;

   Nodes(0) := (1,     Null_Address,   0       );
   Nodes(1) := (Tail,  Base,           Length  );
end Initialise;

function Get_Base return Address is (Address_Base);
function Get_Length return Unsigned_64 is (Max_Length);


function Get_Free_Node return Node_Index is 
begin 
   for I in 1..MAX_ALLOCATIONS-1 loop 
      if Nodes(I).Length = 0 then 
         return I;
      end if;
   end loop;
   return 0;
end Get_Free_Node;


function Allocate(Size: Unsigned_64) return Address is 
   Prev:   Node_Index := Head;
   Match:  Node_Index := Nodes(Head).Next;
   Addr:   Address := NULL_ADDRESS;
begin 
   --Put_Size(Free_Space); Put(LF);
   if Size = 0 or else Size mod Allocation_Unit /= 0 then 
      return 0;
   end if;

   while Match /= Tail and then Nodes(Match).Length < Size loop 
      Prev := Match;
      Match := Nodes(Match).Next;
   end loop;

   if Match = Tail then 
      null;

   -- TODO: need to join other higher regions(?)
   elsif Nodes(Match).Length = Size then 
      Nodes(Prev).Next := Nodes(Match).Next;
      Nodes(Match).Length := 0;     
      Addr := Nodes(Match).Base;
      Free_Space := @ - Size;
   
   elsif Nodes(Match).Length > Size then
      Addr := Nodes(Match).Base;
      Nodes(Match).Base    := Nodes(Match).Base + Address(Size);
      Nodes(Match).Length  := Nodes(Match).Length - Size;    
      Free_Space := @ - Size;  
   end if;

   
   return Addr;
end Allocate;



procedure Free(Base: Address; Length: Unsigned_64) is 
   Prev:  Node_Index := Head;
   Curr:  Node_Index := Head;
   Free:  Node_Index := 0;

begin
   while Curr /= Tail and then Base >= Nodes(Curr).Base loop      
      Prev := Curr;
      Curr := Nodes(Curr).Next;
   end loop;

   if Nodes(Prev).Base + Address(Nodes(Prev).Length) = Base then 
      Nodes(Prev).Length := @ + Length;
   elsif Base + Address(Length) = Nodes(Curr).Base then 
      Nodes(Curr).Length := @ + Length;
      Nodes(Curr).Base   := Nodes(Curr).Base - Address(Length);
   else 
      Free := Get_Free_Node; 
      Nodes(Prev).Next   := Free;
      Nodes(Free)        := (Curr, Base, Length);
   end if;

   while Curr /= Tail 
   and then Nodes(Prev).Base + Address(Nodes(Prev).Length) 
            = Nodes(Curr).Base 
   loop 
      Nodes(Prev).Length := @ + Nodes(Curr).Length;
      Nodes(Prev).Next := Nodes(Curr).Next;
      Nodes(Curr).Length := 0; -- free the node
      Curr := Nodes(Curr).Next;
   end loop;  

   Free_Space := @ + Length;
    
end Free;


procedure Print is 
   I : Node_Index := Nodes(Head).Next;
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
      At_X(0);   Put_Hex(Nodes(I).Base);
      At_X(20);  Put_Size(Nodes(I).Length);
      At_X(40);  Put_Hex(Nodes(I).Length);
      At_X(60);  Put(I);
      I := Nodes(I).Next;
      At_X(70);  if I = Tail then Put("END"); else Put(I); end if;
      Put(LF);
   end loop;
   Put(LF);
end;

end MMap;