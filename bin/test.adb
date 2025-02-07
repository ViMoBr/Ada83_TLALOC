PROCEDURE TEST IS
--  I	: INTEGER	:= 0;
--  J	: INTEGER := 1;

  type REC is record
	  CHAMP_1	:NATURAL;
	end record;

  type ACC is access REC;

  A_1	: ACC;

BEGIN
  if A_1 /= null then
    null;
  end if;
--  I := J + 1;
END	TEST;
