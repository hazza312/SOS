package Syscall is 

    type System_Call is (
        Test,   -- TEST CALL
        Read,   -- READ
        Write  -- WRITE
    );

    procedure Handle(Call: System_Call);

end Syscall;