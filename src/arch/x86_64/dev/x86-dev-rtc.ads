with Arch; use Arch;
with Interfaces; use Interfaces;

package X86.Dev.RTC is 

    Selector_Port : IO_Port := 16#70#;
    Data_Port : IO_Port := 16#71#;

    type Time_Unit is (
        Seconds, Minutes, Hours, Weekday, 
        Day_Of_Month, Month, Year, Century
    );

    for Time_Unit use (
        Seconds => 0, Minutes => 2, Hours => 4, Weekday => 6,
        Day_Of_Month => 7, Month => 8, Year => 9,
        Century => 16#32#
    );

    type Status_Register is (A, B, C);
    for Status_Register use (A => 10, B => 11, C => 12);


    procedure Handler;
    procedure Read_Time;
    procedure Initialise;
    function Get_Ticks return Unsigned_64;

end X86.Dev.RTC;