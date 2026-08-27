# ÉTAT DES PILIERS — tableau de bord TLALOC

**Dernière mise à jour : 25 août 2026**

**Régime** : ce fichier est RÉÉCRIT à chaque clôture ; il est la seule source de
vérité sur « où on en est ». Le récit des sessions est dans JOURNAL_SESSIONS.md,
les pièges dans PIEGES.md, les conventions dans CONVENTIONS_ARCHITECTURE.md,
les sorties attendues dans ORACLES_TESTS.md, l'inventaire des nœuds dans
DIANA_COUVERTURE_TRIAGE.md.

## Méthode (arrêtée le 4 juillet 2026)

Le **LRM Ada 83** est la spécification et son ordre (types → objets → expressions
→ sous-programmes → packages → génériques → tâches) l'ordre de dépendances des
piliers. Le **réseau DIANA** est le contrat d'interface énumérable (triage).
L'**ACVC** est un filet de régression, pas une méthode de conception : ses échecs
informent la priorité des piliers, ils ne constituent pas la liste des tâches.
Deux disciplines : note de **modèle d'exécution** avant chaque nouveau pilier ;
**tri systématique** de chaque échec entre « défaut local d'un pilier existant »
(correction immédiate) et « manifestation d'un pilier absent » (consignation).
La sémantique n'est protégée que par les programmes-témoins à sortie attendue
(piège n° 51) : chaque clôture ajoute son oracle à ORACLES_TESTS.md.

## Piliers clos ou acquis

| Pilier (LRM) | État | Date / référence |
|---|---|---|
| 3.5.1–3.5.4 Scalaires : entiers, énumérés, sous-types | acquis | sessions ≤ avril |
| 3.5.7 Flottants (IEEE 754 double sur pile, SSE2) | acquis | 11 avril |
| 3.5.9 Points fixes | CLOS : mul/div/conversions (F-D, élision FIX·INT, troncature vers zéro), attributs DELTA/SMALL/AFT/FORE (pliés + instanciation), sous-types, littéraux Ns≠1, FIXED_IO complet | 12 juillet |
| **3.6 Tableaux (formes contraintes, opérateurs complets)** | **CLOS** : affectation complète, égalité, ordre lexicographique, logiques booléens composites, caténation toutes formes, tranches (lecture/écriture/paramètre/retour), intervalles nuls, agrégats (positionnel/nommé/others/2D/qualifiés), conversions, attributs dimensionnés, 'RANGE (objet et marque de sous-type) | **5 juillet 2026** — oracles ARRAY_TEST1/2 |
| **3.6 reliquat non contraint** | **CLOS** objets non contraints par agrégat (bornes déduites, trou n°3), attributs sur marque, STRING dynamique, formels/retours,  conversion — ARRAY_TEST3 37/37 | **6 juillet 2026**   (ARRAY_TEST1/2, RECORD_TEST1/2, A2–A8, auto-compilation) + tag git |
| **3.7 Records à discriminants et variantes** | **CLOS** : discriminants (déclaration, contrainte, défauts, lecture, contrôle de flux), variantes statiques (layout ADDITIF), agrégats canoniques (positionnel/nommé/mixte/variantes/imbriqués), vues contraintes nommées et anonymes (objets, composants, éléments de tableau, formels, retours, qualifiés), égalité (BLKCMP sans variantes ; cascade statique à variantes), 'CONSTRAINED par objet, mutables, changement de variante | **5 juillet 2026** — oracles RECORD_TEST1/2 |
| **11 Exceptions (11.1–11.4 périmètre statique)** | **CLOS** : déclaration (STR identité `__exc.data_ptr`), raise nommé/qualifié/nu (LRM 11.3, sauvegarde par activation), handlers sur corps de procédure et blocs (dispatch CEQ/BT, others, choix multiples), propagation multi-frames par pile de contextes de reprise (VARzone, `8+lvl` qwords, EXC_MACH/EXC_RAISE seules macros codi ; runtime auto-hébergé dans _standrd.adb), sorties anticipées (return corps protégé / return handler / exit multi-blocs, pops par niveau), renames = alias d'assemblage (identité partagée, appariement croisé), prédéfinies = exceptions ordinaires de STANDARD, exception d'élaboration → contexte englobant (11.4.2), sentinelle non-rattrapée (nom + code 1) | **7 juillet 2026** — oracles EXC_TEST0/1/1U, EXC_REN0 ; filet A2–A7 + modules compilateur OK || 13 Clauses de représentation (records compacts) | acquis pour le type TREE du bootstrap | 21 juin |
| 3.8/4.8 Access minimal (`new`, `.all`) | minimal bootstrap | 22 juin |
| 5, 6 Instructions, sous-programmes, blocs | acquis (PRO/ELB/UNLINK, display, blocs declare) | ≤ avril + pièges 47–48 + actuals out/in out composants indexés/sélectionnés (piège n° 77, correctif CODE_PROCEDURE_CALL, témoin OUTARG1, 8 juillet).|
| 8.5 Renames d'objets | modèle pointeur complet pour le bootstrap : élaboration (adresse réelle, y compris constante prédéfinie — pliage sensible à IS_SOURCE, n° 105), usages avec REGIONS_PATH ; tranches par doublet CODE_SLICE ; nombre nommé/littéral d'énum en contexte adresse ⇒ lève | 18 juillet 2026 |
| 12 Génériques (packages, sous-programmes, thunks LD/ST CALLI) | acquis | avril + 4 juillet (piège 47) |
| **14.3 TEXT_IO** | **CLOS** (conforme LRM sous restrictions consignées) : architecture deux niveaux RAW/public (GET_RAW/PUT_RAW hors spec ; scanners et lecteurs de structure sur RAW, NEW_LINE/NEW_PAGE émettent en RAW) ; GET public saute les terminateurs et tient LINE/COL/PAGE ; PUT tient COL, coupure implicite à LINE_LENGTH bornée ; SET_COL/SET_LINE sortie ; longueurs COUNT := UNBOUNDED (bombe POSITIVE_COUNT := 0 désamorcée) ; exceptions toutes armées (STATUS/MODE/NAME/USE/END/DATA/LAYOUT, 14.2.1 complet, piège n° 45 désamorcé) ; cadrage énuméré WIDTH en blancs de queue (RM 14.3.9, déviation supprimée) ; FF séparateur des scanners et terminateur de ligne. Restrictions consignées : SET_COL/SET_LINE en entrée différés ; END_OF_FILE/END_OF_PAGE mono-anticipation (piège n° 79) ; copies FILE_TYPE non partagées (état COL/look-ahead divergent entre handles) | **8 juillet 2026** — oracles TEXT14 (42), OUTARG1, IO_TEST |
| 14.2.3 / 14.2.5 SEQUENTIAL_IO, DIRECT_IO | validés tous types ; **témoins DIRECT_IO_TEST et SEQ_IO_TEST repris auto jugeant ** |
| 9.6 CALENDAR | CLOS avec témoin (TIME_OF/SPLIT/opérateurs/rollover/CLOCK ; 1900/2100 → CONSTRAINT_ERROR attendus) | 12 juillet |
|CHECKS RUNTIME|PÉRIMÈTRE 1 CLOS Amont du pilier 11 : comparer-et-brancher vers deux trampolines uniques (ce_raise_/ne_raise_, wrapper FAS). Checks livrés et jugés : gamme scalaire aux SEPT sites (affectation, init de déclaration, param in, return, conversion, qualification, corps générique partagé via GFP/_ENUM_USE_INFO), longueurs des logiques composites (dette D3-contrôle SOLDÉE), index (quatre variantes de CODE_INDEXED), division par zéro (/, mod, rem → NUMERIC_ERROR, fidélité LRM 83). Commutateur global CODI.CHECKS_ENABLED — défaut TRUE, RÉGIME PERMANENT ; OFF réservé au tri des fossiles. Élision : sous-type = type de base (comparaison de nœuds) + garde n° 80 (sous-types anonymes) + statique prouvé. Témoins : CHK_TEST0/1, CHK_LEN0, CHK_IDX0, CHK_DIV0, CHK_ANON0, CHK_CSTPRM0/1/2, CHK_PREDEF0. Filet + ACVC verts checks ON et OFF. Note : NOTE_MODELE_CHECKS v1.4. Campagne de fossiles associée (voir PIEGES n° 80–84) : IDENT_* de l'ACVC ressuscités (n° 81, actuels constants fantômes — trois familles), oscillation fasmg BT/BF soldée (n° 82, tous sauts rel32), amorçage STANDARD réparé (n° 83, LINK 0 avant _STANDRD), lecture des formels génériques in-out réparée (n° 84, adaptateurs INADR/OUTADR branchés côté lecture). DETTES PÉRIMÈTRE 2 (consignées, note §8) : overflow (NUMERIC_ERROR après chaque op — coût), STORAGE_ERROR (bump allocator), gamme fixed/float (bornes fixed élaborées SCALÉES : comparaison directe possible), discriminants (avec pilier 3.7 bis), null access sur .all, checks d'élaboration (PROGRAM_ERROR), copy-back des out (6.4.1 côté retour), contraintes ANONYMES d'objet (n° 80-a), pragma SUPPRESS, élision d'index statique (affaire de l'optimiseur futur).
| Bootstrap : **Jalon POINT FIXE DU BOOTSTRAP (12 aout 2026 13h20)** | T1 (compilé gnat) -> 63 FINC -> T2 (fasmg). T2 recompile les 63 unités : FINC(T2) IDENTIQUES à FINC(T1), octet pour octet, checks ON. fasmg produit T3 = T2. TLALOC est auto-hébergé et idempotent. Le diff des 63 FINC entre deux générations devient l'ORACLE DE NON-RÉGRESSION SUPRÊME : tout remaniement futur (mark/release co-pile, scission d'expander-expressions, optimiseur) doit le laisser vide ou justifier chaque ligne du diff.
 | 18 juillet 2026 |
 | **TARGET_CODE (assembleur natif LLIR/FINC → ELF64, remplaçant fasmg)** | **CLOS — POINT FIXE** : table EMITS = codi x86_64 entier (contrat SIZE_OF = ENCODE par élément, refus « hors tranche » en filet pour les extensions du codi) ; motifs du corpus compilateur acquis : blocs Ada (ELB sans PRO), labels pointés/thunks génériques, entité unique symbole/namespace, redéfinition séquentielle name = $ (époques), rq ; jauges CARTO + bornes calibrées (ADA_COMP : 765 721 éléments, 14 Mo de texte, 200 347 symboles, 10,3 Mo émis) ; **ADA_COMP byte-identique à fasmg, exécutable, et le compilateur assemblé par TARGET_CODE se recompile lui-même — chaîne intégralement auto-hébergée, assemblage ~3× plus rapide que fasmg** | **24 août 2026** — oracles TC_TEST04…25 (chaîne du pilote), avalements DIS_BONJOUR / ENUM_TEST / DIRECT_IO_TEST / SEQ_IO_TEST / ADA_COMP muets |
| **Cible arm64 (codi_arm64.finc)** | **BOOTSTRAP CROISÉ** : compilateur arm64 assemblé par fasmg+codi_arm64 (BT/BF forme longue ; CALL/LCA/LSPA de taille FIXE — adr, QUAD_ADDR ; QUAD_CONST taille = f(val) ; display en encodage direct ; contrat SIZE_OF = ENCODE respecté, prêt pour TARGET_CODE arm64). Exécuté sur Orange Pi 3B (4×A55) : compile tout le source du compilateur en 5 min ; **FINC IDENTIQUES à ceux de T2 x86 (assemblé par TARGET_CODE), octet pour octet**. Manque : assembleur natif sur le Pi (fasmg est x86) → TARGET_CODE arm64. Assemblage fasmg arm64 : 548 s (×2,9 de x86, 18 passes) | **25 août 2026** — oracle diff_finc.sh Pi/laptop vide ; pièges n° 156–158 |

 

## Fondations absentes (piliers non ouverts)

| Pilier (LRM) | Manque | Note |
|---|---|---|
| 3.4 Dérivation | derived_def, derived_subprog | — |
| 8.x Portée, visibilité, use, renommage complet | causes-mères présumées des 4 échecs A8 | tri à faire avant d'ouvrir |
| 9 Tâches | tout | reporté |
| 12.1.3 Défauts de formels génériques | box/name/no_default | CALLI en place (TODO 5.3) |

## Dettes et restrictions consignées (n'empêchant pas les clôtures prononcées)

- **D5-complet** (3.6/4.6) : bornes du résultat de conversion = celles de la
  source ; faux si consommées directement. Re-étiquetage au sous-type cible à faire.
- **D6** (3.6) : bloc info anonyme câblé 1-dim (concat, agrégat dynamique,
  résultat de fonction). Le lot D3 l'a CONTOURNÉE en réutilisant l'info de
  l'opérande gauche — argument pour généraliser ce contournement.

-**D-C7a**. Fonction ORDINAIRE retournant tableau a bornes dynamiques :
       temoin du (modele unique C7) ; dette D6 (bloc info anonyme
       1-dim) susceptible de mordre — a exercer AVANT le premier site.
-**D-C7b**. Temoin negatif return TAB2D(I) (rameau 2D du meme modele).
-**D-C7c**. Modele generique SANS parametre Ada : NO_SUBP_PARAMS=TRUE →
       RTD nu laisse [slot, GFP], GFP AU SOMMET. Inoffensif sur les
       chemins actuels (wrapper UNLINK) ; MORDRAIT une fonction
       generique SCALAIRE sans parametre (le rapatriement prendrait le
       GFP pour le resultat). Temoin avant correctif.
-**D-C8a**. Clause d'adresse de SOUS-PROGRAMME (SYSTEM_CALL at 16#...#) :
       chantier separe, protocole d'appel a instruire.
-**D-C8b**. Mode OUT en cible d'overlay (situation C3 : lire l'actuel avant
       ecriture) ; adresse ABSOLUE d'objet ; scalaire-sur-composite ;
       equation cross-niveau/namespace ; tailles scalaires differentes
       (tolere, non asserte).
-**D-ant**. Inchangees d'avant : n 117-bis (rep d'enumeration, machinerie
       ordinale) ; alignement/variantes des representes (n 117) ;
       mmap + 448 Mio ; double evaluation memberships ; assert
       d'equilibre de pile a PERENNISER en mode debug (a poser POUR la
       reprise segfault, point 4 du memo).



- **D10** (4.1.4) : attributs à préfixe non nommé (tranche, indexé, appel) ;
  même famille : `return (S(2..3))`.
- **D3-contrôle** (4.5.1/11) : pas de contrôle `LEN_G = LEN_D` des logiques
  composites — CONSTRAINT_ERROR différé au pilier exceptions.
- **CODE_QUALIFIED** : records qualifiés (même vice que tableaux avant D9,
  pilier 3.7) ; branche non contrainte suppose une association nommée unique.
- **CODE_USED_NAME_ID** : SOLDÉE 28/07 (vague 1, n° 118) — else TROU(),
  branche exception annotée INTENTIONNELLE.
- **'IMAGE/'VALUE** d'énuméré hors générique → pilier 3.5.5 ('VALUE
  ENTIER fait le 28/07 : primitive STANDARD.INTEGER_VALUE + CODE_VALUE ;
  l'énuméré reste au carnet TROU).
- **A8** : 4 échecs consignés (renommage, use, portée, visibilité).
- **FIXED** : mul/div générales incomplètes (suffisantes pour DURATION).
- Mélange `and then`/`or` non parenthésé mal géré (TODO §5.2 historique).
- Généralisation LD/ST CALLI aux formels entiers/flottants (TODO §5.1 historique).

- **AGG-NC restrictions** (3.6, UNCONSTRAINED_AGGREGATE_OBJECT) : bornes
  déduites délibérément conservatrices — positionnel à cardinal statique, ou
  nommé à choix DN_NUMERIC_LITERAL (min/max calculés dans l'expander) ;
  multidim, choix dynamiques, mixte, `others` → refus bruyant. À élargir si
  un test ACVC l'exige.

- **DN_QUALIFIED à marque non contrainte** (COMPILE_ARRAY_VAR l. ~666) : même
  vice latent que l'ex-branche agrégat (COVAR_ALLOCATE sur SIZ = -1). Aucun
  témoin ne l'exerce ; le jour venu, router vers
  UNCONSTRAINED_AGGREGATE_OBJECT.

- **Marcheur `_aga`** : la retombée ADD_INDEX_DIMENSION sur index non
  contraint calcule des _FST/_LST faux (range du sous-type d'index) —
  INERTES pour l'émission des données (placement séquentiel par _PTR), mais
  non autoritaires : les bornes d'un agrégat ne font foi QUE publiées dans
  un descripteur. Ne pas « corriger » sans témoin, code partagé (D9, 2D,
  qualifiés).

- **Co-pile monotone (piège n° 70)** : R14 ne redescend jamais en flux
  normal — convention PORTEUSE du retour de tableau par référence ; fuite
  CO_VAR en boucle (budget 1 Mo). Refonte = futur pilier « retours
  composites par copie ». Jumelle de la fragilité déjà consignée des
  retours de tableaux CONTRAINTS (donnée en VARzone du frame mort).

- **TEXT_IO conformité 14.3.3** : fichiers standard initialisés avec
  PAGE_LENGTH=72 / LINE_LENGTH=256 au lieu de 0 (non borné). ARMÉ : form
  feed inséré à la 73ᵉ ligne de toute sortie longue (les oracles diff le
  verront). Correctif conjoint requis : longueurs 0 + garde
  `PAGE_LENGTH /= 0 and then` dans NEW_LINE (et audit des usages de
  LINE_LENGTH le jour du cadrage de PUT).

- **STD_INPUT.AT_END_OF_FILE / HAS_LOOK_AHEAD non initialisés** (VARzone
  non zéroée) : look-ahead fantôme possible au premier GET console.

- **DIRECT_IO/SEQUENTIAL_IO : gardes LRM 14.2.1 absentes** (CREATE/OPEN
  sur fichier déjà ouvert → STATUS_ERROR ; échec d'OPEN → NAME_ERROR ;
  CLOSE/DELETE sur fichier fermé → STATUS_ERROR) — lot conjoint à
  planifier sur le modèle TEXT_IO du 8 juillet ; DIRECT_IO_TEST v2 /
  SEQ_IO_TEST v2 acceptent déjà le régime futur. DELETE ne ferme pas le
  descripteur système (fuite d'fd bénigne, à reprendre dans le même lot).

- **Handlers sur corps de PACKAGE** : ANOMALIE bruyante (exceptions
  d'élaboration, différé).

- **Exceptions pendant l'élaboration des unités de bibliothèque** (avant
  le CALL du programme) : atterrissent sur la sentinelle — acceptable.

- **TASKING_ERROR** : symbole déclaré, jamais levée (pilier 9).

- **`goto` sortant de corps protégé** : même comptabilité de pops que
  return/exit, à faire quand CODE_GOTO existera (pilier 5.9) —
  HANDLER_CTX_AT est prêt.

- **SM_RENAMES_EXC au rechargement DCL** : régime constaté au LCA émis par
  text_io recompilé (noter au journal lequel) ; sans conséquence — l'alias
  garantit la correction dans les deux régimes.

- **Checks runtime (CONSTRAINT_ERROR & co.)** : hors pilier 11 ; le point
  d'entrée est prêt (`LCA STANDARD.<X>__exc.data_ptr` + `Sa EXCEPTIONS_
  CURRENT` + `BRA exc_raise_`).

- **Actuels génériques non-sous-programmes** (12.3, A87B59A) : trois
  familles sans convention d'exécution — (1) littéral d'énumération
  comme fonction : l'instanciation stocke la position (`Sb F_disp`),
  le corps partagé CALLI `F__call_ofs` jamais écrit ; thunk résultat
  faisable à court terme (pattern LD_/ST_, convention result__ofs) ;
  (2) opérateur prédéfini : `VAR __call_ofs` sans store ; thunk
  opérateur, "&" sur STRING = le morceau dur (résultat composite) ;
  (3) entrée de tâche : bloqué pilier tasking (la tâche elle-même est
  élidée du FINC). A87B59A assemble, segfaute au bloc C. Corollaire :
  le corps générique partagé INLINE les opérateurs du type formel
  (bloc E : ADD au lieu de CALLI) — faux pour une instance à opérateur
  utilisateur, et masque l'absence de thunk.
- **CODE_SELECTED, branche scalaire à préfixe package** : nom nu sans
  REGIONS_PATH (piège n° 85) — casserait à l'assemblage si exercé.
- **SUBPROGRAM_ORIGIN non appliqué** au chemin fonction ni aux actuels
  génériques qui seraient des renamings (piège n° 82).
- **REGIONS_PATH et sous-unités** : corps générique `is separate`
  (xd_stub / XD_BODY) non vérifié au dump (piège n° 84).
  
 - **conformité TIME_ERROR de TIME_OF**  (le 31/2 passe et se normalise en silence) ; NUM'DIGITS instance-dépendant en corps partagé (aujourd'hui figé à la valeur machine — un champ DIGITS dans le use__info flottant le jour venu).
 
 **Dettes du pilier fixed (frontières tenues par ANOMALIE) :**
- F-D générique : T(X*Y) sur formels en corps partagé (ANOMALIE posée) ;
  fixed→fixed générique encore par comparaison de chaînes ; Q2 use__info
  étendu (AFT/FORE/DELTA runtime) différé — aucun consommateur réel.
- 'DELTA/'SMALL de formel à l'instanciation : AFT/FORE servis, les deux
  autres sur ANOMALIE en attendant un cas réel.
- Overflow des opérations fixed (dont MUL 64 bits de rX·rY avant
  rescale) : Périmètre 2 des checks, avec la gamme fixed/float.
- CALENDAR : TIME_OF ne lève pas TIME_ERROR (31/2 normalisé en silence).
- NUM'DIGITS en corps partagé : valeur machine figée (champ DIGITS du
  use__info flottant le jour venu).
**Dettes sem (front-end intact, décision mainteneur) :**
- sem-1 : small défaut = delta/2 (RM 3.5.9(6) dit « ≤ delta » ; VF
  « juste inférieure » à vérifier au papier) — les oracles fixed en
  DÉPENDENT tous.
- sem-2 : rejet de A*N nu (RM 4.5.5(9-10) le prédéfinit) — les C45x
  ACVC échoueront à la compilation ; instruire aussi A*2.0.
- sem-3 : 'AFT/'FORE pliés à 3 en dur (vrais : AFT=1, FORE=4 pour T8) —
  divergence documentée : attribut d'instanciation JUSTE (calcul
  expander), attribut direct FAUX (pliage sem).

 **Dettes audits différés debogage bootstrap**
 - [ ] Co-pile : mark/release par instruction dans l'appelant (n° 109) ;
      intermédiaire possible : épilogue libérant pour procédures.
- [ ] `La` nus restants à trier avec la question unique « l'opérande
      amont est-il @doublet par construction ? » : instructions 1517,
      1576, 1638, 1898 ; expressions 756. Sains vérifiés : 1763
      (LCA .data_ptr), declarations 1372 (doublet CODE_SLICE).
- [ ] declarations ~1703 : contrat de CODE_ACTUAL_OBJECT_VALUE
      (objet formel générique) vis-à-vis de la convention n° 112.
- [ ] Branche TABLEAU de CODE_RETURN : suppose @doublet_src ;
      `return TAB2D(I)` ferait le trou du n° 112. Non exercé.
- [ ] SELARG/INDARG : factoriser en un helper ; ni l'un ni l'autre ne
      teste DN_CONSTRAINED_RECORD (dette commune) ; out/in-out
      composites INDEXÉS non normalisés (les sélectés le sont).
- [ ] Renaming : DN_CONSTRAINED_RECORD absent d'IS_COMPOSITE (pas de
      __u émis) ; bloc commenté l. ~1348-1352 porte l'ancien bug de
      niveau si ressuscité.
- [x] DN_SLICE en composant d'agrégat : refus bruyant POSÉ dans
      CODE_COMPOSITE_DATA_ADDRESS (vague 2, 28/07).
- [ ] Normaliser l'orthographe d'émission `La  ,  0` (supprimer les
      `La` nus) pour rendre les greps exhaustifs par construction.
- [ ] Dette C1 (LRM 4.6(11), posée le 30/07) : conversion vers tableau
      dérivé à sous-types d'index de profils DIFFÉRENTS — glissement
      de bornes + vérification d'index NON ÉMIS (identité seule ;
      corpus : mêmes profils, non exercé — témoin à créer le jour où).
- [ ] Oracle manquant : fonction ORDINAIRE retournant un tableau
      contraint à bornes dynamiques (le n° 111 ne fut vu que via UC) ;
      oracle énuméré >128 littéraux avec array(ENUM) (n° 107-108).
      
  ORACLE B :
    1. CONV_DER1 : « RESULTAT :  12 OK,   0 ECHECS » + « CONV_DER1 PASSE » ;
       comparer à la sortie de référence GNAT (identique).
    2. Diff FINC du témoin (avant = FINC SUSPECT du commit A, après =
       re-expansion) : SEULES les lignes « ; !! TROU » disparaissent,
       aucune autre émission ne change (l'identité n'émet rien — oracle
       gratuit des suppressions de no-op, technique du 28/07).
    3. Re-run RECENSEMENT auto-compilation : compteur 187 → 127, la
       famille « CODE_CONVERSION cible non faite » ABSENTE du bilan
       (si résidu : ce sont d'autres cibles — les laisser au TROU, ne
       PAS élargir la branche ; doctrine n° 122, bénir l'observé).
    4. Re-expansion STRICT de set_util et d'idl : aucune ligne
       « !! TROU » pour ces unités ; FINC assemblés.
    5. Filet complet (corpus + ACVC A2..A8 + témoins + auto-compilation)
       inchangé ; CONV_DER1 ENTRE au filet ; tag git à la clôture.

- [ ] Garde NE_RAISE si SIZ=0 au doublet résultat tableau contraint
      (appel avant élaboration du type — tordu mais légal).
- [ ] diana.bin : consigner LAST_NODE/LAST_NODE_ATTR relus comme
      invariant logique (la taille fichier ≠ gnat est un non-critère).

 - **Carnet TROU — CAMPAGNE « EXPANDER BRUYANT » CLOSE le 28/07**
  (5 vagues + 6 reclassements post-recensement ; livraisons par
  fichiers d'instructions ancrés, contre-épreuve par rejeu). Définition
  de fini ATTEINTE : grep null; → tout INTENTIONNEL ; when others →
  raise/TROU/DEFAUT DOCUMENTE ; aucun dispatch sans else (revues
  systématiques, 12 dispatchers HORS listes du triage trouvés) ;
  demi-bruyants tous à verdict. Le run RECENSEMENT auto-compilation
  rend 187 traversées / 10 familles = LE PLAN DE TRAVAIL (chantiers
  C1-C8, cf. BILAN_RECENSEMENT_TRIAGE.md ; segfaults SUSPENDUS jusqu'à
  la mise en ordre — décision du 28/07).
  Trous vivants par familles (tous bruyants en STRICT) :
  chantiers C1-C7 du bilan (conversions dérivées 60, case sous-type 84,
  lecture OUT 2, init tableau par objet 3, exponentielle 22, tranches
  ALL/INDEXED 3, instanciation à résultat non contraint 10 — à fusionner
  avec la dette « RESULTAT UNCONSTRAINED » de l'épilogue et l'oracle
  tableau-contraint-dynamique : UNE note de modèle) ;
  C8 'ADDRESS overlay : 3 sites, dossier CHANTIER_ADDRESS_OVERLAY.md,
  recommandation voie 3 (réécriture source en UC) ;
  tasking (pilier 9) : corps + attributs, inchangé ;
  rep-clauses DISCRIMINÉES (reclassements 3-5) : ENUM à agrégat =
  n° 117-bis (machinerie ordinale non auditée : 'POS/'VAL identité,
  SUCC/PRED par INC/DEC, indexation par la valeur — SM_POS→SM_REP de
  l'actuel énuméré DÉJÀ aligné) ; at-mod > 8 ou non statique ;
  'LAST_BIT/'POSITION ; clauses de LONGUEUR = INTENTIONNEL (pliées
  front-end : CD_IMPL_SIZE — vérifier au premier témoin 'SIZE) ;
  arbitrage ouvert : TYPE_SIZE scalaire ignore CD_IMPL_SIZE (test-miroir
  n° 110, croiser n° 117) ;
  frontières : SELARG/INDARG (factorisation + normalisation indexés
  out/in-out, gardes TROU posées, témoins à créer) ; « adresse seule
  vers formel in composite » (observation vague 3, à confronter n° 112) ;
  divers : handlers de corps de package (DEFAUT DOCUMENTE, pilier 11),
  CODE_DERIVED_SUBPROG (SUBPROGRAM_ORIGIN ne suit pas la dérivation),
  attributs restants ('RANGE expression, 'VALUE énuméré, AS_EXP direct).
  ÉLUCIDÉS EN CAMPAGNE (plus au carnet) : IMPLICIT_NOT_EQ (résolu au
  site d'usage), DEFERRED_CONSTANT (LRM 7.4), épilogue instanciation
  (corps synthétisé/partagé, slot résultat), « A VOIR », scorie
  DN_FIXED (morte, supprimée), CODE_ADRESSE (mort présumé, ceinturé),
  PREDEF_NAME de STANDARD, renommage de paquetage (garde avant
  namespace).

Vigilance (etat au 6 aout, apres commits 1-8) :

  - INDARG (element T(I) en actual, dette n 112) et actual AGREGAT vers formel non contraint :
    memes suspects patron, a auditer au classifieur puis remede CODE_ARRAY_OPERAND.
  - Gardes bruyantes restantes de COMPILE_ARRAY_VAR (objet entier, qualifie non-agregat sur non
    contraint) : remede sur etagere (3 lignes, modele commit 8).
  - Tableaux de tableaux : temoin TBL(I)(J) a creer avant tout chantier (la forme n'est PAS au filet).
  - T'SIZE via use__info sur type non contraint (expressions ~2956) : LECTEUR de SIZ=-1, classe C.
  - Dead stores classe B (pre-init __u := patron ecrasee) : laids, benins -- nettoyage de confort le
    jour de PUT_USE_INFO_REF.
  - Chantier de cloture : CODI.PUT_USE_INFO_REF (le point unique des __u), completant le triptyque
    TYPE_INFO_STR (noms, n 99) / CODE_ARRAY_OPERAND (doublets, commit 8) / PUT_USE_INFO_REF (__u).
  - Branches soeurs de CODE_ARRAY_OPERAND (retour de fonction, acces designe Q1b) vers le remede
    durable "__u -> bloc elabore" au lieu de re-evaluer.

Vigilances versees/mises a jour 7 août 2026 :
- Famille n 112 : 4 occurrences connues et soldees, audit grep du
  reliquat recommande AVANT le gros de LIB/SEM_PHASE (piege n 129) ;
  site "A VERIFIER" restant dans expander-instructions
  (DESTINATION_SELECTED, tableau non-agregat), aucun temoin ne
  l exerce.
- CD_IMPL_SIZE des DN_RECORD ordinaires faux (64) : contourne aux
  deux sites agregat (taille symbolique), poseur types_decls a
  auditer, autres consommateurs de COMP_SIZE_BITS a recenser
  (piege n 130).
- Runtime TEXT_IO bootstrappe en CRLF : tolerance fasmg a verifier au
  premier FINC produit par le bootstrappe ; normalisation obligatoire
  des diffs de traces (piege n 131).


## Prochaine séquence (arrêtée le 25/08 — bilan recensement)
 
  - TARGET_CODE arm64 (fermer la boucle sur le Pi sans fasmg) : traits (ELF aarch64
    E_MACHINE 183, PAD 0, CALL_FRAME 16, syscalls openat/unlinkat, p_memsz), puis table
    EMITS par tranches comme x86 (TC-04 : DROP DUP LI ADD SUB MUL BRA SYS_EXIT d'abord),
    SIZE_OF = 4 × nombre de mots (LI = 4·max(1, min(nz, nf)) + 8, CALL 16, LCA/LSPA 16),
    séquences fixes du runtime (EXC_*, CO_*, chaînes, SYS_*) recopiées. Oracle : binaire
    IDENTIQUE à fasmg+codi_arm64 sur les mêmes FINC (oracle unitaire n° 153 par
    mnémonique), exécution sur le Pi, puis T2_arm → FINC → TARGET_CODE arm64 → T3_arm = T2_arm.

1. Rédiger la note de modèle d'exécution du pilier retenu AVANT de coder.
2. Filet complet + tag git à chaque clôture.

## Fichiers à uploader en début de session

Les 8 `expander*.adb`, `codi_x86_64.finc`, les paquetages IO concernés,
`machine_code.ads`, le programme de test en cours, et ce dossier documentaire.
+ analyse de segfault

## restrictions pilier 3.7 (périmètre 1)

- Égalité de records à variantes : champ par champ, variante active seule
  (RM 4.5.2), générée par cascade statique. Restent BRUYANTS : champ record
  à variantes imbriqué, champ tableau, choix par intervalle. Flottants
  comparés bit à bit (comme BLKCMP).
- Égalité : opérande agrégat non supporté (refus bruyant).
- Composants dépendant d'un discriminant : hors périmètre (garde
  SM_DEPENDS_ON_DSCRMT disponible, FALSE partout dans TEST1).
- Fonctions ordinaires retournant un COMPOSITE (record OU tableau
  contraint) : le slot résultat de l'APPELANT prend le placeholder LI 0
  alors que le CORPS (CODE_RETURN record + épilogue RTD prm_siz-8)
  DÉRÉFÉRENCE le slot comme @doublet du lieu résultat — PROUVÉ le 30/07
  par CONV_DER1 v1 : segfault dans MK_L18 (La 2,-result__ofs ; La ,0
  sur 0).  Reproduction minimale : S : REC := F(7).  Côté corps :
  CORRECT ; côté appelant d'INSTANCIATION (TO_CHN) : CORRECT — modèle à
  copier le jour du chantier (fusionner avec C7/NOTE_MODELE, jumelle de
  C10).  CONV_DER1 v1 (function MK) archivé comme témoin FUTUR de ce
  chantier ; v2 passe par procedure MK( N ; S : out SET ).
- Catégorie E → couvert : dscrmt_decl, dscrmt_decl_s, dscrmt_constraint,
  variant_part, variant_s, comp_list (à sortir du triage DIANA).
- 'CONSTRAINED d'un formel de type mutable : approximation statique
  (TRUE exact si type sans défauts ; FALSE commenté dans le FINC sinon,
  la valeur exacte suit l'actuel — flag caché à l'appel, différé).
- Défauts de discriminants d'un COMPOSANT record à l'élaboration du parent
  (RM 3.2.1) : non émis, aucun témoin ne l'exerce.
- Déviation console : PUT d'énuméré avec WIDTH cadre à DROITE (blancs de
  tête, RM 14.3.9 prescrit blancs de queue) ; PUT vers chaîne conforme.
  À harmoniser au pilier 14.Dernière mise à jour : 7 juillet 2026 (clôture pilier 11, exceptions — lots E-A1..E-A4, E-B, E-C).Dernière mise à jour : 7 juillet 2026 (clôture pilier 11, exceptions — lots E-A1..E-A4, E-B, E-C).
  
  **24 août 2026 — POINT FIXE SANS fasmg** : TARGET_CODE assemble
ADA_COMP à l'identique, l'exécutable recompile ses propres sources ; la
référence fasmg passe du rôle d'outil à celui d'ORACLE DE RÉGRESSION
(cmp sur corpus figé). Vigie capacités : éléments à 77 % de la borne
(765 721 / 1 000 000) — au prochain élargissement du corpus, passer
ELT_MAX à 2 000 000 et OPS_MAX à 6 000 000.
    contamination ?).