with Console; use Console;
with System;
with System.Storage_Elements; use System.Storage_Elements;
with Multiboot; use Multiboot;
with X86.Debug;
with X86.Dev.Pic_8259A, X86.Dev.Pit_8253, X86.Dev.Keyboard, X86.Dev.VGA_Console, X86.Dev.RTC;
with System.Machine_Code; use System.Machine_Code;
with Consoleb; 
with X86.Interrupts; use X86.Interrupts;
with Kernel; use Kernel;

package body Arch is

    package Printer is new Consoleb.Printer(
         At_X   => X86.Dev.VGA_Console.At_X,
         Put    => X86.Dev.VGA_Console.Put,
         Clear  => X86.Dev.VGA_Console.Clear);

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



    procedure Initialise_Interrupts is
        Tmp : Unsigned_64 := 0;
        Count: Integer := 0;
        Next : Unsigned_64 := 0;
        Native_A : Unsigned_64 with Import, External_Name => "pit_8253_handler";
        Native_B : Unsigned_64 with Import, External_Name => "x86_dev_keyboard_handler";
    begin 
        X86.Dev.Pic_8259A.Initialise;
        Asm("sti", Volatile=>True);

-- PIT 8253A
        Put("-> registering PIT 8253A @IRQ ");  Put_Hex(Interrupt'Enum_Rep(PIT));   Put(LF);
        X86.Interrupts.Slow_Handler(PIT, X86.Dev.Pit_8253.Handler'Address);
        --X86.Interrupts.Register_Handler(PIT, Native_A'Address);
        
        Put("-> testing PIT 8253A ");
        X86.Dev.Pit_8253.Reset;
        for I in 0..51 loop 
            while I >= Integer(X86.Dev.Pit_8253.Get_Ticks) loop null; end loop;
            Put('.');
        end loop;
        Put_Line(" done");

-- Keyboard
        Put("-> registering Keyboard @IRQ "); Put_Hex(Interrupt'Enum_Rep(Keyboard));   Put(LF);       
        X86.Interrupts.Slow_Handler(Keyboard, X86.Dev.Keyboard.Handler'Address);
        -- X86.Interrupts.Register_Handler(Keyboard, Native_B'Address);

        X86.Dev.Keyboard.Reset;
        Put("-> testing keyboard (press any key) ");
        While Integer(X86.Dev.Keyboard.Get_Ticks) = 0 loop null; end loop;
        for J in 0..36 loop Put('.'); end loop;
        Put_Line(" done");

-- RTC
        Put("-> registering RTC @IRQ "); Put_Hex(Interrupt'Enum_Rep(RTC));   Put(LF); 
        X86.Interrupts.Slow_Handler(RTC, X86.Dev.RTC.Handler'Address);
        X86.Dev.RTC.Initialise;
        
-- done
        At_X(0);    Put("-> PIT ticks:");
        At_X(24);   Put("Keyboard ticks:");
        At_X(47);   Put("RTC Seconds:");

        loop 
            At_X(14); Put_Int(Integer(X86.Dev.Pit_8253.Get_Ticks), bg=>Light_Red);
            At_X(40); Put_Int(Integer(X86.Dev.Keyboard.Get_Ticks), bg=>Light_Red);
            At_X(60); Put_Int(Integer(X86.Dev.RTC.Get_Ticks)/2, bg=>Light_Red);
        end loop;
        
    end Initialise_Interrupts;  


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
    begin 
        X86.Debug.Print_Multiboot_Map(Entries);
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