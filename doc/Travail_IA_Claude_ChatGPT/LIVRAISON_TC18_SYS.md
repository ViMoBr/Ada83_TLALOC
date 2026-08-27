# LIVRAISON TC-18 - FAMILLE SYS_* ET E/S FICHIERS (E5, premier volet)
(21 aout 2026 - s'applique sur l'etat POST-TC-17 + erratum indirect.)

CONTEXTE : l'avalement reel de DIS_BONJOUR.fas (sandbox) passe P0
(17252 elements, tous includes dont MACHINE_CODE.FINC), P1, et P2
entier apres votre renommage SIZ__ ; premier refus de P2B :
SYS_FILE_WRITE hors tranche. Cette livraison complete la table avec
les DIX SYS_* du corpus (transcrits du codi, tailles fixes) et trois
helpers. SYS_FILE_GET_POS / GET_SIZE / SYS_CLOCK_GETTIME restent hors
corpus, donc hors table (refus bruyant).

NOTE PIEGE (SIZ__) : la redefinition sequentielle STATOFS-sur-VAR est
PROUVEE (LVA lisait 16, SD lisait 0 - releve fasmg sur sequence
minimale) ; resolue A LA SOURCE par votre renommage SIZ__. Le refus de
doublon de TARGET_CODE reste STRICT ; son message enrichi (portee +
classes) est au commit 3.

## COMMIT 1 - EMITS : helpers E_POP_RDX et E_COPY_STRING_NUL

### MODIFICATION 1.1 - target_code-emits.adb (apres E_POP_RDI) (insertion pure)
ANCRE (texte existant, unique) :
<<<
  end E_POP_RDI;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
  end E_POP_RDI;

  procedure		E_POP_RDX									--| 8 octets (E/S fichiers)
  is
  begin
    B( 16#48# ); B( 16#8B# ); B( 16#55# ); B( 16#00# );							--| mov rdx, [rbp]
    B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );							--| lea rbp, [rbp-8]
  end E_POP_RDX;

  procedure		E_COPY_STRING_NUL								--| COPY_STRING_APPEND_NUL du codi (31) :
  is													--| copie la chaine Ada (doublet en rsi) sur
  begin												--| la pile montante, NUL final, rdi = debut
    B( 16#48# ); B( 16#8B# ); B( 16#46# ); B( 16#08# );							--| mov rax, [rsi+8]
    B( 16#8B# ); B( 16#48# ); B( 16#0C# );								--| mov ecx, [rax+12]
    B( 16#FF# ); B( 16#C1# );										--| inc ecx
    B( 16#2B# ); B( 16#48# ); B( 16#08# );								--| sub ecx, [rax+8]
    B( 16#48# ); B( 16#8B# ); B( 16#36# );								--| mov rsi, [rsi]
    B( 16#48# ); B( 16#8D# ); B( 16#7D# ); B( 16#08# );							--| lea rdi, [rbp+8]
    B( 16#FC# );											--| cld
    B( 16#AC# ); B( 16#AA# );										--| lodsb ; stosb
    B( 16#E2# ); B( 16#FC# );										--| loop
    B( 16#C6# ); B( 16#07# ); B( 16#00# );								--| mov byte [rdi], 0
    B( 16#48# ); B( 16#8D# ); B( 16#7D# ); B( 16#08# );							--| lea rdi, [rbp+8]
  end E_COPY_STRING_NUL;
>>>

## COMMIT 2 - EMITS : tailles et encodages des dix SYS_*

### MODIFICATION 2.1 - target_code-emits.adb (SIZE_OF, apres CO_VAR) (insertion pure)
ANCRE (texte existant, unique) :
<<<
    elsif M = "CO_VAR"
    then
      return 28;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
    elsif M = "CO_VAR"
    then
      return 28;
    elsif M = "SYS_FILE_CLOSE"
    then
      return 17;
    elsif M = "SYS_PUT_CHAR"
    then
      return 18;
    elsif M = "SYS_FILE_SET_POS"
    then
      return 28;
    elsif M = "SYS_FILE_READ"  or else  M = "SYS_FILE_WRITE"
    then
      return 33;
    elsif M = "SYS_GET_STR"
    then
      return 41;
    elsif M = "SYS_FILE_DELETE"
    then
      return 50;
    elsif M = "SYS_FILE_OPEN"
    then
      return 54;
    elsif M = "SYS_FILE_CREATE"
    then
      return 58;
    elsif M = "SYS_GET_CHAR"
    then
      return 91;
>>>

### MODIFICATION 2.2 - target_code-emits.adb (ENCODE, apres CO_VAR) (insertion pure)
ANCRE (texte existant, unique) :
<<<
      B( 16#4D# ); B( 16#8D# ); B( 16#34# ); B( 16#C6# );		--| lea r14, [r14 + 8*rax]
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
      B( 16#4D# ); B( 16#8D# ); B( 16#34# ); B( 16#C6# );		--| lea r14, [r14 + 8*rax]
    elsif M = "SYS_PUT_CHAR"
    then								--| caractere au sommet, ecrit sur stdout, DROP
      B( 16#48# ); B( 16#89# ); B( 16#EE# );
      B( 16#6A# ); B( 16#01# );
      B( 16#58# );
      B( 16#48# ); B( 16#89# ); B( 16#C2# );
      B( 16#48# ); B( 16#89# ); B( 16#C7# );
      B( 16#0F# ); B( 16#05# );
      B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );
    elsif M = "SYS_GET_CHAR"
    then								--| lecture stdin non canonique (termios modifie puis restaure)
      B( 16#48# ); B( 16#83# ); B( 16#EC# ); B( 16#40# );
      B( 16#6A# ); B( 16#10# );
      B( 16#58# );
      B( 16#48# ); B( 16#31# ); B( 16#FF# );
      B( 16#48# ); B( 16#C7# ); B( 16#C6# ); B( 16#01# ); B( 16#54# ); B( 16#00# ); B( 16#00# );
      B( 16#48# ); B( 16#89# ); B( 16#E2# );
      B( 16#0F# ); B( 16#05# );
      B( 16#83# ); B( 16#64# ); B( 16#24# ); B( 16#0C# ); B( 16#F5# );
      B( 16#6A# ); B( 16#10# );
      B( 16#58# );
      B( 16#48# ); B( 16#31# ); B( 16#FF# );
      B( 16#48# ); B( 16#C7# ); B( 16#C6# ); B( 16#02# ); B( 16#54# ); B( 16#00# ); B( 16#00# );
      B( 16#48# ); B( 16#89# ); B( 16#E2# );
      B( 16#0F# ); B( 16#05# );
      E_POP_RSI;
      B( 16#6A# ); B( 16#00# );
      B( 16#58# );
      B( 16#48# ); B( 16#89# ); B( 16#C7# );
      B( 16#6A# ); B( 16#01# );
      B( 16#5A# );
      B( 16#0F# ); B( 16#05# );
      B( 16#83# ); B( 16#4C# ); B( 16#24# ); B( 16#0C# ); B( 16#0A# );
      B( 16#6A# ); B( 16#10# );
      B( 16#58# );
      B( 16#48# ); B( 16#31# ); B( 16#FF# );
      B( 16#48# ); B( 16#C7# ); B( 16#C6# ); B( 16#02# ); B( 16#54# ); B( 16#00# ); B( 16#00# );
      B( 16#48# ); B( 16#89# ); B( 16#E2# );
      B( 16#0F# ); B( 16#05# );
      B( 16#48# ); B( 16#83# ); B( 16#C4# ); B( 16#40# );
    elsif M = "SYS_GET_STR"
    then								--| lit une ligne dans la chaine (doublet), reporte la longueur lue
      E_POP_RSI;
      B( 16#48# ); B( 16#8B# ); B( 16#46# ); B( 16#08# );
      B( 16#8B# ); B( 16#50# ); B( 16#0C# );
      B( 16#FF# ); B( 16#C2# );
      B( 16#2B# ); B( 16#50# ); B( 16#08# );
      B( 16#31# ); B( 16#C0# );
      B( 16#31# ); B( 16#FF# );
      B( 16#48# ); B( 16#8B# ); B( 16#36# );
      B( 16#0F# ); B( 16#05# );
      E_POP_RSI;
      B( 16#FF# ); B( 16#C8# );
      B( 16#89# ); B( 16#06# );
    elsif M = "SYS_FILE_CREATE"
    then								--| creat(O_CREAT|O_RDWR|O_TRUNC, u+rwx) - resultat sur [rbp]
      E_POP_RSI;
      E_COPY_STRING_NUL;
      B( 16#6A# ); B( 16#02# );
      B( 16#58# );
      B( 16#BE# ); B( 16#42# ); B( 16#02# ); B( 16#00# ); B( 16#00# );
      B( 16#BA# ); B( 16#C0# ); B( 16#01# ); B( 16#00# ); B( 16#00# );
      B( 16#0F# ); B( 16#05# );
      B( 16#48# ); B( 16#89# ); B( 16#45# ); B( 16#00# );
    elsif M = "SYS_FILE_OPEN"
    then								--| open(RDWR) - resultat sur [rbp]
      E_POP_RSI;
      E_COPY_STRING_NUL;
      B( 16#6A# ); B( 16#02# );
      B( 16#58# );
      B( 16#6A# ); B( 16#02# );
      B( 16#5E# );
      B( 16#48# ); B( 16#31# ); B( 16#D2# );
      B( 16#0F# ); B( 16#05# );
      B( 16#48# ); B( 16#89# ); B( 16#45# ); B( 16#00# );
    elsif M = "SYS_FILE_SET_POS"
    then								--| lseek(SEEK_SET) - resultat sur [rbp]
      E_POP_RDI;
      E_POP_RSI;
      B( 16#48# ); B( 16#31# ); B( 16#D2# );
      B( 16#6A# ); B( 16#08# );
      B( 16#58# );
      B( 16#0F# ); B( 16#05# );
      B( 16#48# ); B( 16#89# ); B( 16#45# ); B( 16#00# );
    elsif M = "SYS_FILE_WRITE"
    then								--| write(fd, tampon, longueur) - resultat sur [rbp]
      E_POP_RDI;
      E_POP_RSI;
      E_POP_RDX;
      B( 16#6A# ); B( 16#01# );
      B( 16#58# );
      B( 16#0F# ); B( 16#05# );
      B( 16#48# ); B( 16#89# ); B( 16#45# ); B( 16#00# );
    elsif M = "SYS_FILE_READ"
    then								--| read(fd, tampon, longueur) - resultat sur [rbp]
      E_POP_RDI;
      E_POP_RSI;
      E_POP_RDX;
      B( 16#6A# ); B( 16#00# );
      B( 16#58# );
      B( 16#0F# ); B( 16#05# );
      B( 16#48# ); B( 16#89# ); B( 16#45# ); B( 16#00# );
    elsif M = "SYS_FILE_CLOSE"
    then								--| close(fd) - resultat sur [rbp]
      E_POP_RDI;
      B( 16#6A# ); B( 16#03# );
      B( 16#58# );
      B( 16#0F# ); B( 16#05# );
      B( 16#48# ); B( 16#89# ); B( 16#45# ); B( 16#00# );
    elsif M = "SYS_FILE_DELETE"
    then								--| unlink(nom copie NUL-termine) - resultat sur [rbp]
      E_POP_RSI;
      E_COPY_STRING_NUL;
      B( 16#B8# ); B( 16#57# ); B( 16#00# ); B( 16#00# ); B( 16#00# );
      B( 16#0F# ); B( 16#05# );
      B( 16#48# ); B( 16#89# ); B( 16#45# ); B( 16#00# );
>>>

## COMMIT 3 - SYMBOLS : message de doublon instrumente (en dur)
Ce message vient de payer (SIZ / _ENUM_USE_INFO / classes en clair).

### MODIFICATION 3.1 - target_code-symbols.adb (sur place, auto-localisee)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
    FAULT( "declaration dupliquee : " & NAME );
    return NO_SYM;							--| jamais atteint
>>>
REMPLACER PAR :
<<<
    declare
      P			: constant SYM_ID := SCOPES( CURRENT ).SELF;
    begin
      if P = NO_SYM
      then
	FAULT( "declaration dupliquee (racine) : " & NAME );
      else
	FAULT( "declaration dupliquee : " & NAME & "  dans "
	       & POOL( TABLE( P ).NAME_FIRST .. TABLE( P ).NAME_LAST )
	       & "  classes " & SYM_CLASS'IMAGE( CLASS )
	       & " vs " & SYM_CLASS'IMAGE( TABLE( F ).CLASS ) );
      end if;
    end;
    return NO_SYM;							--| jamais atteint
>>>

ORACLE (quadruple) : compilation ; rejeu TC-04..17 entier (douze cmp
muets, executions conformes) ; l'avalement sandbox franchit les SYS_*
(le refus suivant, s'il existe, designe le prochain trou).
TAILLES : SYS_FILE_CLOSE 17, SYS_FILE_CREATE 58, SYS_FILE_DELETE 50, SYS_FILE_OPEN 54, SYS_FILE_READ 33, SYS_FILE_SET_POS 28, SYS_FILE_WRITE 33, SYS_GET_CHAR 91, SYS_GET_STR 41, SYS_PUT_CHAR 18.
