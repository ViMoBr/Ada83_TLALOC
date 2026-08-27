# CONVENTIONS ET ARCHITECTURE — référence stable

Contenu quasi-invariant : architecture des sources, conventions LLIR,
mécanismes CALLI (LD/ST, ADR), flottant SSE2, architecture TEXT_IO.
Les PIÈGES sont dans PIEGES.md ; l'état d'avancement dans ETAT_PILIERS.md.

## 6. Architecture de l'EXPANDER (7 fichiers)

```
expander.adb                  Programme principal + CODE_ROOT
  ├── package UTILS           Constantes, types, utilitaires
  │   └── body separate       expander-utils.adb
  ├── package EXPRESSIONS     CODE_EXP, CODE_NAME, etc.
  │   └── body separate       expander-expressions.adb
  ├── package DECLARATIONS    CODE_DECL, CODE_HEADER, etc.
  │   ├── body separate       expander-declarations.adb
  │   └── package TYPES_DECLS CODE_TYPE_DECL, CODE_RECORD_DECL, etc.
  │       └── body separate   expander-declarations-types_decls.adb
  ├── package INSTRUCTIONS    CODE_STM_S, CODE_ASSIGN, etc.
  │   └── body separate       expander-instructions.adb
  └── package STRUCTURES      CODE_COMPILATION_UNIT, CODE_BLOCK_BODY
      └── body separate       expander-structures.adb
```


## 7. Conventions LLIR à retenir

- **Pile croissante** (RBP vers le haut). Paramètres sous le FP
  (offsets négatifs). Variables locales au-dessus (offsets positifs).
- **Display** à R15 : 32 niveaux lexicaux.
- **Co-pile** (R14/R13) : allocations dynamiques.
- **Tailles** : b=1, w=2, d=4, q=8. Suffixe 'a' = 'q'.
- **Flottants** : toujours qword (q) sur la pile, IEEE 754 double 64 bits.
  FLOAT (CD_IMPL_SIZE=32) et LONG_FLOAT (64) tous deux en double.
- **Short-circuit** : `A and then B` → DUP, BF skip, DROP, eval B, skip:
  `A or else B` → DUP, BT skip, DROP, eval B, skip:
- **Doublet composite** : `_disp` + `__u`. Passage = adresse du doublet.
- **PRM result__ofs en dernier** dans les fonctions.

- **result__ofs en corps générique** : le PRM GFP_ofs s'intercale entre
  les paramètres et result__ofs (ordre CODE_PARAM_S : params, GFP_ofs si
  IN_GENERIC_BODY, result__ofs si fonction). Slot résultat =
  -8(N params + 2). Piège n° 80.
- **Opérateurs d'un type déclaré dans un package** (dont FILE_MODE des  instances IO) : l'infixe exige un `use` local — l'égalité prédéfinie
  est implicitement déclarée DANS le package et LRM 8.4(5) ne la rend
  pas visible par qualification (l'infixe ne se qualifie pas ; `use
  type` n'existe qu'en Ada 95). Le frontend est CONFORME — le
  « DESACCORD DE TYPE » sur `MODE(F) = IN_FILE` hors clause use n'est
  pas une anomalie. Idiome : `declare use <instance>; begin … end;`.
  Alternative (renommage d'opérateur, 8.5) à éviter tant que le tri A8
  renommage/visibilité n'est pas fait. (session 9 juillet)
- **SD après syscall** : transférer `[rbp]` vers result__ofs.
- **NOT booléen** : `LI 1` + `OUX`. Pas `NON` (bitwise).
- **Syntaxe virgules vides** : `LIa , , offset` / `Ld , FIELD`.
- **Opérateurs mot-clé** : MAJUSCULES dans le symrep DIANA.
- **While** : `BF` (pas BRZ).
- **Fins de ligne Linux** : LF seul. CR ignoré. FF = saut de page.
- **Transferts flottants pile↔xmm** : toujours `movsd` (F2 0F 10/11),
  jamais `movq` (ambigu avec movd 32 bits dans certains contextes fasmg).
- **Blocs declare** : toujours `UNLINK N` avant de quitter le bloc.
- **Wrapper générique** : `La` pour composites et out/in_out, `Lq`
  uniquement pour les `in` scalaires.
- **postpone LIFO** : les `CST` en zone `postpone` sont placés en
  mémoire dans l'ordre inverse de leur émission.
- **GFP_disp** : marqueur d'adresse uniquement — son contenu n'est pas
  utilisé, seule son adresse sert de référence pour les offsets négatifs
  vers les VAR de l'instance (session 25 avril).
- **Correspondance miroir PRM/VAR** : les PRM du namespace du modèle
  (croissants : 8, 16, 24) correspondent aux VAR de l'instance en
  ordre inverse avant GFP_disp (décroissants : -8, -16, -24).
- **CALLI pour LD/ST** : `La lvl, -GFP_ofs` puis `La , -TYPE__st_ofs`
  (simple, pas LIa indirect). Le contenu de `__st_ofs` est déjà
  l'adresse de saut, pas un pointeur.
- **Niveau du GFP** : toute émission de `-GFP_ofs` s'adresse au niveau
  `CODI.GFP_LEVEL` (PRO englobant le plus proche, posé par
  CODE_SUBPROGRAM_BODY, jamais par CODE_BLOCK). Ni `CUR_LEVEL` (faux
  dans un bloc declare : frame sans PRM) ni `GENERIC_BASE_LEVEL+1`
  (faux dans un PRO imbriqué). `DI(CD_LEVEL, DEFN)` n'est juste que
  pour un paramètre du PRO courant. Pièges n° 144 et 155.


## 2. Macros CODI_x86_64 — SSE2 flottant (session 11 avril)

### Convention flottante LLIR

Les flottants IEEE 754 double 64 bits transitent par la **pile entière**
(qword) exactement comme les entiers. Les macros SSE2 chargent/déchargent
depuis la pile vers les registres xmm0/xmm1 pour les opérations.
Transferts pile↔xmm via `movsd` (F2 0F 10/11), toujours 64 bits.

FLOAT (32 bits nominal dans STANDARD) et LONG_FLOAT (64 bits) sont tous
deux stockés en double 64 bits — OPER_SIZ_CHAR force 'q' pour DN_FLOAT.

### Macros ajoutées (15 + CALLI)

| Macro | Rôle | Encodage x86-64 |
|-------|------|-----------------|
| LIF val | Load Immediate Float | movabs rax, dq val + PUSH_RAX |
| FADD | Addition | movsd + addsd xmm0,xmm1 + movsd |
| FSUB | Soustraction | movsd + subsd + movsd |
| FMUL | Multiplication | movsd + mulsd + movsd |
| FDIV | Division | movsd + divsd + movsd |
| FNEG | Négation | xor byte [rbp+7], 0x80 |
| FABS | Valeur absolue | and byte [rbp+7], 0x7F |
| FEXP | Exponentiation A**N | boucle mulsd (N entier) |
| CVTIF | Entier→double | cvtsi2sd xmm0,rax + movsd |
| CVTFI | Double→entier | movsd + cvttsd2si (troncature) |
| FCEQ | A = B | ucomisd + sete + setnp + and |
| FCNE | A /= B | ucomisd + setne + setp + or |
| FCGT | A > B | ucomisd xmm0,xmm1 + seta |
| FCGE | A >= B | ucomisd xmm0,xmm1 + setae |
| FCLT | A < B | ucomisd xmm1,xmm0 + seta |
| FCLE | A <= B | ucomisd xmm1,xmm0 + setae |
| **CALLI** | Call indirect via RAX | POP_RAX + db 0xFF,0xD0 (session 25 avril) |

### Pièges encodage SSE2 rencontrés

- `dq double val` : fasmg ne supporte pas `double`, utiliser `dq val`
- `dq 0x8000000000000000` : fasmg tronque les constantes hex 64 bits,
  écrire les octets en `db` little-endian
- `movq xmm, [rbp]` : ambigu avec movd (32 bits) dans certains contextes,
  **toujours utiliser `movsd`** (F2 0F 10/11) pour les transferts mémoire↔xmm
- FCLT/FCLE : `ucomisd xmm1, xmm0` → ModRM = 0xC8 (pas 0xC9 qui
  donnerait ucomisd xmm1, xmm1)
- FNEG/FABS : opérer directement sur l'octet de signe [rbp+7] en
  little-endian, pas via masque 64 bits


### 2.2 Mécanisme ADR par CALLI — accès aux données brutes (sessions 10 mai (2) et (3))

#### Problème résolu

Pour `DIRECT_IO` et `SEQUENTIAL_IO`, les syscalls `SYS_FILE_WRITE` et
`SYS_FILE_READ` ont besoin de l'adresse des **octets bruts** de `ITEM`.
La convention de passage Ada génère une asymétrie fondamentale :

- Paramètre `in` scalaire : passé **par valeur** (copie sur la pile).
  `LVa` donne l'adresse de cette copie locale — correct pour WRITE.
- Paramètre `out` scalaire : passé **par référence** (adresse de la
  variable destination). `LVa` donne l'adresse du slot contenant
  l'adresse — il faut déréférencer une fois.
- Paramètre composite (`in` ou `out`) : passé par doublet descripteur
  `(_disp, __u)`. `LVa` donne l'adresse du doublet — il faut extraire
  `data_ptr` (offset 0).

#### Solution : deux micro-procédures `__in_adr` et `__out_adr`

Chaque instanciation génère dans son elab_spec deux micro-procédures
supplémentaires, en plus de `LD`, `ST` et `ADR` :

**Pour un type scalaire :**
```asm
__in_adr_TYPE.elab:
    RTD 0               ; LVa a déjà empilé l'adresse correcte (copie locale)

__out_adr_TYPE.elab:
    La -1, 0            ; déréférence : adresse du slot → adresse réelle destination
    RTD 0
```

**Pour un type composite (record, array) :**
```asm
__in_adr_TYPE.elab:
    La -1, 0            ; extrait data_ptr (offset 0 du doublet)
    RTD 0

__out_adr_TYPE.elab:
    La -1, 0            ; idem — même mécanisme dans les deux sens
    RTD 0
```

Le GFP du modèle générique contient donc 5 PRM :
`__u_ofs` (8), `__ld_ofs` (16), `__st_ofs` (24),
`__in_adr_ofs` (32), `__out_adr_ofs` (40).

Dans le body Ada, WRITE appelle `WRITE_SYSTEM_CALL(..., ITEM'ADDRESS)`
où `CODE_ADDRESS` émet `LVa` + CALLI via `__in_adr_ofs`, et READ
appelle `READ_SYSTEM_CALL(..., ITEM'ADDRESS)` où `CODE_ADDRESS` émet
`LVa` + CALLI via `__out_adr_ofs`. Dans les deux cas `READ/WRITE_SYSTEM_CALL`
accèdent à l'adresse réelle via `La 2, -OFS`.

#### `LD` et `ST` composites

Toujours marqués **`A REVOIR`** dans `expander-declarations.adb`
(corps provisoires `LI 0` / `DROP`). Non nécessaires pour DIRECT_IO
et SEQUENTIAL_IO qui utilisent `ITEM'ADDRESS` directement.




### 2.1 Mécanisme LD/ST par CALLI (session 25 avril)

#### Problème résolu

Dans un modèle générique, le paramètre formel de type discret a
`CD_IMPL_SIZE = INTG_SIZE * 8 = 32 bits` (dword). Mais le type actuel
(ex: COULEUR avec 3 valeurs) peut n'avoir que 8 bits (byte). Le store
indirect `SId` écrit 4 octets et corrompt les variables adjacentes.

#### Architecture

Chaque instanciation d'un générique avec type formel discret (`(<>)`)
génère deux micro-procédures de taille correcte (LD et ST) dans
l'elab_spec de l'instance. Leurs adresses sont passées au modèle via
le GFP. Le modèle appelle ST via CALLI pour les affectations aux
paramètres `out` de type formel.

#### Côté instance (expander-declarations.adb)

```asm
; Micro-procédures contournées par BRA pendant l'élaboration
BRA post_LD_COULEUR
LD_COULEUR.elab:
    Lb -1, 0            ; load byte (taille du type actuel)
    RTD 0
post_LD_COULEUR:
BRA post_ST_COULEUR
ST_COULEUR.elab:
    SIb -1, 0           ; store indirect byte
    RTD 0
post_ST_COULEUR:

; VAR en ordre INVERSE des PRM du modèle (correspondance miroir)
VAR COULEUR__st_ofs, q       ; GFP_disp - 24  ↔  PRM offset 24
    LCA ST_COULEUR.elab
    Sa 1, COULEUR__st_ofs
VAR COULEUR__ld_ofs, q       ; GFP_disp - 16  ↔  PRM offset 16
    LCA LD_COULEUR.elab
    Sa 1, COULEUR__ld_ofs
VAR COULEUR__u_ofs, q        ; GFP_disp - 8   ↔  PRM offset 8
    LCA COULEUR.SIZ
    Sa 1, COULEUR__u_ofs
VAR GFP_disp, q              ; référence (offset 0, marqueur d'adresse)
```

#### Côté modèle (expander-structures.adb)

```asm
namespace ENUMERATION_IO
PRMS
    PRM ENUM__u_ofs            ; offset 8  → accédé via -8
    PRM ENUM__ld_ofs           ; offset 16 → accédé via -16
    PRM ENUM__st_ofs           ; offset 24 → accédé via -24
endPRMS
```

#### Store via CALLI (expander-instructions.adb, STORE_OR_CALLI)

```asm
    LVa 1, -ITEM_ofs          ; @param_out (adresse du paramètre)
    Ld 2, REP_disp             ; valeur à stocker
    La 1, -GFP_ofs             ; adresse de GFP_disp
    La , -ENUM__st_ofs          ; [GFP_disp - 24] = adresse de ST
    CALLI                       ; appel indirect → SIb + RTD
```

#### Convention miroir PRM/VAR

Les PRM du namespace du modèle (offsets croissants : 8, 16, 24...)
correspondent aux VAR de l'instance en **ordre inverse** avant
GFP_disp (offsets décroissants : -8, -16, -24...).

Le premier PRM (offset 8, accédé via -8) correspond à la **dernière**
VAR avant GFP_disp (GFP_disp - 8). Le GFP_disp est un simple marqueur
d'adresse dont le contenu n'est pas utilisé.


## 3. TEXT_IO — état actuel (LRM 14.3)

TEXT_IO.FINC est **généré par l'EXPANDER**. Le fichier compile,
assemble et fonctionne. Programme de test IO_TEST validé (11 sections).
Programme ENUM_TEST validé (17 sections, session 25 avril).

### Architecture des GET/PUT

Principe : la version avec FILE est la version **centrale** qui fait
le travail (test `FILE.ID = -1` pour console/fichier). Les versions
sans FILE sont de simples délégations :

| Sans FILE              | Délègue à                            |
|------------------------|--------------------------------------|
| `GET(CHAR)`            | `GET(DEFAULT_INPUT, CHAR)`           |
| `GET(STRING)`          | `GET(DEFAULT_INPUT, STRING)`         |
| `GET_LINE(ITEM,LAST)`  | `GET_LINE(DEFAULT_INPUT,ITEM,LAST)` |
| `PUT(CHAR)`            | `PUT(DEFAULT_OUTPUT, CHAR)`          |
| `PUT(STRING)`          | `PUT(DEFAULT_OUTPUT, STRING)`        |
| `SKIP_LINE(SPACING)`   | `SKIP_LINE(DEFAULT_INPUT, SPACING)` |
| `SKIP_PAGE`            | `SKIP_PAGE(DEFAULT_INPUT)`           |
| `END_OF_LINE`          | `END_OF_LINE(DEFAULT_INPUT)`         |
| `END_OF_PAGE`          | `END_OF_PAGE(DEFAULT_INPUT)`         |
| `END_OF_FILE`          | `END_OF_FILE(DEFAULT_INPUT)`         |

### Procédures testées et fonctionnelles

**File Management (LRM 14.2.1) :**
- CREATE, OPEN, CLOSE, DELETE — avec syscalls Linux
  Réinitialisations dans CREATE/OPEN (session 25 avril).
- RESET(FILE, MODE), RESET(FILE) — via SYS_FILE_SET_POS (lseek)
- MODE, FORM, IS_OPEN — fonctionnels
- NAME — code Ada écrit mais retour de slice non implémenté dans l'expander
- SET_INPUT, SET_OUTPUT, STANDARD_INPUT/OUTPUT, CURRENT_INPUT/OUTPUT

**Line/Page/Column (LRM 14.3.4) :**
- NEW_LINE (2 versions), NEW_PAGE (2 versions)
- SKIP_LINE (2 versions), SKIP_PAGE (2 versions)
- END_OF_LINE, END_OF_PAGE, END_OF_FILE — avec mécanisme lookahead
- SET_LINE_LENGTH (2), SET_PAGE_LENGTH (2)
- LINE_LENGTH (2), PAGE_LENGTH (2)
- SET_COL (2), SET_LINE (2), COL (2), LINE (2), PAGE (2)

**Character/String I/O (LRM 14.3.5–14.3.6) :**
- GET(FILE, CHAR), GET(CHAR)
- PUT(FILE, CHAR), PUT(CHAR)
- GET(FILE, STRING), GET(STRING)
- PUT(FILE, STRING), PUT(STRING)
- GET_LINE (2 versions), PUT_LINE (2 versions)

**INTEGER_IO (LRM 14.3.7) :**
- GET(FILE, ITEM, WIDTH), GET(ITEM, WIDTH) — parse décimal avec signe
- PUT(FILE, ITEM, WIDTH, BASE), PUT(ITEM, WIDTH, BASE) — complet bases 2–16
- GET(FROM:STRING), PUT(TO:STRING) — corps vides

**FLOAT_IO (LRM 14.3.8) — sessions 11-13 avril :**
- PUT(FILE, ITEM, FORE, AFT, EXP) — format `[-]d.dddE[+|-]dd` ✓
- PUT(ITEM, FORE, AFT, EXP) — délègue à PUT(DEFAULT_OUTPUT,...) ✓
- GET(FILE, ITEM, WIDTH) — parse complet, **validé depuis fichier** ✓
- GET(ITEM, WIDTH) — délègue à GET(DEFAULT_INPUT,...) ✓
- GET(FROM:STRING), PUT(TO:STRING) — corps vides

**ENUMERATION_IO (LRM 14.3.10) — sessions 15 et 25 avril :**
- PUT(FILE, ITEM, WIDTH, SET) — format UPPER/LOWER_CASE ✓
- PUT(ITEM, WIDTH, SET) — délègue à PUT(DEFAULT_OUTPUT,...) ✓
- GET(FILE, ITEM) — parse insensible à la casse ✓
- GET(ITEM) — délègue à GET(DEFAULT_INPUT,...) ✓ (console fonctionnel)
- GET(FROM:STRING), PUT(TO:STRING) — corps vides
- Bloc IMAGES des littéraux d'énumérés via BEGIN_BLOC_DEF/END_BLOC_DEF ✓
- Patron de type via `__u_ofs` (SIZ, FST, LST, IMAGES) ✓
- Store dans paramètre `out` via mécanisme LD/ST par CALLI ✓


### Syscalls MACHINE_CODE — convention

Toute fonction MACHINE_CODE avec un syscall doit avoir un `SD` pour
transférer le résultat depuis `[rbp]` vers `result__ofs` :

| Syscall           | Convention pile              | SD offset |
|-------------------|------------------------------|-----------|
| SYS_FILE_CREATE   | @NAME_descriptor             | -16       |
| SYS_FILE_OPEN     | @NAME_descriptor             | -16       |
| SYS_FILE_CLOSE    | FILE_ID                      | -16       |
| SYS_FILE_DELETE   | @NAME_descriptor             | -16       |
| SYS_FILE_SET_POS  | OFFSET, FILE_ID              | -16       |
| SYS_FILE_READ     | LENGTH, @BUFFER, FILE_ID     | -16 ou -24|
| SYS_FILE_WRITE    | LENGTH, @BUFFER, FILE_ID     | -16 ou -24|

## Convention de représentation des composites (issue pièges 112-113)

CODE_EXP d'une expression composite laisse sur la pile d'opérandes :
  @DOUBLET  — objet entier (DN_USED_OBJECT_ID), appel de fonction
              (DN_FUNCTION_CALL), QUALIFIÉ (DN_QUALIFIED — amendement
              vague 2 du 28/07 : CODE_QUALIFIED laisse LVA _disp sur
              ses trois branches ; la règle unique portait le trou que
              deux sites locaux avaient déjà corrigé) ;
  @DATA nue — toute référence de composant (DN_INDEXED, DN_SELECTED,
              DN_ALL) ; DN_SLICE construit son doublet anonyme dans les
              chemins dédiés, mais CODE_EXP d'une tranche laisse
              @data, LEN (DEUX valeurs) : refus TROU posé dans
              CODE_COMPOSITE_DATA_ADDRESS.
Consommation : CODE_COMPOSITE_DATA_ADDRESS, jamais de La/La ,0
inconditionnel. Frontière de sous-programme : @doublet exclusivement
(arguments via SELARG/INDARG pour les composants, slot résultat =
@doublet caller-alloué — record : __dat statique ; tableau contraint :
CO_VAR à SIZ runtime). Le résultat composite revient dans le slot
conservé par RTD prm_siz-8.

## Miroir de layout (issu piège 110)

Toute grandeur de layout calculée côté Ada (taille, offset, stride,
CD_IMPL_SIZE) reproduit EXACTEMENT ce que les macros fasmg font
(STATOFS + align_*, pas d'arrondi final). Au premier écart : pas
d'erreur de compilation — un écrasement mémoire silencieux à
l'exécution. Un seul helper d'alignement (ALIGN_STATIC_BITS), trois
sites, zéro calcul parallèle nouveau sans son test-miroir.

## 8. Discipline des témoins et des livraisons (5 juillet 2026)

### Témoins auto-jugeants

Un témoin ne DOIT pas se contenter d'imprimer : il compare chaque valeur
produite à sa valeur attendue et rend un verdict lisible par le filet.

Forme canonique (cf. ENUM_TEST) :
- un compteur `NB_OK` / `NB_ECHECS` ;
- une procédure `CHECK(OK : BOOLEAN; SECTION, NUMERO : INTEGER)` qui
  incrémente et, sur échec, imprime `* ECHEC section S test N` ;
- en clôture : `RESULTAT : … OK, … ECHECS` puis une ligne verdict
  greppable `<TEST> PASSE` ou `<TEST> ECHOUE` ;
- sections interactives (GET console) placées APRÈS le verdict, pour ne
  pas bloquer un filet automatisé ; alimentables par pipe.

Le filet devient : exécuter, `grep -L "PASSE"`. Justification empirique :
la régression du NOT scalaire est restée invisible deux semaines parce que
l'ancien enum_test imprimait sans juger ; le passage au format auto-jugeant
l'a chiffrée (31/41) au premier lancement. Les valeurs non capturables en
mémoire (cadrage console avec WIDTH) restent des sections visuelles
explicitement étiquetées, avec l'attendu dans la bannière.

Conversion progressive des témoins existants (array_test1/2, record_test1/2,
direct_io_test…) au fil des piliers qui les touchent — pas de refonte de
masse.

### Livraison des correctifs

Mode par défaut : INSTRUCTIONS de patch (emplacement, ancre, bloc à
insérer/retirer, motif en une ligne), appliquées et RELUES par le
mainteneur. Le mainteneur est l'élément lent qui voit ; la relecture forcée
est une fonctionnalité de sûreté, pas un surcoût. Livraison de fichier
complet uniquement sur demande explicite, et alors diff-ée contre la version
locale avant écrasement (cf. piège n° 66). Rafraîchir les sources projet
juste avant chaque lot.

## Resultat de fonction NON CONTRAINT (C7, 01/08)

Le resultat doublet se materialise PAR le corps A TRAVERS le slot :
l'appelant alloue le doublet anonyme (+ bloc info, __u pre-pointe),
pousse LVA anon_disp ; le CODE_RETURN du corps ecrit data_ptr a
[slot]+0 et BLKMOV le descripteur 16 octets vers [[slot]+8] ;
RTD prm_siz-8 laisse le slot. Tout WRAPPER (instanciation) RELAIE son
slot recu au modele — jamais de lieu factice pour un resultat
composite (piege n 123). Data du resultat : co-pile de l'appele,
promue (UNLINK ne redescend pas r14).

## Clause d'adresse d'objet = OVERLAY (C8, 01/08)

Traitee a la DECLARATION via SM_ADDRESS (pose par sem), rien au site
de la clause. Mecanisme par SORTE de cible (grille n 124) : equation
fasmg (meme sorte + meme frame), LVA @slot (composite sur scalaire),
doublet-parametre (La <niv cible>,-ofs / La ,0 — modes in et in out).
__u de l'alias = descripteur de SA vue (la reinterpretation). Init a
travers l'overlay : agregat seulement, sans allocation.
