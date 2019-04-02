with Interfaces; use Interfaces;

package IDT is

    procedure Set_Entry;


private
    type IDT_Entry is record
        Offset_0_15: Unsigned_16;
        Selector: Integer;


        IST_Offset: Unsigned_8 range 0..7;
        Offset_16_31: Unsigned_16;
        Offset_32_63: Unsigned_32;
        Zero: Unsigned_32;
    end record;



--    uint16_t offset_1; // offset bits 0..15
--    uint16_t selector; // a code segment selector in GDT or LDT
--    uint8_t ist;       // bits 0..2 holds Interrupt Stack Table offset, rest of bits zero.
--    uint8_t type_attr; // type and attributes
--    uint16_t offset_2; // offset bits 16..31
--    uint32_t offset_3; // offset bits 32..63
--    uint32_t zero;     // reserved


end IDT;