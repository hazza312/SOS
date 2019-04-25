with System, System.Storage_Elements, System.Machine_Code;
use  System.Storage_Elements, System.Machine_Code;

with Console, Multiboot, Common;
use  Console, Multiboot, Common;

with X86.Dev.Pic_8259A, X86.Dev.Pit_8253, X86.Dev.Keyboard, 
        X86.Dev.VGA_Console, X86.Dev.RTC, X86.Interrupts, X86.Debug;

use X86.Interrupts;

package body Arch is

    function IO_Inb(Port: IO_Port) return Unsigned_8
    is
        Ret: Unsigned_8;
    begin 
        Asm("inb %1, %0",
            Inputs => IO_Port'Asm_Input("d", Port),
            Outputs => Unsigned_8'Asm_Output("=a", Ret) );
        return Ret;
    end IO_Inb;
        
    procedure IO_Outb(Port: IO_Port; Data: Unsigned_8) is
    begin 
        Asm("outb %0, %1",
            Inputs => (Unsigned_8'Asm_Input("a", Data),
            IO_Port'Asm_Input("d", Port)),
            Volatile => True);
    end IO_Outb;

    function CR3_Address return Physical_Address is 
        Val: Physical_Address;
    begin 
        Asm(    "movq %%cr3, %0", 
                Outputs     => Physical_Address'Asm_Output("=a", Val),
                Volatile    => True);
        return Val;
    end CR3_Address;


    procedure Initialise_Interrupts is
        Native_A : Unsigned_64 with Import, External_Name => "x86_dev_pit_8253_handler";
        Native_B : Unsigned_64 with Import, External_Name => "x86_dev_keyboard_handler";
        Native_C : Unsigned_64 with Import, External_Name => "x86_dev_rtc_handler";
    begin 
        X86.Dev.Pic_8259A.Initialise;

-- PIT 8253A
        Put("-> registering PIT 8253A @IRQ ");  
            Put_Hex(Unsigned_64(Interrupt'Enum_Rep(PIT)));   
            Put(LF);
        X86.Interrupts.Register_Handler(PIT, Native_A'Address);
        Asm("sti", Volatile=>True);
        
        -- Put("-> testing PIT 8253A ");
        -- X86.Dev.Pit_8253.Reset;
        -- for I in 0..51 loop 
        --     while I >= Integer(X86.Dev.Pit_8253.Get_Ticks) loop null; end loop;
        --     Put('.');
        -- end loop;
        -- Put_Line(" done");

-- Keyboard
        Put("-> registering Keyboard @IRQ "); 
            Put_Hex(Unsigned_64(Interrupt'Enum_Rep(Keyboard)));   
            Put(LF);       
        X86.Interrupts.Slow_Handler(Keyboard, X86.Dev.Keyboard.Handler'Address);

-- RTC
        Put("-> registering RTC @IRQ "); 
            Put_Hex(Unsigned_64(Interrupt'Enum_Rep(RTC)));   
            Put(LF); 
        X86.Interrupts.Register_Handler(RTC, Native_C'Address);
        X86.Dev.RTC.Initialise;

        -- Put("-> testing RTC ........");
        -- for I in 0..4 loop 
        --     while I >= Integer(X86.Dev.RTC.Get_Ticks) loop null; end loop;
        --     Put("..........");
        -- end loop;
        -- Put_Line(" done");        
        
    end Initialise_Interrupts;  


    procedure Parse_Memory_Entries(
        Biggest_Base: in out Address;
        Biggest_Size: in out Unsigned_64;
        Base: System.Address; N: Natural;
        Debug : Boolean)
    is   
        Entries : Multiboot.Memory_Entries(0..N-1) with Address => Base + 16;
    begin
        Biggest_Size := 0;
        Biggest_Base := 0; 

        if Debug then
            X86.Debug.Print_Multiboot_Map(Entries);
        end if;
        for Memory_Entry of Entries loop
            if Memory_Entry.Availability = Multiboot.Free_Ram 
            and then Memory_Entry.Length > Biggest_Size
            then
                Biggest_Base := Memory_Entry.Base_Address;
                Biggest_Size := Memory_Entry.Length;
            end if;
        end loop;
    end Parse_Memory_Entries;


    procedure Scout_Memory(Base: in out Address; Size: in out Unsigned_64; Debug: Boolean) is
        Tag: Multiboot.Base_Tag with Address => System'To_Address(Multiboot.Boot_Info);
        Byte_Count: Unsigned_32 := 8;
    begin
        while Byte_Count < Tag.Tag_Type loop
            declare 
                Tag_S : Multiboot.Base_Tag with Address => System'To_Address(Multiboot.Boot_Info + Byte_Count);
            begin
                if Tag_S.Tag_Type = 6 then
                    Parse_Memory_Entries(Base, Size, Tag_S'Address, Positive(Tag_S.Tag_Size-24)/24, Debug);
                    exit;
                end if;

                Byte_Count := @ + Tag_S.Tag_Size;
                if Byte_Count mod 8 /= 0 then 
                    Byte_Count := @ + (8 - (@ mod 8));
                end if;
            end;     
        end loop;       
    end Scout_Memory;


   procedure Reload_CR3(Address: Physical_Address) is 
   begin 
   Asm(  "movq %0, %%rax" & LF &
         "movq %%rax, %%cr3",
         Inputs => Physical_Address'Asm_Input("g", Address),
         Clobber => ("rax"),
         Volatile => True
   );

    end Reload_CR3;

end Arch;