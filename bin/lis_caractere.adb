with TEXT_IO;
use  TEXT_IO;
			-------------
procedure			LIS_CARACTERE
is			-------------
  C	: CHARACTER;
begin
  PUT( " Bonjour " );
  NEW_LINE( 2 );

LIRE_UN:
  loop
    PUT( " Entrez un caractere ! " );
    GET( C );
    PUT( " Vous avez tape : " );
    PUT( C );
    NEW_LINE;
    exit when C = 'q';
  end loop LIRE_UN;

end	LIS_CARACTERE;
	-------------
