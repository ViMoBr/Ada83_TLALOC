-----------------------------------------------------------------------------------------------------------------------
--
--	T R U N C _ T E S T   --   temoin : CREATE sur fichier existant doit TRONQUER (aout 2026)
--
--	Revele par le byte-diff TC-05 : TARGET_CODE emettait 330 octets
--	exacts, mais le fichier en gardait 375 — la queue de l'execution
--	precedente survivait. Cause : SYS_FILE_CREATE ouvre avec O_CREAT
--	sans O_TRUNC (commentaire du codi) ; un CREATE Ada par-dessus un
--	fichier plus long laisse l'ancienne fin. Affecte tout programme qui
--	regenere un fichier plus court (les FINC de developpement compris).
--	Remede : ajouter O_TRUNC (16#200#) aux flags de creation (RTS
--	SEQUENTIAL_IO / TEXT_IO ou constante passee a SYS_FILE_CREATE).
--
--	Verdict attendu apres correction : "PASSE trunc_test".
--
-----------------------------------------------------------------------------------------------------------------------

with TEXT_IO;						use TEXT_IO;

procedure		TRUNC_TEST
is

  F			: FILE_TYPE;
  BUF			: STRING( 1 .. 80 );
  LEN			: NATURAL;
  OK			: BOOLEAN	:= TRUE;
  LINES			: NATURAL	:= 0;

  procedure		CHECK ( COND :BOOLEAN; MSG :STRING )
  is
  begin
    if not COND
    then
      OK := FALSE;
      PUT_LINE( "ECHEC trunc : " & MSG );
    end if;
  end CHECK;

begin

  --  1 : ecrire un fichier LONG
  CREATE( F, OUT_FILE, "TRUNC_TMP.TXT" );
  PUT_LINE( F, "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" );
  PUT_LINE( F, "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB" );
  PUT_LINE( F, "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC" );
  CLOSE( F );

  --  2 : le RE-creer plus COURT
  CREATE( F, OUT_FILE, "TRUNC_TMP.TXT" );
  PUT_LINE( F, "ok" );
  CLOSE( F );

  --  3 : relire — une seule ligne, "ok", rien apres
  OPEN( F, IN_FILE, "TRUNC_TMP.TXT" );
  GET_LINE( F, BUF, LEN );
  LINES := 1;
  CHECK( LEN = 2  and then  BUF( 1 .. 2 ) = "ok", "premiere ligne = ok" );
  while not END_OF_FILE( F )
  loop
    GET_LINE( F, BUF, LEN );
    LINES := LINES + 1;
  end loop;
  CLOSE( F );
  CHECK( LINES = 1, "aucune ligne fossile apres re-creation plus courte" );

  begin
    OPEN( F, IN_FILE, "TRUNC_TMP.TXT" );
    DELETE( F );
  end;

  if OK
  then
    PUT_LINE( "PASSE trunc_test" );
  end if;

end	TRUNC_TEST;
