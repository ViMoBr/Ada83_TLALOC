# ERRATUM TC-17 - TEMOIN : FAMILLE INDIRECTE MAL EMPLOYEE (segfault)
(21 aout 2026 - s'applique sur l'etat post-TC-17)

DIAGNOSTIC : TC_TEST17.BIN et TC_REF17 sont IDENTIQUES et segfaultent
tous deux - bug SEMANTIQUE du programme temoin, pas d'encodage. Apres
"LA 0, use__info", la pile porte &SIZ, une adresse SIMPLE. Or
"ULID , 0" (lvl=-1) fait l'indirection DOUBLE : depile une
adresse-D'ADRESSE, charge [&SIZ+0] (le dword siz = 1) comme pointeur,
puis dereference l'adresse 1 -> segfault. Idem "LIQ , , 16". Les formes
justes pour une adresse deja empilee sont les charges SIMPLES a
lvl = -1 : ULD (octets a [pop+disp]) et LQ. Regle a graver (PIEGES) :
L*/UL* a lvl -1 = adresse EMPILEE ; LI*/ULI* = adresse D'ADRESSE
(case de frame ou sommet contenant un pointeur).

## COMMIT UNIQUE - pilote : deux lignes du temoin TC-17

GLOBALE 1 - target_code.adb : remplacer PARTOUT
<<<
    PUT_LINE( F, "	ULID	, 0" );
>>>
par
<<<
    PUT_LINE( F, "	ULD	, 0" );
>>>
occurrences attendues : 1

GLOBALE 2 - target_code.adb : remplacer PARTOUT
<<<
    PUT_LINE( F, "	LIQ	, , 16" );
>>>
par
<<<
    PUT_LINE( F, "	LQ	, 16" );
>>>
occurrences attendues : 1

ORACLE : rebuild ; "PASSE blocs" ; cmp TC_REF17/TC_TEST17.BIN MUET
(les deux assembleurs reassemblent le .fas corrige a l'identique) ;
./TC_TEST17.BIN -> 0 (3..7 = etape fautive) ; rejouabilite TC-04..16.
Note : la couverture d'ULID et de LIQ ne diminue pas - le temoin TC-14
les exerce sous verdict d'execution (frame pointe, formes justes) ; le
temoin TC-17 exerce ici ULD et LQ en forme pile (-1) sur le chemin
reel use__info -> SIZ -> data_ptr.
