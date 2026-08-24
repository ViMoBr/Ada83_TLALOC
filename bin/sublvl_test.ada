with TEXT_IO; use TEXT_IO;

procedure SUBLVL_TEST is

  type FEU is ( VERT, ORANGE, ROUGE );

  NB_OK	: INTEGER := 0;
  NB_KO	: INTEGER := 0;
  COMPTE	: INTEGER := 41;

  package COEUR is
    procedure BATTRE;
  end COEUR;

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

  package body COEUR is separate;

  procedure INTERNE is separate;

begin
  INTERNE;								--| subunit de sous-programme : niveau parent + 1
  COEUR.BATTRE;								--| subunit de corps de package : niveau du contexte
  CHECK( COMPTE = 43, 5 );
  PUT( "RESULTAT :" );
  PUT( INTEGER'IMAGE( NB_OK ) );
  PUT( " OK," );
  PUT( INTEGER'IMAGE( NB_KO ) );
  PUT_LINE( " ECHECS" );
  if NB_KO = 0 then
    PUT_LINE( "SUBLVL_TEST PASSE" );
  else
    PUT_LINE( "SUBLVL_TEST ECHOUE" );
  end if;
end SUBLVL_TEST;


separate( SUBLVL_TEST )
procedure INTERNE is
  IMG	: constant STRING := FEU'IMAGE( ORANGE );			--| le site exact du segfault : 'IMAGE d'un enumere du parent, en initialisation
begin
  CHECK( IMG = "ORANGE", 1 );
  CHECK( FEU'POS( ROUGE ) = 2, 2 );
  CHECK( COMPTE = 41, 3 );						--| lecture montante d'objet du parent
  COMPTE := COMPTE + 1;							--| ecriture montante
end INTERNE;


separate( SUBLVL_TEST )
package body COEUR is

  procedure BATTRE is
    IMG	: constant STRING := FEU'IMAGE( VERT );
  begin
    CHECK( IMG = "VERT", 4 );
    COMPTE := COMPTE + 1;
  end BATTRE;

end COEUR;
