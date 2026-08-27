# LIVRAISON TC-09 - EXC_MACH / EXC_RAISE (pilier 11), RENOMMAGE LVA
(jalon FINC-reel, tranche B - 19 aout 2026)

PREALABLE : cette livraison s'applique sur l'etat POST-TC-08. Regles
d'application identiques a la livraison TC-08 (ancre unique inchangee,
bloc a supprimer contigu apres l'ancre, insertion pure = ancre reprise
en tete du remplacement, tabs significatifs, ASCII strict, <<< >>> hors
blocs, un commit par section avec son oracle).

CONTEXTE : l'expander emet desormais LVA partout (decision de session :
minuscule = indication de type comme La/Lw/Sq ; abreviation = tout
majuscules, LVA = Load Variable Address). Le codi declare "LVa?" - le
"?" rend la macro fasmg INSENSIBLE A LA CASSE : les octets de reference
ne bougent pas, seule la table STRICTE de TARGET_CODE doit suivre.
EXC_MACH et EXC_RAISE sont transcrits du codi (db/dd commentes = spec
d'encodage) : chemin froid, deplacements disp32 UNIFORMES, donc tailles
FIXES - l'invariant de taille deterministe est trivialement tenu.
L'assert "lvl >= 0 & lvl <= 31" du codi devient un refus bruyant.

## COMMIT 1 - RENOMMAGE LVa -> LVA (table EMITS + temoin TC-06)

Trois occurrences, toutes dans target_code (l'expander est deja passe a
LVA cote utilisateur ; le codi n'a pas a changer, "LVa?" acceptant les
deux casses).

### MODIFICATION 1.1 - target_code-emits.adb (SIZE_OF)
ANCRE (texte existant, unique, INCHANGE) :
<<<
    elsif M = "Sb"
    then
      return 8 + S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 2 );
>>>
SUPPRIMER (bloc contigu, immediatement apres l'ancre) :
<<<
    elsif M = "LVa"
>>>
REMPLACER PAR :
<<<
    elsif M = "LVA"
>>>

### MODIFICATION 1.2 - target_code-emits.adb (ENCODE)
ANCRE (texte existant, unique, INCHANGE) :
<<<
    elsif M = "Sb"
    then
      E_POP_RBX;
      E_BASE( OPV( E, 1, -1 ) );
      E_STORE_B( OPV( E, 2, 0 ) );
>>>
SUPPRIMER (bloc contigu, immediatement apres l'ancre) :
<<<
    elsif M = "LVa"
>>>
REMPLACER PAR :
<<<
    elsif M = "LVA"
>>>

### MODIFICATION 1.3 - target_code.adb (temoin TC-06)
ANCRE (texte existant, unique, INCHANGE) :
<<<
    PUT_LINE( F, "	Sa	1, 16" );
    PUT_LINE( F, "	La	1, 16" );
>>>
SUPPRIMER (bloc contigu, immediatement apres l'ancre) :
<<<
    PUT_LINE( F, "	LVa	1, 16" );
>>>
REMPLACER PAR :
<<<
    PUT_LINE( F, "	LVA	1, 16" );
>>>

ORACLE COMMIT 1 : rejeu complet - tous les PASSE, aucun ECHEC ; les cinq
cmp TC-04..08 MUETS (fasmg assemble LVA via LVa? : TC_REF6 inchange a
l'octet) ; executions conformes.

## COMMIT 2 - SIZE_OF : EXC_MACH (S_FPA(lvl) + 57) et EXC_RAISE (53)

Decompte transcrit du codi : FP_IN_RAX (3/4/7 selon lvl) + 4 mov disp32
(4x7) + mov qword imm32 (11) + lea disp32 (7) + mov rsi,r15 (3) +
mov ecx,imm32 (5) + rep movsq (3) = S_FPA + 57. EXC_RAISE : 3+7+3+7+
4+4+4+4+4+3+3+4+3 = 53.

### MODIFICATION 2.1 - target_code-emits.adb (SIZE_OF, avant le repli hors tranche) (insertion pure)
ANCRE (texte existant, unique) :
<<<
	return 10;
      end if;
      return 7;								--| code = 0 : xor edi, edi
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
	return 10;
      end if;
      return 7;								--| code = 0 : xor edi, edi

    elsif M = "EXC_MACH"
    then								--| pilier 11 : photo machine (codi) - chemin froid,
      declare								--| deplacements disp32 UNIFORMES : taille fixe
	LVL		: constant SYMBOLS.VALUE_TYPE := OPV( E, 1, 0 );
      begin
	if LVL < 0  or else  LVL > 31
	then
	  FAULT( "EXC_MACH : lvl hors 0..31 (assert du codi)" );
	end if;
	return S_FPA( LVL ) + 57;
      end;
    elsif M = "EXC_RAISE"
    then
      return 53;							--| deroulage : instance unique, taille fixe
>>>

ORACLE COMMIT 2 : compilation seule (branches inertes tant qu'ENCODE ne
suit pas : un temoin qui les exercerait echouerait au contrat
SIZE_OF = ENCODE, refus bruyant - c'est voulu, commit 3 immediatement).

## COMMIT 3 - ENCODE : EXC_MACH et EXC_RAISE (transcription byte a byte)

Les commentaires reprennent ceux du codi ; rax est clobbe (chemin froid,
documente cote codi : RAX, RCX, RSI, RDI registres de travail).

### MODIFICATION 3.1 - target_code-emits.adb (ENCODE, avant le repli hors tranche) (insertion pure)
ANCRE (texte existant, unique) :
<<<
      if IR.N_OPS( E ) >= 1  and then  IR.OP_TAG( E, 1 ) = IR.INT_OP
	 and then  IR.OP_INT( E, 1 ) /= 0
      then
	B( 16#BF# );										--| mov edi, imm32
	D32( INTEGER( IR.OP_INT( E, 1 ) ) );
      else
	B( 16#31# ); B( 16#FF# );									--| xor edi, edi
      end if;
      B( 16#0F# ); B( 16#05# );									--| syscall
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
      if IR.N_OPS( E ) >= 1  and then  IR.OP_TAG( E, 1 ) = IR.INT_OP
	 and then  IR.OP_INT( E, 1 ) /= 0
      then
	B( 16#BF# );										--| mov edi, imm32
	D32( INTEGER( IR.OP_INT( E, 1 ) ) );
      else
	B( 16#31# ); B( 16#FF# );									--| xor edi, edi
      end if;
      B( 16#0F# ); B( 16#05# );									--| syscall

    elsif M = "EXC_MACH"
    then								--| pilier 11 : photographie de l'etat machine
      declare								--| dans le contexte a [FP(lvl) + ctx]
	LVL		: constant SYMBOLS.VALUE_TYPE := OPV( E, 1, 0 );
	CTX		: constant SYMBOLS.VALUE_TYPE := OPV( E, 2, 0 );
      begin
	if LVL < 0  or else  LVL > 31
	then
	  FAULT( "EXC_MACH : lvl hors 0..31 (assert du codi)" );
	end if;
	E_FPA( LVL );							--| rax := FP(lvl)
	B( 16#48# ); B( 16#89# ); B( 16#A8# );				--| mov [rax + ctx+16], rbp
	D32( INTEGER( CTX + 16 ) );
	B( 16#48# ); B( 16#89# ); B( 16#A0# );				--| mov [rax + ctx+24], rsp
	D32( INTEGER( CTX + 24 ) );
	B( 16#4C# ); B( 16#89# ); B( 16#A8# );				--| mov [rax + ctx+32], r13
	D32( INTEGER( CTX + 32 ) );
	B( 16#4C# ); B( 16#89# ); B( 16#B0# );				--| mov [rax + ctx+40], r14
	D32( INTEGER( CTX + 40 ) );
	B( 16#48# ); B( 16#C7# ); B( 16#80# );				--| mov qword [rax + ctx+48], lvl+1   (nlvl)
	D32( INTEGER( CTX + 48 ) );
	D32( INTEGER( LVL + 1 ) );
	B( 16#48# ); B( 16#8D# ); B( 16#B8# );				--| lea rdi, [rax + ctx+56]   (dest. du prefixe)
	D32( INTEGER( CTX + 56 ) );
	B( 16#4C# ); B( 16#89# ); B( 16#FE# );				--| mov rsi, r15   (source : le display)
	B( 16#B9# );							--| mov ecx, lvl+1
	D32( INTEGER( LVL + 1 ) );
	B( 16#F3# ); B( 16#48# ); B( 16#A5# );				--| rep movsq   (FP(0..lvl) -> ctx+56..)
      end;
    elsif M = "EXC_RAISE"
    then								--| deroulage (LRM 11.4.1) : POP avant dispatch ;
      declare								--| atteint par BRA, jamais par CALL
	TOPD		: constant SYMBOLS.VALUE_TYPE := OPV( E, 1, 0 );
      begin
	B( 16#49# ); B( 16#8B# ); B( 16#1F# );				--| mov rbx, [r15]      (rbx := FP(0))
	B( 16#48# ); B( 16#8B# ); B( 16#83# );				--| mov rax, [rbx + top]   (contexte sommet)
	D32( INTEGER( TOPD ) );
	B( 16#48# ); B( 16#8B# ); B( 16#08# );				--| mov rcx, [rax]      (PREV_CTX)
	B( 16#48# ); B( 16#89# ); B( 16#8B# );				--| mov [rbx + top], rcx   (POP avant dispatch)
	D32( INTEGER( TOPD ) );
	B( 16#4C# ); B( 16#8B# ); B( 16#68# ); B( 16#20# );		--| mov r13, [rax+32]   (frame pointer co-pile)
	B( 16#4C# ); B( 16#8B# ); B( 16#70# ); B( 16#28# );		--| mov r14, [rax+40]   (sommet co-pile)
	B( 16#48# ); B( 16#8B# ); B( 16#60# ); B( 16#18# );		--| mov rsp, [rax+24]   (micro-pile purgee)
	B( 16#48# ); B( 16#8B# ); B( 16#48# ); B( 16#30# );		--| mov rcx, [rax+48]   (NXT_LVL)
	B( 16#48# ); B( 16#8D# ); B( 16#70# ); B( 16#38# );		--| lea rsi, [rax+56]
	B( 16#4C# ); B( 16#89# ); B( 16#FF# );				--| mov rdi, r15
	B( 16#F3# ); B( 16#48# ); B( 16#A5# );				--| rep movsq   (FP(0..lvl) restaures)
	B( 16#48# ); B( 16#8B# ); B( 16#68# ); B( 16#10# );		--| mov rbp, [rax+16]   (pile de travail)
	B( 16#FF# ); B( 16#60# ); B( 16#08# );				--| jmp [rax+8]   (DISPATCH du frame porteur)
      end;
>>>

ORACLE COMMIT 3 : compilation ; rejeu complet inchange (aucun temoin
existant n'emet EXC_*) ; cmp TC-04..08 muets.

## COMMIT 4 - TEMOIN TC-09 (pilote)

Le temoin reproduit le PROTOCOLE de la tete reelle (EXC_MACH puis pose
du DISPATCH et du sommet de pile de contextes) et la GEOGRAPHIE du .fas
reel (instance unique EXC_RAISE dans la region apres SYS_EXIT, atteinte
par BRA depuis le frame imbrique - la resolution du label remonte les
parents, comme exc_raise_ en vrai). Le contexte de 64 octets suit le
layout du pilier 11 : PREV(0), DISPATCH(8), RBP(16), RSP(24), R13(32),
R14(40), NLVL(48), FP(0)(56). Il exerce pour la premiere fois : les
encodages EXC_*, un operande EXPR dans un rangement (Sa 0, CTX9_disp+8,
evalue par EVAL), LVA a lvl 0, et la purge de micro-pile au deroulage
(l'adresse de retour du CALL est jetee : si EXC_RAISE ne detournait pas
le flot, SYS_EXIT 2 le dirait).

### MODIFICATION 4.1 - target_code.adb (insertion pure, fin du pilote)
ANCRE (texte existant, unique : fin du temoin TC-08) :
<<<
      PUT_LINE( "  chmod +x TC_TEST8.BIN && ./TC_TEST8.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + temoin TC-09) :
<<<
      PUT_LINE( "  chmod +x TC_TEST8.BIN && ./TC_TEST8.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;


  --|  TEMOIN TEMPORAIRE EXCEPTIONS (TC-09) - EXC_MACH 0 (photo du
  --|  contexte-sentinelle, motif exact de la tete reelle : EXC_MACH,
  --|  LCA dispatch, Sa ctx+8, LVA, Sa top), puis levee depuis un frame
  --|  imbrique : BRA vers l'instance unique EXC_RAISE (region apres
  --|  SYS_EXIT, comme le .fas reel), deroulage, dispatch sur h9_,
  --|  verification que l'etat de niveau 0 est restaure (G9 = 7 relu
  --|  sur la pile restauree). Verdict : 0 = deroulage et dispatch
  --|  corrects ; 1 = G9 faux apres deroulage ; 2 = EXC_RAISE n'a pas
  --|  detourne le flot. A RETIRER avec les autres.
  declare
    use LEX;
    use SYMBOLS;
    use IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROM9		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC exc : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_TEST9.FAS" );
    PUT_LINE( F, "	include '../../src/expander/fasmg/codi_x86_64.finc'" );
    PUT_LINE( F, "STANDARD = 'STANDARD'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "  virtual at 8" );
    PUT_LINE( F, "    VARzone::" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "	LINK	0, loc_siz" );
    PUT_LINE( F, "	VAR	CTX9_disp, 64" );
    PUT_LINE( F, "	VAR	TOP9_disp, q" );
    PUT_LINE( F, "	VAR	G9_disp, q" );
    PUT_LINE( F, "	EXC_MACH	0, CTX9_disp" );
    PUT_LINE( F, "	LCA	h9_" );
    PUT_LINE( F, "	Sa	0, CTX9_disp + 8" );
    PUT_LINE( F, "	LVA	0, CTX9_disp" );
    PUT_LINE( F, "	Sa	0, TOP9_disp" );
    PUT_LINE( F, "	LI	7" );
    PUT_LINE( F, "	Sq	0, G9_disp" );
    PUT_LINE( F, "	CALL	STANDARD., SP9" );
    PUT_LINE( F, "	SYS_EXIT	2" );
    PUT_LINE( F, "exc_raise9_:" );
    PUT_LINE( F, "	EXC_RAISE	TOP9_disp" );
    PUT_LINE( F, "h9_:" );
    PUT_LINE( F, "	Lq	0, G9_disp" );
    PUT_LINE( F, "	LI	7" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	ok9" );
    PUT_LINE( F, "	SYS_EXIT	1" );
    PUT_LINE( F, "ok9:" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, "if defined SP9_" );
    PUT_LINE( F, "	PRO	SP9" );
    PUT_LINE( F, "	ELB	1" );
    PUT_LINE( F, "	VAR	T9_disp, q" );
    PUT_LINE( F, "	LI	13" );
    PUT_LINE( F, "	Sq	1, T9_disp" );
    PUT_LINE( F, "	BRA	exc_raise9_" );
    PUT_LINE( F, "	UNLINK	1" );
    PUT_LINE( F, "	RTD	0" );
    PUT_LINE( F, "	endPRO" );
    PUT_LINE( F, "end if" );
    PUT_LINE( F, " virtual VARzone" );
    PUT_LINE( F, "   loc_siz = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROM9 := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_TEST9.FAS" );
    PASSES.P1_REACH;
    PASSES.P2_LAYOUT( FROM9, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P2B_ADDRESSES( FROM9, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROM9, IR.ELT_ID( IR.ELT_COUNT ), "TC_TEST9.BIN" );

    CHECK( VALUE_OF( RESOLVE( "STANDARD.CTX9_disp" ) ) = 8
	   and then VALUE_OF( RESOLVE( "STANDARD.TOP9_disp" ) ) = 72
	   and then VALUE_OF( RESOLVE( "STANDARD.G9_disp" ) ) = 80,
	   "layout niveau 0 (ctx 8, top 72, g 80)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.loc_siz" ) ) = 88,
	   "loc_siz de niveau 0 (attendu 88), obtenu"
	   & LONG_INTEGER'IMAGE( VALUE_OF( RESOLVE( "STANDARD.loc_siz" ) ) ) );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.SP9.T9_disp" ) ) = 8
	   and then VALUE_OF( RESOLVE( "STANDARD.SP9.loc_siz" ) ) = 16,
	   "frame imbrique (T9 8, loc_siz 16)" );

    if OK
    then
      PUT_LINE( "PASSE exc" );
      PUT_LINE( "TC_TEST9.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_TEST9.FAS TC_REF9 && cmp TC_REF9 TC_TEST9.BIN" );
      PUT_LINE( "  chmod +x TC_TEST9.BIN && ./TC_TEST9.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;

>>>

ORACLE COMMIT 4 (quadruple) :
(a) BYTE-DIFF : fasmg TC_TEST9.FAS TC_REF9 && cmp TC_REF9 TC_TEST9.BIN
    -> muet. Premier suspect en cas d'ecart : la transcription EXC
    (offsets ctx+16..56, imm32 nlvl) puis LVA/Sa a lvl 0.
(b) CONFORMITE D'ENTREE : fasmg accepte TC_TEST9.FAS.
(c) TEMOIN AUTO-JUGEANT : "PASSE exc", aucun "ECHEC" ;
    ./TC_TEST9.BIN ; echo $? -> 0 (1 = etat mal restaure, 2 = flot non
    detourne).
(d) REJOUABILITE : cmp TC-04..08 muets, executions conformes.

## CLOTURE (documentation, pas de code)

- NOTE_SUBSET : par 1.2 - EXC_MACH / EXC_RAISE : LUS (TC-09) ; noter la
  convention de casse (minuscule = type La/Sq..., abreviations en
  majuscules : LVA, LCA, LSPA...) et que la table EMITS dit LVA.
- Q6 (audit EXC different du .fas reel) : SOLDE par le byte-diff TC-09.
- JOURNAL / PIEGES : renommage LVa -> LVA opere des deux cotes
  (expander par l'utilisateur, table TARGET_CODE ici) ; le codi conserve
  LVa? insensible a la casse, octets inchanges ; script de build corrige
  (target_code-ir.adb, tiret) ; premier exercice du deroulage pilier 11
  sous cmp.
- RESTE du jalon FINC-reel : USEINFO partie code, puis _STANDRD.FINC et
  une unite reelle (miroirs n 110 / Q7 sous DEBUG_LLIR=1).
