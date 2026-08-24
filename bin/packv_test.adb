with TEXT_IO; use TEXT_IO;

procedure PACKV_TEST is

  NB_OK	: INTEGER := 0;
  NB_KO	: INTEGER := 0;

  type UD is range 0 .. 16_383;
  for UD'SIZE use 16;

  type DIGITS_T is array ( 1..6 ) of UD;
  pragma PACK( DIGITS_T );

  type VEC is record
    L	: NATURAL;
    S	: UD;
    D	: DIGITS_T;
  end record;
  pragma PACK( VEC );

  V	: VEC;
  W	: VEC;

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
  V.L := 3;								--| motif SPREAD : ecriture chiffre a chiffre
  V.S := 1;
  for I in 1 .. 6 loop
    V.D( I ) := UD( I * 1000 + I );					--| 1001,2002,...,6006 : chaque case distincte
  end loop;

  CHECK( V.D( 1 ) = 1001 and V.D( 6 ) = 6006, 1 );			--| relecture indexee
  CHECK( V.L = 3 and V.S = 1, 2 );					--| les champs AVANT le tableau intacts

  W := V;								--| copie record entiere (BLKMOV .size)
  CHECK( W.D( 2 ) = 2002 and W.D( 5 ) = 5005, 3 );

  W.D( 4 ) := 4444;							--| ecriture apres copie : pas d'aliasing
  CHECK( V.D( 4 ) = 4004, 4 );

  CHECK( V.D( 1..3 ) = W.D( 1..3 ), 5 );				--| egalite de tranches packees (motif IS_ZERO)
  CHECK( not ( V.D( 3..6 ) = W.D( 3..6 ) ), 6 );

  PUT( "RESULTAT :" );
  PUT( INTEGER'IMAGE( NB_OK ) );
  PUT( " OK," );
  PUT( INTEGER'IMAGE( NB_KO ) );
  PUT_LINE( " ECHECS" );
  if NB_KO = 0 then
    PUT_LINE( "PACKV_TEST PASSE" );
  else
    PUT_LINE( "PACKV_TEST ECHOUE" );
  end if;

exception
  when others =>
    PUT_LINE( "PACKV_TEST ECHOUE (EXCEPTION)" );
end PACKV_TEST;
