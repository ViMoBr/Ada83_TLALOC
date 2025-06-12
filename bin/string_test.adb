with TEXT_IO;
use  TEXT_IO;
			-----------
procedure			STRING_TEST
is			-----------
  L	: NATURAL;
  package NAT_IO is new INTEGER_IO( NATURAL );
begin

  PUT_LINE( "Entrez un nombre entier : " );
  NAT_IO.GET( L );

  PUT_LINE( "Merci" );

end	STRING_TEST;
	-----------
