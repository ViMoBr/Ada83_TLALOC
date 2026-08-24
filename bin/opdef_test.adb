with TEXT_IO; use TEXT_IO;

procedure OPDEF_TEST is

  NB_OK	: INTEGER := 0;
  NB_KO	: INTEGER := 0;

  type PAIRE is record
    A	: INTEGER;
    B	: INTEGER;
  end record;

  type DERIV is new INTEGER;

  U	: PAIRE;
  V	: PAIRE;
  W	: PAIRE;
  D1	: DERIV := 6;

  function MK ( A, B : INTEGER ) return PAIRE is
  begin
    return ( A, B );
  end MK;

  function "+" ( X, Y : PAIRE ) return PAIRE is
  begin
    return ( X.A + Y.A, X.B + Y.B );
  end "+";

  function "**" ( X : PAIRE; N : INTEGER ) return PAIRE is
    R	: PAIRE := X;
  begin
    for I in 2 .. N loop
      R := R + X;
    end loop;
    return R;
  end "**";

  function "<" ( X, Y : PAIRE ) return BOOLEAN is
  begin
    return X.A < Y.A;
  end "<";

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

begin
  U := ( 3, 4 ) + ( 10, 20 );						--| "+" utilisateur record
  CHECK( U.A = 13 and U.B = 24, 1 );

  V := ( 1, 2 ) ** 5;							--| "**" utilisateur record x entier : LE motif du spin
  CHECK( V.A = 5 and V.B = 10, 2 );

  CHECK( OPDEF_TEST."<"( ( 1, 9 ), ( 2, 0 ) ), 3 );					--| "<" utilisateur -> BOOLEAN
  CHECK( not OPDEF_TEST."<"( ( 5, 0 ), ( 2, 9 ) ), 4 );

  D1 := D1 + 7;								--| operateurs IMPLICITES du type derive :
  CHECK( INTEGER( D1 ) = 13, 5 );					--| DOIVENT rester en emission predefinie,
  CHECK( D1 * 2 = 26, 6 );						--| avant COMME apres le correctif

  W := MK( 2, 3 ) + MK( 10, 10 );					--| gauche = APPEL : position(expression) = position(MK) -> collision ANON
  CHECK( W.A = 12 and W.B = 13, 7 );

  W := MK( 1, 1 ) ** 4;							--| le motif exact du segfault 0x45825b (fix_pre l.427)
  CHECK( W.A = 4 and W.B = 4, 8 );

  PUT( "RESULTAT :" );
  PUT( INTEGER'IMAGE( NB_OK ) );
  PUT( " OK," );
  PUT( INTEGER'IMAGE( NB_KO ) );
  PUT_LINE( " ECHECS" );
  if NB_KO = 0 then
    PUT_LINE( "OPDEF_TEST PASSE" );
  else
    PUT_LINE( "OPDEF_TEST ECHOUE" );
  end if;

exception
  when others =>
    PUT_LINE( "OPDEF_TEST ECHOUE (EXCEPTION)" );
end OPDEF_TEST;
