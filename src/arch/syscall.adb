with System, Console, Interfaces, X86.Dev.Keyboard, System.Machine_Code;
use Console, Interfaces, System.Machine_Code;

with Interfaces.C;

package body Syscall is
   procedure DEBUG is begin null; end DEBUG;

   procedure Handle(Call: System_Call) is
      type T is access String(1..28);
      C_Str : T;
   begin
      Asm("movq   %%r15, %0", Outputs => (T'Asm_Output("=g", C_Str)), Volatile=>True);
      Banner("<kernelmode>");
      Banner("SYSCALL", BG=>Light_Green);
      Put("Call #"); Put_Hex( Unsigned_64(System_Call'Enum_Rep(Call)) ); 

      -- TODO: handle syscall with a switch.
      -- replace at some point with a jmp/call table
      case Call is 
         when Test      => Put_Line(" = Test");
         when Read      => Put_Line(" = Read");
         when Write     => Put_Line(" = Write ");
                           Put_Line(C_Str.all);
         when others    => Put_Line("other");
      end case;
      Banner("</kernelmode>");
   end Handle;

end Syscall;