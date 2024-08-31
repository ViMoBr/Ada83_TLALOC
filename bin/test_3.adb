procedure TEST_3 is

  INT	: INTEGER	:= 5;
  OK	: BOOLEAN	:= TRUE;
  CA	: CHARACTER;

  procedure APPELEE ( P1 :in INTEGER; C1 :out CHARACTER; B1 :in out Boolean ) is
    JA	: INTEGER;
  begin
    C1 := 'A';
    B1 := FALSE;
    JA := P1;
  end;

begin
  APPELEE( INT, CA, OK );
end;
