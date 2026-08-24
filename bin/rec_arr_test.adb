------------------------------------------------------------------------------------------------------------------------
-- REC_ARR_TEST -- temoin auto-jugeant, 40 assertions (format CHECK / RESULTAT / verdict greppable).
-- Surface : composants tableau anonymes de record (commits USEINFO + CODE_INDEXED) et concatenation (symptome ././).
-- HARNAIS SANS "&" : la concatenation est SOUS TEST, CHECK et le verdict n'en dependent pas (sinon le juge ment).
-- Temoin negatif (piege n 67) : DEUX executions consecutives, sorties strictement identiques.
------------------------------------------------------------------------------------------------------------------------
with TEXT_IO;	use TEXT_IO;
with REC_PACK;	use REC_PACK;

procedure REC_ARR_TEST is

  package IIO is new INTEGER_IO( INTEGER );

  NB_OK	: NATURAL := 0;
  NB_KO	: NATURAL := 0;

		-----
  procedure	CHECK	( OK : BOOLEAN;  SECTION : NATURAL;  NUM : NATURAL )
  is		-----
  begin
    if OK then
      NB_OK := NB_OK + 1;
    else
      NB_KO := NB_KO + 1;
      PUT( "* ECHEC section" );
      IIO.PUT( SECTION, 3 );
      PUT( " test" );
      IIO.PUT( NUM, 4 );
      NEW_LINE;
    end if;
  end	CHECK;
	-----

		------
  function	LEN_OF	( S : STRING )	return NATURAL
  is		------
  begin
    return S'LENGTH;
  end	LEN_OF;
	------

		----
  function	LEN2	( S : STRING )	return NATURAL
  is		----
  -- Transfert FORMEL -> FORMEL du doublet (miroir TEXT_IO.OPEN -> OPEN_SYSTEM_CALL).
  begin
    return LEN_OF( S );
  end	LEN2;
	----

		-------
  function	CHAR_AT	( S : STRING;  I : POSITIVE )	return CHARACTER
  is		-------
  begin
    return S( I );
  end	CHAR_AT;
	-------

		--
  function	EQ	( X, Y : STRING )	return BOOLEAN
  is		--
  begin
    if X'LENGTH /= Y'LENGTH then
      return FALSE;
    end if;
    for I in 1 .. X'LENGTH loop
      if X( X'FIRST + I - 1 ) /= Y( Y'FIRST + I - 1 ) then
        return FALSE;
      end if;
    end loop;
    return TRUE;
  end	EQ;
	--

		---
  function	NOM	return STRING
  is		---
  begin
    return "null_prog.txt";
  end	NOM;
	---

		---------
  procedure	S2_NICHEE
  is		---------
  -- Record + composant anonyme declares DANS un sous-programme : niveau > 0.
  -- Juge du CD_LEVEL pose par le producteur et du TYPE_LVL lu par CODE_INDEXED.
    type LOCREC	is record
		    N	: NATURAL;
		    S	: STRING( 1 .. 5 );
		  end record;
    V	: LOCREC;
  begin
    V.N := 7;
    V.S( 1 ) := 'X';
    V.S( 5 ) := 'Y';
    CHECK( V.S( 1 ) = 'X',	2,  7 );
    CHECK( V.S( 5 ) = 'Y',	2,  8 );
    CHECK( V.N = 7,		2,  9 );
  end	S2_NICHEE;
	---------

begin
  PUT_LINE( "=== S1. composant STRING anonyme inter-unites (LIGNE) ===" );
  SET( GLOB, "ABC" );
  CHECK( GET( GLOB, 1 ) = 'A',	1,  1 );
  CHECK( GET( GLOB, 3 ) = 'C',	1,  2 );
  CHECK( GLOB.LEN = 3,		1,  3 );
  CHECK( GLOB.BDY( 2 ) = 'B',	1,  4 );			-- lecture cote MAIN (unite tierce)
  GLOB.BDY( 4 ) := 'D';						-- ecriture cote MAIN
  CHECK( GET( GLOB, 4 ) = 'D',	1,  5 );
  POSE( GLOB, 5, 'E' );						-- ecriture cote CORPS
  CHECK( GLOB.BDY( 5 ) = 'E',	1,  6 );

  PUT_LINE( "=== S2. record local d'un sous-programme (niveau > 0) ===" );
  S2_NICHEE;

  PUT_LINE( "=== S3. deux sous-types anonymes du meme type de base ===" );
  declare
    P2	: PAIRE;
  begin
    P2.A( 1 ) := 'A';  P2.A( 2 ) := 'A';  P2.A( 3 ) := 'A';  P2.A( 4 ) := 'A';
    P2.B( 1 ) := 'B';  P2.B( 2 ) := 'B';  P2.B( 3 ) := 'B';
    P2.B( 4 ) := 'B';  P2.B( 5 ) := 'B';  P2.B( 6 ) := 'B';
    CHECK( P2.A( 1 ) = 'A',	3, 10 );
    CHECK( P2.A( 4 ) = 'A',	3, 11 );
    CHECK( P2.B( 1 ) = 'B',	3, 12 );
    CHECK( P2.B( 6 ) = 'B',	3, 13 );
    CHECK( P2.A( 2 ) = 'A',	3, 14 );			-- A intact apres les ecritures de B (bornes croisees)
    CHECK( GLOB.BDY( 5 ) = 'E',	3, 15 );			-- pas de contamination inter-records
  end;

  PUT_LINE( "=== S4. composants de type/sous-type NOMME (non-regression) ===" );
  declare
    RS	: RSUB;
    RV	: RVEC;
  begin
    RS.C( 1 ) := 'L';  RS.C( 2 ) := 'M';  RS.C( 3 ) := 'N';  RS.C( 4 ) := 'O';
    RV.V( 1 ) := 11;   RV.V( 2 ) := 22;   RV.V( 3 ) := 33;
    CHECK( RS.C( 2 ) = 'M',	4, 16 );
    CHECK( RV.V( 3 ) = 33,	4, 17 );
    CHECK( RV.V( 1 ) = 11,	4, 18 );
  end;

  PUT_LINE( "=== S5. concatenation (symptome ././ ) ===" );
  declare
    P4	: STRING( 1 .. 4 );
    CST	: constant STRING := "null_prog.txt";
  begin
    P4( 1 ) := '.';  P4( 2 ) := '/';  P4( 3 ) := '.';  P4( 4 ) := '/';

    CHECK( LEN_OF( P4 & CST ) = 17,				5, 19 );	-- MIROIR EXACT de OPEN( .., PATH & NOM ) : "&" en actual
    CHECK( CHAR_AT( P4 & CST, 5 ) = 'n',			5, 20 );
    CHECK( CHAR_AT( P4 & CST, 17 ) = 't',			5, 21 );

    declare
      R	: constant STRING := P4 & CST;				-- objet non contraint initialise par "&" (bornes deduites)
    begin
      CHECK( EQ( R, "././null_prog.txt" ),			5, 22 );
      CHECK( LEN_OF( R ) = 17,				5, 23 );
    end;

    CHECK( LEN_OF( CST & P4 ) = 17,				5, 24 );	-- ordre inverse
    CHECK( CHAR_AT( CST & P4, 14 ) = '.',			5, 25 );
    CHECK( LEN_OF( P4 & "x" ) = 5,				5, 26 );	-- var & litteral
    CHECK( LEN_OF( "x" & P4 ) = 5,				5, 27 );	-- litteral & var
    CHECK( LEN_OF( P4( 1 .. 2 ) & CST( 1 .. 4 ) ) = 6,		5, 28 );	-- tranche & tranche
    CHECK( CHAR_AT( P4( 1 .. 2 ) & CST( 1 .. 4 ), 3 ) = 'n',	5, 29 );
    CHECK( LEN_OF( GLOB.BDY & "Z" ) = MAX + 1,			5, 30 );	-- COMPOSANT de record en operande
    CHECK( CHAR_AT( GLOB.BDY & "Z", MAX + 1 ) = 'Z',		5, 31 );
    CHECK( LEN_OF( P4 & NOM ) = 17,				5, 32 );	-- operande retour de fonction STRING
    CHECK( CHAR_AT( P4 & NOM, 6 ) = 'u',			5, 33 );
    CHECK( LEN_OF( 'a' & P4 ) = 5,				5, 34 );	-- composant scalaire & tableau
    CHECK( LEN_OF( P4 & 'a' ) = 5,				5, 35 );	-- tableau & composant scalaire
  end;

  -- SENTINELLE_S6_DEBUT ------------------------------------------------------------------------------------------
  -- S6/S7 : sentinelles des trous EN VIGILANCE (tranche de composant, attributs sur prefixe selectionne).
  -- Leur rouge LOCALISE un trou connu, il n'incrimine PAS les commits 1-2. Si l'EXPANSION leve un TROU ici,
  -- commenter du marqueur DEBUT au marqueur FIN et consigner : le trou est alors localise des l'expansion.
  PUT_LINE( "=== S6. tranche de composant (sentinelle) ===" );
  declare
    SL	: LIGNE;
  begin
    SL.BDY( 1 ) := 'A';  SL.BDY( 2 ) := 'B';  SL.BDY( 3 ) := 'C';  SL.BDY( 4 ) := 'D';
    SL.BDY( 5 ) := 'E';  SL.BDY( 6 ) := 'F';  SL.BDY( 7 ) := 'G';  SL.BDY( 8 ) := 'H';
    CHECK( LEN_OF( SL.BDY( 2 .. 4 ) ) = 3,			6, 36 );
    CHECK( EQ( SL.BDY( 2 .. 4 ), "BCD" ),			6, 37 );

    PUT_LINE( "=== S7. attributs sur composant (sentinelle) ===" );
    CHECK( SL.BDY'FIRST = 1,				7, 38 );
    CHECK( SL.BDY'LAST = MAX,				7, 39 );
    CHECK( SL.BDY'LENGTH = MAX,				7, 40 );
  end;
  -- SENTINELLE_S6_FIN --------------------------------------------------------------------------------------------

  PUT_LINE( "=== S8. formes ADA_COMP : package vars, formels, bornes dynamiques, OPEN reel ===" );
  declare
    F	: FILE_TYPE;
    BUF	: STRING( 1 .. 32 );
    L	: NATURAL;
    NL	: NATURAL;
    SL8	: LIGNE;
  begin
    PATHV( 1 ) := '.';  PATHV( 2 ) := '/';  PATHV( 3 ) := '.';  PATHV( 4 ) := '/';
    for I in 1 .. 16 loop
      NOMV( I ) := 'n';
    end loop;
    NOMV( 1 ) := 't';  NOMV( 2 ) := 'm';  NOMV( 3 ) := 'p';  NOMV( 4 ) := '1';
    NL := 4;

    CHECK( LEN_OF( PATHV & NOMV ) = 20,				8, 41 );	-- variables de PACKAGE (inter-unites)
    CHECK( LEN2( PATHV & NOMV ) = 20,				8, 42 );	-- formel -> formel
    CHECK( LEN_OF( PATHV & NOMV( 1 .. NL ) ) = 8,		8, 43 );	-- tranche a borne DYNAMIQUE (var package)
    CHECK( CHAR_AT( PATHV & NOMV( 1 .. NL ), 5 ) = 't',		8, 44 );

    SET( SL8, "tmp2" );
    CHECK( LEN_OF( PATHV & SL8.BDY( 1 .. SL8.LEN ) ) = 8,	8, 45 );	-- tranche DYNAMIQUE de COMPOSANT (motif lexeur)
    CHECK( CHAR_AT( PATHV & SL8.BDY( 1 .. SL8.LEN ), 8 ) = '2',	8, 46 );

    CREATE( F, OUT_FILE, PATHV & NOMV( 1 .. NL ) );				-- "././tmp1" -- syscall REEL, nom concatene
    PUT_LINE( F, "TEMOIN" );
    CLOSE( F );
    OPEN( F, IN_FILE, PATHV & NOMV( 1 .. NL ) );
    GET_LINE( F, BUF, L );
    CLOSE( F );
    CHECK( L = 6,						8, 47 );
    CHECK( BUF( 1 ) = 'T',					8, 48 );

    CREATE( F, OUT_FILE, PATHV & SL8.BDY( 1 .. SL8.LEN ) );			-- "././tmp2" -- nom = tranche de composant
    PUT_LINE( F, "JUGE" );
    CLOSE( F );
    OPEN( F, IN_FILE, PATHV & SL8.BDY( 1 .. SL8.LEN ) );
    GET_LINE( F, BUF, L );
    CLOSE( F );
    CHECK( L = 4,						8, 49 );
    CHECK( BUF( 4 ) = 'E',					8, 50 );

    PUT_LINE( "=== S9. objet non contraint initialise par tranche (forme NOM_TEXTE) ===" );
    declare
      NT	: constant STRING := NOMV( 1 .. 5 );			-- constant STRING := <tranche> : la forme du bug
    begin
      CHECK( LEN_OF( NT ) = 5,				9, 51 );
      CHECK( LEN_OF( PATHV & NT ) = 9,			9, 52 );	-- MIROIR EXACT de PATH_TEXTE & NOM_TEXTE
      CHECK( CHAR_AT( PATHV & NT, 5 ) = 't',		9, 53 );
    end;
  end;

  NEW_LINE;
  PUT( "RESULTAT : " );
  IIO.PUT( NB_OK, 3 );
  PUT( " OK, " );
  IIO.PUT( NB_KO, 3 );
  PUT_LINE( " ECHECS" );
  if NB_KO = 0 then
    PUT_LINE( "REC_ARR_TEST PASSE" );
  else
    PUT_LINE( "REC_ARR_TEST ECHOUE" );
  end if;

end REC_ARR_TEST;
