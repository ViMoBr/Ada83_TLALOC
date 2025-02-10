procedure BUG_2 is


--generic
--  type U is range <>;
--package TESTEUR is
  --procedure DEDANS;
--end TESTEUR;

--package body TESTEUR is

  procedure DEDANS  is
    J : INTEGER := 0;
  begin

--BOUCLE_WHILE:
--  while J < 6 loop
--    J := J + 1;
--  end loop BOUCLE_WHILE;

--BOUCLE:
--  loop
--    J := J + 1;
--  end loop BOUCLE;

BOUCLE_FOR:
  for N in 0 .. 10 loop
    J := J + 1;
  end loop BOUCLE_FOR;

--BLOC_A:
--    declare
--      i :integer := 0;
--    begin
--      i:= 1;
--    end  BLOC_A;

  end DEDANS;

--end TESTEUR;


begin
  null;
end BUG_2;
