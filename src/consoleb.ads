with System;
with Interfaces; use Interfaces;


generic 
    with procedure Putc(C : Character);
package Consoleb is
    procedure X(C : Natural);
    procedure Put(C : Character);
    procedure Put(S: String);
    procedure Put(N : Unsigned_64);
    procedure Put_Int(N : Integer);
    procedure Put_Hex(N: Positive);
    procedure Put_Size(s: Unsigned_64);
    procedure Put_Line(S: String);    
    procedure Banner(S : String); 
    

end Consoleb;