# PIÈGES — registre numéroté (append-only, numéros stables)

Règle d'usage : tout nouveau piège reçoit le numéro suivant et ne réécrit jamais
les précédents (les renvois « piège n X » figurent dans le code et le journal).
Dernière entrée : n° 66 (5 juillet 2026).


1. Double déréférencement paramètre : `LVa` (pas `La`) pour le doublet.
2. Syntaxe virgules vides : `LIa , , ofs` pas `LIa -1, ofs`.
3. PRM result__ofs toujours en dernier dans PRMS.
4. SD après chaque SYS_FILE_* dans les fonctions MACHINE_CODE.
5. NOT booléen = `LI 1` + `OUX`, pas `NON`.
6. While = `BF`, pas `BRZ`.
7. REGIONS_PATH : condition `>= CUR_LEVEL`.
8. Opérateurs en MAJUSCULES.
9. Ada 83 strict (`-gnat83`).
10. STATOFS arrondi : BOOLEAN 1 bit → 1 octet.
11. DN_RANGE_ATTRIBUTE non géré : contournement FIRST..LAST.
12. Versions sans FILE : déléguer, pas de MACHINE_CODE inline.
13. Fichiers uploadés : toujours post-commit github.
14. **fasmg `dq` hex 64 bits** : tronqué, écrire les octets en `db` LE.
15. **fasmg `movq xmm,[mem]`** : peut être interprété comme movd 32 bits,
    utiliser `movsd` (F2 0F 10/11) pour pile↔xmm.
16. **FCLT/FCLE encodage** : ucomisd xmm1,xmm0 = ModRM 0xC8 pas 0xC9.
17. **CODE_CONVERSION statique** : un LI suivi de CVTIF si cible DN_FLOAT.
18. **OPER_SIZ_CHAR DN_FLOAT** : forcer 'q' (CD_IMPL_SIZE=32 dans 
    mais on stocke toujours en double 64 bits).
19. **CODE_SHORT_CIRCUIT** : était un stub `null`, causait des BF/BT sans
    condition évaluée. Corrigé session 12 avril.
20. **Wrapper générique paramètres** : `Lq` pour tous → `La` pour
    composites et out/in_out. Corrigé session 13 avril.
21. **CODE_BLOCK sans UNLINK** : un bloc `declare` faisait LINK N sans
    UNLINK N correspondant → corruption du display au retour.
    Corrigé session 13 avril.
22. **Propagation out/in_out** : `INVERSE_RECURSE_ON_PARAMETERS` ne
    traitait pas DN_OUT_ID / DN_IN_OUT_ID → message d'erreur au lieu
    de code. Corrigé session 13 avril.
23. **GET_LINE console** : SYS_GET_CHAR en boucle → pas d'écho.
    Remplacé par SYS_GET_STR pour la console. Corrigé session 13 avril.
24. **postpone LIFO** : les CST émises en premier se retrouvent en
    dernier en mémoire. Ordre d'émission inverse requis pour obtenir
    un layout mémoire séquentiel.
25. **XD_REGION des procédures de générique** : pointe vers `DN_GENERIC_ID`,
    pas `DN_PACKAGE_ID`. Ne pas utiliser `SM_FIRST` pour tester.
    (session 15 avril)
26. **Level du wrapper générique** : `CUR_LEVEL - 1` pour accéder aux
    variables de l'instance (GFP_disp, __u_ofs), pas `CUR_LEVEL`.
    (session 15 avril)
27. **Ada 83 strict** : pas de déclarations d'objets après un
    sous-programme imbriqué — utiliser `begin declare ... end`.
    (session 15 avril)
28. **LIVa pour double déréférencement** : quand il faut suivre deux
    niveaux de pointeurs (GFP → patron → champ), utiliser LIVa avec
    DISP et OFS, pas deux `La` séparés. (session 15 avril)
29. **Offset IMAGES dans le patron** : depuis TYPE.SIZ, l'offset vers
    IMAGES.data_ptr est 16 (SIZ:dd=0, FST:dd=4, LST:dd=8, puis
    alignement qword → data_ptr à 16). (session 15 avril)
30. **DN_ITERATION_ID dans INVERSE_RECURSE_ON_PARAMETERS** : les
    variables de boucle `for` ne sont ni DN_VARIABLE_ID ni DN_IN_ID.
    Reconstruire le nom FASM via `LABEL_STR(CD_OFFSET)` + `"_disp"`.
    Corrigé session 25 avril.
31. **Offset GFP hard-codé dans MACHINE_CODE** : chaque procédure du
    modèle a un nombre différent de PRM, donc GFP_ofs est à un offset
    différent (-40 pour PUT/4 params, -24 pour GET/2 params). Ne pas
    copier-coller les offsets entre procédures. (session 25 avril)
32. **CODE_ASSIGN et types formels génériques** : `SM_EXP_TYPE` d'un
    type formel peut être `DN_ENUMERATION` mais avec un `CD_IMPL_SIZE`
    différent du type actuel. Le `else` catch-all avec STORE_OR_CALLI
    couvre les cas non reconnus. (session 25 avril)
33. **`exit when not(A and then B or C)`** : le mélange `and then`/`or`
    dans une même expression est mal compilé par l'expander. Réécrire
    en `if/elsif/else/exit`. (session 25 avril)
34. **`return` dans un bloc `declare`** : CODE_RETURN doit émettre les
    UNLINK intermédiaires avant `BRA ret_lbl` pour chaque niveau entre
    CUR_LEVEL et le niveau de la procédure englobante.
    Corrigé session 25 avril.
35. **Réutilisation de FILE_TYPE après CLOSE/OPEN** : les champs internes
    (AT_END_OF_FILE, HAS_LOOK_AHEAD) doivent être réinitialisés dans
    CREATE et OPEN. Corrigé session 25 avril dans text_io.adb.
36. **Mismatch taille store indirect / variable** : un `SId` (dword)
    sur une variable d'un octet (petite énumération) écrase 3 octets
    adjacents. Résolu par le mécanisme LD/ST via CALLI qui utilise la
    taille correcte du type actuel. (session 25 avril)
37. **Micro-procédures LD/ST dans l'elab_spec** : le code des
    micro-procédures doit être contourné par `BRA post_LD/ST` pendant
    l'élaboration, sinon il corrompt la pile. (session 25 avril)
38. **La vs LIa pour charger l'adresse de ST** : `La , -ENUM__st_ofs`
    (simple) et non `LIa , -ENUM__st_ofs, 0` (indirect). Le contenu
    de __st_ofs est déjà l'adresse de saut. (session 25 avril)
39. **Correspondance miroir PRM/VAR** : les VAR de l'instance doivent
    être dans l'ordre **inverse** des PRM du modèle. Le premier PRM
    (offset 8) correspond à la dernière VAR avant GFP_disp (offset -8).
    (session 25 avril)

40. **`LVa` sur `in` composite dans syscall** : donne l'adresse du doublet
    descripteur, pas des données brutes. Pour les I/O fichier, utiliser
    `ITEM'ADDRESS` comme paramètre explicite `SYSTEM.ADDRESS` et `La 2, -OFS`
    dans la macro LLIR. (session 10 mai (1))
41. **`ITEM'ADDRESS` sur composite écrivait des pointeurs de pile** → **résolu
    (session 10 mai (2))**. Voir section 2.2 : mécanisme `__in_adr_ofs` /
    `__out_adr_ofs` via CALLI dans `CODE_ADDRESS`.
42. **Hexdump cohérent ≠ fichier correct** : READ/WRITE symétriques sur le
    même doublet donnent des résultats corrects en intra-processus mais
    écrivent des pointeurs de pile dans le fichier. Un second processus
    segfaulterait. Toujours vérifier avec hexdump que le fichier contient
    les valeurs attendues, pas des adresses `0x7ffc...`. (session 10 mai (1))
43. **`ITEM'ADDRESS` ne déréférence pas automatiquement le doublet** : dans
    un body générique, `X'ADDRESS` où `X` est un composite passe par
    `CODE_ADDRESS` qui émet `LVa` + CALLI via `__in_adr_ofs` ou
    `__out_adr_ofs` selon le mode du paramètre. (session 10 mai (2))
44. **Asymétrie `in` scalaire vs `out` scalaire pour ADDRESS** : un `in`
    scalaire est passé par valeur (copie locale), `LVa` donne directement
    l'adresse correcte → `__in_adr` = no-op (`RTD 0`). Un `out` scalaire
    est passé par référence (adresse de la destination), `LVa` donne
    l'adresse du slot → `__out_adr` doit déréférencer (`La -1, 0`).
    Ne pas confondre les deux micro-procédures. (session 10 mai (3))
45. **`OPEN` sur fichier inexistant échoue silencieusement** : si
    `ERR_OR_ID < 0`, le FILE_TYPE n'est pas mis à jour et conserve ses
    valeurs par défaut (IS_OPENED=FALSE, MODE=IN_FILE). Toujours utiliser
    CREATE pour créer un nouveau fichier, OPEN uniquement pour un fichier
    existant. (session 10 mai (3))
__DÉSAMORCÉ le 8 juillet 2026__: OPEN → NAME_ERROR, CREATE → USE_ERROR (TEXT14/U6.4). »

46. **Sous-type tableau anonyme partagé + `CD_COMPILED`** : deux objets de contrainte identique (p. ex. deux `STRING(1..6)`) peuvent partager le **même** nœud `DN_CONSTRAINED_ARRAY` en DIANA (vérifiable par le dump : `SM_OBJ_TYPE` identique). Le drapeau `CD_COMPILED` posé par `PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC` fait alors sauter la génération du descripteur local pour le second objet, qui retombe sur le type de base non contraint (`._STRING`) via `XD_SOURCE_NAME` → `use__info` invalide → segfault au déréférencement. Matérialiser un type-info local par objet dès qu’il existe une contrainte anonyme, sans dépendre de `CD_COMPILED`. (session 4 juillet)

47. **Niveau d’émission de la table de thunks générique** : `CODE_GENERIC_ACTUALS` est appelé **après** `INC_LEVEL` sur le chemin d’instanciation de sous-programme ; émettre les `Sa` des thunks et de `GFP_disp` à `CUR_LEVEL` écrit dans le frame du corps de l’instance (niveau N), alors que la relecture se fait à `CUR_LEVEL − 1` (le bloc, niveau N−1) et que le frame N n’existe pas encore / plus au moment de l’élaboration du bloc → écriture dans un frame mort → segfault. Passer un niveau cible explicite : `CUR_LEVEL − 1` pour l’instanciation de sous-programme, `CUR_LEVEL` (défaut historique) pour l’instanciation de package, dont le site d’appel n’est pas précédé d’`INC_LEVEL`. (session 4 juillet)

48. **`endPRO` pour un bloc `declare`** : réutiliser `endPRO` (qui définit `post:` et `loc_siz`, symboles globaux au namespace) pour clore un bloc imbriqué crée une seconde définition de `post:` et casse la résolution du `BRA post` de la procédure englobante → saut au milieu du corps → sortie de frame sur pile non initialisée. Rendre `post`/`elab`/`loc_siz` uniques par routine, ou utiliser une macro de fin de bloc distincte ne définissant pas `post:`. (session 4 juillet)



49. CODE_LENGTH / attributs dimensionnés : tout chemin d'attribut tableau doit lire AS_EXP.
50. Affectation composite : LEN depuis le descripteur DESTINATION ([__u].SIZ/8),
    jamais XD_SOURCE_NAME→_TYPE.size (sous-types anonymes → type de base).
    `LCA name.data_ptr` d'une constante STR = @doublet, pas @data : `La` requis.
51. ACVC classe A = oracle compilation+exécution, PAS de valeurs. La sémantique
    n'est protégée que par les programmes-témoins à sortie attendue et les séries C.
    (Démontré deux fois : A21001A vs affectation muette ; VEC3'RANGE vs boucle vide.)
52. Tout compte d'éléments dynamique → CLAMP0. AMENDEMENT : le motif à traquer est
    « tout calcul de compte », pas la paire textuelle SUB/INC (14e site en ordre
    inversé) — une règle de revue formulée comme un grep hérite des angles morts du grep.
53. Opérateur/nœud non reconnu ne doit JAMAIS ne rien émettre (pile déséquilibrée →
    segfault lointain, symptôme BLKMOV avec pointeur en compteur). Stub équilibré + commentaire.
54. AND/OR/XOR scalaires : macros ET/OU/OUX existaient, dispatch absent. NOT booléen reste LI 1+OUX.
55. Un stub doit respecter le CONTRAT DE NATURE du résultat (scalaire vs @doublet),
    pas seulement l'équilibre de pile — la nature dépend de l'opérateur, pas de l'opérande.
56. CD_IMPL_SIZE porte des bits MINIMAUX (1 pour BOOLEAN, 3 pour 7 littéraux), pas
    la taille de stockage : toute consommation composant arrondit au STORAGE_UNIT.
    (OPER_SIZ_CHAR consomme le brut à bon droit : ≤8 → 'b'.)
57. Les deux COMP_SIZE_BITS homonymes (expressions / types_decls) doivent évoluer
    ensemble — candidates à fusion dans UTILS.
58. CD_LEVEL / CD_COMPILED des types vivent sur le TYPE_SPEC, pas sur le *_ID de
    XD_SOURCE_NAME (qui sert au chemin REGIONS_PATH et au libellé, rien d'autre).


59. **Levée de stub : le stub mort ment.** Remplacer un stub par le code réel en
    LAISSANT le stub en place derrière (copier-coller additif) empile le résultat
    forcé PAR-DESSUS le résultat correct — le consommateur lit le stub, le vrai
    résultat devient un orphelin de pile (violation transitoire du n° 53).
    Symptôme vécu (lot D2) : sept FAUX avec un LEXCMP parfaitement fonctionnel
    en dessous. Règle de revue : après chaque levée de stub, (1) supprimer le
    commentaire-sentinelle du stub dans la source, (2) grepper ce commentaire
    dans le .FASM généré — s'il apparaît encore, le stub est vivant. Corollaire :
    tout stub désormais inatteignable (p. ex. après re-routage amont) se SUPPRIME,
    il ne se commente pas. (session 5 juillet)

60. **Vue contrainte ≠ type de base. Tout test X.TY = DN_RECORD (ou DN_ARRAY) dans l’expander doit se demander où passe la vue DN_CONSTRAINED_RECORD : quatre exemplaires du motif dans ce seul lot (CODE_ASSIGN ×3 branches, CODE_RETURN, CODE_FUNCTION_CALL, tailles statiques). Normaliser vers SM_BASE_TYPE dès l’entrée ; les symboles .size/.SIZ/offsets de la vue anonyme N’EXISTENT PAS, ceux de la base oui.
61. SM_VALUE : deux encodages. Valeur courte : PT = HI et le genre est dans le champ NOTY (= DN_NUM_VAL) ; valeur longue : PT /= HI et le genre est dans TY. Confondre NOTY et TY fait rater la staticité (idiome de référence : expander-expressions lignes ~4563/4689).
62. return "littéral" : SM_EXP_TYPE = DN_VOID. Le type ne vient pas de l’expression ; router sur EXP.TY. La macro STR pose une constante dont le champ data_ptr ouvre un doublet complet : LCA nom.data_ptr = @doublet.
63. Convention résultat composite. L’APPELANT fabrique le doublet anonyme (data+use__info) et empile son adresse comme slot résultat ; la fonction BLKMOV à travers [result__ofs].data_ptr. Un LI 0 de placeholder pour un retour composite = écriture à l’adresse nulle chez l’appelé.
64. **« Pas géré » ≠ « pas connaissable ICI ».** Le refus bruyant (n° 53)
    sanctionne un cas non traité ; il ne doit PAS sanctionner une valeur
    simplement indisponible à ce point du flux mais que l'assembleur, lui,
    résoudra. Cas vécu (C11, ACVC A7) : un tableau à composant record dont
    la vue complète (type privé) n'est pas encore compilée n'a pas de
    CD_IMPL_SIZE — mais le symbole <rec>.size existera plus loin dans le
    même FINC, et fasm est multi-passes. Sortie correcte : émettre le
    symbole (report), pas lever. Même partage expander/fasm que STATOFS,
    size=$, les références avant définition. Test mental : « si je mets ce
    calcul entre les mains de fasm, sait-il finir ? » Si oui, report ;
    sinon seulement, refus. (session 5 juillet)

65. **Chaîne de `if` sans `else` final = trou silencieux latent.** Une
    cascade `if COND_1 … end if; if COND_2 … end if;` qui épuise les cas
    connus SANS clause terminale attrape un cas nouveau en NE FAISANT RIEN
    — la variante dégénérée du n° 53, d'autant plus vicieuse qu'aucun stub
    n'est visible à supprimer. Deux occurrences dans la même campagne :
    CODE_RETURN (trois types non gérés, C7-C8, cf. n° 62-63) et <<UNARY>>
    (le NOT, cf. n° 66). Règle : toute cascade de `if` disjoints sur un
    NODE_NAME ou un OP_STR se termine par une garde `if <aucun des cas>
    then … PROGRAM_ERROR`. Un `case … when others` est structurellement
    préférable quand la langue le permet. (session 5 juillet)

66. **Livraison de fichier COMPLET + copie projet en retard = écrasement
    silencieux des correctifs locaux.** Régression vécue : le NOT scalaire,
    restauré localement par le mainteneur, réécrasé à CHAQUE intégration
    d'un fichier entier bâti sur une copie projet datée (elle-même sans
    C12/C13 en début de session — le décalage était mesurable). Symptôme
    différé de deux semaines, invisible tant qu'aucun témoin n'exerçait le
    NOT sous auto-jugement. Parades, par ordre de préférence : (1) livrer
    des INSTRUCTIONS de patch (emplacement, ancre, bloc, motif) que le
    mainteneur applique et RELIT — il est l'élément lent qui voit ;
    (2) à défaut, diff-er tout fichier complet contre la version locale
    AVANT écrasement ; jamais d'intégration en aveugle. Corollaire :
    rafraîchir les sources projet juste avant chaque lot. (session 5 juillet)

67. **Offsets `virtual at 4` à travers le `__u` d'un type NON contraint =
    lecture hors bloc.** Le bloc info d'un type non contraint ne réserve que
    `use__info` et `SIZ` (:= -1, sentinelle correcte) ; les COMP_SIZ/FST/LST
    n'y sont que des OFFSETS sans mémoire. Tout `LId __u, _TYPE.FST_1` dont le
    `__u` pointe encore sur ce bloc lit les VARs voisines du frame — des
    adresses de pile. Signature comportementale caractéristique : sous ASLR,
    blocage (boucle géante) au 1ᵉʳ run, échec PROPRE au 2ᵉ — le
    non-déterminisme entre exécutions EST le témoin de la lecture hors bloc,
    et sa disparition la preuve du correctif. Règle : un objet dont le
    SM_OBJ_TYPE est DN_ARRAY (ou DN_RECORD mutable un jour) doit TOUJOURS
    re-pointer son `__u` vers un bloc contraint (anonyme ou du sous-type)
    avant toute consommation ; le prélude commun qui pose `__u := use__info
    du type` n'est qu'un provisoire à écraser (précédent : littéral chaîne).
    (session 6 juillet)

68. **Après un correctif systémique, l'unique rouge résiduel se suspecte
    d'abord côté ORACLE.** Vécu sur ARRAY_TEST3 : neuf échecs + un blocage
    ramenés à un seul foyer (doublet VC/VD) ; le correctif en a éteint huit
    d'un coup, le neuvième (7.3) était un mensonge du test lui-même
    (`LONGUEUR(VD) = 4` pour un agrégat à trois composants). Un compilateur
    juste contre un oracle faux reste rouge indéfiniment. Règle de revue :
    quand la chaîne causale d'un diagnostic prédit la chute GROUPÉE des
    échecs, tout survivant isolé se re-vérifie à la main dans la source du
    test avant de rouvrir l'expander. (session 6 juillet)
    
    69. **UNLINK prend un NIVEAU, pas un compte.** CODE_EXIT émettait
    `UNLINK CUR_LEVEL+1-EXITED_LOOP_LEVEL` — un compte passé à une macro qui
    fait `FP_IN_RBP lvl`. Coïncidence numérique juste pour UN bloc traversé
    depuis le niveau 1, faux dès deux (un seul UNLINK émis, mauvais niveau).
    Corrigé en boucle par-niveau, forme de CODE_RETURN ; témoin exc_test1 §3
    (exit à travers deux blocs protégés). (session 7 juillet)

70. **R14 monotone est PORTEUR — interdiction de « corriger » UNLINK.**
    La branche tableau de CODE_RETURN copie `data_ptr` (16 octets d'info),
    pas les données : le retour de tableau est PAR RÉFÉRENCE, la donnée vit
    dans la co-pile du frame appelé et se consomme APRÈS son UNLINK. C'est
    parce qu'UNLINK ne redescend pas R14 que ça marche. Ajouter
    `mov r14, r13` ferait pendre chaque `return S1 & S2`. Contrepartie
    consignée : la co-pile ne se reprend JAMAIS en flux normal — un CO_VAR
    en boucle fuit (budget 1 Mo). Seul point légitime de redescente : la
    restauration du déroulage d'exception, couverte par l'invariant de
    frontière d'instruction (tout @co-pile au-dessus de la photo est mort).
    Refonte éventuelle = pilier « retours composites par copie », pas un
    patch. (session 7 juillet, audit Q2)

71. **diana_NODES.txt ne fait pas foi — le dump seul fait foi.**
    `sm_renames_exc :NAME` d'après la grammaire ; sem y met l'EXCEPTION_ID
    CIBLE directement (dump exc_ren0). Deuxième divergence constatée après
    le design EXL/CD_LABEL fantôme. Toute modélisation d'attribut passe par
    un dump du témoin AVANT le code ; les deux fois où la règle a été
    suivie, le dump a contredit l'hypothèse. (session 7 juillet)
    Appendice n° 71 (11 juillet, E-D6) : la règle vaut aussi pour les
  IDIOMES : un idiome LLIR donné DE MÉMOIRE ou en paraphrase au lieu
  d'une citation de l'émetteur a coûté une session de débogage (le
  « La GFP » de GENERIC_FIRST_LAST perdu dans le résumé — pile
  décalée d'un cran). Citer l'émetteur, jamais le résumer. Corollaire
  du n° 71 : quatre sur quatre.

72. **Renames d'exception = identité PARTAGÉE, jamais de nouvelle STR.**
    LRM 8.5 : même entité. Émettre une STR au rename crée une identité
    distincte → handlers inopérants à travers le renommage. Traitement :
    alias d'assemblage au site de déclaration (namespace local dont
    `data_ptr` VAUT celui de la cible directe ; les chaînes composent,
    fasmg résout) — fondé sur la STRUCTURE (AS_NAME) + SM_DEFN seulement,
    robustes au rechargement DCL. Toute manipulation d'un nom d'exception
    passe par CODI.EXCEPTION_ID_OF (descente DN_SELECTED — qui n'a PAS de
    SM_DEFN propre — puis chaîne SM_RENAMES_EXC sous ses deux formes),
    jamais par un SM_DEFN nu. (session 7 juillet)

73. **Les includes d'un FINC de corps viennent de XD_WITH_LIST, pas du
    contexte textuel.** Le corps ré-élabore son spec inline (elab_spec:)
    mais son texte ne porte pas les `with` du spec — symboles indéfinis à
    l'assemblage. XD_WITH_LIST est la fermeture transitive (dump text_io) ;
    passe CODE_TRANS_WITH_INCLUDES, exclusions : _STANDRD (wrapper) et le
    spec propre (nœud TW_COMP_UNIT = XD_PARENT + test de nom). Nom pris au
    SYMREP de l'unité, pas à TW_FILENAME. Gardes `if ~ definite` =
    doublons inoffensifs. (session 7 juillet)

74. **Fossiles réveillés : tout raise de bibliothèque était un no-op avant
    le pilier 11.** L'ancien CODE_RAISE (`null;`) faisait tomber
    l'exécution À TRAVERS les gardes — TEXT_IO a tourné depuis l'origine
    avec des fichiers  jamais ouverts (IS_OPENED jamais posé,
    DEFAULT_IN/OUTPUT jamais affectés) et des gardes en décoration. Règle
    de tri : tout `EXCEPTION NON RATTRAPEE : X` du filet est une DETTE DE
    BIBLIOTHÈQUE rendue visible, pas une régression du pilier — la
    sentinelle nomme l'exception, le grep des gardes localise. Précédents :
    fichiers  TEXT_IO (corrigé), END_ERROR DIRECT_IO/SEQUENTIAL_IO (session 7 juillet témoins à l'ancien contrat, cf. piège n° 79 — reprise planifiée).
 
75. **`raise;` nu ≠ la globale (LRM 11.3) — sauvegarde par ACTIVATION.**
    Le re-raise relève l'exception qui a causé le transfert AU handler
    englobant le plus interne ; or EXCEPTIONS_CURRENT est clobberée par
    tout raise intermédiaire TRAITÉ (bloc interne ou appel qui rattrape
    chez lui). Solution : à l'entrée du dispatch, copier la globale dans
    PREV_CTX (+0) du contexte — champ MORT depuis le pop, par incarnation
    (récursion couverte), aucun restore nulle part. Corollaires : le
    drapeau HANDLER_CTX_AT(L) n'est vrai que pendant les stms protégés
    (un return depuis un HANDLER ne pope pas — contexte déjà dépilé) ; le
    fond de dispatch, lui, propage bien la globale (aucun handler n'a
    couru). Témoins adversariaux exc_test1 §10.2/10.3. (session 7 juillet)

76. **Un nom de symbole émis en deux endroits se FABRIQUE par une fonction
    unique appliquée à une valeur partagée — jamais reconstruit deux
    fois.** Vécu : contexte `exc_ctx_L57` déclaré par CODE_BLOCK_BODY et
    référencé par CODE_RAISE — l'espace de tête d'`'IMAGE` ou un préfixe
    doublé (`exc_ctx_LL57`) guettent toute reconstruction. Faire circuler
    le NUMÉRO (LABEL_TYPE) et composer par LABEL_STR des deux côtés.
    (session 7 juillet)

77. **Actual out/in out qui est un composant indexé (ou sélectionné) :
    le fallback de CODE_PROCEDURE_CALL l'émettait en rvalue.** Le Lb
    final de CODE_EXP remplace l'adresse calculée du composant par sa
    valeur ; l'appelé (convention scalaire out = par référence) écrit à
    travers cette pseudo-adresse — écriture sauvage, segfault à
    retardement ou corruption silencieuse d'une variable voisine. La
    branche DN_INDEXED doit tester le mode du formel comme le fait déjà
    DN_VARIABLE_ID : in → CODE_EXP (correct pour scalaire chargé ET
    composite qui laisse @), out/in out → CODE_OBJECT_ADDRESS (adresse
    seule). Jumeau DN_SELECTED scalaire dans le même dispatch
    (IS_SOURCE => FALSE). Témoin de verrouillage OUTARG1 (indexé,
    sélectionné, indice calculé, boucle sur composant d'un formel non
    contraint). Détecté par TEXT14P/P14 sur le GET(STRING) public de
    TEXT_IO. (session 8 juillet)

78. **« Validé » ne veut pas dire « exercé » : recenser les chemins que
    personne n'emprunte.** Le chemin de lecture sur fichier réel de
    TEXT_IO (OPEN + GET par descripteur, FILE.ID >= 0) n'avait JAMAIS
    tourné depuis l'origine : tous les témoins de lecture passaient par
    la console redirigée (`< fichier`, chemin ID = -1). Le fossile n° 77
    dormait dans le seul appel de cette forme du corpus, sur ce chemin
    mort. À l'ouverture d'un chemin neuf, une sonde à marqueurs
    séquentiels (modèle TEXT14P : un marqueur APRÈS chaque étape, le
    dernier affiché = dernière étape réussie) localise le point de chute
    en une exécution, avant toute spéculation. (session 8 juillet)

79. **END_OF_FILE et END_OF_PAGE ne voient pas à travers les
    terminateurs (un seul caractère d'anticipation).** Depuis que le GET
    public lève END_ERROR au terminateur de fichier, l'idiome
    `while not END_OF_FILE loop GET(char)` lève END_ERROR sur les
    terminateurs de queue d'un fichier fini par PUT_LINE (END_OF_FILE
    peek le CR → FALSE, le GET suivant traverse CR LF et tombe sur la
    fin). Idiomes sûrs : ligne à ligne (GET_LINE + END_OF_FILE), ou
    boucle GET protégée par un handler END_ERROR. Même limite pour
    END_OF_PAGE derrière un CR LF non consommé. Remède complet =
    FILE_TYPE descripteur partagé à tampon (chantier non planifié).
    Premier suspect des échecs DIRECT_IO_TEST/SEQ_IO_TEST du filet du
    8 juillet. (session 8 juillet)

80. **Dans un corps générique, le slot résultat d'une fonction est à
    -8(N+2), pas -8(N+1) : le PRM GFP_ofs s'intercale entre les
    paramètres et result__ofs** (CODE_PARAM_S, drapeau IN_GENERIC_BODY,
    expander-declarations.adb l. ~152-161). Un `SD` au mauvais cran
    écrit dans le slot GFP et laisse le résultat à sa valeur résiduelle
    de pile — fossile invisible tant que le raise aval était un no-op
    (corollaire du n° 74). Vécu : les 4 wrappers syscall à 3 paramètres
    de DIRECT_IO et SEQUENTIAL_IO (`SD -32` au lieu de `-40`) ;
    BYTES_READ en garbage → END_ERROR spurieux au premier READ, données
    pourtant correctement lues depuis l'origine. Les wrappers à 1 et
    2 paramètres étaient justes — le décompte a glissé au passage à 3.
    Règle de contrôle : dans un corps générique, result__ofs =
    -8(nombre de paramètres + 2). Verrous : DIRECT_IO_TEST v2 §8.3 et
    SEQ_IO_TEST v2 §6.2 (élément tronqué : lecture partielle non nulle,
    la branche exacte `BYTES_READ < SIZE_BYTES`). (session 9 juillet)

81. **POP inconditionnel en tête d'une récursion sur séquence DIANA :
    la garde IS_EMPTY qui protège la récursion ne protège pas le
    premier appel.** Vécu : CODE_GENERIC_FRAME_OFFSETS sur un générique
    SANS formels (`GENERIC PROCEDURE P;` — légal) ; le POP d'ouverture
    fait HEAD sur séquence vide → PROGRAM_ERROR idl_man « TETE DE
    SEQUENCE SEQ.FIRST = TREE_NIL ». Règle : tout POP d'ouverture se
    garde lui-même par IS_EMPTY ; ici on n'émet plus du tout le bloc
    `virtual at 8` vide. Détecté par A83009B. (session 9 juillet)

82. **Appel à travers une chaîne de renamings de sous-programme : nom,
    label ET chemin de région doivent TOUS venir de l'origine.** Un
    renaming (SM_UNIT_DESC = DN_RENAMES_UNIT) n'a pas de corps — label
    attribué par CODE_SUBPROG_ENTRY_DECL mais aucun PRO n'existe.
    SUBPROGRAM_ORIGIN (expander-utils) suit AS_NAME.SM_DEFN maillon par
    maillon (dump : pas de raccourci sem ; arrêt sur SM_UNIT_DESC
    void). Résolution partielle = symbole hybride (`PROC3_L7` : nom de
    l'appelé, label de l'origine). Les défauts du profil du renaming
    sont déjà matérialisés par SM_NORMALIZED_PARAM_S — ne rediriger que
    la cible. Non traité : chemin fonction et actuels génériques qui
    seraient des renamings. Détecté par A85013B. (session 9 juillet)

83. **L'assemblage paresseux (`if defined X_`) n'est armé que par la
    macro CALL : toute autre référence à `X.elab` laisse le corps non
    assemblé.** Prendre l'adresse d'un sous-programme par un LCA nu
    (actuels génériques) → « symbol X.elab is undefined » dès que X
    n'est CALLé nulle part directement. Macro LSPA (Load SubProgram
    Address) : même postpone d'armement que CALL + empilement de
    l'adresse ; émise par ACTUAL_SUBPROGRAM avec chemin absolu
    REGIONS_PATH (la résolution relative de l'ancien LCA ne marchait
    que par co-localisation). Règle : adresse de sous-programme = LSPA,
    jamais LCA. Détecté par A87B59A (six occurrences d'un coup).
    (session 9 juillet)

84. **REGIONS_PATH à travers une région générique de sous-programme :
    `generic_id` ne porte pas CD_LABEL (schéma DIANA), et le namespace
    physique est le PRO étiqueté du corps (`P_Lxx`).** XD_REGION des
    locaux d'un corps générique = le GENERIC_ID lui-même (dump MINIG) ;
    le chemin émis « P. » sans label ne correspond à aucun namespace.
    Label à récupérer via D(AS_SOURCE_NAME, D(XD_BODY, REGION)) —
    XD_BODY, pas SM_BODY (absent du dump). Les génériques de PACKAGE
    gardent leur namespace NON étiqueté (discriminer par SM_SPEC).
    Réserve : corps en sous-unité (xd_stub) non vérifié. Corollaire :
    pour un objet du frame COURANT, émettre le nom relatif (niveau =
    CUR_LEVEL) plutôt qu'un chemin absolu — toujours valide, immunisé.
    Détecté par A87B59A (BLKMOV, lecture du descripteur destination).
    (session 9 juillet)

85. **CODE_SELECTED : variable COMPOSITE nommée à travers un préfixe
    package — la base n'était jamais poussée.** La branche
    DN_VARIABLE_ID de PROCESS_DESIGNATOR ne traitait que le scalaire ;
    pour PACK1.ARG1.<champs> (record), rien n'était émis et les
    `LVA ,offset` de la chaîne s'additionnaient sur pile vide → Ld sur
    adresse poubelle, segfault. Fix : La lvl + REGIONS_PATH + `_disp`
    (chemin absolu obligatoire, la variable vit dans le namespace du
    package). Jumeaux consignés NON exercés : la branche scalaire du
    même endroit émet le nom NU sans REGIONS_PATH (`PACK1.SCALAIRE`
    casserait à l'assemblage) ; un package imbriqué dans le préfixe
    transite par le else « PAS FAIT » (commentaire inoffensif, le
    chemin absolu couvre). Détecté par A83C01G (composants homonymes
    de packages). (session 9 juillet)

86. **Macro fasmg inconditionnelle « ! » : indispensable pendant une
    capture (struc/postpone laissée ouverte), fatale dans un `if`
    faux — exigences irréconciliables.** Le « ! » a la sémantique de
    `end if` : interprété même dans un bloc sauté. Une split-macro dont
    la seconde moitié ferme une capture ouverte par la première DOIT
    être « ! » (sinon elle est avalée comme texte)… et explose
    (`end postpone` orphelin, « unexpected instruction ») dès que la
    paire vit sous un `if defined` faux — aucun flag ne peut aider, le
    déséquilibre est syntaxique, avant toute évaluation. Remède : ne
    JAMAIS capturer entre deux macros ; données inline sautées par BRA
    (pattern des thunks LD_/ST_, prouvé sous les gardes), tailles par
    différence d'étiquettes résolue au multipasse. Un `postpone /
    end postpone` COMPLET sur lignes brutes reste, lui, sain dans un
    if faux (sauté en bloc). Vécu : BEGIN/END_BLOC_DEF, énuméré déclaré
    dans un sous-programme jamais appelé (A83009A/B).
    (session 9 juillet)

87. **Les postpones fasmg s'exécutent en LIFO — tout contrat
    d'adjacence mémoire fondé sur leur ordre d'enregistrement est
    invisible et fragile.** L'ancien BLOC_DEF construisait le layout
    ENUM_USE_INFO étendu — SIZ@0, FST@+4, LST@+8, doublet images @+16,
    consommé EN DUR par GET_ENUM_IMAGES de TEXT_IO (LIVa __u+16) — par
    l'ordre d'enregistrement de cinq postpones ; l'ordre d'émission des
    CST (LST, FST, SIZ) était le miroir du LIFO. Un grep symbolique ne
    voit pas ce consommateur : chercher AUSSI les offsets en dur côté
    runtime Ada (ASM_OP_x). Le contrat est désormais posé en clair et
    d'un seul tenant par END_BLOC_DEF siz,fst,lst ; gardien :
    ENUM_TEST. (session 9 juillet)
    
88. **L'oscillation rel8/rel32 sous alignements  (non-convergence
  fasmg A54B01A/02A/A35801E, déclenchée par le correctif n° 81). Les
  macros de branchement qui re-décident leur taille à chaque passe sur
  le `disp` de la passe précédente convergent tant que le système est
  monotone ; les ALIGNEMENTS introduisent une dépendance anti-monotone
  (du code en plus peut faire tomber du padding) et ouvrent des cycles
  sans point fixe. Symptôme : « could not generate code within the
  allowed number of passes » sur quelques exécutables seulement, après
  une modification anodine. BRA avait déjà été forcé rel32 pour cette
  raison (branche rel8 commentée — la trace était dans codi) ; BT/BF
  ont suivi quand le pilier checks a multiplié leur population près de
  la frontière ±127. Règle : toute décision de taille inter-passes doit
  être MONOTONE (verrou qui ne fait que s'élargir) ou supprimée.

88. **L'actuel constant scalaire fantôme (fossile A54B02A, exhumé
  par le check E-A). Dans CODE_PROCEDURE_CALL, la branche
  DEFN = DN_CONSTANT_ID ne traitait qu'énuméré et tableau : une
  CONSTANTE INTEGER/FIXED/FLOAT en position d'actuel direct n'était PAS
  ÉMISE — retombée silencieuse (violation type du n° 53). Le callee
  lisait ses paramètres un cran trop profond et RTD rendait une cellule
  périmée. Conséquence historique : REPORT.EQUAL(REC_LIMIT, …) faux →
  IDENT_INT ≡ 0 depuis l'origine — invisible car la série A de l'ACVC ne
  vérifie aucune valeur et les CASE à couverture totale absorbent tout.
  Leçons : (a) chaque retombée silencieuse restante est un n° 81 en
  puissance — le else bruyant n'est pas du confort, c'est du diagnostic ;
  (b) un harnais de test dont on ne vérifie jamais les valeurs (IDENT_*)
  peut être inerte sans bruit ; (c) le même objet peut être émis
  correctement comme opérande et perdu comme actuel — les chemins
  d'émission diffèrent, tester les DEUX positions.
   
89. ** (11 juillet, mainteneur) : la sous-hypothèse
  « bornes des prédéfinis de  jamais élaborées » était FAUSSE —
  _STANDRD.FINC les élabore (stores SHL/NEG/SUB vers FST/LST, exécutés
  en tête de flux, avant le LINK 0 mais avec FP(0) déjà posé par
  l'init). Elle reposait sur l'attribution de la levée A54B02A au site
  I contre _INTEGER ; le n° 81 a montré que la levée venait du site J
  (IDENT_INT ≡ 0 → 0 < FST). La garde d'élision du n° 80 et la dette
  (a) — contraintes anonymes non contrôlées — restent valides.
  LEÇON DE TRIAGE : quand une cause plus profonde est découverte,
  ré-auditer systématiquement quelles observations les hypothèses
  antérieures expliquent ENCORE. Ici : plus aucune. Une dette fantôme
  a vécu un jour de trop faute de ce ré-audit.
  
 90. ** La pile d'évaluation pré-LINK piétine la VARzone** (trouvé
  par CHK_PREDEF0 : BOOLEAN'LAST = débris via use-info, INTEGER et
  CHARACTER justes). L'élaboration de _STANDRD s'exécutait avant le
  LINK 0 : RBP = FP(0), les poussées d'évaluation écrivent sur les
  premières cases de la VARzone — tout store précoce (~2 premiers
  qwords) est écrasé par les élaborations suivantes. _BOOLEAN.use__info
  était dans la zone ; la sentinelle du pilier 11, réinitialisée après
  le LINK par le wrapper, était guérie sans le savoir — ce qui a masqué
  le piège. Correctif : LINK 0 AVANT l'include de _STANDRD. Leçons :
  (a) un invariant de machine à pile (« les poussées vont au-dessus des
  frames ») ne vaut que si le frame est ALLOUÉ ; (b) la signature
  « premiers éléments faux, suivants justes » désigne une zone de
  recouvrement, pas une donnée fausse ; (c) le témoin qui imprime les
  VALEURS (CHK_PREDEF0) a trouvé en trois lignes ce qu'aucun test de
  déroulement ne pouvait voir — même famille de leçon que le n° 81.
  
 91. ** Adaptateur OUTADR sur locale de corps partagé — la double déréférence lit la valeur comme adresse ; le test VC_ID.TY = DN_IN_ID copié d'un site paramètre était toujours faux sur un VC ». Corollaire d'invariant : push d'adresse destination ⇔ CALLI-ST, un seul prédicat (ST_VIA_CALLI).
  
 92. **  double émission 'DIGITS (le CODE_FLOAT_DIGITS résiduel après le bloc declare) — fuite de pile par attribut, bénigne en élaboration, fatale en corps.
 
 93. **La double émission d'attribut** (segfault FLOAT_IO.PUT, 11
  juillet). Le bloc declare ajouté pour 'DIGITS (SM_ACCURACY) avait
  laissé le CODE_FLOAT_DIGITS historique APRÈS le end : chaque T'DIGITS
  poussait DEUX valeurs, une consommée, une orpheline. En élaboration
  la fuite est bénigne (fond de pile, tout le relatif reste cohérent —
  le filet ne voit RIEN) ; dans un corps, le premier appariement
  adresse/valeur qui suit (SIq, CALLI) est décalé d'un slot → store à
  travers un motif de bits → segfault loin de la cause. Règle : un
  chemin d'attribut émet EXACTEMENT une valeur ; symétriquement, un
  chemin muet (le null de 'DELTA) est le même bug en sens inverse.

 94. **OUTADR sur locale de corps partagé** (le segfault, cause
  racine ; lot n° 84 incomplet). Dans CODE_VC_ID, le sélecteur
  d'adaptateur testait VC_ID.TY = DN_IN_ID — copie d'un site
  PARAMÈTRE, toujours faux sur un VC (VARIABLE/CONSTANT_ID) : toutes
  les locales de type formel prenaient OUTADR (une déréférence de
  trop) ; la valeur flottante était lue comme une adresse. INTEGER_IO
  n'a aucune locale NUM relue (preuve par zéro au grep) — les témoins
  du n° 84 ne pouvaient pas le voir ; FLOAT_TEST (avril, hors filet
  depuis) le voyait en trois lignes. Correctif systémique : prédicat
  unique ST_VIA_CALLI = IN_GENERIC_BODY et FORMEL et (OUT ou IN_OUT),
  partagé entre les pushes d'adresse destination et STORE_OR_CALLI —
  l'adresse n'est empilée QUE si elle sera consommée. Leçon : quand
  un idiome a deux moitiés (préparer/consommer), UNE condition, pas
  deux copies.

 95. **L'identité en DIANA ne se teste pas par égalité de nœuds**
  (famille, trois membres, pilier fixed). (a) L'ABSENCE d'un attribut
  ne se compare pas à UNE sentinelle : TREE_VOID et TREE_NIL
  coexistent — tester la propriété visée (ici : opérandes DN_FIXED),
  pas le vide. (b) Un même NOM vit sous DEUX espèces : DN_SYMBOL_REP
  (déclaration du formel) et DN_TXTREP (préfixe d'attribut) — même
  graphie NUM, nœuds jamais égaux ; l'identité nominale se juge par
  PRINT_NAME (clés-chaînes de la table formel→actuel). (c)
  SM_IS_ANONYMOUS vaut TRUE sur un sous-type NOMMÉ — le drapeau ne
  discrimine pas l'anonymat, XD_SOURCE_NAME fait foi (cohérent n° 80).

 96. **Le « A FAIRE » qui rend la main corrompt** (élaboration _T34,
  dump F-1). CODE_STATIC_FIXED_VALUE sur small à NUMER≠1 : commentaire
  + return — mais l'APPELANT émettait quand même son Sq FST : store
  depuis une pile jamais alimentée, FST/LST = débris. Doublé d'un trou
  SILENCIEUX voisin : CODE_NUMERIC_LITERAL lisait NUMER_SMALL puis
  l'IGNORAIT (« HYPOTHESE NUMER_SMALL = 1 ») — D := 6.0 sur small 3/4
  donnait 24 au lieu de 8, sans un mot. Règle : un chemin incomplet
  COMPLÈTE ou LÈVE (la garde F-A est le modèle) ; un commentaire
  d'hypothèse dans le source est un n° 53 en sursis — le transformer
  en ANOMALIE exécutable ou le solder.

 97. **La garde d'inclusion asymétrique** (conflit PRMzone, premier
assemblage d'ADA_COMP, 12 juillet). Les with émettent
if ~ definite X / include X.FINC — mais qui définit X ? Les
packages, oui (PACK_NAME = 'PACK_NAME' en tête de FINC) ; les
unités génériques, NON : leur FINC restait indéfiniment
« ~ definite », donc ré-inclus à chaque with — et même deux fois
dans la MÊME unité (CODE_WITH_CONTEXT puis fermeture transitive).
Aggravant : le FINC d'UNCHECKED_CONVERSION contenait un corps
compilé du MODÈLE (PRO UNCHECKED_CONVERSION_L1), code mort
depuis l'expansion inline des instances, et NON gardé — le
if defined name_lbl_ de CODE_SUBPROGRAM_BODY n'est émis que si
ENCLOSING_BODY /= VOID, jamais au niveau bibliothèque. Deuxième
inclusion → réouverture du namespace → redéfinition de
PRMzone:: (un label d'espace d'adressage ne se définit qu'une
fois). Règle : toute unité incluse via if ~ definite X DÉFINIT
X en première ligne de son FINC — la garde et sa clé sont les
deux moitiés d'UN idiome (même famille que le n° 94 : une
condition, pas deux copies). Corollaire : le FINC d'un modèle
générique de sous-programme ne contient JAMAIS de corps — les
instances sont expansées sur site.

 98. **Garde d'inclusion asymétrique** (UNCHECKED_CONVERSION) 
 99. **La staticité des bornes vit en UN exemplaire** (STATIC_BOUND_VALUE), le test de propriété ne vaut que là où la lecture est licite (l'espèce fixe ses attributs, USED_NAME ≠ USED_OBJECT), un cache de taille se teste par « connue et positive », et le pliage statique appartient à sem (LRM 4.9) — le filet expander est une dette localisée, pas une architecture.
 
 100. **XD_REGION d'un composant peut être DN_PRIVATE_TYPE_ID** (records
  représentés dérivés, session bootstrap). La garde « OWNER.TY =
  DN_TYPE_ID » de FIND_COMP_REP_ELEM_FROM_COMPONENT rejetait les
  discriminants hérités d'un type PRIVÉ dérivé (new TREE) → branche
  offset sur un record représenté → symbole fantôme. REGIONS_PATH
  acceptait déjà PRIVATE/L_PRIVATE_TYPE_ID : quand un consommateur de
  XD_REGION énumère les espèces, s'aligner sur la liste de
  REGIONS_PATH. Corollaire verrouillé dans COMPILE_RECORD_VAR : un
  record représenté n'exporte AUCUN offset — comp_rep introuvable ⇒
  LÈVE, jamais la branche offset.

 101. **`_disp` et `_ofs` ne se mélangent pas dans un corps générique.**
  `X_disp` = physique côté INSTANCE (VAR) ; `X_ofs` = constante
  d'accès relative au GFP (bloc virtual de
  CODE_GENERIC_FRAME_OFFSETS), seul nom légal dans le corps :
  `La n,-GFP_ofs` puis `LVA ,-X_ofs`. LOAD_MEM écrivait `-X_disp`
  (deux lignes, scalaire et composite) — l'erreur fasmg ressemble à
  un défaut REGIONS_PATH mais le chemin est bon, seul le suffixe ment.

 102. **TYPE_INFO_STR : contrat d'argument, et la regex qui le viole**
  (extension du n° 99). Le helper prend un TYPE_SPEC (descente
  XD_SOURCE_NAME) ou, version généralisée, un TYPE_NAME (retour
  direct : un nom du source n'est jamais anonyme) ; tout le reste —
  en particulier un DN_SYMBOL_REP — LÈVE. La substitution mécanique
  `'_' & PRINT_NAME( X ) → TYPE_INFO_STR( X )` passe le symrep dans
  100 % des cas (X était `D( LX_SYMREP, ... )`). Forme B légitime à
  NE PAS convertir vers le spec : bornes de sous-types scalaires
  (CODE_SCALAR_SUBTYPE_FIRST_LAST) — le nom AU SITE fait foi, l'alias
  canonique du spec peut différer.

 103. **Un sous-programme de bibliothèque withé s'inclut comme un
  paquetage.** CODE_WITH_CONTEXT (DN_PROCEDURE_ID/DN_FUNCTION_ID) et
  CODE_TRANS_WITH_INCLUDES doivent émettre la garde d'include ; et la
  tête de FINC d'une unité sous-programme doit porter `X = 'X'`
  (convention n° 97 — était réservée aux paquetages/génériques).
  Sinon : CALL émis, `X_L1.elab` jamais défini. Dette active :
  CD_PARAM_SIZE := 0 posé en aveugle par la branche with — faux dès
  qu'un sous-programme withé aura des formels (garde à poser).

 104. **Expression universelle en `return` = type de RETOUR, pas type
  de l'expression.** `return ADDR_SIZE;` (nombre nommé) →
  DN_UNIVERSAL_INTEGER, hors CLASS_SCALAR. Repli : universel ⇒
  FULL_VIEW du sous-type de retour. ET le caractère de store vient de
  ce type : EXP_TYPE_CHAR sur un universel répond 'b' (CD_IMPL_SIZE
  absent) — Sb dans un slot résultat relu en d = 24 bits de bruit,
  silencieux. Deux corrections indissociables.

 105. **Le pliage de constante doit consulter IS_SOURCE** (renames,
  élaboration). Dans PROCESS_DESIGNATOR, la branche
  CONSTANT/NUMBER/ENUM émettait `LI valeur` même en contexte ADRESSE
  (CODE_OBJECT_ADDRESS → IS_SOURCE=FALSE) : le slot pointeur du
  renommage recevait la valeur (déréférencement de 9 au premier
  usage). Constante : LVa + REGIONS_PATH + _disp (le stockage existe
  dans _STANDRD). Nombre nommé / littéral d'énumération : PAS des
  objets, pas d'adresse ⇒ LÈVE. Bug frère au même endroit : l'usage
  du renommage émettait le _disp SANS REGIONS_PATH — un namespace
  FRÈRE n'est pas trouvé par la remontée fasmg (seuls les parents le
  sont) : l'absence de chemin n'est tolérable qu'intra-région.

 106. **fasmg est multi-passes : les displays se rejouent.** La
  répétition de la liste d'includes = passes successives, pas une
  ré-inclusion (les gardes `~ definite` agissent AU SEIN d'une
  passe). Diagnostic de convergence : suivre `push_pop_rax_count`
  par passe — répétition = convergence proche ; oscillation =
  optimisation dont la décision dépend des adresses qu'elle modifie
  ⇒ la rendre MONOTONE entre passes (un verdict « non élidé » ne se
  reprend pas), quitte à laisser des octets. Consigner le nombre de
  passes du premier assemblage réussi comme référence.

  Lecture de trace acquise (2 occurrences décisives) : la pile de
  macros de l'erreur fasmg désigne l'ARGUMENT fautif — `macro LId /
  macro FETCH_DWORD : if disp = 0` ⇒ c'est le 3e opérande (offset)
  qui est indéfini, le 2e (base) a déjà été consommé par
  INDIRECT_BASE_IN_RAX. Trancher par la pile avant de soupçonner un
  opérande.

 107. **Tableau indexé par MARQUE de type énuméré : bornes jamais
  émises.** Le chemin sans INDEX_CONSTRAINT de
  PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC ne traitait que DN_INTEGER ;
  DN_ENUMERATION tombait dans le else-commentaire → _FST_1/_LST_1
  restaient à 0 (VAR zéro-initialisées). Signature : indice 0 passe,
  indice 1 lève CONSTRAINT_ERROR. Fix : STATIC_BOUND_VALUE sur les
  bornes de SM_RANGE (SM_REP), repli CODE_EXP. Les plages explicites
  `range A..B` passaient déjà par HAS_RANGES, seules les marques de
  type étaient touchées.

 108. **Énumérés sur conteneur octet/word : charge SIGNÉE.** La
  branche énumérée d'IS_UNSIGNED_TYPE était commentée (pas de
  sm_representation dans diana.idl, D stricte — cf. 95a) → Lb au lieu
  de ULb. Signature : tout marche jusqu'à 'VAL(128), relu -128, échec
  du check FST. Fix : SM_REP du PREMIER littéral du type de BASE ≥ 0
  (RM83 13.3 : codes croissants → premier = minimum) ; couvre la
  clause de représentation sans l'attribut absent. Corrige au passage
  CHARACTER ≥ 128 (Latin-1 des sources !).

 109. **La co-pile est un bump allocator MONOTONE : UNLINK ne
  redescend jamais R14.** Fuites : 8 octets par appel (slot ELB) +
  tous les CO_VAR (concat, IMAGE, agrégats dynamiques). Budget =
  p_memsz (l. 2138 finc), franchi → segfault sur le `mov [r14],r13`
  du prochain ELB (PC entre PRO et zone VAR — signature). Palliatif
  en place : 64 Mio. INTERDIT de « corriger » UNLINK par r14:=r13 :
  les résultats de fonctions à taille non contrainte vivent dans la
  frame co-pile du callee et doivent survivre au retour. Vrai fix
  différé : mark/release DANS L'APPELANT au niveau instruction
  (= secondary stack GNAT) ; intermédiaire possible : épilogue
  libérant pour les procédures seulement. Même famille dormante :
  tas HEAP_ALLOC (R12↓) et pile standard (rbp↑) partagent 1 Mio sans
  détection de collision.

 110. **Tout calcul Ada d'une grandeur de layout doit être le MIROIR
  EXACT des macros fasmg.** STATIC_RECORD_SIZE_BITS et le STATIC_SIZE
  de TRAITER_LES_CHAMPS sommaient les tailles SANS simuler les
  align_* que STATOFS émet (STATIC_TYPE_ALIGN_BYTES déjà fourni au
  3e argument !) → CD_IMPL_SIZE < size réel dès qu'un champ aligné
  crée du padding. Signature : stride d'agrégat trop court, chaque
  élément écrase la fin du précédent — pointeur de tas mutilé
  0xffff0000 (octets 0-1 et 4-7 zappés par VP/AREA du suivant).
  Fix : ALIGN_STATIC_BITS avant chaque champ, aux 3 sites. Assumé :
  pas d'arrondi FINAL (STATOFS n'en fait pas) → éléments de tableau
  désalignés à partir du 2e si size ∉ multiple de l'alignement max
  (toléré x86 ; une des raisons du diana.bin ≠ gnat).

 111. **Instance générique : le trampoline d'appel du modèle (LI 0 /
  LVA GFP / args) n'est pas consommé par le corps inline
  d'UNCHECKED_CONVERSION** → pile déséquilibrée, UNLINK dépile un faux
  FP, RTD saute sur une valeur. Fix : hisser le test UC avant les
  émissions (bloc declare remonté) et les garder par not IS_UC ; le
  chemin non-UC émet bien le CALL qui les consomme. *
  
 111. bis. ** Bug frère**
  CODE_FUNCTION_CALL ne préparait le slot résultat composite que pour
  DN_RECORD et DN_ARRAY — DN_CONSTRAINED_ARRAY tombait dans LI 0
  scalaire, déréférencé 0 par le callee. Fix : doublet caller-alloué,
  data par CO_VAR à SIZ runtime du type (bornes dynamiques — TTREES),
  motif identique à l'élaboration d'une variable du type.

 112. **CONVENTION COMPOSITE (6 bugs, désormais règle) : CODE_EXP
  d'un composite rend @DOUBLET pour un objet ENTIER
  (DN_USED_OBJECT_ID) ou un APPEL DE FONCTION (DN_FUNCTION_CALL),
  @DATA nue pour toute RÉFÉRENCE DE COMPOSANT (indexé, sélecté,
  .all).** Tout consommateur voulant l'@data passe par
  CODE_COMPOSITE_DATA_ADDRESS ; un `La ,0` (ou `La` nu — DEUX
  orthographes, angle mort de grep : normaliser !) inconditionnel
  après CODE_EXP est un bug. Sites corrigés : égalité record
  (précédent fondateur OPERAND_DATA_ADDRESS), actual indexé (doublet
  INDARG, jumeau de SELARG qui existait déjà pour les sélectés),
  CODE_RETURN record, agrégat record ×3, init de déclaration,
  CODE_ASSIGN record et tableau. À la frontière d'un sous-programme,
  un composite voyage TOUJOURS en @doublet (arguments, résultat,
  les deux sens) ; l'@data est interne aux expressions.

 113. **Deux niveaux lexicaux distincts dans une même élaboration —
  ne jamais les fusionner.** (a) result__ofs est un PARAMÈTRE de la
  fonction : CODE_RETURN doit l'adresser à ENCLOSING_LEVEL, pas
  CUR_LEVEL (return depuis un declare imbriqué lisait la frame du
  bloc ; la branche tableau et la cascade UNLINK étaient déjà justes
  — précédent interne). Branche scalaire : même fix, corruption
  SILENCIEUSE sinon. (b) Renaming composite : les slots _disp/__u du
  renommage vivent à CUR_LEVEL (stores + CD_LEVEL posé), mais le LVA
  du descripteur de type vise DI(CD_LEVEL, SRC_TYPE) — la session 1
  marchait par coïncidence des niveaux (N_SPEC, tout au niveau 0).

  114. **Un octet REX faux change la destination ET la base : `db 0x49,8D,A0`
  = `lea rsp,[r8+disp]`, pas `lea r12,[rax+disp]`** : l'init du tas
  (codi_x86_64.finc, prologue) encodait REX.B au lieu de REX.R. Résultat :
  R12 jamais écrit (tas partant de 0, premiers `new` rendant -512, -1024…)
  et rsp = r8(-1)+64 Mio — la pile de travail tombée PAR CHANCE dans le BSS
  des 128 Mio de p_memsz, masquant tout jusqu'au premier déréférencement de
  tas. Empreinte de diagnostic : r8=-1 survivant, r15=0x3BFFFFF,
  r12 = -(N_allocs × taille). Correctif : 0x49 → 0x4C. Règle : tout `db`
  manuel visant R8-R15 se vérifie DES DEUX CÔTÉS du ModRM (reg via REX.R,
  r/m via REX.B) — même angle mort que le n° 16, côté préfixe.
  
  note : au prologue le retour du mmap n'est pas testé (échec → R12 ≈ 64 Mio dans le vide, cousin silencieux du 114)

 115. **`CODE_TYPE_MEMBERSHIP` était un stub `null;` : `X in MARQUE` (la
  forme la plus idiomatique du membership !) n'émettait RIEN** — le BF du
  `if` dépilait un booléen jamais empilé, rbp descendait d'un quadword par
  exécution, et les push suivants labouraient le haut de la zone des VAR.
  Fossile de plus pour le n° 96 (le À FAIRE silencieux) : celui-ci a coûté
  trois jours, le crash éclatant à ~200 réductions de grammaire du trou,
  dans DABS via D via un SELARG écrasé. La collision n'apparaissait qu'au
  tour où la dérive s'ALIGNAIT sur une VAR (cf. n° 53, fuite lente) — d'où
  un premier passage réussi, un second fatal, sur les mêmes octets.
  Correctif : implémentation miroir de CODE_RANGE_MEMBERSHIP, bornes lues
  dans _<SOUS_TYPE>.FST/.LST via CODE_SCALAR_SUBTYPE_BOUND (LOAD_BOUND de
  CODE_RANGE_CHECK factorisé). Trois pointes du correctif : PAS de garde
  CHECKS_ENABLED (c'est de la sémantique, pas un check) ; marque = type de
  base → émettre `LI 1`, jamais rien ; marque non scalaire → raise BRUYANT.

 116. **Empreintes FINC d'une émission de condition manquante** :
  `; debut if` immédiatement suivi d'un `BF` nu ; ou un `DUP` en tête du
  squelette `or else` (DUP/BT/DROP) sans production en amont = opérande
  gauche évaporé. Grep systématique de ces motifs sur tous les FINC après
  tout ajout au CODE_EXP. Côté gdb, l'arme contre les dérives de pile :
  `watch $rbp < <base>` (watchpoint logiciel, single-step) dégainé AU
  DERNIER MOMENT — laisser courir en breakpoints normaux jusqu'au dernier
  point sain, poser le watch, continue : gdb s'arrête SUR l'instruction
  mangeuse. Audit mécanique complémentaire : tout PRO dont le PRMS contient
  `result__ofs` doit rendre par `RTD prm_siz-8`, les autres par
  `RTD prm_siz` — grep en deux passes.

 117. **Layout des records représentés : deux anomalies cohérentes donc
  silencieuses** (constatées sur SEMSTAK_UNIT, 36 octets au lieu de ~24) :
  (a) STATIC_TYPE_ALIGN_BYTES rend 8 pour tout composant de type record —
  un TREE représenté 4 octets devrait s'aligner sur 4 ; (b) les variantes
  d'un record à discriminant sont posées SÉQUENTIELLEMENT au lieu de se
  recouvrir (max des branches). Les deux faces du miroir (STATOFS fasmg et
  COMP_SIZ Ada) racontent la même histoire → gaspillage et hétérodoxie du
  diana.bin, pas de crash. Dette consignée, à corriger ensemble et des deux
  côtés à la fois (leçon du n° 110).

 118. **La discipline TROU() — le silence est un bug** (campagne
  « expander bruyant », 28 juillet, briefing du 27). Tout manque de
  capacité de l'expander se signale AU SITE : procédure centrale TROU
  (expander-utils) — message « !! TROU <site> [: <noeud>] » dans le
  FINC ET sur la console (leçon n° 96), puis PROGRAM_ERROR ; mode
  RECENSEMENT (TROU_RECENSEMENT, option W) : compte et continue, le
  FINC est alors SUSPECT par construction et ne s'assemble jamais ;
  bilan « N TROU(s) traversés » à CLOSE_OUTPUT_FILE. Trois découvertes
  structurelles : (a) l'arbre de dispatch ENTIER (CODE_EXP → ~35
  dispatchers en cascade de classes) était en if/elsif SANS else — un
  noeud hors classes traversait tout et disparaissait ; l'avaleur
  était SYSTÉMIQUE, pas accidentel, et le grep ne le voit pas (audit
  manuel, désormais un else TROU() partout) ; (b) « !! TROU CODE_EXP »
  nu = appelant ayant passé TREE_VOID — doctrine : correction TOUJOURS
  chez l'appelant par garde annotée de la raison (modèle CODE_RETURN),
  JAMAIS en faisant accepter le vide au producteur ; (c) le FINC du
  recensement EST le traceback : « ; !! TROU » tombe au site
  d'émission, `grep -B 12` + commentaires DEBUG identifient la
  construction en secondes. Quatre bugs latents VIVANTS payés au tri
  (n° 119-120) contre trois jours pour le seul n° 115 chassé au gdb.
  Fossile fondateur : n° 115 ; définition de fini : plus un null; sans
  INTENTIONNEL annoté, plus un dispatcher sans else, plus un « pas
  géré » sans raise.

 119. **Le contrat attribut-fonction invisible : l'argument de
  T'POS(X)/PRED/SUCC/VAL est évalué par CODE_FUNCTION_CALL, PAS par
  CODE_ATTRIBUTE.** La forme appel (DN_FUNCTION_CALL de nom
  DN_ATTRIBUTE) évalue l'actuel puis délègue l'opération ; AS_EXP du
  noeud attribut est TOUJOURS vide sur cette forme — mais DIANA
  prévoit le slot. Les quatre branches refaisaient CODE_EXP(AS_EXP) =
  no-op silencieux qui MASQUAIT le contrat : POS/VAL (identité) et
  PRED/SUCC (DEC/INC sur le sommet) marchaient depuis l'origine grâce
  à l'appelant, sans que la division du travail soit écrite nulle
  part. Révélé par le premier recensement (_STANDRD INTEGER_IMAGE /
  ENUM_IMAGE). Correctif : appel vestigial supprimé, ceinture
  INVERSÉE — le cas vide est le légitime documenté, AS_EXP peuplé
  (forme directe jamais émise) est le TROU. Leçon générale : un trou
  silencieux ne cache pas que des bugs, il cache aussi des CONTRATS ;
  oracle gratuit du correctif : diff des FINC (le no-op n'émettait
  rien).

 120. **Préfixes non nommés de composant sélectionné : deux CEQ sur
  fond de pile.** RECURSE_SELECTED ne connaissait que les préfixes
  nommés/indexés/déréférencés ; deux formes du corpus tombaient au
  travers SANS RIEN émettre — le comparateur consommait du fond de
  pile : (a) préfixe APPEL, `DABS(0,TXT_T).NSIZ = NB_TREES`
  (IDL_MAN.HASH_SEARCH — troisième fossile de cette fonction, la
  déduplication des symbol_rep du binaire auto-compilé répondait au
  hasard) ; (b) préfixe CONVERSION-VUE, `TREE(DEFINTERP).TY =
  DN_NULLARY_CALL` (SET_UTIL.IS_NULLARY, dérivés privés de TREE,
  famille n° 117). Correctifs : (a) branche DN_FUNCTION_CALL sur le
  modèle CODE_INDEXED — CODE_EXP(appel) laisse @doublet, La extrait
  data_ptr, PROCESS_DESIGNATOR reprend par ses chemins « adresse en
  pile » ; garde TROU sur retour non record (déréf implicite 4.1.3
  non instruite) ; (b) normalisation EN TÊTE DU TRI : boucle while qui
  rebranche NAME sur l'opérande quand ROOT_RECORD prouve la même
  racine de dérivation (hypothèse documentée : pas de rep propre sur
  les dérivés) — la conversion enveloppant n'importe quel préfixe, la
  transparence d'adressage se traite AVANT le dispatch, pas comme une
  branche. Tout binaire auto-compilé antérieur à ces correctifs est
  suspect (HASH_SEARCH et IS_NULLARY faux) : re-dérouler depuis le
  compilateur de référence.

 121. **Les avaleurs qui ne déséquilibrent pas la pile : le programme
  FAUX qui tourne** (vagues 2-5 du bruyant, 28/07). Le n° 115 (pile)
  n'est qu'une espèce ; la campagne en a collecté quatre autres, toutes
  invisibles au filet tant qu'un témoin ne vise pas juste : (a) boucle
  FOR sans INC/DEC émis = boucle INFINIE (dispatch itération muet) ;
  (b) offsets GFP faux (formel générique non couvert = slots non
  réservés, tout le cadre décalé) ; (c) émission SYNTAXIQUEMENT cassée
  (`LI ` sans opérande — l'erreur part à l'assemblage, loin du site) ;
  (d) layout continué après « OFFSET NON STATIQUE » (tous les offsets
  SUIVANTS faux). S'y ajoute la DIVERGENCE DE CONVENTION dormante :
  l'actuel énuméré émettait SM_POS là où toute la maison est SM_REP —
  identique tant que rep = pos, faux au premier `for T use (...)`.
  Amendement du n° 112 au passage : DN_QUALIFIED EST un producteur
  d'@doublet — la règle unique (CODE_COMPOSITE_DATA_ADDRESS) portait le
  trou que deux sites locaux avaient déjà corrigé chacun pour soi.
  Leçon : quand un site local contredit la règle unique, c'est la RÈGLE
  qu'on audite d'abord. Et la leçon de clôture : les greps de MOTS
  (« pas géré/a faire ») inventorient, seule la vérification
  STRUCTURELLE du critère de fini clôt — deux survivants pris ainsi
  ('STORAGE_SIZE avalé dans une branche explicite de chaîne, « choix
  inconnu » hors lexique).

 122. **La boucle recensement → triage → reclassement : bénir l'observé,
  jamais la classe** (6 reclassements, 28/07). Un TROU vivant au
  recensement n'est pas d'office à implémenter : (a) verdicts
  PRÉ-ÉCRITS pris tels quels — le TROU de vague 4 portait déjà sa porte
  de sortie (« si l'élaboration à la complétion suffit, LRM 7.4,
  reclasser ») et l'« A VOIR » sa promesse (le FINC de TO_CHN a fourni
  la vraie raison : corps synthétisé, résultat via le slot, RTD
  prm_siz-8) ; (b) DISCRIMINER plutôt que bénir — length_enum_rep
  couvre DEUX clauses (longueur pliée front-end = INTENTIONNEL ; enum à
  agrégat = TROU n° 117-bis), at-mod se plie statiquement (divise 8 =
  garanti par le miroir STATOFS, sinon TROU), PREDEF_NAME borné aux
  trois sortes OBSERVÉES (argument_id sonne encore) ; (c) un TROU trop
  LARGE se raffine (RECORD_REP sonnait sur tout nœud alors que seule
  l'ALIGNEMENT était avalée). Chaque reclassement porte sa raison ET sa
  référence de recensement dans le commentaire — le verdict interdit
  « A VOIR » est mort avec sa vraie raison écrite.

123. **Le protocole resultat scalaire ne se transpose pas aux doublets :
    le wrapper RELAIE, il ne rapatrie pas.** Scalaire : slot factice
    (LI 0), le modele ecrit DANS son slot, RTD prm_siz-8 le laisse, le
    wrapper rapatrie (S<c> lvl,-result__ofs). Composite non contraint :
    le resultat se materialise PAR le corps A TRAVERS le slot — le
    wrapper doit passer SON slot recu (La lvl,-result__ofs) comme lieu
    result du modele ; LI 0 = ecriture a l'adresse 0 au CODE_RETURN du
    modele (segfault d'INSTF1). Corollaire : un fossile INTENTIONNEL
    peut benir une moitie jamais exercee — le reclassement n 4
    (« RTD prm_siz-8 le laisse a l'appelant ») decrivait le protocole
    PARTAGE comme acquis alors que son amont (le relais) n'existait
    pas. Un INTENTIONNEL sur un rameau non exerce vaut un TROU muet.
    (session 1er aout)

124. **Trois SORTES de slots, trois mecanismes d'overlay — l'equation
    fasmg exige la meme sorte des deux cotes ET le meme frame.**
    Contenu du slot selon l'objet : VALEUR (scalaire local),
    DATA_PTR (composite local), @DOUBLET de l'actuel (parametre
    composite, TOUS modes — n 91/94). D'ou la grille (alias / cible) :
    scalaire/scalaire = equation X_disp = Y_disp ; composite/composite
    local = equation (data_ptr partage, __u propre = vue de
    reinterpretation) ; composite/scalaire = VAR + data_ptr := @slot
    cible (LVA/Sa) ; composite/parametre = La <niv cible>,-ofs /
    La ,0 / Sa. Toute case hors grille = TROU discrimine : equater a
    sorte differente fait DEREFERENCER une valeur ou lire un pointeur
    comme valeur. Init a travers l'overlay : agregat seulement — un
    litteral chaine RE-POINTERAIT _disp sur la CONSTANTE (aliaserait
    la constante, pas la cible). (session 1er aout)

125. **Une garde de FAISABILITE appartient au MECANISME qu'elle
    protege, pas au recruteur commun.** La garde « meme niveau »
    (necessaire a l'equation : un seul CD_LEVEL sert _disp ET __u de
    l'alias) etait posee dans OVERLAY_TARGET, le helper commun — elle
    rejetait la cible AVANT que la voie parametre (niveau LIBRE : le
    La s'adresse a FP(niveau cible) explicitement, comme tout acces
    parametre emis d'un bloc) ait pu jouer. Symptome : TROU sur un cas
    que le mecanisme aval savait traiter ; declencheur : CODE_BLOCK
    fait INC_LEVEL, toute declaration en bloc est au-dessus des
    parametres. Posee trop haut, une garde interdit aux autres
    mecanismes ce qui leur est permis. (session 1er aout)
    
 126. **`namespace X` fasmg ROUVRE un namespace existant.** L'ancien " namespace _STRING" des composants
    de record greffait _COMP_SIZ/_FST_1/_LST_1 DANS STANDARD._STRING, aux offsets exacts du layout
    contraint : le patron pollue etait un faux descripteur auto-coherent qui amortissait TOUS les
    __u := patron fautifs. Symptome de de-greffe : les lecteurs passent de "presque juste" (255) au
    bruit (segfault). Tout namespace emis doit porter un nom neuf (_<comp>__type, ANON_*).

127. **CD_COMPILED survit au rechargement DCL** (spec compilee puis corps) : il signifie "compile un
    jour", jamais "label atteignable dans CE FINC". Aucune emission de bloc atteignable ne doit etre
    gardee par lui (generalisation du n 46 aux composants ; l'elab_spec du corps re-emet TOUT).

128. **La famille XD_SOURCE_NAME -> patron est close a SIX consommateurs assainis** : USEINFO record,
    CODE_INDEXED direct, CODE_SLICE prefixe selecte, SELARG composant, SELARG nom etendu, init d'objet
    non contraint par tranche/composant. Discriminant unique : D( SM_TYPE_SPEC, XD_SOURCE_NAME(TS) )
    /= TS => anonyme => bloc elabore (_<obj>__type / _<comp>__type), jamais le patron. Sorties
    legitimes du grep '_STRING.use__info' d'un FINC : le doublet de tete du patron dans _STANDRD, les
    dead stores de classe B (pre-init ecrasee par "La ,8 / Sa __u" en fin d'elaboration), les formels
    non contraints (info portee par l'ACTUEL). Tout le reste est un bug.

129. **COVAR_ALLOCATE sur un TYPE_SPEC non contraint lit SIZ = -1 du patron** : toute branche d'init
    de COMPILE_ARRAY_VAR appelee avec TYPE_SPEC.TY = DN_ARRAY doit passer par le modele doublet
    (CODE_ARRAY_OPERAND / CODE_SLICE source + __u partage + LId pour la longueur), jamais par
    PUT_TYPE_INFO_PREFIX.SIZ. Restent au refus bruyant : objet entier, qualifie non-agregat
    (remede sur etagere : trois lignes, cf. commit 8 au journal).

130. **Fenetre d'un classifieur de FINC = le segment d'elaboration**, jamais N lignes fixes : la
    re-ecriture "from function result" de la classe B arrive apres les centaines de lignes de l'init.
    Borner au prochain "var elab" / "begin:" / "PRO". (95% de faux VIVANTS avec la fenetre fixe.)

131. **Le harnais d'un temoin ne doit pas dependre de la fonctionnalite sous test** (CHECK et verdict
    de REC_ARR_TEST impriment par PUT successifs, sans "&"). Corollaire : le couple longueur/contenu
    (tests 36/37) discrimine doublet sain / base non recalee -- concevoir les paires exprès.

132. **L'indentation ne dit pas l'imbrication** : CODE_ARRAY_OPERAND semblait niché ("\t  procedure")
    mais etait au niveau module -- une ligne de spec a suffi a l'exporter. Verifier le "end" suivant
    avant de planifier une migration.

133. **Forensique memoire** : data = litteral + qwords 0x00D9xxxx adjacents = zone constante (le
    litteral suivi des CELLULES data_ptr/info_ptr voisines). x/4wx sur l'info : SIZ = 0xFFFFFFFF
    signe le patron nu ; autre bruit = bloc ANON non rempli ou ecrase.

134. **Tabulations sed grep** :Dans une classe de caractères, \t n'est une tabulation que pour GNU sed, pas pour grep : [ \t] y vaut {espace, antislash, t}. Symptôme vicieux : un pipeline sed+grep où l'extraction marche et le test échoue — le classifieur v1/v2 flaggait 100% VIVANT en silence. Toujours [[:space:]], et toujours étalonner un juge sur un cas MORT connu avant de croire ses VIVANT.

135. **La regle unique n 112 a des consommateurs retardataires --
    occurrences 3 et 4 dans la meme session.** (a) EMIT_ONE_COMP
    (composante composite d agregat tableau) : le correctif "SId ->
    BLKMOV" d une session anterieure prenait CODE_EXP nu comme
    source ; pour un objet entier c est l @DOUBLET -> chaque element
    recevait les octets du data_ptr. SIGNATURE MEMORABLE : valeur
    UNIFORME dans toutes les cellules d un remplissage = pointeur
    copie comme donnee (un vrai residu memoire n est pas uniforme).
    (b) COMPILE_RECORD_VAR (init de declaration) : "La ,0"
    inconditionnel apres CODE_EXP -- juste pour l appel de fonction
    (@doublet), faux pour une reference de composante (@data nue) :
    la VALEUR de la source devient l adresse source du BLKMOV
    (T := S.NEXT difforme, motif APPEND). Ne s etait jamais vu car
    la quasi-totalite des inits record du corpus sont des appels de
    fonction (X : TREE := D(...)). REMEDE UNIQUE :
    CODE_COMPOSITE_DATA_ADDRESS, qui discrimine le La par producteur.
    AUDIT DU RESTE DE LA FAMILLE RECOMMANDE : grep CODE_EXP suivi de
    La/BLKMOV hors regle unique ; site "A VERIFIER" connu dans
    DESTINATION_SELECTED (tableau non-agregat). (session 7 aout)

136. **CD_IMPL_SIZE d un DN_RECORD ordinaire vaut 64 quel que soit le
    nombre de champs** -- COMP_SIZE_BITS le croit et taille les
    agregats tableau-de-records a 8 octets (longueur BLKMOV ET pas
    d avance). Le record REPRESENTE (TREE, 32) est juste, donc le
    bootstrap ne mordait pas. Contournement au consommateur : taille
    symbolique _TYPE.size (modele EMIT_ONE_COMPONENT), longueur et
    pas TOUJOURS DE CONCERT (une seule des deux = pire que le bug).
    Poseur (types_decls) a auditer au chantier tailles ; recenser
    alors les AUTRES consommateurs de COMP_SIZE_BITS sur des records
    (CODE_INDEXED, CODE_SLICE...). (session 7 aout)

137. **Le runtime TEXT_IO du binaire bootstrappe termine ses lignes
    en CR+LF** (gnat : LF). Deux consequences : (a) tout diff de
    traces gnat/bootstrappe doit NORMALISER (tr -d bslash-r + rognage
    des blancs de queue), sinon "tout differe" -- a failli masquer
    l identite bit-exacte des traces PAR_PHASE ; (b) les FINC que le
    bootstrappe PRODUIRA en mode W porteront ce CRLF : verifier la
    tolerance fasmg au premier FINC bootstrappe, et trancher l origine
    (NEW_LINE du TEXT_IO runtime, source hors contexte projet a ce
    jour). (session 7 aout)

138. **CUR_LEVEL := 0 en tete de TOUTE unite — faux pour un subunit
    dont le parent porte un frame.** Un subunit de la PROCEDURE
    SEM_PHASE se compilait au niveau de son parent ; a l'execution son
    LINK ecrasait display[parent] et tout acces montant lisait le
    frame du subunit (use__info = 0, ENUM_IMAGE derefere 0+16 :
    SIGSEGV 0x4028d8). Sain par accident pour les subunits de
    bibliotheque (parent package, base 0) — PAR/LIB_PHASE passaient.
    Canal de correction : CD_LEVEL de la premiere declaration (stub /
    spec), qui traverse la bibliotheque comme CD_LABEL ; poseur ajoute
    au stub de package (pas de frame : niveau du contexte). Signature
    gdb : registre = petite constante exacte d'un LI de la sequence
    appelante (ici 0x10) = base nulle + offset. Gardien : SUBLVL_TEST.
    (session 7 aout, lot subunits)

139. **Agregat d'un tableau DE tableaux : COLLECT_DIMENSIONS aplatit en
    multi-dim, et une composante NON-agregat couvrant les dimensions
    restantes (litteral de chaine, objet, appel) tombait dans la voie
    scalaire d'EMIT_ONE_COMP** -- SId rangeait l'@doublet du litteral :
    contenu = tranches de pointeurs (pas constant entre elements = ecart
    des blocs STR), positions et strides JUSTES. Symptome bootstrap :
    BLTN_TEXT_ARRAY empoisonne, symboles d'operateurs doublons, deflist
    de "-" vide, HEAD leve au premier DN_FUNCTION_CALL (SHORT_INTEGER
    de _standrd). Garde de profondeur posee : DEPTH < NB_DIMS et
    non-agregat => copie en bloc, longueur _STR_(DEPTH), source regle
    n 112. Gardien : AGGSTR_TEST (checks 2-10). AUDIT RECOMMANDE :
    EMIT_ONE_COMPONENT (agregat RECORD) avec composante tableau-de-
    tableaux, et agregats MIXTES (K_A => "AND", K_B => ('O','R','!')) --
    le second membre passe par la voie agregat imbrique, non couvert
    par le temoin. (session 8 aout)

140. **Operateur DEFINI PAR L'UTILISATEUR emis comme le predefini
    homonyme.** Le dispatch DN_USED_OP envoyait tout a
    CODE_DN_BLTN_OPERATOR_ID, dont le garde acceptait DN_OPERATOR_ID :
    emission PAR NOM ("**" -> CALL INTEGER_POW, "+" -> ADD...) sur les
    @doublets des operandes records. Symptome bootstrap : spin
    d'INTEGER_POW (N = adresse de pile, E astronomique, code de la
    boucle PROUVE correct au desassemblage) au 2**15 de SHORT_INTEGER ;
    et poison SILENCIEUX de tous les +,-,*,comparaisons d'UARITH.
    Discrimination posee au dispatch : SUBPROGRAM_ORIGIN d'abord (un
    renames d'un predefini reste par nom), puis DN_OPERATOR_ID a vrai
    corps -> voie normale d'appel de fonction (protocole D(...)).
    Frontiere : les operateurs IMPLICITES des types derives restent
    par nom -- gardes par OPDEF_TEST 5-6. Lecon de methode : une
    boucle "infinie" while-decrementante = parametre d'entree
    astronomique = chercher le SITE D'APPEL, pas la boucle.
     Raccord de nommage : l'APPEL passe par LETTERED_SUBNAME comme le
    PRO (l'un sans l'autre = identifiant fasmg invalide '+'_Lnn) ;
    typo latent de la table sur "=" corrige au meme lot.
    Gardien : OPDEF_TEST. (session 8 aout 2026)

    effet comportemental assumé du correctif : tout opérateur utilisateur
    dont le corps applique le même opérateur au même type sans conversion
    récursait légitimement ; calendar.adb corrigé en conséquence.

141. **Doublet anonyme nomme par position source : COLLISION sur un
    appel d'operateur infixe.** La position d'une expression infixe =
    celle de son operande GAUCHE ; si cet operande est un appel a
    resultat record, PREPARE_FUNCTION_RESULT_PLACE emettait DEUX
    VAR ANON_l_c homonymes dans le namespace -- fasmg multi-passes lie
    les references de facon degeneree, @ nul propage dans D/DABS,
    segfault 0x45825b (La sur VAL). Invisible avant le piege n 140 :
    le chemin builtin n'allouait pas de doublet-resultat d'operateur.
    Le LEXEME n'offre pas d'issue : LX_SRCPOS du DN_USED_OP = debut
    d'expression = position de l'operande gauche (verifie au FINC).
    Unicite par SUFFIXE hors position : ANON_l_c_L<n> via NEW_LABEL
    (deterministe), pour les seuls lieux-resultat d'operateurs.
     AUDITS RECOMMANDES : (a)
    PREPARE_ARRAY_RESULT_PLACE garde CALL_NODE -- un operateur
    utilisateur rendant un tableau NON contraint recollisionnerait
    (hors corpus) ; (b) defense assembleur : faire aboyer la macro VAR
    de codi sur une redefinition dans le meme namespace -- la
    collision etait un silence fasmg. Gardien : OPDEF_TEST 7-8.
    (session 8 aout)

142. **UN OPERATEUR EST UNE FONCTION : tout test DN_FUNCTION_ID d'un
    emetteur doit inclure DN_OPERATOR_ID.** Cinquieme et sixieme faces
    du territoire du piege n 140 : l'epilogue RTD testait
    DN_FUNCTION_ID seul -- un corps d'operateur recevait RTD prm_siz
    (epilogue de PROCEDURE), le slot resultat etait depile, et le La
    de l'appelant dereferencait le LI de taille reste au sommet
    (segfault rax = 8 = _PAIRE.size, temoin OPDEF). Trois freres
    corriges au meme lot : epilogue des corps synthetises, appel
    PREFIXE PKG."op"(..) de CODE_SELECTED (retombee silencieuse), init
    par appel selectionne. Recensement mecanique de la famille :
    grep DN_FUNCTION_ID expander*.adb | grep -v DN_OPERATOR_ID --
    a repasser apres tout nouveau test de genre de sous-programme ;
    les seuls survivants legitimes sont les unites de bibliotheque
    (un operateur ne peut pas en etre une). Lecon jumelle du n 141 :
    la collision ANON etait reelle mais MASQUEE par ce trou -- deux
    familles peuvent partager un meme symptome, corriger la premiere
    ne dispense pas de re-deriver la chaine causale sur le crash
    suivant. Gardien : OPDEF_TEST 1-8 complet. (session 8 aout)
    
   143. **STATIC_TYPE_ALIGN_BYTES ignorait pragma PACK : les tableaux
    packes recevaient l'alignement de leur composant.** Symptome
    bootstrap : U_VALUE/UARITH corrompait les universels a >= 2
    doublets (quads hauts recopies en bas -- 2**31-1 lu 2100214748),
    6 lignes de diff sur le FINC bootstrappe de _standrd, PRINT_NUM
    innocente (RECSTR/RECSTR2 verts). Garde posee : tableau packe ->
    alignement 1 (la garde teste la BASE : les sous-types contraints
    remontent a SM_IS_PACKED). DESACCORD DES DEUX PARTIES nomme au
    journal (type-info _VECTOR vs consommateurs UNIV_OPS) -- un
    alignement seul ne corrompt pas. MIROIRS a honorer : STATOFS
    fasmg (n 110) et chantier n 117 (l'en-tete de la fonction
    l'exigeait). RESERVE vague 4 : DB(SM_IS_PACKED) sur attribut
    vierge doit rendre FALSE -- cellules vierges non nulles sous
    bootstrappe (note SECV1). Gardien : PACKV_TEST ; RECSTR_TEST et
    RECSTR2_TEST restent au filet (squelette et chair de PRINT_NUM).
    (session 9 aout)
    
144. **GFP lu au niveau GENERIC_BASE_LEVEL+1 avec l'offset LOCAL : faux
    des qu'un sous-programme est IMBRIQUE dans le corps generique.**
    Chaque PRO d'un corps generique porte son propre PRM GFP_ofs
    (CODE_PARAM_S) et le symbole GFP_ofs se resout au PRM du PRO
    COURANT (namespace fasmg) : le niveau doit etre CUR_LEVEL, jamais
    GENERIC_BASE_LEVEL+1 (egaux seulement a l'imbrication 1, d'ou la
    survie du bug jusqu'au premier generique a fonction interne
    recursive). Melange niveau externe / offset interne = lecture d'un
    AUTRE PRM du frame englobant (REQ_UTIL : TYPESET, une adresse de
    pile) ; [pseudo-GFP - 24] via IS_XXX__call_ofs -> CALLI dans la
    pile (T2 sur _standrd.adb, REQUIRE_XXX recursif). Corrige aux deux
    sites exerces (CODE_PROCEDURE_CALL : propagation + CALLI formel).
    JUMEAUX NON EXERCES consignes, meme famille, recensement mecanique :
    grep -n "GENERIC_BASE_LEVEL" expander*.adb | grep "GFP_ofs"
    (~21 sites : LOAD_MEM et CODE_USED_OBJECT_ID pour les objets
    formels, use__info des types formels — 'SIZE 'SMALL 'WIDTH
    FIRST/LAST, conversions et litteraux fixed —, init de locale de
    type formel, STORE_OR_CALLI, MACHINE_CODE) — tous faux au meme
    titre si l'acces part d'un sous-programme imbrique dans le corps
    partage. RESERVE : depuis un bloc declare d'un corps generique,
    CUR_LEVEL est le niveau du BLOC (frame propre SANS PRM GFP) — il
    faudrait le niveau du PRO englobant ; non exerce, meme famille que
    le bug de niveau des thunks (journal A35801B). Gardien :
    T2 ./ _standrd.adb M + diff FINC de REQ_UTIL. (session 10 aout)
    RESERVE LEVEE le 24 aout 2026 : exercee par FLOAT_IO.PUT (bloc
    ROUNDING) apres passage de CODE_VC_ID a CUR_LEVEL -> n 155
    (GFP_LEVEL). Les jumeaux GENERIC_BASE_LEVEL+1 restent a convertir.

145. ** OPERAND_DATA_ADDRESS
(CODE_RECORD_EQUALITY) ** copie locale divergente de la règle n°112
jamais rebranchée + DN_PARENTHESIZED absent de la règle unique ;
opérande gauche d'égalité TREE « ( A op B ) = U_VAL(1) » chargé comme
adresse de doublet -> comparaisons BOOLEAN d'UARITH à FAUX permanent ->
« INTEGER TYPE TOO LARGE » sur tout type entier à borne 'LAST sous T2.
Diagnostic : sondes @IB1/@IB3 (valeurs saines, six booléens FFFFFF ->
mecanisme amont des donnees), FINC croisés site/corps, arithmétique des
labels ancrée par _NOT__L38. Gardien : OPB_TEST 11-12 (rouge capturé
« 11 OK, 1 ECHECS »). Recensement mécanique de la famille : grep des
discriminations par espèce sur producteurs d'@doublet HORS
CODE_COMPOSITE_DATA_ADDRESS ; auditer aussi les AUTRES consommateurs
d'espèces qui ne déballent ni CONVERSION ni PARENTHESIZED.
Annexe : élaboration « R : STRING := littéral » ALIASE le littéral
(pas de copie) — dormant, à recenser séparément.

146. ** agrégat affecté à une TRANCHE ** CODE_ASSIGN
jetait (DROP) la longueur de tranche et CODE_ARRAY_AGGREGATE remplissait
aux bornes du TYPE depuis le début de tranche : queue de tableau écrasée
+ (bas_tranche − FST) octets au-delà. Symptôme : segfault UNLINK de
WRITE_LIB (cellule LINK = 8×TRUE = 0x0101...), dépendant de HIGH_BLOCK
(_standrd immune, fermetures transitives touchées). Diagnostic : hardware
watchpoint sur la cellule LINK -> écriture prise sur le fait dans
MARK_DONT_MOVE_PAGES ; FINC : DROP de len_dst + _FST_1/_LST_1 littéraux
du type. Correctif : contrainte applicable = celle de la tranche (RM83
4.3.2), range de tranche passée à l'agrégat, dimension 1 surchargée.
Gardien : SLAGG_TEST (rouge 5 OK/3 ECHECS capturé). À recenser : autres
consommateurs d'agrégats qui jettent une longueur déjà calculée
(grep DROP au voisinage de CODE_AGGREGATE).

147. **  co-pile = allocateur à bosse par
processus ** l'UNLINK ne rend pas r14, ET NE DOIT PAS le rendre : les
résultats dynamiques des fonctions vivent sur la co-pile du callé et
sont consommés après retour (contrat d'évasion). Tentative R1
(restauration à l'UNLINK) révoquée : écrasait les têtes des STRING
retournées (_standrd, noms mangés, PROGRAM_ERROR). Symptôme initial :
segfault d'épuisement au LINK sur la plus grosse unité (text_io.adb,
r14 = fin d'arène, profondeur faible). Traitement : plafond 128 Mo ->
1 Go (p_memsz), fuite bornée par unité compilée. Gardiens : STRRET_TEST
(contrat d'évasion — vert obligatoire sous tout remaniement futur),
COPILE_TEST (capacité). Chantier ouvert : récupération saine (retour
glissant ou marques de relâche). Leçon de méthode : les témoins de
runtime doivent couvrir les contrats d'ÉVASION.

148. ** double empilement de l'@data pour un préfixe
NOM ÉTENDU ** dans CODE_INDEXED, un préfixe DN_SELECTED déclenchait
CODE_SELECTED( IS_SOURCE => FALSE ) qui empilait l'adresse de la table,
puis la queue commune (ARRAY_DEFN /= DN_COMPONENT_ID) la RE-empilait :
pour PKG.ARR( I ) — désignateur DN_VARIABLE_ID — fuite de pile +1 par
référence. Bénigne aux frontières d'instruction (résorbée), LÉTALE quand
elle naît dans un bloc de paramètres : le quadmot parasite s'intercale
entre le lieu-résultat et l'actuel, le callé lit -result__ofs = @table
NUE, son SIq corrompt [table+0] en silence (inscriptible, pas de faute)
et le BLKMOV d'info de CODE_RETURN vise [table+8] = petit champ de
l'élément 1 -> stos sur 0x1, segfault dans l'ÉPILOGUE DU CALLÉ alors que
la faute est au SITE D'APPEL. Symptôme : les 6 segfaults du bootstrap T2
(lex, idl-lib_phase, idl-err_phase, expander-expressions,
expander-declarations, ada_comp + types_decls collatéral) = exactement
les unités contenant goto/étiquette, car les seuls PKG.ARR(I).champ du
compilateur passés en actuels vivent dans CODE_GOTO/CODE_LABELED
(CODI.GOTO_LABELS(E).LBL, CODI.GOTO_PENDING(TOP).LBL_G -> LABEL_STR).
Diagnostic différentiel : PAS la co-pile (signature n° 109 absente :
ici stos de BLKMOV, pas mov [r14],r13 à l'ELB) ; le paramètre LBL était
LU JUSTE (tranche 2..3 en pile) -> un seul quadmot parasite, entre
result__ofs et l'actuel. Empreinte FINC irréfutable : deux
`La n, ...ARR_disp` CONSÉCUTIFS IDENTIQUES avant l'indexation.
Correctif : garde sur le pré-empilement — seul le COMPOSANT (R.A(N))
pré-empile, même prédicat que la queue commune :
`D( SM_DEFN, D( AS_DESIGNATOR, NAME ) ).TY = DN_COMPONENT_ID` ;
tout autre désignateur (variable, constante, paramètre de nom étendu)
est servi par la queue (REGIONS_PATH absolu, checks via ARR__u,
IS_PARAM). Chemin DN_COMPONENT_ID inchangé à l'octet près. Vérifié :
les 6 unités passent, 63 FINC T2 identiques aux FINC T1. Gardien :
GOTO_SELARG_TEST (forme exacte PKG.T(I).LBL en actuel d'une fonction
STRING sous concaténation + goto arrière + goto avant ; rouge
reproductible avec le T1 d'avant-commit) et l'oracle suprême du point
fixe (diff des 63 FINC). Leçons : (a) une fuite de pile se cherche AU
SITE D'APPEL, pas dans le callé — jumelle du n° 113 (result__ofs) et
cousine du n° 141 (collisions ANON, l'audit recommandé pointait un cran
trop haut) ; (b) un crash « dans » une routine ultra-exercée innocente
la routine et accuse la forme de l'appel. À recenser : grep de
l'empreinte double-La sur TOUS les FINC régénérés (aucune occurrence
attendue) ; CODE_SLICE préfixe DN_SELECTED (structure différente, pas
de queue ré-empilante — vérifier au FINC qu'aucun PKG.ARR(A..B) ne
produit le motif).

149. ** — ELB OUVRE LE FRAME, PAS PRO. Au codi, PRO = namespace + BRA
post ; ELB = VARzone fraîche + elab: + LINK. La conflation « PRO ouvre »
tenait par accident (PRO toujours suivi d'ELB sur le petit corpus). Les
BLOCS Ada la brisent : namespace BLOCK__n / ELB n / … / endPRO, ELB
sans PRO. Règle : PRO_PENDING — l'ELB d'un PRO armé appartient au
sous-programme (PRMS déjà logés), un ELB orphelin pousse SON frame.
Signature du défaut : « endPRO hors sous-programme » avec FTOP à zéro,
plusieurs endPRO pour un seul PRO dans la même région paresseuse.
Gardien : TC_TEST19 (fonction interne gardée morte + deux blocs
imbriqués, verdicts exécutés).

150. ** — LABELS POINTÉS : LA DÉTECTION AVANT LA DÉCLARATION. La tête de
ligne est scannée par NEXT_WORD (sans points) : sur « LD_ENUM.elab: »,
POS s'arrête au point, le test ':' échoue et la ligne devient un
pseudo-mnémonique (refus « hors tranche » TROMPEUR : le mot fautif est
un label raté, pas un mnémonique manquant). Deux volets indissociables :
lookahead [mot|'.'] avant le test du ':', PUIS déclaration éclatée
(ENTER_SCOPE par segment, USE_SCOPE de restauration). Gardien :
TC_TEST20 (thunk BRA post_X / X.elab: / ULB -1,0 / RTD 0, appelé par
CALLI nu).

151. ** — L'ENTITÉ UNIQUE SYMBOLE/NAMESPACE (fasmg). Un même nom peut
être variable ET espace de noms : VAR X puis namespace X (ou l'inverse)
ne font qu'une entité — « namespace X » sur un X existant rouvre ses
enfants, définir X sur un namespace pose classe et valeur SANS perdre
les enfants. Relevé ADA_COMP : ANON_…_D_info (doublet d'info de type
anonyme, GRMR_OPS). Modèle : la descente pointée teste « possède des
enfants » (UNDER /= 0), pas « est un SCOPE_NAME » ; réouverture /
attachement / unification selon l'état, classe et valeur conservées ;
toute autre duplication reste refusée. Gardien : TC_TEST23 (les deux
ordres, lectures de la variable ET de ses enfants pointés).

152. ** — REDÉFINITION SÉQUENTIELLE name = $ : LES ÉPOQUES. La macro VAR
fait une assignation fasmg REDÉFINISSABLE : GFP_disp peut être déclaré
deux fois dans le même scope (ADA_COMP, HASH_SEARCH), chaque référence
liée à la définition la plus récente AU POINT DU TEXTE, les deux
emplacements réservés. Résolution tardive oblige : BIRTH par cellule
(0 = de tout temps ; seules les OMBRES — FRAME_OFFSET sur FRAME_OFFSET
— naissent à leur élément déclarant), FIND rend la première cellule de
sa chaîne (plus récente d'abord) née avant ou à l'époque courante,
boucles P2/P2B/P3 et différés estampillent l'élément courant. PIÈGE
DANS LE PIÈGE : la boucle des différés va en ORDRE INVERSE — sans
restauration NATURAL'LAST en sortie de chaque passe, l'époque reste
figée sur le premier élément global et tout RESOLVE hors boucle remonte
le temps (vu au CHECK du témoin : 24 au lieu de 32). Doctrine : l'ombre
est restreinte au motif relevé ; d'autres classes redéfinies
attendront leur relevé. Gardien : TC_TEST24 (défini/référencé/
REDÉFINI/re-référencé, 5 et 9 survivent chacun dans son emplacement,
CHECKs temporels par SET_EPOCH).

153. ** — L'ORACLE UNITAIRE fasmg, ET LA FAUTE LATENTE ULW. Méthode :
assembler un squelette constant AVEC et SANS le mnémonique isolé
(opérandes du témoin), le delta d'octets EST la taille fasmg de
l'instruction — confrontée à SIZE_OF, elle localise en secondes ce que
le byte-diff global ne fait que signaler. Première prise : FETCH_WORD_U
= movzx RAX (REX 48 0F B7, QUATRE octets d'opcode) — la ligne ULW de la
table comptait trois ; ENUM_TEST n'exerce jamais ULW, la faute dormait
sous seize cmp muets. Leçon jumelle du contrat SIZE_OF = ENCODE : le
contrat garantit la cohérence INTERNE, seul fasmg arbitre la vérité
EXTERNE — une entrée peut être cohérente et fausse des deux côtés.
Réflexe : toute entrée nouvelle passe à l'oracle unitaire avec les
opérandes de son témoin.

154. ** — CONVENTIONS D'EXÉCUTION À CONSIGNER (TC-21, validées par cmp
et exécution du témoin) : (a) fonctions SYS_FILE_* : convention
LIEU-RÉSULTAT — l'appelant empile le slot résultat (LI 0) AVANT les
arguments ; après les pops de la macro, mov [rbp], rax écrase ce slot ;
(b) LEXCMP : normalisation 64 bits des composants (movsx/movzx/movsxd
selon siz et sgn) puis UNE comparaison signée suffit à l'ordre
lexicographique LRM 4.5.2 — taille 96 + paire de charges, huit
variantes, sauts relatifs paramétrés ; (c) BLKAND/OU/OUX : une seule
usine à opcode (BLK_OP_OCTET : and 20 / or 08 / xor 30), blocs vides
égaux/neutres ; (d) rd/rq en zone virtual : zéro octet à l'émission,
TOUTE la sémantique est l'avance de position (4×N / 8×N) à P2.

155. ** — `-GFP_ofs` S'ADRESSE AU NIVEAU DU PRO ENGLOBANT (GFP_LEVEL),
NI CUR_LEVEL NI GENERIC_BASE_LEVEL+1. Le symbole GFP_ofs se resout au
PRM du PRO courant (namespace) ; le frame qui le porte est celui de ce
PRO. CUR_LEVEL est faux dans un bloc declare (frame propre par ELB,
AUCUN PRM : [display(bloc) - GFP_ofs] lit la pile d'operandes sous le
bloc — segfault FLOAT_IO.PUT sur ROUNDING, VAL = 8.639975 pris pour
un GFP, TEST_CALENDAR/FLOAT_TEST/FLOAT_FIXED_IO_TEST) ;
GENERIC_BASE_LEVEL+1 est faux dans un PRO imbrique (n 144, MAKE_FLOAT).
Les deux corrections successives avaient oscillé entre ces deux valeurs
pour le meme site. Regle unique : CODI.GFP_LEVEL, pose par
CODE_SUBPROGRAM_BODY apres INC_LEVEL (et par CODE_PACKAGE_BODY
generique), sauvegarde/restaure comme GENERIC_BASE_LEVEL, JAMAIS
touche par CODE_BLOCK. Reflexe : toute emission de `-GFP_ofs` passe par
GFP_LEVEL ; DI(CD_LEVEL, DEFN) n'est juste que pour un parametre du PRO
courant (ancienne puce STORE_OR_CALLI). Gardiens : GENBLK_TEST (bloc
dans PRO, bloc dans PRO imbrique, appel du corps generique depuis un
bloc), TEST_CALENDAR (PUT depuis DUR_IO). Recensement mecanique des
jumeaux restants (commit 2, oracle de point fixe FINC) :
    grep -n "GENERIC_BASE_LEVEL" expander*.adb | grep "GFP_ofs"
(session 24 aout)

156. ** — PRÉCÉDENCE fasmg ET SUBSTITUTION TEXTUELLE DES PARAMÈTRES DE
MACRO. Les paramètres sont remplacés token par token (manuel fasmg §8),
et les opérateurs bit à bit lient PLUS FORT que l'arithmétique : and/or/
xor au-dessus de + - *, shl/shr/mod encore au-dessus (manuel §"Expressions").
Donc `LOAD_QUAD 8*lvl, …` évaluait `(ofs mod 8) = 0` comme
`8*(lvl mod 8) = 0` (faux pour lvl 1..7) et `ofs shr 3` comme
`8*(lvl shr 3)` (0 pour lvl 1..7). Le `local signed_ofs = ofs` en tête
des macros codi_arm64 neutralisait le second effet sans le nommer ; le
premier était ACTIF : FP_IN_RAX émettait un LDUR (voie ±255, correcte
par chance) au lieu du LDR scalé pour tout niveau non multiple de 8
(vu au désassemblage, session 25 août). Règle : dans une macro, tout
paramètre utilisé dans une expression s'écrit `(param)` ; ne jamais
compter sur un local de copie pour « fixer » la précédence. Les
comparaisons (= < >=) sont sûres (priorité la plus basse). Gardien :
grep des `shl|shr|mod|and` précédés d'un nom de paramètre nu dans les
.finc.

157. ** — ARM64 : AUCUN SAUT LLIR NE DOIT DÉPENDRE DE LA DISTANCE, ET
AUCUNE MATÉRIALISATION D'ADRESSE NE DOIT DÉPENDRE DE SA VALEUR.
(a) CBZ/CBNZ/B.cond ont ±1 Mo (imm19) : suffisant pour tout témoin,
insuffisant pour le compilateur entier (`BT STANDARD.ne_raise_`,
_STANDRD.FINC 1175, assert à chaque passe, -p épuisé). Forme longue
SYSTÉMATIQUE : cbz/cbnz x0, .+8 enjambant un B (imm26, ±128 Mo) — jumeau
arm64 du n° 82 (BT/BF rel32). (b) QUAD_CONST, qui saute les chunks nuls,
était appelée sur des références avant (retour de CALL/CALLI, cible de
LSPA, ptr+disp de LCA) : taille dépendant de la valeur de la passe
précédente, non monotone (n° 88), et contraire au contrat SIZE_OF =
ENCODE de TARGET_CODE. Règle : immédiat connu au parse → QUAD_CONST
(taille = f(val)) ; adresse → QUAD_ADDR (movz+movk, taille fixe) ou
adr PC-relatif (CALL/CALLI : adr x16, .+16). Les CBZ/CBNZ/B.cond
INTRA-macro (cibles à quelques instructions) restent légitimes.
Gardien : grep "dd 0xB4\|dd 0xB5\|dd 0x54" hors cibles locales.

158. ** — « could not generate code within the allowed number of
passes » N'EST PAS TOUJOURS UNE OSCILLATION. L'assemblage lazy
(postpone `X_ = X.elab`, n° 83/87) découvre UN niveau de la chaîne
d'appels par passe : ADA_COMP converge en 18 passes sur les DEUX cibles,
naturellement. Avec -p 20 on est à deux passes du plafond ; une chaîne
plus profonde reproduirait le message du 25 août SANS assert associé et
enverrait chercher une oscillation qui n'existe pas. Réflexe : lire le
nombre de passes en -v 2, et garder -p au défaut fasmg (100) ; n'accuser
le n° 88 que si les passes s'égrènent jusqu'au plafond avec des tailles
qui bougent. Corollaire : à passes égales, un écart de temps entre
cibles est un coût PAR LIGNE interprétée, mesurable statiquement.
