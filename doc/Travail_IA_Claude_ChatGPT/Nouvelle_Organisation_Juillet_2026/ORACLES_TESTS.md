# ORACLES — programmes-témoins et sorties attendues

Contrat du filet (piège n° 51) : l'ACVC classe A ne protège pas la sémantique ;
seuls ces programmes à sortie attendue le font. Toute campagne close ajoute ici
son témoin. Filet complet = modules du compilateur + ACVC A2..A8 + ces témoins
+ auto-compilation.

## 9. Programmes de test — résultats validés

### IO_TEST (sections 1-11, entiers et fichiers)

```
=== 1. Ecriture fichier ===          CREATE + PUT + NEW_LINE + CLOSE
=== 2. Relecture fichier ===         OPEN + GET_LINE + CLOSE
=== 3. SET_OUTPUT fichier ===        SET_OUTPUT + PUT_LINE + NEW_LINE
=== 4. Relecture io_def.dat ===      Relecture fichier écrit via défaut
=== 5. INTEGER_IO bases ===          PUT base 10/16/2/8, négatifs, WIDTH, zéro
=== 6. INTEGER_IO dans fichier ===   PUT(FILE) + relecture
=== 7. RESET fichier ===             CREATE + RESET(IN_FILE) + GET_LINE
=== 8. SKIP_LINE ===                 SKIP_LINE(1) + SKIP_LINE(1)
=== 9. NEW_PAGE ===                  NEW_PAGE + SKIP_PAGE + GET_LINE
=== 10. END_OF_FILE ===              Lecture directe 3 lignes
=== 11. END_OF_FILE boucle ===       while not END_OF_FILE loop
```

### FLOAT_TEST (session 11 avril, 22 tests + defaults)

```
=== 1-7 ===                          Constantes, arithmétique, comparaisons, conversions
=== FIN ===                          22 tests validés
```

11/7/2026 FLOAT_TEST réintègre le filet — c'était le seul témoin relisant des locales de type formel dans un corps partagé, absent depuis avril ; INTEGER_IO ne peut pas jouer ce rôle (zéro occurrence, preuve par le grep).

### ENUM_TEST (pilier 3.7 → refonte auto-jugeante, 5 juillet 2026, 41 assertions)

Témoin converti au format auto-jugeant : chaque valeur produite est vérifiée
par CHECK(condition, section, numéro) ; verdict final greppable.
RESULTAT :  41 OK,   0 ECHECS
ENUM_TEST PASSE

Oracle du filet = la ligne `ENUM_TEST PASSE` (absence = régression, avec
`* ECHEC section S test N` pour localiser). La section console (17) suit le
verdict : `console OK` si l'entrée pipée est « rouge ».

Sections visuelles résiduelles (cadrage console non capturable en chaîne,
déviation RM 14.3.9 consignée — cadrage à DROITE, blancs de tête) :
=== V2. PUT avec WIDTH ===     [      BLEU] [     ROUGE]
=== V7. JOUR WIDTH+LOWER_CASE === [      samedi]
=== V10. Boucle jours WIDTH=10 ===     LUNDI     MARDI  MERCREDI  …  DIMANCHE
Couvre : PUT vers chaîne (littéraux, LOWER_CASE, via variable, FILE_MODE,
cadrage à gauche conforme), GET fichier/casse mixte/JOUR, roundtrips
couleurs et jours, boucle GET en ordre non déclaratif, GET chaîne (token,
casse, index de fin L), attributs 'FIRST/'LAST/'POS.

Mise à jour ENUM_TEST : la note « Sections visuelles résiduelles
(déviation RM 14.3.9 consignée — cadrage à DROITE, blancs de tête) » est
caduque depuis le 8 juillet : le cadrage console est désormais conforme
(blancs de QUEUE). Les sections visuelles montrent le comportement
conforme ; re-vérification visuelle faite au filet du 8 juillet.

- 9 juillet 2026  (41 assertions + vérification console interactive
  « rouge ») : GARDIEN DU CONTRAT ENUM_USE_INFO étendu (SIZ@0, FST@+4,
  LST@+8, doublet images @+16 lu par GET_ENUM_IMAGES). À repasser après
  TOUTE retouche de BLOC_DEF, de CODE_ENUMERATION_DECL ou
  d'ENUMERATION_IO. Attendu : « RESULTAT : 41 OK, 0 ECHECS /
  ENUM_TEST PASSE », plus l'écho console. Vert le 9 juillet (2) après
  refonte BLOC_DEF.

### DIRECT_IO_TEST v2 (refonte auto-jugeante, 9 juillet 2026, 65 assertions)

Conversion au format canonique après le fossile n° 80 (SD -32 → -40,
slot résultat des fonctions en corps générique). Trois instances
(COULEUR énuméré 8 bits, POINT record 96 bits, VECTEUR tableau 128 bits).
S1-S3 roundtrips par égalité composite complète + SIZE (après écriture et
en relecture) + IS_OPEN/MODE ; S2 INDEX = FROM+1 après READ positionné ;
S4 SET_INDEX/INDEX/END_OF_FILE ; S5 RESET + réécriture partielle INOUT
(agrégat qualifié de record en actual) ; S6 boucle `while not END_OF_FILE
loop READ` — idiome SÛR pour DIRECT_IO, positions exactes, pas de
look-ahead (contra piège n° 79) ; S7 extension par WRITE positionné
au-delà de la fin (LRM 14.2), SIZE étendu + trou relu à zéro (fichier
creux Linux) ; S8 exceptions : END_ERROR (séquentiel à EOF, positionné
hors fichier, **élément tronqué** — fichier COULEUR de 5 octets ouvert
par POINT_DIO, verrou du fossile n° 80), MODE_ERROR (READ sur OUT,
END_OF_FILE sur OUT, WRITE sur IN), STATUS_ERROR (READ/SIZE/RESET sur
fichier fermé) ; S9 DELETE ressuscité, jugé par échec de la tentative de
re-OPEN (régime actuel : échec silencieux → IS_OPEN FALSE ; handler
NAME_ERROR accepte d'avance le régime du futur lot 14.2.1).
Crée et supprime ses fichiers *_direct.dat et scratch_direct.dat.
Dernières lignes exactes :
```
RESULTAT :  65 OK,   0 ECHECS
DIRECT_IO_TEST PASSE
```
Oracle du filet = la ligne `DIRECT_IO_TEST PASSE`. Vert intégral le
9 juillet 2026.
Non asserté (dette 14.2.1, gardes absentes des packages) : CREATE/OPEN
sur fichier déjà ouvert → STATUS_ERROR ; échec d'OPEN → NAME_ERROR ;
CLOSE/DELETE sur fichier fermé → STATUS_ERROR.

### SEQ_IO_TEST v2 (refonte auto-jugeante, 9 juillet 2026, 50 assertions)

Jumeau séquentiel de DIRECT_IO_TEST v2, mêmes trois instances.
S1-S3 roundtrips par égalité composite + IS_OPEN/MODE + END_OF_FILE
après le dernier élément ; S4 boucle `while not END_OF_FILE` (idiome
sûr, positions exactes) ; S5 RESET : rembobinage simple puis RESET avec
changement de mode (IN → OUT → IN) en réécriture COMPLÈTE des 5 éléments
en ordre inverse — délibérément indépendant de la sémantique de
troncature de RESET(OUT_FILE), non arbitrée (le corps fait lseek 0 sans
troncature) ; S6 exceptions : END_ERROR (lecture après le dernier
élément, **élément tronqué** — verrou du fossile n° 80), MODE_ERROR
(READ sur OUT, END_OF_FILE sur OUT, WRITE sur IN), STATUS_ERROR
(READ/RESET/MODE sur fichier fermé) ; S7 DELETE jugé par échec de
re-OPEN (NAME_ERROR accepté d'avance, dette 14.2.1).
Crée et supprime ses fichiers *_seq.dat et scratch_seq.dat.
Dernières lignes exactes :
```
RESULTAT :  50 OK,   0 ECHECS
SEQ_IO_TEST PASSE
```
Oracle du filet = la ligne `SEQ_IO_TEST PASSE`. Vert intégral le
9 juillet 2026 (au premier passage).
Même dette 14.2.1 non assertée que DIRECT_IO_TEST v2.

### ARRAY_TEST1 v2 (pilier 3.6, sessions 4–5 juillet, 9 sections)

Contraint 1D (indexation, FIRST/LAST/LENGTH), agrégats (positionnel, range,
others), matrice 2D et attributs dimensionnés, index par énuméré, STRING
(littéral, caténation), tranches (lecture, affectation, paramètre), paramètres
et fonction non contraints, 'RANGE à préfixe objet, 'IMAGE.
**Sortie attendue** (repères) : §1 `1 9 25 1 5 5` ; §3 `14 24 35 3 2 1 4 3 5` ;
§5 `GHIJKL / ABCDEFGHIJKL / GHIJKLABCDEF` ; §6 `DEFGHI GHIDEF XYZJKL DEFGHI 2 5 4 [BCDE]` ;
§7 `... [DEFGHI] 1 7 7 [BONJOUR] 150 18` ; §8 `150` ; §9 `42`.
Vert intégral le 5 juillet 2026.

### ARRAY_TEST2 v2 (pilier 3.6, sessions 4–5 juillet, sections D1–D9)

Opérateurs et formes composites : D7 nuls/CLAMP0, D1 égalité, D2 lexicographique
(7 cas dont témoin signé `(-5,2,3) < (1,2,3)` — protège movsx vs movzx),
D3 logiques booléens (and/or/xor/not composites), D4 caténation toutes formes,
D5 conversion, D8 retour de tranche, D9 agrégats qualifiés + VEC3'RANGE.
**Sortie attendue** : D7 `0 0 3 2 0 [] ABCDEFGHIJKL ABCDEFGHIJKL ABCDEF` ;
D1 `VRAI FAUX VRAI FAUX VRAI FAUX` ; D2 `VRAI ×7` ;
D3 `VRAI FAUX VRAI FAUX VRAI FAUX FAUX VRAI` ; D4 `XAB ABY XY XABYAB` ;
D5 `100 300 11 13 100` ; D8 `ONT BCDE` ; D9 `3 4 9 0 9 5 8 1 3`.
Vert intégral le 5 juillet 2026.

### État ACVC (5 juillet 2026)

Modules du compilateur : compilent et s'exécutent. Séries **A2 à A7 : vertes
en totalité**. Série **A8 : 17 tests verts**, échecs restants consignés
(renommage, use, portée, visibilité — hypothèse causes-mères communes,
cf. point de méthode du 4 juillet). Auto-compilation : verte après lot D2
(les comparaisons STRING du compilateur passaient auparavant par le stub).

- **Série ACVC a8** : verte le 9 juillet (2) à l'exception d'A87B59A
  (assemble, segfaut d'exécution — dette « actuels génériques
  non-sous-programmes », voir ETAT_PILIERS). A83009A/B (BLOC_DEF sous
  garde), A85013B (renamings), A83C01G (préfixe package) sont les
  verrous des pièges n° 81-82, 85-87.
  
### RECORD_TEST1 (pilier 3.7, lot R-A) 
— sortie attendue intégrale :
R1 `5 30 9` ; R2 `3 7` ; R3 `42 43 0 2` ; R4 `200 VRAI FAUX` ;
R5 `17 3 6 2` ; R6 `6 40 41 5` ; R7 `2 15` ; bannières comprises.
Couvre : élaboration des discriminants (contrainte normalisée), agrégats
positionnels/nommés avec discriminants et variantes (marcheur canonique
SM_NORMALIZED_COMP_S), affectation complète et égalité BLKCMP (sans
variantes), composant record de record (W.P) et de tableau (ARR de BUF(2)),
paramètres in/in out et retour de fonction record contraint, discriminant
en borne de boucle.

### RECORD_TEST2 (pilier 3.7, lot R-B)
— sortie attendue intégrale :
E1 `0 77 1` ; E2 `FAUX VRAI` ; E3 `9` ; E4 `0 13` ; E5 `21 2` ;
E6 `55 1` ; E7 `13` ; bannières comprises.
Couvre : défauts de discriminants élaborés (M : MUT → PT = LEAF), mutation
de variante par affectation complète, 'CONSTRAINED par objet (variable
mutable → FAUX, objet contraint → VRAI), agrégat qualifié de record
(doublet anonyme), sous-type contraint d'un type à défauts (MLEAF), mutable
composant de record (BOX.N, taille max), changement de variante à travers
un formel in out, retour de mutable par fonction.

### ARRAY_TEST3 (pilier 3.6 reliquat non contraint, session 6 juillet, sections U1–U9)

Format auto-jugeant (CHECK + verdict greppable « ARRAY_TEST3 PASSE »).
Couvre les 7 trous de NOTE_MODELE_UNCONSTRAINED : U1 attributs sur marque de
sous-type non contraint (VEC5) ; U2 objets contraints d'un type non contraint
(directe, sous-type nommé, 2D) ; U3 objet non contraint initialisé par agrégat
à bornes DÉDUITES (positionnel → INTEGER'FIRST.., nommé → 1..3) ; U4 littéral
chaîne ; U5 STRING(1..N) et STRING(N..2N) dynamiques ; U6 composants non
scalaires (array of constrained array, array of record) ; U7 formels/retours
non contraints, 'LENGTH sur formel, 2D ; U8 retour STRING de longueur calculée
(résultat nommé — contournement dette D10) ; U9 conversion avec glissement
d'indices A3(VC), 7..9.
**Sortie attendue** : les 9 bannières « === Un. ... === » sans aucune ligne
« * ECHEC », puis `RESULTAT :  37 OK,   0 ECHECS` / `ARRAY_TEST3 PASSE`.
**Témoin négatif** (piège n° 67) : deux exécutions consécutives IDENTIQUES —
toute variation run-à-run signe une lecture hors bloc via `__u`.
Historique d'oracle : 7.3 corrigé le 6 juillet (`LONGUEUR(VD) = 3`, et non 4 —
piège n° 68). Vert intégral le 6 juillet 2026.

### EXC_TEST0 (pilier 11, session 7 juillet — témoin d'amorçage, dump DIANA de référence)
Sortie : VIDE. Code retour 0. Trois chemins : handler local apparié (bloc 1),
propagation LEVE → BLOCK__2 (prédéfinie non appariée puis others), frames
frères de même niveau lexical (restauration FP(2) à la bonne incarnation).
Le dump $$$_TREE de ce témoin est la référence des nœuds du pilier.

### EXC_TEST1 (pilier 11, lots E-B/E-C + addendum, 19 assertions auto-jugées)
12 sections : 1 return depuis corps protégé / 2 return depuis handler /
3 exit à travers DEUX blocs protégés (témoin du piège n° 69) / 4 récursion
+ handler levant (CNT=4 incarnations) / 5 handler dans handler /
6 propagation profonde (3 frames) / 7 renames croisés (les deux sens, via
REN0_PACK) / 8 prédéfinies levées à la main / 9 choix multiple E1|E2 /
10 raise nu dont ADVERSARIAUX 10.2-10.3 (exception traitée dans le handler
— par bloc puis par appel — puis `raise;` qui doit relever l'EXTERNE ;
juges du piège n° 75) / 11 exception en ÉLABORATION de bloc → englobant
(LRM 11.4.2) / 12 bloc protégé × 100 000 itérations (anti-fuite).
Sections 1/2/3/6 suivies d'un CONTROLE d'intégrité de la pile des
contextes. Dernières lignes exactes :
```
RESULTAT :  19 OK,   0 ECHECS
EXC_TEST1 PASSE
```
Code retour 0.

### EXC_TEST1U (pilier 11 — témoin PERMANENT de la sentinelle)
Sortie exacte : `EXCEPTION NON RATTRAPEE : PERDUE` (une ligne).
Code retour 1 — LE VÉRIFIER (`$?`), c'est la moitié auto-jugeante.

### EXC_REN0 (pilier 11 — renommage inter-unités, dump de référence SM_RENAMES_EXC)
Deux unités (REN0_PACK + EXC_REN0). Sortie : VIDE. Code retour 0.
Le dump de ce témoin a établi la forme réelle de SM_RENAMES_EXC (piège 71).

### TEXT14 (pilier 14.3, 8 juillet 2026, 42 assertions)

Témoin auto-jugeant de la conformité LRM chapitre 14 de TEXT_IO.
U1 comptabilité COL/LINE en sortie ; U2 SET_COL avant/arrière ;
U3 coupure implicite à LINE_LENGTH bornée + LAYOUT_ERROR ; U4 SET_LINE et
longueur de page ; U5 relecture sur fichier réel (GET à travers les
terminateurs, look-ahead END_OF_LINE traversé par GET(STRING), scanner
entier, GET_LINE, END_ERROR) ; U6 gardes MODE/STATUS/NAME_ERROR ;
U7 DATA_ERROR et LAYOUT_ERROR des variantes chaîne ; U8 cas résiduels
(chaîne nulle, DATA_ERROR fichier, FF devant un entier, END_OF_LINE sur
FF). Crée et supprime ses fichiers TEXT14_*.TXT.
RESULTAT :  42 OK,   0 ECHECS
TEXT14 PASSE
Oracle du filet = la ligne `TEXT14 PASSE`.

### OUTARG1 (correctif expandeur piège n° 77, 8 juillet 2026, 8 assertions)

Verrou de la classe « actual out/in out composé » : composant indexé en
out et in out (indice littéral et calculé), composant sélectionné en out
et in out, boucle sur composant indexé d'un formel non contraint (motif
exact du GET(STRING) public). Indépendant du chemin fichier.
OUTARG1 PASSE
Oracle du filet = la ligne `OUTARG1 PASSE`.

### TEXT14P (sonde, hors filet)

Sonde de bisection à marqueurs séquentiels P00..P20 sur la séquence
écriture → CLOSE → OPEN → relecture. Pas d'oracle : outil de diagnostic à
ressortir quand un chemin d'E/S neuf s'ouvre (piège n° 78).

## Témoins du pilier CHECKS (permanents au filet, checks ON)

CHK_TEST0  — gamme d'affectation (E-A) : 1..5 OK, 6 sentinelle
             CONSTRAINT_ERROR, $? = 1. Contre-épreuve OFF : 2,3,4 KO.
CHK_LEN0   — LEN_G=LEN_D (E-B) : 1..4 OK (dont tranches et tableaux
             nuls), 5 sentinelle CONSTRAINT_ERROR, $? = 1.
CHK_IDX0   — index (E-C) : 1..9 OK (quatre variantes, multi-dim,
             négatif, descripteur), 10 sentinelle, $? = 1.
CHK_TEST1  — gamme six sites (E-D) : 1..5 OK, 6a OK T = 9, 7 OK,
             8 sentinelle CONSTRAINT_ERROR, $? = 1. 6b consigne : la
             violation générique hors bornes reste à outiller.
CHK_DIV0   — division par zéro (E-E) : 1..4 OK (NUMERIC_ERROR et PAS
             CONSTRAINT_ERROR — juge de Q7), 5 sentinelle
             NUMERIC_ERROR, $? = 1.
CHK_ANON0  — piège n° 80 : 1..4 OK, 5 OK-dette (violation anonyme
             SILENCIEUSE — si cette section change, dette soldée ou
             régression : mettre à jour témoin et note).
CHK_CSTPRM0/1/2 — fossile n° 81 (scalaires/composites/privés en
             actuel) : toutes lignes OK, $? = 0.
CHK_PREDEF0 — bornes prédéfinies via use-info + BOOLEAN'IMAGE
             (pièges n° 80-rectif et n° 83) :
             INTEGER -2147483648/2147483647, CHARACTER 0/127,
             BOOLEAN 0/1, IMAGE TRUE FALSE, $? = 0.

Sondes RETIRÉES du filet (diagnostic une-fois, archivées) :
CHK_ANON1/2/2B/3, CHK_DUMP0.

### FIX_TEST1 (12 juillet, pilier fixed — 15 assertions)

```
=== S1. Multiplicatif T(X*Y), T(X/Y), elision FIX.INT ===
=== S2. fixed -> fixed (rescale, identite, troncature) ===
=== S3. Attributs plies, sous-type ===
 T8'AFT (sem-3, attendu 3) =          3        <- AFFICHE non asserte (dette sem-3)
 T8'FORE (sem-3, attendu 3) =          3       <- idem
=== S4. Division fixed par zero -> NUMERIC_ERROR (Q7) ===
RESULTAT :          15 OK,           0 ECHECS
FIX_TEST1 PASSE
```
Oracle : la ligne « FIX_TEST1 PASSE ». Gardiens de troncature vers
zéro : tests 3 (1.59375), 10 (3.75), 11 (-2.25 — un plancher donnerait
-3.0). DÉPEND du régime sem-1 (small = delta/2) : si sem change,
toutes les représentations attendues changent.

### FLOAT_FIXED_IO_TEST (12 juillet — 11 sections, FLOAT_IO + FIXED_IO)

```
=== 1. FLOAT_IO PUT LONG_FLOAT — formats ===   pi 3.141593E+00, grand 1.2346E+15,
                                               petit -4.5679E-08, zero, un, negatif,
                                               FORE pad "   2.50E+00"
=== 2. FLOAT_IO PUT FLOAT ===                  e 2.7183E+00, -1.000E-03
=== 3. FIXED_IO PUT DURATION ===               1.500 / 0.020 / -3.14 / 0.000 / "  12.50"
=== 4-6. FLOAT_IO GET (fichier, WIDTH, console) ===
=== 7-10. FIXED_IO GET (fichier, exposants 2.5E-1 -> 0.2500, WIDTH, console) ===
=== 11. GET roundtrip — deux valeurs sur une ligne ===
=== FIN ===
```
Oracle : sortie complète ci-dessus. Sections 6 et 10 interactives
(entrées : -1.5E+2 et 1.5). Gardien du contrat GFP/adaptateurs
(n° 92) et du calcul FIXED_AFT/FORE d'instanciation (F-4a).

### FLOAT_TEST — RÉINTÉGRÉ AU FILET (12 juillet)

Témoin d'avril, seul à relire des locales de type formel en corps
partagé — son absence du filet a laissé vivre le n° 92 de fin avril à
juillet. Ne plus jamais retirer un témoin sans vérifier qui d'autre
couvre ses chemins.

### TEST_CALENDAR (12 juillet — témoin d'exception 1900/2100 ajouté)

Sections TIME_OF/SPLIT, sélecteurs, rollover minuit, opérateurs
(DELTA_T = 2.500000E-01), journée ordinaire, passage année, HORS GAMME
(1900 -> CONSTRAINT_ERROR OK, 2100 -> CONSTRAINT_ERROR OK), non
bissextile, passage arrière, CLOCK (visuel), cohérence. Conversion au
format CHECK/RESULTAT : à faire à l'occasion (dette de confort, pas de
couverture).

### Choses à ajouter (28 juillet 2026)

- ORACLE membership (suite piège n° 115) : programme minimal exerçant
  (a) `X in SOUS_TYPE` vrai et faux, (b) `X not in SOUS_TYPE`,
  (c) `X in TYPE_DE_BASE` (doit empiler LI 1, pas rien), (d) la forme
  déjà couverte `X in A..B` en témoin, (e) un membership en opérande
  gauche d'un `or else` (le DUP doit avoir son opérande). Vérifier en
  binaire : aucun `; debut if` suivi d'un BF nu dans le FINC produit.

- ORACLE équilibre de pile (suite pièges n° 53/115/116) : en mode debug,
  assert rbp == FP(niveau)+alloc en tête de chaque grande boucle de
  phase — prend toute fuite au tour où elle naît, pas 200 itérations
  plus loin.
  
### TROU_SEL1 (préfixe appel de selected, n° 120a, 28 juillet)
F(...).COMP : champ scalaire, second champ (offsets non nuls), record
REPRÉSENTÉ (jumelle n° 110 — le cas DABS.NSIZ), opérandes composés
(MK(1).A + MK(2).A). Auto-jugeant : `TROU_SEL1 PASSE`.
Oracle corpus associé : idl-idl_man re-expansé STRICT sans trou, FINC
de HASH_SEARCH portant CALL DABS / La / extraction NSIZ avant le CEQ.

### TROU_VAL1 ('VALUE entier, 28 juillet)
Aller-retour INTEGER'VALUE(INTEGER'IMAGE(X)) sur { 0, 42, -1, grands
± } ; formes "  123  ", "+7", "1_000" ; LONG_INTEGER'VALUE sur
rationnel PRINT_NUM ; chaînes illicites ("12X", "") → CONSTRAINT_ERROR
ATTRAPÉE (le raise du runtime est exercé). `TROU_VAL1 PASSE`.

### TROU_CONV1 (préfixe conversion-vue, n° 120b, 28 juillet)
R(X).A sur dérivé privé, jumelles rep/non-rep, variable ET paramètre
in, composition conversion-sur-appel R(MK(N)).B. `TROU_CONV1 PASSE`.
Oracle corpus : set_util re-expansé STRICT sans trou, FINC d'IS_NULLARY
portant La -DEFINTERP_ofs / La -1,0 / extraction TY avant LI 230/CEQ.

### Oracle négatif permanent de la discipline TROU (n° 118)
Un attribut/noeud hors périmètre DOIT produire « !! TROU <site> » sur
la console ET « ; !! TROU » dans le FINC, puis PROGRAM_ERROR en STRICT
(essai fondateur : 'TERMINATED). En RECENSEMENT : bilan « N TROU(s)
traversés -- FINC SUSPECT » à la fermeture, et jamais d'assemblage du
FINC. Oracle du filet : le run corpus complet en STRICT ne rend AUCUNE
ligne « !! TROU ».

## Témoins DUS — chantiers C1-C7 (à écrire AVANT chaque implantation)

- C1 CONV_DER1 : conversions record dérivé et tableau dérivé,
  aller-retour + comparaison de contenu (identité de représentation).
- C2 CASE_ST1 : case à choix marque-de-sous-type statique — première
  borne, dernière, hors fenêtre, mélange avec choix simples et others.
- C3 OUT_RD1 : out scalaire relu après écriture (même chemin que in out).
- C4 ARRVAR1 : init de tableau par objet entier, par appel, par
  qualifié (les trois formes @doublet de la règle unique).
- C5 POWI1 : 3**5, X**0, X**1, exposant variable, exposant négatif
  (CONSTRAINT_ERROR exercée via ce_raise_).
- C6 SLICE_PF1 : P.all(2..5) et A(I)(2..5), source ET destination.
- C7 (avec sa NOTE_MODELE) : fonction générique instanciée à résultat
  STRING + l'oracle du carnet « fonction ordinaire retournant tableau
  contraint à bornes dynamiques » + témoin négatif return TAB2D(I) —
  UN SEUL modèle d'exécution, trois témoins.
Discipline n° 114/115 : jamais de rameau non exercé ; chaque témoin
passe le filet AVANT le chantier suivant.

### CONV_DER1 v2 (chantier C1, 30 juillet 2026, 12 assertions)
Conversions vers types composites DÉRIVÉS (LRM 4.6, identité de
représentation) : record direct (aller-retour, composé, actual, égalité
composite), record PRIVÉ dérivé hors paquetage (miroir set_util — seconde
saveur DIANA de `private`, SM_DERIVED, découverte C1-bis), tableau
contraint dérivé (miroir idl.adb ; dette LRM 4.6(11) au carnet, non
exercée).  A payé DEUX bugs latents : (1) la conversion absente des
producteurs d'@doublet de la règle unique CCDA — affectations composites
de conversions fausses en silence (C1-ter) ; (2) le placeholder LI 0 du
lieu résultat des fonctions ordinaires à résultat composite — segfault
MK, chantier suspendu consigné (v2 passe par procedure MK, v1 archivé
comme témoin futur).  Hors périmètre volontaire : aucun sous-programme
DÉRIVÉ appelé ; test 1.4 = contre-témoin n° 120b.  Oracle :
« RESULTAT :  12 OK,   0 ECHECS / CONV_DER1 PASSE » ; FINC : chaque
BLKMOV d'affectation-de-conversion porte son `La` source ; élaboration de
DS identique à celle de S via STANDARD…SETS._SET.

### CASE_ST1 (chantier C2, 30 juillet 2026, 18 assertions)
case à choix marque-de-sous-type (LRM 5.4 ; choix statiques 5.4(4)) :
marque entière à bornes négatives et positives — première/dernière borne,
intérieur, hors fenêtre des deux côtés — ; marque énumérée en couverture
complète SANS others (bornes = 'FIRST/'LAST du type, chemin SM_REP) ;
marque et choix simple dans la même alternative.  Implantation : fenêtre
CGE/CGT/BF de DN_RANGE, bornes par la règle CODE_DISCRETE_RANGE_BOUND
(DN_RANGE inchangé par construction).  Oracle : « RESULTAT :  18 OK,
0 ECHECS / CASE_ST1 PASSE » ; FINC : fenêtre présente aux 5 sites-marque.

### OUT_RD1 (chantier C3, 30 juillet 2026, 10 assertions)
Relecture d'un paramètre out après écriture (dialecte toléré par le
front-end ; illégal en Ada 83 strict LRM 6.2 — contre-épreuve GNAT en mode
par défaut).  Out entier, out énuméré, accumulation en boucle.
Implantation : DN_OUT_ID → LOAD_MEM, même chemin que in out (protocole
n° 91/94 : le slot porte l'adresse) ; TROU discriminé conservé en corps
générique.  Oracle : « 10 OK / OUT_RD1 PASSE ».

### ARRINI1 (chantier C4, 30 juillet 2026, 9 assertions)
Init de tableau par objet entier (VEC, STRING) et par conversion d'objet
dérivé (transparence C1-ter) ; sémantique de copie vérifiée par mutation
de la source post-init.  Implantation : branche DN_USED_OBJECT_ID |
DN_CONVERSION dans COMPILE_ARRAY_VAR — COVAR_ALLOCATE puis BLKMOV, @SRC
par CCDA, modèle de la branche tranche ; init par appel de fonction
EXCLUE (protocole lieu résultat suspendu, carnet).  Oracle : « 9 OK /
ARRINI1 PASSE » ; FINC : CO_VAR + BLKMOV aux 3 sites, conversion
dépouillée pour la forme VEC(Z).

### POW1 (chantier C5, 30 juillet 2026, 15 assertions)
Exponentielle entière générale X**N (LRM 4.5.6) : base/exposant
dynamiques, X**0=1, X**1=X, 0**0=1, bases négatives, imbrication en
expression, non-régression du pli 2**N (DEC/SHL), exposant négatif =
CONSTRAINT_ERROR rattrapée.  Implantation : primitive Ada cachée
STANDARD.INTEGER_POW (_standrd.adb, famille INTEGER_IMAGE/INTEGER_VALUE,
levée par raise Ada — pilier 11) + détour par temporaires au site (idiome
CODE_VALUE, protocole scalaire n° 91/94).  Oracle : « 15 OK / POW1
PASSE » ; _standrd.adb ré-expansé ZÉRO trou ; FINC : CALL
STANDARD. ,INTEGER_POW_L<nn> aux sites généraux, DEC/SHL conservé.

### INSTF1 (chantier C7, 1er aout 2026 — 8 assertions, PERMANENT au filet)

Instanciation de fonction generique a resultat NON CONTRAINT (STRING).
DEUX instances de BAND a actuels differents (bornes 3 et 5 — le vrai
test du partage de modele) ; trois formes d'usage : affectation depuis
l'appel, operande direct d'egalite, init de declaration par l'appel.
Juge le relais du slot par le wrapper (piege n 123) et le CODE_RETURN
doublet du modele.
```
=== INSTF1 : instanciation, resultat non contraint ===
RESULTAT :  8 OK,  0 ECHECS
INSTF1 PASSE
```
Oracle du filet = la ligne « INSTF1 PASSE ».

### ADDR_OV1 v6 (chantier C8, 1er aout 2026 — 27 assertions, PERMANENT au filet)

Clauses d'adresse d'objet (overlay LRM 13.5), TOUTE la grille du piege
n 124 : S1 alias meme type (2 sens) ; S2 reinterpretation tableau de
records (motif univ_ops) ; S3 overlay record (3 vues / 1 memoire) ;
S4 attributs = vue de l'ALIAS ; S5 overlay SCALAIRE (equation, motif
TEST_ADDRESS) ; S6 motif print_nod (array de CHARACTER sur INTEGER,
init A TRAVERS a l'elaboration) ; S7 parametres (in, in out, depuis un
BLOC — geometrie univ_ops exacte, niveaux differents).
```
=== ADDR_OV1 : clause d'adresse d'objet (overlay) ===
RESULTAT : 27 OK,  0 ECHECS
ADDR_OV1 PASSE
```
Oracle du filet = la ligne « ADDR_OV1 PASSE ».
DEPENDANCES ASSUMEES (les juges memes du temoin) : petit-boutisme
x86_64 (S6.1 — comme print_nod) ; layout maison PAIR = deux entiers
contigus sans bourrage, miroir STATOFS (S2/S3) ; passage par REFERENCE
des composites (7.2 — si les petits composites passaient un jour par
copie, 7.2 le detecterait).

### Temoins DUS — mise a jour C7/C8

- C7 : INSTF1 FAIT. Restent DUS du « modele unique » : fonction
  ORDINAIRE retournant tableau a bornes dynamiques (oracle du carnet),
  et temoin negatif return TAB2D(I) — lies a la dette D6 (bloc info
  anonyme 1-dim).
- C8 : ADDR_OV1 FAIT. Rameaux hors benediction (TROU discrimines,
  temoin AVANT tout code) : mode OUT ; adresse ABSOLUE d'objet ;
  scalaire-sur-composite ; equation cross-niveau ; clause de
  SOUS-PROGRAMME (chantier separe) ; tailles scalaires differentes
  (tolere-non-asserte).
  
### REC_ARR_TEST (composants tableau de record + concatenation, 5-6 aout 2026, 53 assertions)

Trois unites : REC_PACK.ADS (LIGNE miroir de LINE_OF_SOURCE avec borne en constante nommee, PAIRE a
deux sous-types anonymes du meme type de base, composants nommes S4/TVEC, variables package PATHV/NOMV),
REC_PACK.ADB (indexations via record-PARAMETRE), REC_ARR_TEST.ADB. L'ordre de compilation EST le test
(spec -> corps -> main = rechargement DCL). Harnais sans "&" (fonctionnalite sous test).
Sections : S1 composant inter-unites ; S2 record local niveau>0 (CD_LEVEL) ; S3 double anonyme meme
base (collision) ; S4 composants nommes (non-regression) ; S5 concatenation 15 formes (19 = "&" en
actual, miroir OPEN) ; S6/S7 tranche et attributs de composant (ex-sentinelles, vertes) ; S8 formes
ADA_COMP (package vars, formel->formel, bornes dynamiques, CREATE/OPEN reels -> fichiers ././tmp1,
././tmp2 a purger) ; S9 objet non contraint := tranche (la forme NOM_TEXTE).
Verdict greppable "REC_ARR_TEST PASSE", RESULTAT :  53 OK,   0 ECHECS ; DEUX executions identiques
(piege n 67). Gardien permanent : a repasser apres toute retouche de CODE_RECORD_TYPE_DECL,
PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC, CODE_INDEXED, CODE_SLICE, SELARG, COMPILE_ARRAY_VAR ou des
operandes du "&". La matrice de triage section->site est dans TEMOIN_REC_ARR_ORACLE.txt du depot.

### Oracle permanent : classifieur use__info v2 (grep du patron)

Sur tous les FINC regeneres : chaque "La ..., STANDARD._STRING.use__info" est classe MORT (le __u vise
est re-ecrit avant la fin de son segment d'elaboration -- borne au prochain 'var elab'/'begin:'/'PRO')
ou VIVANT. Etat de reference apres la session du 5-6 aout : ZERO vivant. Tout vivant nouveau est un
bug par definition (piege NN+2 : les sorties legitimes sont toutes MORTES ou hors motif). Etendre au
besoin le motif aux autres bases non contraintes du corpus.

### SECV1 (agregat others vers .all, 7 aout 2026, 3 etages)

Isole le motif exact de ALLOC_PAGE : X.all := (others => V) sur
array(0..127). Etage A : element record ORDINAIRE (2 INTEGER), valeur
constante -- juge aussi la taille (piege n 130). Etage B : element
record REPRESENTE 32 bits calque du TREE, valeur = constante
declarative. Etage C : idem B, valeur construite localement.
```
A: 0 B: 0 C: 0
SECV1 OK
```
Oracle du filet = la ligne "SECV1 OK". Grille diagnostique en cas de
rechute : A seul rouge = taille (n 130) ; B rouge C vert = lecture de
constante representee ; les trois rouges a 128 = source @doublet
(n 129a). Gardien permanent de EMIT_ONE_COMP, COMPUTE_DYNAMIC_DIMS et
de la regle unique cote agregats ; a repasser apres toute retouche de
CODE_ARRAY_AGGREGATE ou de CODE_COMPOSITE_DATA_ADDRESS.

### TTAIL1 (init de declaration record depuis composante, 7 aout 2026, 3 etages)

Isole le motif d IDL_MAN.APPEND (T_TAIL := S.NEXT). Etage A :
T : RB := S_PRM.NEXT, record represente 32 bits, composante d un
parametre formel. Etage C : meme motif, record ordinaire. Etage F :
T : RB := MK_B (appel de fonction) -- producteur @doublet, sentinelle
de NON-REGRESSION de la discrimination.
```
A OK
C OK
F OK
TTAIL1 OK
```
Oracle du filet = la ligne "TTAIL1 OK". Oracle negatif historique
(avant C8) : "A ECHEC" puis SEGFAULT a C (BLKMOV depuis une adresse =
la valeur entiere de la composante). Gardien permanent du site d init
de COMPILE_RECORD_VAR ; si F casse un jour, c est la discrimination de
CODE_COMPOSITE_DATA_ADDRESS elle-meme qui a un trou.

### SUBLVL_TEST (lot subunits, 7 aout 2026, 5 assertions)

Trois unites : sublvl_test.adb + subunit de sous-programme (INTERNE) +
subunit de corps de package (COEUR). Couvre : niveau lexical des
subunits a parent PORTEUR DE FRAME — 'IMAGE d'enumere du parent en
initialisation (site FIX_PRE du bootstrap), lectures/ecritures
montantes d'objet, appel montant (CHECK), sous-programme d'un corps
de package separe. Ordre de compilation : parent puis subunits.
Attendu : « RESULTAT : 5 OK, 0 ECHECS / SUBLVL_TEST PASSE ».
Gardien du piege n 138 ; a repasser apres toute retouche de
CODE_COMPILATION_UNIT, des stubs ou du couple LINK/display.

### AGGSTR_TEST (lot agregats tableau-de-tableaux, 8 aout 2026, 10 assertions)

Une unite : aggstr_test.adb. Couvre : agregat NOMME desordonne et agregat
POSITIONNEL d'un tableau constant indexe par enumere a composantes STRING(1..3)
rembourrees '!', dans un package spec au niveau 1 (motif PRENAME/
BLTN_TEXT_ARRAY) -- init d'objet depuis element indexe, double indexation
caractere, egalite composite, affectation vers STRING_3, boucle de rognage.
Attendu : « RESULTAT : 10 OK, 0 ECHECS / AGGSTR_TEST PASSE ». Historique :
rouge 9/10 avant correctif (seul ITEM'LENGTH passait -- positions justes,
contenu pointeurs). Gardien du piege n 139 ; a repasser apres toute retouche
de CODE_ARRAY_AGGREGATE, COLLECT_DIMENSIONS, EMIT_ONE_COMP ou de la regle
n 112 (CODE_COMPOSITE_DATA_ADDRESS).

### OPDEF_TEST (lot operateurs utilisateur, 8 aout 2026, 6 assertions)

Une unite : opdef_test.adb. Couvre : operateurs definis par l'utilisateur
sur type record ("+" binaire, "**" mixte record x entier -- le motif du spin
UARITH --, "<" vers BOOLEAN, resultats records en doublets anonymes) ET la
frontiere des operateurs IMPLICITES d'un type derive d'INTEGER (checks 5-6),
qui doivent rester en emission predefinie. Attendu : « RESULTAT : 6 OK,
0 ECHECS / OPDEF_TEST PASSE ». Historique : rouge 1-4 avant correctif
(emission par nom sur @doublets), 5-6 verts des l'origine. Gardien du piege
n 140 ; a repasser apres toute retouche du dispatch DN_USED_OP, de
CODE_DN_BLTN_OPERATOR_ID, de SUBPROGRAM_ORIGIN ou du protocole d'appel
de fonction.

### RECSTR_TEST et RECSTR2_TEST (lot chiffres longs, 8-9 aout 2026, 4+6 assertions)

Deux unites jumelles : recstr_test.adb (SQUELETTE de RECURSE_DOUBLETS --
recursion sans parametre, variable montante mutee, deux constantes STRING
locales d'appels, recursion en tete de catenation chainee) et
recstr2_test.adb (la CHAIR : tranches pleines de constantes en catenation,
agregat STRING'(1..COMPL => '0') a bornes dynamiques et VIDES, SHORT
represente 16 bits, mod 10_000, donnees de 2147483647). Historique :
VERTS D'ORIGINE tous deux -- ce sont les temoins qui ont DISCULPE PRINT_NUM
et retourne le soupcon vers UARITH/alignement (piege n 143). Attendu :
« 4 OK / RECSTR_TEST PASSE » et « 6 OK / RECSTR2_TEST PASSE ». A repasser
apres toute retouche des catenations, des constantes dynamiques, des
tranches ou de CO_VAR.

### PACKV_TEST (lot alignement packe, 9 aout 2026, 6 assertions)

Une unite : packv_test.adb. Record pragma PACK au motif VECTOR d'UNIV_OPS
(L, S, tableau packe d'UD 16 bits) : ecriture indexee chiffre a chiffre,
relecture, copie record entiere, non-aliasing apres copie, egalites de
tranches packees. Gardien du piege n 143 (STATIC_TYPE_ALIGN_BYTES et
pragma PACK). Historique : pose APRES le patch (rouge d'avant-patch non
capture -- constate vert 6/6 sur T1 patche). Attendu : « RESULTAT : 6 OK,
0 ECHECS / PACKV_TEST PASSE ». A repasser apres toute retouche de
STATIC_TYPE_ALIGN_BYTES, du layout des records packes, de STATOFS ou du
chantier n 117.

### OPB_TEST (lot operateurs BOOLEAN sur record represente, 11 aout 2026, 12 assertions)

Une unite : opb_test.adb. Couvre : record represente 32 bits calque sur
TREE (rep clause at mod 4, TOUTES composantes a l'octet 0 -- les deux
seules formes couvertes par l'expander, cf. gardes recensees en session),
operateurs utilisateur ">="/"<=" a resultat BOOLEAN sous les quatre
formes d'appel (condition de if, affectation a BOOLEAN, parametre
effectif, appel depuis sous-programme imbrique), paire HOMONYME
NODE/BOOLEAN (resolution en presence des deux freres, checks 1-10), et
le motif UARITH exact : egalite de records representes dont l'operande
gauche est un APPEL D'OPERATEUR PARENTHESE ( LEFT >= RIGHT ) = MK(1)
(checks 11-12). Attendu : « RESULTAT : 12 OK, 0 ECHECS / OPB_TEST
PASSE ». Historique : checks 1-10 verts d'origine (protocole scalaire et
homonymes disculpes par l'echelle de fidelite), check 11 rouge capture
« 11 OK, 1 ECHECS » avant correctif F1, 12/12 apres. Gardien du piege
n 145 (5e occurrence de la regle n 112 : DN_PARENTHESIZED transparent
pour la forme du resultat + OPERAND_DATA_ADDRESS rebranchee sur la regle
unique) ; a repasser apres toute retouche de CODE_COMPOSITE_DATA_ADDRESS,
CODE_RECORD_EQUALITY, du dispatch DN_USED_OP ou du protocole d'appel.

### SLAGG_TEST (lot agregat vers tranche, 11 aout 2026, 8 assertions)

Une unite : slagg_test.adb. Couvre : agregat (others => X) affecte a une
TRANCHE a bornes DYNAMIQUES (variable K), composant BOOLEAN, deux vagues
FALSE/TRUE au motif exact de WRITE_LIB.MARK_DONT_MOVE_PAGES. Detection
FONCTIONNELLE (relectures du tableau, aucun pari sur la disposition
memoire) : le remplissage aux bornes du TYPE ecrase la queue du tableau
a l'interieur. Attendu : « RESULTAT : 8 OK, 0 ECHECS / SLAGG_TEST
PASSE ». Historique : rouge capture « 6 OK, 2 ECHECS » (checks 4-5)
avant correctif W1 -- le check 8, prevu rouge, etait BLANCHI par le
second debordement compensant le premier (les deux vagues debordaient,
la seconde re-ecrasait en FALSE ce que la premiere avait sali) ; lecon :
deux instances du meme bug peuvent se masquer fonctionnellement, le
watchpoint les voyait toutes deux. Gardien du piege n 146 (contrainte
applicable = celle de la tranche, RM83 4.3.2 ; DIM_TBL(1) surchargee par
AS_DISCRETE_RANGE du DN_SLICE) ; a repasser apres toute retouche de
CODE_ASSIGN (voie DN_SLICE), CODE_ARRAY_AGGREGATE, COLLECT_DIMENSIONS
ou CODE_SLICE.

### COPILE_TEST (lot capacite co-pile, 11 aout 2026, 4 assertions)

Une unite : copile_test.adb. Temoin de CAPACITE (reclasse) : phase 1 =
30 000 000 d'appels d'une fonction triviale (bosse >= 240 Mo -- la
co-pile ne rend jamais r14, 8 octets par LINK a vie du processus,
n 147) ; phase 2 = 200 000 appels a tableau local de taille dynamique
(CO_VAR). Attendu sous arene 1 Go : « RESULTAT : 4 OK, 0 ECHECS /
COPILE_TEST PASSE » en quelques secondes. Historique : segfault sous
l'arene 128 Mo d'origine (capture de l'epuisement) ; a aussi servi de
contre-exemple de methode -- sa phase 2 consommait les CO_VAR dans le
frame allocateur et avait donc VALIDE A TORT la restauration de r14 a
l'UNLINK (tentative R1, revoquee) : il ne teste PAS le contrat
d'evasion, c'est le role de STRRET_TEST. A repasser apres tout
changement de p_memsz ou des macros LINK/UNLINK/ELB.

### STRRET_TEST (lot contrat d'evasion co-pile, 11 aout 2026, 7 assertions)

Une unite : strret_test.adb. LE gardien du contrat d'evasion (n 147) :
les fonctions a resultat dynamique (STRING) laissent leurs donnees sur
la co-pile DU CALLE et l'appelant les consomme APRES le retour. Couvre :
resultat STRING passe directement a l'appel suivant (le cas _standrd --
le LINK du consommateur alloue au-dessus de l'evade), longueur/contenu
d'un evade simple, catenation de DEUX resultats de fonction (deux evades
vivants simultanement), imbrication F(G(..)) et F(F(G(..))), copie
immediate puis appel interpose. Attendu : « RESULTAT : 7 OK, 0 ECHECS /
STRRET_TEST PASSE ». Historique : vert sous le regime a bosse ; c'est
le temoin qui AURAIT invalide la tentative R1 avant tout build (sous R1
les tetes des chaines retournees etaient ecrasees -- constate sur
_standrd : noms manges puis PROGRAM_ERROR). VERT OBLIGATOIRE sous TOUT
remaniement futur de la co-pile (retour glissant, marques de relache,
toute restauration de r14) : ce temoin passe AVANT le build de T2 dans
l'ordre des oracles.

### diff_finc.sh (oracle de point fixe, 11 aout 2026, outillage)

Script dans /bin : confronte chaque FINC de ./ADA__LIB/ADA__LIB (produits
T2) a son homonyme de ./ADA__LIB (produits T1), CRLF normalise (piege
n 131) ; rapport dans ./diff_finc/RAPPORT.txt, diffs complets conserves
par fichier divergent. Verdict binaire « POINT FIXE PREDEFINIS :
ATTEINT / NON ATTEINT ». Doctrine : l'oracle de point fixe PRIME sur
l'oracle d'execution -- une divergence sur un FINC qui « passe » est une
miscompilation latente (le n 145 a vecu ainsi) ; toute divergence passe
devant tout nouveau chantier. Etat au 11 aout : 10/10 identiques,
53 FINC cote T1 seulement (les sources du compilateur -- la liste de
courses de T3).

### Sondes @IB1/@IB3 (hors filet, diagnostic erreur type A)

Posees dans idl-sem_phase-def_walk.adb (DN_INTEGER_DEF), gardees par
DEBUG_SEM : @IB1 = valeurs LOWER/UPPER_BOUND et PREDEFINED_INTEGER_
FIRST/LAST via PRINT_NUM ; @IB3 = les six booleens de la cascade
SHORT/INTEGER/LONG en chaine TFTTTT (reference T1). La variante @IB2
(BOOLEAN'IMAGE sur appel d'operateur) a ete RETIREE : elle levait
PROGRAM_ERROR sous T2 -- decouverte annexe consignee en session
(territoire n 140-142, temoin a ecrire le jour venu). EN PLACE a la
cloture du 11 aout ; retrait par grep @IB une fois la campagne T3
entamee (elles ne touchent pas les FINC produits, seulement la
verbosite de T2).

## GOTO_SELARG_TEST — gardien du piège n° 148 (préfixe nom étendu indexé)

Source : tests/goto_selarg_test.adb (livré avec le commit n° 148).
Forme exacte du bug : table de records au niveau paquetage, index
runtime, champ scalaire passé en actuel d'une fonction à résultat
STRING, appel en opérande de concaténation ; plus un goto arrière et un
goto avant (exercent CODE_GOTO/CODE_LABELED du compilateur HÔTE quand ce
témoin sert de source compilée).

Verdict attendu (exécution du binaire, checks ON) :
	tour 1 -> L32
	tour 2 -> L32
	fin -> L12

Rouge de référence : reproductible en recompilant le témoin avec le T1
d'AVANT le commit n° 148 (segfault à l'exécution sur le premier
PUT_LINE : BLKMOV, rdi = valeur du champ à [T(1)+8]).

Oracle FINC associé (sans exécution) : sur le FINC du témoin,
	grep -n -B1 "T_disp"
ne doit montrer AUCUNE paire de `La` consécutifs identiques.

Oracle suprême du dépôt (rappel, hérite de cette session) : diff des
63 FINC entre la génération T1 et la génération T2 = VIDE. À rejouer
après tout remaniement de l'expander.

### Sondes @GT/@PC/@AP (hors filet, outil de diagnostic bootstrap)

Posees dans idl-par_phase.adb (@GT1-4 fin de GET_TOKEN, @PC1-5
dispatch/reductions/goto, dumps du noeud ligne frais) et
idl-idl_man.adb (@AP0-7, @APe : operandes d APPEND pas a pas).
EN PLACE a la cloture du 7 aout, gardees par DEBUG_PARSE cote
par_phase. Protocole de re-usage (premier run W du bootstrappe) :
run gnat-W = reference (existe, trace du 7/08) ; run boot-W ;
normaliser CRLF (piege n 131) ; diff ; premiere divergence = point
d entree du chantier. Retrait final par grep @GT/@PC/@AP.

## Chaîne TARGET_CODE (pilote interactif, entrée vide = tests)

TC_TEST19  blocs Ada internes (ELB sans PRO, fonction gardée morte)   exit 0 (3..5)
TC_TEST20  thunks génériques, labels pointés, ET, BLKCMP, CALLI nu    exit 0 (3..7)
TC_TEST21  complétion codi : mots, ALU, bitfields, flottants, CVTXI,
           BLK*, LEXCMP ×3, horloge, fichiers bout en bout            exit 0 (3..33)
TC_TEST23  entité unique symbole/namespace (les deux ordres)          exit 0 (3..6)
TC_TEST24  redéfinition séquentielle (deux emplacements, 5 et 9)      exit 0 (3..5)
TC_TEST25  rq en zone virtual (écarts 16 / 20)                        exit 0 (3..4)
TC_TEST3   test négatif volontaire : CONSTRAINT_ERROR attendue, pas de BIN

Chaque témoin : quadruple oracle — fasmg TC_TESTn.FAS TC_REFn && cmp
muet ; exécution → 0 ; rejeu de toute la chaîne muet ; avalements du
corpus réel muets. Oracle suprême : cmp ADA_COMP / ADA_COMP.x86exe muet
+ auto-recompilation du compilateur assemblé.

Oracle unitaire (localisation) : squelette constant avec/sans le
mnémonique isolé, delta d'octets = taille fasmg, confrontée à SIZE_OF.
