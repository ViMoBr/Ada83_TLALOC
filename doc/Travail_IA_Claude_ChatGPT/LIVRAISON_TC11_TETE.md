# LIVRAISON TC-11 - CONTENU STR GENERALISE, TETE REELLE COMPLETE
(jalon FINC-reel, tranche D - 19 aout 2026)

PREALABLE : s'applique sur l'etat POST-erratum TC-10. Regles habituelles
(trois formes : standard, insertion pure, sur place).

MODELE : la macro STR du codi fait "db bytes" - le contenu est une LISTE
melant chaines quotees et octets litteraux. La tete reelle emet
"STR EXC_NL__, 10" (l'octet LF seul) : DO_DEFERRED, qui supposait le
contenu STRB en operande 2, produirait un bloc VIDE. Generalisation :
longueur et emission parcourent les operandes 2..N (STRB = longueur
effective '' comprise ; INT = UN octet, refus bruyant hors 0..255 ;
tout autre tag = refus bruyant). CST inchange.

Le temoin TC-11 est la TETE REELLE COMPLETE de CREATE_FAS_MAIN_FILE
(sans les includes d'unites) : sentinelle pilier 11 (EXC_MACH 0 avec
l'operande EXPR "EXC_CTX0__dat + _EXCEPTION_CONTEXT.DISPATCH"), les
trois trampolines exc_raise_ / exc_uncaught_ (avec ses trois
SYS_PUT_STR, dont un sur adresse CHARGEE par La) / ce_raise_ /
ne_raise_, et le chemin "exception non rattrapee" execute DE BOUT EN
BOUT : le main fait BRA ce_raise_, qui pose CONSTRAINT_ERROR__exc et
deroule sur la sentinelle ; le verdict est la SORTIE EXACTE
"EXCEPTION NON RATTRAPEE : CONSTRAINT_ERROR" + LF et le code 1.

## COMMIT 1 - EMITS : contenu STR = liste (chaines, octets)

### MODIFICATION 1.1 - target_code-emits.adb (apres STRB_LEN : deux sous-programmes) (insertion pure)
ANCRE (texte existant, unique) :
<<<
  end STRB_LEN;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
  end STRB_LEN;

  function		STR_CONTENT_LEN ( E :IR.ELT_ID ) return SYMBOLS.VALUE_TYPE
  --| contenu d'un STR = operandes 2.. : chaine quotee (STRB) ou OCTET
  --| litteral (db du codi - tete reelle : STR EXC_NL__, 10), melables
  is
    N			: SYMBOLS.VALUE_TYPE := 0;
  begin
    if IR.N_OPS( E ) < 2
    then
      FAULT( "STR sans contenu" );
    end if;
    for I in 2 .. IR.N_OPS( E )
    loop
      if IR.OP_TAG( E, I ) = IR.STRB_OP
      then
	N := N + STRB_LEN( IR.OP_TXT( E, I ) );
      elsif IR.OP_TAG( E, I ) = IR.INT_OP
      then
	if IR.OP_INT( E, I ) < 0  or else  IR.OP_INT( E, I ) > 255
	then
	  FAULT( "octet de STR hors 0..255" );
	end if;
	N := N + 1;
      else
	FAULT( "contenu de STR inattendu (chaine ou octet)" );
      end if;
    end loop;
    return N;
  end STR_CONTENT_LEN;

  procedure		EMIT_STR_CONTENT ( E :IR.ELT_ID )
  --| emission des octets du contenu, dans l'ordre des operandes
  is
  begin
    for K in 2 .. IR.N_OPS( E )
    loop
      if IR.OP_TAG( E, K ) = IR.STRB_OP
      then
	declare
	  T		: constant STRING := LEX.IMAGE( IR.OP_TXT( E, K ) );
	  I		: NATURAL	  := T'FIRST;
	begin
	  while I <= T'LAST
	  loop
	    if T( I ) = '''  and then  I < T'LAST  and then  T( I + 1 ) = '''
	    then
	      I := I + 1;						--| '' -> un seul '
	    end if;
	    B( CHARACTER'POS( T( I ) ) );
	    I := I + 1;
	  end loop;
	end;
      else
	B( INTEGER( IR.OP_INT( E, K ) ) );				--| octet litteral (controle par STR_CONTENT_LEN)
      end if;
    end loop;
  end EMIT_STR_CONTENT;

>>>

### MODIFICATION 1.2 - target_code-emits.adb (DO_DEFERRED, declarations du bloc STR) (sur place, auto-localisee)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
	    LEN		: constant SYMBOLS.VALUE_TYPE := STRB_LEN( IR.OP_TXT( E, 2 ) );
	    P		: constant SYMBOLS.VALUE_TYPE := ALIGNED8( CUR );
	    T		: constant STRING := LEX.IMAGE( IR.OP_TXT( E, 2 ) );
	    I		: NATURAL;
>>>
REMPLACER PAR :
<<<
	    LEN		: constant SYMBOLS.VALUE_TYPE := STR_CONTENT_LEN( E );
	    P		: constant SYMBOLS.VALUE_TYPE := ALIGNED8( CUR );
>>>

### MODIFICATION 1.3 - target_code-emits.adb (DO_DEFERRED, emission du contenu STR) (sur place, auto-localisee)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
	      I := T'FIRST;
	      while I <= T'LAST
	      loop
		if T( I ) = '''  and then  I < T'LAST  and then  T( I + 1 ) = '''
		then
		  I := I + 1;						--| '' -> un seul '
		end if;
		B( CHARACTER'POS( T( I ) ) );
		I := I + 1;
	      end loop;
>>>
REMPLACER PAR :
<<<
	      EMIT_STR_CONTENT( E );
>>>

ORACLE COMMIT 1 : compilation ; rejeu complet inchange (tous les STR
existants ont un contenu STRB en operande 2 : longueur et octets
identiques) ; les sept cmp TC-04..10 muets ; executions conformes
(okAH inclus).

## COMMIT 2 - TEMOIN TC-11 (pilote)

### MODIFICATION 2.1 - target_code.adb (insertion pure, fin du pilote)
ANCRE (texte existant, unique : fin du temoin TC-10) :
<<<
      PUT_LINE( "  chmod +x TC_TEST10.BIN && ./TC_TEST10.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + temoin TC-11) :
<<<
      PUT_LINE( "  chmod +x TC_TEST10.BIN && ./TC_TEST10.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;


  --|  TEMOIN TEMPORAIRE TETE REELLE (TC-11) - reproduction integrale
  --|  de la tete et de la queue de CREATE_FAS_MAIN_FILE (sans les
  --|  includes d'unites) : sentinelle pilier 11 (EXC_MACH 0 avec
  --|  l'operande EXPR ctx + _EXCEPTION_CONTEXT.DISPATCH), trampolines
  --|  exc_raise_ / exc_uncaught_ / ce_raise_ / ne_raise_, STR a octet
  --|  litteral (EXC_NL__, 10). Le main fait BRA ce_raise_ : chemin
  --|  "exception non rattrapee" de bout en bout. Verdict du binaire :
  --|  sortie "EXCEPTION NON RATTRAPEE : CONSTRAINT_ERROR" + LF, code 1
  --|  (le code 0 du SYS_EXIT nu apres le BRA ne doit JAMAIS sortir).
  --|  A RETIRER avec les autres.
  declare
    use LEX;
    use SYMBOLS;
    use IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROM11		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC tete : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_TEST11.FAS" );
    PUT_LINE( F, "	include '../../src/expander/fasmg/codi_x86_64.finc'" );
    PUT_LINE( F, "STANDARD = 'STANDARD'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "  virtual at 8" );
    PUT_LINE( F, "    VARzone::" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "	LINK	0, loc_siz" );
    PUT_LINE( F, "_EXCEPTION_CONTEXT = '_EXCEPTION_CONTEXT'" );
    PUT_LINE( F, " namespace _EXCEPTION_CONTEXT" );
    PUT_LINE( F, "virtual at 0" );
    PUT_LINE( F, "	STATOFS	PREV_CTX, 8, 8" );
    PUT_LINE( F, "	STATOFS	DISPATCH, 8, 8" );
    PUT_LINE( F, "end virtual" );
    PUT_LINE( F, "end namespace " );
    PUT_LINE( F, "	VAR	EXC_CTX0__dat, 64" );
    PUT_LINE( F, "	VAR	EXCEPTIONS_TOP_CTX_disp, q" );
    PUT_LINE( F, "	VAR	EXCEPTIONS_CURRENT_disp, q" );
    PUT_LINE( F, "	EXC_MACH	0, EXC_CTX0__dat" );
    PUT_LINE( F, "	LCA	exc_uncaught_" );
    PUT_LINE( F, "	Sa	0, EXC_CTX0__dat + _EXCEPTION_CONTEXT.DISPATCH" );
    PUT_LINE( F, "	LVA	0, EXC_CTX0__dat" );
    PUT_LINE( F, "	Sa	0, EXCEPTIONS_TOP_CTX_disp" );
    PUT_LINE( F, "	BRA	ce_raise_" );
    PUT_LINE( F, "	SYS_EXIT" );
    PUT_LINE( F, "exc_raise_:" );
    PUT_LINE( F, "	EXC_RAISE	EXCEPTIONS_TOP_CTX_disp" );
    PUT_LINE( F, "exc_uncaught_:" );
    PUT_LINE( F, "	STR	EXC_MSG__, 'EXCEPTION NON RATTRAPEE : '" );
    PUT_LINE( F, "	STR	EXC_NL__, 10" );
    PUT_LINE( F, "	LCA	EXC_MSG__.data_ptr" );
    PUT_LINE( F, "	SYS_PUT_STR" );
    PUT_LINE( F, "	La	0, EXCEPTIONS_CURRENT_disp" );
    PUT_LINE( F, "	SYS_PUT_STR" );
    PUT_LINE( F, "	LCA	EXC_NL__.data_ptr" );
    PUT_LINE( F, "	SYS_PUT_STR" );
    PUT_LINE( F, "	SYS_EXIT	1" );
    PUT_LINE( F, "ce_raise_:" );
    PUT_LINE( F, "	LCA	CONSTRAINT_ERROR__exc.data_ptr" );
    PUT_LINE( F, "	Sa	0, EXCEPTIONS_CURRENT_disp" );
    PUT_LINE( F, "	BRA	exc_raise_" );
    PUT_LINE( F, "ne_raise_:" );
    PUT_LINE( F, "	LCA	NUMERIC_ERROR__exc.data_ptr" );
    PUT_LINE( F, "	Sa	0, EXCEPTIONS_CURRENT_disp" );
    PUT_LINE( F, "	BRA	exc_raise_" );
    PUT_LINE( F, "	STR	CONSTRAINT_ERROR__exc, 'CONSTRAINT_ERROR'" );
    PUT_LINE( F, "	STR	NUMERIC_ERROR__exc, 'NUMERIC_ERROR'" );
    PUT_LINE( F, " virtual VARzone" );
    PUT_LINE( F, "   loc_siz = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROM11 := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_TEST11.FAS" );
    PASSES.P1_REACH;
    PASSES.P2_LAYOUT( FROM11, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P2B_ADDRESSES( FROM11, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROM11, IR.ELT_ID( IR.ELT_COUNT ), "TC_TEST11.BIN" );

    CHECK( VALUE_OF( RESOLVE( "STANDARD._EXCEPTION_CONTEXT.DISPATCH" ) ) = 8,
	   "record statique du contexte (DISPATCH 8)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.EXC_CTX0__dat" ) ) = 8
	   and then VALUE_OF( RESOLVE( "STANDARD.EXCEPTIONS_TOP_CTX_disp" ) ) = 72
	   and then VALUE_OF( RESOLVE( "STANDARD.EXCEPTIONS_CURRENT_disp" ) ) = 80,
	   "sentinelle et globales pilier 11 (8, 72, 80)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.loc_siz" ) ) = 88,
	   "loc_siz de niveau 0 (88)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.EXC_NL__.data" ) )
	     = VALUE_OF( RESOLVE( "STANDARD.EXC_NL__.data_ptr" ) ) + 32,
	   "bloc STR a octet litteral : structure standard" );

    if OK
    then
      PUT_LINE( "PASSE tete" );
      PUT_LINE( "TC_TEST11.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_TEST11.FAS TC_REF11 && cmp TC_REF11 TC_TEST11.BIN" );
      PUT_LINE( "  chmod +x TC_TEST11.BIN && ./TC_TEST11.BIN ; echo $?" );
      PUT_LINE( "  (attendu : EXCEPTION NON RATTRAPEE : CONSTRAINT_ERROR puis 1)" );
    end if;
  end;

>>>

ORACLE COMMIT 2 (quadruple) :
(a) fasmg TC_TEST11.FAS TC_REF11 && cmp TC_REF11 TC_TEST11.BIN -> muet.
    Premiers suspects en cas d'ecart : la longueur du bloc EXC_NL__
    (LST_1 = 1, un octet de data) puis l'ordre LIFO des quatre STR.
(b) fasmg accepte TC_TEST11.FAS.
(c) "PASSE tete", aucun ECHEC ; ./TC_TEST11.BIN affiche exactement
    "EXCEPTION NON RATTRAPEE : CONSTRAINT_ERROR" + LF et rend 1.
(d) cmp TC-04..10 muets, executions conformes.

## CLOTURE (documentation, pas de code)

- NOTE_SUBSET par 1.2 : STR - contenu LISTE (chaines, octets) LU
  (TC-11) ; tete reelle : TOUTES les formes de CREATE_FAS_MAIN_FILE
  sont desormais lues et byte-exactes (structure TC-08, protocole
  TC-09, use-info TC-10, trampolines et STR numerique TC-11).
- Par 5 : jalon FINC-reel, dernier morceau restant : avaler
  _STANDRD.FINC et une unite reelle (DIS_BONJOUR) - miroirs n 110 / Q7
  sous DEBUG_LLIR=1. PREREQUIS MATERIEL : les fichiers _STANDRD.FINC et
  DIS_BONJOUR.fas/.FINC (non presents dans l'espace projet).
