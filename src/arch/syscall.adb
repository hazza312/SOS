with System, Console, Interfaces, X86.Dev.Keyboard, System.Machine_Code;
use Console, Interfaces, System.Machine_Code;

package body Syscall is  

   procedure Handle(Call: System_Call) is 
   begin
      --Asm("cli", Volatile => True);
      Put_Hex( Unsigned_64(System_Call'Enum_Rep(Call)) ); 
      Put(LF);

      case Call is 
         when Test      => Put_Line("test procedure");
         when others    => Put_Line("other");
      end case;
   
   -- while not X86.Dev.Keyboard.Has_Input loop null; end loop;

   --loop null; end loop;
   --Asm("sysret", Volatile => True);

   end Handle;

end Syscall;