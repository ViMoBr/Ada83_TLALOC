# Session 11-12/08/2026 — « NOT VISIBLE BY SELECTION » au bootstrap : F1

## Symptome de depart
T2 (TLALOC compile par T1) rejette « NOT VISIBLE BY SELECTION » les
littéraux d'enumeration selectionnes (SEQ_IO.IN_FILE, DA.LX_SRCPOS,
PRENAME.COUNT...) dans 6 unites ; T1 (gnat) accepte. Code legal
(LRM 8.3, 4.1.3, 12.3, 3.5.1) : divergence de bootstrap.

## Methode
Temoins minimaux VISEL/VISEL2 (litteral selecte : paquetage, renommage,
instance, case, sous use ; controles non-litteraux) -> reproduction en
3 unites. Sondes differentielles T1s/T2s dans FIND_SELECTED_VISIBILITY
(19 modifications, modele piege n 78), eclatees en primitives prouvees
apres crashes frame-sensibles. Divergence unique exposee :
SONDEB2 NE=TRUE sur singleton -> le littéral se croit homographe de
lui-meme dans le bloc discard -> elimine.

## Cause (F1)
`TEMP_DEFINTERP /= OLD_DEFINTERP`, DEFINTERP_TYPE is new TREE
(SET_UTIL, prive complete par derivation). Finc : LVA/LVA/CNE —
comparaison d'ADRESSES de doublets. L'aiguillage COMPOSITE_OPERATORS
(expander-expressions ~4600) teste le genre NOMINAL
(DN_RECORD/DN_ARRAY...) : un derive/prive n'y repond pas -> chute dans
le chemin scalaire (CODE_EXP empile l'@doublet, CEQ/CNE brut).

## Correctif
Percage FULL_TYPE_VIEW de PRM1_TYPE avant les tests de genre
(6e occurrence de la regle unique, garde C1-bis), v2 : gate par genre
(DN_PRIVATE / DN_L_PRIVATE / DN_INCOMPLETE) apres incident
« !! PAS D ATTRIBUT XD_SOURCE_NAME » sur DN_ANY_INTEGER (TEXT_IO,
corps generiques). Verifie au finc : AVANT DN_PRIVATE -> APRES
DN_RECORD -> CODE record equality (@A Ld @B Ld CEQ, postlude LI 1/OUX
pour /=).

## Resultat
T2 refabrique compile TOUTES les unites precedemment en faute.
Restent 6 SEGFAULTS (lex, lib_phase, err_phase, expander-expressions,
expander-declarations, ada_comp) -> prochaine session.

## Verrous et temoins
- RECEQ_TEST  (14 OK) : records directs — STABLE, au depot.
- RECEQ4_TEST (19 OK attendus) : + derives par conversion (R8/R9) —
  verrou F1, au depot.
- DARREQ_TEST (3 OK) : tableaux derives — STABLE, au depot.
- VISEL/VISEL2 : verrous de la selection des litteraux, au depot.
- receq2 v1 : reproducteur F4 (conserver tel quel, ne PAS corriger).

## Registre des fossiles
- F1 egalite des derives de record : CORRIGE (cette session).
- F2 composition A5 (D->deref->CEQ->ENUM_IMAGE sous slot resultat),
  PROGRAM_ERROR frame-sensible : OUVERT, dossier finc partiel.
- F3 BOOLEAN'IMAGE sur predefinis jamais prouve sous codegen TLALOC :
  OBSERVATION.
- F4 agregat d'un type derive -> segfault elaboration : OUVERT,
  reproducteur receq2 v1.
- F5 egalite tableaux derives : INVALIDE par DARREQ — FERME.
- F6 fonction a resultat PRIVE/DERIVE de record (protocole de retour
  composite manque — RET_TS.TY nominal, expressions ~1449/1549/1818,
  meme famille que F1) : OUVERT — suspect n 1 de l'instabilite
  RECEQ2B/RECEQ3 (PK.MK2), a instruire avec les 6 segfaults.

## Programme prochaine session
1. Les 6 segfaults de T2comp — commencer par lex.adb (petit) ;
   hypotheses croisees F2/F4/F6 a garder sous la main.
2. F6 : temoin fonction-a-resultat-derive + audit des trois sites
   RET_TS ; puis reintegrer R10 au verrou RECEQ.
3. F4 : correctif agregat de derive (SM_COMP_LIST via percage).
4. Si propre : point fixe T2 -> T3.
