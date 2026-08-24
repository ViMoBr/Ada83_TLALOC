# NOTE — SUBSET FASMG DE LA CHAÎNE FINC (recensement v2)

v2 (19 août 2026) : intègre tout ce que les tranches TC-02..TC-07 ont
ÉTABLI SOUS ORACLE (quadruple byte-diff muet, exécutions conformes).
Chaque correction est tracée vers le témoin qui l'a imposée. Remplace
la v1, qui était devenue MATÉRIELLEMENT FAUSSE par endroits (USEINFO,
STR, unités STATOFS) et muette sur des acquis payés (point-séparateur,
tête canonique, labels de macros).

CHANGEMENTS v1 → v2 :
- §1.1 : le point final des préfixes CALL/LSPA est LE SÉPARATEUR
  (TC-07c) ; USEINFO a TROIS opérandes (TC-05) ; VAR n,c,k réserve k
  UNITÉS (TC-03) ; RTD prend prm_siz nom ou littéral.
- §1.2 : tête canonique STANDARD = 'STANDARD' + frame de niveau 0
  (TC-07f, DIS_BONJOUR faisant foi) ; les gardes n° 97 vivent dans
  STANDARD (TC-02f) ; includes codi_* sautés (TC-04).
- §2.2 : STATOFS en OCTETS (TC-03) ; labels elab/post internes aux
  macros (TC-03/07) ; Q7 pile-vs-chaînage instrumentée.
- §2.3 : LIFO CONFIRMÉ au byte-diff ; STR = NAMESPACE à 8 membres
  (TC-05) ; marques lazy booléennes côté TARGET_CODE (asymétrie).
- §2.5 : sélections disp confirmées au cmp (TC-06) ; suspect codi
  lvl>15 consigné.
- §2.6 : prologue 82 octets ; O_TRUNC sur SYS_FILE_CREATE (CODI-01).
- §3/§4 : état réalisé de TARGET_CODE (tranches, plages rejouables).
- §5 : Q5 CLOSE ; hiérarchie des oracles DÉMONTRÉE ; conformité
  d'ENTRÉE ajoutée aux oracles.
- §0 (nouveau) : fondations STANDARD (largeurs des types).

Objet, méthode, principe directeur : inchangés depuis la v1 — le
langage à implanter est le LANGAGE FINC, à vocabulaire CLOS ; fasmg
reste l'implémentation de référence et l'oracle différentiel.


## 0. FONDATIONS STANDARD (établi TC-04c — hypothèse v1 corrigée)

INTEGER = 32 bits ; LONG_INTEGER = 64 bits ; FLOAT digits 6 ;
LONG_FLOAT digits 15 (= IEEE double). Conséquences : VALUE_TYPE de
TARGET_CODE = LONG_INTEGER ; littéraux LIF = LONG_FLOAT ; l'évaluateur
travaille en 64 bits. Toute nouvelle unité qui suppose une largeur la
VÉRIFIE contre standard (le byte-diff a payé pour apprendre ça).


## 1. RECENSEMENT A — ce que les FINC contiennent (langage d'entrée)

### 1.1 Lignes de macros LLIR
Une invocation par ligne : `MNEMO  arg, arg, ...`. ~120 macros
publiques (les ancillaires PUSH_RAX, FETCH_*, QUAD_CONST, RV_BRANCH…
ne sont JAMAIS écrites dans les FINC — usage interne).

Syntaxes d'arguments :
- entiers décimaux signés (`LI -5`, `LVa 1, -24`) — jusqu'à 64 bits ;
- littéraux flottants décimaux (`LIF 3.14`) — IEEE double
  (LONG_FLOAT), conversion à la charge de TARGET_CODE ;
- ARGUMENTS VIDES à virgules conservées : `LIa , , ofs`, `Ld , FIELD`
  (défauts lvl:-1, disp:0, ofs:0) ;
- noms simples et POINTÉS : `X_disp`, `_OBJ__type.FST_1`,
  `STANDARD.ce_raise_`, `STR_L235.data_ptr` ;
- expressions d'opérandes : `ptr+disp`, `exc_ctx + _CTX.DISPATCH` ;
- paires `prefix, subname` pour CALL/LSPA — LE PRÉFIXE PORTE UN POINT
  FINAL : c'est LE SÉPARATEUR de la concaténation `#` de fasmg
  (`CALL STANDARD.TARGET_CODE_L1.EMITS. ,B_L18`). La forme nue soude
  les lexèmes (STANDARDSP7) : ERREUR fasmg, et TARGET_CODE produit le
  MÊME verdict depuis TC-07c — l'assembleur natif n'est jamais plus
  indulgent que la référence (leçon : l'ACCEPTATION D'ENTRÉE fait
  partie de la conformité) ;
- USEINFO lvl, field_name, load_instruc& : TROIS opérandes, le
  troisième est une INSTRUCTION COMPLÈTE embarquée (réserve
  field_name__u, émet load_instruc puis Sa lvl, field_name__u) —
  le NOM est l'opérande 2 (TC-05 ; la v1 se trompait) ;
- VAR nom, c, k : k UNITÉS de largeur c (b/w/d/q → align idem) ;
  c LITTÉRAL = k absent, taille en octets, align_q ; défaut k=1
  (`VAR exc_ctx_L233, q, 11` = 11 qwords) ;
- RTD p : p = littéral ou nom (prm_siz) ;
- chaînes quotées pour STR ('' double = un ').

### 1.2 Directives structurelles et TÊTE CANONIQUE
| Construction | Émetteur | Rôle |
|---|---|---|
| `namespace N` / `end namespace` | tête .fas, PRO/STR/endPRO | portée hiérarchique |
| `include 'chemin'` | tête .fas, with, ferm. transitive, corps | inclusion |
| `if ~ definite S` / `if defined S` / `end if` | gardes n° 97, lazy | inclusion conditionnelle |
| `NAME = 'NAME'` | tête de FINC d'unité, tête .fas | symbole de garde (valeur indifférente) |
| `virtual at 0/8` / `end virtual` | types_decls, structures, tête | zones de layout |
| `STATOFS nom, siz, algn` | types_decls | offsets de composants |
| `label:` | ret_lbl:, L<n>, begin: | cibles de branchement |
| `display '...', 10` / `hexa_show '...', $` | traces, carto | MAP — sous option |
| `;` commentaire, `; EXL Lnn` | partout | ignorer |

TÊTE CANONIQUE du .fas (DIS_BONJOUR faisant foi, TC-07f) :
```
include 'codi_<cible>.finc'          <- SAUTÉ par TARGET_CODE (le codi
STANDARD = 'STANDARD'                   est son implémentation) : le
namespace STANDARD                      MÊME .fas nourrit les deux
  virtual at 8                          assembleurs, l'oracle est cmp
    VARzone::
  end virtual
	LINK	0, loc_siz           <- frame de NIVEAU 0
```
- `STANDARD = 'STANDARD'` AVANT le namespace : NÉCESSAIRE à la
  convergence du lazy fasmg (constat empirique ; raison profonde à
  documenter). TARGET_CODE n'en a PAS besoin (son atteignabilité
  converge sans) mais doit l'ACCEPTER : garde et namespace COEXISTENT
  sur le même nom, DANS LES DEUX ORDRES (promotion garde→scope, et
  affectation tolérée sur scope — TC-07f). Asymétrie bénigne
  consignée.
- Les gardes n° 97 des FINC d'unités s'exécutent DANS namespace
  STANDARD : elles y sont déclarées, et les `~definite` du corpus les
  y trouvent par portée courante (TC-02f — interroger qualifié depuis
  la racine).
- Le token `VARzone::` et le frame de niveau 0 : PAS ENCORE lus par
  LEX — morceau identifié du jalon « avaler un FINC réel ».
- Fins de ligne : LF ; CR neutralisé (CRLF toléré) ; FF saut de page.

- "VARzone:: et frame de niveau 0 : LUS"
  (TC-08) ; noter la regle loc_siz de niveau 0 SANS align_q. Par 2.2 -
  frame 0 dans le modele pile. Par 5 - jalon FINC-reel : rayer le
  premier morceau ; restent USEINFO partie code, EXC_MACH/EXC_RAISE,
  puis l'unite reelle + miroirs (n 110, Q7 via DEBUG_LLIR).

### 1.3 Subset NÉGATIF (constaté absent — à NE PAS implanter)
Inchangé v1 : pas de struc/esc, pas de définition de macros dans les
FINC, pas de match/irp/iterate/calminstruction, pas de sections ni
formats objets, repeat hors align_*, arithmétique au-delà de
`+ - * / mod` — l'évaluateur 64 bits à six opérateurs suffit
(CONFIRMÉ sur TC-02..07).


## 2. RECENSEMENT B — services fasmg internalisés dans TARGET_CODE

### 2.1 Namespaces hiérarchiques et résolution
Inchangé v1 (remontée des PARENTS uniquement, jamais les frères —
piège n° 105 ; noms pointés = navigation depuis une racine trouvée
par remontée). EN SERVICE et exercé par tous les témoins. Ajouts :
réouverture cumulative ; coexistence garde↔namespace (§1.2).

### 2.2 Zones virtuelles de layout — RÈGLES RELUES AU CODI (TC-03)
- PRMS ouvre PRMzone à 8 ; PRM : `name_ofs = $`, dq (⇒ +8) ;
  endPRMS : `prm_siz = $-8`.
- ELB lvl : déclare le label `elab` ICI (avant le LINK qu'elle émet —
  c'est la cible des CALL), ouvre VARzone à 8, émet LINK lvl, loc_siz
  (référence avant, résolue par le layout).
- VAR : align par caractère (b/w/d/q), taille littérale = octets +
  align_q ; k unités (§1.1).
- USEINFO : réserve `field_name__u` (align_q, +8) PUIS émet du code
  (l'instruction embarquée + Sa) — la partie code est dimensionnée
  par EMITS (pas encore en tranche).
- endPRO : déclare le label `post` ICI (cible du BRA de PRO), align_q,
  `loc_siz = $`, ferme le namespace.
- PRO : namespace + BRA post — le CONTOURNEMENT D'ÉLABORATION : les
  corps sont inclus pendant l'élaboration, AVANT leurs appelants ; le
  flot les enjambe (dans le .fas réel, l'ENTRÉE du programme tombe
  sur un BRA de PRO).
- STATOFS nom, siz, algn : OCTETS partout (réservation rb siz ;
  algn ∈ {1,2,4,8} octets ; repli par taille si 0 : >4:q, >2:d,
  >1:w). Le « miroir en bits » du piège n° 110 est interne à
  l'expander ; l'interface FINC est en octets. TARGET_CODE est la
  TROISIÈME implémentation du calcul — vérifiée à la main (TC-03),
  test-miroir contre fasmg à rejouer sur FINC réel.
- Q7 (OUVERTE) : VARzone des sous-programmes IMBRIQUÉS — fasmg
  rebinde VARzone:: à chaque ELB ; TARGET_CODE implémente le modèle
  PILE (une zone par frame). Oracle de tranchement prêt :
  DEBUG_LLIR = 1 fait afficher chaque loc_siz par fasmg — comparer
  sur une unité imbriquée dès le jalon FINC-réel. Bascule = une ligne.

### 2.3 Différés — SÉMANTIQUE CONFIRMÉE AU BYTE-DIFF (TC-05)
LIFO strict : dernier enregistré, premier émis — après le code,
alignement qword, bourrage 16#90# (x86). CONFIRMÉ octet pour octet
(cmp TC_REF5, y compris une fuite qui a elle-même respecté le LIFO).

STR name,'bytes' crée un NAMESPACE à 8 membres :
```
name.data_ptr  dq  @data        (base du bloc, = ce que LCA empile)
name.info_ptr  dq  @info
name.info      dd  8*len, 8, 1, len
name.data      db  les octets   (@ = data_ptr + 32)
name.SIZ/COMP_SIZ/FST_1/LST_1 = 0/4/8/12 (statiques)
```
CST name,c,val : align par unité c, d-c val. Les deux DIFFÉRÉS.

Lazy : fasmg pose `SYM_ = SYM.elab` en postpone ; TARGET_CODE marque
l'atteignabilité en P1 (point fixe borné) et résout DIRECTEMENT
`prefix.subname.elab` — les marques restent BOOLÉENNES (équivalence
stricte, un mécanisme de moins ; asymétrie consignée). Les gardes
lazy s'évaluent DANS LE SCOPE ESTAMPILLÉ de l'élément (TC-02f).
DÉMONTRÉ TC-07 : multipasse fasmg et atteignabilité P1 produisent
LES MÊMES OCTETS, contournements d'élaboration compris.

### 2.4 Références avant, évaluation, refus
Inchangé v1, avec l'inventaire exercé : BRA/BT avant, loc_siz (LINK
de ELB), ASM_SIZE (en-tête ELF + base de co-pile), post (BRA de PRO),
.elab (CALL/LSPA). `assert`/`err` : refus bruyants conservés.

### 2.5 Sélection d'encodage et FORME CANONIQUE — CONFIRMÉ (TC-06/07)
Inchangé v1 sur le fond ; désormais EXERCÉ sous cmp : disp0/8/32
(FETCH/STORE/LEA), LINK alloc8/32, RTD 1/5/8, display petit/grand
niveau. Les opérandes symboliques (X_disp, loc_siz, ptr+disp) sont
résolus PAR SIZE_OF — ce sont des OFFSETS posés par le layout, jamais
des adresses : l'invariant tient, et VALUE_OF lève si une phase a été
sautée (garde anti bug de phase). CALL = E8 rel32 (5, fixe) ;
LSPA = movabs .elab (18, canonique) ; formes canoniques inchangées
pour ARM/RISC-V (à transcrire au retarget).

SUSPECT CODI CONSIGNÉ (jamais exercé, transcrit FIDÈLEMENT des deux
côtés) : mise à jour du display, branche lvl > 15 — ModRM 6F + dd
(forme disp8 avec un dd ; la forme disp32 serait AF). À auditer DES
DEUX CÔTÉS à la fois, avec témoin, le jour où lvl > 15 existera.

### 2.6 Amorçage et image binaire (par cible) — TRANSCRIT (TC-04)
ELF64 (64) + Phdr unique PT_LOAD RWX (56), org 0x400000, entrée
0x400078 ; e_machine 62/183/243 ; p_filesz = ASM_SIZE ;
p_memsz = ASM_SIZE + 16 Gio (co-pile) — ATTENTION : 16 Gio = 2^34,
hors gamme INTEGER : contournement KILO en attendant le plieur
(fold64/foldrej). Prologue x86 : 82 octets (xor rax ; mmap tas
64 Mio → r12 ; pile montante −4 Mio, display 32 niveaux r15, rbp,
FP0 ; co-pile r14 = ENTRY + 8*ceil(ASM/8), r13). Bourrage align_* :
0x90 x86, 0x00 ARM/RISC-V. SYS_FILE_CREATE : flags 0x242
(O_CREAT|O_RDWR|O_TRUNC — CODI-01, témoin trunc_test ; CREATE Ada =
fichier NEUF) — la table TARGET_CODE reprendra 0x242.


## 3. VOCABULAIRE LLIR — ÉTAT DE LA TABLE x86 DE TARGET_CODE

IMPLÉMENTÉ SOUS CMP (tranches TC-04..07) : DROP DUP LI ADD SUB MUL
BRA SYS_EXIT ; LCA SYS_PUT_STR STR CST (différés LIFO) ; LINK UNLINK
La Lq Ld Lb Sa Sq Sd Sb LVa CEQ BT ; CALL CALLI RTD LSPA PRO ELB
endPRO (+ PRMS PRM endPRMS VAR STATOFS en taille zéro). Zéro octet
d'écart sur quatre binaires ; exécutions conformes (okAH, verdicts
par code de sortie).

RESTANT (transcription réglée, une famille par livraison sous cmp) :
arith./logique complète (DIV REM NEG AND OU OUX NOT SHL SHR SAR…) ;
comparaisons restantes (CNE CGT CGE CLT CLE, INC, CLAMP0, BF) ;
charges/rangements manquants (Lw Sw, non-signés UL*, indirects
LI*/SI*/ULI*, LIVa) ; champs de bits (UBFX SBFX BFI) ; blocs
(BLKMOV BLKCMP BLKAND/OU/OUX/NOT, LEXCMP) ; flottant (F*, CVT*,
FC*) ; OVER ; exceptions (EXC_MACH, EXC_RAISE) ; SYS_* restants ;
USEINFO (partie code, instruction embarquée) ; CO_VAR, HEAP_ALLOC,
BEGIN/END_BLOC_DEF.

État des cibles : inchangé v1 (x86 référence ; ARM point fixe +
filet partiel sur Orange Pi ; RISC-V synchronisé NON TESTÉ —
méfiance).


## 4. ARCHITECTURE DE TARGET_CODE — RÉALISÉE

Les sept points d'arbitrage v1 tiennent ; l'état concret :
- Cinq paquetages à corps separate : LEX (P0 : parse, effets
  structurels, gardes deux régimes, saut codi_*), SYMBOLS (table +
  portées + marques + coexistence garde/namespace), IR (éléments
  estampillés scope + lazy, opérandes 64 bits), PASSES (P1
  atteignabilité GLOBALE idempotente ; P2 layout PAR PLAGE),
  EMITS (P2B adressage + P3 émission PAR PLAGE, différés filtrés
  par plage, auto-contrôles : en-tête 0x78, prologue 82, octets
  émis = SIZE_OF par élément, ASM cohérent P2B/P3, placement
  différés cohérent).
- Les PLAGES (FROM, TO) sont l'outil de rejouabilité des témoins ;
  le pilote de production appellera (1, ELT_COUNT).
- Leçon de méthode gravée : quand tous les invariants internes
  tiennent et que l'observable diverge, chercher ENTRE le programme
  et l'observation (fossiles de fichiers, CREATE sans TRUNC).


## 5. ORACLES — HIÉRARCHIE DÉMONTRÉE

(a) BYTE-DIFF contre fasmg : l'oracle suprême, DÉMONTRÉ — il a vu un
p_memsz amputé de 16 Gio invisible à l'exécution (pages arrondies par
le noyau) et des fossiles de fichiers que trois garde-fous internes
unanimes ne pouvaient pas voir. Même .fas pour les deux assembleurs
(saut codi_*). Au premier écart : offset + hexdump, bissection.
(b) CONFORMITÉ D'ENTRÉE (nouveau, TC-07c) : fasmg juge aussi le
LANGAGE — un .fas que fasmg refuse doit échouer chez TARGET_CODE
(la forme nue des préfixes l'a prouvé). Les témoins passent par les
DEUX assembleurs, pas seulement leurs octets.
(c) Filet des témoins auto-jugeants + verdicts par code de sortie.
(d) Point fixe : T2 assemblé par TARGET_CODE recompile les 63 unités
à l'identique — l'entrée de TARGET_CODE sous l'oracle suprême.

Questions :
- Q5 : CLOSE — les différés lazy n'émettent aucun octet ; leur rang
  LIFO n'affecte pas le placement des constantes (confirmé TC-05/07).
- Q6 : RÉSIDUEL — l'assert « adresses < 2^32 » est posé (P2B) ; la
  co-pile au-delà de 2^32 est réservée par p_memsz sans qu'aucune
  constante d'adresse n'y pointe ; vérifier une fois EXC_MACH /
  EXC_RAISE au moment de leur tranche.
- Q7 : OUVERTE (§2.2) — VARzone imbriquée, oracle DEBUG_LLIR prêt.
- Jalon FINC-réel : lire `VARzone::` et la tête de niveau 0 (§1.2),
  USEINFO partie code, puis avaler une unité du dépôt et rejouer les
  miroirs (n° 110, Q7) dessus.
  
  
