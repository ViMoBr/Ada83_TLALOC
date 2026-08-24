with TEXT_IO;			use TEXT_IO;
with UNCHECKED_CONVERSION;

procedure SLCONV1
is
  OK_COUNT	: NATURAL	:= 0;
  KO_COUNT	: NATURAL	:= 0;

  BIG	: STRING( 1..12 )	:= "ABCDEFGHIJKL";

  subtype MID4	is STRING( 5..8 );
  subtype CHN4	is STRING( 1..4 );

  function TO_CHN4	is new UNCHECKED_CONVERSION( MID4, CHN4 );

  R	: CHN4;

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
  PUT_LINE( "=== SLCONV1 : tranche en valeur (conversion + UC) ===" );

  R := TO_CHN4( MID4( BIG( 5..8 ) ) );				-- le chemin du segfault 0x46ff17
  CHECK( "S1 UC( conversion( tranche ) )", R = "EFGH" );

  R := BIG( 9..12 );						-- non-regression @data+LEN direct (CODE_ASSIGN, TRUE explicite)
  CHECK( "S2 affectation source tranche", R = "IJKL" );

  CHECK( "S3 UC en operande d'egalite", TO_CHN4( MID4( BIG( 1..4 ) ) ) = "ABCD" );

  PUT_LINE( "RESULTAT :" & NATURAL'IMAGE( OK_COUNT ) & " OK,"
	  & NATURAL'IMAGE( KO_COUNT ) & " ECHECS" );
  if  KO_COUNT = 0  then
    PUT_LINE( "SLCONV1 PASSE" );
  else
    PUT_LINE( "SLCONV1 ECHOUE" );
  end if;

end SLCONV1;
