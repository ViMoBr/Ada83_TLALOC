# LIVRAISON TC-15 - CONVERSION DECIMALE EXACTE, UNITES VAR (erratum TC-14)
(20 aout 2026 - s'applique sur l'etat POST-TC-14)

DIAGNOSTIC DE L'ECART TC-14 (hexdump releve) : octets 0x57A et 0x58C -
le bit de poids faible des doubles de 1.0E38 et 1.0E308, un ulp SOUS la
reference fasmg. L'arrondi correct donne ..B1 / ..A0 (fasmg, verifie par
arithmetique exacte) ; la conversion naive par multiplications par 10
successives donne ..B0 / ..9F : EXACTEMENT les octets de TC_TEST14.BIN.
Le defaut est donc dans le GET flottant du runtime TLALOC (chaque
multiplication arrondit ; l'ulp se perd sur les grands exposants).
Meme famille que enumcst : programme legal, resultat inexact - a
consigner comme bug runtime, avec ce releve pour temoin.

PARADE COTE TARGET_CODE (independante du runtime) : les octets IEEE ne
viennent PLUS de FIO.GET. LEX conserve le TEXTE du litteral flottant ;
EMITS le convertit par ARITHMETIQUE DECIMALE EXACTE (division/
multiplication par 2 sur tableaux de chiffres, un SEUL arrondi, au plus
pres pair) : DEC64 remplace Q64F. FIO.GET ne sert plus qu'au temoin
lexical (FVAL, sans effet sur les octets).

S'y ajoute l'erratum des unites VAR : le corpus regenere emet B/W/D/Q
et des TAILLES NOMMEES (VAR X, NS.TYPE.size) ; la macro VAR du codi
replie la casse et fait align_q + reservation de la valeur pour les
tailles nommees (compte ignore dans cette branche : refus bruyant chez
nous). Si vous avez deja replie la casse dans DO_VAR pour faire passer
TEST14, remplacez votre correction par la forme ci-dessous.

## COMMIT 1 - PASSES : DO_VAR (casse + tailles nommees)

### MODIFICATION 1.1 - target_code-passes.adb (DO_VAR, choix de l'unite) (sur place, auto-localisee)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
      declare
	C		: constant STRING := LEX.IMAGE( IR.OP_TXT( E, 2 ) );
      begin
	if C = "b"
	then
	  UNIT := 1;
	elsif C = "w"
	then
	  UNIT := 2;
	elsif C = "d"
	then
	  UNIT := 4;
	elsif C = "q"
	then
	  UNIT := 8;
	else
	  FAULT( "caractere de taille VAR inconnu : " & C );
	end if;
      end;
      VPOSES( FTOP ) := ALIGNED( VPOSES( FTOP ), UNIT );
      SYMBOLS.DECLARE_SYM( LEX.IMAGE( IR.OP_TXT( E, 1 ) ),
			   SYMBOLS.FRAME_OFFSET, VPOSES( FTOP ) );
      VPOSES( FTOP ) := VPOSES( FTOP ) + UNIT * COUNT;
>>>
REMPLACER PAR :
<<<
      declare
	C		: constant STRING := LEX.IMAGE( IR.OP_TXT( E, 2 ) );
      begin
	if C = "b"  or else  C = "B"
	then								--| repli de casse, comme la macro VAR du codi
	  UNIT := 1;
	elsif C = "w"  or else  C = "W"
	then
	  UNIT := 2;
	elsif C = "d"  or else  C = "D"
	then
	  UNIT := 4;
	elsif C = "q"  or else  C = "Q"
	then
	  UNIT := 8;
	else								--| taille NOMMEE (corpus : VAR X, NS.TYPE.size) :
	  if IR.N_OPS( E ) >= 3						--| align_q + reservation de la valeur ; le compte
	  then								--| n'existe pas dans cette branche du codi
	    FAULT( "compte avec taille nommee (hors codi) : " & C );
	  end if;
	  VPOSES( FTOP ) := ALIGNED( VPOSES( FTOP ), 8 );
	  SYMBOLS.DECLARE_SYM( LEX.IMAGE( IR.OP_TXT( E, 1 ) ),
			       SYMBOLS.FRAME_OFFSET, VPOSES( FTOP ) );
	  VPOSES( FTOP ) := VPOSES( FTOP ) + LEX.EVAL( IR.OP_TXT( E, 2 ) );
	  return;
	end if;
      end;
      VPOSES( FTOP ) := ALIGNED( VPOSES( FTOP ), UNIT );
      SYMBOLS.DECLARE_SYM( LEX.IMAGE( IR.OP_TXT( E, 1 ) ),
			   SYMBOLS.FRAME_OFFSET, VPOSES( FTOP ) );
      VPOSES( FTOP ) := VPOSES( FTOP ) + UNIT * COUNT;
>>>

ORACLE COMMIT 1 : compilation ; rejeu inchange (unites minuscules et
litterales des temoins passes : memes chemins).

## COMMIT 2 - LEX : conserver le texte des litteraux flottants

### MODIFICATION 2.1 - target_code-lex.adb (CLASSIFY, branche flottante) (insertion pure)
ANCRE (texte existant, unique) :
<<<
	FIO.GET( LINE( A .. B ), FV, LST );
	TAGS( NOPS )  := IR.FLT_OP;
	FVALS( NOPS ) := FV;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
	FIO.GET( LINE( A .. B ), FV, LST );
	TAGS( NOPS )  := IR.FLT_OP;
	FVALS( NOPS ) := FV;
	TXTS( NOPS )  := STORE( LINE( A .. B ) );			--| le TEXTE fait foi : les octets IEEE sont
									--| produits par DEC64 (EMITS), pas par GET
>>>

ORACLE COMMIT 2 : compilation ; rejeu inchange (FVAL toujours pose :
le temoin lexical TC-01 est intact).

## COMMIT 3 - EMITS : DEC64 remplace Q64F

### MODIFICATION 3.1 - target_code-emits.adb (Q64F devient DEC64) (sur place, auto-localisee)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
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
REMPLACER PAR :
<<<
  procedure		DEC64 ( S :LEX.SLICE )
  --| litteral decimal -> IEEE 754 double, petit-boutiste, par
  --| ARITHMETIQUE DECIMALE EXACTE : la valeur vraie est representee en
  --| decimal fixe (tableaux de chiffres), normalisee par des divisions
  --| et multiplications par 2 (exactes), et arrondie UNE seule fois (au
  --| plus pres, pair en cas d'egalite). Independant du GET du runtime -
  --| le GET naif perd un ulp sur 1.0E38 / 1.0E308 (releve du 20 aout).
  --| Denormaux, infinis : hors corpus, refus bruyant.
  is
    T			: constant STRING := LEX.IMAGE( S );
    P			: NATURAL	:= T'FIRST;
    NEG			: BOOLEAN	:= FALSE;
    DIG			: array ( 1 .. 60 ) of INTEGER;
    ND			: NATURAL	:= 0;
    E10			: INTEGER	:= 0;
    ESIGN		: INTEGER	:= 1;
    EABS		: INTEGER	:= 0;
    WI			: array ( 1 .. 400 ) of INTEGER;		--| partie entiere, poids fort en tete
    LI			: NATURAL	:= 0;
    WF			: array ( 1 .. 1300 ) of INTEGER;		--| fraction, dixiemes en tete
    LF			: NATURAL	:= 0;
    E2			: INTEGER	:= 0;
    M			: SYMBOLS.VALUE_TYPE	:= 0;
    G			: INTEGER	:= 0;
    STICKY		: BOOLEAN	:= FALSE;
    ALLZ		: BOOLEAN	:= TRUE;
    BSE			: SYMBOLS.VALUE_TYPE;
    FRC			: INTEGER;

    procedure		NORM_WI
    is
    begin
      while LI > 1  and then  WI( 1 ) = 0
      loop
	for I in 1 .. LI - 1
	loop
	  WI( I ) := WI( I + 1 );
	end loop;
	LI := LI - 1;
      end loop;
      if LI = 1  and then  WI( 1 ) = 0
      then
	LI := 0;
      end if;
    end NORM_WI;

    procedure		DIV2
    is
      C			: INTEGER := 0;
      V			: INTEGER;
    begin
      for I in 1 .. LI
      loop
	V := C * 10 + WI( I );
	WI( I ) := V / 2;
	C := V mod 2;
      end loop;
      for I in 1 .. LF
      loop
	V := C * 10 + WF( I );
	WF( I ) := V / 2;
	C := V mod 2;
      end loop;
      if C = 1
      then
	if LF >= WF'LAST
	then
	  FAULT( "litteral flottant trop long (DEC64)" );
	end if;
	LF := LF + 1;
	WF( LF ) := 5;
      end if;
      NORM_WI;
    end DIV2;

    procedure		MUL2
    is
      C			: INTEGER := 0;
      V			: INTEGER;
    begin
      for I in reverse 1 .. LF
      loop
	V := WF( I ) * 2 + C;
	WF( I ) := V mod 10;
	C := V / 10;
      end loop;
      for I in reverse 1 .. LI
      loop
	V := WI( I ) * 2 + C;
	WI( I ) := V mod 10;
	C := V / 10;
      end loop;
      if C > 0
      then
	if LI >= WI'LAST
	then
	  FAULT( "depassement DEC64" );
	end if;
	for I in reverse 1 .. LI
	loop
	  WI( I + 1 ) := WI( I );
	end loop;
	LI := LI + 1;
	WI( 1 ) := C;
      end if;
    end MUL2;

  begin
    if P <= T'LAST  and then  T( P ) = '-'
    then
      NEG := TRUE;
      P := P + 1;
    end if;
    while P <= T'LAST  and then  T( P ) in '0' .. '9'
    loop
      if ND >= DIG'LAST
      then
	FAULT( "litteral flottant trop long" );
      end if;
      ND := ND + 1;
      DIG( ND ) := CHARACTER'POS( T( P ) ) - CHARACTER'POS( '0' );
      P := P + 1;
    end loop;
    if P <= T'LAST  and then  T( P ) = '.'
    then
      P := P + 1;
      while P <= T'LAST  and then  T( P ) in '0' .. '9'
      loop
	if ND >= DIG'LAST
	then
	  FAULT( "litteral flottant trop long" );
	end if;
	ND := ND + 1;
	DIG( ND ) := CHARACTER'POS( T( P ) ) - CHARACTER'POS( '0' );
	E10 := E10 - 1;
	P := P + 1;
      end loop;
    end if;
    if P <= T'LAST  and then  ( T( P ) = 'E'  or else  T( P ) = 'e' )
    then
      P := P + 1;
      if P <= T'LAST  and then  ( T( P ) = '+'  or else  T( P ) = '-' )
      then
	if T( P ) = '-'
	then
	  ESIGN := -1;
	end if;
	P := P + 1;
      end if;
      while P <= T'LAST  and then  T( P ) in '0' .. '9'
      loop
	EABS := EABS * 10 + ( CHARACTER'POS( T( P ) ) - CHARACTER'POS( '0' ) );
	P := P + 1;
      end loop;
      E10 := E10 + ESIGN * EABS;
    end if;
    if P <= T'LAST
    then
      FAULT( "litteral flottant inattendu : " & T );
    end if;

    for I in 1 .. ND
    loop
      if DIG( I ) /= 0
      then
	ALLZ := FALSE;
      end if;
    end loop;
    if ND = 0  or else  ALLZ
    then
      for I in 1 .. 7
      loop
	B( 0 );
      end loop;
      if NEG
      then
	B( 128 );
      else
	B( 0 );
      end if;
      return;
    end if;

    if E10 >= 0
    then
      if ND + E10 > WI'LAST
      then
	FAULT( "exposant decimal hors du corpus" );
      end if;
      LI := ND + E10;
      for I in 1 .. ND
      loop
	WI( I ) := DIG( I );
      end loop;
      for I in ND + 1 .. LI
      loop
	WI( I ) := 0;
      end loop;
      LF := 0;
    else
      FRC := -E10;
      if FRC > WF'LAST - 60
      then
	FAULT( "exposant decimal hors du corpus" );
      end if;
      if FRC >= ND
      then
	LI := 0;
	LF := FRC;
	for I in 1 .. FRC - ND
	loop
	  WF( I ) := 0;
	end loop;
	for I in 1 .. ND
	loop
	  WF( FRC - ND + I ) := DIG( I );
	end loop;
      else
	LI := ND - FRC;
	for I in 1 .. LI
	loop
	  WI( I ) := DIG( I );
	end loop;
	LF := FRC;
	for I in 1 .. FRC
	loop
	  WF( I ) := DIG( LI + I );
	end loop;
      end if;
    end if;
    NORM_WI;

    while LI > 1  or else  ( LI = 1  and then  WI( 1 ) >= 2 )
    loop
      DIV2;
      E2 := E2 + 1;
    end loop;
    while LI = 0
    loop
      MUL2;
      E2 := E2 - 1;
    end loop;
    LI := 0;								--| retirer le 1 de tete (valeur dans [1,2))
    for K in 1 .. 52
    loop
      MUL2;
      M := M * 2;
      if LI > 0
      then
	M := M + 1;
	LI := 0;
      end if;
    end loop;
    MUL2;
    if LI > 0
    then
      G := 1;
      LI := 0;
    end if;
    for I in 1 .. LF
    loop
      if WF( I ) /= 0
      then
	STICKY := TRUE;
      end if;
    end loop;
    if G = 1  and then  ( STICKY  or else  M mod 2 = 1 )
    then								--| arrondi au plus pres, pair en cas d'egalite
      M := M + 1;
      if M = 4503599627370496
      then								--| report de mantisse : 2**52
	M := 0;
	E2 := E2 + 1;
      end if;
    end if;
    if E2 + 1023 < 1  or else  E2 + 1023 > 2046
    then
      FAULT( "flottant hors du corpus (denormal ou infini)" );
    end if;
    BSE := SYMBOLS.VALUE_TYPE( E2 + 1023 );
    for I in 1 .. 6
    loop
      B( INTEGER( M mod 256 ) );
      M := M / 256;
    end loop;
    B( INTEGER( M mod 16 ) + INTEGER( BSE mod 16 ) * 16 );
    if NEG
    then
      B( INTEGER( BSE / 16 ) + 128 );
    else
      B( INTEGER( BSE / 16 ) );
    end if;
  end DEC64;
>>>

### MODIFICATION 3.2 - target_code-emits.adb (ENCODE, LIF : appel) (sur place, auto-localisee)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
      Q64F( IR.OP_FLT( E, 1 ) );
>>>
REMPLACER PAR :
<<<
      DEC64( IR.OP_TXT( E, 1 ) );					--| depuis le TEXTE (conversion exacte)
>>>

ORACLE COMMIT 3 : compilation ; rejeu complet ; LE VERDICT DECISIF :
cmp TC_REF14 TC_TEST14.BIN MUET sur votre machine (les octets de
1.0E38 / 1.0E308 deviennent ..B1 / ..A0, l'arrondi correct).

## COMMIT 4 - PILOTE : unites du temoin TC-14 en majuscules
(DEJA APPLIQUE CHEZ VOUS - fourni pour l'alignement des etats ;
verifier seulement que vos lignes coincident.)

GLOBALE 1 - target_code.adb : remplacer PARTOUT
<<<
    PUT_LINE( F, "	VAR	P14_disp, q" );
>>>
par
<<<
    PUT_LINE( F, "	VAR	P14_disp, Q" );
>>>
occurrences attendues : 1

GLOBALE 2 - target_code.adb : remplacer PARTOUT
<<<
    PUT_LINE( F, "	VAR	B14_disp, b, 1" );
>>>
par
<<<
    PUT_LINE( F, "	VAR	B14_disp, B, 1" );
>>>
occurrences attendues : 1

GLOBALE 3 - target_code.adb : remplacer PARTOUT
<<<
    PUT_LINE( F, "	VAR	FAR14_disp, d" );
>>>
par
<<<
    PUT_LINE( F, "	VAR	FAR14_disp, D" );
>>>
occurrences attendues : 1

ORACLE COMMIT 4 (quadruple, sur le tout) :
(a) cmp TC-04..14 TOUS muets - dont TC-14, l'ecart d'un ulp resorbe ;
(b) fasmg accepte tout (unites majuscules : repli de la macro VAR) ;
(c) rejeu complet, treize PASSE ; ./TC_TEST14.BIN -> 0 ;
(d) compilation TLALOC sans plantage (DEC64 : tableaux et entiers, rien
    d'exotique).

## CLOTURE (documentation)
- PIEGES : "GET flottant du runtime TLALOC : un ulp perdu sur les grands
  exposants (1.0E38, 1.0E308) - conversion naive par multiplications par
  10. Temoin : hexdump TC-14 du 20 aout (0x57A, 0x58C). TARGET_CODE ne
  depend plus du GET pour les octets (DEC64) ; le runtime reste a
  corriger pour toute autre utilisation (DEC64 est un modele de
  correctif)."
- NOTE_SUBSET : VAR - unites B/W/D/Q (repli de casse comme le codi) et
  TAILLES NOMMEES (align_q + valeur, compte refuse) ; LIF - octets par
  DEC64 depuis le texte.
- RESTE : E3 calcul/comparaisons/branches, E4 blocs inline, E5 avalement.
