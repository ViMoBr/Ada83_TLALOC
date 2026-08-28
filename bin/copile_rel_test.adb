------------------------------------------------------------------------------------------------------------------------
-- COPILE_REL_TEST -- temoin du chantier co-pile, lot 1 (UNLINKR choisi par l'expander)
--
-- Contrat teste : les frames qui ne rendent PAS un tableau liberent leur co-pile a
-- l'epilogue (UNLINKR) ; les fonctions a resultat tableau la gardent (contrat
-- d'evasion, n 147) et leurs evades survivent aux appels interposes.
--
-- Verdict fonctionnel : << RESULTAT : 8 OK, 0 ECHECS >> puis << COPILE_REL_TEST PASSE >>.
-- Mesure associee : /usr/bin/time -v ./copile_rel_test -> RSS max < 100 Mo apres le lot
-- (sous le regime a bosse : plus de 2 Go, sections 1 et 2).
------------------------------------------------------------------------------------------------------------------------

with TEXT_IO; use TEXT_IO;

procedure COPILE_REL_TEST is

  NB_OK		: INTEGER := 0;
  NB_ECHECS	: INTEGER := 0;
  TOTAL		: INTEGER := 0;

  type PAIR is record						-- Ada 83 : declarations de base AVANT les corps
    A, B : INTEGER;
  end record;

  LC		: CHARACTER;
  R6		: INTEGER;
  P5		: PAIR;

  procedure CHECK( OK : BOOLEAN; SECTION, NUMERO : INTEGER ) is
  begin
    if  OK  then
      NB_OK := NB_OK + 1;
    else
      NB_ECHECS := NB_ECHECS + 1;
      PUT_LINE( "* ECHEC section" & INTEGER'IMAGE( SECTION ) & " test" & INTEGER'IMAGE( NUMERO ) );
    end if;
  end CHECK;

  -- Section 1 : procedure a tableau local de taille dynamique (CO_VAR), frame relache.
  procedure FILL( N : INTEGER; LAST_CHAR : out CHARACTER ) is
    S : STRING( 1 .. N );
  begin
    S := ( others => 'x' );
    LAST_CHAR := S( N );
  end FILL;

  -- Section 2 : fonction SCALAIRE qui fabrique des chaines (IMAGE + concat), frame relache.
  function LEN_IMG( N : INTEGER ) return INTEGER is
    T : STRING := INTEGER'IMAGE( N ) & "abc";
  begin
    return T'LENGTH;
  end LEN_IMG;

  -- Section 3 : fonction a resultat STRING (frame GARDE, contrat d'evasion).
  function NAME( I : INTEGER ) return STRING is
  begin
    return "N" & INTEGER'IMAGE( I );
  end NAME;

  -- Procedure interposee qui alloue et rend de la co-pile (UNLINKR) entre la
  -- production d'un evade et sa consommation.
  procedure NOISE is
    S : STRING( 1 .. 500 );
  begin
    S := ( others => 'z' );
  end NOISE;

  -- Consomme son parametre STRING APRES un appel interpose qui relache.
  function AFTER_NOISE( S : STRING ) return BOOLEAN is
  begin
    NOISE;
    NOISE;
    return S = "N 42";
  end AFTER_NOISE;

  -- Section 4 : return depuis un bloc declare dans une fonction STRING
  -- (les blocs traverses par un return doivent GARDER la co-pile).
  function BLK( I : INTEGER ) return STRING is
  begin
    declare
      T : STRING := INTEGER'IMAGE( I );
    begin
      return T & T;
    end;
  end BLK;

  -- Section 5 : fonction RECORD (copie chez l'appelant, frame relache) dont le
  -- corps fabrique des chaines.
  function MK_PAIR( I : INTEGER ) return PAIR is
    T : STRING := INTEGER'IMAGE( I ) & INTEGER'IMAGE( I + 1 );
    P : PAIR;
  begin
    P.A := T'LENGTH;
    P.B := I;
    return P;
  end MK_PAIR;

  -- Section 6 : exit hors d'un bloc declare, puis usage d'une copie faite dans le bloc.
  procedure EXIT_BLOCK( RES : out INTEGER ) is
    KEEP : INTEGER := 0;
  begin
    loop
      declare
        T : STRING := NAME( 7 ) & NAME( 8 );
      begin
        KEEP := T'LENGTH;
        exit;
      end;
    end loop;
    RES := KEEP;
  end EXIT_BLOCK;

begin
  PUT_LINE( "COPILE_REL_TEST -- chantier co-pile lot 1" );

  -- 1. capacite : 2 000 000 appels x 1000 octets = 2 Go sous le regime a bosse
  for I in 1 .. 2_000_000 loop
    FILL( 1000, LC );
  end loop;
  CHECK( LC = 'x', 1, 1 );

  -- 2. capacite : 3 000 000 appels d'une fonction scalaire a temporaires STRING
  TOTAL := 0;
  for I in 1 .. 3_000_000 loop
    TOTAL := TOTAL + LEN_IMG( I );
  end loop;
  CHECK( TOTAL > 3_000_000 * 4, 2, 1 );
  CHECK( LEN_IMG( 5 ) = 5, 2, 2 );					-- " 5abc"

  -- 3. evasion : resultat STRING consomme apres des appels interposes qui relachent
  CHECK( AFTER_NOISE( NAME( 42 ) ), 3, 1 );
  declare
    R : STRING := NAME( 42 );
  begin
    NOISE;
    NOISE;
    CHECK( R = "N 42", 3, 2 );
  end;

  -- 4. return depuis un bloc declare dans une fonction STRING
  CHECK( BLK( 12 ) = " 12 12", 4, 1 );

  -- 5. fonction record a temporaires STRING dans son corps
  P5 := MK_PAIR( 9 );
  CHECK( P5.A = 5 and P5.B = 9, 5, 1 );				-- " 9" & " 10"

  -- 6. exit a travers un bloc
  EXIT_BLOCK( R6 );
  CHECK( R6 = 6, 6, 1 );						-- "N 7" & "N 8"

  PUT_LINE( "RESULTAT :" & INTEGER'IMAGE( NB_OK ) & " OK," & INTEGER'IMAGE( NB_ECHECS ) & " ECHECS" );
  if  NB_ECHECS = 0  then
    PUT_LINE( "COPILE_REL_TEST PASSE" );
  else
    PUT_LINE( "COPILE_REL_TEST ECHOUE" );
  end if;

end COPILE_REL_TEST;
