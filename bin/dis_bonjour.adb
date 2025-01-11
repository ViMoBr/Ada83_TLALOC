with TEXT_IO;
use  TEXT_IO;
procedure DIS_BONJOUR is
--  NOM	:constant STRING	:= "Vincent";
--  MSG	:constant STRING	:= "Merci !";
--  C	: CHARACTER	:= 'N';
begin
--  PUT( NOM );
--  PUT( " !" );

	EXT_LOOP:
loop
		GET_CHAR_LOOP:
  loop
BLOC_CHAR:
    declare
      C	: CHARACTER	:= 'N';
    begin
      PUT( " Entrez un caractere : " );
      GET( C );
      exit when C = 'q';
      exit EXT_LOOP when C = 'x';
      PUT( C );
    end BLOC_CHAR;
  end loop GET_CHAR_LOOP;
  PUT( "Demi sortie !" );
  NEW_LINE;
end loop EXT_LOOP;

--  NEW_LINE;

--  if C = 'Y' then
--    PUT( "OK" );
--  elsif C = 'N' then
--    PUT( "NOK" );
--  else
--    PUT( "??" );
--  end if;

--  NEW_LINE;
--  PUT( MSG );

--  NEW_LINE( 2 );
--  PUT( C );
--  NEW_LINE;
end;
