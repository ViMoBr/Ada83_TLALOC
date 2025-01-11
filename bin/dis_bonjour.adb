with TEXT_IO;
use  TEXT_IO;
procedure DIS_BONJOUR is
  NOM	:constant STRING	:= "Vincent";
  MSG	:constant STRING	:= "Merci !";
  C	: CHARACTER	:= 'Y';
begin
  PUT( NOM );
  PUT( " !" );
  PUT( " Entrez un caractere : " );
  GET( C );
  PUT( ASCII.CR ); NEW_LINE;
  PUT( MSG );

  PUT( ASCII.CR ); NEW_LINE( 2 );
  PUT( C );
  PUT( ASCII.CR ); NEW_LINE;
end;
