# LIVRAISON TC-22 - CAPACITES : JAUGES ET NOUVELLES BORNES
(23 aout 2026 - s'applique sur l'etat POST-TC-21. Preparation de
l'assemblage du compilateur entier par TARGET_CODE. Les modifications
s'appliquent DANS L'ORDRE : certaines ancres du commit 2 supposent le
commit 1 applique.)

Deux commits : (1) JAUGES - accesseurs sur les compteurs internes et
releve CARTO imprime apres chaque assemblage nomme, pour dimensionner
sur mesure plutot qu'a l'aveugle ; (2) NOUVELLES BORNES, une
modification par constante, justification en tete de chacune. Les
bornes n'affectent aucune emission : l'oracle est le rejeu muet
integral plus la ligne CARTO. Les debordements sont deja bruyants
partout (TEXT_MAX, POOL_MAX, ELT_MAX) - rien a corriger de ce cote.

## COMMIT 1 - JAUGES

### MODIFICATION 1.1 - target_code.adb (insertion pure)
ANCRE (texte existant, unique) :
<<<
    TEXT_MAX		: constant	:= 2_000_000;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
    TEXT_MAX		: constant	:= 2_000_000;
    function  TEXT_USED					return NATURAL;				--| jauge : occupation de la reserve de texte
>>>

### MODIFICATION 1.2 - target_code.adb (insertion pure)
ANCRE (texte existant, unique) :
<<<
    SCOPE_MAX		:constant			:= 16_384;
    type SCOPE_ID		is range 0 .. SCOPE_MAX;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
    SCOPE_MAX		:constant			:= 16_384;
    type SCOPE_ID		is range 0 .. SCOPE_MAX;
    function  POOL_USED					return NATURAL;				--| jauges capacites (TC-22)
    function  POOL_CAPACITY				return NATURAL;				--| borne du pool (declaree au corps)
    function  SYM_COUNT					return NATURAL;
    function  SCOPE_COUNT				return NATURAL;
>>>

### MODIFICATION 1.3 - target_code.adb (insertion pure)
ANCRE (texte existant, unique) :
<<<
    function  ASM_SIZE						return SYMBOLS.VALUE_TYPE;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
    function  ASM_SIZE						return SYMBOLS.VALUE_TYPE;
    function  BIN_CAPACITY				return NATURAL;				--| jauge : borne du tampon binaire
>>>

### MODIFICATION 1.4 - target_code-lex.adb (sur place, auto-localisee)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
end	LEX;
>>>
REMPLACER PAR :
<<<
  function		TEXT_USED				return NATURAL
  is			---------
  begin
    return TEXT_TOP;
  end	TEXT_USED;
	---------

end	LEX;
>>>

### MODIFICATION 1.5 - target_code-symbols.adb (sur place, auto-localisee)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
end	SYMBOLS;
>>>
REMPLACER PAR :
<<<
  function		POOL_USED				return NATURAL
  is			---------
  begin
    return POOL_TOP;
  end	POOL_USED;
	---------

  function		POOL_CAPACITY				return NATURAL
  is			-------------
  begin
    return POOL_MAX;
  end	POOL_CAPACITY;
	-------------

  function		SYM_COUNT				return NATURAL
  is			---------
  begin
    return NATURAL( LAST_SYM );
  end	SYM_COUNT;
	---------

  function		SCOPE_COUNT				return NATURAL
  is			-----------
  begin
    return NATURAL( LAST_SCOPE );
  end	SCOPE_COUNT;
	-----------

end	SYMBOLS;
>>>

### MODIFICATION 1.6 - target_code-emits.adb (sur place, auto-localisee)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
end	EMITS;
>>>
REMPLACER PAR :
<<<
  function		BIN_CAPACITY				return NATURAL
  is			------------
  begin
    return BIN_MAX;
  end	BIN_CAPACITY;
	------------

end	EMITS;
>>>

### MODIFICATION 1.7 - target_code.adb (insertion pure)
NOTE : imprime apres chaque assemblage nomme - le point de mesure pour
dimensionner les bornes sur le compilateur reel.
ANCRE (texte existant, unique) :
<<<
      EMITS.P3_EMIT( 1, IR.ELT_ID( IR.ELT_COUNT ), TAMPON( 1 .. LONGUEUR ) & ".x86exe" );
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
      EMITS.P3_EMIT( 1, IR.ELT_ID( IR.ELT_COUNT ), TAMPON( 1 .. LONGUEUR ) & ".x86exe" );
      PUT_LINE( "CARTO capacites :" );
      PUT_LINE( "  elements " & NATURAL'IMAGE( IR.ELT_COUNT )
		& " /" & INTEGER'IMAGE( IR.ELT_MAX )
		& "   differes" & NATURAL'IMAGE( IR.DEFER_COUNT )
		& " /" & INTEGER'IMAGE( IR.DEFER_MAX ) );
      PUT_LINE( "  texte    " & NATURAL'IMAGE( LEX.TEXT_USED )
		& " /" & INTEGER'IMAGE( LEX.TEXT_MAX ) );
      PUT_LINE( "  symboles " & NATURAL'IMAGE( SYMBOLS.SYM_COUNT )
		& " /" & INTEGER'IMAGE( SYMBOLS.SYM_MAX )
		& "   scopes" & NATURAL'IMAGE( SYMBOLS.SCOPE_COUNT )
		& " /" & INTEGER'IMAGE( SYMBOLS.SCOPE_MAX ) );
      PUT_LINE( "  pool     " & NATURAL'IMAGE( SYMBOLS.POOL_USED )
		& " /" & NATURAL'IMAGE( SYMBOLS.POOL_CAPACITY ) );
      PUT_LINE( "  octets   " & SYMBOLS.VALUE_TYPE'IMAGE( EMITS.ASM_SIZE )
		& " /" & NATURAL'IMAGE( EMITS.BIN_CAPACITY ) );
>>>

ORACLE COMMIT 1 : compilation ; rejeu integral muet (les jauges ne
touchent aucune emission) ; la ligne CARTO apparait apres chaque
assemblage nomme.

## COMMIT 2 - NOUVELLES BORNES
Dimensionnees pour l'expander complet (18 122 lignes Ada, expansion
typique x4 a x8 en FINC, soit 100-300 mille elements estimes) avec
marge x2 ; a ajuster d'apres le releve CARTO reel. Memoire statique
totale apres agrandissement : ~400 Mo (.bss), sans incidence sur la
pile.

### MODIFICATION 2.1 - target_code.adb (sur place, auto-localisee)
JUSTIFICATION : tout le texte FINC inclus y loge ; ENUM_TEST ~0,4 Mo,
compilateur estime 3-8 Mo. (Ancre POST-COMMIT-1.)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
    TEXT_MAX		: constant	:= 2_000_000;
    function  TEXT_USED
>>>
REMPLACER PAR :
<<<
    TEXT_MAX		: constant	:= 16_000_000;
    function  TEXT_USED
>>>

### MODIFICATION 2.2 - target_code.adb (sur place, auto-localisee)
JUSTIFICATION : ENUM_TEST consomme deja 19 807 elements ; estimation
compilateur 200-400 mille.
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
    ELT_MAX		: constant		:= 120_000;
>>>
REMPLACER PAR :
<<<
    ELT_MAX		: constant		:= 500_000;
>>>

### MODIFICATION 2.3 - target_code.adb (sur place, auto-localisee)
JUSTIFICATION : ratio 3 operandes/element maintenu.
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
    OPS_MAX		: constant		:= 360_000;
>>>
REMPLACER PAR :
<<<
    OPS_MAX		: constant		:= 1_500_000;
>>>

### MODIFICATION 2.4 - target_code.adb (sur place, auto-localisee)
JUSTIFICATION : l'expander porte des milliers de litteraux chaines
(messages, images d'enumeration).
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
    DEFER_MAX		: constant		:= 20_000;
>>>
REMPLACER PAR :
<<<
    DEFER_MAX		: constant		:= 100_000;
>>>

### MODIFICATION 2.5 - target_code.adb (sur place, auto-localisee)
JUSTIFICATION : environ un symbole pour 4-6 elements ; 500 mille
elements -> ~1 M avec marge.
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
    SYM_MAX		:constant			:= 262_144;
>>>
REMPLACER PAR :
<<<
    SYM_MAX		:constant			:= 1_048_576;
>>>

### MODIFICATION 2.6 - target_code.adb (sur place, auto-localisee)
JUSTIFICATION : namespaces + blocs + thunks du compilateur entier.
(Ancre POST-COMMIT-1.)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
    SCOPE_MAX		:constant			:= 16_384;
    type SCOPE_ID		is range 0 .. SCOPE_MAX;
    function  POOL_USED
>>>
REMPLACER PAR :
<<<
    SCOPE_MAX		:constant			:= 65_536;
    type SCOPE_ID		is range 0 .. SCOPE_MAX;
    function  POOL_USED
>>>

### MODIFICATION 2.7 - target_code-symbols.adb (sur place, auto-localisee)
JUSTIFICATION : noms qualifies longs (STANDARD.TEXT_IO...BLOCK__n) ;
suit SYM_MAX, x4 en moyenne par nom.
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
  POOL_MAX		:constant		:= 2_000_000;
>>>
REMPLACER PAR :
<<<
  POOL_MAX		:constant		:= 16_000_000;
>>>

### MODIFICATION 2.8 - target_code-symbols.adb (sur place, auto-localisee)
JUSTIFICATION : chaines moyennes ~16 a 1 M de symboles sinon ; sans
effet sur l'emission (identites sequentielles).
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
  HASH_MOD		:constant NATURAL	:= 8192;
>>>
REMPLACER PAR :
<<<
  HASH_MOD		:constant NATURAL	:= 65_536;
>>>

### MODIFICATION 2.9 - target_code-emits.adb (sur place, auto-localisee)
JUSTIFICATION : le binaire du compilateur pesera plusieurs Mo
(ENUM_TEST : 90 Ko).
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
  BIN_MAX			: constant			:= 4_000_000;
>>>
REMPLACER PAR :
<<<
  BIN_MAX			: constant			:= 32_000_000;
>>>

ORACLE COMMIT 2 (quadruple, par rejeu) :
(a) batterie TC-04..21 : cmp muets inchanges (aucun octet emis ne
    depend des bornes - HASH_MOD compris).
(b) DIS_BONJOUR, ENUM_TEST, DIRECT_IO_TEST, SEQ_IO_TEST : muets.
(c) La ligne CARTO donne le point de calibration ; aucune jauge ne
    devrait depasser 50 pour cent sur la plus grosse unite de test.
(d) Au premier assemblage du compilateur : si une jauge approche sa
    borne, elargir la constante concernee (une modification), rejouer.
