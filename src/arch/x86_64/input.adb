with X86.Dev.Keyboard;
with Console;
with Arch; use Arch;

package body Input is 

   procedure Enable_Cursor is null; 

   procedure Disable_Cursor is 
   begin 
      null;
      -- IO_Outs(16#a#, 16#3d4#);
      -- IO_Outs(16#20#, 16#3d5#);
   end; 



   function Get_Word(S: in out String) return Positive is
      I: Positive := S'First;
      C: Character;
   begin
      X86.Dev.Keyboard.Flush;

      while I < S'Last loop 
         C := Get_Char;
         exit when C = ' ';
         S(I) := C;
         I := I + 1;
      end loop;

      return I - S'First;         
   end Get_Word;


   function  Get_Line(S: in out String) return Positive is
      I: Positive := S'First;
      C: Character;
   begin 
      X86.Dev.Keyboard.Flush;

      while I < S'Last loop 
         C := Get_Char;
         if C = Console.LF then 
            S(I) := Character'Val(0);
            exit;
         end if;
         S(I) := C;
         I := I + 1;
      end loop;

      return I - S'First;   
   end Get_Line;


   function Get_Char return Character is 
      C: Character;
   begin
      while not X86.Dev.Keyboard.Has_Input loop null; end loop;
      C := X86.Dev.Keyboard.Get_Character;
      Console.Put(C);
      return C;
   end Get_Char;

end Input;