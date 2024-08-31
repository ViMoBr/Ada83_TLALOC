with MACHINE_CODE;
use  MACHINE_CODE;
procedure TEST_2 is

  procedure CALL_SYS is
  begin
    ASM_OP_1'( OPCODE => LDI, VAL => 1 );
    ASM_OP_0'( OPCODE => PUT_STR );
    ASM_OP_2'( OPCODE => STW, LVL => 1, OFS => 8 );
    ASM_OP_1'( OPCODE => DB, VAL => 16#C3# );
  end;

begin
  CALL_SYS;
end;
