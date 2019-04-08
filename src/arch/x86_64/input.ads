with X86.Dev.Keyboard;

package Input is 

   procedure Enable_Cursor;
   procedure Disable_Cursor;
   function Get_Word(S: in out String) return Positive;
   function Get_Line(S: in out String) return Positive;
   function Get_Char return Character;

end Input;