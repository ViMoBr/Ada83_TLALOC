-----------------------------------------------------------------------------------------------------------------------
--
--	F O L D 6 4 _ T E S T   --   v2 : pliage statique en LONG_INTEGER (aout 2026)
--
--	REMPLACE la v1, fondee sur une hypothese FAUSSE (INTEGER 64 bits).
--	STANDARD TLALOC : INTEGER 32 bits, LONG_INTEGER 64 bits.
--	Le premier byte-diff TC-04 a revele "constant INTEGER := 2**34"
--	ENROULE a 0 au lieu d'etre REFUSE (LRM 4.9 : statique hors gamme =
--	illegal) — c'est le temoin negatif foldrej_test qui porte ce cas.
--	ICI : le pliage statique en LONG_INTEGER (type correct) est-il juste ?
--	  S : constante typee LONG_INTEGER, pliage statique ;
--	  N : nombre nomme universel, plie a l'usage en contexte LONG ;
--	  P : exponentiation statique 2**34 en contexte LONG ;
--	  R : reference calculee A L'EXECUTION (variable LONG, imul qword).
--	Si S/N/P echouent avec R juste : le plieur a un probleme de largeur
--	interne meme dans le bon type -> les contournements "KILO" restent.
--	Si tout passe : les contournements peuvent retomber en constantes.
--
--	Verdict attendu (plieur sain sur LONG) : "PASSE fold64_test".
--
-----------------------------------------------------------------------------------------------------------------------

with TEXT_IO;						use TEXT_IO;

procedure		FOLD64_TEST
is

  S			: constant LONG_INTEGER	:= 16 * 1024 * 1024 * 1024;
  N			: constant		:= 16 * 1024 * 1024 * 1024;
  V			: LONG_INTEGER		:= 1024;
  R			: LONG_INTEGER;
  OK			: BOOLEAN		:= TRUE;

  procedure		CHECK ( COND :BOOLEAN; MSG :STRING )
  is
  begin
    if not COND
    then
      OK := FALSE;
      PUT_LINE( "ECHEC fold64 : " & MSG );
    end if;
  end CHECK;

begin

  R := 16 * V * V * V;							--| reference : execution (imul qword)
  PUT_LINE( "R (execution)       =" & LONG_INTEGER'IMAGE( R ) );
  PUT_LINE( "S (pliage LONG)     =" & LONG_INTEGER'IMAGE( S ) );
  PUT_LINE( "N (nombre nomme)    =" & LONG_INTEGER'IMAGE( N ) );
  PUT_LINE( "LONG_INTEGER'LAST   =" & LONG_INTEGER'IMAGE( LONG_INTEGER'LAST ) );

  CHECK( R = 17_179_869_184,	"arithmetique LONG_INTEGER a l'execution" );
  CHECK( S = R,			"pliage statique d'une constante LONG_INTEGER" );
  CHECK( N = R,			"nombre nomme universel en contexte LONG" );
  CHECK( 2 ** 34 = R,		"exponentiation statique en contexte LONG" );
  CHECK( S / 1024 / 1024 = 16 * 1024,
				"division sur la valeur pliee" );

  if OK
  then
    PUT_LINE( "PASSE fold64_test" );
  end if;

end	FOLD64_TEST;
