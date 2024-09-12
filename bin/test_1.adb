--with TEXT_IO;
--use  TEXT_IO;
procedure TEST_1 is

  J	: INTEGER		:= 15;
  K	: INTEGER;
--  procedure INTERNE ( VAL :in INTEGER ) is begin null; end;

--  MSG	:constant STRING	:= "Bonjour";
begin
  for I in reverse 0 .. J loop
    K := I;
  end loop;

--  PUT_LINE( MSG );
end;
