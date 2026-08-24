with TEXT_IO;			use TEXT_IO;

procedure RETSLICE
is
  OK_COUNT	: NATURAL := 0;
  KO_COUNT	: NATURAL := 0;

  BUF	: STRING( 1..255 );
  LEN	: NATURAL := 0;


  R9	: STRING( 1..9 );

  function TS return STRING
  is
  begin
    return BUF( 1..LEN );				-- la forme exacte de TOKEN_STRING (D-C7a)
  end TS;

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
  PUT_LINE( "=== RETSLICE : fonction ordinaire, retour tranche dynamique ===" );

  BUF( 1..9 ) := "NULL_PROG";
  LEN := 9;

  PUT( "R0 affiche [" );				-- consommation directe (visuelle)
  PUT( TS );
  PUT_LINE( "]  attendu [NULL_PROG]" );

  CHECK( "R1 egalite directe", TS = "NULL_PROG" );

  R9 := TS;						-- affectation depuis le resultat
  CHECK( "R2 affectation", R9 = "NULL_PROG" );

  CHECK( "R3 concat simple", ( "x" & TS ) = "xNULL_PROG" );

  CHECK( "R4 concat double (forme DEBUG_PRINT)",	-- la forme observee tronquee
	 ( "identifier" & "\" & TS ) = "identifier\NULL_PROG" );

  LEN := 2;						-- l'analogue de IS
  BUF( 1..2 ) := "IS";
  CHECK( "R5 longueur 2 directe", TS = "IS" );
  CHECK( "R6 longueur 2 en concat", ( "x" & TS ) = "xIS" );

  LEN := 7;						-- longueur mobile
  BUF( 1..7 ) := "NULL_PR";
  CHECK( "R7 longueur mobile", TS = "NULL_PR" );

  PUT_LINE( "RESULTAT :" & NATURAL'IMAGE( OK_COUNT ) & " OK,"
	  & NATURAL'IMAGE( KO_COUNT ) & " ECHECS" );
  if  KO_COUNT = 0  then
    PUT_LINE( "RETSLICE PASSE" );
  else
    PUT_LINE( "RETSLICE ECHOUE" );
  end if;

end RETSLICE;
