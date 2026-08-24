-----------------------------------------------------------------------------------------------------------------------
--
--	I N D A R G _ T E S T   --   temoin de la dette n 112, volet INDARG (aout 2026)
--
--	Actuels INDEXES composites en mode out / in out : jumeaux des selectes
--	(SELARG, vague 2). Reveles par TARGET_CODE.LEX :
--	    OPEN( FILES( FTOP ), IN_FILE, ... )
--	(composant indexe d'un tableau de FILE_TYPE, record limite prive, en
--	in out). Remede : WRAP_COMPOSITE_ACTUAL_DOUBLET apres l'adresse —
--	l'@element nue violait la frontiere doublet des formels composites.
--	Le scalaire indexe out/in-out (adresse nue) est le COMPORTEMENT
--	HISTORIQUE, controle ici pour non-regression (l'enveloppe est no-op).
--
--	Verdict attendu : "PASSE indarg_test", aucun ECHEC.
--
-----------------------------------------------------------------------------------------------------------------------

with TEXT_IO;						use TEXT_IO;

procedure		INDARG_TEST
is

  type REC		is
    record
      A			: INTEGER	:= 0;
      B			: INTEGER	:= 0;
    end record;

  type ARR5		is array ( 1 .. 5 ) of INTEGER;

  RTAB			: array ( 1 .. 3 ) of REC;
  ATAB			: array ( 1 .. 3 ) of ARR5;
  ITAB			: array ( 1 .. 3 ) of INTEGER	:= ( others => 0 );
  FILES			: array ( 1 .. 2 ) of FILE_TYPE;

  K			: INTEGER	:= 2;
  OK			: BOOLEAN	:= TRUE;
  BUF			: STRING( 1 .. 40 );
  LEN			: NATURAL;

  procedure		BUMP_R ( X :in out REC )
  is
  begin
    X.A := X.A + 1;
    X.B := 7;
  end BUMP_R;

  procedure		FILL_R ( X :out REC )
  is
  begin
    X.A := 5;
    X.B := 6;
  end FILL_R;

  procedure		BUMP_A ( V :in out ARR5 )
  is
  begin
    V( 3 ) := V( 3 ) + 10;
  end BUMP_A;

  procedure		SET_I ( N :out INTEGER )
  is
  begin
    N := 42;
  end SET_I;

  procedure		CHECK ( COND :BOOLEAN; MSG :STRING )
  is
  begin
    if not COND
    then
      OK := FALSE;
      PUT_LINE( "ECHEC indarg : " & MSG );
    end if;
  end CHECK;

begin

  --  1 : record indexe, in out (variable d'indice)
  RTAB( K ).A := 1;
  BUMP_R( RTAB( K ) );
  CHECK( RTAB( 2 ).A = 2  and then  RTAB( 2 ).B = 7, "record indexe in out" );

  --  2 : record indexe, out (indice litteral)
  FILL_R( RTAB( 3 ) );
  CHECK( RTAB( 3 ).A = 5  and then  RTAB( 3 ).B = 6, "record indexe out" );

  --  3 : tableau indexe, in out
  ATAB( 1 )( 3 ) := 5;
  BUMP_A( ATAB( 1 ) );
  CHECK( ATAB( 1 )( 3 ) = 15, "tableau indexe in out" );

  --  4 : controle historique — scalaire indexe out (adresse nue, enveloppe no-op)
  SET_I( ITAB( K ) );
  CHECK( ITAB( 2 ) = 42  and then  ITAB( 1 ) = 0  and then  ITAB( 3 ) = 0,
	 "scalaire indexe out (comportement historique)" );

  --  5 : le payeur reel — FILE_TYPE (record limite prive) indexe, in out,
  --      a travers CREATE / PUT_LINE / CLOSE / OPEN / GET_LINE / DELETE
  CREATE( FILES( K ), OUT_FILE, "INDARG_TMP.TXT" );
  PUT_LINE( FILES( K ), "doublet" );
  CLOSE( FILES( K ) );
  OPEN( FILES( K ), IN_FILE, "INDARG_TMP.TXT" );
  GET_LINE( FILES( K ), BUF, LEN );
  CHECK( LEN = 7  and then  BUF( 1 .. 7 ) = "doublet", "FILE_TYPE indexe (OPEN/GET_LINE)" );
  DELETE( FILES( K ) );

  if OK
  then
    PUT_LINE( "PASSE indarg_test" );
  end if;

end	INDARG_TEST;
