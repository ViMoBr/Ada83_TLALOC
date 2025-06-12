with TEXT_IO;
use  TEXT_IO;
			----------
procedure			ARRAY_TEST
is			----------
  S	:constant STRING := "Camille";
  C	: CHARACTER;
begin
  for I in S'FIRST .. S'LAST loop
    C := S( I );
    PUT( C ); PUT( '_' );
  end loop;
  NEW_LINE;
end	ARRAY_TEST;
	----------
