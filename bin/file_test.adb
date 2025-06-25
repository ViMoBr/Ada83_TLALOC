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
--  OPEN( F, OUT_FILE, NOM );
  PUT( PROMPT );
  GET( C );
  CLOSE( F );
  DELETE( F );
end	FILE_TEST;
	---------
