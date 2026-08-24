with TEXT_IO;			use TEXT_IO;

procedure LITAFF1
is
  OK_COUNT	: NATURAL := 0;
  KO_COUNT	: NATURAL := 0;

  W9	: STRING( 1..9 );
  B12	: STRING( 1..12 );

  procedure CHECK( LABEL :STRING; COND :BOOLEAN )
  is
  begin
    if  COND  then
      OK_COUNT := OK_COUNT + 1;
    else
      KO_COUNT := KO_COUNT + 1;
      PUT_LINE( "ECHEC " & LABEL );
    end if;
  end CHECK;

begin
  PUT_LINE( "=== LITAFF1 : litteral de chaine en instruction d'affectation ===" );

  W9 := "NULL_PROG";					-- litteral -> objet entier (instruction)
  CHECK( "L1 objet := litteral", W9 = "NULL_PROG" );

  B12 := "------------";				-- litteral -> objet entier, autre taille
  B12( 1..3 ) := "xyz";				-- litteral -> tranche en tete
  CHECK( "L2 tranche tete := litteral", B12 = "xyz---------" );

  B12( 4..6 ) := "abc";				-- litteral -> tranche DECALEE (offset destination)
  CHECK( "L3 tranche decalee := litteral", B12 = "xyzabc------" );

  PUT_LINE( "RESULTAT :" & NATURAL'IMAGE( OK_COUNT ) & " OK,"
	  & NATURAL'IMAGE( KO_COUNT ) & " ECHECS" );
  if  KO_COUNT = 0  then
    PUT_LINE( "LITAFF1 PASSE" );
  else
    PUT_LINE( "LITAFF1 ECHOUE" );
  end if;

end LITAFF1;
