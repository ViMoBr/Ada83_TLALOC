-----------------------------------------------------------------------------------------------------------------------
--
--	L I M A G E _ T E S T   --   temoin : LONG_INTEGER'IMAGE tronque a 32 bits (aout 2026)
--
--	Revele par la SORTIE de fold64_test v2 : les CHECK passent (valeurs
--	64 bits justes, pliage statique LONG compris) mais les affichages
--	sont faux avec la signature exacte d'une troncature 32 bits :
--	  2**34            imprime  0        (2**34 mod 2**32)
--	  LONG_INTEGER'LAST imprime -1        ((2**63-1) mod 2**32 = -1 signe)
--	L'attribut IMAGE de LONG_INTEGER passe donc par un chemin INTEGER
--	(expander ou RTS). Troisieme membre de la famille des troncatures
--	silencieuses (avec l'enroulement statique de foldrej_test — et
--	l'arithmetique, ELLE, est saine).
--	Ce temoin s'auto-juge sur les CHAINES produites, pas sur les valeurs.
--
--	Verdict attendu apres correction : "PASSE limage_test".
--
-----------------------------------------------------------------------------------------------------------------------

with TEXT_IO;						use TEXT_IO;

procedure		LIMAGE_TEST
is

  V			: LONG_INTEGER	:= 1024;
  R			: LONG_INTEGER;
  OK			: BOOLEAN	:= TRUE;

  procedure		CHECK ( COND :BOOLEAN; MSG :STRING )
  is
  begin
    if not COND
    then
      OK := FALSE;
      PUT_LINE( "ECHEC limage : " & MSG );
    end if;
  end CHECK;

begin

  R := 16 * V * V * V;							--| 17_179_869_184, calcule (arithmetique saine)

  CHECK( LONG_INTEGER'IMAGE( R ) = " 17179869184",
	 "IMAGE d'une valeur > 2**32" );
  CHECK( LONG_INTEGER'IMAGE( -R ) = "-17179869184",
	 "IMAGE d'une valeur negative < -2**32" );
  CHECK( LONG_INTEGER'IMAGE( LONG_INTEGER'LAST ) = " 9223372036854775807",
	 "IMAGE de LONG_INTEGER'LAST" );
  CHECK( LONG_INTEGER'IMAGE( 42 ) = " 42",
	 "IMAGE d'une petite valeur (non-regression)" );

  if OK
  then
    PUT_LINE( "PASSE limage_test" );
  end if;

end	LIMAGE_TEST;
