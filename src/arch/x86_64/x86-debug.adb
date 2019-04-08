with Multiboot; use Multiboot;
with Console; use Console;

package body X86.Debug is 
    

    procedure Print_Multiboot_Map(Entries: Multiboot.Memory_Entries) is   
    begin 
        Set_Colour(FG => Grey);
        At_X(0);    Put("Base Address");
        At_X(20);   Put("Length (hex)");
        At_X(40);   Put("Length");
        At_X(60);   Put("Type");
                    Put(LF);

        Set_Colour;
        for Current of Entries loop 
            At_X(0);    Put_Hex(Current.Base_Address);
            At_X(20);   Put_Hex(Current.Length);
            At_X(40);   Put_Size(Current.Length);
            At_X(60);   case Current.Availability is          
                        when Free_Ram       => Put("RAM");
                        when others         => Put("unavailable"); 
                        end case;        
            Put(LF);
        end loop;
        Put(LF);
    end Print_Multiboot_Map;


end X86.Debug;