# JOURNAL DES SESSIONS — récits datés (append-only)

Le « pourquoi » des décisions. L'état courant est dans ETAT_PILIERS.md ;
les pièges extraits des sessions sont dans PIEGES.md (numéros cités ici).

## 11. CALENDAR, FIXED_IO et reprises TEXT_IO

15 mai à 5 juin 2026. La réalisation du package CALENDAR a requis la mise en place du calcul sur type réel Ada FIXED, particulièrement pour DURATION et TIME. Le package CALENDAR est opérationnel, le sous package générique FIXED_IO de TEXT_IO a été rédigé et testé. Les procédures GET de TEXT_IO qui utilisaient un GET_LINE ont été reprises et sont maintenant conformes aux règles de lecture Ada avec des scanners appropriés. Le calcul sur type FIXED n'est cependant pas tout à fait complet, en particulier pour les multiplications et divisions, et les opérations arithmétiques sur type FIXED sont en place pour que CALENDAR fonctionne avec le type DURATION défini dans STANDARD. On peut considérer que mis à part le traitement des exceptions, TEXT_IO est presque achevé et fonctionne ainsi que CALENDAR dans les cas normaux d'utilisation.

## 12. Expérimentation avec SEQUENTIAL_IO

Session 5 juin 2026 — Validation communication série Arduino
Communication entre un binaire TLALOC et un Arduino Uno équipé d'un shield afficheur ILI9481 480×320 validée. SEQUENTIAL_IO instancié sur CHARACTER permet un protocole binaire octet par octet via /dev/ttyACM0 (device cdc_acm). Le programme de test serial_test.adb ouvre le port, envoie des commandes de couleur et des chaînes ASCII, ferme proprement — l'afficheur Arduino reçoit et affiche correctement texte et couleurs.
Contraintes identifiées et résolues : (1) la configuration stty ne persiste pas entre ouvertures sur cdc_acm — contournement par un fd externe maintenu ouvert (tail -f /dev/null > /dev/ttyACM0 &) ; (2) reset automatique de l'Arduino à l'ouverture du port DTR — condensateur 10 µF entre RESET et GND ; (3) buffer UART matériel de l'Uno limité à 64 octets, insuffisant pour un envoi en rafale depuis sys_write — porté à 256 octets dans HardwareSerial.h.
Côté afficheur, deux corrections au sketch Arduino : inversion de la coordonnée X dans drawPixel (x + (FONT_W - 1 - px) au lieu de x + px) pour le mirroir horizontal, et inversion de la palette RGB565 pour la polarité inversée du bus 8 bits du shield clone.
Reste à faire : macro SYS_SERIAL_CONFIG (ioctl/tcsetattr) dans codi_x86_64.finc pour rendre la configuration du port autonome sans dépendre du fd externe ; validation de la réception (INOUT_FILE + READ bloquant) ; gestion des timeouts via SYS_SELECT ou SYS_POLL pour éviter un sys_read bloquant indéfiniment.


## Session 10 juin 2026 — Retour de record par fonction

Implémentation du retour de valeur composite de type record par les fonctions Ada 83. La convention retenue est symétrique à celle des paramètres out composites : l'appelant alloue un doublet anonyme (_disp, __u, __dat) dans sa VARzone et empile son adresse comme result__ofs supplémentaire (dernier PRM). La fonction remplit les données brutes via La , 0 (extraction du data_ptr depuis le doublet) suivi de CODE_AGGREGATE ou BLKMOV selon que l'expression retournée est un agrégat ou une variable. Côté appelant, après le CALL, le sommet de pile est l'adresse du doublet résultat, utilisable directement comme opérande dans une expression ou affecté par BLKMOV dans COMPILE_RECORD_VAR. Cinq corrections ont été nécessaires : (1) CODE_FUNCTION_CALL pour l'allocation du doublet anonyme au lieu du LI 0 scalaire ; (2) CODE_RETURN pour le La , 0 + agrégat ou BLKMOV ; (3) COMPILE_RECORD_VAR pour l'initialisation par function_call ; (4) CODE_AGGREGATE branche record pour le BLKMOV des composantes de type record (le DUP global supprimé, chaque branche gérant le sien) ; (5) CODE_SELECTED branche else pour la lecture d'un champ scalaire terminal sur adresse directe en pile : L & OPER_SIZ_CHAR avec lvl=-1 (et non LId qui déréférence deux fois, ni LVA qui n'accède pas à la valeur). Validé sur records plats, records imbriqués, fonctions retournant un record utilisé directement comme paramètre sans variable intermédiaire, et lecture de champs de champs (S.A.X).

## Session 14 juin 2026 CODE_ASSIGN — rationalisation des affectations `selected` / `indexed` de records

Une étape importante de consolidation de `EXPANDER.INSTRUCTIONS.CODE_ASSIGN` a été réalisée lors du début de bootstrap du compilateur TLALOC par lui-même. Le problème initial venait d’une simplification dangereuse : lorsqu’une destination d’affectation était un `DN_SELECTED`, `CODE_ASSIGN` remplaçait cette destination par son dernier designator via `LAST_OF_SELECTED`. Cette ruse fonctionnait dans quelques cas simples, mais elle détruisait l’information essentielle de base pour les affectations à des composantes de records. Par exemple, `R.C := X;` ne doit pas être traité comme une affectation au seul `component_id C`, mais comme une affectation à l’adresse effective `adresse de R + offset(C)`. Un `DN_COMPONENT_ID` n’est pas une cellule mémoire autonome ; il n’a de sens qu’en tant qu’offset relatif à un objet record.

La règle désormais retenue est de respecter plus explicitement le modèle LLIR : les scalaires, les access, les fixed et les float transitent directement sur la pile sous forme de valeur, puis sont stockés ; les composites, c’est-à-dire records, arrays, strings et slices, transitent par adresse de données et sont copiés par `BLKMOV` lorsque nécessaire. Pour une destination calculée (`selected`, `indexed`, `slice`, et plus tard `all`), le schéma général devient : calculer `@destination`, évaluer la source, puis stocker indirectement ou copier par `BLKMOV`.

Le traitement dangereux suivant a donc été supprimé :

```
if DST_NAME.TY = DN_SELECTED then
   DST_NAME := CODI.LAST_OF_SELECTED( DST_NAME );
end if;
```
Une vraie branche DN_SELECTED a été ajoutée dans CODE_ASSIGN. Elle appelle maintenant :

EXPRESSIONS.CODE_SELECTED( DST_NAME, IS_SOURCE => FALSE );

afin de calculer l’adresse effective de la destination. Cela permet de traiter correctement les affectations à des composantes scalaires et composites, par exemple R.I := 12, R.E := ROUGE, R.C := R2.C ou R.C := (4, 8).

Une correction a aussi été faite sur les copies composites sélectionnées. Pour une affectation du type R1.C := R2.C;, le code généré ne doit pas faire de La après la source R2.C, car CODE_SELECTED fournit déjà l’adresse des données de la composante. Le La ne reste nécessaire que pour les objets composites représentés par un doublet, par exemple une variable record autonome dont CODE_EXP fournit l’adresse du doublet avant extraction de l’adresse des données.

CODE_INDEXED a ensuite été corrigé pour les tableaux composants de records. Le cas R.A(N) := (12,12);, où A est une composante tableau d’un record, ne doit pas utiliser A__u, car A__u n’existe que pour un objet tableau autonome. La règle introduite est donc la suivante : pour A(N), où A est un tableau objet autonome, on utilise le couple A_disp / A__u; pour R.A(N), où A est une composante inline d’un record, l’adresse de base est déjà calculée par CODE_SELECTED, et les informations de bornes et de taille de composant sont chargées directement depuis le type TABLE.

CODE_SELECTED a également été complété pour les sélections dont le préfixe est indexé. Les formes R.A(N).X et A(N).X ont la structure DIANA d’un DN_SELECTED dont le préfixe est un DN_INDEXED. Le schéma ajouté est :

elsif PREFIX.TY = DN_INDEXED then
   CODE_INDEXED( PREFIX );
   PROCESS_DESIGNATOR;

Ainsi, CODE_INDEXED produit d’abord l’adresse de l’élément de tableau, puis PROCESS_DESIGNATOR ajoute l’offset du champ sélectionné, ou charge directement la valeur du champ selon que CODE_SELECTED est appelé en contexte source ou destination.

Une protection défensive a enfin été ajoutée dans CODE_ASSIGN contre les destinations dont SM_EXP_TYPE vaut DN_VOID. Ce cas ne devrait normalement jamais parvenir à l’expander ; il révèle plutôt un défaut antérieur de résolution sémantique.

Le programme de test TEST_ASSIGN_1 valide maintenant les cas suivants :

R.I := 12;                  -- composante entière
R.F := 1.25;                -- composante flottante
R.E := ROUGE;               -- composante énumération

R1.C := R2.C;               -- affectation composante record par BLKMOV
R1.C := (4, 8);             -- affectation composante record par agrégat

A(N).X := 12;
A(N).Y := 13;               -- indexed puis selected

R.A(N) := (12,12);          -- selected puis indexed, élément record

La sortie obtenue est :

cas 1 R.I  12
cas 2 R.F  1.25000E+000
cas 3 R.E ROUGE
cas 4 R1.C [         12,         24]
cas 5 R1.C [          4,          8]
cas 6 A(N).X A(N).Y   [         12,         13]
cas 7 R.A(N) [         12,         12]

Un défaut du frontend a été identifié au passage. Le test erroné A(N).C := 12;, où A(N) est de type SUBREC ne contenant que les champs X et Y, n’est pas rejeté par la phase sémantique. Le champ C n’existe pas dans SUBREC, mais le frontend laisse passer une expression dont SM_EXP_TYPE vaut DN_VOID. Ce cas est maintenant intercepté défensivement par l’expander, mais la vraie correction devra être faite côté SEM_PHASE : la résolution d’un selected dont le préfixe est un DN_INDEXED doit vérifier que le designator appartient bien au type record de l’élément indexé.

Cette étape clarifie proprement la frontière entre objet autonome, composante inline, adresse calculée et copie composite. Elle stabilise CODE_ASSIGN sans remettre en cause les chemins déjà sophistiqués de l’expander, notamment les paramètres, les génériques et les stores indirects par CALLI.

# Session 14 juin 2026 — Traitement des déclarations d’objets renommés (renames)

Une correction importante a été apportée à l’EXPANDER pour traiter les déclarations Ada 83 d’objets renommés, jusque-là incomplètes dans EXPANDER.DECLARATIONS.CODE_RENAMES_OBJ_DECL. Le problème initial apparaissait pendant le début de bootstrap de TLALOC par lui-même, dans IDL.adb, procédure MAKE, sur le motif IDL_TBL.N_SPEC( NN ).NS_SIZE = 0. Le nom introduit par renames était représenté dans DIANA par un DN_VARIABLE_ID ayant SM_RENAMES_OBJ = TRUE, mais l’expander le traitait ensuite comme une variable ordinaire dotée d’un CD_LEVEL et d’un CD_OFFSET normaux. Comme aucune vraie allocation n’avait été faite pour cet objet renommé, l’accès ultérieur pouvait produire une erreur du type : L ATTRIBUT CD_LEVEL DU NOEUD [DN_VARIABLE_ID<...>] N EST PAS UN ENTIER.

La règle retenue est que le renames Ada 83 n’est pas une nouvelle variable, mais un alias vers un objet existant. Il ne faut donc pas recopier naïvement le CD_LEVEL ou le CD_OFFSET de l’objet renommé, car le renommé peut être une adresse calculée complexe : composante de record, élément de tableau, combinaison selected/indexed/selected, etc. La solution mise en place consiste à matérialiser localement le renommage par un petit objet pointeur. Pour un alias scalaire, X_disp contient l’adresse effective de l’objet réel renommé. La lecture de X doit donc être indirecte (LIx lvl, X_disp, 0) et l’écriture également indirecte (SIx lvl, X_disp, 0). Pour un alias composite, le modèle TLALOC habituel est conservé : Y_disp contient l’adresse des données réelles et Y__u contient l’adresse du patron de type ; le couple Y_disp/Y__u forme donc un doublet composite normal utilisable par les chemins existants de BLKMOV, selected, indexed et passage de paramètres.

Une procédure auxiliaire de calcul d’adresse d’objet, du type CODE_OBJECT_ADDRESS, a été introduite côté expressions. Elle laisse sur la pile l’adresse brute des données désignées par un nom adressable. Elle couvre notamment les DN_USED_OBJECT_ID, DN_SELECTED et DN_INDEXED, en s’appuyant sur les corrections récentes de CODE_SELECTED et CODE_INDEXED, capables de produire l’adresse effective d’une destination calculée. Un point important a été identifié dans renames_obj_decl : il ne faut pas utiliser AS_NAME comme source de vérité après la phase sémantique. Dans certains cas comme Y : REC renames T(2);, le parseur conserve dans AS_NAME une forme syntaxique DN_FUNCTION_CALL, tandis que la sémantique a correctement reconstruit dans SM_INIT_EXP du DN_VARIABLE_ID renommant la vraie forme DN_INDEXED. CODE_RENAMES_OBJ_DECL utilise donc désormais SM_INIT_EXP(SOURCE_NAME) pour coder l’adresse du renommé, avec éventuellement AS_NAME seulement comme repli défensif.

CODE_RENAMES_OBJ_DECL déclare maintenant un VAR <nom>_disp, q, calcule l’adresse effective du renommé via CODE_OBJECT_ADDRESS, puis stocke cette adresse dans <nom>_disp. Si le type renommé est composite, il déclare également <nom>__u et y place l’adresse du patron de type correspondant, de façon à présenter l’alias composite comme un doublet TLALOC ordinaire. Le DN_VARIABLE_ID ou DN_CONSTANT_ID introduit par le renommage reçoit alors un CD_LEVEL correspondant au niveau où ce petit pointeur d’alias est déclaré, et CD_COMPILED est positionné à TRUE. Ainsi, l’objet renommant possède bien un support mémoire local, mais ce support n’est qu’un pointeur vers l’objet réel.

Une première correction dans CODE_VC_ID a ajouté une branche spéciale pour SM_RENAMES_OBJ. Pour un renommage scalaire, la lecture génère LI + suffixe de taille (LIb, LIw, LId, LIq) sur <nom>_disp, 0, donc lit la valeur pointée. Pour un renommage composite, la lecture génère LVA lvl, <nom>_disp, afin de fournir l’adresse du doublet alias. Le test initial a montré que l’affectation à un alias scalaire fonctionnait déjà, mais que la lecture produisait une valeur aberrante : X avant = 2118616188. Le FINC montrait alors Ld 1, X_disp, c’est-à-dire un chargement du contenu du slot X_disp lui-même, donc des bits bas de l’adresse, au lieu d’un chargement indirect de la valeur renommée. L’analyse a montré que certains chemins de l’expander appellent directement LOAD_MEM sans passer par CODE_VC_ID. La correction décisive a donc été de traiter également SM_RENAMES_OBJ au début de LOAD_MEM, avec la même convention : LIx lvl, X_disp, 0 pour un scalaire renommé, LVA lvl, Y_disp pour un composite renommé.

Le test TEST_RENAMES_1 a validé les cas essentiels. Pour X : INTEGER renames R.B, la lecture de X donne bien la valeur initiale de R.B, puis X := 99 modifie effectivement R.B. Pour Y : REC renames T(2), les affectations Y.A := 300 et Y.B := 400 modifient l’élément réel T(2). Le test a ensuite été complété par des écritures croisées entre l’objet réel et l’alias composite : R.A := 111, R.B := 222, puis Y.A := 333, Y.B := 444, toutes correctement relues. La sortie validée est :

X avant =          20
R.B apres X := 99 =          99
T(2).A =         300
T(2).B =         400
R.A =         111
R.B =         222
Y.A =         333
Y.B =         444

Enfin, la compilation de IDL.adb passe désormais dans l’expander. Cela valide le motif réaliste qui avait déclenché l’erreur initiale : un renommage ou usage apparenté sur une chaîne d’adressage selected → indexed → selected, comme IDL_TBL.N_SPEC( NN ).NS_SIZE. La correction stabilise donc le traitement des renames d’objets scalaires et composites sur noms adressables, sans remettre en cause les chemins existants de variables ordinaires, de records, de tableaux, de paramètres, de génériques et de copies composites par BLKMOV.


# Session 19 juin 2026 — Réécriture de CODE_ARRAY_AGGREGATE et stabilisation des tableaux composants de records

Une étape importante a été réalisée sur le traitement des agrégats de tableaux dans EXPANDER.EXPRESSIONS.CODE_ARRAY_AGGREGATE. L’ancienne procédure distinguait trop fortement les cas DN_ARRAY et DN_CONSTRAINED_ARRAY : le premier était traité comme dynamique mais de façon limitée, tandis que le second supposait des bornes statiques récupérables par SM_VALUE. Cette hypothèse était fausse pour certains DN_CONSTRAINED_ARRAY dont les bornes peuvent dépendre d’expressions dynamiques. La procédure a donc été reprise avec une règle plus robuste : considérer les bornes comme dynamiques, y compris lorsqu’elles sont statiquement connues, et calculer dynamiquement longueurs, strides et positions d’écriture. Le traitement est ainsi uniformisé pour DN_ARRAY et DN_CONSTRAINED_ARRAY, avec prise en charge de plusieurs dimensions.

La notation des champs de gestion de tableaux a également été clarifiée pour éviter une collision dangereuse entre variables de gestion et offsets de use_info. Les variables réelles du type tableau sont maintenant préfixées par un underscore, par exemple _COMP_SIZ, _FST_1, _LST_1, tandis que les noms sans underscore COMP_SIZ, FST_1, LST_1, etc. restent les offsets statiques dans le bloc use_info. Cette distinction est essentielle : un accès direct à un type statique utilise les variables _FST_n, _COMP_SIZ, alors qu’un accès via un paramètre tableau utilise le pointeur __u et les offsets FST_n, COMP_SIZ.

Plusieurs erreurs successives ont été isolées et corrigées. La première venait de l’écriture des valeurs d’agrégat : l’adresse courante du tableau devait être utilisée comme pointeur indirect, et non comme simple emplacement mémoire. L’usage de SId avec un pointeur de parcours a permis d’écrire correctement les éléments dans les données du tableau. La deuxième difficulté concernait les tableaux multidimensionnels : le calcul des strides devait respecter l’ordre des dimensions et l’indexation Ada en mémoire linéaire. Les tests ont validé les tableaux 2D et 3D, notamment les accès M(2,3) et C1(2,2,3). La troisième difficulté concernait les tableaux composants de records, par exemple H.V, où V est un tableau inline dans un record. L’indexation directe H.V(I) ne doit pas chercher un couple V_disp/V__u, inexistant pour une composante inline, mais partir de l’adresse du composant calculée par CODE_SELECTED, puis ajouter l’offset d’index.

Un dernier défaut plus subtil est apparu lors du passage d’un composant tableau comme paramètre, par exemple CHECK_VECTEUR_PARAM(H.V, ...) ou CHECK_VECTEUR_PARAM(RV.V, ...). La convention TLALOC pour les composites passés en paramètre est de transmettre l’adresse d’un doublet {data_ptr, use_info_ptr}. Une variable tableau autonome possède naturellement ce doublet sous la forme V_disp suivi de V__u. En revanche, un composant tableau inline dans un record ne possède que ses données dans le record ; l’emplacement H.V + 8 est au milieu des données du tableau, pas un pointeur use_info. Le code généré empilait donc seulement l’adresse des données du composant, ce qui provoquait un faux use_info et un segfault dans la procédure appelée.

La correction a été faite dans EXPANDER.INSTRUCTIONS.CODE_PROCEDURE_CALL, dans la gestion des paramètres effectifs de type DN_SELECTED. Lorsqu’un paramètre effectif sélectionné est composite, en particulier tableau ou record, l’expander fabrique désormais un petit doublet temporaire local :

VAR SELARG_x_disp, q
VAR SELARG_x__u,   q

Il y stocke l’adresse des données calculée par CODE_SELECTED(..., IS_SOURCE => FALSE), puis l’adresse du use_info du type, et transmet enfin LVA SELARG_x_disp à la procédure appelée. Cela rend un composant composite inline équivalent, du point de vue de l’appel, à une variable composite autonome.

Le programme TEST_AGREGATS_2 valide maintenant l’ensemble des cas suivants : agrégats de tableaux 1D positionnels, nommés et avec others, tableaux à borne zéro, passage de tableaux en paramètres, indexation scalaire, tableaux multidimensionnels, tableaux de records, records contenant tableaux, affectation d’éléments de tableaux composants de records, passage de ces composants tableaux en paramètres, et tableaux locaux à bornes dynamiques. La sortie finale obtenue est :

=== bilan ===
TOUS LES TESTS SONT OK

Cette étape stabilise fortement la frontière entre variable tableau autonome, composant tableau inline, doublet composite {data,use_info}, offsets statiques de use_info, et calcul dynamique des dimensions. Elle prépare aussi les prochains chantiers liés au bootstrap, où les structures DIANA combinent records, tableaux, accès, contraintes dynamiques et représentations compactes.

## Session 21 juin 2026 — Clauses de représentation pour records compacts et type DIANA TREE

Une étape importante a été franchie dans le traitement des clauses de représentation Ada 83, avec pour objectif direct le support du type DIANA `TREE`, record à variantes compacté sur 32 bits. Ce type est central pour le bootstrap de TLALOC, car il sert de représentation compacte des pointeurs DIANA et combine discriminant, variantes superposées et champs numériques dans un seul mot machine.

Un nouveau sous-ensemble de services a été ajouté dans l’EXPANDER sous la forme du package interne `REPRESENTED_ITEMS`, placé dans le corps de `EXPANDER` de façon à être accessible aux déclarations, expressions et instructions. Ce package regroupe désormais les opérations liées aux types possédant une clause de représentation de record : détection d’un record représenté, lecture des `comp_rep`, calcul de taille effective, génération du patron de type, génération d’agrégat compacté, lecture de composant représenté et écriture de composant représenté.

La première difficulté a été de comprendre correctement les informations fournies par DIANA. Pour `TREE`, le champ backend `CD_IMPL_SIZE` du `DN_RECORD` vaut encore zéro au moment où l’expander intervient, alors que la taille sémantique provenant de la clause `for TREE'SIZE use 32` est déjà disponible dans `SM_SIZE`. Le calcul de taille des records représentés a donc été corrigé pour utiliser prioritairement `SM_SIZE`, puis l’occupation maximale calculée à partir des `DN_COMP_REP`, et seulement en dernier recours `CD_IMPL_SIZE`. Cela permet de générer correctement le patron :

```
TREE = 'TREE'
namespace TREE
VAR use__info, q
VAR SIZ, d
        LVA     1, SIZ
        Sa      1, use__info
        LI      32
        Sd      1, SIZ
size = 4
...
end namespace
```

La deuxième difficulté venait du lien retour `SM_COMP_REP`. Dans le dump DIANA de `TREE`, les nœuds `DN_COMP_REP` contiennent bien le nom résolu du composant ou discriminant par `AS_NAME.SM_DEFN`, mais le `DN_DISCRIMINANT_ID` `PT` ne possède pas nécessairement un `SM_COMP_REP` exploitable. Le parcours des clauses de représentation a donc été inversé : au lieu de partir du composant et d’exiger son lien retour `SM_COMP_REP`, l’expander parcourt directement la séquence `AS_COMP_REP_S` du `DN_RECORD_REP` et utilise chaque `DN_COMP_REP` comme source de vérité. Cette correction est essentielle pour les discriminants représentés.

La génération des records représentés a été limitée volontairement à un premier périmètre robuste : records tenant sur au plus 64 bits, avec les champs représentés à `byte_offset = 0`. Ce périmètre couvre le cas visé de `TREE`, où les champs sont superposés selon les variantes :

```
PT   at 0 range 0  .. 1
LN   at 0 range 2  .. 8
SLN  at 0 range 2  .. 8
NSIZ at 0 range 2  .. 8
PG   at 0 range 9  .. 23
SPG  at 0 range 9  .. 23
ABSS at 0 range 9  .. 23
COL  at 0 range 24 .. 31
TY   at 0 range 24 .. 31
NOTY at 0 range 24 .. 31
```

La génération des agrégats de record représenté a ensuite été ajoutée par `CODE_REPRESENTED_RECORD_AGGREGATE`. La convention retenue est que l’adresse des données du record est déjà au sommet de pile, comme dans le chemin record ordinaire. L’expander duplique cette adresse, initialise un accumulateur entier à zéro, puis insère chaque composant d’agrégat dans sa plage de bits. Les agrégats utilisés pour les constantes `TREE_NIL`, `TREE_VOID` et `TREE_ROOT` sont ainsi compactés directement dans un mot 32 bits au lieu de passer par les offsets de record ordinaire. Le FINC généré pour `TREE_ROOT` est maintenant de la forme :

```
La 1, TREE_ROOT_disp
                        ; Assign_represented_record_aggregate size 32 bits
DUP
LI      0
                        ; pack PT range 0 .. 1 width 2
LI      0
LI      0
LI      2
BFI
                        ; pack TY range 24 .. 31 width 8
LI      2
LI      24
LI      8
BFI
                        ; pack PG range 9 .. 23 width 15
LI      1
LI      9
LI      15
BFI
                        ; pack LN range 2 .. 8 width 7
LI      0
LI      2
LI      7
BFI
Sd
DROP
```

Pour rendre cette génération lisible et réutilisable, la LLIR x86-64 a été enrichie de primitives de manipulation de champs de bits. `UBFX` et `SBFX` étaient déjà ajoutées pour l’extraction unsigned/signed. Une nouvelle macro `BFI` a été définie comme insertion de champ dans une valeur empilée, avec la convention :

```
old_quad, inserted_value, lsb, width  -->  new_quad
```

Son effet est :

```
new_quad =
  (old_quad and not (((1 << width) - 1) << lsb))
  or ((inserted_value and ((1 << width) - 1)) << lsb)
```

Cette primitive joue le rôle symétrique de `UBFX/SBFX`. Elle sert à la fois au packing des agrégats représentés et à l’affectation ultérieure de champs représentés. Une correction d’encodage a été notée lors de l’optimisation de la macro : après dépilement de `width`, `lsb` et `inserted_value`, la valeur initiale à modifier se trouve en `[rbp]`; l’instruction d’effacement du champ doit donc viser `[rbp]` et non `[rbp+8]`.

La lecture de composant représenté a été intégrée dans `CODE_SELECTED`. Lorsque le designator d’une sélection est un `DN_COMPONENT_ID` ou un `DN_DISCRIMINANT_ID` possédant une représentation, l’expander ne calcule plus un offset `STATOFS` ordinaire. Il charge l’adresse des données du record préfixe, lit le mot compacté, puis extrait la plage de bits par `UBFX` ou `SBFX`. Pour `TREE_ROOT.TY`, le schéma généré est conceptuellement :

```
La 1, TREE_ROOT_disp
Ld
LI 24
LI 8
UBFX
```

et pour `TREE_ROOT.PG` :

```
La 1, TREE_ROOT_disp
Ld
LI 9
LI 15
UBFX
```

L’écriture de composant représenté a ensuite été ajoutée par `CODE_STORE_REP_COMPONENT`. L’intégration se fait dans `CODE_ASSIGN` avant le chemin `DN_SELECTED` ordinaire, car pour un champ représenté l’adresse utile est celle du record entier, non celle d’un composant à offset statique. La procédure reçoit l’adresse des données du record sur la pile, duplique cette adresse pour conserver la destination, charge l’ancien mot compacté, évalue l’expression source, applique `BFI`, puis stocke le mot modifié. Pour une affectation comme :

```
T.PG := 12;
```

le schéma LLIR est :

```
La 1, T_disp
DUP
Ld
LI 12
LI 9
LI 15
BFI
Sd
```

Les tests réalisés valident la chaîne complète. Les constantes représentées sont correctement initialisées et relues :

```
TREE_NIL.TY=> DN_NIL, TREE_NIL.PG=>  0
T.TY=> DN_NIL, T.PG=>  0
```

L’affectation répétée d’un même champ montre que `BFI` efface bien l’ancien contenu du champ avant insertion, et ne se contente pas d’un `or` :

```
T.PG := 12;
T.PG := 3;
```

donne :

```
apres assign 12 et 3 T.PG=>  3
```

Enfin, l’affectation de plusieurs champs disjoints du même mot compacté vérifie l’indépendance des plages de bits :

```
T.TY := DN_ROOT;
T.PG := 24;
T.LN := 5;
```

donne :

```
apres assign DN_ROOT, 24, 5
T.TY=> DN_ROOT, T.PG=> 24, T.LN=>  5
```

Cette session valide donc un premier support opérationnel des clauses de représentation de records compacts tenant dans un mot machine : lecture de la clause `T'SIZE`, génération du patron de type, compactage des agrégats, lecture de composants par extraction de bits et écriture de composants par insertion de bits. Le type `TREE` de DIANA est maintenant utilisable en lecture et en écriture dans ce périmètre. Les limites connues restent volontairement simples : champs à `byte_offset = 0`, taille totale inférieure ou égale à 64 bits, et pas encore de généralisation aux clauses plus larges ou aux représentations multi-octets avec offsets non nuls. Pour le bootstrap de TLALOC, ce jalon est néanmoins majeur, car il couvre précisément le modèle compact du nœud DIANA `TREE`.

## Session 22 juin 2026 — Support minimal de `new`, des types access et de `.all` pour le bootstrap

Une étape importante a été franchie dans le support minimal de l’allocation dynamique Ada 83, avec pour objectif immédiat de débloquer les modules du frontend TLALOC qui utilisent des buffers de pages DIANA alloués dynamiquement, en particulier `IDL.PAGE_MAN.adb` et `IDL.IDL_MAN.adb`. Le cas réduit `TEST_NEW.adb` reproduisait le motif réaliste issu du gestionnaire de pages : un tableau `PAG` de records `RPG_DATA`, chaque record contenant un champ access `DATA : A_SECTOR`, où `A_SECTOR` désigne un `SECTOR`, tableau contraint de 128 valeurs `TREE`. L’expression critique était de la forme `PAG(CUR_RP).DATA.all(1).ABSS`, combinant indexation de tableau, sélection de champ record, déréférencement access par `.all`, nouvelle indexation du tableau désigné, puis lecture d’un champ représenté compacté dans le type DIANA `TREE`.

L’erreur initiale était `FUNCTION D : PAS D ATTRIBUT LX_SYMREP DANS [DN_ALL<...>]`. Elle venait du fait que `CODE_INDEXED` rencontrait comme préfixe un nœud `DN_ALL`, mais supposait encore que le préfixe indexé était un nom ordinaire possédant `LX_SYMREP`. La correction a consisté à introduire un vrai traitement de `DN_ALL` dans l’expander : `.all` est désormais considéré comme un préfixe adressable qui fournit l’adresse brute de l’objet désigné par une valeur access. La convention retenue pour ce premier périmètre est simple : une valeur access est un pointeur machine de 64 bits vers les données du désigné ; `null` vaut zéro ; `new T` alloue la taille de `T` sur un tas rudimentaire et retourne l’adresse brute ; `X.all` utilise cette adresse comme base de l’objet désigné.

Côté LLIR, une macro minimale `HEAP_ALLOC` a été ajoutée. Elle implémente volontairement un simple bump allocator descendant basé sur le registre de tas déjà prévu dans le modèle mémoire, sans libération, sans free-list, sans contrôle de collision pile/tas et sans levée de `Storage_Error`. Ce choix est suffisant pour le bootstrap visé, où les allocations attendues sont les secteurs de pages DIANA, typiquement 50 secteurs de 512 octets. Ce n’est donc pas encore une implémentation complète du modèle Ada 83 des types access, mais un support pragmatique du cas `new SECTOR` nécessaire au compilateur.

Côté déclarations de types, `CODE_ACCESS_DECL` a été ajouté. Un type access génère maintenant un namespace de type avec `use__info`, une taille `SIZ` fixée à 64 bits, et un pointeur `DESIG__u` vers le patron de type du désigné. Une erreur importante a été corrigée au passage : les nœuds DIANA `DN_ACCESS` ne possèdent pas l’attribut `CD_IMPL_SIZE`. Il ne faut donc jamais lire ni écrire `CD_IMPL_SIZE` sur un `DN_ACCESS`; la taille backend d’un access est une constante de l’expander, `ADDR_SIZE * STORAGE_UNIT`, soit 64 bits sur les cibles actuelles. Cette correction a aussi permis aux records contenant des champs access d’être considérés comme entièrement statiques du point de vue des offsets.

Le record `RPG_DATA` est maintenant correctement généré. Son champ `DATA : A_SECTOR` apparaît comme un champ scalaire de 8 octets, avec un `USEINFO` pointant vers `A_SECTOR.use__info`, et non comme un composite inline. Le layout obtenu est cohérent : `VP` occupe 2 octets, `AREA` 4 octets, `CHANGED` 1 octet, `RECUPERABLE` 1 octet, et `DATA` 8 octets, soit un total de 16 octets pour `RPG_DATA`. Le tableau `PAG` a donc un `COMP_SIZ` de 128 bits et alloue correctement `50 * 16 = 800` octets sur la co-pile pour ses données.

Côté expressions, l’expander sait maintenant compiler `null_access`, `subtype_allocator`, `qualified_allocator` dans un premier périmètre, et `DN_ALL`. Une première erreur dans le générateur d’allocator a été corrigée : le FINC initial produisait `LI SECTOR.SIZ`, ce qui empilait le symbole ou l’offset associé à `SECTOR.SIZ`, alors qu’il fallait charger le contenu de la variable de type info. Le code correct est maintenant `Ld SECTOR.SIZ`, suivi de `LI 8`, `DIV`, puis `HEAP_ALLOC`, afin d’allouer `SECTOR.SIZ / 8` octets. Pour `SECTOR`, la taille vaut 4096 bits, donc l’allocation demandée est bien de 512 octets.

L’affectation `PAG(CUR_RP).DATA := new SECTOR;` est désormais générée correctement. L’expander calcule d’abord l’adresse de `PAG(CUR_RP)`, ajoute l’offset du champ `DATA`, produit l’adresse de ce champ avec `LVA`, charge la taille du désigné `SECTOR.SIZ`, la convertit en octets, appelle `HEAP_ALLOC`, puis stocke le pointeur obtenu dans le champ `DATA` par `Sa`. Le champ access est donc traité comme un qword ordinaire stocké dans le record, ce qui est exactement la représentation voulue.

La lecture `PAG(CUR_RP).DATA.all(1).ABSS` est également correctement générée. Le code calcule l’adresse de `PAG(CUR_RP)`, charge le qword `DATA`, utilise cette valeur comme adresse de base du `SECTOR` désigné, indexe l’élément `(1)` avec les informations de bornes et de taille de composant de `SECTOR`, charge le mot compacté `TREE`, puis extrait le champ représenté `ABSS` avec `UBFX` sur la plage `9 .. 23`. Le chaînage complet est donc validé : tableau `PAG` → record `RPG_DATA` → champ access `DATA` → `.all` → tableau `SECTOR` → élément `TREE` représenté → champ `ABSS`.

Plusieurs chemins de l’expander ont été ajustés pour considérer `DN_ACCESS` comme une valeur scalaire de taille adresse : déclarations de champs de records, calculs d’offsets statiques, chargements et stores, affectations, et calcul d’adresse d’objet. En revanche, le périmètre reste volontairement minimal. Il ne traite pas encore `Unchecked_Deallocation`, les contrôles de null access, `Storage_Error`, les access-to-unconstrained-array, la libération mémoire, les finalisations éventuelles, ni tous les cas d’affectation composite via `.all`. Pour le besoin immédiat du bootstrap, ce support couvre cependant le motif essentiel : allocation d’un secteur par `new SECTOR`, stockage du pointeur dans un record, déréférencement par `.all`, indexation dans le tableau désigné, puis accès à un composant représenté.

Le résultat pratique est que `TEST_NEW.adb` génère maintenant un FINC cohérent pour les déclarations et les instructions concernées, et surtout que `IDL.PAGE_MAN.adb`, l’un des deux modules du frontend bloqués par l’allocation dynamique des pages DIANA, passe désormais dans l’expander. Ce jalon complète utilement le support récent des records représentés compacts et prépare la suite du bootstrap, notamment la validation de `IDL.IDL_MAN.adb` et les éventuels cas plus larges d’usage des types access.

## Session 4 juillet 2026 — Passage complet des séries ACVC A2–A7, correction de trois bugs de fond (sous-types anonymes partagés, blocs `declare`, niveau des thunks génériques) et point de méthode

Cette session marque un jalon de couverture : après correction de trois défauts structurels, **toutes les séries ACVC A2, A3, A5, A6 et A7 passent**, ainsi que les anciens `ENUM_TEST` et `DIRECT_IO_TEST`, et l’ensemble des modules du compilateur continue de passer l’expander. Il reste, dans la série A8, quatre tests en erreur sur vingt. Les trois bugs traités ci-dessous ont ceci de commun qu’ils n’étaient pas des cas particuliers isolés mais des **erreurs de modèle** : chacun violait un invariant que l’expander était censé maintenir, et chacun ne se révélait que dans une configuration lexicale précise (typiquement la présence d’un bloc `declare … begin … end` interne), ce qui explique qu’ils soient restés masqués tant que les déclarations testées vivaient au niveau de la procédure englobante.

### 1. Sous-type tableau anonyme partagé entre deux objets — `CD_COMPILED` surchargé (A21001A)

Le test `A21001A` compilait mais produisait une **erreur de segmentation** à l’exécution. Le fault tombait sur un `LId … D_info, _STRING.LST_1` du code de concaténation : ce `LId` déréférence le contenu du champ `__info` d’une des chaînes (`C2`), et ce pointeur `use__info` était invalide. La cause immédiate était que `C2`, déclaré `STRING(1..6)` exactement comme `C1`, avait été alloué avec le descripteur du type **non contraint** `STANDARD._STRING` au lieu d’un sous-type contraint local, contrairement à `C1` (`_C1__type`) et `C3` (`_C3__type`, contrainte `1..12` distincte).

La cause racine a été établie par le dump DIANA (`____TREE.TXT`), et non par supposition : `C1` et `C2`, ayant une contrainte identique `STRING(1..6)`, **partagent physiquement le même nœud** `DN_CONSTRAINED_ARRAY` (`SM_OBJ_TYPE` = `[P233,L64]` pour les deux ; `C3` a son propre nœud `[P233,L110]`). Or, dans `EXPANDER.DECLARATIONS`, la décision d’émettre un descripteur local repose sur le drapeau `CD_COMPILED` porté par le `TYPE_SPEC` (`if DB(CD_COMPILED, TYPE_SPEC) = FALSE then …`), et `PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC` positionne `CD_COMPILED := TRUE` sur ce nœud en fin de traitement. Le déroulé fautif était donc : `C1` trouve le drapeau à faux, génère `_C1__type`, et marque le nœud partagé comme compilé ; `C2`, voyant le même nœud désormais à `TRUE`, saute la génération et retombe sur le chemin `REGIONS_PATH(TYPE_NAME) & TYPE_NAME_STR`, où `TYPE_NAME := D(XD_SOURCE_NAME, TYPE_SPEC)` remonte au type de base `STRING`, d’où `STANDARD._STRING`. Le drapeau `CD_COMPILED`, correct pour un type **nommé** (émis une fois, réutilisé par son nom), est faux pour un sous-type **anonyme d’objet partagé**, car le chemin de réutilisation ne retrouve pas le label local déjà émis.

La correction retenue (option « un descripteur par objet ») matérialise un type-info local dès qu’il existe une contrainte anonyme d’objet, indépendamment de `CD_COMPILED`, en alignant ainsi `A21001A` sur le comportement déjà correct de `A22002A` (qui, lui, ne partageait pas le nœud et générait bien `_C2__type`). Le surcoût — un descripteur `_C2__type` identique à `_C1__type` — est négligeable et sûr. Point de vigilance conservé : ne pas supprimer le marquage `CD_COMPILED` en aval, qui sert légitimement de garde d’unicité pour les types nommés et les composants (lecture en plusieurs points de `types_decls`).

Cette investigation a aussi confirmé un point de vocabulaire utile pour la lecture du FINC : dans `LId …, _STRING.LST_1`, le symbole `_STRING.LST_1` est l’**offset statique** du champ `LST_1` dans le descripteur (une petite constante, ici 12), et non une borne ; ce qui change avec le correctif n’est pas cet offset mais la **base** (le pointeur `use__info` chargé), désormais celui d’un descripteur contraint valide.

### 2. Blocs `declare` imbriqués — labels `post` / `elab` / `loc_siz` partagés par les macros `PRO`/`endPRO`

En marge de A21001A, un second défaut structurel a été identifié dans le traitement des blocs `declare` internes. `CODE_BLOCK` réutilise la mécanique de sous-programme : il émet `namespace BLOCK__n`, un `ELB` (donc un `LINK` de niveau), puis en clôture un `UNLINK` suivi de **`endPRO`**. Or `endPRO` définit le label `post:` et la variable `loc_siz`, tous deux **globaux au namespace fasmg courant**, et fait `end namespace`. Émettre `endPRO` pour un bloc imbriqué dans une procédure produit donc **deux définitions de `post:`** (celle du bloc, celle de la procédure), ce qui casse la résolution du `BRA post` que la macro `PRO` de la procédure englobante émet pour contourner l’élaboration. Selon la résolution, le saut atterrit sur le `post:` du bloc — au milieu du corps, juste avant le `CALL RESULT` — et le programme exécute la sortie de frame sur une pile jamais initialisée, d’où le fault.

La leçon générale, déjà visible dans le code des thunks (qui, eux, nomment explicitement leurs cibles `post_LD_NP_…`, `post_ST_NP_…` et ne posent aucun problème), est que **les labels `post`/`elab` nus des macros `PRO`/`ELB`/`endPRO` sont une source d’ambiguïté dès qu’il y a imbrication**. Le remède de fond consiste à rendre ces labels uniques par routine, soit en les qualifiant par le nom de la routine dans les macros, soit en faisant émettre par l’expander des labels déjà uniques (une macro dédiée de fin de bloc, distincte de `endPRO` et ne définissant pas `post:`). Ce défaut est de même famille que le bug de niveau des thunks génériques ci-dessous : dans les deux cas, une entité lexicalement locale à un niveau donné était traitée avec un symbole ou un niveau partagé.

### 3. Instanciation de sous-programme générique dans un bloc `declare` — niveau des thunks du type formel (A35801B, A35502R)

Les deux seuls segfaults de la série A3 (`A35801B`, attributs `DIGITS/MANTISSA/…` sur un sous-type formel `digits <>` ; `A35502R`, attributs `WIDTH/POS/VAL/…` sur un type formel discret `(<>)`) avaient une **cause racine commune**, isolée grâce au harnais `db 0xCC` / `show` inséré dans le FINC. Le fault tombait sur le premier `Sa 3, NP_…__outadr_ofs` de la mise en place de la table de thunks du type formel, c’est-à-dire **entre la fin du corps de `P` (`UNLINK 3` / `RTD` déjà exécutés) et le `PRO NP`**. À cet instant, le flux exécute l’**élaboration du bloc `declare`, au niveau 2** ; or `Sa 3` indexe le display à `FP(3)`, niveau qui vient précisément d’être refermé. L’écriture se fait donc dans un frame mort — fault immédiat, et non simple incohérence latente.

Le mécanisme sous-jacent est le passage de type formel par **table de thunks** (`__u_ofs`, `__ld_ofs`, `__st_ofs`, `__inadr_ofs`, `__outadr_ofs`) plus une case `GFP_disp` (Generic Frame Pointer) : l’instance prépare cette table à l’élaboration du bloc, avant tout appel, et le corps générique y accède par `La lvl, -GFP_ofs` puis `[GFP − T__*_ofs]` (le layout relatif — `u` à `GFP−8`, `ld` à `−16`, etc. — a été vérifié correct). Le contrat physique exige que la table et `GFP_disp` vivent dans le **frame du bloc où l’instance est déclarée** (niveau 2), et l’unique store déjà correct, `LVA CUR_LEVEL − 1, GFP_disp`, le confirmait. Le défaut : `CODE_GENERIC_ACTUALS` définit `LVL_STR := LEVEL_NUM'IMAGE(CODI.CUR_LEVEL)`, mais `CODE_SUBPROG_ENTRY_DECL` exécute `INC_LEVEL` **avant** d’appeler `CODE_GENERIC_ACTUALS`. Au moment de l’émission, `CUR_LEVEL` désigne déjà le corps de l’instance (3), et toute la table est écrite en `Sa 3` alors qu’elle est relue en `LVA 2`. C’est une confusion classique en génération à display entre le **niveau lexical d’une entité** (le frame où elle vit) et le **niveau courant du générateur** (le `CUR_LEVEL` mouvant du compilateur).

Un point important a évité un correctif trop naïf : `CODE_GENERIC_ACTUALS` possède **deux sites d’appel** de contextes de niveau différents. Le site d’instanciation de **sous-programme** générique (dans `CODE_SUBPROG_ENTRY_DECL`) est appelé après `INC_LEVEL` ; le site d’instanciation de **package** générique (dans `CODE_PACKAGE_DECL`) est appelé **sans** `INC_LEVEL` préalable. Fixer `LVL_STR` à `CUR_LEVEL − 1` en dur aurait décalé le chemin package, que rien ne montre défaillant. La correction retenue passe donc un **niveau cible explicite** en paramètre : `TARGET_LEVEL := CODI.CUR_LEVEL − 1` pour le site sous-programme (aligné sur le `LVA CUR_LEVEL − 1, GFP_disp` existant), et le comportement historique `CUR_LEVEL` pour le site package (valeur par défaut, donc aucun changement de ce chemin). Après correction, la table passe en `Sa 2`, cohérente avec sa relecture, et les deux tests s’exécutent correctement. Le correctif répare de surcroît un bug **latent** au niveau bibliothèque (instanciation sans bloc, où l’ancien code écrivait `Sa 2` pour une relecture `LVA 1`) : il ne pouvait que le rendre cohérent, jamais le casser.

Ce troisième cas rejoint et précise le piège n° 26 (« level du wrapper générique : `CUR_LEVEL − 1` ») déjà consigné : le bon niveau n’est pas seulement affaire de relecture depuis le corps, il conditionne aussi l’**écriture** de la table, et l’émettre au mauvais niveau depuis l’élaboration d’un bloc conduit à un accès à un frame déjà dépilé.

### 4. Point de méthode — de l’ordonnancement par les tests vers un pilotage par les nœuds DIANA

La difficulté croissante ressentie sur la série A8 (quatre échecs restants, portant sur le renommage, `use`, la portée et la visibilité) a motivé une réflexion sur la politique de développement de l’expander. Le constat partagé est que l’ACVC est un **oracle de conformité et de régression**, non une **méthode de conception** : l’ordre lexicographique des numéros de test (A8 avant A9) n’encode aucune dépendance sémantique réelle, et se laisser ordonnancer par lui expose au risque, déjà pressenti, de corriger point par point des fonctionnalités dont les fondations ne sont pas encore posées. La table « fondations à compléter » (§4) le confirme : ce qui reste — unconstrained arrays, records à discriminants, types access complets, gestionnaires d’exceptions, dérivation, renames, tâches — relève de piliers sémantiques, non de rustines.

La hiérarchie de pilotage retenue pour la suite est la suivante. Le **LRM Ada 83** tient lieu de spécification et, par sa structure (types → objets → expressions → sous-programmes → packages → génériques → tâches), d’ordre de dépendances légitime pour choisir le prochain pilier. Le **réseau DIANA** (fichiers `diana_NODES.txt` / `diana_CLASS_.txt`) tient lieu de contrat d’interface énumérable : chaque `DN_*` non traité par un `case … when` de l’expander est une dette explicite. L’**ACVC** reste le filet de régression, exécuté en totalité à chaque changement, mais ses échecs servent désormais à *informer la priorité des piliers* plutôt qu’à *constituer la liste de tâches*. Deux disciplines complètent cette orientation : pour chaque nouveau pilier, rédiger en amont une brève note de **modèle d’exécution** (représentation mémoire, invariants de pile/display, conventions d’appel) afin de décider sciemment entre extension et refonte, en ne refondant que ce qu’un pilier manquant force à refondre ; et pour les échecs ACVC restants (dont les quatre de A8), pratiquer un **tri systématique** entre « défaut local d’un pilier existant » (à corriger immédiatement, comme les trois bugs ci-dessus) et « manifestation d’un pilier absent » (à consigner, sans bricolage ponctuel). L’hypothèse de travail est que les quatre échecs A8 se ramènent, comme A21001A et les deux tests génériques, à une ou deux causes-mères communes plutôt qu’à quatre bugs indépendants.


# Session du 4 juillet 2026 (suite) — Pilier LRM 3.6, campagne ARRAY_TEST

## Résultat global

ARRAY_TEST1 v2 : vert intégral (à re-passer en clôture, cf. §5).
ARRAY_TEST2 v2 : déroulé complet sans crash ; toutes sections conformes SAUF la
dernière ligne de D9 (`VEC3'RANGE`, cf. §3). Le pilier 3.6 a désormais ses
fondations : affectation complète, égalité, caténation toutes formes, tranches
et intervalles nuls, retour de tranche, agrégats qualifiés.

## 1. Correctifs appliqués (dans l'ordre de la session)

| # | Quoi | Où | Nature |
|---|---|---|---|
| A | 'LENGTH(N) lit la dimension (AS_EXP) | CODE_LENGTH, 2 chemins | défaut local |
| B | Affectation complète tableau : @DST + LEN([__u].SIZ/8) + @SRC + BLKMOV ; sources littéral (STR+LCA+La), tranche (DROP), doublet (La) | CODE_ASSIGN, branche tableau | branche inachevée terminée |
| — | Macro CLAMP0 (max(0,·), 11 octets, dérivée d'ABS) + 14 sites (le 14e : CODE_SLICE dest., ordre INC/SUB inversé) | finc + 4 fichiers | D7 clos |
| — | Macro BLKCMP (miroir BLKMOV, ZF armé par xor pour LEN=0) | finc | D1 |
| — | CODE_COMPOSITE_OPERATOR : "="/"/=" réels (longueurs puis BLKCMP), stubs équilibrés typés (scalaire LI 0 pour relationnels ; opérande gauche pour AND/OR/XOR/NOT composites) | expressions, avant CODE_FUNCTION_CALL | D1 clos, D2/D3 stubés |
| — | Hissage CODE_ARRAY_OPERAND / CODE_ARRAY_AGGREGATE_OPERAND avec paramètre CONTEXT_TYPE (COMP_BITS/BYTES recalculés localement ; « 8 » câblés de la branche tranche remplacés) | expressions | refactor prévu note §4.5 |
| — | Câblage scalaire AND/OR/XOR → macros ET/OU/OUX préexistantes | chaîne d'opérateurs | bug latent indépendant |
| — | COMP_SIZE_BITS ×2 : arrondi au STORAGE_UNIT (CD_IMPL_SIZE(BOOLEAN)=1 bit → LEN=0 et stride=0 par division entière) | expressions + types_decls | cause racine des « six VRAI » |
| — | Opérande composant de "&" : tableau temporaire d'1 élément co-pile (SI+OPER_SIZ_CHAR) | CODE_ARRAY_OPERAND | D4 clos |
| — | Retour de tranche : aiguillage DN_SLICE → CODE_SLICE(IS_DESTINATION=>FALSE) | CODE_RETURN, branche tableau | D8 clos |
| — | Agrégat qualifié de sous-type CONTRAINT : doublet anonyme, __u → use__info du type, data = CO_VAR(SIZ/8), TYPE_LVL = CD_LEVEL du TYPE_SPEC | CODE_QUALIFIED | D9 débloqué |

## 2. Verdicts ARRAY_TEST2 (état de clôture)

- **D7** intervalles nuls : validé (y compris descripteur dynamique et concat à opérande nul).
- **D1** égalité/inégalité : validé (littéraux, longueurs inégales → FAUX sans comparaison).
- **D2** lexicographique : stub honnête (6 FAUX). Lot suivant.
- **D3** logiques booléens : stub « opérande gauche » (valeurs traçables). Lot suivant.
- **D4** caténation formes composant : **clos**, cascades comprises.
- **D5** conversion : **acquis par transparence** (CODE_CONVERSION laisse passer le
  @doublet ; bornes/longueur viennent du descripteur destination). Restriction
  consignée : les bornes du RÉSULTAT de conversion sont celles de la source —
  faux si consommées directement (paramètre non contraint, attributs).
- **D8** retour de tranche : **clos** (bornes réelles conservées, data chez l'appelant).
- **D9** : agrégats 2D imbriqués ✓ (acquis, D6 partiellement invalidé comme dette ?
  à réexaminer), choix multiples ✓, qualifié nommé+others ✓ (RM83 4.3.2(6) : la
  forme non qualifiée est illégale en affectation — le frontend avait raison).
  **VEC3'RANGE : échec silencieux** (boucle à zéro itération) — préfixe marque de
  sous-type non traité dans CODE_RANGE_ATTRIBUTE_BOUND. Correctif esquissé :
  branche type DN_CONSTRAINED_ARRAY → Ld TYPE_LVL, <path>_T._FST_1 / _LST_1
  (idiome du patch qualifié). À faire ou consigner.

(Pièges n° 49–58 extraits vers PIEGES.md ; dettes reprises dans ETAT_PILIERS.md.)

## 4. Restrictions et dettes consignées (hors lots D2/D3)

- 'RANGE préfixe marque de sous-type tableau (D9, correctif esquissé §2).
- D10 : attributs à préfixe non nommé (tranche, indexé, appel) — CHN_PREFIX lu à
  l'entrée de CODE_ATTRIBUTE. Même famille : expressions enveloppées (return (S(2..3))).
- D6 : bloc info anonyme câblé 1-dim (concat, agrégat dynamique, résultat de
  fonction) — à réexaminer à la lumière du succès des agrégats 2D.
- D5 complet : re-étiquetage des bornes au sous-type cible (doublet anonyme sans copie).
- CODE_QUALIFIED : records qualifiés = même vice (CODE_AGGREGATE sans destination),
  pour le pilier 3.7 ; branche non contrainte : suppose UNE association nommée à UN
  choice range (STRING'('a','b','c') positionnel déraillerait).
- CODE_USED_NAME_ID : retombée silencieuse — aligner sur le style bruyant de
  CODE_USED_OBJECT_ID (others → message + PROGRAM_ERROR).
- 'IMAGE/'VALUE d'énuméré hors générique → pilier 3.5.5.

## 5. Prochaine séquence

1. (Option) correctif VEC3'RANGE, re-passer ARRAY_TEST2 → attendu final `1 3`.
2. **Filet complet** : ARRAY_TEST1 v2 (beaucoup de code partagé a bougé :
   COMP_SIZE_BITS, CODE_SLICE, CODE_RETURN, chaîne d'opérateurs) + séries ACVC
   A2–A8 + tests maison + auto-compilation. Tag git de clôture de campagne.
3. Lot **D2** : macro LEXCMP paramétrée taille × signe (repe cmpsb inutilisable :
   little-endian multi-octets et signés ; énumérés/CHARACTER non signés, INTEGER
   signé), règle du préfixe, puis LI 0 + CLT/CLE/CGT/CGE côté expander.
4. Lot **D3** : BLKAND/BLKOU/BLKOUX + NOT composite (copie + OUX octet), mêmes
   prologue/épilogue que la concat.
5. Mise à jour DIANA_COUVERTURE_TRIAGE (D4/D8 sortent de la dette) et de la table
   « fondations » de la synthèse.


## Session 5 juillet 2026 — Lots D2 et D3, filet complet, CLÔTURE du pilier 3.6

**Lot D2 (LRM 4.5.2)** : macro `LEXCMP siz,sgn` — itération par composant
(`repe cmpsb` inutilisable : little-endian multi-octets, signes) avec
NORMALISATION 64 bits au chargement (`movsx` si signé, `movzx` sinon), après
quoi une unique comparaison signée 64 bits est correcte dans les deux cas ;
le paramètre de signe ne choisit que l'instruction de chargement. Résultat
tri-état −1/0/+1 ; règle du préfixe = signe des longueurs restantes à
l'épuisement (couvre les tableaux nuls). Côté expander : `LI 0` +
`CLT/CLE/CGT/CGE` — mapping direct des quatre opérateurs, sans macro dédiée.
Signe déterminé par `COMP_TYPE.TY = DN_INTEGER` (énumérés/CHARACTER/BOOLEAN
non signés). Incident instructif : le stub laissé collé sous le code réel a
masqué un LEXCMP correct (sept FAUX) → **piège n° 59**. Témoin signé ajouté
à ARRAY_TEST2 : `(-5,2,3) < (1,2,3)` (protège movsx vs movzx, que les cas
positifs ne distinguent pas).

**Lot D3 (LRM 4.5.1)** : composants BOOLEAN un octet 0/1 (piège n° 56) →
opérations octet à octet exactes. Macros `BLKAND/BLKOU/BLKOUX` (usine interne
`BLK_OP_OCTET opc`, convention miroir BLKMOV : @DST, LEN, @SRC) et `BLKNOT`
(xor de chaque octet avec 1 — NOT booléen du piège n° 5, pas 0xFF). Épilogue
plus simple que la concat : les bornes du résultat étant celles de l'opérande
GAUCHE (4.5.1), le `__u` du doublet résultat RÉUTILISE le pointeur info de G ;
seule la data est allouée (CO_VAR de LEN_G, copie G→R par BLKMOV, application
sur place). Le `not` composite est intercepté AVANT `CODE_EXP` dans
CODE_DN_BLTN_OPERATOR_ID et routé vers CODE_COMPOSITE_OPERATOR (PRM_2 := PRM_1)
pour bénéficier de la normalisation CODE_ARRAY_OPERAND ; l'ancien stub à
<<UNARY>> supprimé (piège n° 59, corollaire). Restriction consignée : pas de
contrôle d'égalité des longueurs (pilier 11).

**Filet** : modules du compilateur verts, séries A2–A7 vertes, A8 : 17 verts
(4 échecs consignés inchangés), ARRAY_TEST1 v2 et ARRAY_TEST2 v2 intégralement
conformes (sorties dans ORACLES_TESTS.md), auto-compilation verte — noter que
les comparaisons STRING internes du compilateur passaient jusqu'ici par le
stub LI 0 et empruntent désormais LEXCMP.

**Clôture du pilier 3.6** (formes contraintes, opérateurs complets) prononcée.
Reliquat consigné en fondation : déclaration des types non contraints eux-mêmes
(CODE_UNCONSTRAINED_ARRAY_DECL, STRING général) — audit par témoin + dump à
l'ouverture. Documentation réorganisée en cinq fichiers (ETAT_PILIERS, PIEGES,
CONVENTIONS_ARCHITECTURE, ORACLES_TESTS, JOURNAL_SESSIONS) + triage mis à jour :
la synthèse monolithique est retirée du projet.

Session pilier 3.7, lot R-A (RECORD_TEST1) : CLOS, 7/7 sections conformes, filet vert (unités compilateur, ACVC, TEXT/DIRECT/SEQUENTIAL_IO, enum_test, direct_io_test). Dix correctifs C1–C10 sur quatre fichiers. Chaîne causale remarquable : le refus bruyant de C5 (égalité) a révélé C9 (idl.adb, bootstrap) ; l’else bruyant de C7 (CODE_RETURN) a révélé C8 (return “” de FORM) ; l’audit FINC post-C7 a innocenté CODE_RETURN et incriminé l’appelant (C10). Trois trous SILENCIEUX préexistants dans le même if de CODE_RETURN (DN_CONSTRAINED_RECORD, DN_ACCESS, DN_STRING_LITERAL) : FORM était compilé cassé depuis toujours, invisible car jamais appelé.

Complément lot R-A : correctif C11 après régression ACVC série A7 (A71004A,
A74006A, A74205E). Un tableau à composant record dont la vue complète (type
privé) n'est pas encore compilée levait le refus bruyant C4b. Ce n'était pas
une erreur mais un « pas connaissable ICI » : COMP_SIZE_BITS rend 0, le site
d'émission bascule sur le symbole <rec>.size*8 (fasm multi-passes) et force
le chemin dynamique. Leçon : distinguer « pas géré » (refus bruyant) de « pas
connaissable à ce point du flux » (report symbolique à l'assembleur) — même
partage expander/fasm que STATOFS et size=$.

Session pilier 3.7, lot R-B (RECORD_TEST2) : 7/7 sections conformes AU PREMIER
PASSAGE. Trois correctifs proactifs C12–C14 appliqués à l'ouverture sur les
dettes documentées en clôture R-A (C12 agrégat qualifié de record ; C13
'CONSTRAINED par objet) plus un trou silencieux du pré-audit (C14, déréférence-
ment doublet→data incohérent entre branches d'affectation). Les sections
E1/E4/E5/E6/E7 ont passé sur les seuls acquis du lot R-A — validation de la
stratégie « câbler R-B pendant R-A » (défauts dans C1, retours dans C7/C10,
égalité dans C9).

Régression enum_test (découverte par le passage au témoin AUTO-JUGEANT) :
le NOT scalaire (LI 1 / OUX) avait été commenté au lot D3 quand le NOT
composite est parti vers COMPOSITE_OPERATORS, et la ré-émission scalaire
n'avait jamais réintégré la copie projet. Cause aggravante : mes livraisons de
FICHIERS COMPLETS écrasaient à chaque intégration la restauration locale de
l'utilisateur. La chaîne <<UNARY>> étant une suite de `if` sans else final
(même anti-motif que CODE_RETURN), `not <booléen>` n'émettait rien → booléen
inchangé sur la pile → logique inversée dans la recherche de littéral
d'ENUMERATION_IO (GET fichier = position 0 ; GET chaîne = premier littéral de
même longueur). Correctifs (utilisateur) : NOT scalaire restauré + cadrage à
gauche de ENUMERATION_IO.PUT(TO:STRING) ; garde anti-trou-silencieux ajoutée
en fin de chaîne <<UNARY>> (opérateur unaire non reconnu → PROGRAM_ERROR, "+"
unaire admis). Conséquence de méthode : passage aux livraisons en INSTRUCTIONS
ligne par ligne (utilisateur dans la boucle) et aux témoins auto-jugeants.

Clôture pilier 3.7 prononcée (filet complet vert : unités compilateur, A2–A7,
RECORD_TEST1/2, ENUM_TEST 41/41, auto-compilation). Quatorze correctifs C1–C15
sur quatre fichiers, trois bugs dormants antérieurs débusqués par les refus
bruyants (égalité des TREE du bootstrap, return "" de FORM, NOT scalaire). Le
motif dominant — « la vue contrainte n'est pas le type de base » — a produit
six correctifs. Pilier suivant décidé : reliquat 3.6 unconstrained arrays,
puis exceptions.

## Session 7 juillet 2026 — Pilier 11 (exceptions) : ouverture ET clôture

**Note avant code** : fusion de la note de la session antérieure et du
rafraîchissement (v2) ; l'audit Q2 a INVERSÉ le verdict pressenti — R14
monotone est porteur (retour tableau par référence, piège n° 70) →
contexte en VARzone acté. Recadrage doctrinal du mainteneur : « codi =
machine à pile, pas le runtime » — le runtime vit en Ada dans _standrd.adb
(variables de service, record EXCEPTION_CONTEXT dont les STATOFS SONT la
spécification du layout, sentinelle EXC_CTX0, cinq prédéfinies par
CODE_EXCEPTION_DECL ordinaire) ; codi ne gagne que EXC_MACH (photographie
de l'état caché) et EXC_RAISE (déroulage, instance unique posée par le
wrapper, atteinte par BRA — 5 octets/site, les checks futurs compteront) ;
tout le protocole est de la LLIR émise par l'expander.

**E-A1** raise→déroulage→sentinelle jugé avant tout handler (exc_test0
mourant proprement). **E-A2** handlers : push à begin: (11.4.2 gratuit),
pop-avant-dispatch (11.4.1), dispatch CEQ/BT auto-contenu, pops de sorties
anticipées par HANDLER_CTX_AT — et correction au passage du bug UNLINK
compte-vs-niveau de CODE_EXIT (piège n° 69). **E-A3/bis/ter** renames :
identité partagée par alias d'assemblage (LRM 8.5), résolution
EXCEPTION_ID_OF (DN_SELECTED sans SM_DEFN propre → raise/choix qualifiés
réparés du même coup) ; deux dumps ont contredit deux hypothèses —
sm_renames_exc porte l'ID, pas le NAME (piège n° 71). **E-A4** includes
des corps depuis XD_WITH_LIST (fermeture transitive prouvée au dump,
exclusion du spec propre par XD_PARENT, piège n° 73). **Fossile majeur**
réveillé par le pilier : les fichiers standard de TEXT_IO n'ont JAMAIS été
ouverts — gardes en décoration depuis l'origine (piège n° 74) ; corrigé à
l'élaboration du corps. **E-B** exc_test1 14/14. **E-C** raise nu : piège
sémantique 11.3 identifié AVANT codage (la globale clobberée par toute
exception traitée dans le handler) → sauvegarde par activation dans
PREV_CTX mort, pistage expander (niveau + suffixe LABEL_TYPE, fabrication
du nom par LABEL_STR unique — piège n° 76). Addendum critique externe
réconcilié : convergences confirmées, off-by-one 7+lvl→8+lvl repris dans
la note, design EXC_HANDLED écarté (discipline de restauration évitée),
deux sections de témoin extraites (élaboration 11.4.2, boucle anti-fuite).

**Clôture** : exc_test1 19/19, exc_test1u (sentinelle + $?=1), exc_ren0 ;
filet ACVC A2–A7, tous modules du compilateur ; un fossile résiduel
(END_ERROR DIRECT_IO) en cours côté mainteneur. Tag git.

## Session 8 juillet 2026 — TEXT_IO conforme LRM 14 ; fossile expandeur « actual out composé »

Refonte de conformité du package TEXT_IO, préparée par un arbitrage à deux
avis (Claude + second expert) dont la clé d'architecture est la séparation
stricte de deux niveaux. Le niveau RAW (GET_RAW, PUT_RAW caractère et
chaîne, hors spec, corps ASM inchangés relocalisés avant leurs appelants)
est un flux d'octets pur : pas de mise en page, pas d'exceptions, GET_RAW
arme AT_END_OF_FILE et rend NUL à EOF. Le niveau public conforme LRM est
construit au-dessus : GET saute les terminateurs LF/FF (CR ignoré comme
moitié muette du CR LF), tient LINE/COL/PAGE et lève END_ERROR ; PUT tient
COL et fait la coupure implicite à LINE_LENGTH bornée (14.3.6(4)). Règles
de circulation : les scanners tokenisants (INTEGER/FLOAT/FIXED/
ENUMERATION_IO) et les lecteurs de structure (SKIP_*, END_OF_*, GET_LINE)
restent intégralement sur GET_RAW (visibilité des terminateurs, droit au
unget) ; NEW_LINE/NEW_PAGE/SET_COL émettent leurs caractères physiques via
PUT_RAW (sinon double comptabilité de COL) ; aucun niveau n'appelle
l'autre à contre-sens. GET(STRING) est réécrit en boucle sur le GET
public — l'ancien chemin READ en bloc, qui contournait le look-ahead, a
disparu ; PUT(STRING) garde un chemin rapide en bloc quand la ligne n'est
pas bornée.

Contenu du lot, dans l'ordre du patch : champs de longueur passés de
POSITIVE_COUNT à COUNT := UNBOUNDED (le 0 hors sous-type était une bombe
pour le futur pilier checks) et défauts non bornés partout (LRM 14.3.3) ;
élaboration explicite complète des fichiers standard (ID, IS_DEFAULT_IO,
LOOK_AHEAD, HAS_LOOK_AHEAD, AT_END_OF_FILE — VARzone non zéroée) ; gardes
LRM 14.2.1 (CREATE/OPEN sur fichier déjà ouvert → STATUS_ERROR, CLOSE/
DELETE sur fichier fermé → STATUS_ERROR) ; échec d'OPEN → NAME_ERROR
(piège n° 45 désamorcé) et de CREATE → USE_ERROR ; END_ERROR à l'entrée de
SKIP_LINE/SKIP_PAGE/GET_LINE et après le saut de blancs des scanners
fichier ; DATA_ERROR armé partout (énumérés, image sans chiffre, chiffre
incompatible avec la base des based literals — variantes chaîne ET
fichier) ; LAYOUT_ERROR dans les quatre PUT(TO : STRING) à la place du
remplissage d'étoiles, et dans SET_COL/SET_LINE contre les longueurs
bornées ; SET_COL/SET_LINE sortie complets (espaces, NEW_LINE/NEW_PAGE
implicites en arrière) ; cadrage énuméré PUT(FILE) avec WIDTH corrigé en
blancs de QUEUE (RM 14.3.9(10), la déviation console consignée disparaît) ;
FF reconnu comme séparateur par les scanners numériques et comme
terminateur de ligne par END_OF_LINE (un FF seul porte ligne+page dans
notre encodage).

Le lot a réveillé un fossile de l'expandeur, vieux comme
CODE_PROCEDURE_CALL : un actual DN_INDEXED tombait dans le fallback
CODE_EXP (rvalue) quel que soit le mode du formel — pour un out/in out
scalaire (convention par référence), le Lb final remplaçait l'adresse
calculée du composant par sa valeur, que l'appelé utilisait comme adresse
de dépôt : écriture sauvage. Le seul appel de cette forme dans tout le
corpus était la branche console de l'ancien GET(STRING), jamais exercée ;
la boucle du GET(STRING) public en a fait le chemin unique. Chaîne de
diagnostic exemplaire à retenir : segfault TEXT14/U5 → sonde à marqueurs
séquentiels TEXT14P (une exécution localise : P14) → lecture du FINC
(séquence LIa/…/ADD/Lb avant le CALL) → correctif d'une branche dans
INVERSE_RECURSE_ON_PARAMETERS, calquée sur le test de mode existant de
DN_VARIABLE_ID (in → CODE_EXP ; out/in out → CODE_OBJECT_ADDRESS).
Le témoin OUTARG1 verrouille la classe entière : indexé (U1), sélectionné
— le jumeau du même fallback — (U2), et le motif exact du GET(STRING)
(boucle sur composant indexé d'un formel non contraint, U3). Pièges
n° 77-78.

L'extension U8 du témoin (utilisateur) a trouvé trois trous dans l'angle
mort du lot — les scanners fichier n'étaient nourris qu'en entrées
valides sans terminateur de page : DATA_ERROR absent des variantes
fichier, FF non séparateur, END_OF_LINE aveugle au FF. Les trois corrigés
le jour même (TEXT14 42/42).

Filet final : modules du compilateur, TEXT14, OUTARG1, IO_TEST, EXC_TEST*,
ENUM_TEST, A2–A8, auto-compilation — tout vert SAUF DIRECT_IO_TEST et
SEQ_IO_TEST qui tombent en END_ERROR : témoins datant de l'ancien contrat
(« GET rend NUL à EOF » / idiome END_OF_FILE + lecture caractère,
déviation mono-anticipation consignée au piège n° 79), les packages
eux-mêmes n'ont pas bougé. Remise d'aplomb dans une session dédiée.

Restrictions consignées de la session : SET_COL/SET_LINE en ENTRÉE
restent des affectations directes du compteur (placeholder commenté) ;
END_OF_FILE/END_OF_PAGE à un caractère d'anticipation ne voient pas à
travers les terminateurs (remède commun avec l'aliasing des copies
FILE_TYPE : futur chantier « descripteur partagé à tampon », non
planifié).

## Session 9 juillet 2026 — fossile n° 80 (slot résultat en corps générique) ; témoins DIRECT_IO/SEQUENTIAL_IO auto-jugeants

Tri du reliquat `EXCEPTION NON RATTRAPEE : END_ERROR` du filet du
7 juillet (DIRECT_IO_TEST/SEQ_IO_TEST) : défaut réel de bibliothèque,
pas idiome de témoin — le point de chute était le premier READ après
réouverture, sa garde `BYTES_READ < SIZE_BYTES` armée par le pilier 11.
Cause : les 4 wrappers syscall à 3 paramètres (READ_SYSTEM_CALL ×2,
WRITE_SYSTEM_CALL ×2) de chacun des deux paquetages stockaient le retour
du syscall par `SD -32` — le slot GFP_ofs — au lieu de `-40`, le vrai
result__ofs (-8(N+2), le PRM GFP_ofs s'intercalant en corps générique ;
piège n° 80). BYTES_READ recevait la valeur résiduelle du slot -40
jamais écrit → END_ERROR spurieux ; les données étaient pourtant
correctement lues depuis l'origine, et côté WRITE le clobber était
masqué (ERR_CODE inutilisé, frame aussitôt mort). Les wrappers à 1 et
2 paramètres étaient justes — la table de contrôle des SD par arité
(1→-24, 2→-32, 3→-40) a fait le diagnostic. Correctif appliqué à la
main par le mainteneur dans les deux corps (8 SD au total).

Refonte des deux témoins au format canonique du 5 juillet :
DIRECT_IO_TEST v2 (65 assertions — SIZE/INDEX/MODE/IS_OPEN assertés,
extension par WRITE positionné au-delà de la fin, élément tronqué,
MODE_ERROR ×3, STATUS_ERROR ×3, DELETE ressuscité jugé par échec de
re-OPEN) et SEQ_IO_TEST v2 (50 assertions — RESET avec changement de
mode en réécriture complète inversée, indépendante de la sémantique de
troncature non arbitrée ; jumeau de l'élément tronqué). Verts au premier
passage. Les §8.3/§6.2 (élément tronqué : fichier de 5 octets ouvert par
l'instance POINT, lecture partielle non nulle) sont les verrous exacts
de la branche du fossile.

Au passage, tri d'un faux piège : le « DESACCORD DE TYPE » du frontend
sur `MODE(F) = IN_FILE` hors clause use est CONFORME (LRM 8.4(5),
l'égalité de FILE_MODE est déclarée dans l'instance ; c'est la plaie qui
a motivé `use type` en Ada 95) — idiome `declare use` consigné en
convention. Signal utile pour le tri A8 à venir : le frontend applique
strictement les règles de visibilité.

Dette 14.2.1 des deux paquetages consignée (gardes CREATE/OPEN déjà
ouvert, échec d'OPEN → NAME_ERROR, CLOSE/DELETE fermé → STATUS_ERROR,
sur le modèle du lot TEXT_IO du 8 juillet) ; les témoins acceptent déjà
le régime futur (handlers NAME_ERROR d'avance en S9/S7).

**Clôture** : DIRECT_IO_TEST v2 65/65, SEQ_IO_TEST v2 50/50 ; filet
complet + tag git.

## Session 9 juillet 2026 (2) — série ACVC a8 : quatre erreurs, deux segfaults, refonte BLOC_DEF

Tri des quatre échecs de la série a8 (A83009A/B, A85013B, A87B59A), puis
deux segfaults repérés après coup dans le flux (A83C01G, A87B59A), puis
le problème fasmg de fond commun aux A83009x.

**A83009B** : PROGRAM_ERROR idl_man sur générique SANS formels
(`GENERIC PROCEDURE P;` légal) — POP inconditionnel en tête de
CODE_GENERIC_FRAME_OFFSETS, la garde IS_EMPTY ne protégeait que la
récursion (piège n° 81). Le bloc `virtual at 8` n'est plus émis si vide.

**A85013B** : appel à travers une chaîne de renamings
(PROC3 renames PROC2 renames PROC1). Un renaming n'a pas de corps ;
SUBPROGRAM_ORIGIN (expander-utils) suit SM_UNIT_DESC = DN_RENAMES_UNIT
maillon par maillon — le dump a confirmé AS_NAME.SM_DEFN lien à lien,
pas de raccourci sem, et l'arrêt sur SM_UNIT_DESC void. Nom, label ET
chemin de région doivent tous venir de l'origine — l'oubli du nom a
produit l'hybride PROC3_L7 en cours de route (piège n° 82). Les défauts
du profil du renaming étaient déjà justes (SM_NORMALIZED_PARAM_S).

**A87B59A structurel**, deux étages : (1) l'assemblage paresseux n'est
armé que par CALL — un actuel générique sous-programme jamais appelé
directement laissait son corps non assemblé (`LCA F1_L11.elab` sans
garde) ; macro LSPA ajoutée au codi, émission par ACTUAL_SUBPROGRAM avec
REGIONS_PATH (piège n° 83). (2) REGIONS_PATH à travers une région
générique : generic_id ne porte pas CD_LABEL au schéma, le namespace
physique est le PRO étiqueté du corps ; dump MINIG à l'appui
(XD_REGION des locaux = le GENERIC_ID ; label via XD_BODY →
AS_SOURCE_NAME — XD_BODY, pas SM_BODY, absent du dump). Correctif
systémique dans REGIONS_PATH + nom relatif pour les locaux du frame
courant au site BLKMOV (piège n° 84).

**A83C01G (segfault)** : composants de record homonymes de packages —
CODE_SELECTED ne poussait jamais la base d'une variable COMPOSITE
nommée à travers un préfixe package (PACK1.ARG1.champs) ; les
LVA ,offset s'additionnaient sur pile vide. Base poussée par
La lvl + REGIONS_PATH + _disp (piège n° 85, jumeaux non exercés
consignés).

**A87B59A (segfault)** : TRIAGE, pas correctif — trois familles
d'actuels génériques sans convention d'exécution : littéral
d'énumération comme fonction (bloc C/F : position stockée en F_disp,
corps partagé CALLI sur F__call_ofs jamais écrit), opérateur prédéfini
(bloc E/F : VAR sans store ; "&" STRING = le morceau dur), entrée de
tâche (bloc D : pilier tasking absent). Dette consignée, thunk littéral
identifié comme seule pièce détachable. Le bloc E ne survit que parce
que le corps partagé INLINE l'opérateur (ADD) — faux pour l'instance à
"+" utilisateur, dette corollaire.

**Refonte BLOC_DEF** (A83009A/B) : la split-macro struc/esc/postpone
avec END_BLOC_DEF « ! » était structurellement condamnée — le « ! »
est indispensable pendant la capture et fatal dans un `if defined`
faux, exigences irréconciliables (piège n° 86). Au passage, mea culpa
instructif : « aucun consommateur d'IMAGES » au grep symbolique — faux,
TEXT_IO.ENUMERATION_IO lit le doublet images par OFFSET (LIVa
__u+16), contrat d'adjacence construit par l'ordre LIFO des postpones
(piège n° 87). Nouveau schéma : données inline sautées par BRA (pattern
des thunks), noms fixes IMAGES.* dans le namespace du type,
END_BLOC_DEF siz,fst,lst pose le layout ENUM_USE_INFO étendu EN CLAIR
(SIZ@0, FST@+4, LST@+8, doublet@+16) ; plus de struc BYTES_BLOC, de
CST ni de postpone dans ce chemin. CODE_ENUMERATION_DECL adapté.
Première formulation locale/match fautive (« :skip » indéfini),
remplacée par les noms fixes — l'unicité vient du namespace.

**Clôture** : ENUM_TEST 41 OK + console (gardien du contrat),
série a8 verte sauf A87B59A (exécution, triage actuels génériques),
non-régression complète. Patchs : expander-structures,
expander-instructions, expander-expressions, expander-utils,
expander-declarations, types_decls, codi_x86_64.finc, _STANDRD.FINC
régénéré.

## Sessions 9–11 juillet 2026 — Pilier CHECKS RUNTIME : ouvert, CLOS

Méthode intégrale : note d'arbitrage AVANT code (v1 → v1.4), dump
E-0 (piège 71 : 3/3 — bornes fixed rationnelles non scalées,
placeholder DN_ENUMERATION même pour actuel entier), étapes-témoins
E-A..E-F, livraisons ancrées, règle de tri des fossiles appliquée en
vraie grandeur.

Construit : trampolines ce_raise_/ne_raise_, CODE_RANGE_CHECK
(élisions par nœuds), CHECKS_ENABLED (régime permanent ON), checks
gamme (7 sites), LEN composites (dette D3 soldée), index (4
variantes), division par zéro (Q7 : NUMERIC_ERROR, fidélité 83).

Campagne de fossiles (5, tous par témoins à VALEURS) :
n° 80 sous-type anonyme → base (garde d'élision ; dette 80-b
RECTIFIÉE — leçon de ré-audit) ; n° 81+bis+ter actuels constants
fantômes (scalaires, composites, privés — IDENT_* de l'ACVC inertes
depuis l'origine, ressuscités ; else bruyant : deux prises en 24 h) ;
n° 82 oscillation rel8/rel32 BT/BF sous alignements (tous sauts
rel32, le « 4 octets de NOP » historique expliqué) ; n° 83 pile
d'évaluation pré-LINK sur la VARzone (LINK 0 avant _STANDRD ;
BOOLEAN'LAST et 'IMAGE guéris) ; n° 84 adaptateurs INADR/OUTADR
jamais appelés côté lecture (génériques in-out réellement
fonctionnels pour la première fois).

État final : filet complet + ACVC A2–A8 verts checks ON ET OFF,
auto-compilation verte (FINC ; assemblage bootstrap rendu viable par
n° 81). Le pilier a coûté ~15 livraisons et payé cinq fossiles que
rien d'autre ne pouvait voir : « la sécurité Ada n'était pas une
lourdeur, c'était un révélateur ».

## Sessions 11–12 juillet 2026 — Segfault CALENDAR → pilier FIXED (3.5.9) : ouvert, CLOS

Entrée par un segfault de TEST_CALENDAR qui n'était pas CALENDAR :
deux fossiles d'expander débusqués par lecture de FINC. N° 91 : double
émission 'DIGITS (CODE_FLOAT_DIGITS résiduel après le bloc declare —
fuite d'un slot par attribut, bénigne en élaboration, fatale en corps).
N° 92 : sélecteur OUTADR sur locale de corps partagé (test
VC_ID.TY = DN_IN_ID copié d'un site paramètre, toujours faux sur un
VC — double déréférence, la valeur flottante lue comme adresse).
Correctif systémique : prédicat unique ST_VIA_CALLI (push d'adresse
destination ⇔ CALLI-ST), quatre sites alignés. Leçon de couverture :
FLOAT_TEST (avril) était le seul témoin relisant des locales de type
formel — absent du filet depuis avril, réintégré ; INTEGER_IO ne peut
pas jouer ce rôle (zéro occurrence au grep). TEST_CALENDAR converti :
les cas 1900/2100 devenaient des témoins d'exception (le check E-A
avait raison contre le test — YEAR_NUMBER 1901..2099 exclut les
séculaires par construction du LRM).

Pilier FIXED ensuite, méthode intégrale. **F-1** : deux dumps
FIX_DUMP0, Q1 fermée. SM_ACCURACY = delta déclaré / CD_IMPL_SMALL =
small implémenté, tous deux rationnels sur le TYPE_SPEC ; clause
'SMALL repliée par sem (nœud DN_LENGTH_ENUM_REP à ignorer) ; sous-type
fixed = nouveau DN_FIXED héritant ACCURACY/SMALL, bornes pliées
rationnelles non scalées (piège 71 confirmé partout). RECTIFICATION
DE F-0 : la « conversion implicite de l'entier » n'existe pas — sem
REJETTE la forme nue A*N (dette sem-2, RM 4.5.5(9-10)) ; l'idiome
imposé T(A*T(N)) fait que TOUT le multiplicatif entre par
DN_CONVERSION : F-B rétrogradé en élision interne de F-D. Trois
dettes sem consignées : sem-1 small défaut = delta/2 (lecture « juste
inférieure » à vérifier au LRM papier), sem-2 rejet FIX*INT nu,
sem-3 'AFT/'FORE pliés à 3 en dur. Butin de sonde : littéral fixed à
Ns≠1 silencieusement faux + bail corrompant de CODE_STATIC_FIXED_VALUE
(n° 94).

**F-2** : formule unique repr = Nv·Ds/(Dv·Ns) posée à trois sites
(littéral statique, littéral générique via _FIXED_USE_INFO,
CODE_STATIC_FIXED_VALUE — factorisation EMIT_FIXED_TYPE_INFO
type/sous-type) ; CODE_SUBTYPE_DECL DN_FIXED (le PAS FAIT de
DAY_DURATION) ; attributs pliés via CODE_FOLDED_ATTRIBUTE (le null
muet de 'DELTA supprimé — règle : un attribut émet exactement UNE
valeur ou ANOMALIE).

**F-3** : révision Q5 — ZÉRO macro codi : CVTIX est déjà le noyau
« ·N/D en 128 bits », MUL/DIV complètent. F-D : interception dans
CODE_CONVERSION (critère = celui de la garde F-A : opérandes DN_FIXED,
prédéfinie seulement), élision FIX·INT intégrée, fixed→fixed statique
par rationnels réduits (identité TEQ), zero-check ne_raise_ sur les
divisions. Q3 tranchée : troncature vers zéro (gardien : -2.5 en
small 3/4 → -2.25). Témoin FIX_TEST1 : 15/15 premier passage.

**F-4a** : NUM'FORE à l'instanciation — nœud de spec générique
PARTAGÉ entre instances, sem ne peut pas plier ; table
formel→actuel dans UTILS (CLEAR par instanciation — indispensable,
FLOAT_IO et FIXED_IO nomment tous deux leur formel NUM). Deux ratés
de clé instructifs : SM_DEFN ≠ AS_SOURCE_NAME, puis DN_SYMBOL_REP ≠
DN_TXTREP pour la même graphie (n° 93) — clés-chaînes finales.
FIXED_AFT/FIXED_FORE calculés VRAIS de l'actuel (divergence sem-3
documentée : attribut d'instanciation juste, attribut direct = 3).
FLOAT_FIXED_IO_TEST : 11 sections vertes, FIXED_IO(DURATION) complet
(PUT cadré, GET avec exposants). A83041C a révélé le troisième
consommateur : 'DELTA en contexte FLOTTANT (idiome CODE_SMALL
réutilisé : rationnel → LIF).

**Clôture** : filet complet + ACVC (A83041C compris) + FIX_TEST1 +
FLOAT_TEST + FLOAT_FIXED_IO_TEST + TEST_CALENDAR + auto-compilation,
tout vert. Patchs : expander-expressions, expander-instructions,
expander-declarations, expander-utils, expander.adb, types_decls ;
TEXT_IO.FINC et prédéfinis régénérés. Zéro modification codi, zéro
modification sem (trois dettes consignées à la place). Tag git
recommandé : pilier-fixed-clos.

## Sessions 14–17 juillet 2026 — Bootstrap compilateur
*D10 partiellement soldée (volet appel, FIRST/LAST/LENGTH, 1-dim), volets indexé/tranche et 'RANGE toujours ouverts.

## Session 18 juillet 2026 — Auto-assemblage ADA_COMP (fasmg oracle de cohérence)

Objectif : assembler ADA_COMP.fas complet (IDL + EXPANDER auto-compilé).
fasmg joue l'oracle de cohérence inter-unités : chaque symbole fantôme
est un mensonge entre le site déclarant et le site utilisant. Sept
défauts soldés en chaîne, tous par lecture du trace fasmg (la pile de
macros nomme l'argument fautif : `FETCH_DWORD` ⇒ 3e opérande, garde
`LId` ⇒ 2e — discriminant décisif à deux reprises).

**(1) Records représentés dérivés/privés** (DEFINTERP_TYPE = new TREE,
privé, SET_UTIL). HAS_COMPONENT_REP répondait FALSE sur PT hérité :
la garde XD_REGION de FIND_COMP_REP_ELEM_FROM_COMPONENT n'acceptait
que DN_TYPE_ID, or un type privé a pour occurrence canonique un
DN_PRIVATE_TYPE_ID — REGIONS_PATH le savait (ligne ~729), pas
REPRESENTED_ITEMS. Élargissement des gardes (DN_PRIVATE_TYPE_ID,
DN_L_PRIVATE_TYPE_ID) + CODI.FULL_VIEW dans FIND_COMP_REP_ELEM et
CODE_STORE_REP_COMPONENT ; verrous posés dans COMPILE_RECORD_VAR
(3 sites) : record représenté sans comp_rep trouvé ⇒ LÈVE — le
namespace représenté n'exporte AUCUN offset, la branche offset y est
structurellement illégale.

**(2) Corps génériques : _disp/_ofs** (MESSAGE : in STRING de
REQ_TYPE_XXX). LOAD_MEM, branche « formel objet de type non formel »,
émettait `-X_disp` (nom physique côté instance) au lieu de `-X_ofs`
(constante d'accès relative au GFP, bloc virtual de
CODE_GENERIC_FRAME_OFFSETS). Deux lignes (scalaire + composite) ; la
branche HAS_GENERIC_TYPE voisine était correcte (preuve par symétrie).

**(3) Piège n° 99 en rafale : sous-types tableaux anonymes.**
`_OBJ.FST_1` fabriqué au lieu de `_OBJ__type.FST_1` (namespace local
de COMPILE_ARRAY_VAR) : d'abord le 'RANGE de boucle
(CODE_RANGE_ATTRIBUTE_BOUND, branche CLASS_VC_NAME), puis 'FIRST/'LAST
en expression (CODE_ATTRIBUTE, branche variable tableau) — même
maladie, organes distincts. Balayage systématique vers TYPE_INFO_STR ;
le balayage a introduit ses régressions : la substitution mécanique
`'_' & PRINT_NAME( X )` → `TYPE_INFO_STR( X )` passait le SYMBOL_REP
(diagnostic D : « PAS D ATTRIBUT XD_SOURCE_NAME DANS DN_SYMBOL_REP » —
imprimé SANS lever, FINC corrompu en aval, n° 96 en sursis). Helper
durci et généralisé : accepte un SPEC (descente XD_SOURCE_NAME) ou un
NAME (retour direct — un nom écrit dans le source n'est jamais
anonyme), lève sinon. Forme B légitime recensée
(CODE_SCALAR_SUBTYPE_FIRST_LAST) : pour les bornes de sous-types
scalaires, le nom AU SITE fait foi, pas l'alias canonique du spec.

**(4) with d'un sous-programme de bibliothèque** (EXPANDER depuis
ADA_COMP) : CALL vers `EXPANDER_L1.elab` jamais défini. Trois trous :
CODE_WITH_CONTEXT branche DN_PROCEDURE_ID posait CD_LEVEL/CD_PARAM_SIZE
sans émettre l'include ; CODE_TRANS_WITH_INCLUDES filtrait sur
PACKAGE/GENERIC seulement ; tête de FINC des unités sous-programmes
sans la garde `X = 'X'` (convention n° 97, réservée jusqu'ici à
CODE_PACKAGE_DECL/CODE_GENERIC_DECL). Correctifs aux trois sites
(+ DN_FUNCTION_ID par symétrie) et régénération d'EXPANDER.FINC.
Dette consignée : CD_PARAM_SIZE := 0 fabriqué en aveugle pour les
sous-programmes withés — garde à poser si la liste de formels est non
vide.

**(5) CODE_RETURN et types universels** (TYPE_SIZE d'expander-utils,
unité compilée pour la première fois — le refus bruyant R6 a parlé).
`return ADDR_SIZE;` (nombre nommé) : DN_UNIVERSAL_INTEGER hors
dispatch. Correctif LRM : expression universelle ⇒ FULL_VIEW du
sous-type de RETOUR de la fonction (déjà calculé pour le check E-D3,
hissé) ; et caractère de store dérivé de CE type (EXP_TYPE_CHAR sur
un universel aurait répondu 'b' — Sb dans un slot relu en d, R6 bis
silencieux évité). DN_UNIVERSAL_REAL couvert par le même repli.

**(6) Renames d'objets : bug bilatéral** (tab renames ASCII.HT,
UTILS). Le modèle pointeur de CODE_RENAMES_OBJ_DECL (VAR X_disp,q +
adresse à l'élaboration — conforme LRM 8.5, constituants évalués une
fois) était trahi des deux côtés : usage `LIb 1, TAB_disp, 0` SANS
REGIONS_PATH (UTILS est un namespace FRÈRE de REPRESENTED_ITEMS — la
remontée fasmg ne trouve que les parents) ; et l'élaboration rangeait
la VALEUR (`LI 9` / `Sa`) : CODE_OBJECT_ADDRESS → CODE_SELECTED
(IS_SOURCE => FALSE) → PROCESS_DESIGNATOR, dont la branche
CONSTANT/NUMBER/ENUM pliait en LI sans consulter IS_SOURCE — seule
branche de la procédure à l'ignorer. Correctif : branche constante
sensible à IS_SOURCE (LVa + REGIONS_PATH + _disp — le stockage existe,
STANDARD.ASCII.HT_disp) ; NUMBER_ID et LITTÉRAL D'ÉNUM en contexte
adresse ⇒ LÈVE (pas des objets Ada, pas de stockage — le pliage muet
refabriquerait un pointeur-valant-9).

**(7) fasmg multi-passes** : la répétition de la liste d'includes est
le rejeu normal des displays à chaque passe, pas une ré-inclusion
(les gardes `~ definite` protègent AU SEIN d'une passe). Temps dominé
par EXPANDER.FINC (volume). Thermomètre de convergence : le compteur
`optim push_pop_rax_count` — décroissance puis répétition = proche ;
OSCILLATION = cycle décision↔adresses, remède : rendre l'optimisation
monotone entre passes (hystérésis). Limite de passes fasmg = message
explicite, pas de blocage muet.

**État de sortie** : fasmg ne signale plus d'erreur de symbole ;
assemblage en convergence au moment de la clôture. À consigner au
premier succès : le NOMBRE DE PASSES du résumé final (référence de
non-régression de convergence). Patchs : expander-utils,
expander-represented_items, expander-declarations, expander-expressions,
expander-instructions, expander-structures ; EXPANDER.FINC régénéré.

## 20 juillet 2026 Session « CREATE_IDL_TREE_FILE → PAR_PHASE » (chasse aux segfaults
## d'exécution d'ADA_COMP, ~10 bugs, pièges 107-113)

Fil : élaboration passée, diana.bin produit, puis remontée de
CREATE_IDL_TREE_FILE (INIT_SPEC, PAGE_MAN, MAKE) jusqu'à IDL_MAN
(HASH_SEARCH, DABS, INSERT) et l'entrée de PAR_PHASE (POP_ITEM).
Méthode rodée : adresse segfault → map → x/3i + registres → FINC →
générateur. Chaque valeur de registre a signé son bug (0xffff0000 =
pointeur mutilé par écrasement de stride ; déréférencement de 0 =
slot résultat scalaire ; PC entre PRO et VAR = co-pile pleine).

(1) INIT_SPEC : bornes énumérées absentes (n° 107) puis Lb signé sur
NODE_NAME au nœud 128 (n° 108) — diana.tbl est le premier code à
exercer les gros tableaux indexés énumérés.
(2) Co-pile : fuite structurelle, palliatif 64 Mio, vrai fix différé
et documenté (n° 109). NE PAS toucher UNLINK naïvement.
(3) RPG_DATA : divergence calcul Ada / layout STATOFS (n° 110) ;
diana.bin TLALOC ≠ gnat en taille = padding, bénin en circuit fermé.
(4) UNCHECKED_CONVERSION : trampoline non consommé + retour tableau
contraint non préparé (n° 111) — HASH_SEARCH cumule générique +
tableau dynamique + UC, excellent chien renifleur.
(5) La couture composite @doublet/@data, six occurrences en cascade
(TO_INT, DABS, INSERT, POP_ITEM…) → convention n° 112 + helper
CODE_COMPOSITE_DATA_ADDRESS + balayage grep des deux orthographes.
(6) Niveaux : return-depuis-bloc et renaming inter-niveaux (n° 113).

**État de sortie** : ADA_COMP dépasse HASH_SEARCH/INSERT et entre
dans PAR_PHASE (POP_ITEM corrigé) — la table parse.bin se déroule
sur un vrai source. Dettes ouvertes : voir bloc AUDITS. Patchs :
expander-declarations-types_decls, expander-utils, expander-
declarations, expander-expressions, expander-instructions,
codi_x86_64.finc (p_memsz).

## Session 25-27/07/2026 — deux segfaults, PAR_PHASE de null_prog franchie

Segfault 1 (0x446249, BLKMOV de l'agrégat d'ALLOC_PAGE) : rdi=-512 et
r12=-25600=-(50×512) signaient un tas partant de zéro. Cause : un octet
REX faux dans le prologue du wrapper — `db 0x49,8D,A0` assemblait
`lea rsp,[r8+64Mio]` au lieu de `lea r12,[rax+64Mio]`. R12 jamais
initialisé, et la pile de travail relogée par accident dans le BSS de la
co-pile (d'où r15=0x3BFFFFF, adresses impaires partout). Correctif : un
octet, 0x49→0x4C. → PIÈGE n° 114.

Segfault 2 (0x45173d, BLKMOV de DABS_L37, ~220 passages avant crash) :
longue remontée. Observations clés : slot VAL = &_TREE.SIZ (le CONTENU
d'un __u), [&_TREE.SIZ]=32, T fonctionnel dans le même appel, premier
passage du site réussi. Chaîne d'élimination : DABS/D/D_L17/DABS_L38
conformes (retours composites en doublet OK — la vague post-111 tient) ;
émission SELARG conforme ; LVa à niveau vide sain (BASE_IN_RAX -1 =
POP_RAX) ; USEINFO/STATOFS sans collision de symbole (USEINFO définit
`champ__u`) ; rétro-propagation loc_siz des PRO imbriqués INNOCENTÉE
(fausse piste, retirée). Cause réelle : CODE_TYPE_MEMBERSHIP = `null;`.
Les deux `X in LT_WITH_SEMANTICS` de PARSE_COMPILATION n'émettaient rien ;
le BF orphelin mangeait un quadword par lexème décalé ; à dérive k=1 le
paramètre 3 de D s'empilait pile sur SELARG_L317__u que le `Sa __u`
écrasait ensuite avec &_TREE.SIZ. Toute la géométrie observée découle de
ce seul trou. Correctif : corps miroir de CODE_RANGE_MEMBERSHIP avec
CODE_SCALAR_SUBTYPE_BOUND factorisé depuis CODE_RANGE_CHECK ; cas type de
base → `LI 1` ; non-scalaire → raise bruyant ; pas de garde
CHECKS_ENABLED. → PIÈGES n° 115, 116, 117.

Après correctifs : l'analyse syntaxique de null_prog.adb passe. Erreur
suivante dans une autre phase — chantier séparé.

Techniques retenues : lecture du fingerprint registres (empreinte REX) ;
watch $rbp conditionnel dégainé tard ; empreinte « debut if + BF nu ».
Dettes ouvertes : double évaluation de EXP dans les deux memberships
(style maison, bénin sans effet de bord) ; alignement/variantes des
représentés (n° 117) ; mmap non testé + 448 Mio perdus ; oracle
membership à écrire ; assert rbp-contre-base en tête de boucle en mode
debug à pérenniser.

## Session 28/07/2026 — campagne « expander bruyant » : recensement initial CLOS

Exécution du briefing du 27/07 (fin de session n° 115). Infrastructure :
procédure TROU (utils, spec CODI) — FINC + console + PROGRAM_ERROR,
mode RECENSEMENT (option W) qui compte sans lever, bilan par unité à la
fermeture. Essai validé sur 'TERMINATED commenté (oracle négatif).

Vague 1 (arbre de CODE_EXP, contexte expression) : else TROU() sur les
13 dispatchers muets + CODE_USED_OP + queue de CODE_USED_NAME_ID +
CODE_ATTRIBUTE complet (branches ET chaînes internes 'C/'L/'M/'P/'S) ;
CODE_POS ceinturé (mort présumé, aucun appelant) ; annotations
INTENTIONNEL ('BASE, exception-comme-nom, normalisation base, adresse
déjà en pile).

Le recensement du corpus a rendu quatre catégories, toutes soldées :
1. CODE_EXP(TREE_VOID) en masse → contrat attribut-fonction invisible
   (n° 119), appel vestigial supprimé, ceinture inversée. Diff FINC =
   oracle (aucune émission ne change).
2. RECURSE_SELECTED : DN_FUNCTION_CALL → F(...).COMP jamais émis
   (HASH_SEARCH, CEQ sur fond de pile — n° 120a). Branche modèle
   CODE_INDEXED, témoin TROU_SEL1.
3. CODE_ATTRIBUTE 'VALUE (29 sites expander-expressions + idl +
   types_decls, tous INTEGER/LONG_INTEGER sur PRINT_NUM) → primitive
   cachée STANDARD.INTEGER_VALUE (réciproque d'INTEGER_IMAGE, une
   seule 64 bits pour les deux types), CODE_VALUE avec lieu résultat
   passé sous l'argument par temporaire (zéro macro codi). Témoin
   TROU_VAL1 (aller-retour IMAGE/VALUE + CONSTRAINT_ERROR exercée).
4. RECURSE_SELECTED : DN_CONVERSION → TREE(X).COMP jamais émis
   (IS_NULLARY, SET_UTIL — n° 120b). Normalisation conversion-vue en
   tête du tri, garde ROOT_RECORD même-racine. Témoin TROU_CONV1.

Run final corpus + auto-compilation : ZÉRO trou. Quatre bugs latents
vivants payés au recensement (deux binaires auto-compilés étaient
faux : dédup des symboles, prédicats IS_*ARY) — re-déroulé depuis le
compilateur de référence.

Techniques retenues : le FINC du recensement comme traceback
(grep -B 12 '!! TROU') ; ceinture inversée (le cas constaté devient le
légitime documenté, l'imprévu devient le TROU) ; diff de FINC comme
oracle gratuit des suppressions de no-op ; garde appelant annotée pour
tout enfant optionnel.

Dettes ouvertes : carnet TROU dans ETAT_PILIERS (tasking, 'VALUE
énuméré, rep-clauses, déréf implicite, forme directe AS_EXP) ; vagues
2-5 du briefing à dérouler (frontières d'appel + TYPE_SIZE raise
commenté ; instructions ; déclarations/structures ; promotion des ~30
demi-bruyants « pas fait » vus dans les FINC). Patchs : expander-utils,
expander-expressions, expander.adb (spec UTILS), _standrd.adb.

## Session du 28 juillet 2026 (suite) — vagues 2-5 + reclassements : campagne close

Vague 2 (frontières n° 112 + layout) : CODE_ADRESSE ceinturé mort
présumé ; TYPE_SIZE/LOAD_TYPE_SIZE sous TROU ; STATIC_TYPE_SIZE_BITS
contrat du 0 documenté + 2 TROU d'ignorance ; règle unique CCDA
corrigée (DN_QUALIFIED ajouté — amendement n° 112) et imposée aux trois
sites d'affectation ; gardes TROU sur CODE_RETURN tableau,
CODE_ACTUAL_OBJECT_VALUE, SELARG vue contrainte, indexé out/in-out ;
'CONSTRAINED/'WIDTH LI 0 sous TROU ; commit B : orthographe La
normalisée (21 lignes, octets identiques). Vague 3 (arbre instructions,
26 modifs) : 11 else de dispatch dont 5 HORS liste (revue systématique
— CLAUSES_STM, TEST_CLAUSE_ELEM_S, BLOCK_LOOP, ENTRY_STM, INC/DEC =
boucle infinie), 9 corps tasking+DELAY, 2 découvertes actuels (LI sans
opérande, else INVERSE_RECURSE). Vague 4 (déclarations/structures, 32
modifs) : §1c + 7 hors liste (dont GFP offsets) ; élucidations :
IMPLICIT_NOT_EQ → INTENTIONNEL (résolu au site d'usage),
DERIVED_SUBPROG → TROU confirmé (SUBPROGRAM_ORIGIN ne suit pas la
dérivation), scorie DN_FIXED supprimée. Reclassements post-recensement
1-6 : PREDEF_NAME de STANDARD ; renommage de paquetage (garde avant
namespace, _SYSTEM) ; split LENGTH/ENUM + SM_POS→SM_REP ;
RECORD_REP affiné + épilogue instanciation élucidé (FINC TO_CHN) ;
at-mod plié statiquement (STATIC_BOUND_VALUE exporté) + dossier
'ADDRESS ouvert ; constante différée LRM 7.4. Vague 5 (32 modifs) :
22 promotions TROU (équilibres conservés), 6 DEFAUT DOCUMENTE, 2
prises tardives de la vérification structurelle ('STORAGE_SIZE,
« choix inconnu »). Définition de fini ATTEINTE (greps vérifiés).

Bilan recensement auto-compilation : 187 traversées / 10 familles / 8
chantiers (C1-C8, BILAN_RECENSEMENT_TRIAGE.md). DÉCISION : segfaults
suspendus jusqu'à compteur zéro ; séquencement C1 (conversions
dérivées, 60) → C2 (case sous-type, 84) → C3-C6 → C8 ('ADDRESS 3
sites, voie 3 recommandée) → C7 (résultat non contraint, NOTE_MODELE)
→ STRICT permanent.

Méthode consolidée : livraison par fichier d'instructions ancré (une
modif = ancre unique + bloc avant + bloc après, tabs préservées),
contre-épreuve par REJEU programmatique sur sources vierges, filet
syntaxique -gnats -gnat83 ; deux commits quand deux oracles (logique =
diff FINC ; orthographe = filet, octets identiques). Pièges versés :
121 (avaleurs non-115 + amendement 112 + leçon greps), 122 (doctrine
du reclassement : bénir l'observé, jamais la classe).

## Session du 1er aout 2026 — C7 + C8 : le recensement tombe a ZERO, STRICT permanent

**C7 (instanciation de fonction generique a resultat non contraint,
10 traversees).** Oracle INSTF1 ecrit avant (deux instances BAND a
bornes differentes, trois formes d'usage). Le FINC de l'oracle a montre
que les trois piliers etaient DEJA cables et corrects (site d'appel
@doublet anonyme ; CODE_RETURN ecrivant data_ptr + descripteur A
TRAVERS le slot ; RTD prm_siz-8) — le maillon casse etait le WRAPPER :
INSTANTIATION_SUBPROG_GENERIQUE poussait LI 0 comme lieu result du
modele (protocole scalaire), et BAND ecrivait a l'adresse 0 (le
segfault de l'oracle). Correctif : quand le resultat est DN_ARRAY, le
wrapper RELAIE son slot recu (La lvl,-result__ofs) ; epilogue :
rien a rapatrier — TROU soldé en INTENTIONNEL discrimine (record/
access non contraints restent TROU) ; fossile n 4 amende (sa moitie
PARTAGE supposait un relais qui n'existait pas). INSTF1 PASSE (8 OK),
les 10 traversees corpus tombent. → PIEGE n 123.

**C8 (clauses d'adresse d'objet, 3 traversees + les refus scalaires).**
Le dump DIANA du mainteneur (TEST_ADDRESS) a tranche d'emblee : sem
POSE SM_ADDRESS (objets ET sous-programmes) ; et l'expander etait a
moitie cable — push d'adresse ORPHELIN dans COMPILE_ARRAY_VAR (fuite
d'un quadmot par elaboration), Sa _disp MANQUANT dans
COMPILE_RECORD_VAR. Mecanisme retenu (proposition mainteneur) :
**resolution PAR NOM deleguee a fasmg** — equation de symbole
X_disp = Y_disp, zero code, seul schema couvrant les SCALAIRES.
Cinq lots successifs, chacun declenche par une decouverte du corpus :
- v2 : helper OVERLAY_TARGET + equation (scalaire, array, record) ;
  suppression de l'orphelin ; verdict discrimine a CODE_NAMED_REP
  (clause de SOUS-PROGRAMME → TROU « hors objet », chantier separe).
- v2.1 (print_nod) : SORTES ASYMETRIQUES — le slot scalaire porte sa
  VALEUR : array-sur-scalaire = VAR + data_ptr := @slot cible (LVA/Sa),
  pas d'equation ; et INIT A TRAVERS l'overlay (agregat → array
  seulement : l'idiome d'endianite ECRIT la cible a l'elaboration).
  Fermeture d'un angle mort v2 : scalaire-sur-composite equatait a
  tort (jamais mordu).
- v2.2 (univ_ops, U_INT) : cible = PARAMETRE in — troisieme sorte de
  slot (@doublet de l'actuel, n 91/94) : La lvl,-V_ofs / La ,0 / Sa.
- v2.3 (meme site, bloc) : XD_REGION = BLOCK_LOOP_ID, CODE_BLOCK fait
  INC_LEVEL — la garde de niveau posee DANS le helper interdisait a la
  voie parametre ce qui lui est permis. Garde redescendue chez ses
  proprietaires (equation/LVA) ; le La du parametre s'adresse au
  NIVEAU DE LA CIBLE. → PIEGE n 125.
- v2.4 (SPREAD) : parametre in out — protocole IDENTIQUE (slot
  composite = @doublet pour tous les modes), trois tests = DN_IN_ID
  elargis. Mode out : au carnet (situation C3).
Temoin ADDR_OV1 v6 : 27 assertions, 7 sections (alias, univ_ops,
record, attributs, scalaire, endianite print_nod, parametres in /
in out / en bloc). → PIEGE n 124.

**Bilan : recensement auto-compilation 187 → 0.** Listing sans TROU du
01/08. BASCULE STRICT PERMANENTE (option W hors filet,
TROU_RECENSEMENT = FALSE par defaut). Prochain : re-deroule STRICT +
filet, puis POINT 8 — reprise des segfaults (null_prog, phase
post-PAR_PHASE) sur FINC sains ; diagnostics anterieurs a re-observer
(premiere execution correcte d'univ_ops/print_nod).

Methode consolidee : lots ancres v2→v2.4 COMPOSABLES (contre-epreuve :
rejeu de la chaine entiere depuis source vierge = octet-identique a
l'etat final) ; le dump DIANA du mainteneur a tranche DEUX impasses
(SM_ADDRESS pose ; XD_REGION bloc) — le demander TOT. Patchs :
expander-declarations.adb SEUL (C7 + C8). Temoins verses au filet :
INSTF1, ADDR_OV1.

### Session 5-6 aout 2026 -- la famille du patron non contraint (8 commits, temoin REC_ARR_TEST)

Point de depart : anomalie spec/corps du type-info de LEX.LINE_OF_SOURCE (bloc imbrique du composant
BDY : STRING(1..MAX_STRING) absent au corps, USEINFO pointant STANDARD._STRING). Point d'arrivee :
null_prog.adb passe lexeur et debut de parseur sur le bootstrappe (STORE_SYM correct, DN_PROCEDURE_SPEC
construit) ; reste un CONSTRAINT_ERROR au scan de BEGIN -- chantier de la prochaine session.

**Le mecanisme central, en une phrase** : l'ancien code de composant de record emettait ` namespace
_STRING`, qui en fasmg ROUVRE le namespace STANDARD._STRING et y greffe _COMP_SIZ@+4/_FST_1@+8/_LST_1@+12
-- exactement le layout contraint ; le patron pollue devenait un faux descripteur auto-coherent
(FST=1/LST=255, les bornes de BDY lui-meme), et TOUS les emetteurs fautifs de __u := patron marchaient
par accident. La de-greffe (commit 1) a transforme leurs lectures en bruit (longueurs ~4 Mo), d'ou la
cascade : "concatenation cassee" -> segfault OPEN -> chasse aux ecrivains -> 6 consommateurs assainis.

**Les 8 commits** :
1. types_decls / composant tableau anonyme de record : bloc LOCAL _<comp>__type emis INDEPENDAMMENT de
   CD_COMPILED (l'attribut revient TRUE au corps via rechargement DCL -- piege n 46 generalise), nomme
   par composant (collision de deux anonymes du meme type de base eliminee), USEINFO pointe le local.
2. CODE_INDEXED : discriminant IS_ANON_COMP (identite D(SM_TYPE_SPEC, XD_SOURCE_NAME) /= TYPE_SPEC) +
   helper PUT_INFO_DIRECT factorisant les 4 emissions (checks FST/LST, offset, COMP_SIZ) ; producteur
   aligne sur le meme test + CD_LEVEL pose sur le sous-type anonyme (records imbriques corrects).
3. CODE_ARRAY_OPERAND : garde litteral-seulement elargi a BORNE_RE_EMISSIBLE (litteral, CONSTANTE,
   nombre nomme -- immuables donc re-emissibles) ; discriminant/variable restent bruyants.
4. CODE_SLICE prefixe DN_SELECTED : recalage @data + (FIRST(tranche)-FIRST(prefixe))*comp_size, avec
   FIRST(prefixe) LU au bloc elabore (_<comp>__type / _<TYPE>) -- zero re-evaluation, discriminants
   couverts par construction. Temoin 37 rouge->vert (le couple 36/37 longueur/contenu a discrimine).
5. SELARG actual composant : __u := _<comp>__type.use__info (meme discriminant que 2 et 4).
6. COMPILE_ARRAY_VAR, objet NON CONTRAINT initialise par TRANCHE (la forme NOM_TEXTE, cause directe du
   segfault) : le doublet source de CODE_SLICE (info normalisee 1..len) fournit __u, la longueur (idiome
   LId du "&") et la source du BLKMOV -- plus jamais SIZ=-1 du patron. Formes soeurs (objet entier,
   composant, qualifie) posees en refus bruyant.
7. SELARG nom ETENDU d'objet (IDL.LIB_PATH) : __u := le __u de l'OBJET lui-meme.
8. Garde "composant" levee par FIX_PRE (ITEM_NAME := BLTN_TEXT_ARRAY(OP_NAME)) : CODE_ARRAY_OPERAND
   etait DEJA au niveau module (indentation trompeuse) -- exporte au spec d'EXPRESSIONS en UNE ligne,
   la branche composant reprend le modele tranche a l'identique. Le normalisateur "expression tableau
   -> doublet" est desormais un SERVICE.

**Methode retenue (a reutiliser)** : temoin auto-jugeant AVANT correctif (rouge->vert = preuve), harnais
sans dependance a la fonctionnalite sous test, matrice de triage section->site, recensement des emetteurs
DANS LES SOURCES DE L'EXPANDER (seul ecrivain au monde) plutot que dans les FINC, classifieur v2
MORT/VIVANT (fenetre = segment d'elaboration), diff FINC avant/apres comme detecteur de collateral,
forensique gdb (x/4wx info : SIZ=-1 signe le patron ; data en zone constante = litteral + cellules).

**Observations pour la prochaine session (CONSTRAINT_ERROR au LEX_SCAN{BEGIN})** : dans la trace, les
attributs NON renseignes du DN_PROCEDURE_ID affichent tous [DN_ALTERNATIVE_PRAGMA,P357,L86] -- y compris
CD_LEVEL qui devrait etre un entier. Remplissage par defaut du dumper ou vraie contamination : a trancher
en premier.

**Etat** : REC_ARR_TEST 53/53 (2 runs identiques), filet vert, bootstrap lexe/parse null_prog jusqu'a IS.

## Session 7 aout 2026 -- PAR_PHASE bootstrappee BIT-EXACTE sur null_prog
## (CONSTRAINT_ERROR au LEX_SCAN{BEGIN} soldee ; famille n 112,
## occurrences 3 et 4 ; pieges 129-131)

Fil complet, du symptome a la racine -- quatre niveaux d indirection :
CONSTRAINT_ERROR sec apres LEX_SCAN{BEGIN} -> fenetre GET_TOKEN/dispatch
(sondes @GT1-4/@PC1-5, commits 1-2) -> fenetre DI/LIST/APPEND (@GT2a/2b,
commit 3) -> 3e APPEND, branche else premier passage (@AP0-7, commit 4)
-> T_TAIL := S.NEXT rendu difforme des l INITIALISATION -> PG=0 ->
check de gamme perimetre 1 CUR_VP := T.PG (VPG_NUM 1..MAX_VPG) dans
DABS. Le site de check pressenti etait le bon ; le poison venait de
plus haut.

En chemin, la question ouverte de la session precedente (attributs non
renseignes affiches [DN_ALTERNATIVE_PRAGMA,P357,L86] : dumper ou
contamination ?) est TRANCHEE par le diff gnat/bootstrappe : dumper --
print_nod parcourt tous les slots du genre, gnat montre DN_VIRGIN aux
memes slots. MAIS le residu bootstrappe etait UNIFORME, et un residu
uniforme n est pas un residu : c etait la boucle de remplissage
(others => TREE_VIRGIN) d ALLOC_PAGE qui tournait avec une source
fausse. Temoin SECV1 (3 etages A record ordinaire / B represente 32
bits / C valeur locale) : ECHEC 128/128/128 -> lecture du FINC : la
source du BLKMOV etait LVA X_disp (l @doublet) au lieu de La X_disp
(le data_ptr) -- chaque cellule recevait le bas d adresse de X__dat.
C est la valeur [DN_ITERATION_ID,P6996,L102] des cellules "vierges".

Deux miscompilations DISTINCTES de la meme famille n 112 se
superposaient donc : (a) source de composante composite d agregat
tableau -- EMIT_ONE_COMP emettait CODE_EXP nu, le correctif anterieur
(commentaire "bug PAG(RP).DATA.all") avait remplace SId par BLKMOV
mais viole la regle unique sur la source ; spectaculaire (pages non
vierges) mais INOFFENSIVE pour null_prog ; (b) init de DECLARATION
record -- COMPILE_RECORD_VAR faisait CODE_EXP + "La ,0" inconditionnel,
juste pour un producteur d @doublet (appel de fonction : les milliers
de X : TREE := D(...) marchaient), faux pour une reference de
composante (@data nue) : la VALEUR 32 bits du TREE devenait l adresse
source -- le vrai tueur. Sans le temoin SECV1, corriger (a) et
conclure trop vite etait le piege naturel.

Correctifs (3 commits, 4 modifications) :
- C6 (expander-expressions, EMIT_ONE_COMP) : source BLKMOV par
  CODE_COMPOSITE_DATA_ADDRESS -- 3e amendement de la regle unique.
- C7 (expander-expressions, COMPUTE_DYNAMIC_DIMS + EMIT_ONE_COMP) :
  CD_IMPL_SIZE d un DN_RECORD ordinaire = 64 quel que soit le nombre
  de champs (LI 8 pour un record de 16 octets) -> taille SYMBOLIQUE
  _TYPE.size, modele EMIT_ONE_COMPONENT, appliquee DE CONCERT a la
  longueur et au pas _STR (garde identique : DN_RECORD non represente ;
  le TREE represente garde le numerique, 32 juste). Contournement au
  consommateur ; poseur a auditer (types_decls), dette au carnet.
- C8 (expander-declarations, COMPILE_RECORD_VAR) : init par la regle
  unique (CODE_COMPOSITE_DATA_ADDRESS remplace CODE_EXP + La ,0).
  Temoin TTAIL1 avant correctif : A ECHEC puis SEGFAULT a C (BLKMOV
  depuis l adresse 33 -- coherent) ; apres : A/C/F OK.

Verdict : TLALOC(TLALOC) mene null_prog.adb au bout de la phase
syntaxique. Diff des traces integrales gnat/bootstrappe : IDENTIQUES A
L OCTET PRES sur toute la portion syntaxique (732 lignes -- etats,
actions, numeros de pages/lignes de noeuds, dumps), apres normalisation
des fins de ligne : la trace bootstrappee est en CRLF (runtime TEXT_IO,
piege n 131) et le diff brut disait "tout differe". Fausse alerte
geree en fin de session : le supplement du listing gnat etait LIB_PHASE
et suivantes (option W cote gnat, S cote bootstrappe) -- lecon de
protocole : comparer a OPTIONS IDENTIQUES.

Methode : la chaine sondes-encadrantes -> diff gnat/boot -> temoin
minimal -> lecture FINC -> correctif d une ligne a fonctionne trois
fois de suite dans la meme session. Trois occurrences de la famille
n 112 en trois chantiers successifs : AUDIT PREVENTIF recommande
(grep des CODE_EXP suivis de La/BLKMOV hors regle unique) avant ou
pendant l ouverture de LIB/SEM_PHASE, qui multiplient les copies de
TREE/SEQ. Site frere deja marque "A VERIFIER" dans
expander-instructions (DESTINATION_SELECTED, tableau non-agregat).

**Etat de sortie** : PAR_PHASE bootstrappe bit-exact sur null_prog ;
SECV1 et TTAIL1 au filet ; sondes @GT/@PC (idl-par_phase), @AP
(idl-idl_man) ENCORE EN PLACE (retrait par grep @GT/@PC/@AP quand le
chantier suivant n en aura plus besoin -- elles resserviront telles
quelles au premier run W). Patchs : expander-expressions.adb (C6, C7),
expander-declarations.adb (C8).

**Suite (deux voies, a arbitrer)** : (1) securiser l acquis syntaxique
-- option P apres PAR_PHASE (dump DIANA syntax-only), diff gnat/boot
du dump, corpus de sources au-dela de null_prog ; (2) attaquer la
compilation complete (W) de _standrd.ads par le bootstrappe --
prerequis de TOUT null_prog en W (LIB_PHASE exige la bibliotheque).
Pour (2), prevoir l upload LIB_PHASE/SEM_PHASE selon l INDEX, et la
reference gnat-W existe deja (trace du 7/08, sondes comprises).

## Sessions 8-9 aout 2026 -- campagne du segfault 0x4028d8 : POINT FIXE
## ATTEINT SUR _standrd.ads

Juge final : FINC(TLALOC(TLALOC)) IDENTIQUE A L'OCTET PRES a
FINC(TLALOC(gnat)) sur _standrd.ads -- 18 932 octets, CRLF pres, cmp muet.
Le bootstrappe execute PAR + SEM + EXPANDER complets sur la spec standard.

Familles closes, dans l'ordre de la chaine (pieges 138 a 143) :
138 subunits a parent porteur de frame (CUR_LEVEL, canal CD_LEVEL +
    remontee XD_REGION) -- gardien SUBLVL_TEST ;
139 agregat de tableau DE tableaux, composante non-agregat en voie
    scalaire (garde de profondeur EMIT_ONE_COMP) -- gardien AGGSTR_TEST ;
140 operateurs UTILISATEUR emis comme predefinis (dispatch DN_USED_OP) +
    trois raccords de nommage (appel lettre, REGIONS_PATH, table "=") ;
141 collision des doublets anonymes sur infixe (suffixe NEW_LABEL --
    lecon : le nommage positionnel ne peut pas separer une expression de
    son operande gauche) ;
142 UN OPERATEUR EST UNE FONCTION : epilogue RTD prm_siz-8 + appel
    prefixe + init selectionne (recensement grep au piege) -- gardien
    OPDEF_TEST 1-8 ;
143 STATIC_TYPE_ALIGN_BYTES et pragma PACK (patch V.M. ; desaccord
    type-info/consommateurs A CITER ICI apres les 4 greps du lot) --
    gardien PACKV_TEST ; PRINT_NUM disculpee par RECSTR_TEST et
    RECSTR2_TEST (verts d'origine, au filet).

Lecons de methode gravees : deux familles peuvent partager un symptome
(141 masquee par 142) -- re-deriver la chaine causale a chaque crash ; une
boucle infinie while-decrementante = parametre astronomique = chercher le
site d'appel ; un alignement ne corrompt jamais seul -- nommer le
desaccord.

Sondes @PD et @PN retirees. Suivant en file : segfault de _standrd.adb
(corps de la bibliotheque standard), meme protocole.

Incidemment : calendar.adb corrigé : conversions de type explicites dans les fonctions de comparaison (elle partaient en récursion infinie sans les conversions DURATION).

## Session 10 aout 2026 -- segfault _standrd.adb (corps) : GFP au niveau
## GENERIC_BASE_LEVEL+1 dans les sous-programmes IMBRIQUES d'un corps
## generique (piege 144) ; POINT FIXE ATTEINT SUR _standrd.adb OPTION W

Symptome : T2 sur _standrd.adb option M, flot d'execution envoye dans la
pile (rip = rax = 0x7fffffc0f498, adresse de pile ; backtrace : deux
frames de REQUIRE_XXX au-dessus de N_REQUIRE_SCALAR_TYPE, crash au CALLI
du sous-programme formel IS_XXX).

Chaine causale (une seule famille, piege 144). REQUIRE_XXX est une
fonction recursive IMBRIQUEE (ELB 3) dans le corps generique
REQ_TYPE_XXX (ELB 2) de SEM_PHASE.REQ_UTIL. CODE_PROCEDURE_CALL
emettait les deux acces GFP -- propagation aux appels internes et CALLI
formel -- au niveau GENERIC_BASE_LEVEL+1 (= 2) avec le symbole GFP_ofs,
que fasmg resout au PRM du PRO COURANT (namespace) : offset 16, qui au
niveau 2 est... TYPESET_ofs. Le pseudo-GFP lu etait l'adresse d'un
typeset (pile) ; [pseudo-GFP - 24] via IS_XXX__call_ofs = qword de pile
quelconque ; CALLI dedans. Verrous numeriques du diagnostic : offset 16
= TYPESET aux deux etages ; rip = rax = adresse de pile ; ecart
rbp - rsp d'environ 72 Ko explique par la fuite d'un slot resultat par
appel formel sous recursion (symptome secondaire de l'ancienne
propagation inconditionnelle, disparu a la regeneration -- la garde
not IS_GENERIC_FORMAL_SUBPROGRAM de la source courante ne l'emet plus).

Correctif : deux sites de CODE_PROCEDURE_CALL (propagation + CALLI
formel) passes de GENERIC_BASE_LEVEL+1 a CUR_LEVEL. Justification
structurelle : chaque PRO d'un corps generique porte son propre
PRM GFP_ofs (CODE_PARAM_S) et le recoit par propagation a chaque appel
-- CUR_LEVEL est correct a tous les etages, et la sortie est octet a
octet inchangee a l'imbrication 1 (les deux niveaux coincident), ce que
le diff FINC de REQ_UTIL a confirme. Bug invisible jusqu'ici : premier
generique du corpus a fonction interne recursive appelant un formel.
Jumeaux non exerces consignes au piege 144 (~21 sites, recensement
grep GENERIC_BASE_LEVEL | grep GFP_ofs : LOAD_MEM, use__info des types
formels, litteraux et conversions fixed, STORE_OR_CALLI, MACHINE_CODE)
+ RESERVE bloc declare (frame propre sans PRM GFP : CUR_LEVEL y serait
faux aussi, il faudrait le niveau du PRO englobant).

Juge final : _standrd.adb passe COMPLETEMENT en option W dans T2, et
FINC(TLALOC(TLALOC)) IDENTIQUE A L'OCTET PRES a FINC(TLALOC(gnat)) --
2220 lignes, md5 identiques, CRLF pres, cmp muet. Premier CORPS au
point fixe (les specs l'etaient depuis le 9 aout). Oracle plus fort que
le temoin FINC du correctif : le REQ_UTIL corrige TOURNE dans T2
pendant cette compilation -- la resolution de surcharge par typesets
(REQUIRE_SCALAR/UNIVERSAL_TYPE, recursion comprise, CALLI formel de
bout en bout) produit les memes decisions que la reference gnat ; une
divergence silencieuse de filtrage se serait vue au diff.

Suivant en file : les packages predefinis, meme protocole en boucle --
essai de compilation T2, correction des segfaults s'il y en a,
comparaison des FINC T1/T2 (CRLF pres). Objectif de campagne :
recompiler avec T2 tout ce que T1 compile et obtenir les MEMES FINC.

## Session 11 aout 2026 -- CAMPAGNE DES PREDEFINIS : trois chantiers
## (pieges 145, 146, 147), POINT FIXE ATTEINT SUR LES 10 BIBLIOTHEQUES
## (15 compilations : 10 specs + 5 corps)

Etat d'entree : specs passant sauf text_io/direct_io.ads (« INTEGER TYPE
TOO LARGE FOR IMPLEMENTATION » sur COUNT, absent sous T1) ; corps tous
en segfault (calendar/direct_io/sequential_io en WRITE_LIB, text_io en
sem_phase). Protocole de session : livraisons en ancre/suppression/
remplacement groupees par commit avec oracle.

CHANTIER 1 -- erreur type A (piege 145). Sondes en escalier dans
DEF_WALK/DN_INTEGER_DEF : @IB1 (valeurs quatre a quatre IDENTIQUES --
donnees innocentees, GET_STATIC_VALUE et relecture _STANDRD hors de
cause) ; @IB2 avorte (BOOLEAN'IMAGE sur appel d'operateur ->
PROGRAM_ERROR runtime : decouverte annexe consignee, territoire
140-142) ; @IB3 = FFFFFF (les SIX comparaisons fausses, y compris
0 >= -32768 : trois configurations mathematiques disjointes -> aucune
corruption de donnees ne les uniformise -> le resultat BOOLEAN ne
parvient jamais a l'appelant). Temoin OPB en echelle de fidelite :
protocole scalaire nu 8/8, homonymes 10/10 -- la miscompilation est
contextuelle. Lecture FINC croisee : site d'appel _LE__L31/_GE__L32
(arithmetique des labels ancree par _NOT__L38 -- les extraits
_LE__L27/_GE__L29 etaient les freres TREE, prouve par CODE_RETURN
DN_RECORD et l'ordre d'empilement des operandes), corps BOOLEAN enfin
extraits : l'operande GAUCHE de l'egalite record fait CALL puis Ld SANS
La -- il charge les 32 bits bas de l'ADRESSE du doublet, CEQ toujours
faux. Cause : ( LEFT <= RIGHT ) est un DN_PARENTHESIZED (parentheses
OBLIGATOIRES entre relationnels), et OPERAND_DATA_ADDRESS -- copie
locale DIVERGENTE de la regle n 112, jamais rebranchee sur
CODE_COMPOSITE_DATA_ADDRESS dont elle est l'ancetre nomme -- discrimine
par espece sans deballer. La regle unique elle-meme ne deballait pas
PARENTHESIZED (freres latents, p.ex. T : TREE := (D(...))). Correctif
F1 : la regle apprend DN_PARENTHESIZED dans la boucle de deballage
(meme statut que la conversion C1-ter, meme AS_EXP) ; OPERAND_DATA_
ADDRESS delegue a la regle (garde agregat conservee). Gardien OPB 11-12
rouge capture « 11 OK, 1 ECHECS ». Resultat : les 10 specs passent,
@IB3 = TFTTTT.

CHANTIER 2 -- segfault WRITE_LIB (piege 146), trois corps d'un coup.
Poison 0x0101010101010101 = HUIT TRUE ; hardware watchpoint sur la
cellule LINK -> ecriture prise sur le fait dans MARK_DONT_MOVE_PAGES,
cliche a sept octets sur huit (remplissage octet par octet, boucle SIb).
FINC en toutes lettres : CODE_ASSIGN (cible DN_SLICE) calcule @dst ET
len_dst puis DROP la longueur ; CODE_ARRAY_AGGREGATE recalcule aux
bornes DU TYPE (_FST_1 = 0 litteral, _LST_1 = MAX_VPG) et remplit
LEN(type) composants depuis le debut de tranche : debordement de
(bas_tranche - FST_type) octets au-dela + queue de tableau ecrasee a
l'interieur. Explique tout : _standrd immune (aucun with, HIGH_BLOCK
petit), fermetures transitives touchees, find pile negatif du premier
dossier (les frames vivent dans la zone statique, r13 = 0x18e4a60).
Correctif W1 : contrainte applicable = celle de la TRANCHE (RM83
4.3.2) ; AS_DISCRETE_RANGE du DN_SLICE passee en parametre defaute
TREE_VOID a CODE_AGGREGATE -> CODE_ARRAY_AGGREGATE surcharge DIM_TBL(1)
seule (tranches 1-dim, RM83 4.1.2) ; toute la machinerie aval devient
juste ; bornes re-evaluees (pures dans le corpus, consigne). Gardien
SLAGG rouge capture « 6 OK, 2 ECHECS » -- le check 8 prevu rouge etait
BLANCHI par le second debordement compensant le premier (lecon : deux
instances du meme bug peuvent se masquer fonctionnellement). Resultat :
calendar/direct_io/sequential_io.adb passent.

CHANTIER 3 -- segfault text_io.adb (piege 147), le seul au RUNTIME.
Crash au LINK du prologue de DABS avec r14 = 0x8DD0000 TOUT ROND = fin
d'arene, r13 = r14-8, profondeur C de 32 seulement : EPUISEMENT sans
profondeur. Lecture de codi_x86_64.finc : la co-pile est declaree
« desallouee a la maniere de la pile usuelle » (doc), EXC_RAISE restaure
bien r14 (« balaye frames abandonnes »), mais la macro UNLINK annonce en
commentaire « liberer les allocations » et n'est suivie QUE du depilage
de chaine : r14 n'est JAMAIS rendu sur le chemin normal (TODO annonce
non implemente). Allocateur a bosse : 8 octets par LINK + tous les
CO_VAR, a vie du processus -- text_io (plus gros corps) creve les
128 Mo (p_memsz). TENTATIVE R1 (mov r14,r13 a l'UNLINK) REVOQUEE :
casse le CONTRAT D'EVASION -- les resultats STRING des fonctions vivent
sur la co-pile du calle et sont consommes apres retour ; sous R1 le
LINK du consommateur ecrasait leurs tetes (constate sur _standrd :
noms manges, PROGRAM_ERROR). COPILE_TEST avait valide le mauvais
contrat (CO_VAR consommes dans le frame allocateur). Decision R2 :
UNLINK d'origine + commentaire n 147 (le prochain lecteur ne retombera
pas dans le piege d'une ligne), arene 128 Mo -> 1 Go (reservation
PT_LOAD, pages au toucher, fuite bornee par processus = par unite
compilee), vrai chantier documente pour plus tard (retour glissant --
recommande : deux sites seulement, CODE_RETURN dynamique + UNLINK --
ou marques de relache type ss_mark/ss_release). Gardien STRRET_TEST
(contrat d'evasion, 7 assertions) : vert obligatoire sous tout
remaniement futur, PASSE AVANT le build dans l'ordre des oracles.
Resultat : text_io.adb passe.

JUGE FINAL DE CAMPAGNE : diff_finc.sh (nouvel outillage, oracle de
point fixe) -- 10 FINC sur 10 IDENTIQUES a la reference T1 (CRLF pres),
0 divergent, 0 manquant. POINT FIXE PREDEFINIS ATTEINT. 53 FINC cote
T1 seulement = les sources du compilateur = la liste de courses de T3.

Annexes consignees en route (reserves, pas de chantier ouvert) :
garde at-mod de CODE_RECORD_REP testee par IDENTITE de noeud au lieu de
l'espece (un source SANS at mod tombe en TROU « non statique » --
fossile, meme lecon que les cellules vierges non nulles de SECV1) ;
CODE_LOAD_REP_COMPONENT refuse byte_offset non nul (couverture
documentee, refus propre) ; l'elaboration R : STRING := litteral ALIASE
le litteral sans copie (dormant) ; double endPRO des blocs declare
(tolere fasmg, fossile n 142 possible) ; BOOLEAN'IMAGE sur appel
d'operateur utilisateur -> PROGRAM_ERROR runtime (territoire 140-142,
temoin a ecrire le jour venu).

Lecons de methode gravees : les temoins de RUNTIME doivent couvrir les
contrats d'EVASION, pas seulement les contrats locaux (l'echec de R1
vaut la lecon) ; l'oracle de POINT FIXE prime sur l'oracle d'execution
(une divergence FINC qui « passe » est une dette qui murit -- le n 145
en fut une) ; une valeur uniforme n'est pas toujours un pointeur ou un
remplissage de recopie -- huit octets 0x01 etaient huit TRUE (completer
la grille du n 135) ; et deux instances d'un meme bug peuvent se
compenser fonctionnellement (SLAGG check 8) -- le watchpoint, lui, voit
tout.

Suivant en file : T3 -- compilation par T2 des ~53 sources du
compilateur. Premier essai deja fait : grande majorite des modules
passent ; le reste = erreurs Ada 83 detectees par la semantique de T2,
a confronter au LRM (legitimes ? divergences T1/T2 ?). Prealables en
parallele : mesure de calibrage co-pile (r14 en fin de text_io.adb --
sem_phase.adb sera plusieurs fois plus gourmand, savoir si 1 Go tient
ou si le retour glissant devient prerequis de T3) ; retrait des sondes
@IB ; objectif terminal inchange : FINC(T2(sources)) IDENTIQUES a
FINC(T1(sources)), diff_finc.sh un cran plus haut.

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

## 12 août 2026 — Les 6 derniers segfaults, un seul bug ; POINT FIXE à 13h20

Session gdb + lecture systématique sur le segfault de T2 compilant
lex.adb (rapport seg_fault_T2_lex.md). Démarche et verdicts :

1. Co-pile ÉCARTÉE en dix minutes par signature (n° 109 : faute au
   mov [r14],r13 du prochain ELB ; ici stos d'un BLKMOV dans l'épilogue
   de LABEL_STR, rdi=1). Le callé LABEL_STR innocenté : exercé par
   toutes les unités vertes.
2. Fil conducteur trouvé : CODE_GOTO/CODE_LABELED ne s'exécutent que si
   l'unité compilée contient goto/étiquette. Les 6 unités en échec sont
   EXACTEMENT celles-là (vérifié sur les 2 du projet, confirmé par grep
   sur les 4 autres). Un bug, pas six.
3. Décodage du crash : le paramètre LBL était lu juste (tranche 2..3 en
   pile) -> UN quadmot parasite entre le lieu-résultat et l'actuel ->
   -result__ofs du callé visait une @table nue ; SIq corrompait
   [table+0] en silence, BLKMOV fautait sur [table+8]=1.
4. Coupable : CODE_INDEXED, double empilement de l'@data pour un préfixe
   nom étendu (CODE_SELECTED PUIS la queue commune). Empreinte FINC :
   deux `La ...GOTO_LABELS_disp` consécutifs identiques — vérifiée AVANT
   correctif, disparue APRÈS. Piste n° 141 (collisions ANON) écartée en
   chemin : l'audit recommandé pointait PREPARE_ARRAY_RESULT_PLACE, le
   trou était un cran plus bas, dans le préfixe de l'actuel.
5. Correctif : garde DN_COMPONENT_ID sur le pré-empilement (même
   prédicat que la queue commune ; chemin R.A(N) inchangé à l'octet).
   Livraison ancrée LIVRAISON_FIX_INDEXED_NOM_ETENDU.md, commit unique.
6. VERDICT : les 6 unités passent. Passe complète : 63 FINC produits par
   T2, contrôlés IDENTIQUES à ceux de T1. fasmg -> T3 = T2 à 13h20.
   **POINT FIXE DU BOOTSTRAP ATTEINT.** Consigné : piège n° 148, jalon
   ETAT_PILIERS, témoin GOTO_SELARG_TEST au filet.

Leçon de méthode (au piège) : un crash dans une routine ultra-exercée
innocente la routine et accuse la FORME de l'appel ; une fuite de pile
se cherche au site d'appel. Et : la table PIEGES a payé deux fois dans
la même session (n° 109 pour écarter, n° 141 pour orienter).

## 18 août 2026 — Fabrication de TARGET_CODE

Purge du residu USEINFO (1.1) 

## 20 août 2026 — Macros codi LLIR en majuscules pour TARGET_CODE

Incident B/W/D/Q clos : macro VAR de codi réécrite (dispatch explicite double casse, pièges fasmg backquote/affectation-de-paramètre reportés dans PIEGES), quatre Lq résiduels et case d'alignement remis en majuscules ; filet vert, bootstrap T1→T2→T3 vert. Contrat retenu pour TARGET_CODE : surface LLIR en majuscules, endPRMS/endPRO à trancher

## Sessions des 21–24 août 2026 — TARGET_CODE avale le compilateur : point fixe SANS fasmg

Campagne en trois actes, du corpus élargi au bootstrap complet de
l'assembleur natif.

**Acte I — corpus ENUM_TEST (TC-19, TC-20).**
1. « endPRO hors sous-programme » sur ENUM_TEST : la région PUT_L81 de
   TEXT_IO, jamais atteinte par DIS_BONJOUR, contient des BLOCS Ada
   internes. Au codi, PRO ne fait que namespace + BRA post : c'est ELB
   QUI OUVRE LE FRAME (VARzone fraîche + LINK). Un bloc s'écrit
   namespace BLOCK__n / ELB / endPRO — ELB sans PRO. Règle fidèle :
   drapeau PRO_PENDING ; l'ELB d'un PRO armé est celui du
   sous-programme, un ELB orphelin pousse son propre frame (TC-19,
   treize cmp muets du premier coup).
2. Thunks génériques : BRA post_X / X.elab: / corps bref / post_X:,
   adressés par LCA X.elab et appelés par CALLI nu (macro sans
   opérande, adresse empilée). Labels POINTÉS : détection par lookahead
   [mot|'.'] avant le test ':' (NEXT_WORD s'arrêtait au point — la
   ligne devenait un pseudo-mnémonique), déclaration éclatée
   ENTER_SCOPE par segment. Plus ET (12) et BLKCMP (45). TC-20.
3. En chemin : le renommage SIZ__ du patron est PARTOUT dans les
   unités régénérées — recalage des copies sandbox, la cohérence du
   corpus est source de vérité.

**Acte II — complétion EMITS et capacités (TC-21, TC-22), sur les
sources reformatées de l'utilisateur.**
4. TC-21 : les 26 mnémoniques restants transcrits du codi, repérés par
   les commentaires « a faire » (mots signés/non signés, ALU, champs de
   bits UBFX/SBFX/BFI, flottants FABS/FEXP/CVTXI/FCEQ/FCLE, familles
   BLK*, LEXCMP paramétrée 96+F à huit variantes, horloge, lseek).
   Témoin à 31 verdicts, fichiers de bout en bout. L'ORACLE UNITAIRE
   fasmg (delta d'octets par mnémonique isolé, avec/sans l'instruction
   sur un squelette constant) a débusqué une faute LATENTE de la table
   existante : FETCH_WORD_U est movzx RAX (REX 48 0F B7, quatre octets
   d'opcode), pas trois — ULW dormait, jamais exercé par le corpus.
5. TC-22 : jauges (TEXT_USED, POOL_USED/CAPACITY, SYM/SCOPE_COUNT,
   BIN_CAPACITY) + relevé CARTO après chaque assemblage nommé ; bornes
   ELT 500k, OPS 1,5M, DEFER 100k, TEXT 16M, SYM 1M, SCOPE 65 536,
   POOL 16M, HASH 65 536, BIN 32M. Calibration ENUM_TEST : ~78
   éléments par Ko de FINC.

**Acte III — ADA_COMP, les trois motifs du compilateur (TC-23 à
TC-25), et le point fixe.**
6. « déclaration dupliquée ANON_…_D_info, FRAME_OFFSET vs SCOPE_NAME » :
   en fasmg, un symbole et son espace d'enfants ne font QU'UNE entité.
   TC-23 : descente pointée sur « possède des enfants » (UNDER /= 0),
   ENTER_SCOPE sur un symbole valué = réouverture ou attachement
   (classe et valeur conservées), DECLARE sur un namespace pur =
   unification. Les deux ordres au témoin, cmp arbitre.
7. « GFP_disp deux fois FRAME_OFFSET » : la macro VAR fait
   name_disp = $ — assignation fasmg REDÉFINISSABLE, liaison de chaque
   référence à la définition la plus récente AU POINT DU TEXTE. Notre
   résolution étant tardive, restitution par ÉPOQUES : BIRTH par
   cellule (0 = de tout temps ; les ombres naissent à leur élément
   déclarant), FIND filtre BIRTH <= EPOCH, les boucles P2/P2B/P3 et les
   différés estampillent l'élément courant, restauration NATURAL'LAST
   en sortie de passe (la boucle INVERSE des différés figeait l'époque
   sur le premier élément global — vu au CHECK du témoin). TC-24.
8. TC-25 : rq (réservation de qwords, avance 8×N en zone virtual, zéro
   octet), calqué sur rd. HEAP_ALLOC ajouté par l'utilisateur en
   autonomie ; correctif expander en chemin.
9. **VERDICT (24 août)** : ADA_COMP.fas — 14 Mo de FINC, 765 721
   éléments, 200 347 symboles, 17 149 scopes, 10 294 504 octets émis —
   **cmp INTÉGRALEMENT MUET contre fasmg**. L'exécutable produit
   fonctionne, ET LE COMPILATEUR ASSEMBLÉ PAR TARGET_CODE SE RECOMPILE
   LUI-MÊME. Assemblage ~3× plus rapide que fasmg. **POINT FIXE DU
   BOOTSTRAP SANS fasmg : la chaîne est intégralement auto-hébergée.**

Leçon de méthode : trois motifs de corpus seulement séparaient les
unités de test du compilateur entier — et chacun s'est rendu au relevé
(l'extrait GRMR_OPS, le message de refus, le micro-test fasmg), jamais
à l'anticipation. L'oracle unitaire (delta par mnémonique isolé) rejoint
la panoplie aux côtés du cmp intégral : il localise en secondes ce que
le byte-diff global ne fait que signaler. Et les jauges CARTO ont
transformé « il va peut-être y avoir des limites de tables » en trois
constantes élargies sur mesure, sans une seule panne aveugle.

## 24 août 2026 (suite) — Segfault FLOAT_IO.PUT : GFP_LEVEL, la réserve du n° 144 levée

**Symptôme.** Filet repassé après la campagne TARGET_CODE et le
travail sur GET(FROM: STRING) de FLOAT_IO : TEST_CALENDAR, FLOAT_TEST
et FLOAT_FIXED_IO_TEST segfaultent au premier PUT flottant ; tout le
reste vert. Rapport gdb (segfault_0x40697A_test_calendar.md) : faute à
`mov -0x20(%rax),%rax` avec RAX = 0x402147AACD9E83E5 = 8,639975, soit
VAL (86 399,75 normalisé) ; l'instruction est le `LA , -NUM__inadr_ofs`
qui déréférence un pseudo-GFP lu par `LA 2, -GFP_ofs`.

**Décodage.** Dans le FINC, le niveau 2 est BLOCK__29 — le bloc
`declare ROUNDING : NUM := 0.5` de PUT — tandis que VAL est lu en
`LVA 1, …PUT_L69.VAL_disp` : le PRO est au niveau 1. Un bloc declare
ouvre un frame (ELB) mais ne porte AUCUN PRM : [display(2) − GFP_ofs]
tombe dans la pile d'opérandes sous le frame du bloc, où traîne VAL.
C'est mot pour mot la RÉSERVE consignée au n° 144 (« depuis un bloc
declare d'un corps générique, CUR_LEVEL est le niveau du BLOC »). Elle
a été exercée par la correction MAKE_FLOAT (GET, fonction imbriquée)
qui avait fait passer CODE_VC_ID de GENERIC_BASE_LEVEL+1 à CUR_LEVEL :
juste pour un PRO imbriqué, faux pour un bloc. Trois témoins, un PUT,
un bug. Nous avions oscillé entre les deux mauvaises réponses.

**Correctif (commit unique, 15 modifications).** Le bon niveau n'est
ni CUR_LEVEL ni GENERIC_BASE_LEVEL+1 : c'est celui du PRO ENGLOBANT LE
PLUS PROCHE, dont le namespace résout le symbole `GFP_ofs` et dont le
frame porte ce PRM. Nouvelle variable `CODI.GFP_LEVEL`, posée après
INC_LEVEL dans CODE_SUBPROGRAM_BODY (sauvegarde/restauration comme
GENERIC_BASE_LEVEL) et dans la branche générique de CODE_PACKAGE_BODY ;
CODE_BLOCK ne la touche jamais. Les huit sites `CUR_LEVEL … -GFP_ofs`
(CODE_VC_ID ×2, CODE_ADDRESS ×2, CODE_CONSTRAINED, 'WIDTH, propagation
et CALLI formel de CODE_PROCEDURE_CALL) passent à GFP_LEVEL ; deux
fossiles commentés retirés au passage.

**Oracle et verdict.** Diff FINC de TEXT_IO limité aux `LA 2,` → `LA 1,`
dans les BLOCK__n de FLOAT_IO.PUT / FIXED_IO.PUT, `LA 2` de MAKE_FLOAT
inchangé. Les trois témoins passent ; filet vert. Gardien GENBLK_TEST
(6 assertions : bloc dans PRO, bloc dans PRO imbriqué, appel du corps
générique depuis un bloc, sur LONG_FLOAT et FLOAT) PASSE, assemblé par
TARGET_CODE (CARTO : 20 885 éléments, 2 812 symboles, 35 760 octets).

**Reste en file (commit 2, mécanique).** Les ~21 jumeaux
`GENERIC_BASE_LEVEL+1 … -GFP_ofs` recensés au n° 144 passent à
GFP_LEVEL. Oracle de point fixe : FINC IDENTIQUES sur tout le filet
SAUF à l'intérieur des PRO imbriqués dans un corps générique
(MAKE_FLOAT), où 1 devient 2. Après ce commit, `-GFP_ofs` n'aura plus
qu'UN niveau dans tout l'expander.

Leçon de méthode : une réserve écrite au piège est une prédiction ;
quand deux corrections successives oscillent entre deux valeurs pour
un même site, aucune des deux n'est la règle — chercher la grandeur
qui les subsume (ici : le frame porteur du PRM, pas le niveau courant
ni le niveau de base).

## 25 août 2026 — Cible arm64 : BT/BF hors plage, contrat de taille fixe, premier bootstrap croisé sur Orange Pi 3B

**Symptôme.** Assemblage du compilateur ENTIER pour arm64 (fasmg -p 20,
codi_arm64.finc) : « could not generate code within the allowed number
of passes », puis assert de la macro BT sur `BT STANDARD.ne_raise_`
(_STANDRD.FINC 1175). Les témoins unitaires arm64 passaient tous.

**Décodage.** BT/BF émettaient CBNZ/CBZ x0, lbl : immédiat imm19, plage
±1 Mo. Le trampoline ne_raise_ est à plus de 1 Mo dans l'image complète ;
l'assert échouait à chaque passe et fasmg épuisait -p. Les autres
CBZ/CBNZ/B.cond de codi_arm64 sont intra-macro (cibles à quelques
instructions) ; BRA (B, imm26) a ±128 Mo. Même famille que le n° 82 x86
(BT/BF rel8/rel32) : un saut LLIR ne doit jamais dépendre de la distance.

**Correctif 1 (commit unique, 2 modifications).** Forme longue
SYSTÉMATIQUE par inversion : `cbz x0, .+8` enjambe un `B lbl` émis par
la macro BRA (BF symétrique avec cbnz). Aucune décision de taille
inter-passes (n° 82/88) ; +4 octets par BT/BF. Assemblage complet OK en
18 passes, 714 s sur le laptop x86 — contre 188 s pour x86-64, en 18
passes aussi.

**Décodage du ×3,8.** À passes égales l'écart est un coût PAR PASSE :
lignes fasmg interprétées par expansion (comptage statique, sous-macros
comprises) : LI 5 → 21, LVA 28 → 73, LQ/SQ 30 → 78, LIQ 47 → 144,
CALL 9 → 32. Coupables : QUAD_CONST (repeat 4 + deux if par tour + trois
local) appelée par LI/LCA/LSPA/CALL/CALLI et par les voies de repli ;
LOAD_QUAD (trois local, chaîne if) sous chaque FP_IN_RAX. Plus grave :
QUAD_CONST choisissait son NOMBRE d'instructions selon les chunks nuls
de la valeur, et elle était appelée sur des RÉFÉRENCES AVANT (retour de
CALL, prefix#subname#_ de LSPA, ptr+disp de LCA) — la décision de taille
non monotone du n° 88, et une violation du contrat SIZE_OF = ENCODE de
TARGET_CODE.

**Correctif 2 (deux commits, 21 modifications).** C1, adresses de taille
fixe : CALL/CALLI matérialisent l'adresse de retour par `adr x16, .+16`
(une instruction, plus de label local) ; LCA/LSPA passent par QUAD_ADDR,
movz+movk TOUJOURS deux instructions (assert image < 4 Go, même hypothèse
que le movabs fixe de x86) ; QUAD_CONST réservée aux immédiats, taille =
max(1, min(chunks ≠ 0, chunks ≠ 0xFFFF)) — fonction de la seule valeur,
calculable au parse — avec chemins rapides à une ligne (0..0xFFFF → movz,
-0x10000..-1 → movn) ; LI -1 passe de 4 instructions à 1. C2, display et
mémoire : FP_IN_RAX/RAX_IN_FP/FP_IN_RBP en encodage direct
(0xF9400380 | lvl<<10), LOAD_QUAD/STORE_QUAD et les neuf FETCH_*/STORE_*
sans local, tout paramètre parenthésé (piège n° 156 découvert au
passage : FP_IN_RAX émettait un LDUR au lieu du LDR scalé pour tout
niveau non multiple de 8, correct par chance).

**Contre-épreuve hors cible.** fasmg g.l8vn (dépôt officiel) sur des
témoins LLIR assemblés avec l'ancien et le nouveau codi : passes 4 → 3 et
2 → 2 ; diff des désassemblages limité aux changements attendus ; 410 LI
aléatoires 64 bits (bornes 0, -1, ±0x10000, 2^63, 2^64-1) rematérialisés
exacts au nombre minimal d'instructions ; x17 des voies de repli exacts ;
adr x16 vise l'instruction qui suit le b/br.

**Oracle et verdict.** Assemblage complet arm64 : 714 s → 548 s
(ratio arm64/x86 3,8 → 2,9 ; le reste est le coût intrinsèque des `dd …
or … shl …` de fasmg). L'exécutable arm64 transféré sur Orange Pi 3B
(RK3566, 4×A55) compile TOUT le source du compilateur en FINC en 5 min.
Ramenés par scp, ces FINC sont comparés (diff_finc.sh) à ceux produits
par T2 x86 assemblé par TARGET_CODE : AUCUNE DIFFÉRENCE. Deux chaînes
indépendantes (fasmg+codi_arm64 sur A55, TARGET_CODE+x86 sur laptop)
convergent vers la même LLIR sur le plus gros corpus disponible :
l'expander est correct sur arm64 et chaque instruction LLIR sollicitée a
la sémantique de son homologue x86. Jalon : PREMIER BOOTSTRAP CROISÉ.

**Ce qui manque pour fermer la boucle sur le Pi.** fasmg est un programme
x86 (cœur en assembleur x86, pas de build arm64 natif) : le Pi ne peut
pas assembler les FINC qu'il produit. C'est TARGET_CODE arm64 qui ferme
la boucle ; CPU_KIND/TARGET_TRAITS l'anticipent (E_MACHINE 183, PAD 0,
CALL_FRAME 16) et, depuis C1, chaque macro de codi_arm64 a une taille
calculable au parse : la table EMITS arm64 est une transcription mot de
32 bits par mot de 32 bits, oracle d'identité byte-à-byte contre
fasmg+codi_arm64 sur les mêmes FINC, puis exécution sur le Pi.

Leçon de méthode : quand deux cibles prennent le même nombre de passes,
l'écart de temps est un coût par ligne et se MESURE statiquement
(lignes interprétées par expansion) avant toute hypothèse sur l'outil ;
et la LLIR étant indépendante de la cible, le diff des FINC entre deux
exécutables de cibles différentes est l'oracle de portage le plus fort
et le moins cher — il a validé d'un coup codi_arm64 sur tout le corpus.
