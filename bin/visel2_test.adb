--| VISEL2_TEST — discriminateur bibliotheque / coeur de resolution.
--|
--| Jumeau de VISEL_TEST mais TOUT est declare LOCALEMENT : aucun des
--| prefixes ne passe par une unite relue de la bibliotheque (seul
--| TEXT_IO est with'e, et ses appels ne selectionnent aucun littéral).
--|
--| ORACLE (T1) : compilation muette, execution :
--|     RESULTAT :  6 OK,   0 ECHECS
--|     VISEL2_TEST PASSE
--|
--| LECTURE DU VERDICT T2 :
--|   N1..N3 en faute  => le bug est dans la recherche par selection
--|                       elle-meme (vis_util / expreso) ;
--|   N1..N3 propres   => la recherche est saine sur symboles locaux,
--|                       le bug est dans la RELECTURE bibliotheque des
--|                       littéraux (lib_phase) — les symboles relus
--|                       arrivent mutiles.
--|
--|   N1  litteral selecte, paquetage IMBRIQUE local
--|   N2  litteral selecte via renommage d'un paquetage local
--|   N3  litteral selecte via instance LOCALE d'un generique LOCAL
--|   N4  controles : declaration non littérale, memes prefixes

with TEXT_IO;	use TEXT_IO;

procedure VISEL2_TEST is

  NB_OK	: INTEGER := 0;
  NB_KO	: INTEGER := 0;

  package NP is					--| paquetage imbrique, tout local
    type COLOR is ( RED, GREEN, BLUE );
    CONST : constant INTEGER := 42;
  end NP;

  package RN	renames NP;			--| renommage local de local

  generic					--| generique local
    type ELEM is private;
  package NG is
    type MODE is ( M_IN, M_OUT );
    NIL : constant INTEGER := 7;
  end NG;

  package LINST	is new NG( INTEGER );		--| instance locale de local

  C	: NP.COLOR;
  M	: LINST.MODE;

  procedure ASSERT( OK : BOOLEAN; MSG : STRING ) is
  begin
    if  OK  then
      NB_OK := NB_OK + 1;
    else
      NB_KO := NB_KO + 1;
      PUT_LINE( "ECHEC : " & MSG );
    end if;
  end ASSERT;

begin

  --| N1 : littéral selecte, paquetage imbrique local
  C := NP.RED;
  ASSERT( NP.COLOR'POS( C ) = 0, "N1 NP.RED" );

  --| N2 : littéral selecte via renommage local
  C := RN.GREEN;
  ASSERT( NP.COLOR'POS( C ) = 1, "N2 RN.GREEN" );

  --| N3 : littéral selecte via instance locale d'un generique local
  M := LINST.M_OUT;
  ASSERT( LINST.MODE'POS( M ) = 1, "N3 LINST.M_OUT" );

  --| N4 : controles non littéraux, memes trois prefixes
  ASSERT( NP.CONST    = 42, "N4 NP.CONST" );
  ASSERT( RN.CONST    = 42, "N4 RN.CONST" );
  ASSERT( LINST.NIL   =  7, "N4 LINST.NIL" );

  PUT_LINE( "RESULTAT : " & INTEGER'IMAGE( NB_OK ) & " OK, "
	& INTEGER'IMAGE( NB_KO ) & " ECHECS" );
  if  NB_KO = 0  then
    PUT_LINE( "VISEL2_TEST PASSE" );
  else
    PUT_LINE( "VISEL2_TEST ECHOUE" );
  end if;

end VISEL2_TEST;
