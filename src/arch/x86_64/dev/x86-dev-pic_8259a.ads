with Interfaces; use Interfaces;
with Arch; use Arch;
with Ada.Unchecked_Conversion; 

package X86.Dev.PIC_8259A is

    type IRQ is range 32..47 ;
    type Device is (Master, Slave);
    type Destination is (Command, Data); 

    IRQ_Base : constant array(Device) of IRQ := (
        Master => 16#20#,
        Slave => 16#28#);

    Port : constant array(Device, Destination) of IO_Port := (
        Master => (Command => 16#20#, Data => 16#21#),
        Slave  => (Command => 16#A0#, Data => 16#A1#));

    type CW_Type is (ICW1, ICW2, ICW3_Master, ICW3_Slave, ICW4);
    type Bit_Field is array(0..7) of Boolean with Pack;

    -- see https://pdos.csail.mit.edu/6.828/2009/readings/hardware/8259A.pdf
    -- 8080 configurations here, ignoring MCS80/85

    type Control_Word(Id: CW_Type) is record 
        case Id is 
        when ICW1 =>
            ICW4_Present:      Boolean;
            Cascade:           Boolean;
            CAI_4:             Boolean;
            Level_Triggered:   Boolean;
            Reserved_0:        Integer range 1..1 := 1;
        when ICW2 =>
            Offset:            IRQ;
        when ICW3_Master =>
            Master_Mask:       Bit_Field;
        when ICW3_Slave =>
            Slave_Mask:        Bit_Field;
        when ICW4 =>
            Mode_80xx:         Boolean;
            Auto_EOI:          Boolean;
            Master:            Boolean;
            Buffered:          Boolean;
            SFNM_Mode:         Boolean;
            Reserved_1:        Integer range 0..0 := 0;
        end case;
    end record;

    for Control_Word use record 
        ICW4_Present    at 0 range 0..0;
        Cascade         at 0 range 1..1;
        CAI_4           at 0 range 2..2;
        Level_Triggered at 0 range 3..3;
        Reserved_0      at 0 range 4..7;
        Offset          at 0 range 0..7;
        Master_Mask     at 0 range 0..7;
        Slave_Mask      at 0 range 0..7;
        Mode_80xx       at 0 range 0..0;
        Auto_EOI        at 0 range 1..1;
        Master          at 0 range 2..2;
        Buffered        at 0 range 3..3;
        SFNM_Mode       at 0 range 4..4;
        Reserved_1      at 0 range 5..7;
    end record;

    procedure Send(D: Device; Dest: Destination; Msg: Control_Word) with Inline;
    procedure Initialise;
    procedure Send_EOI(Num: IRQ);   


end X86.Dev.PIC_8259A;