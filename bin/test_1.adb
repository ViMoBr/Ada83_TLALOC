--with TEXT_IO;
procedure TEST_1 is

  STR		: STRING( 1 .. 68 );

--  package INT_IO is new TEXT_IO.INTEGER_IO( INTEGER );

begin
  STR( STR'LAST ) := '#';
--  INT_IO.PUT( J, WIDTH => 10, BASE => 16 );

end;
