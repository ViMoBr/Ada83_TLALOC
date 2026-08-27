# BLOCS DE CLÔTURE — CAMPAGNE TARGET_CODE (TC-19 → TC-25, point fixe sans fasmg)
(24 août 2026 — quatre blocs à coller : JOURNAL_SESSIONS, PIEGES,
ETAT_PILIERS, ORACLES_TESTS. Numérotation des pièges à caler sur votre
compteur réel — je pars de n° 149.)

=====================================================================
## BLOC 1 — à coller en queue de JOURNAL_SESSIONS.md
=====================================================================

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

=====================================================================
## BLOC 2 — à coller en queue de PIEGES.md
=====================================================================

n° 149 — ELB OUVRE LE FRAME, PAS PRO. Au codi, PRO = namespace + BRA
post ; ELB = VARzone fraîche + elab: + LINK. La conflation « PRO ouvre »
tenait par accident (PRO toujours suivi d'ELB sur le petit corpus). Les
BLOCS Ada la brisent : namespace BLOCK__n / ELB n / … / endPRO, ELB
sans PRO. Règle : PRO_PENDING — l'ELB d'un PRO armé appartient au
sous-programme (PRMS déjà logés), un ELB orphelin pousse SON frame.
Signature du défaut : « endPRO hors sous-programme » avec FTOP à zéro,
plusieurs endPRO pour un seul PRO dans la même région paresseuse.
Gardien : TC_TEST19 (fonction interne gardée morte + deux blocs
imbriqués, verdicts exécutés).

n° 150 — LABELS POINTÉS : LA DÉTECTION AVANT LA DÉCLARATION. La tête de
ligne est scannée par NEXT_WORD (sans points) : sur « LD_ENUM.elab: »,
POS s'arrête au point, le test ':' échoue et la ligne devient un
pseudo-mnémonique (refus « hors tranche » TROMPEUR : le mot fautif est
un label raté, pas un mnémonique manquant). Deux volets indissociables :
lookahead [mot|'.'] avant le test du ':', PUIS déclaration éclatée
(ENTER_SCOPE par segment, USE_SCOPE de restauration). Gardien :
TC_TEST20 (thunk BRA post_X / X.elab: / ULB -1,0 / RTD 0, appelé par
CALLI nu).

n° 151 — L'ENTITÉ UNIQUE SYMBOLE/NAMESPACE (fasmg). Un même nom peut
être variable ET espace de noms : VAR X puis namespace X (ou l'inverse)
ne font qu'une entité — « namespace X » sur un X existant rouvre ses
enfants, définir X sur un namespace pose classe et valeur SANS perdre
les enfants. Relevé ADA_COMP : ANON_…_D_info (doublet d'info de type
anonyme, GRMR_OPS). Modèle : la descente pointée teste « possède des
enfants » (UNDER /= 0), pas « est un SCOPE_NAME » ; réouverture /
attachement / unification selon l'état, classe et valeur conservées ;
toute autre duplication reste refusée. Gardien : TC_TEST23 (les deux
ordres, lectures de la variable ET de ses enfants pointés).

n° 152 — REDÉFINITION SÉQUENTIELLE name = $ : LES ÉPOQUES. La macro VAR
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

n° 153 — L'ORACLE UNITAIRE fasmg, ET LA FAUTE LATENTE ULW. Méthode :
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

n° 154 — CONVENTIONS D'EXÉCUTION À CONSIGNER (TC-21, validées par cmp
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

=====================================================================
## BLOC 3 — ETAT_PILIERS.md (ligne de tableau + jalon)
=====================================================================

À insérer dans le tableau des piliers clos :

| **TARGET_CODE (assembleur natif LLIR/FINC → ELF64, remplaçant fasmg)** | **CLOS — POINT FIXE** : table EMITS = codi x86_64 entier (contrat SIZE_OF = ENCODE par élément, refus « hors tranche » en filet pour les extensions du codi) ; motifs du corpus compilateur acquis : blocs Ada (ELB sans PRO), labels pointés/thunks génériques, entité unique symbole/namespace, redéfinition séquentielle name = $ (époques), rq ; jauges CARTO + bornes calibrées (ADA_COMP : 765 721 éléments, 14 Mo de texte, 200 347 symboles, 10,3 Mo émis) ; **ADA_COMP byte-identique à fasmg, exécutable, et le compilateur assemblé par TARGET_CODE se recompile lui-même — chaîne intégralement auto-hébergée, assemblage ~3× plus rapide que fasmg** | **24 août 2026** — oracles TC_TEST04…25 (chaîne du pilote), avalements DIS_BONJOUR / ENUM_TEST / DIRECT_IO_TEST / SEQ_IO_TEST / ADA_COMP muets |

À ajouter au chapeau (dernière mise à jour / jalons) :

**24 août 2026 — POINT FIXE SANS fasmg** : TARGET_CODE assemble
ADA_COMP à l'identique, l'exécutable recompile ses propres sources ; la
référence fasmg passe du rôle d'outil à celui d'ORACLE DE RÉGRESSION
(cmp sur corpus figé). Vigie capacités : éléments à 77 % de la borne
(765 721 / 1 000 000) — au prochain élargissement du corpus, passer
ELT_MAX à 2 000 000 et OPS_MAX à 6 000 000.

=====================================================================
## BLOC 4 — à coller en queue de ORACLES_TESTS.md
=====================================================================

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
