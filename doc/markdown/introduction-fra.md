 <h1 style="text-align:center;">INTRODUCTION</h1>

Le compilateur A83 transforme un fichier texte écrit dans le langage Ada 83 en un fichier exécutable ELF à reliure dynamique.

Le travail de transformation opère en phases bien distinctes qui fabriquent une structure de donnée intermédiaire DIANA (Descriptive Intermediate Attributed Notation for Ada) à partir de laquelle on dérive une structure de données de code intermédiaire optimisable indépendant du matériel MICODE (Machine Independent CODE) et enfin le code exécutable et liable en ELF.

La structure DIANA est stockée par blocs dans un fichier de travail temporaire "$$$.TMP" qui est accessible à toutes les phases.

Le code intermédiaire est conservé dans un fichier ".FINC" au format texte qui peut être examiné.

Le format ELF (Executable and Linkable Format) est utilisé pour la forme exécutable à liaison dynamique, pour chaque unité un fichier ".elf" est donc produit.

Enfin un fichier ".DCL" (ou ".BDY" ou ".SUB" pour un corps ou une sous-unité Ada) contient une description DIANA qui est "withable" dans la phase "lib_phase" de sorte qu'un module puisse en utiliser d'autres en les mentionnant dans une clause "with". Ces fichiers sont stockés dans un répertoire librairie.
```
               |------------|
               |    A83     |
module.adb --> |------------|
               | par_phase  |
               | lib_phase  |
$$$.TMP <----> | sem_phase  |
               | err_phase  |
               | micode_gen | --> module.COD                  (code intermédiaire)
               | code_gen   | --> module.elf                  (exécutable)
               | write_lib  | --> module.DCL / .BDY / .SUB    (unité librairie, DIANA withable)
               |------------|
```
Lors d'un appel au compilateur, on doit fournir 3 paramètres :
* un chemin d'accès à un répertoire "projet" qui contient le répertoire librairie ADA__LIB où seront stockés les ".dcl", ".sub" et ".cod". Cet accès est soit relatif à l'emplacement de l'exécutable ada_comp appelé par a83.sh, soit absolu.

* un accès au texte source à compiler (accès relatif au répertoire projet)

* une lettre indiquant la phase après laquelle on s'arrête. On peut en effet vouloir de faire qu'une analyse syntaxique, vérification rapide d'erreurs de frappe par exemple, ou bien s'arrêter après l'analyse sémantique afin d'examiner la structure DIANA.

Comme il n'y a pas de passage de paramètre à un programme Ada 83, il faut fournir la chaîne de paramétrage via le shell et le standard input.
Il existe donc un fichier script a83.sh prenant 3 paramètres qui sont relayés par une commande :
```
 ./ada_comp <<< "$1 $2 $3"
```
L'appel au compilateur (exécutable "ada_comp") se fait alors par quelque chose comme :
```
 ./a83.sh  ./  ./idl_tools/diana_node_attr_class_names.ads  w
```
Où l'on suppose être dans le répertoire "bin" contenant a83.sh et qui fait office de répertoire projet de test, contenant donc un répertoire "ADA__LIB". De sorte que le chemin projet est "./", l'accès relatif au source est ici "./idl_tools/diana_node_attr_class_names.ads" et la lettre d'arrêt est "w" (arrêt après la phase "write_lib").


## 1. LES PHASES DE COMPILATION ##

Il y a 7 phases de compilation dont la description détaillée suit.

<br></br>

### 1.1 PHASE D'ANALYSE LEXICALE ET SYNTAXIQUE (_"PAR_PHASE"_) ###
Cette phase effectue l'analyse lexicale et syntaxique du texte source soumis à compilation. Il s'agit d'un analyseur LALR(1) classique dont les tables sont fabriquées par un système spécifique présent dans un répertoire "src/lalr_tools".

La structure logicielle de la phase est la suivante (dans le répertoire src/par_phase, le point d'entrée étant la procédure _"par_phase"_) :

---

<pre>
 <h4 style="text-align:center;">PHASE "PAR_PHASE"</h4>

     [ <a href="../../bin/text_io.ads">text_io</a> ..........\
     [<a href="../../bin/text_io.adb">bdy</a>                |
                         |
     [ <a href="../../bin/sequential_io.ads">sequential_io</a> ..\ |
     [bdy              | |
                       | |
                       | |    [ <a href="../../src/par_phase/lex.ads">lex</a> .......\
                       | \..> [<a href="../../src/par_phase/lex.adb">bdy</a>         |
                       |                   |
                       |      [ <a href="../../src/par_phase/grmr_ops.ads">grmr_ops</a> ..|
                       |      [<a href="../../src/par_phase/grmr_ops.adb">bdy</a>         |
                       |                   |
                       \....> [ <a href="../../src/par_phase/grmr_tbl.ads">grmr_tbl</a> ..|
                                           |    [ <a href="../../src/ada_comp/idl.ads">idl</a>
                                           |    | ( par_phase
                                           |    [<a href="../../src/ada_comp/idl.adb">bdy</a>
                                           \..> | _( <a href="../../src/par_phase/idl-par_phase.adb">par_phase</a>
                                                     | _( <a href="../../src/par_phase/idl-par_phase-set_dflt.adb">set_dflt</a>
</pre>

---
 Les fichiers concernés (accessibles par les liens au dessus) sont:
```
   lex.ads           lex.adb
   grmr_ops.ads      grmr_ops.adb
   grmr_tbl.ads
   idl-par_phase.adb
   idl-par_phase-set_dflt.adb

```
---

Le point d'entrée de la phase est la procédure _"idl.par_phase"_ qui est une sous unité séparée du module _"idl"_ dont on parlera plus loin. Sa déclaration a cette forme :
```
    procedure PAR_PHASE ( PATH_TEXTE, NOM_TEXTE, LIB_PATH :STRING );
```

A l'issue de l'éxécution de _"par_phase"_ sur le fichier source, un arbre DIANA ne contenant que les informations de syntaxe est présent dans le fichier de travail "$$$.TMP". un appel de A83 avec une lettre option d'affichage de l'arbre de "$$$.TMP" permet de visualiser l'arbre obtenu.

<br></br>

### 1.2 PHASE LIBRAIRIE (_"LIB_PHASE"_) ###

Le langage Ada 83 permet une compilation modulaire : un module peut utiliser des définitions et des services fournis et compilés précédemment par un autre module qui est mentionné dans une clause "with".

Avant de vérifier si la sémantique statique du fichier compilé est correcte, la phase _"lib_phase"_ lit les fichiers ".DCL" (ou ".BDY" ou ".SUB") et intègre les arbres DIANA de ces modules "withés". Il faut en effet disposer des définitions utilisées et de leurs caractéristiques sémantiques antérieurement obtenues pour vérifier la sémantique du module en cours de compilation.

La phase est contenue dans un seul fichier dans le répertoire src/ada_comp :

<pre>
 <a href="../../src/ada_comp/idl-lib_phase.adb">idl-lib_phase.adb</a>
</pre>

Cette unité procédure _"idl.par_phase"_ séparée du module "idl" est le point d'entrée de la phase. Elle est sans paramètre (mais incluse et séparée du module _"idl"_) :
```
    procedure LIB_PHASE;
```
L'arbre contenu dans "$$$.TMP" est complété par les blocs relogés des unités "withées". La lettre d'arrêt après lib_phase est "L".

<br></br>

### 1.3 PHASE D'ANALYSE SEMANTIQUE (_"SEM_PHASE"_) ###

Cette phase effectue la vérification sémantique statique du module compilé, c'est une phase très complexe répartie en 29 modules (répertoire src/sem_phase) et dont le point d'entrée est la procédure _"idl.sem_phase"_ contenue dans le fichier <pre>
 <a href="../../src/sem_phase/idl-sem_phase.adb">idl-sem_phase.adb</a>
</pre>

La structure logicielle est une inclusion de sous-unités :

---

<pre>
 <h4 style="text-align:center;">PHASE "SEM_PHASE"</h4>
         [ <a href="../../src/ada_comp/idl.ads">idl</a>
         |
         | ( sem_phase
         [<a href="../../src/ada_comp/idl.adb">bdy</a>
         | _( <a href="../../src/sem_phase/idl-sem_phase.adb">sem_phase</a>
              |
              | _[ <a href="../../src/sem_phase/idl-sem_phase-aggreso.adb">aggreso</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-att_walk.adb">att_walk</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-chk_stat.adb">chk_stat</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-def_util.adb">def_util</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-def_walk.adb">def_walk</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-derived.adb">derived</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-eval_num.adb">eval_num</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-expreso.adb">expreso</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-exp_type.adb">exp_type</a>
              | _( <a href="../../src/sem_phase/idl-sem_phase-fix_pre.adb">fix_pre</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-fix_with.adb">fix_with</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-gen_subs.adb">gen_subs</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-hom_unit.adb">hom_unit</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-instant.adb">instant</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-make_nod.adb">make_nod</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-newsnam.adb">newsnam</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-nod_walk.adb">nod_walk</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-pra_walk.adb">pra_walk</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-pre_fcns.adb">pre_fcns</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-red_subp.adb">red_subp</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-rep_clau.adb">rep_clau</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-req_util.adb">req_util</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-sem_glob.adb">sem_glob</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-set_util.adb">set_util</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-stm_walk.adb">stm_walk</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-uarith.adb">uarith</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-univ_ops.adb">univ_ops</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-vis_util.adb">vis_util</a>
</pre>

---
   Les fichiers concernés sont dans src/sem_phase :
```
     idl-sem_phase
     idl-sem_phase-aggreso.adb       idl-sem_phase-att_walk.adb
     idl-sem_phase-chk_stat.adb      idl-sem_phase-def_util.adb
     idl-sem_phase-def_walk.adb      idl-sem_phase-derived.adb
     idl-sem_phase-eval_num.adb      idl-sem_phase-expreso.adb
     idl-sem_phase-exp_type.adb      idl-sem_phase-fix_pre.adb
     idl-sem_phase-fix_with.adb      idl-sem_phase-gen_subs.adb
     idl-sem_phase-hom_unit.adb      idl-sem_phase-instant.adb
     idl-sem_phase-make_nod.adb      idl-sem_phase-newsnam.adb
     idl-sem_phase-nod_walk.adb      idl-sem_phase-pra_walk.adb
     idl-sem_phase-pre_fcns.adb      idl-sem_phase-red_subp.adb
     idl-sem_phase-rep_clau.adb      idl-sem_phase-req_util.adb
     idl-sem_phase-sem_glob.adb      idl-sem_phase-set_util.adb
     idl-sem_phase-stm_walk.adb      idl-sem_phase-uarith.adb
     idl-sem_phase-univ_ops.adb      idl-sem_phase-vis_util.adb
```
---

<br></br>

### 1.4 PHASE _"ERR_PHASE"_ ###

Les erreurs trouvées dans les phases précédentes sont accumulées dans l'arbre DIANA et présentées dans la phase _"err_phase"_. s'il y a des erreurs, les phases suivantes ne sont pas exécutées.
La procédure ERR_PHASE sans paramètre est contenue dans le fichier idl-err_phase.adb du répertoire src/ada_comp.

<pre>
 <a href="../../src/ada_comp/idl-err_phase.adb">idl-err_phase.adb</a>
</pre>

Elle est séparée du module _"idl"_.

<br></br>

### 1.5 PHASE GENERATION DE CODE INTERMEDIAIRE (_"MICODE_GEN"_) ###

A partir de l'arbre DIANA vérifié tant syntaxiquement que sémantiquement, une forme de code machine intermédiaire indépendant du matériel cible est élaborée.
Le premier compilateur Ada 83 validé ciblait un interpréteur de machine à pile. Le seul source accessible en langage C est celui de Ada-Ed.
Un projet ultérieur mené en Pologne (voir le dossier doc/Thèses_Pologne) utilisait un code intermédiaire de machine à pile, mais avec l'intention de le traduire en assembleur machine 386 (thèse de A.Wierzinska). Le traducteur de DIANA en "A-Code", une extension du traditionnel P-Code de Pascal pour l'Ada, a été construit par M.Cierniak et peut servir d'exemple.
Cependant, les processeurs actuels (2024) sont des machines à registres et les optimiseurs de code les plus modernes, comme LLVM ou des substituts plus simples tel QUBE, travaillent sur une représentation en opérations à 3 adresses et une approche SSA (Single Static Assignment). la question se pose donc de savoir s'il n'est pas judicieux de viser un code intermédiaire de ce genre, plus facile à traduire en assembleur par exemple pour du RISC-V qui a l'avantage d'être une spécification moderne et "propre" comparé à du processeur Amd/Intel x86 très alourdi par son histoire et les contraintes de compatibilité.

<br></br>

### 1.6 PHASE GENERATION DE CODE CIBLE (_"CODE_GEN"_) ###

Le code intermédiaire est ensuite traduit en code machine cible porté dans des fichiers ELF qui ont l'avantage d'être on seulement directement exécutables, mais de posséder un mécanisme de liaison dynamique qui permet de se passer d'un relieur (linker) classique.

<br></br>

### 1.7 PHASE ECRITURE DE MODULE LIBRAIRIE (_"WRITE_LIB"_) ###

La dernière opération du compilateur consiste à fabriquer un bloc d'arbre DIANA qui peut être intégré à une autre compilation ultérieure qui utiliserait en clause "with" le module que l'on finit de compiler.
Tous les blocs DIANA du module en cours de compilation ne sont pas à sauvegarder parce que certaines parties de l'arbre dans $$$.TMP proviennent de clauses "with" et donc de fichiers librairies déjà sauvegardés.
Or la séquence des phases est telle que les blocs d'arbre DIANA à sauvegarder (provenant de l'analyse syntaxique puis de l'analyse sémantique) sont séparé par des blocs "withés à ne pas sauvegarder". Il faut donc reloger les noeuds à sauvegarder et les compacter en une seule plage de blocs dont ont fait le fichier .DCL, .BDY ou .SUB.
Un algorithme de marquage à la relocation détruit l'ancien arbre (certains pointeurs étant volontairement dénaturés lors du marquage). Ce n'est pas grave dans la mesure où il n'y a plus d'opération à faire après cette dernière phase, et que l'examen de l'arbre DIANA, s'il faut le faire, peut se faire en stoppant avant la phase _"write_lib"_.
Cette phase est effectuée par la procédure présente dans le fichier de src/ada_comp :
<pre>
 <a href="../../src/ada_comp/idl-write_lib.adb">idl-write_lib.adb</a>
</pre>

