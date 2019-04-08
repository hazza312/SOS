with System; use System;
with System.Storage_Elements; use System.Storage_Elements;
with Ada.Unchecked_Conversion; 
with Interfaces; use Interfaces;

package body consoleb is

    procedure X(C : Natural) is null;
    procedure Put(C : Character) is null;
    procedure Put(S: String) is null;
    procedure Put(N : Unsigned_64) is null;
    procedure Put_Int(N : Integer) is null;
    procedure Put_Hex(N: Positive) is null;
    procedure Put_Size(s: Unsigned_64) is null;
    procedure Put_Line(S: String) is null;    
    procedure Banner(S : String) is null; 


end consoleb;