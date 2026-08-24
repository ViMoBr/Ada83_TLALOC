-----------------------------------------------------------------------------------------------------------------------
--
--	N U M A R G _ T E S T   --   temoin : nombre nomme en actuel de parametre (aout 2026)
--
--	Revele par TARGET_CODE.EMITS ( Q64( ENTRY_PT ), ENTRY_PT nombre nomme
--	universel ) : INVERSE_RECURSE_ON_PARAMETERS ne traitait pas
--	DN_NUMBER_ID (demi-bruyant "DEFN non fait"). Le corpus historique ne
--	passait jamais de nombre nomme en actuel (constantes TYPEES partout).
--	Remede : plier a l'usage via CODE_EXP( SM_INIT_EXP ), idiome deja
--	etabli en contexte expression (expressions:450, CODE_USED_OBJECT_ID).
--
--	Verdict attendu : "PASSE numarg_test", aucun ECHEC.
--
-----------------------------------------------------------------------------------------------------------------------

with TEXT_IO;						use TEXT_IO;

procedure		NUMARG_TEST
is

  BIG			: constant	:= 16#400078#;			--| 4_194_424 : nombre nomme universel entier
  K			: constant	:= 5;
  R			: constant	:= 1.5;				--| nombre nomme universel reel

  OK			: BOOLEAN	:= TRUE;
  ACC			: INTEGER	:= 0;

  procedure		CHECK ( COND :BOOLEAN; MSG :STRING )
  is
  begin
    if not COND
    then
      OK := FALSE;
      PUT_LINE( "ECHEC numarg : " & MSG );
    end if;
  end CHECK;

  procedure		TAKE_I ( X :INTEGER )
  is
  begin
    ACC := ACC + X;
  end TAKE_I;

  procedure		TAKE_F ( X :FLOAT )
  is
  begin
    if X > 1.4  and then  X < 1.6
    then
      ACC := ACC + 1;
    end if;
  end TAKE_F;

begin

  --  1 : nombre nomme entier en actuel (le payeur : Q64( ENTRY_PT ))
  TAKE_I( BIG );
  CHECK( ACC = 16#400078#, "nombre nomme entier en actuel" );

  --  2 : dans une boucle (contexte du payeur : appels en serie)
  ACC := 0;
  for I in 1 .. 3
  loop
    TAKE_I( K );
  end loop;
  CHECK( ACC = 15, "nombre nomme en actuel, corps de boucle" );

  --  3 : expression sur nombre nomme (deja couvert par expressions:450,
  --      controle de non-regression du pliage)
  ACC := 0;
  TAKE_I( K + 1 );
  CHECK( ACC = 6, "expression sur nombre nomme en actuel" );

  --  4 : nombre nomme reel vers formel FLOAT
  ACC := 0;
  TAKE_F( R );
  CHECK( ACC = 1, "nombre nomme reel en actuel" );

  if OK
  then
    PUT_LINE( "PASSE numarg_test" );
  end if;

end	NUMARG_TEST;
