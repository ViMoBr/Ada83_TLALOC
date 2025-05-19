with TEXT_IO;
use  TEXT_IO;
			----------
procedure			ARRAY_TEST
is			----------
  S	:constant STRING := "Camille";
--  S2	: STRING( 1 .. 256 );
  C	: CHARACTER;
begin
  for I in S'FIRST .. S'LAST loop
    C := S( I );
    PUT( C ); PUT( '_' );
  end loop;
end	ARRAY_TEST;
	----------
