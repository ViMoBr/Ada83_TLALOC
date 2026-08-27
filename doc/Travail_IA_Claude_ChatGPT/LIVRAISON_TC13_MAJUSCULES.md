# LIVRAISON TC-13 - MNEMONIQUES EN MAJUSCULES (nouvelle convention)
(19 aout 2026 - s'applique sur l'etat POST-TC-12)

DECISION DE SESSION : machine_code produit les images d'enumeres en
majuscules ; la convention minuscule-type (TC-09) est ABANDONNEE au
profit d'une regle unique : TOUS LES MNEMONIQUES EN MAJUSCULES, cote
expander comme cote TARGET_CODE. Seul "rd" reste minuscule (directive
NATIVE fasmg, pas une macro du codi). Les macros codi sont "?"
(insensibles a la casse) : le renommage est NEUTRE A L'OCTET, ce que
l'oracle verifie.

FORME NOUVELLE : MODIFICATION GLOBALE - un motif exact (tabulations
significatives), un remplacement, et le NOMBRE D'OCCURRENCES attendu
dans le fichier. REFUSER LA MODIFICATION si le compte differe (etat
inattendu). L'ordre d'application est indifferent (motifs disjoints).

## COMMIT UNIQUE - renommage table EMITS + synthese LEX + temoins

GLOBALE 1 - target_code-emits.adb : remplacer PARTOUT
<<<
= "La"
>>>
par
<<<
= "LA"
>>>
occurrences attendues : 2

GLOBALE 2 - target_code-emits.adb : remplacer PARTOUT
<<<
= "Lq"
>>>
par
<<<
= "LQ"
>>>
occurrences attendues : 2

GLOBALE 3 - target_code-emits.adb : remplacer PARTOUT
<<<
= "Ld"
>>>
par
<<<
= "LD"
>>>
occurrences attendues : 2

GLOBALE 4 - target_code-emits.adb : remplacer PARTOUT
<<<
= "Lb"
>>>
par
<<<
= "LB"
>>>
occurrences attendues : 2

GLOBALE 5 - target_code-emits.adb : remplacer PARTOUT
<<<
= "Sa"
>>>
par
<<<
= "SA"
>>>
occurrences attendues : 2

GLOBALE 6 - target_code-emits.adb : remplacer PARTOUT
<<<
= "Sq"
>>>
par
<<<
= "SQ"
>>>
occurrences attendues : 2

GLOBALE 7 - target_code-emits.adb : remplacer PARTOUT
<<<
= "Sd"
>>>
par
<<<
= "SD"
>>>
occurrences attendues : 2

GLOBALE 8 - target_code-emits.adb : remplacer PARTOUT
<<<
= "Sb"
>>>
par
<<<
= "SB"
>>>
occurrences attendues : 2

GLOBALE 9 - target_code-lex.adb : remplacer PARTOUT
<<<
STORE( "Sa" )
>>>
par
<<<
STORE( "SA" )
>>>
occurrences attendues : 1

GLOBALE 10 - target_code.adb : remplacer PARTOUT
<<<
"	La	
>>>
par
<<<
"	LA	
>>>
occurrences attendues : 2

GLOBALE 11 - target_code.adb : remplacer PARTOUT
<<<
"	Lq	
>>>
par
<<<
"	LQ	
>>>
occurrences attendues : 7

GLOBALE 12 - target_code.adb : remplacer PARTOUT
<<<
"	Ld	
>>>
par
<<<
"	LD	
>>>
occurrences attendues : 4

GLOBALE 13 - target_code.adb : remplacer PARTOUT
<<<
"	Lb	
>>>
par
<<<
"	LB	
>>>
occurrences attendues : 1

GLOBALE 14 - target_code.adb : remplacer PARTOUT
<<<
"	Sa	
>>>
par
<<<
"	SA	
>>>
occurrences attendues : 8

GLOBALE 15 - target_code.adb : remplacer PARTOUT
<<<
"	Sq	
>>>
par
<<<
"	SQ	
>>>
occurrences attendues : 6

GLOBALE 16 - target_code.adb : remplacer PARTOUT
<<<
"	Sd	
>>>
par
<<<
"	SD	
>>>
occurrences attendues : 4

GLOBALE 17 - target_code.adb : remplacer PARTOUT
<<<
"	Sb	
>>>
par
<<<
"	SB	
>>>
occurrences attendues : 1

GLOBALE 18 - target_code.adb : remplacer PARTOUT
<<<
 	La 0,
>>>
par
<<<
 	LA 0,
>>>
occurrences attendues : 1

GLOBALE 19 - target_code.adb : remplacer PARTOUT
<<<
LIa
>>>
par
<<<
LIA
>>>
occurrences attendues : 2

NOTE : les commentaires d'EMITS citant les anciennes graphies (La,
Sq...) sont laisses tels quels - historiques, sans effet.

ORACLE (quadruple, applique au tout) :
(a) les NEUF cmp TC-04..12 MUETS - c'est la preuve de neutralite du
    renommage (macros "?" : memes octets sous les deux graphies) ;
(b) fasmg accepte les neuf .FAS regeneres (graphies majuscules) ;
(c) rejeu complet : douze PASSE, aucun ECHEC ; executions conformes
    (okAH, c'est l'ete dit + guillemets, EXCEPTION NON RATTRAPEE +
    code 1 pour TC-11, codes 0 ailleurs) ;
(d) compilation sans avertissement.

CLOTURE :
- JOURNAL / NOTE_SUBSET : convention de casse UNIQUE (majuscules) ;
  la table EMITS reste STRICTE (pas de repli de casse) - les FINC
  regeneres par l'expander uniformise doivent etre la reference du
  corpus E2. PIEGES : entree TC-09 (casse "?") mise a jour - resolue
  par uniformisation cote emetteur, pas par tolerance cote lecteur.
- PREREQUIS E2 : re-televerser les FINC regeneres (_STANDRD, TEXT_IO,
  IO_EXCEPTIONS, DIS_BONJOUR) pour figer la table des acces
  (LIA/LID/LIQ/LIF/LIVA/ULB/ULD/ULIB/ULID/SIB/SID/SIQ/SW/LW...).
