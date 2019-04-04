with Multiboot; use Multiboot;
with Console; use Console;

package body X86_Debug is 
    

    procedure Print_Multiboot_Map(Entries: Multiboot.Memory_Entries) is   
    begin 
        At_X(0);    Put("Base Address", fg=>Grey);
        At_X(20);   Put("Length (hex)", fg=>Grey);
        At_X(40);   Put("Length", fg=>Grey);
        At_X(60);   Put("Type", fg=>Grey);             Put(LF);

        for Current of Entries loop 
            At_X(0);    Put_Hex(Positive(Current.Base_Address));
            At_X(20);   Put_Hex(Positive(Current.Length));
            At_X(40);   Put_Size(Positive(Current.Length));
            At_X(60);   case Current.Availability is          
                        when Free_Ram       => Put("RAM");
                        when others         => Put("unavailable"); 
                        end case;        
            Put(LF);
        end loop;
        Put(LF);
    end Print_Multiboot_Map;


end X86_Debug;