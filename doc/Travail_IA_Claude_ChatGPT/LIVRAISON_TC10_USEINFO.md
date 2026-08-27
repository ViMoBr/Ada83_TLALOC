# LIVRAISON TC-10 - USEINFO PARTIE CODE (expansion a la fasmg)
(jalon FINC-reel, tranche C - 19 aout 2026)

PREALABLE : s'applique sur l'etat POST-TC-09. Regles habituelles ; forme
supplementaire "SUR PLACE" : quand le bloc a modifier est lui-meme unique,
il sert d'ancre et il est remplace en bloc (pas de bloc a supprimer
distinct).

MODELE (corpus relu dans l'expander, types_decls) : toutes les emissions
sont de la forme
  USEINFO lvl, NOM, <tab>La lvl2, chemin.pointe.use__info
ou use__info est un simple "VAR use__info, q" dans le namespace du type
(FRAME_OFFSET au niveau du type) - la charge est donc un La ORDINAIRE.
La macro codi fait : reservation VARzone (NOM__u, deja en P2 depuis
TC-05), puis load_instruc, puis "Sa lvl, NOM__u". L'implementation juste
est l'EXPANSION au LEX, comme fasmg expanse sa macro : l'element USEINFO
est reduit a (lvl, nom) pour le layout de P2, la charge (operandes 3..,
rejoints par ", ") est re-parsee en element ordinaire, et le rangement
"Sa lvl, nom__u" est synthetise. EMITS n'apprend RIEN de neuf : USEINFO
rejoint seulement les listes zero-octet (comme VAR).

## COMMIT 1 - LEX : branche USEINFO (expansion en trois elements)

### MODIFICATION 1.1 - target_code-lex.adb (PROCESS_LINE, apres la branche STR/CST) (insertion pure)
ANCRE (texte existant, unique) :
<<<
      end if;
      IR.NEW_ELT( IR.MACRO_CALL, STORE( LINE( WF .. WL ) ) );
      EMIT_OPERANDS;
      IR.DEFER_LAST;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
      end if;
      IR.NEW_ELT( IR.MACRO_CALL, STORE( LINE( WF .. WL ) ) );
      EMIT_OPERANDS;
      IR.DEFER_LAST;

    elsif EQL( WF, WL, "USEINFO" )
    then								--| EXPANSION a la fasmg : (1) element USEINFO
      if NOPS < 3							--| reduit a lvl, nom - le layout de P2 ; (2) la
	 or else  TAGS( 2 ) /= IR.NAME_OP				--| charge (ops 3.., rejoints par ", ") re-parsee
      then								--| en element ordinaire ; (3) "Sa lvl, nom__u"
	FAULT( "forme USEINFO inattendue (lvl, nom, charge)" );		--| synthetise. EMITS n'a rien a apprendre.
      end if;
      declare
	L1TAG		: constant IR.OPERAND_TAG := TAGS( 1 );
	L1TXT		: constant SLICE	  := TXTS( 1 );
	L1INT		: constant LONG_INTEGER	  := IVALS( 1 );
	NAME2		: constant SLICE	  := TXTS( 2 );
	N		: NATURAL		  := 0;
      begin
	IR.NEW_ELT( IR.MACRO_CALL, STORE( LINE( WF .. WL ) ) );
	IR.ADD_OP( TAGS( 1 ), TXTS( 1 ), IVALS( 1 ), FVALS( 1 ) );
	IR.ADD_OP( TAGS( 2 ), TXTS( 2 ), IVALS( 2 ), FVALS( 2 ) );
	for I in 3 .. NOPS
	loop								--| reconstruire la ligne de charge dans LINE
	  if TAGS( I ) /= IR.EXPR_OP  and  TAGS( I ) /= IR.NAME_OP
	  then
	    FAULT( "charge USEINFO hors corpus (texte attendu)" );
	  end if;
	  declare
	    P		: constant STRING := IMAGE( TXTS( I ) );
	  begin
	    if I > 3
	    then
	      LINE( N + 1 .. N + 2 ) := ", ";
	      N := N + 2;
	    end if;
	    LINE( N + 1 .. N + P'LENGTH ) := P;
	    N := N + P'LENGTH;
	  end;
	end loop;
	LEN := N;							--| la ligne d'origine est consommee : reutilisable
	POS := 1;
	NEXT_WORD( WF, WL );
	PARSE_OPERANDS;
	IR.NEW_ELT( IR.MACRO_CALL, STORE( LINE( WF .. WL ) ) );
	EMIT_OPERANDS;
	IR.NEW_ELT( IR.MACRO_CALL, STORE( "Sa" ) );			--| le rangement de la macro codi
	IR.ADD_OP( L1TAG, L1TXT, L1INT, 0.0 );
	IR.ADD_OP( IR.NAME_OP, STORE( IMAGE( NAME2 ) & "__u" ) );
      end;

>>>

ORACLE COMMIT 1 : compilation ; rejeu complet. ATTENTION : TC-03 exerce
"USEINFO 1, BUF3, LI 0" en P2 SEULEMENT (pas de P2B/P3 sur sa plage) -
les deux elements expanses (LI 0, Sa) restent donc inertes et les CHECK
TC-03 (BUF3__u = 56, loc_siz = 64) sont INCHANGES. Cinq cmp muets.

## COMMIT 2 - EMITS : USEINFO dans les listes zero-octet

L'element USEINFO reduit ne pese rien (le code vit dans les elements
expanses). Deux listes jumelles, auto-localisees par leur derniere ligne
(return 0 / null).

### MODIFICATION 2.1 - target_code-emits.adb (SIZE_OF) (sur place, auto-localisee)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
    elsif M = "endPRO"  or else  M = "PRMS"  or else  M = "PRM"
	  or else  M = "endPRMS"  or else  M = "VAR"  or else  M = "STATOFS"
    then
      return 0;								--| pure declaration : zero octet
>>>
REMPLACER PAR :
<<<
    elsif M = "endPRO"  or else  M = "PRMS"  or else  M = "PRM"
	  or else  M = "endPRMS"  or else  M = "VAR"  or else  M = "STATOFS"
	  or else  M = "USEINFO"					--| code expanse au LEX (TC-10)
    then
      return 0;								--| pure declaration : zero octet
>>>

### MODIFICATION 2.2 - target_code-emits.adb (ENCODE) (sur place, auto-localisee)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
    elsif M = "endPRO"  or else  M = "PRMS"  or else  M = "PRM"
	  or else  M = "endPRMS"  or else  M = "VAR"  or else  M = "STATOFS"
    then
      null;								--| pure declaration : zero octet
>>>
REMPLACER PAR :
<<<
    elsif M = "endPRO"  or else  M = "PRMS"  or else  M = "PRM"
	  or else  M = "endPRMS"  or else  M = "VAR"  or else  M = "STATOFS"
	  or else  M = "USEINFO"					--| code expanse au LEX (TC-10)
    then
      null;								--| pure declaration : zero octet
>>>

ORACLE COMMIT 2 : compilation ; rejeu inchange.

## COMMIT 3 - TEMOIN TC-10 (pilote)

### MODIFICATION 3.1 - target_code.adb (insertion pure, fin du pilote)
ANCRE (texte existant, unique : fin du temoin TC-09) :
<<<
      PUT_LINE( "  chmod +x TC_TEST9.BIN && ./TC_TEST9.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + temoin TC-10) :
<<<
      PUT_LINE( "  chmod +x TC_TEST9.BIN && ./TC_TEST9.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;


  --|  TEMOIN TEMPORAIRE USEINFO CODE (TC-10) - la forme exacte du
  --|  corpus expander : bloc type (garde + namespace + VAR use__info,q
  --|  + Sa lvl, use__info local), puis USEINFO lvl, NOM avec charge
  --|  "La lvl, chemin.use__info" (deux morceaux : la reconstruction
  --|  avec virgule est exercee), relecture par NOM__u. Le VAR dans un
  --|  namespace non-PRO loge dans le frame 0 (portee et pile, mini-Q7).
  --|  Verdict : 0 = la valeur a traverse use__info -> NOM__u ; 1 = non.
  --|  A RETIRER avec les autres.
  declare
    use LEX;
    use SYMBOLS;
    use IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROM10		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC useinfo : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_TEST10.FAS" );
    PUT_LINE( F, "	include '../../src/expander/fasmg/codi_x86_64.finc'" );
    PUT_LINE( F, "STANDARD = 'STANDARD'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "  virtual at 8" );
    PUT_LINE( F, "    VARzone::" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "	LINK	0, loc_siz" );
    PUT_LINE( F, "_T10 = '_T10'" );
    PUT_LINE( F, " namespace _T10" );
    PUT_LINE( F, "VAR use__info, q" );
    PUT_LINE( F, "	LI	5150" );
    PUT_LINE( F, "	Sa	0, use__info" );
    PUT_LINE( F, "end namespace " );
    PUT_LINE( F, "	USEINFO	0, ARR10, 	La 0, _T10.use__info" );
    PUT_LINE( F, "	Lq	0, ARR10__u" );
    PUT_LINE( F, "	LI	5150" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	ok10" );
    PUT_LINE( F, "	SYS_EXIT	1" );
    PUT_LINE( F, "ok10:" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, " virtual VARzone" );
    PUT_LINE( F, "   loc_siz = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROM10 := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_TEST10.FAS" );
    PASSES.P1_REACH;
    PASSES.P2_LAYOUT( FROM10, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P2B_ADDRESSES( FROM10, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROM10, IR.ELT_ID( IR.ELT_COUNT ), "TC_TEST10.BIN" );

    CHECK( VALUE_OF( RESOLVE( "STANDARD._T10.use__info" ) ) = 8,
	   "use__info du bloc type dans le frame 0 (8)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.ARR10__u" ) ) = 16,
	   "ARR10__u reserve apres (16), obtenu"
	   & LONG_INTEGER'IMAGE( VALUE_OF( RESOLVE( "STANDARD.ARR10__u" ) ) ) );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.loc_siz" ) ) = 24,
	   "loc_siz de niveau 0 (24)" );

    if OK
    then
      PUT_LINE( "PASSE useinfo" );
      PUT_LINE( "TC_TEST10.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_TEST10.FAS TC_REF10 && cmp TC_REF10 TC_TEST10.BIN" );
      PUT_LINE( "  chmod +x TC_TEST10.BIN && ./TC_TEST10.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;

>>>

ORACLE COMMIT 3 (quadruple) :
(a) fasmg TC_TEST10.FAS TC_REF10 && cmp TC_REF10 TC_TEST10.BIN -> muet.
    Premier suspect en cas d'ecart : l'ORDRE d'expansion (reservation /
    charge / Sa) ou la reconstruction de la charge.
(b) fasmg accepte TC_TEST10.FAS (garde + namespace du type, end
    namespace avec espace final : formes de l'expander).
(c) "PASSE useinfo", aucun ECHEC ; ./TC_TEST10.BIN -> 0.
(d) cmp TC-04..09 muets, executions conformes ; TC-03 (USEINFO en P2
    seul) : CHECK inchanges.

## CLOTURE (documentation, pas de code)

- NOTE_SUBSET par 1.2 : USEINFO - layout LU (TC-05), CODE LU (TC-10,
  expansion au LEX) ; noter le corpus (charge = toujours "La lvl,
  chemin.use__info") et le refus bruyant hors corpus.
- JOURNAL : l'element USEINFO reduit (lvl, nom) est desormais suivi de
  ses deux elements expanses dans l'IR ; les listes zero-octet d'EMITS
  incluent USEINFO.
- RESTE du jalon FINC-reel : avaler _STANDRD.FINC et une unite reelle
  (miroirs n 110 / Q7 sous DEBUG_LLIR=1) - il faudra au prealable la
  tete reelle complete, qui exerce EXC_MACH avec l'operande
  "EXC_CTX0__dat + _EXCEPTION_CONTEXT.DISPATCH" (EXPR via EVAL, deja
  couvert par TC-09).
