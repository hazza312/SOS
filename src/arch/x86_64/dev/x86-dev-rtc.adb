with Interfaces; use Interfaces;
with Arch; use Arch;
with Console; use Console;

package body X86.Dev.RTC is

    -- TODO: types?
    -- Counts : array(Time_Unit) of Integer;
    Ticks : Unsigned_64 := 0 with Export, External_Name => "x86_dev_rtc_ticks";

    procedure Handler is 
        X : Unsigned_8;
    begin
        -- someone else can do the "cascading"
        Ticks := Ticks + 1;
        IO_Outb(Selector_Port, C'Enum_Rep);
        X := IO_Inb(Data_Port);
    end Handler;

    procedure Read_Time is 
    begin 
        null;
    end Read_Time;

    procedure Initialise is
        Old : Unsigned_8 := 0; 
    begin
        -- enable interrupts
        IO_Outb(Selector_Port, 16#80# or B'Enum_Rep);
        Old := IO_Inb(Data_Port);

        IO_Outb(Selector_Port, 16#80# or B'Enum_Rep);
        IO_Outb(Data_Port, Old or 16#40#);


        -- change rate to 2Hz
        IO_Outb(Selector_Port, 16#80# or A'Enum_Rep);
        Old := IO_Inb(Data_Port);

        IO_Outb(Selector_Port, 16#80# or A'Enum_Rep);
        IO_Outb(Data_Port, (Old and 16#f0#) or 16#0f#);
        null;
    end Initialise;

    function Get_Ticks return Unsigned_64 is (Ticks);



end X86.Dev.RTC;