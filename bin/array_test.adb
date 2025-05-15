with TEXT_IO;
use  TEXT_IO;
			----------
procedure			ARRAY_TEST
is			----------
  S	:constant STRING := "Camille";
  S2	: STRING( 1 .. 256 );
  C	: CHARACTER;
begin
  C := S( 2 );
  PUT( C );
  S2( 3 ) := C;
  C := S2( 3 );
  PUT( C );
end	ARRAY_TEST;
	----------
