procedure TEST_3 is

  INT_L1	: INTEGER	:= 5;
  OK	: BOOLEAN	:= TRUE;
  CAR	: CHARACTER;

  procedure APPELEE ( INTA, INTB :in INTEGER:= 0; PRM_C :out CHARACTER; PRM_B :in out Boolean ) is
    INT_L21, INT_L22	: INTEGER;
  begin
    PRM_C:= 'A';
    PRM_B := FALSE;
    INT_L21 := INTA+3;
    INT_L22 := INTB+INT_L21;
  end;

begin
  APPELEE( INT_L1, PRM_C => CAR, PRM_B => OK );
end;
