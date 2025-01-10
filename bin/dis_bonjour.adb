with TEXT_IO;
use  TEXT_IO;
procedure DIS_BONJOUR is
  NOM	:constant STRING	:= "Vincent";
  MSG	:constant STRING	:= "Bonjour";
begin
  PUT( NOM );
  PUT( '!' );
  NEW_LINE( 3 );
  PUT( MSG );
--  PUT( NOM );
  NEW_LINE;
  PUT( NOM );
  NEW_LINE;
end;
