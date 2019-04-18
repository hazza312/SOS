package Syscall is 

    type System_Call is (Test, Read, Write);

    procedure Handle(Call: System_Call);

end Syscall;