# LIVRAISON TC-14 - FAMILLE DES ACCES (tranche E2)
(19 aout 2026 - s'applique sur l'etat POST-TC-13. Regles habituelles.)

TABLE FIGEE SUR LE CORPUS REGENERE (majuscules, codi reorganise) :
LIF, LIVA, ULB, ULD, ULIB, ULID, LID, LIQ, LIA (= LIQ), SW, SIB, SID,
SIQ - transcrits des macros du codi (BASE_IN_RAX / INDIRECT_BASE_IN_RAX
/ FETCH_* / STORE_* / PUSH_RAX). Les operandes vides prennent les
DEFAUTS du codi (lvl:-1, disp:0, ofs:0) - OPV et EMPTY_OP le font deja.
Motifs de taille (octets de base avant deplacement) : movzx octet 4,
mov 32 bits non signe 2, movsx dword 3, mov qword 3, store word 3,
store byte/dword 2, store qword 3, lea 3 (0 si deplacement nul).
LIF : movabs + 8 octets IEEE 754 double (18, fixe) - l'encodeur
extrait signe/exposant/mantisse par arithmetique exacte (puissances de
2) ; denormaux et infinis HORS CORPUS : refus bruyant.

## COMMIT 1 - EMITS : quatre helpers d'encodage + encodeur IEEE 754

### MODIFICATION 1.1 - target_code-emits.adb (apres E_STORE_Q) (insertion pure)
ANCRE (texte existant, unique) :
<<<
  procedure		E_STORE_Q ( D :SYMBOLS.VALUE_TYPE )						--| mov qword [rax+d], rbx
  is
  begin
    B( 16#48# ); B( 16#89# );
    E_MODRM_DISP( 16#18#, 16#58#, 16#98#, D );
  end E_STORE_Q;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
  procedure		E_STORE_Q ( D :SYMBOLS.VALUE_TYPE )						--| mov qword [rax+d], rbx
  is
  begin
    B( 16#48# ); B( 16#89# );
    E_MODRM_DISP( 16#18#, 16#58#, 16#98#, D );
  end E_STORE_Q;

  procedure		E_FETCH_BU ( D :SYMBOLS.VALUE_TYPE )						--| movzx rax, byte [rax+d]
  is
  begin
    B( 16#48# ); B( 16#0F# ); B( 16#B6# );
    E_MODRM_DISP( 16#00#, 16#40#, 16#80#, D );
  end E_FETCH_BU;

  procedure		E_FETCH_DU ( D :SYMBOLS.VALUE_TYPE )						--| mov eax, dword [rax+d] (zero-etend)
  is
  begin
    B( 16#8B# );
    E_MODRM_DISP( 16#00#, 16#40#, 16#80#, D );
  end E_FETCH_DU;

  procedure		E_STORE_W ( D :SYMBOLS.VALUE_TYPE )						--| mov word [rax+d], bx
  is
  begin
    B( 16#66# ); B( 16#89# );
    E_MODRM_DISP( 16#18#, 16#58#, 16#98#, D );
  end E_STORE_W;

  procedure		E_IBASE ( LVL, DISP :SYMBOLS.VALUE_TYPE )					--| INDIRECT_BASE_IN_RAX du codi :
  is													--| base (pile ou frame) puis
  begin												--| rax := [rax + disp]
    E_BASE( LVL );
    B( 16#48# ); B( 16#8B# );
    E_MODRM_DISP( 16#00#, 16#40#, 16#80#, DISP );
  end E_IBASE;
>>>

### MODIFICATION 1.2 - target_code-emits.adb (apres Q64 : encodeur flottant) (insertion pure)
ANCRE (texte existant, unique) :
<<<
  procedure		Q64 ( V :SYMBOLS.VALUE_TYPE )
  is
    U			: SYMBOLS.VALUE_TYPE := V;
  begin
    for I in 1 .. 8
    loop
      B( INTEGER( U mod 256 ) );
      U := ( U - ( U mod 256 ) ) / 256;
    end loop;
  end Q64;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
  procedure		Q64 ( V :SYMBOLS.VALUE_TYPE )
  is
    U			: SYMBOLS.VALUE_TYPE := V;
  begin
    for I in 1 .. 8
    loop
      B( INTEGER( U mod 256 ) );
      U := ( U - ( U mod 256 ) ) / 256;
    end loop;
  end Q64;

  procedure		Q64F ( V :LONG_FLOAT )								--| IEEE 754 double, petit-boutiste :
  --| extraction par arithmetique EXACTE (multiplications par 2) - la					--| 52 bits de mantisse, 11 d'exposant,
  --| mantisse de LONG_FLOAT (double hote) tient dans 52 bits, le residu				--| 1 de signe
  --| final est nul. Denormaux, infinis, NaN : hors corpus, refus bruyant.
  is
    A			: LONG_FLOAT		:= V;
    SGN			: SYMBOLS.VALUE_TYPE	:= 0;
    EXP			: INTEGER		:= 0;
    M			: SYMBOLS.VALUE_TYPE	:= 0;
    BSE			: SYMBOLS.VALUE_TYPE;
  begin
    if A = 0.0
    then
      for I in 1 .. 8
      loop
	B( 0 );
      end loop;
      return;
    end if;
    if A < 0.0
    then
      SGN := 1;
      A := -A;
    end if;
    while A >= 2.0
    loop
      A := A / 2.0;
      EXP := EXP + 1;
    end loop;
    while A < 1.0
    loop
      A := A * 2.0;
      EXP := EXP - 1;
    end loop;
    if EXP + 1023 < 1  or else  EXP + 1023 > 2046
    then
      FAULT( "flottant hors du corpus (denormal ou infini)" );
    end if;
    BSE := SYMBOLS.VALUE_TYPE( EXP + 1023 );
    A := A - 1.0;
    for I in 1 .. 52
    loop
      A := A * 2.0;
      M := M * 2;
      if A >= 1.0
      then
	M := M + 1;
	A := A - 1.0;
      end if;
    end loop;
    for I in 1 .. 6
    loop												--| six octets bas de la mantisse
      B( INTEGER( M mod 256 ) );
      M := M / 256;
    end loop;
    B( INTEGER( M mod 16 ) + INTEGER( BSE mod 16 ) * 16 );						--| 4 bits hauts de mantisse + 4 bas d'exposant
    B( INTEGER( BSE / 16 ) + INTEGER( SGN ) * 128 );							--| 7 bits hauts d'exposant + signe
  end Q64F;
>>>

ORACLE COMMIT 1 : compilation (helpers inertes tant que la table ne les
appelle pas) ; rejeu inchange.

## COMMIT 2 - SIZE_OF : douze branches

### MODIFICATION 2.1 - target_code-emits.adb (SIZE_OF, apres EXC_RAISE) (insertion pure)
ANCRE (texte existant, unique) :
<<<
    elsif M = "EXC_RAISE"
    then
      return 53;							--| deroulage : instance unique, taille fixe
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
    elsif M = "EXC_RAISE"
    then
      return 53;							--| deroulage : instance unique, taille fixe

    elsif M = "LIF"
    then
      return 18;							--| movabs + IEEE double + push (fixe)
    elsif M = "LIVA"
    then
      declare
	O		: constant SYMBOLS.VALUE_TYPE := OPV( E, 3, 0 );
      begin
	if O = 0
	then
	  return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 ) + 8;
	end if;
	return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 )
	       + S_DISP( O, 3 ) + 8;					--| lea rax, [rax+ofs]
      end;
    elsif M = "ULB"
    then
      return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 4 ) + 8;
    elsif M = "ULD"
    then
      return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 2 ) + 8;
    elsif M = "ULIB"
    then
      return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 )
	     + S_DISP( OPV( E, 3, 0 ), 4 ) + 8;
    elsif M = "ULID"
    then
      return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 )
	     + S_DISP( OPV( E, 3, 0 ), 2 ) + 8;
    elsif M = "LID"
    then
      return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 )
	     + S_DISP( OPV( E, 3, 0 ), 3 ) + 8;
    elsif M = "LIQ"  or else  M = "LIA"
    then								--| LIA = LIQ (alias du codi)
      return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 )
	     + S_DISP( OPV( E, 3, 0 ), 3 ) + 8;
    elsif M = "SW"
    then
      return 8 + S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 );
    elsif M = "SIB"
    then
      return 8 + S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 )
	     + S_DISP( OPV( E, 3, 0 ), 2 );
    elsif M = "SID"
    then
      return 8 + S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 )
	     + S_DISP( OPV( E, 3, 0 ), 2 );
    elsif M = "SIQ"
    then
      return 8 + S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 )
	     + S_DISP( OPV( E, 3, 0 ), 3 );
>>>

ORACLE COMMIT 2 : compilation ; rejeu inchange (contrat SIZE/ENCODE :
un temoin qui exercerait ces mnemoniques avant le commit 3 echouerait
bruyamment - voulu, commit 3 immediatement).

## COMMIT 3 - ENCODE : douze branches

### MODIFICATION 3.1 - target_code-emits.adb (ENCODE, apres EXC_RAISE) (insertion pure)
ANCRE (texte existant, unique) :
<<<
	B( 16#FF# ); B( 16#60# ); B( 16#08# );				--| jmp [rax+8]   (DISPATCH du frame porteur)
      end;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
	B( 16#FF# ); B( 16#60# ); B( 16#08# );				--| jmp [rax+8]   (DISPATCH du frame porteur)
      end;
    elsif M = "LIF"
    then
      if IR.N_OPS( E ) < 1  or else  IR.OP_TAG( E, 1 ) /= IR.FLT_OP
      then
	FAULT( "LIF : litteral flottant attendu" );
      end if;
      B( 16#48# ); B( 16#B8# );						--| movabs rax, imm64 (IEEE double)
      Q64F( IR.OP_FLT( E, 1 ) );
      E_PUSH_RAX;
    elsif M = "LIVA"
    then
      declare
	O		: constant SYMBOLS.VALUE_TYPE := OPV( E, 3, 0 );
      begin
	E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );
	if O /= 0
	then
	  B( 16#48# ); B( 16#8D# );					--| lea rax, [rax+ofs]
	  E_MODRM_DISP( 16#00#, 16#40#, 16#80#, O );
	end if;
	E_PUSH_RAX;
      end;
    elsif M = "ULB"
    then
      E_BASE( OPV( E, 1, -1 ) );
      E_FETCH_BU( OPV( E, 2, 0 ) );
      E_PUSH_RAX;
    elsif M = "ULD"
    then
      E_BASE( OPV( E, 1, -1 ) );
      E_FETCH_DU( OPV( E, 2, 0 ) );
      E_PUSH_RAX;
    elsif M = "ULIB"
    then
      E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );
      E_FETCH_BU( OPV( E, 3, 0 ) );
      E_PUSH_RAX;
    elsif M = "ULID"
    then
      E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );
      E_FETCH_DU( OPV( E, 3, 0 ) );
      E_PUSH_RAX;
    elsif M = "LID"
    then
      E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );
      E_FETCH_D( OPV( E, 3, 0 ) );
      E_PUSH_RAX;
    elsif M = "LIQ"  or else  M = "LIA"
    then								--| LIA = LIQ (alias du codi)
      E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );
      E_FETCH_Q( OPV( E, 3, 0 ) );
      E_PUSH_RAX;
    elsif M = "SW"
    then
      E_POP_RBX;
      E_BASE( OPV( E, 1, -1 ) );
      E_STORE_W( OPV( E, 2, 0 ) );
    elsif M = "SIB"
    then
      E_POP_RBX;
      E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );
      E_STORE_B( OPV( E, 3, 0 ) );
    elsif M = "SID"
    then
      E_POP_RBX;
      E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );
      E_STORE_D( OPV( E, 3, 0 ) );
    elsif M = "SIQ"
    then
      E_POP_RBX;
      E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );
      E_STORE_Q( OPV( E, 3, 0 ) );
>>>


## COMMIT 4 - TEMOIN TC-14 (pilote)

(Pas de temoin TC-13 : la tranche 13 etait le renommage, sans temoin
propre - sa preuve est la batterie entiere.)

### MODIFICATION 4.1 - target_code.adb (insertion pure, fin du pilote)
ANCRE (texte existant, unique : fin du temoin TC-12) :
<<<
      PUT_LINE( "  chmod +x TC_TEST12.BIN && ./TC_TEST12.BIN ; echo $?" );
      PUT_LINE( "  (attendu : c'est l'ete dit ""oui"" puis 0)" );
    end if;
  end;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + temoin TC-14) :
<<<
      PUT_LINE( "  chmod +x TC_TEST12.BIN && ./TC_TEST12.BIN ; echo $?" );
      PUT_LINE( "  (attendu : c'est l'ete dit ""oui"" puis 0)" );
    end if;
  end;

  --|  TEMOIN TEMPORAIRE ACCES (TC-14) - la famille indirecte du corpus
  --|  regenere : SIQ/SIB/SID (rangements indirects), ULIB/ULID/LID/LIQ
  --|  (charges indirectes signees et non), LIA (alias LIQ) en forme
  --|  pile a operandes VIDES (defauts du codi), LIVA (adresse
  --|  indirecte), SW en forme pile, ULB/ULD (zero-extension, dont un
  --|  deplacement 32 bits), LIF (IEEE 754 : aller-retour execute sur
  --|  10.0 ; 0.1, 0.5, 1.0E38, 1.0E308, -2.5 assembles pour le
  --|  byte-diff). Verdicts : 0 = tout bon ; 3..12 = etape fautive.
  --|  Premier LINK 0 en alloc32 (loc_siz 256). A RETIRER avec les
  --|  autres.
  declare
    use LEX;
    use SYMBOLS;
    use IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROM14		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC acces : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_TEST14.FAS" );
    PUT_LINE( F, "	include '../../src/expander/fasmg/codi_x86_64.finc'" );
    PUT_LINE( F, "STANDARD = 'STANDARD'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "  virtual at 8" );
    PUT_LINE( F, "    VARzone::" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "	LINK	0, loc_siz" );
    PUT_LINE( F, "	VAR	P14_disp, q" );
    PUT_LINE( F, "	VAR	B14_disp, b, 1" );
    PUT_LINE( F, "	VAR	PAD14_disp, 199" );
    PUT_LINE( F, "	VAR	FAR14_disp, d" );
    PUT_LINE( F, "	VAR	BLK14_disp, 24" );
    PUT_LINE( F, "	LVA	0, BLK14_disp" );
    PUT_LINE( F, "	SA	0, P14_disp" );
    PUT_LINE( F, "	LI	81985529216486895" );
    PUT_LINE( F, "	SIQ	0, P14_disp, 16" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	SIQ	0, P14_disp, 8" );
    PUT_LINE( F, "	LI	255" );
    PUT_LINE( F, "	SIB	0, P14_disp, 2" );
    PUT_LINE( F, "	LI	-2" );
    PUT_LINE( F, "	SID	0, P14_disp, 4" );
    PUT_LINE( F, "	ULIB	0, P14_disp, 2" );
    PUT_LINE( F, "	LI	255" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k1" );
    PUT_LINE( F, "	SYS_EXIT	3" );
    PUT_LINE( F, "k1:" );
    PUT_LINE( F, "	ULID	0, P14_disp, 4" );
    PUT_LINE( F, "	LI	4294967294" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k2" );
    PUT_LINE( F, "	SYS_EXIT	4" );
    PUT_LINE( F, "k2:" );
    PUT_LINE( F, "	LID	0, P14_disp, 4" );
    PUT_LINE( F, "	LI	-2" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k3" );
    PUT_LINE( F, "	SYS_EXIT	5" );
    PUT_LINE( F, "k3:" );
    PUT_LINE( F, "	LIQ	0, P14_disp, 16" );
    PUT_LINE( F, "	LI	81985529216486895" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k4" );
    PUT_LINE( F, "	SYS_EXIT	6" );
    PUT_LINE( F, "k4:" );
    PUT_LINE( F, "	LVA	0, P14_disp" );
    PUT_LINE( F, "	LIA	, , 16" );
    PUT_LINE( F, "	LI	81985529216486895" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k5" );
    PUT_LINE( F, "	SYS_EXIT	7" );
    PUT_LINE( F, "k5:" );
    PUT_LINE( F, "	LIVA	0, P14_disp, 16" );
    PUT_LINE( F, "	LVA	0, BLK14_disp + 16" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k6" );
    PUT_LINE( F, "	SYS_EXIT	8" );
    PUT_LINE( F, "k6:" );
    PUT_LINE( F, "	LVA	0, BLK14_disp + 8" );
    PUT_LINE( F, "	LI	48879" );
    PUT_LINE( F, "	SW	, 0" );
    PUT_LINE( F, "	ULD	0, BLK14_disp + 8" );
    PUT_LINE( F, "	LI	48879" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k7" );
    PUT_LINE( F, "	SYS_EXIT	9" );
    PUT_LINE( F, "k7:" );
    PUT_LINE( F, "	LI	255" );
    PUT_LINE( F, "	SB	0, B14_disp" );
    PUT_LINE( F, "	ULB	0, B14_disp" );
    PUT_LINE( F, "	LI	255" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k8" );
    PUT_LINE( F, "	SYS_EXIT	10" );
    PUT_LINE( F, "k8:" );
    PUT_LINE( F, "	LI	-1" );
    PUT_LINE( F, "	SD	0, FAR14_disp" );
    PUT_LINE( F, "	ULD	0, FAR14_disp" );
    PUT_LINE( F, "	LI	4294967295" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k9" );
    PUT_LINE( F, "	SYS_EXIT	11" );
    PUT_LINE( F, "k9:" );
    PUT_LINE( F, "	LIF	10.0" );
    PUT_LINE( F, "	SIQ	0, P14_disp, 0" );
    PUT_LINE( F, "	LIF	10.0" );
    PUT_LINE( F, "	LIQ	0, P14_disp, 0" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k10" );
    PUT_LINE( F, "	SYS_EXIT	12" );
    PUT_LINE( F, "k10:" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, "	LIF	0.1" );
    PUT_LINE( F, "	LIF	0.5" );
    PUT_LINE( F, "	LIF	1.0E38" );
    PUT_LINE( F, "	LIF	1.0E308" );
    PUT_LINE( F, "	LIF	-2.5" );
    PUT_LINE( F, " virtual VARzone" );
    PUT_LINE( F, "   loc_siz = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROM14 := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_TEST14.FAS" );
    PASSES.P1_REACH;
    PASSES.P2_LAYOUT( FROM14, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P2B_ADDRESSES( FROM14, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROM14, IR.ELT_ID( IR.ELT_COUNT ), "TC_TEST14.BIN" );

    CHECK( VALUE_OF( RESOLVE( "STANDARD.P14_disp" ) ) = 8
	   and then VALUE_OF( RESOLVE( "STANDARD.B14_disp" ) ) = 16
	   and then VALUE_OF( RESOLVE( "STANDARD.FAR14_disp" ) ) = 224
	   and then VALUE_OF( RESOLVE( "STANDARD.BLK14_disp" ) ) = 232,
	   "layout niveau 0 (8, 16, 224, 232)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.loc_siz" ) ) = 256,
	   "loc_siz 256 (LINK 0 en alloc32, premiere fois)" );

    if OK
    then
      PUT_LINE( "PASSE acces" );
      PUT_LINE( "TC_TEST14.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_TEST14.FAS TC_REF14 && cmp TC_REF14 TC_TEST14.BIN" );
      PUT_LINE( "  chmod +x TC_TEST14.BIN && ./TC_TEST14.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;

>>>

ORACLE COMMIT 4 (quadruple) :
(a) fasmg TC_TEST14.FAS TC_REF14 && cmp TC_REF14 TC_TEST14.BIN -> muet.
    Premiers suspects : les octets IEEE de 0.1 / 1.0E308 (conversion
    decimale), puis les motifs movzx/mov 32 (bases 4 et 2).
(b) fasmg accepte TC_TEST14.FAS (operandes vides comprises).
(c) "PASSE acces" ; ./TC_TEST14.BIN -> 0 (3..12 = etape fautive).
(d) cmp TC-04..12 muets, executions conformes.

## CLOTURE (documentation)
- NOTE_SUBSET par 1.2 : famille des acces LUE (TC-14) ; LIA = LIQ ;
  defauts lvl:-1/disp:0/ofs:0 par operandes vides ; encodeur IEEE 754
  (denormaux/infinis : refus bruyant).
- RESTE : E3 calcul/comparaisons/branches, E4 blocs inline (align_q en
  flot : SIZE_OF avec adresse courante), E5 avalement.
