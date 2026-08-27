# LIVRAISON TC-24 - REDEFINITION SEQUENTIELLE DES VAR (corpus ADA_COMP)
(23 aout 2026 - s'applique sur l'etat POST-TC-23.)

RELEVE : GFP_disp declare DEUX FOIS FRAME_OFFSET dans HASH_SEARCH_L148.
La macro VAR du codi fait 'name_disp = $' - assignation fasmg
REDEFINISSABLE : fasmg avale le doublon (verifie en micro-test, deux
emplacements reserves) et lie chaque REFERENCE a la definition la plus
recente AU POINT DU TEXTE. Notre resolution etant tardive (P2B/P3), il
faut restituer cette temporalite : des EPOQUES.

MECANIQUE : chaque cellule porte BIRTH (0 = de tout temps). Seules les
OMBRES - cellules creees par redefinition d'un FRAME_OFFSET sur un
FRAME_OFFSET - naissent a l'epoque de leur element declarant. FIND
parcourt sa chaine (plus recente d'abord) et rend la premiere cellule
nee avant ou a l'epoque courante ; P2, P2B, P3 et les differes
estampillent l'element en cours ; hors boucle (temoins, EVAL libre),
l'epoque par defaut NATURAL'LAST rend tout visible, la plus recente
l'emportant - le comportement d'hier. Toute autre duplication reste
refusee bruyamment.

## COMMIT 1 - SYMBOLS : les epoques

### MODIFICATION 1.1 - target_code-symbols.adb (insertion pure)
ANCRE (texte existant, unique) :
<<<
  POOL_TOP		: NATURAL			:= 0;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
  POOL_TOP		: NATURAL			:= 0;

  EPOCH		: NATURAL			:= NATURAL'LAST;				--| element en cours des boucles P2/P2B/P3 ;
											--| LAST hors boucle : tout visible (TC-24)
>>>

### MODIFICATION 1.2 - target_code-symbols.adb (sur place, auto-localisee)
La cellule porte sa naissance.
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
			  UNDER		: SCOPE_ID	:= 0;					--| scope OUVERT par ce symbole (SCOPE_NAME)
>>>
REMPLACER PAR :
<<<
			  UNDER		: SCOPE_ID	:= 0;					--| scope OUVERT par ce symbole (SCOPE_NAME)
			  BIRTH		: NATURAL		:= 0;				--| 0 = de tout temps ; ombres : element declarant
>>>

### MODIFICATION 1.3 - target_code-symbols.adb (FIND reecrite, filtree par epoque)
NOTE : si votre FIND actuelle differe de l'ancre, reporter seulement le
critere BIRTH <= EPOCH dans le test de correspondance.
ANCRE = BLOC A SUPPRIMER (la fonction FIND actuelle, integralement) :
<<<
  function		FIND ( SCOPE :SCOPE_ID; NAME :STRING ) return SYM_ID
  is			----

    S			: SYM_ID	:= BUCKETS( HASH_OF( SCOPE, NAME ) );

  begin
    while  S /= NO_SYM  loop
      if  TABLE( S ).SCOPE = SCOPE  and then  SAME_NAME( S, NAME )  then
        return  S;
      end if;
      S := TABLE( S ).NEXT_H;
    end loop;
    return  NO_SYM;

  end	FIND;
>>>
REMPLACER PAR :
<<<
  function		FIND		( SCOPE :SCOPE_ID; NAME :STRING )		return SYM_ID
  is			----
    S	: SYM_ID	:= BUCKETS( HASH_OF( SCOPE, NAME ) );
  begin
    while  S /= NO_SYM  loop
      if  TABLE( S ).SCOPE = SCOPE
	and then  TABLE( S ).BIRTH <= EPOCH							--| epoque : la definition la plus recente
	and then  POOL( TABLE( S ).NAME_FIRST .. TABLE( S ).NAME_LAST ) = NAME				--| deja nee au point du texte (TC-24)
      then
	return  S;
      end if;
      S := TABLE( S ).NEXT_H;
    end loop;
    return  NO_SYM;
  end	FIND;
>>>

### MODIFICATION 1.4 - target_code-symbols.adb (insertion pure)
ANCRE (texte existant, unique) :
<<<
  end	FIND;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
  end	FIND;
	----

			---------
  procedure		SET_EPOCH	( N :NATURAL )							--| estampille des boucles d'elements (TC-24)
  is			---------
  begin
    EPOCH := N;
  end	SET_EPOCH;
	---------
>>>

### MODIFICATION 1.5 - target_code-symbols.adb (insertion pure)
DECLARE_IN : l'ombre - redefinition d'un FRAME_OFFSET par un
FRAME_OFFSET, fidele au 'name = $' fasmg. Toute autre duplication
reste refusee.
ANCRE (texte existant, unique) :
<<<
    if  CLASS = LAZY_MARK  and then  TABLE( F ).CLASS = LAZY_MARK  then
      return  F;
    end if;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
    if  CLASS = LAZY_MARK  and then  TABLE( F ).CLASS = LAZY_MARK  then
      return  F;
    end if;

    if  CLASS = FRAME_OFFSET  and then  TABLE( F ).CLASS = FRAME_OFFSET  then				--| VAR redefini (name = $ fasmg : GFP_disp
      declare											--| d'ADA_COMP) : OMBRE nee a l'epoque de
        S	: constant SYM_ID := NEW_CELL( SCOPE, NAME, CLASS, VALUE );					--| l'element declarant - les references
      begin											--| anterieures gardent l'ancienne (TC-24)
        TABLE( S ).BIRTH := EPOCH;
        return  S;
      end;
    end if;
>>>

### MODIFICATION 1.6 - target_code.adb (insertion pure)
Le spec SYMBOLS expose SET_EPOCH.
ANCRE (texte existant, unique) :
<<<
    function  SCOPE_COUNT				return NATURAL;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
    function  SCOPE_COUNT				return NATURAL;
    procedure SET_EPOCH		( N :NATURAL );							--| epoque des boucles d'elements (TC-24)
>>>

ORACLE COMMIT 1 : compilation ; rejeu integral muet (EPOCH par defaut
NATURAL'LAST et BIRTH 0 partout : FIND se comporte comme hier tant
qu'aucune ombre n'existe).

## COMMIT 2 - PASSES/EMITS : estampiller les boucles

### MODIFICATION 2.1 - target_code-passes.adb (insertion pure)
P2 : l'epoque de l'element en cours.
ANCRE (texte existant, unique) :
<<<
    for  E in FROM .. TO  loop
      declare
        EI	:constant IR.ELT_ID		:= IR.ELT_ID( E );
      begin
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
    for  E in FROM .. TO  loop
      declare
        EI	:constant IR.ELT_ID		:= IR.ELT_ID( E );
      begin
	SYMBOLS.SET_EPOCH( NATURAL( E ) );								--| epoque du texte (TC-24)
>>>

### MODIFICATION 2.2 - target_code-emits.adb (insertion pure)
P2B : idem.
ANCRE (texte existant, unique) :
<<<
    for  E in FROM .. TO  loop
      if  PASSES.ACTIVE( E )  then
        SYMBOLS.USE_SCOPE( IR.SCOPE_OF( E ) );
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
    for  E in FROM .. TO  loop
      if  PASSES.ACTIVE( E )  then
        SYMBOLS.USE_SCOPE( IR.SCOPE_OF( E ) );
        SYMBOLS.SET_EPOCH( NATURAL( E ) );								--| epoque du texte (TC-24)
>>>

### MODIFICATION 2.3 - target_code-emits.adb (insertion pure)
P3 : idem (la boucle du contrat SIZE_OF = ENCODE).
ANCRE (texte existant, unique) :
<<<
    for E in FROM .. TO
    loop
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
    for E in FROM .. TO
    loop
      SYMBOLS.SET_EPOCH( NATURAL( E ) );								--| epoque du texte (TC-24)
>>>

### MODIFICATION 2.4 - target_code-emits.adb (sur place, auto-localisee)
Differes : l'epoque de l'element differe (le STR/CST vit a son point
du texte).
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
	SYMBOLS.USE_SCOPE( IR.SCOPE_OF( E ) );
	if E < FROM  or else  E > TO
>>>
REMPLACER PAR :
<<<
	SYMBOLS.USE_SCOPE( IR.SCOPE_OF( E ) );
	SYMBOLS.SET_EPOCH( NATURAL( E ) );								--| epoque du texte (TC-24)
	if E < FROM  or else  E > TO
>>>

### MODIFICATION %s - %s (sur place : restauration d'epoque en sortie de %s)
NOTE : la boucle des differes va en ordre inverse - sans restauration,
l'epoque resterait figee sur le premier element global.
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
    SYMBOLS.USE_SCOPE( S0 );

  end	P2_LAYOUT;
>>>
REMPLACER PAR :
<<<
    SYMBOLS.USE_SCOPE( S0 );
    SYMBOLS.SET_EPOCH( NATURAL'LAST );								--| hors boucle : tout redevient visible (TC-24)

  end	P2_LAYOUT;
>>>

### MODIFICATION %s - %s (sur place : restauration d'epoque en sortie de %s)
NOTE : la boucle des differes va en ordre inverse - sans restauration,
l'epoque resterait figee sur le premier element global.
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
    SYMBOLS.USE_SCOPE( S0 );

  end	P2B_ADDRESSES;
>>>
REMPLACER PAR :
<<<
    SYMBOLS.USE_SCOPE( S0 );
    SYMBOLS.SET_EPOCH( NATURAL'LAST );								--| hors boucle : tout redevient visible (TC-24)

  end	P2B_ADDRESSES;
>>>

### MODIFICATION %s - %s (sur place : restauration d'epoque en sortie de %s)
NOTE : la boucle des differes va en ordre inverse - sans restauration,
l'epoque resterait figee sur le premier element global.
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
    SYMBOLS.USE_SCOPE( S0 );

  end	P3_EMIT;
>>>
REMPLACER PAR :
<<<
    SYMBOLS.USE_SCOPE( S0 );
    SYMBOLS.SET_EPOCH( NATURAL'LAST );								--| hors boucle : tout redevient visible (TC-24)

  end	P3_EMIT;
>>>

ORACLE COMMIT 2 : rejeu integral muet (les estampilles ne changent
rien tant qu'aucune ombre n'existe : BIRTH 0 partout).

## COMMIT 3 - TEMOIN TC-24 (pilote)

### MODIFICATION 3.1 - target_code.adb (insertion pure, fin du pilote)
ANCRE (texte existant, unique : fin du temoin TC-23) :
<<<
      PUT_LINE( "  chmod +x TC_TEST23.BIN && ./TC_TEST23.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + temoin TC-24) :
<<<
      PUT_LINE( "  chmod +x TC_TEST23.BIN && ./TC_TEST23.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;

  --|  TEMOIN TEMPORAIRE REDEFINITION (TC-24) - le releve ADA_COMP :
  --|  VAR GFP24 defini, reference, REDEFINI, re-reference ; les deux
  --|  emplacements coexistent et gardent chacun leur valeur (5 et 9).
  --|  L'arbitre de la temporalite est le cmp fasmg.
  --|  Verdicts : 0 = tout bon ; 3..5 = etape fautive. A RETIRER.
  declare
    use LEX;
    use SYMBOLS;
    use IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROM24		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC redef : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_TEST24.FAS" );
    PUT_LINE( F, "	include '../../src/expander/fasmg/codi_x86_64.finc'" );
    PUT_LINE( F, "STANDARD = 'STANDARD'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "  virtual at 8" );
    PUT_LINE( F, "    VARzone::" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "	LINK	0, loc_siz" );
    PUT_LINE( F, "	VAR	P24A_disp, Q" );
    PUT_LINE( F, "	VAR	P24B_disp, Q" );
    PUT_LINE( F, "; premiere definition et reference AVANT redefinition" );
    PUT_LINE( F, "	VAR	GFP24_disp, Q" );
    PUT_LINE( F, "	LVA	0, GFP24_disp" );
    PUT_LINE( F, "	SA	0, P24A_disp" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	SD	0, GFP24_disp" );
    PUT_LINE( F, "; redefinition sequentielle (name = $) et references APRES" );
    PUT_LINE( F, "	VAR	GFP24_disp, Q" );
    PUT_LINE( F, "	LVA	0, GFP24_disp" );
    PUT_LINE( F, "	SA	0, P24B_disp" );
    PUT_LINE( F, "	LI	9" );
    PUT_LINE( F, "	SD	0, GFP24_disp" );
    PUT_LINE( F, "; les deux emplacements sont DISTINCTS et gardent chacun leur valeur" );
    PUT_LINE( F, "	LA	0, P24A_disp" );
    PUT_LINE( F, "	LA	0, P24B_disp" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BF	k24_3" );
    PUT_LINE( F, "	SYS_EXIT	3" );
    PUT_LINE( F, "k24_3:" );
    PUT_LINE( F, "	LID	0, P24A_disp, 0" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k24_4" );
    PUT_LINE( F, "	SYS_EXIT	4" );
    PUT_LINE( F, "k24_4:" );
    PUT_LINE( F, "	LID	0, P24B_disp, 0" );
    PUT_LINE( F, "	LI	9" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k24_5" );
    PUT_LINE( F, "	SYS_EXIT	5" );
    PUT_LINE( F, "k24_5:" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, " virtual VARzone" );
    PUT_LINE( F, "   loc_siz = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROM24 := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_TEST24.FAS" );
    PASSES.P1_REACH;
    PASSES.P2_LAYOUT( FROM24, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P2B_ADDRESSES( FROM24, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROM24, IR.ELT_ID( IR.ELT_COUNT ), "TC_TEST24.BIN" );

    CHECK( VALUE_OF( RESOLVE( "STANDARD.GFP24_disp" ) ) = 32,
	   "hors boucle : la redefinition la plus recente (32)" );
    SET_EPOCH( NATURAL( FROM24 ) );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.GFP24_disp" ) ) = 24,
	   "a l'epoque d'avant la redefinition : l'originale (24)" );
    SET_EPOCH( NATURAL'LAST );

    if OK
    then
      PUT_LINE( "PASSE redef" );
      PUT_LINE( "TC_TEST24.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_TEST24.FAS TC_REF24 && cmp TC_REF24 TC_TEST24.BIN" );
      PUT_LINE( "  chmod +x TC_TEST24.BIN && ./TC_TEST24.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;

>>>

ORACLE (quadruple) : (a) cmp TC_REF24/TC_TEST24.BIN muet - l'ARBITRE
de la temporalite (offsets des deux emplacements, adresses liees par
position du texte) ; (b) fasmg accepte ; (c) PASSE redef,
./TC_TEST24.BIN -> 0 ; (d) batterie muette, DIS_BONJOUR / ENUM_TEST /
DIRECT_IO_TEST / SEQ_IO_TEST muets, ADA_COMP franchit ce refus.

NOTE DOCTRINE : l'ombre est restreinte au motif RELEVE (FRAME_OFFSET
sur FRAME_OFFSET). Si ADA_COMP revele d'autres classes redefinies
sequentiellement (PARAM, STATIC...), on elargira au releve, pas par
anticipation.
