***
#	TLALOC COMPILER

procedure **ADA_COMP**

_rôle_ : programme principal, lit les paramètres d'entrée (chemin projet, chemin texte source, option). Puis lance les phases de comîlation en s'arrêtant suivant l'option : "S" ou "s" arrêt après analyse syntaxique ; "L" ou "l" arrêt après phase librairie, "M" ou "m" arrêt après analyse sémantique ; "C" arrêt après l'expander ; "W" va jusqu'à l'écriture en bibliothèque en passant par l'expander ; "w" écriture en librairie SANS passer par l'expander (sert au débogage).

```
0006 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/ada_comp/ada_comp.ads

0173 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/ada_comp/ada_comp.adb

with TEXT_IO, CALENDAR, IDL, EXPANDER;
```

***
##	IDL

package **IDL**

_rôle_ : fournit tout le support d'accès et de gestion du réseau DIANA, englobe les procédures de phases successives (sauf l'expander).

```
0136 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/ada_comp/idl.ads

with DIANA_NODE_ATTR_CLASS_NAMES;

0622 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/ada_comp/idl.adb

with SYSTEM, UNCHECKED_CONVERSION, TEXT_IO;
```
**IDL** subunits

```
0312 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/communs/idl-page_man.adb

0141 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/communs/idl-idl_tbl.adb

0556 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/communs/idl-idl_man.adb

0356 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/communs/idl-print_nod.adb
```

package spec **DIANA_NODE_ATTR_CLASS_NAMES**

```
https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/bin/idl_tools/diana_node_attr_class_names.ads
```

***
###	PAR_PHASE

IDL subunit procedure **PAR_PHASE**

_rôle_ : analyse lexicale et syntaxique, construction du réseau DIANA partiel.

```
0813 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/par_phase/idl-par_phase.adb

with LEX, GRMR_OPS, GRMR_TBL;
```
package **GRMR_TBL**

```
0042 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/par_phase/grmr_tbl.ads

with SEQUENTIAL_IO;
```
package **GRMR_OPS**

```
030 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/par_phase/grmr_ops.ads

0120 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/par_phase/grmr_ops.adb
```
package **LEX**

```
0063 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/par_phase/lex.ads

0672 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/par_phase/lex.adb

with TEXT_IO;
```
PAR_PHASE subunit procedure **SET_DFLT**

```
0104 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/par_phase/idl-par_phase-set_dflt.adb
```

***
###	LIB_PHASE

IDL subunit procedure **LIB_PHASE**

rôle : complète le réseau DIANA en chargeant les blocs DIANA compilés antérieurement de la bibliothèque de compilation  (.DCL, .BDY, .SUB)  pour résoudre les WITH et les dépendances aux unités ancêtres.

```
1230 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/ada_comp/idl-lib_phase.adb

with SEQUENTIAL_IO;
```

***
###	SEM_PHASE

IDL subunit procedure **SEM_PHASE**

_rôle_ : effectue l'analyse sémantique du réseau DIANA formé par l'analyse syntaxique et les inclusions de bibliothèque. Ajoute des noeuds sémantique et complète le réseau DIANA par des noeuds sémantiques.

```
2667 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/sem_phase/idl-sem_phase.adb
```
SEM_PHASE subunits

```
0728 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/sem_phase/idl-sem_phase-aggreso.adb
1033 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/sem_phase/idl-sem_phase-att_walk.adb
0096 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/sem_phase/idl-sem_phase-chk_stat.adb
0604 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/sem_phase/idl-sem_phase-def_util.adb
1190 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/sem_phase/idl-sem_phase-def_walk.adb
0316 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/sem_phase/idl-sem_phase-derived.adb
0143 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/sem_phase/idl-sem_phase-eval_num.adb
0515 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/sem_phase/idl-sem_phase-exp_type.adb
0874 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/sem_phase/idl-sem_phase-expreso.adb
0712 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/sem_phase/idl-sem_phase-fix_pre.adb
0627 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/sem_phase/idl-sem_phase-fix_with.adb
0319 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/sem_phase/idl-sem_phase-gen_subs.adb
0101 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/sem_phase/idl-sem_phase-hom_unit.adb
0531 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/sem_phase/idl-sem_phase-instant.adb
2925 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/sem_phase/idl-sem_phase-make_nod.adb
0367 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/sem_phase/idl-sem_phase-newsnam.adb
1466 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/sem_phase/idl-sem_phase-nod_walk.adb
0381 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/sem_phase/idl-sem_phase-pra_walk.adb
0430 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/sem_phase/idl-sem_phase-pre_fcns.adb
1339 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/sem_phase/idl-sem_phase-red_subp.adb
0359 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/sem_phase/idl-sem_phase-rep_clau.adb
0638 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/sem_phase/idl-sem_phase-req_util.adb
0106 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/sem_phase/idl-sem_phase-sem_glob.adb
0709 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/sem_phase/idl-sem_phase-set_util.adb
1028 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/sem_phase/idl-sem_phase-stm_walk.adb
0508 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/sem_phase/idl-sem_phase-uarith.adb 
0576 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/sem_phase/idl-sem_phase-univ_ops.adb
0905 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/sem_phase/idl-sem_phase-vis_util.adb
```

***
###	ERR_PHASE
IDL subunit procedure **ERR_PHASE**

_rôle_ : gère l'affichage des erreurs éventuelles émises lors des phases de compilation.

```
0099 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/ada_comp/idl-err_phase.adb
```

***
###	WRITE_LIB

IDL subunit procedure **WRITE_LIB**

_rôle_ : écrit le réseau DIANA correspondant juste à l'unité compilée sous forme de bloc de pages virtuelles contenant les noeuds dans la bibliothèque. Fichier à extension ".SUB" pour une subunit, ".DCL" pour une specification, ".BDY" pour un corps.  ATTENTION : cette étape détruit le fichier temporaire de travail $$$.TMP dans le tépertoire de  bibliothèque ADA__LIB. Il n'est donc plus question d'utiliser le dump PRETTY_DIANA après cette étape. On peut avoir un arbre complet en stoppant à l'étape d'expansion avec l'option "c".

```
0264 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/ada_comp/idl-write_lib.adb

with SEQUENTIAL_IO;
```

***
##	EXPANDER 6 fichiers

_rôle_ : produit un texte d'assemblage (LLIR Low Level Intermediate Representation) en macro langage de FASM pour l'unité compilée. Le fichier a l'extension".FINC". Les instructions sont celles d'une machine à pile avec des modes d'accès et une structuration mémoire adaptées à Ada 83.

procedure **EXPANDER**

_rôle_ : procédure de lancement de la phase de production du texte de code LLIR.

```
1415 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/expander/expander.adb

with DIANA_NODE_ATTR_CLASS_NAMES, IDL, TEXT_IO;
```
EXPANDER subunits

```
0420 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/expander/expander-utils.adb
0434 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/expander/expander-structures.adb
0945 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/expander/expander-instructions.adb
1054 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/expander/expander-expressions.adb
1703 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/expander/expander-declarations.adb
```

###	PRETTY_DIANA 1 fichier

IDL subunit procedure **PRETTY_DIANA**

_rôle_ : contient un service d'affichage du réseau DIANA contenu dans le fichier temporaire $$$.TMP situé dans le répertoire bibliothèque ./ADA__LIB  lui même dans le répertoire de projet . Les options d'affichage plus ou moins complet sont données à la ligne de commande ("A" all DIANA avec les inclusions, "P" pretty présenté résumé DIANA de l'unité sans les inclusions, "U" ugly tout sans résumé).

```
0441 lignes https://raw.githubusercontent.com/ViMoBr/Ada83_TLALOC/refs/heads/main/src/pretty/idl-pretty_diana.adb
```
