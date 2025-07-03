with TEXT_IO;
use  TEXT_IO;
			---------
procedure			FILE_TEST
is			---------

  F	: TEXT_IO.FILE_TYPE;
  NOM	:constant STRING	:= "./essai.txt";
  C	: CHARACTER;
  PROMPT	:constant STRING	:= "Taper un caractere ";

begin
  CREATE( F, OUT_FILE, NOM );
  PUT_LINE( "FICHIER CREE !" );
  PUT( PROMPT );
  GET( C );

  CLOSE( F );
  PUT_LINE( "FICHIER FERME !" );
  PUT( PROMPT );
  GET( C );

  OPEN( F, OUT_FILE, NOM );
  PUT_LINE( "FICHIER OUVERT !" );
  PUT( PROMPT );
  GET( C );

  PUT_LINE( "ECRITURES..." );
  PUT( F, 'Z' );
  PUT( F, "CONTENT !" );
  NEW_LINE( F );
  PUT( F, "SUPER CONTENT !" );
  PUT( PROMPT );
  GET( C );

  CLOSE( F );
  PUT_LINE( "FICHIER FERME !" );
  DELETE( F );
  PUT_LINE( "FICHIER DETRUIT !" );
end	FILE_TEST;
	---------
