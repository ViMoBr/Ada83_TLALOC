package RETPKG is

  procedure SETB	( S :STRING );
  function  TS		return STRING;
  procedure STORE	( S :STRING );			-- l'analogue de STORE_SYM
  function  STORED_LEN	return NATURAL;
  function  STORED_EQ	( S :STRING ) return BOOLEAN;	-- resultat interne vs formel

end RETPKG;


package body RETPKG is

  BUF	: STRING( 1..255 );
  LEN	: NATURAL := 0;

  SBUF	: STRING( 1..255 );
  SLEN	: NATURAL := 0;

  procedure SETB( S :STRING )
  is
  begin
    BUF( 1..S'LENGTH ) := S;
    LEN := S'LENGTH;
  end SETB;

  function TS return STRING
  is
  begin
    return BUF( 1..LEN );				-- la forme exacte de TOKEN_STRING
  end TS;

  procedure STORE( S :STRING )
  is
  begin
    SBUF( 1..S'LENGTH ) := S;
    SLEN := S'LENGTH;
  end STORE;

  function STORED_LEN return NATURAL
  is
  begin
    return SLEN;
  end STORED_LEN;

  function STORED_EQ( S :STRING ) return BOOLEAN
  is
  begin
    return SBUF( 1..SLEN ) = S;			-- tranche interne vs FORMEL (motif HASH)
  end STORED_EQ;

end RETPKG;


with TEXT_IO;			use TEXT_IO;
with RETPKG;

procedure RETPKG1
is
  OK_COUNT	: NATURAL := 0;
  KO_COUNT	: NATURAL := 0;

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
  PUT_LINE( "=== RETPKG1 : retour tranche dynamique, niveau paquetage ===" );

  RETPKG.SETB( "NULL_PROG" );

  PUT( "P1 brut    [" );				-- consommation directe inter-unite
  PUT( RETPKG.TS );
  PUT_LINE( "]  attendu [NULL_PROG]" );

  CHECK( "P2 egalite directe", RETPKG.TS = "NULL_PROG" );

  CHECK( "P3 concat double (forme DEBUG_PRINT)",	-- la forme observee tronquee
	 ( "identifier" & "\" & RETPKG.TS ) = "identifier\NULL_PROG" );

  RETPKG.STORE( RETPKG.TS );				-- l'analogue de STORE_SYM( TOKEN_STRING )
  CHECK( "P4 longueur stockee", RETPKG.STORED_LEN = 9 );
  CHECK( "P5 contenu stocke",   RETPKG.STORED_EQ( "NULL_PROG" ) );

  RETPKG.SETB( "IS" );					-- l'analogue du token is
  CHECK( "P6 longueur 2 en concat", ( "x" & RETPKG.TS ) = "xIS" );

  PUT_LINE( "RESULTAT :" & NATURAL'IMAGE( OK_COUNT ) & " OK,"
	  & NATURAL'IMAGE( KO_COUNT ) & " ECHECS" );
  if  KO_COUNT = 0  then
    PUT_LINE( "RETPKG1 PASSE" );
  else
    PUT_LINE( "RETPKG1 ECHOUE" );
  end if;

end RETPKG1;
