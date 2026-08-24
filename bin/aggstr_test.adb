with TEXT_IO; use TEXT_IO;

procedure AGGSTR_TEST is

  NB_OK	: INTEGER := 0;
  NB_KO	: INTEGER := 0;

  package DICO is
    type CLE is ( K_A, K_B, K_C, K_D, K_E );
    subtype STR3 is STRING( 1..3 );
    TXT	: constant array ( CLE ) of STR3 := (
	K_C => "CC!",	K_A => "AND",	K_E => "E!!",
	K_D => "DD!",	K_B => "OR!"
	);								--| associations nommees dans le desordre, rembourrage '!'
    POSTXT	: constant array ( CLE ) of STR3 := (
	"AND",	"OR!",	"CC!",	"DD!",	"E!!"
	);								--| jumeau POSITIONNEL, memes textes
  end DICO;

  procedure CHECK ( COND :BOOLEAN; NUM :INTEGER ) is
  begin
    if COND then
      NB_OK := NB_OK + 1;
    else
      NB_KO := NB_KO + 1;
      PUT( "* ECHEC test" );
      PUT( INTEGER'IMAGE( NUM ) );
      NEW_LINE;
    end if;
  end CHECK;

  use DICO;

begin
  declare
    ITEM	: constant STRING := TXT( K_B );				--| LE motif du crash : init d'objet depuis element indexe
  begin
    CHECK( ITEM'LENGTH = 3, 1 );
    CHECK( ITEM = "OR!", 2 );
  end;

  CHECK( TXT( K_A )( 1 ) = 'A', 3 );					--| double indexation : chemin scalaire
  CHECK( TXT( K_A )( 3 ) = 'D', 4 );
  CHECK( TXT( K_D )( 2 ) = 'D', 5 );

  CHECK( TXT( K_E ) = "E!!", 6 );					--| egalite composite directe sur element indexe

  declare
    S3	: STR3	:= ( others=> '?' );
  begin
    S3 := TXT( K_C );							--| AFFECTATION (pas init) depuis element indexe
    CHECK( S3 = "CC!", 7 );
  end;

  CHECK( POSTXT( K_B ) = "OR!", 8 );					--| jumeau positionnel : discrimine le chemin nomme
  CHECK( POSTXT( K_E ) = "E!!", 9 );

  declare								--| boucle de rognage du motif reel
    ITEM	: constant STRING := TXT( K_E );
    L		: NATURAL := 3;
  begin
    while L > 0 and then ITEM( L ) = '!' loop
      L := L - 1;
    end loop;
    CHECK( L = 1, 10 );
  end;

  PUT( "RESULTAT :" );
  PUT( INTEGER'IMAGE( NB_OK ) );
  PUT( " OK," );
  PUT( INTEGER'IMAGE( NB_KO ) );
  PUT_LINE( " ECHECS" );
  if NB_KO = 0 then
    PUT_LINE( "AGGSTR_TEST PASSE" );
  else
    PUT_LINE( "AGGSTR_TEST ECHOUE" );
  end if;

exception
  when others =>
    PUT_LINE( "AGGSTR_TEST ECHOUE (EXCEPTION)" );
end AGGSTR_TEST;
