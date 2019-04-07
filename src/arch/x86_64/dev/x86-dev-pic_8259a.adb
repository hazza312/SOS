with Arch; use Arch;
with Ada.Unchecked_Conversion; 

package body X86.Dev.PIC_8259A is

    function Convert is new Ada.Unchecked_Conversion(Control_Word, Unsigned_16);

    procedure Send(D: Device; Dest: Destination; Msg: Control_Word) is 
    begin
        IO_Outb(Port(D, Dest), Unsigned_8(Convert(Msg) and 16#ff#));
    end Send;

    procedure Initialise is
        Restart: Control_Word := (ICW1, ICW4_Present => True, others => <>);
        X86_Mode: Control_Word := (ICW4, Mode_80xx => True, others => <>);
    begin
        Send(Master, Command, Restart);
        Send(Slave, Command, Restart);
        
        Send(Master, Data, (ICW2, IRQ_Base(Master)));
        Send(Slave, Data, (ICW2, IRQ_Base(Slave)));

        Send(Master, Data, (ICW3_Master, (2=>True, others => <>)));
        Send(Slave, Data, (ICW3_Slave, (1=>True, others => <>)));

        Send(Master, Data, X86_Mode);
        Send(Slave, Data, X86_Mode);
    end Initialise;

    procedure Send_EOI(Num: IRQ) is
    begin
        null;
    end Send_EOI; 


end X86.Dev.PIC_8259A;