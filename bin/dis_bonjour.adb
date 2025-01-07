with TEXT_IO;
use  TEXT_IO;
procedure DIS_BONJOUR is
  NOM	:constant STRING	:= "Vincent";
  MSG	:constant STRING	:= "Bonjour";
begin
  PUT( NOM );	-- put première chaîne ok
  PUT( '!' );	-- le put char abime la seconde chaîne
  NEW_LINE;	-- pareil
  PUT( MSG );	-- seconde chaîne plante alors
  PUT( NOM );
  NEW_LINE;
  PUT( NOM );
  NEW_LINE;
end;
