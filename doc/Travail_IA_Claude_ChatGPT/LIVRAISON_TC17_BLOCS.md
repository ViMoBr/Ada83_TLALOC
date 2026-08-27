# LIVRAISON TC-17 - BLOCS D'IMAGES, db, BLKMOV, CO_VAR (tranche E4)
(20 aout 2026 - s'applique sur l'etat POST-TC-16. Regles habituelles.)

ARCHITECTURE : END_BLOC_DEF contient le premier ALIGNEMENT INLINE du
subset (align_q en plein flot, bourrage NOP 0x90) - sa taille depend de
l'adresse au point d'appel. P2B et P3 tiennent cette adresse
sequentiellement : une variable de module CURADDR, posee avant chaque
appel a SIZE_OF, la fournit. L'invariant de taille deterministe est
PRESERVE : l'adresse PROPRE est connue au moment du calcul, seules les
adresses futures restent interdites.

SEMANTIQUE (macros du codi) : BEGIN_BLOC_DEF = BRA IMAGES.skip + pose
de IMAGES.data (les db d'images suivent, inline, enjambes par le BRA) ;
END_BLOC_DEF siz,fst,lst = info (dd x4 : 8*len, 8, 1, len), align_q
NOP, SIZ/FST/LST/pad (dd x4), data_ptr/info_ptr (dq x2), label skip.
Les symboles IMAGES.* vivent dans un sous-scope IMAGES du namespace du
type (ENTER_SCOPE le cree/rouvre) ; SIZ/FST/LST dans le namespace du
type - tous poses a P2B (ce sont des ADRESSES). db = octets inline
(entiers 0..255 et chaines melables). BLKMOV = copie d'octets (34),
CO_VAR = allocation co-pile alignee (28).

## COMMIT 1 - EMITS : CURADDR, E_POP_RDI, DB_LEN / EMIT_DB

### MODIFICATION 1.1 - target_code-emits.adb (declarations de module) (insertion pure)
ANCRE (texte existant, unique) :
<<<
  PROLOGUE_SIZE		: constant			:= 82;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
  PROLOGUE_SIZE		: constant			:= 82;
  CURADDR		: SYMBOLS.VALUE_TYPE	:= 0;			--| adresse du POINT D'APPEL de SIZE_OF (posee par
									--| P2B et P3) : alignements INLINE (END_BLOC_DEF)
>>>

### MODIFICATION 1.2 - target_code-emits.adb (apres E_POP_RCX) (insertion pure)
ANCRE (texte existant, unique) :
<<<
  end E_POP_RCX;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
  end E_POP_RCX;

  procedure		E_POP_RDI									--| 8 octets (BLKMOV)
  is
  begin
    B( 16#48# ); B( 16#8B# ); B( 16#7D# ); B( 16#00# );							--| mov rdi, [rbp]
    B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );							--| lea rbp, [rbp-8]
  end E_POP_RDI;
>>>

### MODIFICATION 1.3 - target_code-emits.adb (apres EMIT_STR_CONTENT) (insertion pure)
ANCRE (texte existant, unique) :
<<<
  end EMIT_STR_CONTENT;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
  end EMIT_STR_CONTENT;

  function		DB_LEN ( E :IR.ELT_ID ) return SYMBOLS.VALUE_TYPE
  --| contenu d'un db : TOUS les operandes (entiers 0..255 et chaines)
  is
    N			: SYMBOLS.VALUE_TYPE := 0;
  begin
    if IR.N_OPS( E ) < 1
    then
      FAULT( "db sans contenu" );
    end if;
    for I in 1 .. IR.N_OPS( E )
    loop
      if IR.OP_TAG( E, I ) = IR.STRB_OP
      then
	N := N + STRB_LEN( IR.OP_TXT( E, I ) );
      elsif IR.OP_TAG( E, I ) = IR.INT_OP
      then
	if IR.OP_INT( E, I ) < 0  or else  IR.OP_INT( E, I ) > 255
	then
	  FAULT( "octet de db hors 0..255" );
	end if;
	N := N + 1;
      else
	FAULT( "contenu de db inattendu (chaine ou octet)" );
      end if;
    end loop;
    return N;
  end DB_LEN;

  procedure		EMIT_DB ( E :IR.ELT_ID )
  is
  begin
    for K in 1 .. IR.N_OPS( E )
    loop
      if IR.OP_TAG( E, K ) = IR.STRB_OP
      then
	declare
	  T		: constant STRING := LEX.IMAGE( IR.OP_TXT( E, K ) );
	begin
	  for I in T'RANGE
	  loop
	    B( CHARACTER'POS( T( I ) ) );
	  end loop;
	end;
      else
	B( INTEGER( IR.OP_INT( E, K ) ) );
      end if;
    end loop;
  end EMIT_DB;
>>>

## COMMIT 2 - EMITS : CURADDR pose, symboles du bloc a P2B

### MODIFICATION 2.1 - target_code-emits.adb (P2B : branches BEGIN/END_BLOC_DEF) (sur place, auto-localisee)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
	  if LEX.IMAGE( IR.MNEMO_OF( E ) ) = "ELB"
	  then								--| le label elab vit DANS la macro : adresse
	    SYMBOLS.SET_VALUE( SYMBOLS.RESOLVE( "elab" ), CUR );	--| AVANT le LINK qu'elle emet (TC-07)
	  elsif LEX.IMAGE( IR.MNEMO_OF( E ) ) = "endPRO"
	  then								--| idem pour post (cible du BRA de PRO)
	    SYMBOLS.SET_VALUE( SYMBOLS.RESOLVE( "post" ), CUR );
	  end if;
	  CUR := CUR + SIZE_OF( E );
>>>
REMPLACER PAR :
<<<
	  if LEX.IMAGE( IR.MNEMO_OF( E ) ) = "ELB"
	  then								--| le label elab vit DANS la macro : adresse
	    SYMBOLS.SET_VALUE( SYMBOLS.RESOLVE( "elab" ), CUR );	--| AVANT le LINK qu'elle emet (TC-07)
	  elsif LEX.IMAGE( IR.MNEMO_OF( E ) ) = "endPRO"
	  then								--| idem pour post (cible du BRA de PRO)
	    SYMBOLS.SET_VALUE( SYMBOLS.RESOLVE( "post" ), CUR );
	  elsif LEX.IMAGE( IR.MNEMO_OF( E ) ) = "BEGIN_BLOC_DEF"
	  then								--| IMAGES.data = adresse APRES le BRA (TC-17)
	    SYMBOLS.ENTER_SCOPE( "IMAGES" );
	    SYMBOLS.SET_VALUE( SYMBOLS.DECLARE_SYM( "data",
			       SYMBOLS.CODE_LABEL ), CUR + 5 );
	    SYMBOLS.USE_SCOPE( IR.SCOPE_OF( E ) );
	  elsif LEX.IMAGE( IR.MNEMO_OF( E ) ) = "END_BLOC_DEF"
	  then								--| ENUM_USE_INFO etendu : info a CUR, align_q
	    declare							--| NOP apres info, SIZ/FST/LST/pad (dd) puis
	      PS		: SYMBOLS.VALUE_TYPE;			--| data_ptr/info_ptr (dq) ; skip = fin, cible
	    begin							--| du BRA d'ouverture
	      PS := ( 8 - ( ( CUR + 16 ) mod 8 ) ) mod 8;
	      SYMBOLS.ENTER_SCOPE( "IMAGES" );
	      SYMBOLS.SET_VALUE( SYMBOLS.DECLARE_SYM( "data_end",
				 SYMBOLS.CODE_LABEL ), CUR );
	      SYMBOLS.SET_VALUE( SYMBOLS.DECLARE_SYM( "info",
				 SYMBOLS.CODE_LABEL ), CUR );
	      SYMBOLS.SET_VALUE( SYMBOLS.DECLARE_SYM( "data_ptr",
				 SYMBOLS.CODE_LABEL ), CUR + 16 + PS + 16 );
	      SYMBOLS.SET_VALUE( SYMBOLS.DECLARE_SYM( "info_ptr",
				 SYMBOLS.CODE_LABEL ), CUR + 16 + PS + 24 );
	      SYMBOLS.SET_VALUE( SYMBOLS.DECLARE_SYM( "skip",
				 SYMBOLS.CODE_LABEL ), CUR + 16 + PS + 32 );
	      SYMBOLS.USE_SCOPE( IR.SCOPE_OF( E ) );
	      SYMBOLS.SET_VALUE( SYMBOLS.DECLARE_SYM( "SIZ",
				 SYMBOLS.CODE_LABEL ), CUR + 16 + PS );
	      SYMBOLS.SET_VALUE( SYMBOLS.DECLARE_SYM( "FST",
				 SYMBOLS.CODE_LABEL ), CUR + 16 + PS + 4 );
	      SYMBOLS.SET_VALUE( SYMBOLS.DECLARE_SYM( "LST",
				 SYMBOLS.CODE_LABEL ), CUR + 16 + PS + 8 );
	    end;
	  end if;
	  CURADDR := CUR;						--| adresse du point d'appel (alignements inline)
	  CUR := CUR + SIZE_OF( E );
>>>

### MODIFICATION 2.2 - target_code-emits.adb (P3 : CURADDR avant le contrat) (sur place, auto-localisee)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
	T0 := TOP;
	ENCODE( E );
>>>
REMPLACER PAR :
<<<
	T0 := TOP;
	CURADDR := ORG + SYMBOLS.VALUE_TYPE( TOP );			--| pour le SIZE_OF du contrat (TC-17)
	ENCODE( E );
>>>

## COMMIT 3 - EMITS : tailles et encodages des cinq formes

### MODIFICATION 3.1 - target_code-emits.adb (SIZE_OF, apres BF) (insertion pure)
ANCRE (texte existant, unique) :
<<<
    elsif M = "BF"
    then
      return 16;							--| comme BT (jz rel32)
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
    elsif M = "BF"
    then
      return 16;							--| comme BT (jz rel32)
    elsif M = "BEGIN_BLOC_DEF"
    then
      return 5;								--| BRA IMAGES.skip (les db suivent, inline)
    elsif M = "END_BLOC_DEF"
    then								--| info dd x4 + align_q NOP + dd x4 + dq x2 :
      return 48 + ( 8 - ( ( CURADDR + 16 ) mod 8 ) ) mod 8;		--| l'adresse du point d'appel donne le bourrage
    elsif M = "db"
    then
      return DB_LEN( E );						--| octets inline
    elsif M = "BLKMOV"
    then
      return 34;
    elsif M = "CO_VAR"
    then
      return 28;
>>>

### MODIFICATION 3.2 - target_code-emits.adb (ENCODE, apres BF) (insertion pure)
ANCRE (texte existant, unique) :
<<<
      B( 16#0F# ); B( 16#84# );						--| jz rel32
      D32( INTEGER( V - ( ORG + SYMBOLS.VALUE_TYPE( TOP ) + 4 ) ) );
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
      B( 16#0F# ); B( 16#84# );						--| jz rel32
      D32( INTEGER( V - ( ORG + SYMBOLS.VALUE_TYPE( TOP ) + 4 ) ) );
    elsif M = "BEGIN_BLOC_DEF"
    then								--| BRA IMAGES.skip (resolution posee a P2B)
      V := SYMBOLS.VALUE_OF( SYMBOLS.RESOLVE( "IMAGES.skip" ) );
      B( 16#E9# );
      D32( INTEGER( V - ( ORG + SYMBOLS.VALUE_TYPE( TOP ) + 4 ) ) );
    elsif M = "END_BLOC_DEF"
    then
      declare
	D0		: constant SYMBOLS.VALUE_TYPE
			:= SYMBOLS.VALUE_OF( SYMBOLS.RESOLVE( "IMAGES.data" ) );
	D1		: constant SYMBOLS.VALUE_TYPE
			:= SYMBOLS.VALUE_OF( SYMBOLS.RESOLVE( "IMAGES.data_end" ) );
      begin
	D32( INTEGER( 8 * ( D1 - D0 ) ) );				--| info : longueur en BITS
	D32( 8 );
	D32( 1 );
	D32( INTEGER( D1 - D0 ) );
	while ( ORG + SYMBOLS.VALUE_TYPE( TOP ) ) mod 8 /= 0
	loop
	  B( 16#90# );							--| align_q : bourrage NOP
	end loop;
	D32( INTEGER( OPV( E, 1, 0 ) ) );				--| SIZ (en bits pour un enumere)
	D32( INTEGER( OPV( E, 2, 0 ) ) );				--| FST
	D32( INTEGER( OPV( E, 3, 0 ) ) );				--| LST
	D32( 0 );
	Q64( D0 );							--| data_ptr
	Q64( SYMBOLS.VALUE_OF( SYMBOLS.RESOLVE( "IMAGES.info" ) ) );	--| info_ptr
      end;
    elsif M = "db"
    then
      EMIT_DB( E );
    elsif M = "BLKMOV"
    then								--| dest, compte, source empiles (source au sommet)
      E_POP_RSI;
      E_POP_RCX;
      E_POP_RDI;
      B( 16#48# ); B( 16#85# ); B( 16#C9# );				--| test rcx, rcx
      B( 16#74# ); B( 16#05# );						--| jz +5
      B( 16#FC# );							--| cld
      B( 16#AC# );							--| lodsb
      B( 16#AA# );							--| stosb
      B( 16#E2# ); B( 16#FC# );						--| loop
    elsif M = "CO_VAR"
    then								--| alloue N octets (arrondis qword) sur la
      E_POP_RAX;							--| co-pile, empile l'adresse de debut de bloc
      B( 16#4C# ); B( 16#89# ); B( 16#75# ); B( 16#08# );		--| mov [rbp+8], r14
      B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#08# );		--| lea rbp, [rbp+8]
      B( 16#48# ); B( 16#83# ); B( 16#C0# ); B( 16#07# );		--| add rax, 7
      B( 16#48# ); B( 16#C1# ); B( 16#F8# ); B( 16#03# );		--| sar rax, 3
      B( 16#4D# ); B( 16#8D# ); B( 16#34# ); B( 16#C6# );		--| lea r14, [r14 + 8*rax]
>>>

## COMMIT 4 - TEMOIN TC-17 (pilote)

### MODIFICATION 4.1 - target_code.adb (insertion pure, fin du pilote)
ANCRE (texte existant, unique : fin du temoin TC-16) :
<<<
      PUT_LINE( "  chmod +x TC_TEST16.BIN && ./TC_TEST16.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + temoin TC-17) :
<<<
      PUT_LINE( "  chmod +x TC_TEST16.BIN && ./TC_TEST16.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;

  --|  TEMOIN TEMPORAIRE BLOCS (TC-17) - le bloc d'images de _BOOLEAN
  --|  reproduit a l'identique (BEGIN_BLOC_DEF / db val, len, chaine /
  --|  END_BLOC_DEF 1, 0, 1 / LCA SIZ / SA use__info), premier
  --|  alignement INLINE du subset (bourrage NOP d'END_BLOC_DEF),
  --|  lecture par le chemin reel (use__info -> SIZ -> data_ptr a +16
  --|  -> octets d'images), BLKMOV (copie de l'image TRUE vers le
  --|  frame), CO_VAR (allocation co-pile ecrite et relue). Verdicts :
  --|  0 = tout bon ; 3..7 = etape fautive. A RETIRER avec les autres.
  declare
    use LEX;
    use SYMBOLS;
    use IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROM17		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC blocs : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_TEST17.FAS" );
    PUT_LINE( F, "	include '../../src/expander/fasmg/codi_x86_64.finc'" );
    PUT_LINE( F, "STANDARD = 'STANDARD'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "  virtual at 8" );
    PUT_LINE( F, "    VARzone::" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "	LINK	0, loc_siz" );
    PUT_LINE( F, "_B17 = '_B17'" );
    PUT_LINE( F, "namespace _B17" );
    PUT_LINE( F, "VAR use__info, Q" );
    PUT_LINE( F, "BEGIN_BLOC_DEF" );
    PUT_LINE( F, "db 0, 5, ""FALSE""" );
    PUT_LINE( F, "db 1, 4, ""TRUE""" );
    PUT_LINE( F, "END_BLOC_DEF 1, 0, 1" );
    PUT_LINE( F, "	; SIZ en bits !" );
    PUT_LINE( F, "	LCA	SIZ" );
    PUT_LINE( F, "	SA	0, use__info" );
    PUT_LINE( F, "end namespace" );
    PUT_LINE( F, "	VAR	BUF17_disp, 8" );
    PUT_LINE( F, "	VAR	CP17_disp, Q" );
    PUT_LINE( F, "	LA	0, _B17.use__info" );
    PUT_LINE( F, "	ULID	, 0" );
    PUT_LINE( F, "	LI	1" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k17_3" );
    PUT_LINE( F, "	SYS_EXIT	3" );
    PUT_LINE( F, "k17_3:" );
    PUT_LINE( F, "	LA	0, _B17.use__info" );
    PUT_LINE( F, "	LIQ	, , 16" );
    PUT_LINE( F, "	SA	0, CP17_disp" );
    PUT_LINE( F, "	ULIB	0, CP17_disp, 2" );
    PUT_LINE( F, "	LI	70" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k17_4" );
    PUT_LINE( F, "	SYS_EXIT	4" );
    PUT_LINE( F, "k17_4:" );
    PUT_LINE( F, "	LVA	0, BUF17_disp" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	LA	0, CP17_disp" );
    PUT_LINE( F, "	LI	9" );
    PUT_LINE( F, "	ADD" );
    PUT_LINE( F, "	BLKMOV" );
    PUT_LINE( F, "	ULB	0, BUF17_disp" );
    PUT_LINE( F, "	LI	84" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k17_5" );
    PUT_LINE( F, "	SYS_EXIT	5" );
    PUT_LINE( F, "k17_5:" );
    PUT_LINE( F, "	ULB	0, BUF17_disp + 3" );
    PUT_LINE( F, "	LI	69" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k17_6" );
    PUT_LINE( F, "	SYS_EXIT	6" );
    PUT_LINE( F, "k17_6:" );
    PUT_LINE( F, "	LI	24" );
    PUT_LINE( F, "	CO_VAR" );
    PUT_LINE( F, "	SA	0, CP17_disp" );
    PUT_LINE( F, "	LI	77" );
    PUT_LINE( F, "	SIB	0, CP17_disp, 5" );
    PUT_LINE( F, "	ULIB	0, CP17_disp, 5" );
    PUT_LINE( F, "	LI	77" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k17_7" );
    PUT_LINE( F, "	SYS_EXIT	7" );
    PUT_LINE( F, "k17_7:" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, " virtual VARzone" );
    PUT_LINE( F, "   loc_siz = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROM17 := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_TEST17.FAS" );
    PASSES.P1_REACH;
    PASSES.P2_LAYOUT( FROM17, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P2B_ADDRESSES( FROM17, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROM17, IR.ELT_ID( IR.ELT_COUNT ), "TC_TEST17.BIN" );

    CHECK( VALUE_OF( RESOLVE( "STANDARD._B17.SIZ" ) ) mod 8 = 0,
	   "SIZ aligne qword (align_q inline)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD._B17.IMAGES.data_end" ) )
	     - VALUE_OF( RESOLVE( "STANDARD._B17.IMAGES.data" ) ) = 13,
	   "treize octets d'images (7 + 6)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.loc_siz" ) ) = 32,
	   "layout niveau 0 (use__info 8, BUF17 16, CP17 24 : loc_siz 32)" );

    if OK
    then
      PUT_LINE( "PASSE blocs" );
      PUT_LINE( "TC_TEST17.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_TEST17.FAS TC_REF17 && cmp TC_REF17 TC_TEST17.BIN" );
      PUT_LINE( "  chmod +x TC_TEST17.BIN && ./TC_TEST17.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;

>>>

ORACLE COMMIT 4 (quadruple) :
(a) fasmg TC_TEST17.FAS TC_REF17 && cmp -> muet. Premiers suspects :
    le bourrage NOP (position et compte) puis les dq absolus
    data_ptr / info_ptr.
(b) fasmg accepte TC_TEST17.FAS.
(c) "PASSE blocs" ; ./TC_TEST17.BIN -> 0 (3..7 = etape fautive).
(d) cmp TC-04..16 muets, executions conformes.

## CLOTURE (documentation)
- NOTE_SUBSET par 1.2 : blocs d'images LUS (TC-17) ; ARCHITECTURE :
  SIZE_OF connait desormais l'adresse du point d'appel (CURADDR, posee
  par P2B et P3) - l'invariant de taille deterministe est preserve
  (adresse propre connue, adresses futures interdites).
- E5, dernier morceau : avaler _STANDRD + TEXT_IO + IO_EXCEPTIONS +
  DIS_BONJOUR (miroirs n 110 / Q7 sous DEBUG_LLIR=1), executer
  " Bonjour", et clore le jalon FINC-reel.
