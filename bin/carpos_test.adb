with TEXT_IO;
use  TEXT_IO;
			-----------
procedure			CARPOS_TEST
is			-----------
  S	: STRING( 1 .. 16 );
  I	: INTEGER	:= S'LAST;
  F	: INTEGER		:= INTEGER'LAST;
  C	: CHARACTER	:= '0';
  P	: INTEGER;
begin
  P := CHARACTER'POS( C );
end	CARPOS_TEST;
	-----------
