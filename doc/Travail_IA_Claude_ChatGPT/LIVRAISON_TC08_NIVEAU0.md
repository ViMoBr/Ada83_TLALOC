# LIVRAISON TC-08 - TETE/QUEUE CANONIQUES DU .fas, FRAME DE NIVEAU 0
(jalon FINC-reel, tranche A - 19 aout 2026)

REGLES D'APPLICATION :
- Une modification = une ANCRE (texte existant unique, a ne PAS modifier),
  un bloc a SUPPRIMER (contigu, immediatement apres l'ancre sauf mention
  contraire), un bloc de REMPLACEMENT insere a la place du bloc supprime.
- Pour les INSERTIONS pures : le bloc a supprimer est l'ancre elle-meme,
  reprise a l'identique en tete du remplacement.
- Les TABULATIONS des blocs sont significatives (extraites des sources ou
  conformes a la convention des fichiers : indentation 2 par niveau,
  tabification des colonnes par 8). Verifier que l'editeur ne convertit
  pas les tabs. ASCII strict partout.
- Un commit par section, dans l'ordre ; chaque commit a son oracle.
- <<< et >>> delimitent les blocs et n'en font pas partie.

RAPPEL DU MODELE (source : expander.adb, CREATE_FAS_MAIN_FILE, relu) :
la tete du .fas reel ouvre le frame de NIVEAU 0 par le motif litteral
"virtual at 8 / VARzone:: / end virtual" puis "LINK 0, loc_siz" ; les VAR
de niveau 0 (elaboration de _STANDRD et des unites) y logent ; la queue
"virtual VARzone / loc_siz = $ / end virtual" fige loc_siz SANS align_q
(a la difference du endPRO du codi). Cote fasmg, VARzone est resolu par
portee de namespace : c'est le modele PILE de P2 (mini-Q7, tranche par le
byte-diff du temoin TC-08).

## COMMIT 1 - PASSES : purge du residu USEINFO (erreur de signature v1)

Le bloc USEINFO de P2_LAYOUT declare, apres le "nom__u" correct (operande
2, TC-05), un second symbole construit sur l'operande 1 - or op1 est lvl,
un ENTIER : OP_TXT en est vide et la declaration produit un symbole
parasite "__u" sans avancement de VPOS. Residu de la signature v1.
Aucun temoin ne l'exerce (TC-03 verifie BUF3__u=56 et loc_siz=64, tous
deux inchanges par la purge).

### MODIFICATION 1.1 - target_code-passes.adb (P2_LAYOUT, bloc USEINFO)
ANCRE (texte existant, unique, INCHANGE) :
<<<
	      SYMBOLS.DECLARE_SYM( LEX.IMAGE( IR.OP_TXT( EI, 2 ) ) & "__u",
				   SYMBOLS.FRAME_OFFSET, VPOSES( FTOP ) );
>>>
SUPPRIMER (bloc contigu, immediatement apres l'ancre sauf mention contraire) :
<<<
	      VPOSES( FTOP ) := VPOSES( FTOP ) + 8;
	      SYMBOLS.DECLARE_SYM( LEX.IMAGE( IR.OP_TXT( EI, 1 ) ) & "__u",
				   SYMBOLS.FRAME_OFFSET, VPOSES( FTOP ) );
>>>
REMPLACER PAR :
<<<
	      VPOSES( FTOP ) := VPOSES( FTOP ) + 8;
>>>

ORACLE COMMIT 1 : recompilation ; rejeu complet du pilote - tous les
"PASSE" presents, AUCUN "ECHEC" ; les quatre byte-diffs restent muets
(fasmg TC_TESTn.FAS TC_REFn && cmp TC_REFn TC_TESTn.BIN, n = 4..7) ;
executions conformes (okAH, codes 0).

## COMMIT 2 - IR + LEX : lire "nom::" et "virtual NOM"

Deux genres d'elements nouveaux, en FIN d'enumeration ELT_KIND (les
boucles P1/P2B/P3 filtrent par genre : les nouveaux y sont ignores -
commit compilable et neutre pour les temoins existants ; P2 les traite
au commit 3).

### MODIFICATION 2.1 - target_code.adb (spec IR, enumeration ELT_KIND)
ANCRE (texte existant, unique, INCHANGE) :
<<<
			     VIRT_CLOSE,								--| "end virtual"
>>>
SUPPRIMER (bloc contigu, immediatement apres l'ancre sauf mention contraire) :
<<<
			     MAP_NOTE );								--| display / hexa_show (emis sous option)
>>>
REMPLACER PAR :
<<<
			     MAP_NOTE,								--| display / hexa_show (emis sous option)
			     AREA_DEF,								--| "nom::" : zone d'adressage (VARzone, tete .fas)
			     VIRT_REOPEN );							--| "virtual NOM" : reouverture de zone (queue .fas)
>>>

### MODIFICATION 2.2 - target_code-lex.adb (PROCESS_LINE, branche label)
Le double deux-points de la tete canonique ("VARzone::") devient un
element AREA_DEF ; le simple deux-points reste un label de code. Pas de
declaration de symbole pour la zone : P2 la traite par nom (subset).
ANCRE (texte existant, unique, INCHANGE) :
<<<
    NEXT_WORD( WF, WL );
    if WL < WF
    then
      FAULT( "ligne non reconnue" );
    end if;
>>>
SUPPRIMER (bloc contigu, immediatement apres l'ancre sauf mention contraire) :
<<<
    --  label ?
    if POS <= LEN  and then  LINE( POS ) = ':'
    then
      POS := POS + 1;
      SYMBOLS.DECLARE_SYM( LINE( WF .. WL ), SYMBOLS.CODE_LABEL );
      IR.NEW_ELT( IR.LABEL_DEF, STORE( LINE( WF .. WL ) ) );
      return;
    end if;
>>>
REMPLACER PAR :
<<<
    --  label ?  ("nom:" = label de code ; "nom::" = zone d'adressage)
    if POS <= LEN  and then  LINE( POS ) = ':'
    then
      POS := POS + 1;
      if POS <= LEN  and then  LINE( POS ) = ':'
      then								--| "nom::" (VARzone de la tete canonique) :
	POS := POS + 1;							--| genre dedie, traite en P2 (frame de niveau 0)
	IR.NEW_ELT( IR.AREA_DEF, STORE( LINE( WF .. WL ) ) );
      else
	SYMBOLS.DECLARE_SYM( LINE( WF .. WL ), SYMBOLS.CODE_LABEL );
	IR.NEW_ELT( IR.LABEL_DEF, STORE( LINE( WF .. WL ) ) );
      end if;
      return;
    end if;
>>>

### MODIFICATION 2.3 - target_code-lex.adb (PROCESS_LINE, branche virtual)
La forme "virtual NOM" (queue du .fas reel : " virtual VARzone")
devient VIRT_REOPEN avec le nom en operande NAME_OP. La forme
"virtual at" est inchangee.
ANCRE (texte existant, unique, INCHANGE) :
<<<
    if EQL( WF, WL, "if" )
    then
      DO_IF;
      return;
    end if;
>>>
SUPPRIMER (bloc contigu, immediatement apres l'ancre sauf mention contraire) :
<<<
    if EQL( WF, WL, "virtual" )
    then
      NEXT_WORD( F2, L2 );						--| "at"
      if not EQL( F2, L2, "at" )
      then
	FAULT( "virtual sans at" );
      end if;
      IR.NEW_ELT( IR.VIRT_OPEN, STORE( "virtual" ) );
      PARSE_OPERANDS;							--| la base (0 ou 8)
      EMIT_OPERANDS;
      return;
    end if;
>>>
REMPLACER PAR :
<<<
    if EQL( WF, WL, "virtual" )
    then
      NEXT_WORD( F2, L2 );						--| "at" ou nom de zone
      if EQL( F2, L2, "at" )
      then
	IR.NEW_ELT( IR.VIRT_OPEN, STORE( "virtual" ) );
	PARSE_OPERANDS;							--| la base (0 ou 8)
	EMIT_OPERANDS;
      else								--| "virtual NOM" : reouverture de zone (queue du
	if L2 < F2							--| .fas reel : virtual VARzone / loc_siz = $)
	then
	  FAULT( "virtual sans at ni nom de zone" );
	end if;
	IR.NEW_ELT( IR.VIRT_REOPEN, STORE( "virtual" ) );
	IR.ADD_OP( IR.NAME_OP, STORE( LINE( F2 .. L2 ) ) );
      end if;
      return;
    end if;
>>>

ORACLE COMMIT 2 : identique au commit 1 (comportement inchange sur toutes
les entrees existantes - aucun temoin ne contient "::" ni "virtual NOM").

## COMMIT 3 - PASSES : frame de niveau 0, reouverture, affectations

P2 apprend : AREA_DEF "VARzone" (dans un virtual at) = OUVERTURE DU FRAME
DE NIVEAU 0 (FTOP := 1, VPOS := $ de la zone englobante), jamais depile ;
VIRT_REOPEN "VARzone" = mode reouverture ou "X = $" fige la position
courante du frame au sommet (le loc_siz de niveau 0, SANS align_q -
fidele a la queue emise par l'expander) ; ASSIGNMENT general =
PLAIN_VALUE par EVAL (la spec IR le promettait, il n'etait traite nulle
part). VIRT_CLOSE en mode reouverture referme le mode au lieu de depiler
STOP. Le controle final admet FTOP = 1 si et seulement si le frame 0 a
ete ouvert : strictement identique a l'existant pour TC-02..07.

### MODIFICATION 3.1 - target_code-passes.adb (en-tete de commentaire) (insertion pure)
Documentation des regles nouvelles, a la suite des regles endPRO.
ANCRE (texte existant, unique) :
<<<
--	  endPRO   : declare le label post ; align_q ; loc_siz = VPOS ;
--	             depile le contexte de frame ;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
--	  endPRO   : declare le label post ; align_q ; loc_siz = VPOS ;
--	             depile le contexte de frame ;
--	  tete .fas: "VARzone::" (dans un virtual at) OUVRE LE FRAME DE
--	             NIVEAU 0 (VPOS = base de la zone ; jamais depile) ;
--	  queue .fas: "virtual VARzone" rouvre la zone du frame courant ;
--	             "X = $" y fige la position SANS align_q (fidele a
--	             l'expander, CREATE_FAS_MAIN_FILE) ;
>>>

### MODIFICATION 3.2 - target_code-passes.adb (P2_LAYOUT, declarations) (insertion pure)
Deux etats locaux, declares AVANT les corps imbriques (ordre des
declarations Ada 83 : objets avant corps de sous-programmes).
ANCRE (texte existant, unique) :
<<<
  procedure		P2_LAYOUT		( FROM, TO :IR.ELT_ID )
  is
    S0			: constant SYMBOLS.SCOPE_ID := SYMBOLS.CURRENT_SCOPE;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
  procedure		P2_LAYOUT		( FROM, TO :IR.ELT_ID )
  is
    S0			: constant SYMBOLS.SCOPE_ID := SYMBOLS.CURRENT_SCOPE;

    FRAME0		: BOOLEAN	:= FALSE;						--| "VARzone::" vu : frame de niveau 0 ouvert
    REOPENED		: BOOLEAN	:= FALSE;						--| "virtual VARzone" en cours (X = $)
>>>

### MODIFICATION 3.3 - target_code-passes.adb (P2_LAYOUT, corps DO_ASSIGN) (insertion pure)
Nouveau corps imbrique, apres "end DO_STATOFS;" (zone des corps :
ordre Ada 83 respecte).
ANCRE (texte existant, unique) :
<<<
    end DO_STATOFS;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
    end DO_STATOFS;

    procedure		DO_ASSIGN ( E :IR.ELT_ID )
    --| affectation generale "X = expr" (les gardes n 97 sont interceptees
    --| a P0). Forme "X = $" : position courante de la VARzone ROUVERTE -
    --| le loc_siz de niveau 0 de la queue du .fas, SANS align_q (fidele a
    --| l'expander ; endPRO, lui, aligne). Sinon : EVAL, refus bruyant.
    is
      R			: constant STRING := LEX.IMAGE( IR.OP_TXT( E, 1 ) );
      RL		: NATURAL;
    begin
      if IR.N_OPS( E ) < 1
      then
	FAULT( "affectation sans expression" );
      end if;
      RL := R'LAST;
      while RL >= R'FIRST  and then  ( R( RL ) = ' '  or  R( RL ) = ASCII.HT )
      loop
	RL := RL - 1;
      end loop;
      if RL = R'FIRST  and then  R( R'FIRST ) = '$'
      then
	if not REOPENED  or else  FTOP = 0
	then
	  FAULT( "affectation de $ hors zone rouverte : "
		 & LEX.IMAGE( IR.MNEMO_OF( E ) ) );
	end if;
	SYMBOLS.DECLARE_SYM( LEX.IMAGE( IR.MNEMO_OF( E ) ),
			     SYMBOLS.PLAIN_VALUE, VPOSES( FTOP ) );
      else
	SYMBOLS.DECLARE_SYM( LEX.IMAGE( IR.MNEMO_OF( E ) ),
			     SYMBOLS.PLAIN_VALUE,
			     LEX.EVAL( IR.OP_TXT( E, 1 ) ) );
      end if;
    end DO_ASSIGN;
>>>

### MODIFICATION 3.4 - target_code-passes.adb (P2_LAYOUT, boucle : branches nouvelles)
AREA_DEF, VIRT_REOPEN et ASSIGNMENT prennent la tete de la cascade ;
la branche VIRT_OPEN passe de "if" a "elsif" (deux dernieres lignes du
remplacement). Le corps de la branche VIRT_OPEN (controles et push de
zone) est INCHANGE et n'est pas dans le bloc supprime.
ANCRE (texte existant, unique, INCHANGE) :
<<<
	if ACTIVE( EI )
	then
	  SYMBOLS.USE_SCOPE( IR.SCOPE_OF( EI ) );
>>>
SUPPRIMER (bloc contigu, immediatement apres l'ancre sauf mention contraire) :
<<<
	  if IR.KIND_OF( EI ) = IR.VIRT_OPEN
	  then
>>>
REMPLACER PAR :
<<<
	  if IR.KIND_OF( EI ) = IR.AREA_DEF
	  then								--| "VARzone::" (tete canonique, dans un virtual
	    if LEX.IMAGE( IR.MNEMO_OF( EI ) ) /= "VARzone"		--| at) : OUVERTURE DU FRAME DE NIVEAU 0 - les VAR
	    then							--| du niveau 0 y logent ; jamais depile par endPRO
	      FAULT( "zone d'adressage inconnue : "
		     & LEX.IMAGE( IR.MNEMO_OF( EI ) ) );
	    end if;
	    if STOP = 0  or else  FTOP /= 0  or else  FRAME0
	    then
	      FAULT( "VARzone:: attendu une fois, au niveau 0, dans un virtual at" );
	    end if;
	    FTOP := 1;
	    VPOSES( 1 ) := SPOSES( STOP );				--| $ courant de la zone englobante (8)
	    PPOSES( 1 ) := 8;
	    FRAME0 := TRUE;

	  elsif IR.KIND_OF( EI ) = IR.VIRT_REOPEN
	  then								--| "virtual VARzone" (queue du .fas) : le $ des
	    if IR.N_OPS( EI ) < 1					--| affectations devient la position courante du
	       or else  IR.OP_TAG( EI, 1 ) /= IR.NAME_OP		--| frame au sommet de la pile
	       or else  LEX.IMAGE( IR.OP_TXT( EI, 1 ) ) /= "VARzone"
	    then
	      FAULT( "reouverture de zone inconnue" );
	    end if;
	    if FTOP = 0  or else  REOPENED
	    then
	      FAULT( "virtual VARzone hors frame ou deja rouvert" );
	    end if;
	    REOPENED := TRUE;

	  elsif IR.KIND_OF( EI ) = IR.ASSIGNMENT
	  then								--| "X = expr" (spec IR : evaluee en P2) ; la
	    DO_ASSIGN( EI );						--| forme "X = $" exige la zone rouverte

	  elsif IR.KIND_OF( EI ) = IR.VIRT_OPEN
	  then
>>>

### MODIFICATION 3.5 - target_code-passes.adb (P2_LAYOUT, boucle : VIRT_CLOSE)
En mode reouverture, "end virtual" referme le mode ; sinon, depile la
zone statique comme avant.
ANCRE (texte existant, unique, INCHANGE) :
<<<
	    SPOSES( STOP ) := IR.OP_INT( EI, 1 );
>>>
SUPPRIMER (bloc contigu, immediatement apres l'ancre sauf mention contraire) :
<<<
	  elsif IR.KIND_OF( EI ) = IR.VIRT_CLOSE
	  then
	    if STOP = 0
	    then
	      FAULT( "end virtual sans virtual" );
	    end if;
	    STOP := STOP - 1;
>>>
REMPLACER PAR :
<<<
	  elsif IR.KIND_OF( EI ) = IR.VIRT_CLOSE
	  then
	    if REOPENED
	    then							--| fermeture de la reouverture : STOP intact
	      REOPENED := FALSE;
	    else
	      if STOP = 0
	      then
		FAULT( "end virtual sans virtual" );
	      end if;
	      STOP := STOP - 1;
	    end if;
>>>

### MODIFICATION 3.6 - target_code-passes.adb (P2_LAYOUT, controles finaux)
Le frame 0 reste legitimement ouvert en fin d'IR ; une reouverture non
fermee est un refus bruyant.
ANCRE (texte existant, unique, INCHANGE ; l'ancre SUIT ici le bloc a supprimer (controle STOP, inchange)) :
<<<
    if STOP /= 0
    then
      FAULT( "virtual sans end virtual en fin d'IR" );
    end if;
>>>
SUPPRIMER (bloc contigu, immediatement apres l'ancre sauf mention contraire) :
<<<
    if FTOP /= 0
    then
      FAULT( "PRO sans endPRO en fin d'IR" );
    end if;
>>>
REMPLACER PAR :
<<<
    if FTOP /= 0  and then  not ( FRAME0  and  FTOP = 1 )
    then
      FAULT( "PRO sans endPRO en fin d'IR" );
    end if;
    if REOPENED
    then
      FAULT( "virtual VARzone sans end virtual en fin d'IR" );
    end if;
>>>

ORACLE COMMIT 3 : identique aux commits 1-2 (branches nouvelles dormantes
sur les temoins existants : aucun AREA_DEF / VIRT_REOPEN / ASSIGNMENT
dans leurs plages P2). Rejeu complet, quatre cmp muets, executions
conformes.

## COMMIT 4 - TEMOIN TC-08 (pilote)

Le temoin reproduit TEXTUELLEMENT la tete et la queue de l'expander
(y compris la tabulation devant include, les 2/4 espaces de la tete et
l'espace unique devant "virtual VARzone"). Il exerce, pour la premiere
fois sous cmp : LINK a lvl 0 (jamais couvert par TC-06/07), les charges
et rangements a lvl 0 (S_BASE(0) = 3, FP(0) du display), la
retropropagation de loc_siz de niveau 0 au LINK de tete, un loc_siz NON
aligne (19 : q + 3 octets, cas discriminant de l'absence d'align_q), et
la coexistence du frame 0 avec un frame imbrique (modele pile).

Les CHECK internes ne visent que la machinerie NOUVELLE de P2 (offsets et
loc_siz, valeurs calculables a la main) ; la verite octet reste a l'oracle
supreme (cmp fasmg) et au verdict d'execution - pas de CHECK d'ASM_SIZE
recopiant SIZE_OF a la main.

### MODIFICATION 4.1 - target_code.adb (insertion pure, fin du pilote)
ANCRE (texte existant, unique : fin du temoin TC-07) :
<<<
      PUT_LINE( "  chmod +x TC_TEST7.BIN && ./TC_TEST7.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + temoin TC-08) :
<<<
      PUT_LINE( "  chmod +x TC_TEST7.BIN && ./TC_TEST7.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;


  --|  TEMOIN TEMPORAIRE TETE/QUEUE (TC-08) - frame de NIVEAU 0 : tete
  --|  canonique (VARzone:: dans virtual at 8, LINK 0 retropropage,
  --|  VAR de niveau 0) et queue (virtual VARzone / loc_siz = $ SANS
  --|  align_q), coexistence avec un sous-programme imbrique (modele
  --|  pile, mini-Q7). Tete et queue TEXTUELLEMENT identiques a celles
  --|  de l'expander (CREATE_FAS_MAIN_FILE). Verdict du binaire :
  --|  0 = 42 relu au niveau 0 apres ecriture par SP8 via le display,
  --|  1 = non. A RETIRER avec les autres.
  declare
    use LEX;
    use SYMBOLS;
    use IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROM8		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC niveau0 : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_TEST8.FAS" );
    PUT_LINE( F, "	include '../../src/expander/fasmg/codi_x86_64.finc'" );
    PUT_LINE( F, "STANDARD = 'STANDARD'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "  virtual at 8" );
    PUT_LINE( F, "    VARzone::" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "	LINK	0, loc_siz" );
    PUT_LINE( F, "	VAR	G8_disp, q" );
    PUT_LINE( F, "	VAR	B8_disp, b, 3" );
    PUT_LINE( F, "	LI	41" );
    PUT_LINE( F, "	Sq	0, G8_disp" );
    PUT_LINE( F, "	CALL	STANDARD., SP8" );
    PUT_LINE( F, "	Lq	0, G8_disp" );
    PUT_LINE( F, "	LI	42" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	ok8" );
    PUT_LINE( F, "	SYS_EXIT	1" );
    PUT_LINE( F, "ok8:" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, "if defined SP8_" );
    PUT_LINE( F, "	PRO	SP8" );
    PUT_LINE( F, "	ELB	1" );
    PUT_LINE( F, "	VAR	T8_disp, q" );
    PUT_LINE( F, "	Lq	0, G8_disp" );
    PUT_LINE( F, "	LI	1" );
    PUT_LINE( F, "	ADD" );
    PUT_LINE( F, "	Sq	1, T8_disp" );
    PUT_LINE( F, "	Lq	1, T8_disp" );
    PUT_LINE( F, "	Sq	0, G8_disp" );
    PUT_LINE( F, "	UNLINK	1" );
    PUT_LINE( F, "	RTD	0" );
    PUT_LINE( F, "	endPRO" );
    PUT_LINE( F, "end if" );
    PUT_LINE( F, " virtual VARzone" );
    PUT_LINE( F, "   loc_siz = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROM8 := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_TEST8.FAS" );
    PASSES.P1_REACH;
    PASSES.P2_LAYOUT( FROM8, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P2B_ADDRESSES( FROM8, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROM8, IR.ELT_ID( IR.ELT_COUNT ), "TC_TEST8.BIN" );

    CHECK( VALUE_OF( RESOLVE( "STANDARD.G8_disp" ) ) = 8
	   and then VALUE_OF( RESOLVE( "STANDARD.B8_disp" ) ) = 16,
	   "VAR de niveau 0 dans le frame 0 (8, 16)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.loc_siz" ) ) = 19,
	   "loc_siz de niveau 0 NON aligne (attendu 19), obtenu"
	   & LONG_INTEGER'IMAGE( VALUE_OF( RESOLVE( "STANDARD.loc_siz" ) ) ) );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.SP8.T8_disp" ) ) = 8
	   and then VALUE_OF( RESOLVE( "STANDARD.SP8.loc_siz" ) ) = 16,
	   "frame imbrique intact (pile : T8 8, loc_siz 16)" );

    if OK
    then
      PUT_LINE( "PASSE niveau0" );
      PUT_LINE( "TC_TEST8.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_TEST8.FAS TC_REF8 && cmp TC_REF8 TC_TEST8.BIN" );
      PUT_LINE( "  chmod +x TC_TEST8.BIN && ./TC_TEST8.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;

>>>

ORACLE COMMIT 4 (quadruple, hierarchie par 5 de la note) :
(a) BYTE-DIFF : fasmg TC_TEST8.FAS TC_REF8 && cmp TC_REF8 TC_TEST8.BIN
    -> muet. Au premier ecart : offset + hexdump, bissection (les
    premiers candidats a auditer sont l'encodage LINK/Sq/Lq a lvl 0,
    exerce ici pour la premiere fois).
(b) CONFORMITE D'ENTREE : fasmg accepte TC_TEST8.FAS (il le doit : tete
    et queue sont celles du .fas reel).
(c) TEMOIN AUTO-JUGEANT : "PASSE niveau0", aucun "ECHEC" ; execution :
    ./TC_TEST8.BIN ; echo $? -> 0.
(d) REJOUABILITE : les cmp TC-04..07 restent muets, executions conformes.

## CLOTURE (documentation, pas de code)

- NOTE_SUBSET_FASMG : par 1.2 - "VARzone:: et frame de niveau 0 : LUS"
  (TC-08) ; noter la regle loc_siz de niveau 0 SANS align_q. Par 2.2 -
  frame 0 dans le modele pile. Par 5 - jalon FINC-reel : rayer le
  premier morceau ; restent USEINFO partie code, EXC_MACH/EXC_RAISE,
  puis l'unite reelle + miroirs (n 110, Q7 via DEBUG_LLIR).
- JOURNAL_SESSIONS : consigner la purge du residu USEINFO (1.1) et les
  DEUX pieges releves en chemin, a verser aussi dans PIEGES :
  (i) les macros codi declarees avec "?" (LVa?, LINK?...) sont
  INSENSIBLES A LA CASSE cote fasmg, et l'expander emet "LVA" dans la
  tete du .fas reel alors que MNEMO_IS compare en casse stricte - a
  resoudre a la tranche EXC/tete reelle ;
  (ii) le temoin TC-08 est le premier a exercer lvl 0 dans LINK et les
  charges/rangements : toute divergence cmp commence par la.
