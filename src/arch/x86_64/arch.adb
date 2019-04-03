with Console; use Console;
with System;
with System.Storage_Elements; use System.Storage_Elements;
with Multiboot; use Multiboot;
with X86_Debug;

package body Arch is 

    procedure Insert_Entry(Holes: in out Holes_List; E: Multiboot.Memory_Entry) is 
        I : Natural := 0;
        Length : Natural := Natural(E.Length);
    begin 
        while I in Holes_List'Range and then Holes(I).Length > Length loop 
            I := I + 1;
        end loop;

        if I <= Holes'Last then        
            for J in reverse I+1..Holes'Last loop 
                Holes(J) := Holes(J-1);
            end loop;
            Holes(I) := (Base => System'To_Address(E.Base_Address), 
                         Length => Length);
        end if;
    end Insert_Entry;


    procedure Parse_Memory_Entries(Holes: in out Holes_List; Base: System.Address; N: Natural) is   
        Entries : Multiboot.Memory_Entries(0..N-1) with Address => Base + 16;
        I : Natural := 0;
        Tmp: Free_Hole;
    begin 
        X86_Debug.Print_Multiboot_Map(Entries);
        for Memory_Entry of Entries loop
            if Memory_Entry.Availability = Multiboot.Free_Ram then
                Insert_Entry(Holes, Memory_Entry); 
            end if;
            I := I + 1;
            exit when I > Holes'Last;
        end loop;
    end Parse_Memory_Entries;


    procedure Scout_Memory(Holes: in out Holes_List) is
        Tag: Multiboot.Base_Tag with Address => System'To_Address(Multiboot.Boot_Info);
        Byte_Count: Unsigned_32 := 8;
    begin
        while Byte_Count < Tag.Tag_Type loop
            declare 
                Tag_S : Multiboot.Base_Tag with Address => System'To_Address(Multiboot.Boot_Info + Byte_Count);
            begin
                if Tag_S.Tag_Type = 6 then
                    Parse_Memory_Entries(Holes, Tag_S'Address, Positive(Tag_S.Tag_Size-24)/24);
                    exit;
                end if;

                Byte_Count := @ + Tag_S.Tag_Size;
                if Byte_Count mod 8 /= 0 then 
                    Byte_Count := @ + (8 - (@ mod 8));
                end if;
            end;     
        end loop;       
    end Scout_Memory;

end Arch;