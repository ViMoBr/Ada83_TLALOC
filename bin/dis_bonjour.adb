with TEXT_IO;
use  TEXT_IO;
procedure DIS_BONJOUR is
  MSG	:constant STRING	:= "Bonjour !";
begin
  PUT( MSG );
  PUT( ASCII.LF );
  NEW_LINE;
end;
