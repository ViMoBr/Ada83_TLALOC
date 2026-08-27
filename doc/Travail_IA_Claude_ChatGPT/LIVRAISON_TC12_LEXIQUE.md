# LIVRAISON TC-12 - LEXIQUE ELARGI DU FINC REEL (tranche E1)
(19 aout 2026 - s'applique sur l'etat POST-TC-11. Regles habituelles.)

CORPUS (releve sur _STANDRD / TEXT_IO / IO_EXCEPTIONS / DIS_BONJOUR) :
- chaines a GUILLEMETS DOUBLES, y compris VIDE (STR RET_STR_L57, "")
  et melant l'autre delimiteur (" l'ete ") ; doublage du delimiteur
  actif ('c''est', "dit " + doubles-doubles) ;
- "$" en zone STATIQUE : records manuels "X = $ / rd 1" (virtual at
  4) et "size = $" apres des STATOFS (virtual at 0) ;
- "rd N" : reservation de N dwords en zone statique ;
- "LI size*8" : operande EXPR de LI (la table exigeait un litteral).

DECISION DE NORMALISATION : le doublage du delimiteur est RESOLU AU
STORE (CLASSIFY) - le STRB porte les octets effectifs. STRB_LEN devient
une longueur simple et l'emission perd sa gestion du doublage. Aucun
temoin existant n'a de doublage : octets inchanges (rejeu au cmp).

## COMMIT 1 - LEX : deux delimiteurs de chaine, doublage resolu au STORE

### MODIFICATION 1.1 - target_code-lex.adb (PARSE_OPERANDS, declarations) (sur place, auto-localisee)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
    A, B		: NATURAL;
    DEPTH		: NATURAL;
    INQ			: BOOLEAN;
    C			: CHARACTER;
    DONE		: BOOLEAN	:= FALSE;
>>>
REMPLACER PAR :
<<<
    A, B		: NATURAL;
    DEPTH		: NATURAL;
    INQ			: BOOLEAN;
    QC			: CHARACTER	:= ''';				--| delimiteur ACTIF de la chaine en cours
    C			: CHARACTER;
    DONE		: BOOLEAN	:= FALSE;
>>>

### MODIFICATION 1.2 - target_code-lex.adb (PARSE_OPERANDS, suivi de chaine) (sur place, auto-localisee)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
	if INQ
	then
	  if C = '''
	  then
	    if POS < LEN  and then  LINE( POS + 1 ) = '''
	    then
	      POS := POS + 1;						--| doublage : reste en chaine
	    else
	      INQ := FALSE;
	    end if;
	  end if;
	elsif C = '''
	then
	  INQ := TRUE;
>>>
REMPLACER PAR :
<<<
	if INQ
	then
	  if C = QC
	  then
	    if POS < LEN  and then  LINE( POS + 1 ) = QC
	    then
	      POS := POS + 1;						--| doublage : reste en chaine
	    else
	      INQ := FALSE;
	    end if;
	  end if;
	elsif C = '''  or else  C = '"'
	then
	  INQ := TRUE;
	  QC  := C;
>>>

### MODIFICATION 1.3 - target_code-lex.adb (CLASSIFY, branche chaine) (sur place, auto-localisee)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
    if LINE( A ) = '''
    then								--| chaine quotee (doublage '' conserve tel quel)
      if B <= A  or else  LINE( B ) /= '''
      then
	FAULT( "chaine non close" );
      end if;
      TAGS( NOPS ) := IR.STRB_OP;
      TXTS( NOPS ) := STORE( LINE( A + 1 .. B - 1 ) );
      return;
    end if;
>>>
REMPLACER PAR :
<<<
    if LINE( A ) = '''  or else  LINE( A ) = '"'
    then								--| chaine quotee (' ou ") : le DOUBLAGE du
      declare								--| delimiteur actif est RESOLU ici - le STRB
	QC		: constant CHARACTER := LINE( A );		--| stocke les octets EFFECTIFS (TC-12) ;
	BUF		: STRING( 1 .. LINE_MAX );			--| l'autre delimiteur est un octet ordinaire
	N		: NATURAL	:= 0;
	I		: NATURAL;
      begin
	if B <= A  or else  LINE( B ) /= QC
	then
	  FAULT( "chaine non close" );
	end if;
	I := A + 1;
	while I <= B - 1
	loop
	  if LINE( I ) = QC
	  then								--| forcement double (l'operande aurait clos sinon)
	    I := I + 1;
	  end if;
	  N := N + 1;
	  BUF( N ) := LINE( I );
	  I := I + 1;
	end loop;
	TAGS( NOPS ) := IR.STRB_OP;
	TXTS( NOPS ) := STORE( BUF( 1 .. N ) );
      end;
      return;
    end if;
>>>

ORACLE COMMIT 1 : compilation ; rejeu inchange - le temoin lex (TC-01)
et les contenus STR existants n'ont ni guillemet double ni doublage.

## COMMIT 2 - EMITS : longueurs simples, LI generalise

### MODIFICATION 2.1 - target_code-emits.adb (STRB_LEN : contenu deja normalise) (sur place, auto-localisee)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
  function		STRB_LEN ( S :LEX.SLICE ) return SYMBOLS.VALUE_TYPE
  --| longueur EFFECTIVE d'une tranche STRB : les '' doubles comptent 1
  is
    N			: SYMBOLS.VALUE_TYPE := 0;
    I			: NATURAL	:= S.F;
    T			: constant STRING := LEX.IMAGE( S );
  begin
    I := T'FIRST;
    while I <= T'LAST
    loop
      if T( I ) = '''  and then  I < T'LAST  and then  T( I + 1 ) = '''
      then
	I := I + 1;										--| doublage : un seul octet
      end if;
      N := N + 1;
      I := I + 1;
    end loop;
    return N;
  end STRB_LEN;
>>>
REMPLACER PAR :
<<<
  function		STRB_LEN ( S :LEX.SLICE ) return SYMBOLS.VALUE_TYPE
  --| longueur d'une tranche STRB : octets EFFECTIFS (le doublage du
  --| delimiteur est resolu au STORE par CLASSIFY depuis TC-12)
  is
  begin
    if S.F = 0  or  S.L < S.F
    then
      return 0;
    end if;
    return SYMBOLS.VALUE_TYPE( S.L - S.F + 1 );
  end STRB_LEN;
>>>

### MODIFICATION 2.2 - target_code-emits.adb (EMIT_STR_CONTENT : emission directe) (sur place, auto-localisee)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
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
>>>
REMPLACER PAR :
<<<
	begin
	  while I <= T'LAST
	  loop
	    B( CHARACTER'POS( T( I ) ) );				--| octets effectifs (doublage resolu au STORE)
	    I := I + 1;
	  end loop;
	end;
>>>

### MODIFICATION 2.3 - target_code-emits.adb (ENCODE, LI : operande via OPV) (sur place, auto-localisee)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
    elsif M = "LI"
    then
      if IR.N_OPS( E ) < 1  or else  IR.OP_TAG( E, 1 ) /= IR.INT_OP
      then
	FAULT( "LI : litteral entier attendu (tranche TC-04)" );
      end if;
      B( 16#48# ); B( 16#B8# );						--| movabs rax, imm64
      Q64( IR.OP_INT( E, 1 ) );
      E_PUSH_RAX;
>>>
REMPLACER PAR :
<<<
    elsif M = "LI"
    then
      if IR.N_OPS( E ) < 1
      then
	FAULT( "LI : operande attendu" );
      end if;
      B( 16#48# ); B( 16#B8# );						--| movabs rax, imm64
      Q64( OPV( E, 1, 0 ) );						--| litteral, nom ou EXPR (corpus : LI size*8)
      E_PUSH_RAX;
>>>

ORACLE COMMIT 2 : compilation ; rejeu inchange (tous les LI existants
sont des litteraux : OPV rend la meme valeur).

## COMMIT 3 - PASSES + EMITS : $ statique et rd

### MODIFICATION 3.1 - target_code-passes.adb (DO_ASSIGN : $ en zone statique) (sur place, auto-localisee)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
	if not REOPENED  or else  FTOP = 0
	then
	  FAULT( "affectation de $ hors zone rouverte : "
		 & LEX.IMAGE( IR.MNEMO_OF( E ) ) );
	end if;
	SYMBOLS.DECLARE_SYM( LEX.IMAGE( IR.MNEMO_OF( E ) ),
			     SYMBOLS.PLAIN_VALUE, VPOSES( FTOP ) );
>>>
REMPLACER PAR :
<<<
	if REOPENED  and then  FTOP > 0
	then								--| $ de la VARzone ROUVERTE (queue du .fas)
	  SYMBOLS.DECLARE_SYM( LEX.IMAGE( IR.MNEMO_OF( E ) ),
			       SYMBOLS.PLAIN_VALUE, VPOSES( FTOP ) );
	elsif STOP > 0
	then								--| $ d'une zone STATIQUE (records manuels :
	  SYMBOLS.DECLARE_SYM( LEX.IMAGE( IR.MNEMO_OF( E ) ),		--| X = $ / rd 1 ; size = $ apres STATOFS - TC-12)
			       SYMBOLS.PLAIN_VALUE, SPOSES( STOP ) );
	else
	  FAULT( "affectation de $ hors de toute zone : "
		 & LEX.IMAGE( IR.MNEMO_OF( E ) ) );
	end if;
>>>

### MODIFICATION 3.2 - target_code-passes.adb (P2_LAYOUT : branche rd) (insertion pure)
ANCRE (texte existant, unique) :
<<<
	    elsif MNEMO_IS( EI, "STATOFS" )
	    then
	      DO_STATOFS( EI );
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
	    elsif MNEMO_IS( EI, "STATOFS" )
	    then
	      DO_STATOFS( EI );

	    elsif MNEMO_IS( EI, "rd" )
	    then							--| reservation de N dwords en zone statique
	      if STOP = 0  or else  IR.N_OPS( EI ) < 1			--| (records manuels de _STANDRD - TC-12)
		 or else  IR.OP_TAG( EI, 1 ) /= IR.INT_OP
		 or else  IR.OP_INT( EI, 1 ) < 0
	      then
		FAULT( "forme rd inattendue (N dwords, en zone virtual)" );
	      end if;
	      SPOSES( STOP ) := SPOSES( STOP ) + 4 * IR.OP_INT( EI, 1 );
>>>

### MODIFICATION 3.3 - target_code-emits.adb (SIZE_OF, liste zero-octet + rd) (sur place, auto-localisee)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
    elsif M = "endPRO"  or else  M = "PRMS"  or else  M = "PRM"
	  or else  M = "endPRMS"  or else  M = "VAR"  or else  M = "STATOFS"
	  or else  M = "USEINFO"					--| code expanse au LEX (TC-10)
    then
      return 0;								--| pure declaration : zero octet
>>>
REMPLACER PAR :
<<<
    elsif M = "endPRO"  or else  M = "PRMS"  or else  M = "PRM"
	  or else  M = "endPRMS"  or else  M = "VAR"  or else  M = "STATOFS"
	  or else  M = "USEINFO"					--| code expanse au LEX (TC-10)
	  or else  M = "rd"						--| reservation statique (TC-12)
    then
      return 0;								--| pure declaration : zero octet
>>>

### MODIFICATION 3.4 - target_code-emits.adb (ENCODE, liste zero-octet + rd) (sur place, auto-localisee)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
    elsif M = "endPRO"  or else  M = "PRMS"  or else  M = "PRM"
	  or else  M = "endPRMS"  or else  M = "VAR"  or else  M = "STATOFS"
	  or else  M = "USEINFO"					--| code expanse au LEX (TC-10)
    then
      null;								--| pure declaration : zero octet
>>>
REMPLACER PAR :
<<<
    elsif M = "endPRO"  or else  M = "PRMS"  or else  M = "PRM"
	  or else  M = "endPRMS"  or else  M = "VAR"  or else  M = "STATOFS"
	  or else  M = "USEINFO"					--| code expanse au LEX (TC-10)
	  or else  M = "rd"						--| reservation statique (TC-12)
    then
      null;								--| pure declaration : zero octet
>>>

## COMMIT 4 - TEMOIN TC-12 (pilote)

### MODIFICATION 4.1 - target_code.adb (insertion pure, fin du pilote)
ANCRE (texte existant, unique : fin du temoin TC-11) :
<<<
      PUT_LINE( "  chmod +x TC_TEST11.BIN && ./TC_TEST11.BIN ; echo $?" );
      PUT_LINE( "  (attendu : EXCEPTION NON RATTRAPEE : CONSTRAINT_ERROR puis 1)" );
    end if;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + temoin TC-12) :
<<<
      PUT_LINE( "  chmod +x TC_TEST11.BIN && ./TC_TEST11.BIN ; echo $?" );
      PUT_LINE( "  (attendu : EXCEPTION NON RATTRAPEE : CONSTRAINT_ERROR puis 1)" );
    end if;


  --|  TEMOIN TEMPORAIRE LEXIQUE FINC (TC-12) - guillemets doubles
  --|  (vide, delimiteur oppose, doublages des deux delimiteurs),
  --|  record manuel "X = $ / rd N / size = $" en virtual at 4, LI a
  --|  operande EXPR (LI size*8, forme corpus). Verdict : affiche
  --|  c'est l'ete dit "oui"  puis 0 = SIZ12 (=128 via size12*8)
  --|  relu ; 2 = non. A RETIRER avec les autres.
  declare
    use LEX;
    use SYMBOLS;
    use IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROM12		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC lexfinc : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_TEST12.FAS" );
    PUT_LINE( F, "	include '../../src/expander/fasmg/codi_x86_64.finc'" );
    PUT_LINE( F, "STANDARD = 'STANDARD'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "  virtual at 8" );
    PUT_LINE( F, "    VARzone::" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "	LINK	0, loc_siz" );
    PUT_LINE( F, "_R12 = '_R12'" );
    PUT_LINE( F, " namespace _R12" );
    PUT_LINE( F, "VAR SIZ12, d" );
    PUT_LINE( F, "  virtual at 4" );
    PUT_LINE( F, "A12 = $" );
    PUT_LINE( F, "	rd 1 " );
    PUT_LINE( F, "B12 = $" );
    PUT_LINE( F, "	rd 2" );
    PUT_LINE( F, "size12 = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "	LI	 size12*8" );
    PUT_LINE( F, "	Sd	0, SIZ12" );
    PUT_LINE( F, "end namespace " );
    PUT_LINE( F, "	STR	V12, "" l'ete """ );
    PUT_LINE( F, "	STR	W12, 'c''est'" );
    PUT_LINE( F, "	STR	X12, ""dit """"oui""""""" );
    PUT_LINE( F, "	STR	E12, """"" );
    PUT_LINE( F, "	LCA	W12.data_ptr" );
    PUT_LINE( F, "	SYS_PUT_STR" );
    PUT_LINE( F, "	LCA	V12.data_ptr" );
    PUT_LINE( F, "	SYS_PUT_STR" );
    PUT_LINE( F, "	LCA	X12.data_ptr" );
    PUT_LINE( F, "	SYS_PUT_STR" );
    PUT_LINE( F, "	Ld	0, _R12.SIZ12" );
    PUT_LINE( F, "	LI	128" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	ok12" );
    PUT_LINE( F, "	SYS_EXIT	2" );
    PUT_LINE( F, "ok12:" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, " virtual VARzone" );
    PUT_LINE( F, "   loc_siz = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROM12 := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_TEST12.FAS" );
    PASSES.P1_REACH;
    PASSES.P2_LAYOUT( FROM12, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P2B_ADDRESSES( FROM12, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROM12, IR.ELT_ID( IR.ELT_COUNT ), "TC_TEST12.BIN" );

    CHECK( VALUE_OF( RESOLVE( "STANDARD._R12.A12" ) ) = 4
	   and then VALUE_OF( RESOLVE( "STANDARD._R12.B12" ) ) = 8
	   and then VALUE_OF( RESOLVE( "STANDARD._R12.size12" ) ) = 16,
	   "record manuel en virtual at 4 (A 4, B 8, size 16)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD._R12.SIZ12" ) ) = 8
	   and then VALUE_OF( RESOLVE( "STANDARD.loc_siz" ) ) = 12,
	   "layout niveau 0 (SIZ12 8, loc_siz 12)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.X12.data_ptr" ) )
	     = VALUE_OF( RESOLVE( "STANDARD.E12.data_ptr" ) ) + 32
	   and then VALUE_OF( RESOLVE( "STANDARD.W12.data_ptr" ) )
	     = VALUE_OF( RESOLVE( "STANDARD.X12.data_ptr" ) ) + 48
	   and then VALUE_OF( RESOLVE( "STANDARD.V12.data_ptr" ) )
	     = VALUE_OF( RESOLVE( "STANDARD.W12.data_ptr" ) ) + 40,
	   "longueurs normalisees (0, 9, 5) et placement LIFO" );

    if OK
    then
      PUT_LINE( "PASSE lexfinc" );
      PUT_LINE( "TC_TEST12.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_TEST12.FAS TC_REF12 && cmp TC_REF12 TC_TEST12.BIN" );
      PUT_LINE( "  chmod +x TC_TEST12.BIN && ./TC_TEST12.BIN ; echo $?" );
      PUT_LINE( "  (attendu : c'est l'ete dit ""oui"" puis 0)" );
    end if;
  end;

>>>

ORACLE COMMIT 4 (quadruple) :
(a) fasmg TC_TEST12.FAS TC_REF12 && cmp TC_REF12 TC_TEST12.BIN -> muet.
    Premiers suspects : longueurs normalisees des STR (LST_1 de X12 =
    9) et l'imm64 du LI size12*8 (128).
(b) fasmg accepte TC_TEST12.FAS.
(c) "PASSE lexfinc" ; execution : affiche  c'est l'ete dit "oui"  et
    rend 0.
(d) cmp TC-04..11 muets, executions conformes.

## CLOTURE (documentation)
- NOTE_SUBSET par 1.2 : chaines des deux delimiteurs (doublage resolu
  au STORE), $ statique, rd, LI a operande EXPR - LUS (TC-12).
- JOURNAL : decision de normalisation des STRB (octets effectifs).
  RESTE : E2 acces + REFONTE CASSE (le corpus TEXT_IO mele LIVA/LIVa,
  LA/La, SD/Sd : macros codi en "?", la table EMITS devra replier la
  casse des mnemoniques - arbitrage a la tranche E2), E3 calcul, E4
  blocs inline, E5 avalement.
