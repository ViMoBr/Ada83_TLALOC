with TEXT_IO;
use  TEXT_IO;
			-----------
procedure			STRING_TEST
is			-----------
  S	: STRING( 1 .. 256 );
  L	: NATURAL;
  type MAT is array( 1 ..15, 1 .. 18 ) of NATURAL;
  M	: MAT;
begin
  PUT_LINE( "Entrez une chaine svp : " );
  GET_LINE( S, L );
  PUT( S );
  PUT_LINE( "Merci" );

end	STRING_TEST;
	-----------
