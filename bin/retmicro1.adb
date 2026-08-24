with TEXT_IO;			use TEXT_IO;

procedure RETMICRO1
is
  BUF		: STRING( 1..255 );
  LEN		: NATURAL := 0;

  R9		: STRING( 1..9 );
  EXPECTED	: constant STRING( 1..9 ) := "NULL_PROG";
  N		: NATURAL;

  function TS return STRING
  is
  begin
    return BUF( 1..LEN );
  end TS;

begin
  BUF( 1..9 ) := "NULL_PROG";
  LEN := 9;

  PUT( "M1 brut    [" );
  PUT( TS );						-- consommation la plus directe
  PUT_LINE( "]" );

  R9 := TS;						-- affectation depuis le resultat
  PUT( "M2 affecte [" );
  PUT( R9 );
  PUT_LINE( "]" );

  if  TS = "NULL_PROG"  then				-- l'egalite de R1, jugee sans CHECK
    PUT_LINE( "M3 egalite VRAI" );
  else
    PUT_LINE( "M3 egalite FAUX" );
  end if;

  N := 0;						-- octets reellement copies, sans doublet
  for I in 1..9 loop
    if  R9( I ) = EXPECTED( I )  then
      N := N + 1;
    end if;
  end loop;
  PUT( "M4 octets egaux :" );
  PUT( NATURAL'IMAGE( N ) );
  NEW_LINE;

  PUT_LINE( "RETMICRO1 FIN" );
end RETMICRO1;
